local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local Config = require(ReplicatedStorage.Shared.Config.Animations)
local Vfx = require(ReplicatedStorage.Shared.Config.Vfx)
local Controller = {}
local connections, bindings = {}, {}
local started, elapsed = false, 0
local stats = { emitted = 0, left = 0, right = 0, failedLoads = 0, lastMarker = "", lastSpeed = 0 }

local function assetNumber(id)
	return type(id) == "string" and string.match(id, "^rbxassetid://(%d+)$") or nil
end

local function disconnect(list)
	for _, connection in list do
		connection:Disconnect()
	end
	table.clear(list)
end

local function removeTrack(state, track)
	local listeners = state.tracks[track]
	if listeners then
		disconnect(listeners)
		state.tracks[track] = nil
	end
end

local function clearTracks(state)
	for track in state.tracks do
		removeTrack(state, track)
	end
	if state.runTrack then
		pcall(function()
			state.runTrack:Stop(Config.Fade)
		end)
		state.runTrack:Destroy()
		state.runTrack = nil
	end
	if state.animation then
		state.animation:Destroy()
		state.animation = nil
	end
end

local function cleanupCharacter(binding)
	local state = binding.state
	if not state then
		return
	end
	binding.state = nil
	state.dead = true
	disconnect(state.connections)
	if state.playedConnection then
		state.playedConnection:Disconnect()
	end
	if state.diedConnection then
		state.diedConnection:Disconnect()
	end
	clearTracks(state)
	for _, foot in state.feet do
		foot.attachment:Destroy()
	end
	table.clear(state.feet)
end

local function moving(state, requireInput)
	local humanoid, root = state.humanoid, state.character:FindFirstChild("HumanoidRootPart")
	if state.dead or not state.character:IsDescendantOf(workspace) or not humanoid
		or humanoid.Health <= 0 or humanoid.RigType ~= Enum.HumanoidRigType.R15
		or not root or not root:IsA("BasePart") then return false, 0 end
	local velocity = root.AssemblyLinearVelocity
	local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	local movementState = humanoid:GetState()
	return (movementState == Enum.HumanoidStateType.Running or movementState == Enum.HumanoidStateType.RunningNoPhysics)
		and humanoid.FloorMaterial ~= Enum.Material.Air and speed > Config.MinimumMovingSpeed
		and (not requireInput or humanoid.MoveDirection.Magnitude > 0.01), speed
end

local function emitter(state, side)
	local foot = state.character:FindFirstChild(side .. "Foot")
	if not foot or not foot:IsA("BasePart") or not assetNumber(Vfx.Textures.Puff) then
		return nil
	end
	local existing = state.feet[side]
	if existing and existing.attachment.Parent == foot then
		return existing.particle
	end
	if existing then
		existing.attachment:Destroy()
	end
	local attachment = Instance.new("Attachment")
	attachment.Name = "HeroSprintFootstep"
	-- Lift the sprite center slightly so the floor does not clip half of the cloud.
	attachment.Position = Vector3.new(0, -foot.Size.Y * 0.5 + 0.22, 0)
	local particle = Instance.new("ParticleEmitter")
	particle.Name, particle.Texture = "Puff", Vfx.Textures.Puff
	particle.Rate, particle.Enabled, particle.LockedToPart = 0, false, false
	particle.Lifetime, particle.Speed, particle.Drag = NumberRange.new(0.3, 0.4), NumberRange.new(0.5, 1), 4
	particle.Acceleration, particle.SpreadAngle = Vector3.new(0, 0.5, 0), Vector2.new(20, 20)
	particle.LightEmission, particle.LightInfluence = 0.1, 0
	particle.Color = ColorSequence.new(Color3.new(1, 1, 1))
	particle.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(0.4, 1.1), NumberSequenceKeypoint.new(1, 1.25) })
	particle.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(0.4, 0.2), NumberSequenceKeypoint.new(1, 1) })
	particle.RotSpeed, particle.EmissionDirection = NumberRange.new(-20, 20), Enum.NormalId.Top
	particle.Parent, attachment.Parent = attachment, foot
	state.feet[side] = { attachment = attachment, particle = particle }
	return particle
