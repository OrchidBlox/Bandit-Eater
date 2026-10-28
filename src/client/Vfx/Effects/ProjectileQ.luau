-- Q projectile presentation for Wind, Earth, Water, Sword and Shadow, built on the Fire Q recipe:
-- gather at the hand, release overshoot, shaped hero, wake emitters, impact burst.
-- Each power has its own silhouette (curled air, tumbling boulder, teardrop, crescent, crescent orb).
-- Visual size stays inside the server hit radius. No damage, hitstop or movement changes.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Kit = require(script.Parent.Parent.Kit)
local Cartoon = require(script.Parent.Parent.Cartoon)
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local Projectile = {}

local WHITE = Color3.new(1, 1, 1)
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

local function template(name)
	local library = ReplicatedStorage:FindFirstChild("Assets")
	library = library and library:FindFirstChild("PowerMoves")
	local item = library and library:FindFirstChild(name)
	item = item and (item:IsA("MeshPart") and item or item:FindFirstChildWhichIsA("MeshPart", true))
	return item
end

local function meshPart(group, name, color, material, transparency)
	local tpl = template(name)
	if not tpl then
		return nil
	end
	local part = Kit.safePart(tpl:Clone())
	part:ClearAllChildren()
	part.TextureID, part.Color, part.Material, part.Transparency = "", color, material, transparency
	part.Parent = group
	return part
end

-- Recipes: look and feel per power. size is the core diameter in studs.
local RECIPES = {
	Wind = {
		trailPuff = { Color3.fromRGB(240, 255, 250), Color3.fromRGB(127, 232, 207), 2.2 },
		spark = { 1, 70 }, stars = 10, light = 1.8,
		burst = { stars = 7, embers = 12, puffs = 8 },
	},
	Earth = {
		trailPuff = { Color3.fromRGB(240, 226, 200), Color3.fromRGB(185, 150, 100), 2.4 },
		spark = { 0, 0 }, stars = 8, light = 0,
		burst = { stars = 8, embers = 0, puffs = 11 },
	},
	Water = {
		trailPuff = { Color3.fromRGB(225, 246, 255), Color3.fromRGB(63, 182, 255), 1.9 },
		spark = { 0.6, 50 }, stars = 6, light = 1.6,
		burst = { stars = 6, embers = 14, puffs = 8 },
	},
	Sword = {
		trailPuff = { WHITE, Color3.fromRGB(201, 211, 222), 1.5 },
		spark = { 0.35, 45 }, stars = 14, light = 0.8,
		burst = { stars = 9, embers = 10, puffs = 5 },
	},
	Shadow = {
		trailPuff = { Color3.fromRGB(217, 194, 255), Color3.fromRGB(122, 70, 220), 2.2 },
		spark = { 0.3, 50 }, stars = 10, light = 1.5,
		burst = { stars = 7, embers = 10, puffs = 8 },
	},
}

for fusion, base in { Sword_Wind = "Wind", Sword_Earth = "Earth", Sword_Water = "Water", Sword_Shadow = "Shadow", Sword_Sword = "Sword" } do
	RECIPES[fusion] = RECIPES[base]
end
RECIPES.Sword_Fire = {
	trailPuff = { Color3.fromRGB(255, 233, 190), Color3.fromRGB(255, 138, 31), 2.0 },
	spark = { 1, 70 }, stars = 12, light = 1.8,
	burst = { stars = 8, embers = 16, puffs = 7 },
}
RECIPES.Sword_Sword = {
	trailPuff = { WHITE, Color3.fromRGB(255, 226, 140), 1.6 },
	spark = { 0.5, 50 }, stars = 16, light = 1.2,
	burst = { stars = 10, embers = 12, puffs = 5 },
}

