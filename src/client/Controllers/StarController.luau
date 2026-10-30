-- Power Star presentation. The server owns each star's logical position (PowerStarService, tag "PowerStar"); this
-- controller hides the server body locally and draws a lively copy: a real squash-and-stretch bounce, a layered glow
-- (hot centre fading to the power's colour, glowing rim shell, soft halo, point light), orbiting sparkles, landing
-- puffs with a ring, and a faster spin and stretch while someone inhales it. Presentation only: no hitboxes.
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Visual = require(ReplicatedStorage.Shared.PowerStarVisual)
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local Kit = require(script.Parent.Parent.Vfx.Kit)

local Controller = {}

local TAG = "PowerStar"
local BOUNCE_TIME, BOUNCE_HEIGHT = 1.05, 4.6
local CULL_DISTANCE = 220
local WARM = Color3.fromRGB(255, 247, 205)

local stars = {} -- model -> state
local connections = {}
local clock = 0

local function numbers(...)
	local keys = {}
	for i, v in { ... } do
		table.insert(keys, NumberSequenceKeypoint.new((i - 1) / (select("#", ...) - 1), v))
	end
	return NumberSequence.new(keys)
end

local function emitter(parent, texture, color, size, transparency, lifetime, speed, extra)
	local e = Instance.new("ParticleEmitter")
	e.Texture, e.Color, e.Size, e.Transparency = texture, color, size, transparency
	e.Lifetime, e.Speed, e.Rate, e.Enabled = lifetime, speed, 0, false
	e.LightInfluence, e.LockedToPart, e.ZOffset = 0, false, 0.5
	for key, value in extra or {} do
		e[key] = value
	end
	e.Parent = parent
	return e
end

local function invisiblePart(parent, size)
	local part = Kit.safePart(Instance.new("Part"))
	part.Size, part.Transparency, part.Parent = size, 1, parent
	return part
end

local function hideServerBody(model)
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") then
			d.Transparency = 1
		elseif d:IsA("SurfaceGui") then
			d.Enabled = false
		end
	end
end

local function build(power)
	local look = Visuals.Powers[power]
	local folder = Instance.new("Folder")
	folder.Name = "PowerStarFx"
	folder.Parent = Kit.folder()

	local body = Visual.Create(power)
	body.Parent = folder
	-- Soft hot centre behind the emblem on both faces: bright core fading out to the saturated power colour.
	for _, gui in body:GetChildren() do
		if gui:IsA("SurfaceGui") then
			local core = Instance.new("ImageLabel")
			core.Name, core.BackgroundTransparency, core.ZIndex = "Core", 1, 0
			core.AnchorPoint, core.Position, core.Size = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1)
			core.Image, core.ImageColor3, core.ImageTransparency = Config.Textures.Puff, WARM, 0.2
			core.Parent = gui
		end
	end
	local size = body.Size

	-- Glowing rim: a slightly larger neon copy of the star in the highlight colour.
	local shell = body:Clone()
	shell:ClearAllChildren()
	shell.Name, shell.Material, shell.Color, shell.Transparency, shell.CastShadow = "Rim", Enum.Material.Neon, look.Highlight, 0.72, false
	shell.Parent = folder

	local halo = invisiblePart(folder, Vector3.one * 0.5)
	local gui = Instance.new("BillboardGui")
	gui.Name, gui.Size, gui.AlwaysOnTop, gui.LightInfluence, gui.Adornee, gui.MaxDistance = "Halo", UDim2.fromScale(10, 10), false, 0, halo, CULL_DISTANCE
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency, image.Size, image.Image = 1, UDim2.fromScale(1, 1), Config.Textures.Puff
	image.ImageColor3, image.ImageTransparency = look.Body:Lerp(look.Highlight, 0.4), 0.55
	image.Parent, gui.Parent = gui, halo
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness, light.Shadows = look.Body, 13, 1.4, false
	light.Parent = halo
	local sparkles = emitter(halo, Config.Textures.Star, ColorSequence.new(look.Highlight, WARM), numbers(0.55, 0.4, 0), numbers(0, 0.2, 1),
		NumberRange.new(0.7, 1.1), NumberRange.new(1.5, 3.5), { SpreadAngle = Vector2.new(180, 180), Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-160, 160), LightEmission = 1, Rate = 5, Enabled = true })

	local shadow = Kit.safePart(Instance.new("Part"))
	shadow.Shape, shadow.Color, shadow.Material, shadow.Transparency, shadow.Parent = Enum.PartType.Cylinder, Color3.new(0, 0, 0), Enum.Material.SmoothPlastic, 0.6, folder

	local ring = Kit.safePart(Instance.new("Part"))
	ring.Shape, ring.Color, ring.Material, ring.Transparency, ring.Parent = Enum.PartType.Cylinder, look.Highlight, Enum.Material.Neon, 1, folder
	local sparks = emitter(ring, Config.Textures.Star, ColorSequence.new(look.Highlight), numbers(0.9, 0.7, 0), numbers(0, 0.3, 1),
		NumberRange.new(0.5, 0.8), NumberRange.new(8, 14), { SpreadAngle = Vector2.new(50, 50), Rotation = NumberRange.new(0, 360),
			RotSpeed = NumberRange.new(-200, 200), Acceleration = Vector3.new(0, -18, 0), LightEmission = 0.6 })
	local trail = emitter(halo, Config.Textures.Puff, ColorSequence.new(look.Highlight, look.Body), numbers(1.2, 0.8, 0), numbers(0.3, 0.6, 1),
		NumberRange.new(0.25, 0.4), NumberRange.new(0, 1), { SpreadAngle = Vector2.new(20, 20), LightEmission = 1 })

	return { folder = folder, body = body, shell = shell, halo = halo, haloImage = image, light = light, sparkles = sparkles,
		shadow = shadow, ring = ring, sparks = sparks, trail = trail, size = size, look = look }