end

local function footstep(state, side)
	if side ~= "Left" and side ~= "Right" then
		return
	end
	local eligible = moving(state, state.player == Players.LocalPlayer)
	local root, camera = state.character:FindFirstChild("HumanoidRootPart"), workspace.CurrentCamera
	if not eligible or not camera or (camera.CFrame.Position - root.Position).Magnitude > Config.FootstepDistance then
		return
	end
	local particle = emitter(state, side)
	if not particle then
		return
	end
	particle:Emit(1)
	stats.emitted += 1
	if side == "Left" then
		stats.left += 1
	else
		stats.right += 1
	end
	stats.lastMarker = side
end

local function watchTrack(state, track)
	if state.dead or state.tracks[track] or not track.Animation
		or not assetNumber(Config.RunId) or assetNumber(track.Animation.AnimationId) ~= assetNumber(Config.RunId) then return end
	local listeners = {}
	state.tracks[track] = listeners
	table.insert(listeners, track:GetMarkerReachedSignal(Config.Marker):Connect(function(side)
		footstep(state, side)
	end))
	table.insert(listeners, track.Ended:Connect(function()
		if not track.IsPlaying then
			removeTrack(state, track)
		end
	end))
	table.insert(listeners, track.Destroying:Connect(function()
		removeTrack(state, track)
	end))
end

local function refreshAnimator(state)
	local humanoid = state.character:FindFirstChildOfClass("Humanoid")
	if humanoid ~= state.humanoid then
		if state.diedConnection then
			state.diedConnection:Disconnect()
		end
		state.humanoid = humanoid
		state.diedConnection = humanoid and humanoid.Died:Connect(function()
			cleanupCharacter(state.binding)
		end) or nil
	end
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		animator = nil
	end
	if animator ~= state.animator then
		if state.playedConnection then
			state.playedConnection:Disconnect()
		end
		clearTracks(state)
		state.animator, state.attemptedAnimator = animator, nil
		state.playedConnection = animator and animator.AnimationPlayed:Connect(function(track)
			watchTrack(state, track)
		end) or nil
		if animator then
			for _, track in animator:GetPlayingAnimationTracks() do
				watchTrack(state, track)
			end
		end
	end
	if state.player ~= Players.LocalPlayer or not animator or not assetNumber(Config.RunId)
		or state.attemptedAnimator == animator or not state.character:IsDescendantOf(workspace) then return end
	-- Use the replicated Animator; never create a client-only one or replace Animate.
	state.attemptedAnimator = animator
	local animation = Instance.new("Animation")
	animation.Name, animation.AnimationId = "HeroSprint", Config.RunId
	state.animation = animation
	local ok, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)
	if not ok then
		stats.failedLoads += 1
		animation:Destroy()
		state.animation = nil
		return
	end
	track.Priority, track.Looped = Enum.AnimationPriority.Movement, true
	state.runTrack, state.loadStarted = track, os.clock()
end

local function attachCharacter(binding, character)
	cleanupCharacter(binding)
	local state = { player = binding.player, binding = binding, character = character,
		connections = {}, tracks = {}, feet = {}, seenWorkspace = character:IsDescendantOf(workspace) }
	binding.state = state
	table.insert(state.connections, character.AncestryChanged:Connect(function()
		if character:IsDescendantOf(workspace) then
			state.seenWorkspace = true
		elseif state.seenWorkspace then
			cleanupCharacter(binding)
		end
	end))
	refreshAnimator(state)
end

local function unbindPlayer(player)
	local binding = bindings[player]
	if not binding then
		return
	end
	cleanupCharacter(binding)
	disconnect(binding.connections)
	bindings[player] = nil
end