-- Hero builders return { set = function(cf, scale, stretch, time, opacity), count = parts, fallback = bool }.
local function ballLayers(group, c, shellMaterial)
	local rim = newPart(group, Enum.PartType.Ball, c.Shade, Enum.Material.Neon, 0.72)
	local shell = newPart(group, Enum.PartType.Ball, c.Body, shellMaterial, 0.4)
	local core = newPart(group, Enum.PartType.Ball, c.Highlight, Enum.Material.Neon, 0)
	local function set(cf, scale, stretch, opacity, d)
		local function orb(part, diameter, base)
			part.CFrame = cf
			part.Size = Vector3.new(diameter * scale, diameter * scale, diameter * scale * stretch)
			part.Transparency = 1 - (1 - base) * opacity
		end
		orb(rim, d * 1.7, 0.72)
		orb(shell, d * 1.35, 0.4)
		orb(core, d, 0)
	end
	return set, core
end

local HEROES = {}

function HEROES.Wind(group, c)
	local set, core = ballLayers(group, c, Enum.Material.Neon)
	local bands = {}
	for i = 1, 3 do
		local part = meshPart(group, "WindFront", c.Highlight, Enum.Material.Neon, 0.25)
		if part then
			bands[i] = part
		end
	end
	return {
		core = core, count = 3 + #bands, fallback = #bands == 0,
		set = function(cf, scale, stretch, time, opacity)
			set(cf, scale, stretch, opacity, 2.2)
			for i, part in bands do
				local spin = CFrame.Angles(0, 0, time * 9 + i * math.pi * 2 / 3)
				part.CFrame = cf * spin * CFrame.new(0, 1.0 * scale, 0.2 * i)
				part.Size = Vector3.new(3.0, 0.8, 0.4) * scale
				part.Transparency = 1 - 0.75 * opacity
			end
		end,
	}
end

function HEROES.Earth(group, c)
	local main = meshPart(group, "Rock", c.Body, Enum.Material.SmoothPlastic, 1)
	local chips = {}
	for i = 1, 2 do
		chips[i] = meshPart(group, "Rock", i == 1 and c.Highlight or c.Shade, Enum.Material.SmoothPlastic, 1)
	end
	local glow = newPart(group, Enum.PartType.Ball, c.Highlight, Enum.Material.Neon, 1)
	local count = 1 + #chips + (main and 1 or 0)
	return {
		core = glow, count = count, fallback = main == nil,
		set = function(cf, scale, _stretch, time, opacity)
			if main then
				main.CFrame = cf * CFrame.Angles(time * 5.5, time * 3.2, 0)
				main.Size = Vector3.new(3.2, 3.0, 3.1) * scale
				main.Transparency = 1 - opacity
			end
			for i, chip in chips do
				local a = time * 4 + i * math.pi
				chip.CFrame = cf * CFrame.new(math.cos(a) * 2.1 * scale, math.sin(a) * 1.5 * scale, 0.8 * (i - 1.5))
					* CFrame.Angles(time * 7 + i, time * 5, 0)
				chip.Size = Vector3.new(1.2, 1.1, 1.1) * scale
				chip.Transparency = 1 - opacity
			end
			-- Faint warm glow keeps the boulder readable against the grass.
			glow.CFrame = cf
			glow.Size = Vector3.new(4.2, 4.2, 4.2) * scale
			glow.Transparency = 1 - 0.12 * opacity
		end,
	}
end

function HEROES.Water(group, c)
	local set, core = ballLayers(group, c, Enum.Material.SmoothPlastic)
	local tail = meshPart(group, "Droplet", c.Body, Enum.Material.SmoothPlastic, 0.2)
	local beads = {}
	for i = 1, 2 do
		beads[i] = newPart(group, Enum.PartType.Ball, c.Highlight, Enum.Material.SmoothPlastic, 0.1)
	end
	return {
		core = core, count = 3 + (tail and 1 or 0) + 2, fallback = tail == nil,
		set = function(cf, scale, stretch, time, opacity)
			set(cf, scale, stretch, opacity, 2.4)
			if tail then
				-- Teardrop tip streams backward, wobbling.
				tail.CFrame = cf * CFrame.new(0, 0, 1.9 * scale) * CFrame.Angles(math.pi / 2, 0, math.sin(time * 12) * 0.15)
				tail.Size = Vector3.new(2.2, 3.4 * stretch, 1.8) * scale
				tail.Transparency = 1 - 0.8 * opacity
			end
			for i, bead in beads do
				local back = (2.8 + i * 1.4) * scale * stretch
				bead.CFrame = cf * CFrame.new(math.sin(time * 9 + i) * 0.3, math.cos(time * 7 + i) * 0.3, back)
				local d = (0.9 - 0.25 * i) * scale
				bead.Size = Vector3.new(d, d, d * 1.2)
				bead.Transparency = 1 - 0.9 * opacity
			end
		end,
	}
