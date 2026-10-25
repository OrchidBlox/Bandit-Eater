-- Presentation-only locomotion state machine. Never changes humanoid movement.
local Movement = {}
local NAMES = { "Start", "Stop", "Takeoff", "DoubleJump", "Fall", "LandRun", "LandIdle" }
local SUPPORTED = {
	[Enum.HumanoidStateType.Running] = true, [Enum.HumanoidStateType.RunningNoPhysics] = true,
	[Enum.HumanoidStateType.Jumping] = true, [Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.Landed] = true,
}

function Movement.new(animator, humanoid, runTrack, config, beforeRun, beforeTransition)
	local movement = { tracks = {}, animations = {}, run = runTrack, config = config,
		beforeRun = beforeRun, humanoid = humanoid, played = 0, interrupted = 0,
		fallbacks = 0, failedLoads = 0, last = "", loadedAt = os.clock() }
	for _, name in NAMES do
		local id = config.TransitionIds[name]
		if type(id) == "string" and string.match(id, "^rbxassetid://%d+$") then
			local animation = Instance.new("Animation")
			animation.Name, animation.AnimationId = "HeroSprint" .. name, id
			local ok, track = pcall(function()
				return animator:LoadAnimation(animation)
			end)
			if ok then
				track.Priority, track.Looped = Enum.AnimationPriority.Movement, name == "Fall"
				movement.tracks[name], movement.animations[name] = track, animation
			else
				animation:Destroy()
				movement.failedLoads += 1
			end
		end
	end

	function movement:Cancel(fade, interrupted)
		if self.active then
			self.active.track:Stop(fade or config.TransitionFade)
			self.active = nil
			if interrupted then
				self.interrupted += 1
			end
		end
	end

	function movement:Play(name, fade)
		if name == "Fall" then
			if self.fallAttempted then return false end
			self.fallAttempted = true
		elseif name == "Takeoff" or name == "DoubleJump" or name == "LandIdle" or name == "LandRun" then
			self.fallAttempted = false
		end
		self:Cancel(config.TransitionFade, true)
		local track = self.tracks[name]
		if not track or track.Length <= 0 then
			self.fallbacks += 1
			if (name == "Takeoff" or name == "DoubleJump") and runTrack.IsPlaying then
				runTrack:Stop(config.AirFade)
			end
			return false
		end
		if runTrack.IsPlaying then
			runTrack:Stop(config.AirFade)
		end
		beforeTransition(track)
		track:Play(fade or config.TransitionFade, 1, 1)
		track.TimePosition = 0
		self.active = { name = name, track = track, started = os.clock() }
		self.played += 1
		self.last = name
		return true
	end

	function movement:Run(speed, dt, fade)
		local target = math.clamp(speed / config.BaseSpeed, 0.35, 1.8)
		if not runTrack.IsPlaying then
			beforeRun()
			self.playbackSpeed = target
			runTrack:Play(fade or config.StartFade, 1, target)
			runTrack.TimePosition = 0 -- Start and LandRun end on the approved loop's contact pose.
		else
			local alpha = 1 - math.exp(-config.SpeedResponse * dt)
			self.playbackSpeed = (self.playbackSpeed or target) + (target - (self.playbackSpeed or target)) * alpha
			runTrack:AdjustSpeed(self.playbackSpeed)
		end
	end

	movement.connection = humanoid.StateChanged:Connect(function(_, nextState)
		if movement.destroyed then
			return
		end
		if nextState == Enum.HumanoidStateType.Jumping then
			movement.wasAirborne = true
			movement:Play("Takeoff", config.AirFade)
		elseif nextState == Enum.HumanoidStateType.Freefall then
			movement.wasAirborne = true
		end
	end)

	function movement:Update(shouldRun, speed, dt)
		if self.destroyed then
			return
		end
		local movementState = humanoid:GetState()
		local intent = humanoid.MoveDirection
		local airborne = movementState == Enum.HumanoidStateType.Jumping
			or movementState == Enum.HumanoidStateType.Freefall or humanoid.FloorMaterial == Enum.Material.Air
		if humanoid.Health <= 0 or not SUPPORTED[movementState] then
			self:Cancel(config.AirFade, true)
			if runTrack.IsPlaying then
				runTrack:Stop(config.AirFade)
			end
			self.wasMoving, self.wasAirborne, self.direction = false, false, nil
			return
		end
		for name, track in self.tracks do
			if track.Length <= 0 and os.clock() - self.loadedAt > 8 then
				track:Destroy()
				self.animations[name]:Destroy()
				self.tracks[name], self.animations[name] = nil, nil
				self.failedLoads += 1
			end
		end
		if airborne then
			self.wasAirborne, self.wasMoving = true, false
			if runTrack.IsPlaying then
				runTrack:Stop(config.AirFade)
			end
			local active = self.active
			local root = humanoid.RootPart
			local falling = root and root.AssemblyLinearVelocity.Y <= 0
			local risingClip = active and (active.name == "Takeoff" or active.name == "DoubleJump")
			if active and active.name ~= "Fall" and not risingClip then
				self:Cancel(config.AirFade, false)
				active = nil
			end
			if risingClip then
				-- Follow real airtime; never freeze physics to finish a pose.
				if (falling and os.clock() - active.started >= config.MinimumAirPoseTime
					and active.track.TimePosition >= active.track.Length - config.AirHoldLead) or not active.track.IsPlaying then
					self:Play("Fall", config.AirFade)
				elseif active.track.Length - active.track.TimePosition <= config.AirHoldLead then
					active.track:AdjustSpeed(0)
					active.track.TimePosition = math.max(0, active.track.Length - 0.001)
				end
			elseif not active then
				self:Play("Fall", config.AirFade)
			end
			return
		end
		local landed = self.wasAirborne == true
		self.wasAirborne = false
		local reversing = self.direction and intent.Magnitude > 0.01 and self.direction:Dot(intent.Unit) < -0.25
		if intent.Magnitude > 0.01 then
			self.direction = intent.Unit
		end
		if landed then
			local landingMoving = intent.Magnitude > 0.01 and speed > config.MinimumMovingSpeed
			self:Play(landingMoving and "LandRun" or "LandIdle", config.LandingFade)
		elseif self.active then
			local name = self.active.name
			if (name == "Start" or name == "LandRun") and intent.Magnitude <= 0.01 then
				self:Play("Stop", config.TransitionFade)
			elseif shouldRun and (name == "Stop" or name == "LandIdle" or (reversing and name == "Start")) then
				self:Play("Start", config.TransitionFade)
			end
		elseif shouldRun and not self.wasMoving then
			self:Play("Start", config.StartFade)
		elseif not shouldRun and self.wasMoving then
			self:Play("Stop", config.StopFade)
		end
		self.wasMoving = shouldRun
		local active = self.active
		if active then
			local handoff = active.name == "Start" or active.name == "LandRun"
			local remaining = active.track.Length - active.track.TimePosition
			local finished = not active.track.IsPlaying or os.clock() - active.started >= config.MaxTransitionTime
			if finished or (handoff and remaining <= config.TransitionFade) then
				self:Cancel(config.TransitionFade, false)
				if shouldRun then
					self:Run(speed, dt, config.TransitionFade)
				end
			end
		elseif shouldRun then
			self:Run(speed, dt, landed and config.LandingFade or config.StartFade)
		elseif runTrack.IsPlaying then
			runTrack:Stop(config.StopFade)
		end
	end

	function movement:Destroy()
		if self.destroyed then
			return
		end
		self.destroyed = true
		self.connection:Disconnect()
		for _, track in self.tracks do
			pcall(function()
				track:Stop(0)
			end)
			track:Destroy()
		end
		for _, animation in self.animations do
			animation:Destroy()
		end
		table.clear(self.tracks)
		table.clear(self.animations)
		self.active = nil
	end
	return movement
end

return Movement
