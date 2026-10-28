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

local ORB = 2.5 -- core diameter in studs; shell and rim stay inside the 5-stud hit diameter
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
	local library = ReplicatedStorage:FindFirstChild("Assets")
	library = library and library:FindFirstChild("PowerMoves")
	local template = library and library:FindFirstChild("Flame")
	if template and not template:IsA("MeshPart") then
		template = nil
	end

	local group = Instance.new("Folder")
	group.Name = "Fireball_" .. data.Token
	group.Parent = Kit.folder()
	Debris:AddItem(group, data.Duration + 2)
	local e = { group = group, position = data.Origin, caster = data.Caster, partCount = 0, meshFallbacks = template and 0 or 1 }

	-- Orb: neon core inside a translucent shell inside a faint shade rim (the cartoon outline glow).
	local rim = newPart(group, Enum.PartType.Ball, SHADE, Enum.Material.Neon, 0.72)
	local shell = newPart(group, Enum.PartType.Ball, ORANGE, Enum.Material.Neon, 0.35)
	local core = newPart(group, Enum.PartType.Ball, HOT, Enum.Material.Neon, 0)
	e.partCount += 3
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness = ORANGE, 14, 2.5
	light.Parent = core

	-- Flame crown streaming behind the orb: shade, orange, gold, plus two small side lobes.
	local crown = {}
	if template then
		local spec = {
			{ SHADE, Enum.Material.SmoothPlastic, 0.12, Vector3.new(3.1, 5.2, 2.7), 2.0, 0 },
			{ ORANGE, Enum.Material.Neon, 0, Vector3.new(2.4, 4.3, 2.1), 1.7, 0 },
			{ GOLD, Enum.Material.Neon, 0, Vector3.new(1.5, 2.9, 1.4), 1.1, 0 },
			{ ORANGE, Enum.Material.Neon, 0.05, Vector3.new(1.4, 2.8, 1.3), 1.5, 0.45 },
			{ ORANGE, Enum.Material.Neon, 0.05, Vector3.new(1.4, 2.8, 1.3), 1.5, -0.45 },
		}
		for i, s in spec do
			local part = Kit.safePart(template:Clone())
			part:ClearAllChildren()
			part.TextureID, part.Color, part.Material, part.Transparency = "", s[1], s[2], 1
			part.Parent = group
			crown[i] = { part = part, size = s[4], back = s[5], splay = s[6], base = s[3] }
			e.partCount += 1
		end
	end

	-- Wake emitters ride a tail part; impact emitters sit on a static burst part.
	local tail = Kit.safePart(Instance.new("Part"))
	tail.Size, tail.Transparency, tail.Parent = Vector3.new(0.3, 0.3, 0.3), 1, group
	local puffTrail = emitter(tail, Config.Textures.Puff,
		ColorSequence.new(Color3.fromRGB(255, 236, 205), Color3.fromRGB(255, 190, 120)),
		numbers(2.0, 1.4, 0.2), numbers(0.35, 0.55, 1), NumberRange.new(0.4, 0.65), NumberRange.new(0, 2),
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
	local puffBurst = emitter(burst, Config.Textures.Puff, ColorSequence.new(WHITE), numbers(2.2, 3.6, 4.4), numbers(0.15, 0.5, 1),
		NumberRange.new(0.55, 0.85), NumberRange.new(7, 15), { SpreadAngle = Vector2.new(180, 180), Drag = 3 })
	e.partCount += 3

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
		orb(rim, ORB * 1.75, 0.72)
		orb(shell, ORB * 1.4, 0.35)
		orb(core, ORB, 0)
		light.Brightness = 2.5 * opacity * math.min(1, scale + 0.2)
	end

	local function setCrown(cf, scale, stretch, time, opacity)
		for i, c in crown do
			local flicker = 1 + 0.1 * math.sin(time * 17 + i * 1.7)
			local roll = CFrame.Angles(math.pi / 2, 0, math.sin(time * 13 + i) * 0.16)
			local splay = CFrame.Angles(0, c.splay, 0)
			local size = c.size * scale
			c.part.CFrame = cf * CFrame.new(math.sin(c.splay) * 0.9 * scale, 0, c.back * scale * stretch) * splay * roll
			c.part.Size = Vector3.new(size.X, size.Y * flicker * stretch, size.Z)
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
			for i, c in crown do
				if i <= 3 then
					local a = (i - 1) * math.pi * 2 / 3 + 0.5
					local p = self.impactPosition + Vector3.new(math.cos(a) * 2.4 * expand, 0.3 + 1.4 * expand, math.sin(a) * 2.4 * expand)
					local pop = (1 - u) * (1 + 0.25 * math.sin(u * math.pi))
					c.part.CFrame = CFrame.new(p) * CFrame.Angles(0, a, -0.5)
					c.part.Size = Vector3.new(2.2, 3.6, 2) * math.max(pop, 0.02)
					c.part.Transparency = 1 - math.clamp(fadeOut * 1.3, 0, 1)
				else
					c.part.Transparency = 1
				end
			end
			-- Flash ring faces the camera-side of the hit and expands quickly.
			ring.CFrame = CFrame.new(self.impactPosition) * CFrame.Angles(0, math.atan2(-self.impactDir.X, -self.impactDir.Z) + math.pi / 2, 0)
			local ringSize = 2 + 7 * ease(u * 2.2)
			ring.Size = Vector3.new(0.25, ringSize, ringSize)
			ring.Transparency = math.clamp(0.45 + u * 1.2, 0.45, 1)
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
		tail.CFrame = flight * CFrame.new(0, 0, 1.4)
		-- Release flash ring at the hand: a single quick pop.
		local ru = math.clamp(t / 0.2, 0, 1)
		ring.Size = Vector3.new(0.25, 1.5 + 4.5 * ease(ru), 1.5 + 4.5 * ease(ru))
		ring.Transparency = math.clamp(0.4 + ru * 0.8, 0.4, 1)
		return true
	end

	return e
end

return Fireball