end

-- Crescent slash wave: bands = { outline, outer band, middle band, bright inner band }.
local function crescent(group, bands, glowColor)
	local rim = meshPart(group, "Slash", bands[1], Enum.Material.SmoothPlastic, 0.3)
	local layers = {}
	for i = 1, 3 do
		layers[i] = meshPart(group, "Slash", bands[i + 1], Enum.Material.SmoothPlastic, 0)
	end
	local glow = newPart(group, Enum.PartType.Ball, glowColor, Enum.Material.Neon, 0.85)
	local scales = { 1.14, 1, 0.86 }
	return {
		core = glow, count = 1 + (rim and 1 or 0) + #layers, fallback = rim == nil,
		set = function(cf, scale, _stretch, time, opacity)
			-- Convex edge leads; the plane is tilted about the travel axis so it also reads from behind.
			local orient = cf * CFrame.Angles(0, 0, 0.7 + math.sin(time * 9) * 0.05) * CFrame.Angles(0, math.pi / 2, 0)
			local D = 4.4 * scale
			if rim then
				rim.CFrame = orient * CFrame.new(0, 0, 0.05)
				rim.Size = Vector3.new(D * 1.3, D * 1.3, 1.7 * scale)
				rim.Transparency = 1 - 0.7 * opacity
			end
			for i, layer in layers do
				layer.CFrame = orient
				layer.Size = Vector3.new(D * scales[i], D * scales[i], 1.4 * scale)
				layer.Transparency = 1 - opacity
			end
			glow.CFrame = cf
			glow.Size = Vector3.new(2.4, 2.4, 2.4) * scale
			glow.Transparency = 1 - 0.18 * opacity
		end,
	}
end

function HEROES.Sword(group, c)
	local white = Color3.fromRGB(246, 249, 255)
	return crescent(group, { c.Shade, white, white, white }, c.Body)
end

-- Sword fusions: same crescent, banded in the element's palette (Master Sword: silver with gold).
for _, fusion in { "Sword_Wind", "Sword_Earth", "Sword_Water", "Sword_Fire", "Sword_Shadow", "Sword_Sword" } do
	HEROES[fusion] = function(group, c)
		if fusion == "Sword_Sword" then
			return crescent(group, { c.Accent, c.Shade:Lerp(WHITE, 0.2), c.Body, WHITE }, c.Accent)
		end
		return crescent(group, { c.Shade, c.Body, c.Body:Lerp(c.Highlight, 0.5), c.Highlight }, c.Body)
	end
end

function HEROES.Shadow(group, c)
	local rim = newPart(group, Enum.PartType.Ball, c.Shade, Enum.Material.Neon, 0.7)
	local orb = meshPart(group, "ShadowOrb", c.Body, Enum.Material.SmoothPlastic, 0)
	local glow = newPart(group, Enum.PartType.Ball, c.Highlight, Enum.Material.Neon, 0.55)
	return {
		core = glow, count = 2 + (orb and 1 or 0), fallback = orb == nil,
		set = function(cf, scale, stretch, time, opacity)
			rim.CFrame = cf
			rim.Size = Vector3.new(4.4, 4.4, 4.4 * stretch) * scale
			rim.Transparency = 1 - 0.28 * opacity
			if orb then
				orb.CFrame = cf * CFrame.Angles(0, 0, time * 4)
				orb.Size = Vector3.new(3.4, 3.4, 3.0) * scale
				orb.Transparency = 1 - opacity
			end
			glow.CFrame = cf
			glow.Size = Vector3.new(1.6, 1.6, 1.6) * scale
			glow.Transparency = 1 - 0.45 * opacity
		end,
	}
