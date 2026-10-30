-- Fire Q presentation: a glowing layered fireball thrown from the caster's hand.
-- Visual size stays inside the server hit radius (2.5 studs). No damage, hitstop or movement changes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Kit = require(script.Parent.Parent.Kit)
local Cartoon = require(script.Parent.Parent.Cartoon)
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local Fireball = {}

local ORANGE = Color3.fromRGB(255, 138, 31)
local GOLD = Color3.fromRGB(255, 211, 77)
local SHADE = Color3.fromRGB(224, 72, 27)
local HOT = Color3.fromRGB(255, 244, 190)
local WHITE = Color3.new(1, 1, 1)

local ORB_BASE = 2.5 -- Q core diameter in studs; shell and rim stay inside the 5-stud hit diameter (the R Meteor is bigger)
local INK = Color3.fromRGB(34, 12, 10)
local RELEASE_BLEND = 0.12
local IMPACT_TIME = 0.5

local function ease(t)
	return math.sin(math.clamp(t, 0, 1) * math.pi / 2)
end

local function newPart(group, shape, color, material, transparency)
	local part = Kit.safePart(Instance.new("Part"))
	part.Shape, part.Color, part.Material, part.Transparency = shape, color, material, transparency
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	part.Parent = group
	return part
end

local function numbers(...)
	local keys = {}
	for i, v in { ... } do
		table.insert(keys, NumberSequenceKeypoint.new((i - 1) / (select("#", ...) - 1), v))
	end
	return NumberSequence.new(keys)
end

local function emitter(parent, texture, colors, size, transparency, lifetime, speed, extra)
	local e = Instance.new("ParticleEmitter")
	e.Texture, e.Color, e.Size, e.Transparency = texture, colors, size, transparency
	e.Lifetime, e.Speed, e.Rate, e.Enabled = lifetime, speed, 0, false
	e.LightInfluence, e.LockedToPart, e.ZOffset = 0, false, 0.5
	for key, value in extra or {} do
		e[key] = value
	end
	e.Parent = parent
	return e
end

local function muzzle(caster)
	local root = caster:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end
	local hand = caster:FindFirstChild("RightHand")
	if hand and hand:IsA("BasePart") then
		return hand.Position + root.CFrame.LookVector * 0.9
	end
	return root.Position + Vector3.new(0, 0.35, 0) + root.CFrame.LookVector * 2
end