end

local function remove(model)
	local star = stars[model]
	if not star then
		return
	end
	stars[model] = nil
	if star.fx then
		-- Little pop where it was collected.
		local pop = invisiblePart(Kit.folder(), Vector3.one * 0.3)
		pop.CFrame = CFrame.new(star.pos or Vector3.zero)
		local burst = emitter(pop, Config.Textures.Star, ColorSequence.new(star.fx.look.Highlight), numbers(1.1, 0.8, 0), numbers(0, 0.3, 1),
			NumberRange.new(0.4, 0.7), NumberRange.new(10, 18), { SpreadAngle = Vector2.new(180, 180), Rotation = NumberRange.new(0, 360),
				RotSpeed = NumberRange.new(-240, 240), LightEmission = 1 })
		burst:Emit(8)
		Debris:AddItem(pop, 1.2)
		star.fx.folder:Destroy()
	end
end

local function track(model)
	if stars[model] then
		return
	end
	stars[model] = { model = model, age = 0, t = math.random() * BOUNCE_TIME, spin = math.random() * 6, landed = -1 }
end

local function step(model, star, dt)
	if not model:IsDescendantOf(workspace) then
		remove(model)
		return
	end
	local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("MeshPart")
	local power = model:GetAttribute("PowerId")
	if not primary or not power or not Visuals.Powers[power] then
		return
	end
	if not star.fx then
		hideServerBody(model)
		star.fx = build(power)
		star.fx.sparks.Parent.CFrame = primary.CFrame
		star.pos = primary.Position
	end
	local fx = star.fx
	local camera = workspace.CurrentCamera
	local target = primary.Position
	if camera and (camera.CFrame.Position - target).Magnitude > CULL_DISTANCE then
		fx.folder.Parent = nil
		return
	end
	fx.folder.Parent = Kit.folder()

	star.pos = star.pos:Lerp(target, 1 - math.exp(-dt * 12))
	star.age += dt
	local pulled = model:GetAttribute("Pulled") == true

	-- Bounce: parabola with a squash on landing and a stretch on takeoff. Pulled stars hover and stretch toward you.
	local height, sy, sx = 0, 1, 1
	if pulled then
		star.hover = (star.hover or 0) + (1.2 - (star.hover or 0)) * math.min(1, dt * 10)
		height = star.hover
		sy, sx = 1.2, 0.88
		star.spin += dt * 8
	else
		star.hover = 0
		local before = star.t % BOUNCE_TIME
		star.t += dt
		local u = (star.t % BOUNCE_TIME) / BOUNCE_TIME
		height = BOUNCE_HEIGHT * 4 * u * (1 - u)
		if before > star.t % BOUNCE_TIME then
			star.landed = clock
			fx.sparks:Emit(3)
		end
		local squash = math.exp(-(clock - star.landed) * 13) * 0.3
		local stretch = (u < 0.16 and (1 - u / 0.16) * 0.14 or 0) + 0.08 * math.sin(math.pi * u)
		sy, sx = 1 - squash + stretch, 1 + squash * 0.55 - stretch * 0.3
		star.spin += dt * 1.6
	end
	local pop = math.min(1, star.age / 0.35)
	pop = pop < 1 and 1 + 0.25 * math.sin(pop * math.pi) * (1 - pop) * 3 or 1
	local scale = math.min(1, star.age / 0.3) * pop

	local center = star.pos + Vector3.new(0, height, 0)
	local orient = CFrame.Angles(0, star.spin, math.sin(clock * 2.4 + star.spin) * 0.1)
	fx.body.CFrame = CFrame.new(center) * orient
	fx.body.Size = fx.size * Vector3.new(sx, sy, sx) * scale
	fx.shell.CFrame = fx.body.CFrame
	fx.shell.Size = fx.size * Vector3.new(sx, sy, sx) * scale * (1.15 + 0.04 * math.sin(clock * 5))
	fx.halo.CFrame = CFrame.new(center)
	fx.haloImage.Parent.Size = UDim2.fromScale((6.5 + 1.0 * math.sin(clock * 3.3)) * scale, (6.5 + 1.0 * math.sin(clock * 3.3)) * scale)
	fx.light.Brightness = (pulled and 2.4 or 1.3 + 0.35 * math.sin(clock * 4)) * scale
	fx.sparkles.Rate = pulled and 22 or 5
	fx.trail.Rate = pulled and 30 or (height > 1 and 8 or 0)
	fx.trail.Enabled = true

	-- Ground shadow shrinks and fades with height; ring pulses outward from each landing.
	local ground = target.Y - 2.45
	local shadowSize = math.max(0.4, 3.6 * (1 - height / (BOUNCE_HEIGHT * 2.4))) * scale
	fx.shadow.CFrame = CFrame.new(star.pos.X, ground + 0.06, star.pos.Z) * CFrame.Angles(0, 0, math.pi / 2)
	fx.shadow.Size = Vector3.new(0.1, shadowSize, shadowSize)
	fx.shadow.Transparency = 0.55 + math.clamp(height / 12, 0, 0.35)
	local since = clock - star.landed
	local k = math.clamp(since / 0.5, 0, 1)
	fx.ring.CFrame = CFrame.new(star.pos.X, ground + 0.1, star.pos.Z) * CFrame.Angles(0, 0, math.pi / 2)
	fx.ring.Size = Vector3.new(0.12, 1.5 + 7 * k, 1.5 + 7 * k)
	fx.ring.Transparency = star.landed < 0 and 1 or math.clamp(0.35 + k * 0.65, 0.35, 1)
end

function Controller.Stop()
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
	for model in stars do
		remove(model)
	end
end

function Controller.Start()
	for _, model in CollectionService:GetTagged(TAG) do
		track(model)
	end
	table.insert(connections, CollectionService:GetInstanceAddedSignal(TAG):Connect(track))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal(TAG):Connect(remove))
	table.insert(connections, RunService.Heartbeat:Connect(function(dt)
		clock += dt
		dt = math.min(dt, 0.1)
		for model, star in stars do
			step(model, star, dt)
		end
	end))
end

return Controller
