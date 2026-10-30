-- Anime-slick projectile (move 1 of every power except Fire, plus the big Skywheel and Meteor-style R shots). One
-- Codex-built hero mesh in three nested tints (shade, body, hot core) with a hard Highlight outline, thin speed
-- streaks, a windup lane on the floor showing the exact path, and radial impact lines with flung shards.
-- Presentation only: the server owns flight, hits and damage.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Kit = require(script.Parent.Parent.Kit)
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local SlickQ = {}

local INK = Color3.fromRGB(26, 20, 34)
local WHITE = Color3.new(1, 1, 1)
local NEON, SMOOTH = Enum.Material.Neon, Enum.Material.SmoothPlastic
local IMPACT_TIME = 0.45

-- mesh: template name in Assets.PowerMoves; size: its native size; back: studs the mesh centre trails behind the hit point;
-- spin: radians per second about the travel axis (0 = none); tumble: free spin for rocks; width: telegraph lane width.
SlickQ.CONFIG = {
	Wind = { mesh = "WindCrescent", size = Vector3.new(4, 1, 7), back = 2.4, width = 5 },
	Earth = { mesh = "BoulderShot", size = Vector3.new(3, 2.8, 3.6), back = 0, tumble = 5, width = 5, solid = true },
	Water = { mesh = "WaterLance", size = Vector3.new(2, 2, 8), back = 2.6, width = 5 },
	Sword = { mesh = "SlashCrescent", size = Vector3.new(6, 1, 9), back = 0, width = 5 },
	Shadow = { mesh = "ShadowArrow", size = Vector3.new(2.4, 2.4, 7), back = 2.2, width = 5 },
	Sword_Wind = { mesh = "SlashCrescent", size = Vector3.new(6, 1, 9), back = 0, width = 5 },
	Sword_Earth = { mesh = "SlashCrescent", size = Vector3.new(6, 1, 9), back = 0, width = 5 },
	Sword_Water = { mesh = "SlashCrescent", size = Vector3.new(6, 1, 9), back = 0, width = 5 },
	Sword_Fire = { mesh = "SlashCrescent", size = Vector3.new(6, 1, 9), back = 0, width = 5 },
	Sword_Shadow = { mesh = "DarkCrescent", size = Vector3.new(8, 1.5, 10), back = 0, width = 5 },
	Sword_Sword = { mesh = "SlashCrescent", size = Vector3.new(6, 1, 9), back = 0, width = 5, star = "CrownStar" },
}
-- Big shots on the third move (the server sends them as projectiles).
SlickQ.CONFIG_R = {
	Sword_Wind = { mesh = "SkywheelDisc", size = Vector3.new(8, 1, 8), back = 0, spin = 9, flat = true, width = 11 },
}

function SlickQ.Supports(power, key)
	if key == "R" then
		return SlickQ.CONFIG_R[power] ~= nil
	end
	return SlickQ.CONFIG[power] ~= nil
end

local function template(name)
	local library = ReplicatedStorage:FindFirstChild("Assets")
	library = library and library:FindFirstChild("PowerMoves")
	local item = library and library:FindFirstChild(name)
	return item and (item:IsA("MeshPart") and item or item:FindFirstChildWhichIsA("MeshPart", true))
end

local function ease(t)
	return math.sin(math.clamp(t, 0, 1) * math.pi / 2)
end

local function emitter(parent, texture, colors, size, lifetime, speed, extra)
	local e = Instance.new("ParticleEmitter")
	e.Texture, e.Color, e.Size = texture, colors, size
	e.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.4, 0.3), NumberSequenceKeypoint.new(1, 1) })
	e.Lifetime, e.Speed, e.Rate, e.Enabled = lifetime, speed, 0, false
	e.LightInfluence, e.LockedToPart, e.ZOffset = 0, false, 0.5
	for key, value in extra or {} do
		e[key] = value
	end
	e.Parent = parent
	return e
end