local function bindPlayer(player)
	if bindings[player] then
		return
	end
	local binding = { player = player, connections = {} }
	bindings[player] = binding
	table.insert(binding.connections, player.CharacterAdded:Connect(function(character)
		attachCharacter(binding, character)
	end))
	table.insert(binding.connections, player.CharacterRemoving:Connect(function(character)
		if binding.state and binding.state.character == character then
			cleanupCharacter(binding)
		end
	end))
	if player.Character then
		attachCharacter(binding, player.Character)
	end
end

function Controller.debugStats()
	local result = table.clone(stats)
	result.boundCharacters, result.connections, result.tracks, result.emitters = 0, #connections, 0, 0
	result.currentTrackIsPlaying = false
	for _, binding in bindings do
		result.connections += #binding.connections
		local state = binding.state
		if state then
			result.boundCharacters += 1
			result.connections += #state.connections + (state.playedConnection and 1 or 0) + (state.diedConnection and 1 or 0)
			for _, listeners in state.tracks do
				result.tracks += 1
				result.connections += #listeners
			end
			for _, foot in state.feet do
				if foot.attachment.Parent then
					result.emitters += 1
				end
			end
			if binding.player == Players.LocalPlayer and state.runTrack then
				result.currentTrackIsPlaying = state.runTrack.IsPlaying
			end
		end
	end
	return result
end

function Controller.Stop()
	started = false
	disconnect(connections)
	for player in bindings do
		unbindPlayer(player)
	end
end

function Controller.Start()
	if started then
		return
	end
	started, elapsed = true, 0
	table.insert(connections, Players.PlayerAdded:Connect(bindPlayer))
	table.insert(connections, Players.PlayerRemoving:Connect(unbindPlayer))
	for _, player in Players:GetPlayers() do
		bindPlayer(player)
	end
	table.insert(connections, RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < Config.UpdateInterval then
			return
		end
		elapsed = 0
		for _, binding in bindings do
			-- A streamed-out remote character can return without CharacterAdded firing again.
			if not binding.state then
				local character = binding.player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if character and character:IsDescendantOf(workspace) and humanoid and humanoid.Health > 0 then
					attachCharacter(binding, character)
				end
			end
			local state = binding.state
			if not state or state.dead then
				continue
			end
			for side, foot in state.feet do
				if not foot.attachment:IsDescendantOf(state.character) then
					foot.attachment:Destroy()
					state.feet[side] = nil
				end
			end
			refreshAnimator(state)
			local track = state.runTrack
			if not track then
				continue
			end
			local shouldRun, speed = moving(state, true)
			stats.lastSpeed = speed
			if track.Length <= 0 then
				if os.clock() - state.loadStarted > 8 then
					stats.failedLoads += 1
					clearTracks(state)
				end
			elseif shouldRun then
				local playback = math.clamp(speed / Config.BaseSpeed, 0.35, 1.8)
				if not track.IsPlaying then
					watchTrack(state, track)
					track:Play(Config.Fade, 1, playback)
				else
					track:AdjustSpeed(playback)
				end
			elseif track.IsPlaying then
				track:Stop(Config.Fade)
			end
		end
	end))
	table.insert(connections, script.Destroying:Connect(Controller.Stop))
	table.insert(connections, script.AncestryChanged:Connect(function()
		if not script:IsDescendantOf(game) then
			Controller.Stop()
		end
	end))
	task.spawn(function()
		local assets = {}
		if assetNumber(Config.RunId) then
			local animation = Instance.new("Animation")
			animation.AnimationId = Config.RunId
			table.insert(assets, animation)
		end
		if assetNumber(Vfx.Textures.Puff) then
			local particle = Instance.new("ParticleEmitter")
			particle.Texture = Vfx.Textures.Puff
			table.insert(assets, particle)
		end
		pcall(function()
			ContentProvider:PreloadAsync(assets)
		end)
		for _, asset in assets do
			asset:Destroy()
		end
	end)
end

return Controller