end

function Projectile.Supports(power)
	return HEROES[power] ~= nil
end

function Projectile.Play(data, look)
	local power = data.Power
	local build, recipe, c = HEROES[power], RECIPES[power], Visuals.Powers[power]
	if not build or not recipe or not c or look.distanceFactor == 0 then
		return nil
	end

	local group = Instance.new("Folder")
	group.Name = "ProjectileQ_" .. data.Token
	group.Parent = Kit.folder()
	Debris:AddItem(group, data.Duration + 2)
	local e = { group = group, position = data.Origin, caster = data.Caster, partCount = 0, meshFallbacks = 0 }

	local hero = build(group, c)
	e.partCount += hero.count
	e.meshFallbacks = hero.fallback and 1 or 0
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness = c.Body, 12, recipe.light
	light.Parent = hero.core

	local tail = Kit.safePart(Instance.new("Part"))
	tail.Size, tail.Transparency, tail.Parent = Vector3.new(0.3, 0.3, 0.3), 1, group
	local p0, p1, psize = recipe.trailPuff[1], recipe.trailPuff[2], recipe.trailPuff[3]
	local puffTrail = emitter(tail, Config.Textures.Puff, ColorSequence.new(p0, p1),
		numbers(psize, psize * 0.7, 0.2), numbers(0.3, 0.55, 1), NumberRange.new(0.4, 0.65), NumberRange.new(0, 2),
		{ SpreadAngle = Vector2.new(18, 18), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-60, 60) })
	local sparkTrail = emitter(tail, Config.Textures.Puff, ColorSequence.new(c.Highlight, c.Body),
		numbers(1.6, 0.9, 0), numbers(0.1, 0.4, 1), NumberRange.new(0.25, 0.4), NumberRange.new(0, 1.5),
		{ SpreadAngle = Vector2.new(10, 10), LightEmission = recipe.spark[1] })
	local starTrail = emitter(tail, Config.Textures.Star, ColorSequence.new(c.Highlight),
		numbers(1.0, 0.9, 0), numbers(0, 0.2, 1), NumberRange.new(0.5, 0.8), NumberRange.new(3, 7),
		{ SpreadAngle = Vector2.new(35, 35), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-200, 200), LightEmission = 0.3 })

	local burst = Kit.safePart(Instance.new("Part"))
	burst.Size, burst.Transparency, burst.Parent = Vector3.new(0.3, 0.3, 0.3), 1, group
	local ring = newPart(group, Enum.PartType.Cylinder, c.Body, Enum.Material.Neon, 1)
	local starBurst = emitter(burst, Config.Textures.Star, ColorSequence.new(c.Highlight), numbers(1.7, 1.2, 0.2), numbers(0, 0.3, 1),
		NumberRange.new(0.5, 0.85), NumberRange.new(16, 30),
		{ SpreadAngle = Vector2.new(180, 180), Drag = 4, Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-240, 240), Acceleration = Vector3.new(0, -14, 0) })
	local emberBurst = emitter(burst, Config.Textures.Puff, ColorSequence.new(c.Highlight, c.Body),
		numbers(1.7, 1.1, 0), numbers(0, 0.4, 1), NumberRange.new(0.3, 0.5), NumberRange.new(18, 34),
		{ SpreadAngle = Vector2.new(180, 180), Drag = 5, LightEmission = recipe.spark[1] })
	local puffBurst = emitter(burst, Config.Textures.Puff, ColorSequence.new(p0, p1), numbers(2.2, 3.6, 4.4), numbers(0.15, 0.5, 1),
		NumberRange.new(0.55, 0.85), NumberRange.new(7, 15), { SpreadAngle = Vector2.new(180, 180), Drag = 3 })
	e.partCount += 3

	local gather = {}
	for i = 1, 4 do
		local sprite = Cartoon.sprite(group, i % 2 == 0 and Config.Textures.Star or Config.Textures.Puff, i % 2 == 0 and c.Highlight or WHITE)
		if sprite then
			table.insert(gather, sprite)
			e.partCount += 1
		end
	end

	local frame = CFrame.lookAt(data.Origin, data.Origin + data.Direction.Unit)
	local released = false

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
			look.bump(0.03)
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
				starBurst:Emit(recipe.burst.stars)
				emberBurst:Emit(recipe.burst.embers)
				puffBurst:Emit(recipe.burst.puffs)
				puffTrail.Enabled, sparkTrail.Enabled, starTrail.Enabled = false, false, false
			end
			local yaw = math.atan2(-self.impactDir.X, -self.impactDir.Z)
			local cf = CFrame.new(self.impactPosition) * CFrame.Angles(0, yaw, 0)
			hero.set(cf, 1 + 0.8 * ease(u * 1.6), 1, now, math.clamp((1 - u) * 1.4, 0, 1) ^ 1.5)
			ring.CFrame = CFrame.new(self.impactPosition) * CFrame.Angles(0, yaw + math.pi / 2, 0)
			local ringSize = 2 + 7 * ease(u * 2.2)
			ring.Size = Vector3.new(0.25, ringSize, ringSize)
			ring.Transparency = math.clamp(0.45 + u * 1.2, 0.45, 1)
			for _, s in gather do
				s.image.ImageTransparency = 1
			end
			light.Brightness = recipe.light * (1 - u)
			self.position = self.impactPosition
			return true
		end

		if now > data.StartedAt + data.Duration + 0.3 then
			return false
		end

		if not active then
			local pos = muzzle(data.Caster)
			local root = data.Caster:FindFirstChild("HumanoidRootPart")
			if not pos or not root then
				return false
			end
			frame = CFrame.lookAt(pos, pos + root.CFrame.LookVector)
			local scale = 0.25 + 0.55 * ease(charge)
			hero.set(frame, scale * (1 + 0.06 * math.sin(elapsed * 60)), 1, elapsed, 1)
			for i, s in gather do
				local a = i * math.pi * 2 / #gather + elapsed * 14
				local r = 2.6 * (1 - charge) + 0.3
				local p = pos + Vector3.new(math.cos(a) * r, math.sin(a * 1.3) * r * 0.7, math.sin(a) * r)
				Cartoon.placeSprite(s, CFrame.new(p), 0.9 - 0.4 * charge, charge * 0.9, i * 40 + elapsed * 200)
			end
			self.position = pos
			return true
		end

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
			puffTrail.Enabled, sparkTrail.Enabled, starTrail.Enabled = true, true, true
			puffTrail.Rate, sparkTrail.Rate, starTrail.Rate = 40, recipe.spark[2], recipe.stars
		end
		local fade = math.clamp((data.StartedAt + data.Duration - now) / 0.22, 0, 1)
		local travel = frame * CFrame.new(0, 0, -t * data.Speed)
		local offset = (self.launchHand - frame.Position) * (1 - ease(t / RELEASE_BLEND))
		local pos = travel.Position + offset
		local flight = CFrame.lookAt(pos, pos + frame.LookVector)
		self.position = flight.Position
		local grow = 0.8 + 0.2 * ease(t / 0.1)
		local pop = grow * (1 + 0.25 * math.sin(math.clamp(t / 0.2, 0, 1) * math.pi))
		local stretch = 1 + 0.2 * (1 - ease(t / 0.25))
		hero.set(flight, pop, stretch, now, fade)
		tail.CFrame = flight * CFrame.new(0, 0, 1.4)
		local ru = math.clamp(t / 0.2, 0, 1)
		ring.Size = Vector3.new(0.25, 1.5 + 4.5 * ease(ru), 1.5 + 4.5 * ease(ru))
		ring.Transparency = math.clamp(0.4 + ru * 0.8, 0.4, 1)
		return true
	end

	return e
end

return Projectile