function SlickQ.Play(data, look)
	local power = data.Power
	local isR = data.Key == "R"
	local cfg = (isR and SlickQ.CONFIG_R or SlickQ.CONFIG)[power]
	local c = Visuals.Powers[power]
	local tpl = cfg and template(cfg.mesh)
	if not cfg or not c or not tpl or look.distanceFactor == 0 then
		return nil -- meshes not installed yet: the older effect plays instead
	end
	local K = isR and math.max(1, data.Radius / 5) or 1

	local group = Instance.new("Folder")
	group.Name = "SlickQ_" .. data.Token
	group.Parent = Kit.folder()
	Debris:AddItem(group, data.Duration + 2)
	local e = { group = group, position = data.Origin, caster = data.Caster, partCount = 0, meshFallbacks = tpl and 0 or 1 }

	local body = Instance.new("Model")
	body.Name, body.Parent = "Body", group
	local outline = Instance.new("Highlight")
	outline.Name, outline.Adornee, outline.FillTransparency, outline.OutlineColor, outline.OutlineTransparency = "Outline", body, 1, INK, 0
	outline.Parent = body

	local function newPart(parent, shape, color, material, transparency)
		local part = Kit.safePart(Instance.new("Part"))
		part.Shape, part.Color, part.Material, part.Transparency = shape, color, material, transparency
		part.Size = Vector3.one * 0.2
		part.Parent = parent
		e.partCount += 1
		return part
	end
	local function meshPart(name, color, material)
		local source = template(name)
		if not source then
			return nil
		end
		local part = Kit.safePart(source:Clone())
		part:ClearAllChildren()
		part.TextureID, part.Color, part.Material, part.Transparency, part.Parent = "", color, material, 1, body
		e.partCount += 1
		return part
	end

	-- Hero: shade shell, body, hot core (each a smaller copy of the same Codex mesh).
	local layers = {}
	if tpl then
		for i, spec in { { c.Shade, 1 }, { c.Body, 0.78 }, { c.Highlight, 0.52 } } do
			layers[i] = { part = meshPart(cfg.mesh, spec[1], NEON), scale = spec[2] }
		end
	end
	local starPart = cfg.star and meshPart(cfg.star, c.Accent or c.Highlight, NEON)

	-- Speed streaks, impact lines and a windup lane showing the exact path.
	local streaks, lines = {}, {}
	for i = 1, 5 do
		streaks[i] = newPart(group, Enum.PartType.Block, i % 2 == 0 and WHITE or c.Highlight, NEON, 1)
	end
	for i = 1, 10 do
		lines[i] = newPart(group, Enum.PartType.Block, i % 2 == 0 and WHITE or c.Highlight, NEON, 1)
	end
	local laneWidth = isR and data.Radius * 2 or cfg.width
	local laneLength = math.max(10, (data.Duration - (data.Delay or 0.18)) * data.Speed)
	local laneFill = newPart(group, Enum.PartType.Block, c.Body, NEON, 1)
	local laneEdges = { newPart(group, Enum.PartType.Block, c.Highlight, NEON, 1), newPart(group, Enum.PartType.Block, c.Highlight, NEON, 1) }
	local chevrons = {}
	for i = 1, 5 do
		chevrons[i] = newPart(group, Enum.PartType.Block, WHITE, NEON, 1)
	end
	-- Flung shards on impact (the element's own rock/crystal tint) and a flash star.
	local shards = {}
	for i = 1, 8 do
		local shard = meshPart("EmberShard", i % 2 == 0 and c.Shade or INK, SMOOTH)
		if shard then
			shards[i] = shard
		end
	end
	local burst = Kit.safePart(Instance.new("Part"))
	burst.Size, burst.Transparency, burst.Parent = Vector3.one * 0.3, 1, group
	local starBurst = emitter(burst, Config.Textures.Star, ColorSequence.new(c.Highlight), NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.8), NumberSequenceKeypoint.new(1, 0.2) }),
		NumberRange.new(0.45, 0.8), NumberRange.new(16, 30), { SpreadAngle = Vector2.new(180, 180), Drag = 4, Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-240, 240), LightEmission = 0.6 })
	local tail = Kit.safePart(Instance.new("Part"))
	tail.Size, tail.Transparency, tail.Parent = Vector3.one * 0.3, 1, group
	local trail = emitter(tail, Config.Textures.Star, ColorSequence.new(c.Highlight), NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.0), NumberSequenceKeypoint.new(1, 0) }),
		NumberRange.new(0.3, 0.55), NumberRange.new(2, 6), { SpreadAngle = Vector2.new(30, 30), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-200, 200), LightEmission = 0.5 })

	local function setLane(origin, direction, opacity)
		local flat = Vector3.new(direction.X, 0, direction.Z)
		flat = flat.Magnitude > 0.01 and flat.Unit or -Vector3.zAxis
		local floorPos = Vector3.new(origin.X, data.Origin.Y - 2.7, origin.Z)
		local lane = CFrame.lookAt(floorPos, floorPos + flat) * CFrame.new(0, 0.12, -laneLength * 0.5 - 1.5)
		laneFill.CFrame, laneFill.Size, laneFill.Transparency = lane, Vector3.new(laneWidth, 0.05, laneLength), 1 - 0.2 * opacity
		for i, edge in laneEdges do
			edge.CFrame = lane * CFrame.new((i == 1 and -1 or 1) * laneWidth * 0.5, 0.03, 0)
			edge.Size, edge.Transparency = Vector3.new(0.2, 0.08, laneLength), 1 - 0.95 * opacity
		end
		for i, chevron in chevrons do
			chevron.CFrame = lane * CFrame.new(0, 0.04, laneLength * (0.5 - i / 6))
			chevron.Size, chevron.Transparency = Vector3.new(laneWidth * 0.5, 0.06, 0.3), 1 - 0.8 * opacity
		end
	end

	local function setHero(cf, scale, opacity, time)
		local spin = cfg.spin and CFrame.Angles(0, 0, 0) or CFrame.identity
		if cfg.tumble then
			spin = CFrame.Angles(time * cfg.tumble, time * cfg.tumble * 0.7, 0)
		elseif cfg.spin then
			spin = CFrame.Angles(0, time * cfg.spin, 0)
		end
		for _, layer in layers do
			local part = layer.part
			if part then
				part.CFrame = cf * CFrame.new(0, 0, cfg.back * K * scale) * spin
				part.Size = cfg.size * K * scale * layer.scale
				part.Transparency = 1 - opacity
			end
		end
		if starPart then
			starPart.CFrame = cf * CFrame.new(0, 0.6 * K, -cfg.size.Z * 0.5 * K * scale) * CFrame.Angles(0, 0, time * 4)
			starPart.Size = Vector3.new(3, 0.6, 3) * K * scale
			starPart.Transparency = 1 - opacity
		end
	end

	local frame = CFrame.lookAt(data.Origin, data.Origin + data.Direction.Unit)
	local released = false

	local function muzzle()
		local root = data.Caster:FindFirstChild("HumanoidRootPart")
		return root and root.Position + Vector3.new(0, 0.35, 0) + root.CFrame.LookVector * 2.2 or nil
	end

	function e:Destroy()
		if self.destroyed then
			return
		end
		self.destroyed = true
		group:Destroy()
	end

	function e:Release(origin, direction, time)
		frame = CFrame.lookAt(origin, origin + direction.Unit)
		self.releaseAt = time
	end

	function e:Stop(impact, position)
		if not impact then
			self:Destroy()
			return
		end
		if self.impactAt then
			return
		end
		self.impactAt = workspace:GetServerTimeNow()
		self.impactPosition = position or self.position
		self.impactDir = frame.LookVector
		if look.isOwn and look.bump then
			look.bump(0.035)
		end
	end

	function e:Update(now)
		if self.destroyed or not group.Parent then
			return false
		end
		local elapsed = math.max(0, now - data.StartedAt)
		local delay = data.Delay or 0.18
		local charge = math.clamp(elapsed / math.max(0.01, delay), 0, 1)
		local release = self.releaseAt
		local active = release ~= nil and now >= release
		local t = active and now - release or 0

		if self.impactAt then
			local impact = math.max(0, now - self.impactAt)
			if impact > IMPACT_TIME then
				return false
			end
			local u = impact / IMPACT_TIME
			if not self.burstDone then
				self.burstDone = true
				burst.CFrame = CFrame.new(self.impactPosition)
				starBurst:Emit(9)
				trail.Enabled = false
			end
			for _, layer in layers do
				if layer.part then
					layer.part.Transparency = 1 - math.clamp(1 - u * 1.6, 0, 1)
				end
			end
			if starPart then
				starPart.Transparency = 1
			end
			for i, line in lines do
				local a = (i - 1) / #lines * math.pi * 2 + 0.3
				local start = (1.6 + 5 * ease(u * 2)) * K
				local lift = 0.4 + math.sin(a * 2) * 0.8
				local from = self.impactPosition + Vector3.new(math.cos(a) * start, lift, math.sin(a) * start)
				local to = self.impactPosition + Vector3.new(math.cos(a) * (start + 3.5 * K), lift, math.sin(a) * (start + 3.5 * K))
				line.CFrame = CFrame.lookAt((from + to) * 0.5, to)
				line.Size = Vector3.new(0.14, 0.14, 3.5 * K * (1 - u))
				line.Transparency = math.clamp(u * 2.2, 0, 1)
			end
			for i, shard in shards do
				local a = i * 2.399
				local speed = 8 + (i * 4.3) % 8
				local y = (7 + (i * 3.1) % 6) * impact - 14 * impact * impact
				shard.CFrame = CFrame.new(self.impactPosition + Vector3.new(math.cos(a) * speed * impact, math.max(y, 0) + 0.4, math.sin(a) * speed * impact))
					* CFrame.Angles(impact * 7 + i, impact * 5, 0)
				shard.Size = Vector3.one * (0.8 + (i % 3) * 0.4)
				shard.Transparency = math.clamp(u * 1.6 - 0.2, 0, 1)
			end
			for _, streak in streaks do
				streak.Transparency = 1
			end
			setLane(self.impactPosition, self.impactDir, 0)
			self.position = self.impactPosition
			return true
		end

		if now > data.StartedAt + data.Duration + 0.3 then
			return false
		end

		if not active then
			local pos = muzzle()
			if not pos then
				return false
			end
			local root = data.Caster:FindFirstChild("HumanoidRootPart")
			frame = CFrame.lookAt(pos, pos + root.CFrame.LookVector)
			setHero(frame, 0.25 + 0.5 * ease(charge), 1, elapsed)
			setLane(pos, root.CFrame.LookVector, 0.4 + 0.6 * charge)
			self.position = pos
			return true
		end

		if not released then
			released = true
			self.launchHand = muzzle() or frame.Position
			trail.Enabled, trail.Rate = true, 22
			if look.isOwn and look.bump then
				look.bump(0.02)
			end
		end
		local fade = math.clamp((data.StartedAt + data.Duration - now) / 0.22, 0, 1)
		local travel = frame * CFrame.new(0, 0, -t * data.Speed)
		local offset = (self.launchHand - frame.Position) * (1 - ease(t / 0.12))
		local pos = travel.Position + offset
		local flight = CFrame.lookAt(pos, pos + frame.LookVector)
		self.position = flight.Position
		local pop = (0.8 + 0.2 * ease(t / 0.1)) * (1 + 0.2 * math.sin(math.clamp(t / 0.2, 0, 1) * math.pi))
		setHero(flight, pop, fade, t)
		setLane(self.launchHand, frame.LookVector, math.clamp(1 - t / 0.25, 0, 1))
		tail.CFrame = flight * CFrame.new(0, 0, 1.4 * K)
		for i, streak in streaks do
			local side = (i - 3) * 0.6 * K
			local rise = math.sin(i * 2.1) * 0.6 * K
			local length = (4 + (i % 3) * 2.5 + 2 * math.sin(t * 40 + i)) * K
			streak.CFrame = flight * CFrame.new(side, rise, length * 0.5 + 1 * K)
			streak.Size = Vector3.new(0.1, 0.1, length)
			streak.Transparency = 1 - 0.9 * fade
		end
		return true
	end

	return e
end

return SlickQ