function Fireball.Play(data, look)
	if look.distanceFactor == 0 then
		return nil
	end
	local ORB = data.Key == "R" and 4.4 * math.max(1, data.Radius / 5) or ORB_BASE
	local K = ORB / ORB_BASE
	local library = ReplicatedStorage:FindFirstChild("Assets")
	library = library and library:FindFirstChild("PowerMoves")
	local template = library and library:FindFirstChild("CometTail")
	if template and not template:IsA("MeshPart") then
		template = nil
	end

	local group = Instance.new("Folder")
	group.Name = "Fireball_" .. data.Token
	group.Parent = Kit.folder()
	Debris:AddItem(group, data.Duration + 2)
	local e = { group = group, position = data.Origin, caster = data.Caster, partCount = 0, meshFallbacks = template and 0 or 1 }

	-- Orb: neon core inside a translucent shell inside a faint shade rim (the cartoon outline glow).
	local body = Instance.new("Model")
	body.Name, body.Parent = "Body", group
	local outline = Instance.new("Highlight")
	outline.Name, outline.Adornee, outline.FillTransparency, outline.OutlineColor, outline.OutlineTransparency = "Outline", body, 1, INK, 0
	outline.Parent = body
	local rim = newPart(group, Enum.PartType.Ball, INK, Enum.Material.SmoothPlastic, 1)
	local shell = newPart(body, Enum.PartType.Ball, ORANGE, Enum.Material.Neon, 0.35)
	local core = newPart(body, Enum.PartType.Ball, HOT, Enum.Material.Neon, 0)
	e.partCount += 3
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness = ORANGE, 14 * K, 2.5
	light.Parent = core

	-- Flame crown streaming behind the orb: shade, orange, gold, plus two small side lobes.
	local crown = {}
	if template then
		local spec = {
			{ SHADE, Enum.Material.Neon, 0, Vector3.new(2.0, 2.0, 13), 5.6, 0 },
			{ ORANGE, Enum.Material.Neon, 0, Vector3.new(1.4, 1.4, 11), 4.6, 0 },
			{ GOLD, Enum.Material.Neon, 0, Vector3.new(0.8, 0.8, 8), 3.4, 0 },
		}
		for i, s in spec do
			local part = Kit.safePart(template:Clone())
			part:ClearAllChildren()
			part.TextureID, part.Color, part.Material, part.Transparency = "", s[1], s[2], 1
			part.Parent = body
			crown[i] = { part = part, size = s[4] * K, back = s[5] * K, splay = s[6], base = s[3] }
			e.partCount += 1
		end
	end

	-- Wake emitters ride a tail part; impact emitters sit on a static burst part.
	local tail = Kit.safePart(Instance.new("Part"))
	tail.Size, tail.Transparency, tail.Parent = Vector3.new(0.3, 0.3, 0.3), 1, group
	local puffTrail = emitter(tail, Config.Textures.Puff,
		ColorSequence.new(Color3.fromRGB(70, 28, 22), Color3.fromRGB(40, 16, 14)),
		numbers(1.6, 1.2, 0.2), numbers(0.45, 0.7, 1), NumberRange.new(0.4, 0.65), NumberRange.new(0, 2),
		{ SpreadAngle = Vector2.new(18, 18), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-60, 60) })
	local flameTrail = emitter(tail, Config.Textures.Puff,
		ColorSequence.new({ ColorSequenceKeypoint.new(0, GOLD), ColorSequenceKeypoint.new(0.5, ORANGE), ColorSequenceKeypoint.new(1, SHADE) }),
		numbers(1.8, 1.0, 0), numbers(0.1, 0.4, 1), NumberRange.new(0.25, 0.4), NumberRange.new(0, 1.5),
		{ SpreadAngle = Vector2.new(10, 10), LightEmission = 1 })
	local starTrail = emitter(tail, Config.Textures.Star,
		ColorSequence.new(GOLD), numbers(1.0, 0.9, 0), numbers(0, 0.2, 1), NumberRange.new(0.5, 0.8), NumberRange.new(3, 7),
		{ SpreadAngle = Vector2.new(35, 35), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-200, 200), LightEmission = 0.4 })

	local burst = Kit.safePart(Instance.new("Part"))
	burst.Size, burst.Transparency, burst.Parent = Vector3.new(0.3, 0.3, 0.3), 1, group
	local ring = newPart(group, Enum.PartType.Cylinder, ORANGE, Enum.Material.Neon, 1)
	local starBurst = emitter(burst, Config.Textures.Star, ColorSequence.new(GOLD), numbers(1.7, 1.2, 0.2), numbers(0, 0.3, 1),
		NumberRange.new(0.5, 0.85), NumberRange.new(16, 30),
		{ SpreadAngle = Vector2.new(180, 180), Drag = 4, Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-240, 240), Acceleration = Vector3.new(0, -14, 0) })
	local emberBurst = emitter(burst, Config.Textures.Puff,
		ColorSequence.new({ ColorSequenceKeypoint.new(0, HOT), ColorSequenceKeypoint.new(0.4, ORANGE), ColorSequenceKeypoint.new(1, SHADE) }),
		numbers(1.8, 1.2, 0), numbers(0, 0.4, 1), NumberRange.new(0.3, 0.5), NumberRange.new(18, 34),
		{ SpreadAngle = Vector2.new(180, 180), Drag = 5, LightEmission = 1 })
	local puffBurst = emitter(burst, Config.Textures.Puff, ColorSequence.new(Color3.fromRGB(60, 24, 20)), numbers(1.6, 2.6, 3.2), numbers(0.35, 0.7, 1),
		NumberRange.new(0.55, 0.85), NumberRange.new(7, 15), { SpreadAngle = Vector2.new(180, 180), Drag = 3 })
	e.partCount += 3

	-- Anime-slick: thin hard speed streaks trailing the orb and radial lines on impact.
	local streaks, lines = {}, {}
	for i = 1, 6 do
		streaks[i] = newPart(group, Enum.PartType.Block, i % 2 == 0 and HOT or GOLD, Enum.Material.Neon, 1)
	end
	for i = 1, 10 do
		lines[i] = newPart(group, Enum.PartType.Block, i % 2 == 0 and WHITE or GOLD, Enum.Material.Neon, 1)
	end
	e.partCount += 16

	-- Windup telegraph: the exact lane the shot will travel (and, for the Meteor, the blast circle where it lands).
	local isMeteor = data.Key == "R"
	local laneWidth = isMeteor and data.Radius * 2 or 5
	local laneLength = math.max(10, (data.Duration - (data.Delay or 0.18)) * data.Speed)
	local laneFill = newPart(group, Enum.PartType.Block, ORANGE, Enum.Material.Neon, 1)
	local laneEdges = { newPart(group, Enum.PartType.Block, GOLD, Enum.Material.Neon, 1), newPart(group, Enum.PartType.Block, GOLD, Enum.Material.Neon, 1) }
	local laneChevrons = {}
	for i = 1, 5 do
		laneChevrons[i] = newPart(group, Enum.PartType.Block, HOT, Enum.Material.Neon, 1)
	end
	local blastRing = newPart(group, Enum.PartType.Cylinder, GOLD, Enum.Material.Neon, 1)
	e.partCount += 10
	local rock = isMeteor and template and library and library:FindFirstChild("MeteorCore")
	if rock and not rock:IsA("MeshPart") then
		rock = nil
	end
	local shardMesh = library and library:FindFirstChild("EmberShard")
	if shardMesh and not shardMesh:IsA("MeshPart") then
		shardMesh = nil
	end
	local core3d, debris = nil, {}
	if rock then
		core3d = Kit.safePart(rock:Clone())
		core3d:ClearAllChildren()
		core3d.TextureID, core3d.Color, core3d.Material, core3d.Transparency, core3d.Parent = "", Color3.fromRGB(78, 34, 24), Enum.Material.SmoothPlastic, 1, group
		e.partCount += 1
		for i = 1, 9 do
			local piece = Kit.safePart((shardMesh or rock):Clone())
			piece:ClearAllChildren()
			piece.TextureID, piece.Color, piece.Material, piece.Transparency, piece.Parent = "", i % 3 == 0 and Color3.fromRGB(120, 48, 28) or INK, Enum.Material.SmoothPlastic, 1, group
			debris[i] = piece
		end
		e.partCount += 9
	end
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
		for i, chevron in laneChevrons do
			chevron.CFrame = lane * CFrame.new(0, 0.04, laneLength * (0.5 - i / 6))
			chevron.Size, chevron.Transparency = Vector3.new(laneWidth * 0.5, 0.06, 0.3), 1 - 0.8 * opacity
		end
		blastRing.CFrame = CFrame.new(floorPos + flat * (laneLength + 1.5) + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.pi / 2)
		blastRing.Size = Vector3.new(0.12, laneWidth, laneWidth)
		blastRing.Transparency = isMeteor and 1 - 0.85 * opacity or 1
	end

	-- Gather: small puffs and stars spiral into the hand during the windup.
	local gather = {}
	for i = 1, 5 do
		local sprite = Cartoon.sprite(group, i % 2 == 0 and Config.Textures.Star or Config.Textures.Puff, i % 2 == 0 and GOLD or WHITE)
		if sprite then
			table.insert(gather, sprite)
			e.partCount += 1
		end
	end

	local frame = CFrame.lookAt(data.Origin, data.Origin + data.Direction.Unit)
	local released = false

	local function setOrb(cf, scale, stretch, opacity)
		local function orb(part, diameter, base)
			part.CFrame = cf
			part.Size = Vector3.new(diameter * scale, diameter * scale, diameter * scale * stretch)
			part.Transparency = 1 - (1 - base) * opacity
		end
		orb(rim, ORB * 1.55, 1)
		orb(shell, ORB * 0.95, 0)
		orb(core, ORB * 0.6, 0)
		light.Brightness = 2.5 * opacity * math.min(1, scale + 0.2)
	end

	local function setCrown(cf, scale, stretch, time, opacity)
		for i, c in crown do
			local flicker = 1 + 0.1 * math.sin(time * 17 + i * 1.7)
			local sway = CFrame.Angles(0, math.sin(time * 9 + i) * 0.05, math.sin(time * 13 + i) * 0.06)
			local size = c.size * scale
			-- The comet mesh lies along Z (head at -Z); its centre trails behind the orb.
			c.part.CFrame = cf * CFrame.new(0, 0, c.back * scale * stretch) * sway
			c.part.Size = Vector3.new(size.X, size.Y, size.Z * flicker * stretch)
			c.part.Transparency = 1 - (1 - c.base) * opacity
		end
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
				emberBurst:Emit(16)
				puffBurst:Emit(7)
				puffTrail.Enabled, flameTrail.Enabled, starTrail.Enabled = false, false, false
			end
			local expand = ease(u * 1.6)
			local fadeOut = 1 - u
			local cf = CFrame.new(self.impactPosition) * CFrame.Angles(0, math.atan2(-self.impactDir.X, -self.impactDir.Z), 0)
			-- Orb swells into a hot flash, then thins out; crown lobes fling outward.
			setOrb(cf, 1 + 1.6 * expand, 1, math.clamp(fadeOut * 1.4, 0, 1) ^ 1.5)
			for _, c in crown do
				c.part.Transparency = 1
			end
			-- Flash ring faces the camera-side of the hit and expands quickly.
			ring.CFrame = CFrame.new(self.impactPosition) * CFrame.Angles(0, math.atan2(-self.impactDir.X, -self.impactDir.Z) + math.pi / 2, 0)
			local ringSize = 2 + 7 * ease(u * 2.2)
			ring.Size = Vector3.new(0.25, ringSize, ringSize)
			ring.Transparency = math.clamp(0.45 + u * 1.2, 0.45, 1)
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
			for _, streak in streaks do
				streak.Transparency = 1
			end
			setLane(self.impactPosition, self.impactDir, 0)
			if core3d then
				core3d.Transparency = 1
				for i, piece in debris do
					local a = i * 2.399
					local speed = 9 + (i * 4.7) % 8
					local y = (8 + (i * 3.1) % 7) * impact - 14 * impact * impact
					piece.CFrame = CFrame.new(self.impactPosition + Vector3.new(math.cos(a) * speed * impact, math.max(y, 0) + 0.4, math.sin(a) * speed * impact))
						* CFrame.Angles(impact * 7 + i, impact * 5, 0)
					piece.Size = Vector3.one * (0.8 + (i % 3) * 0.4)
					piece.Transparency = math.clamp(u * 1.6 - 0.2, 0, 1)
				end
			end
			if isMeteor then
				blastRing.CFrame = CFrame.new(self.impactPosition.X, data.Origin.Y - 2.5, self.impactPosition.Z) * CFrame.Angles(0, 0, math.pi / 2)
				blastRing.Size = Vector3.new(0.15, laneWidth * (0.6 + 1.1 * ease(u * 2)), laneWidth * (0.6 + 1.1 * ease(u * 2)))
				blastRing.Transparency = math.clamp(0.1 + u * 1.1, 0.1, 1)
			end
			for _, s in gather do
				s.image.ImageTransparency = 1
			end
			self.position = self.impactPosition
			return true
		end

		if now > data.StartedAt + data.Duration + 0.3 then
			return false
		end

		if not active then
			-- Windup: orb grows in the hand while sprites spiral inward.
			local pos = muzzle(data.Caster)
			if not pos then
				return false
			end
			local root = data.Caster:FindFirstChild("HumanoidRootPart")
			local dir = root.CFrame.LookVector
			frame = CFrame.lookAt(pos, pos + dir)
			local scale = 0.25 + 0.55 * ease(charge)
			local wobble = 1 + 0.06 * math.sin(elapsed * 60)
			setOrb(frame, scale * wobble, 1, 1)
			setCrown(frame, scale * 0.45, 1, elapsed, 0)
			setLane(pos, dir, 0.4 + 0.6 * charge)
			for i, s in gather do
				local a = i * math.pi * 2 / #gather + elapsed * 14
				local r = 2.6 * (1 - charge) + 0.3
				local p = pos + Vector3.new(math.cos(a) * r, math.sin(a * 1.3) * r * 0.7, math.sin(a) * r)
				Cartoon.placeSprite(s, CFrame.new(p), 0.9 - 0.4 * charge, charge * 0.9, i * 40 + elapsed * 200)
			end
			self.position = pos
			return true
		end

		-- Release and flight.
		if not released then
			released = true
			self.launchHand = muzzle(data.Caster) or frame.Position
			ring.CFrame = CFrame.new(self.launchHand) * CFrame.Angles(0, math.atan2(-frame.LookVector.X, -frame.LookVector.Z) + math.pi / 2, 0)
			for _, s in gather do
				s.image.ImageTransparency = 1
			end
			if look.isOwn and look.bump then
				look.bump(0.02)
			end
			puffTrail.Enabled, flameTrail.Enabled, starTrail.Enabled = true, true, true
			puffTrail.Rate, flameTrail.Rate, starTrail.Rate = 40, 70, 12
		end
		local fade = math.clamp((data.StartedAt + data.Duration - now) / 0.22, 0, 1)
		local travel = frame * CFrame.new(0, 0, -t * data.Speed)
		-- The visual leaves the hand and merges onto the authoritative flight line.
		local offset = (self.launchHand - frame.Position) * (1 - ease(t / RELEASE_BLEND))
		local pos = travel.Position + offset
		local flight = CFrame.lookAt(pos, pos + frame.LookVector)
		self.position = flight.Position
		-- Grow from the charge size to full, with a 25 percent overshoot, then settle.
		local grow = 0.8 + 0.2 * ease(t / 0.1)
		local pop = grow * (1 + 0.25 * math.sin(math.clamp(t / 0.2, 0, 1) * math.pi))
		local stretch = 1 + 0.25 * (1 - ease(t / 0.25))
		setOrb(flight, pop, stretch, fade)
		setCrown(flight, pop, 1, t + elapsed, fade * ease(t / 0.08))
		setLane(self.launchHand, frame.LookVector, math.clamp(1 - t / 0.25, 0, 1))
		if core3d then
			core3d.CFrame = flight * CFrame.Angles(t * 6, t * 4, 0)
			core3d.Size = Vector3.new(ORB * 1.3, ORB * 1.1, ORB * 1.25) * pop
			core3d.Transparency = 1 - fade
		end
		tail.CFrame = flight * CFrame.new(0, 0, 1.4 * K)
		for i, streak in streaks do
			local side = (i - 3.5) * 0.55 * K
			local rise = math.sin(i * 2.1) * 0.6 * K
			local length = (5 + (i % 3) * 3 + 2 * math.sin(t * 40 + i)) * K
			streak.CFrame = flight * CFrame.new(side, rise, length * 0.5 + 1.2 * K)
			streak.Size = Vector3.new(0.1, 0.1, length)
			streak.Transparency = 1 - 0.9 * fade
		end
		-- Release flash ring at the hand: a single quick pop.
		local ru = math.clamp(t / 0.2, 0, 1)
		ring.Size = Vector3.new(0.25, 1.5 + 4.5 * ease(ru), 1.5 + 4.5 * ease(ru))
		ring.Transparency = math.clamp(0.4 + ru * 0.8, 0.4, 1)
		return true
	end

	return e
end

return Fireball
