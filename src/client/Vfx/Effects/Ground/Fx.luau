-- Small utility toolbox for the E and R moves. Not a template: every move module owns its own look and timeline.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Kit = require(script.Parent.Parent.Parent.Kit)
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local Definitions = require(ReplicatedStorage.Shared.Config.PowerMoves)

local Fx = {}
Fx.WHITE = Color3.new(1, 1, 1)
Fx.SMOOTH, Fx.NEON = Enum.Material.SmoothPlastic, Enum.Material.Neon
Fx.Textures = Config.Textures

function Fx.ease(t)
	return math.sin(math.clamp(t, 0, 1) * math.pi / 2)
end

function Fx.backOut(t)
	t = math.clamp(t, 0, 1)
	return 1 + 2.70158 * (t - 1) ^ 3 + 1.70158 * (t - 1) ^ 2
end

function Fx.numbers(...)
	local keys = {}
	for i, v in { ... } do
		table.insert(keys, NumberSequenceKeypoint.new((i - 1) / (select("#", ...) - 1), v))
	end
	return NumberSequence.new(keys)
end

function Fx.emitter(parent, texture, colors, size, transparency, lifetime, speed, extra)
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

function Fx.puffs(parent, c0, c1, size, extra)
	return Fx.emitter(parent, Fx.Textures.Puff, ColorSequence.new(c0, c1), Fx.numbers(size, size * 1.5, size * 1.8),
		Fx.numbers(0.15, 0.5, 1), NumberRange.new(0.6, 1.0), NumberRange.new(3, 8), extra or { SpreadAngle = Vector2.new(60, 60), Drag = 2 })
end

function Fx.stars(parent, color, size, speed, extra)
	local e = { SpreadAngle = Vector2.new(70, 70), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-240, 240),
		Drag = 3, Acceleration = Vector3.new(0, -16, 0) }
	for k, v in extra or {} do
		e[k] = v
	end
	return Fx.emitter(parent, Fx.Textures.Star, ColorSequence.new(color), Fx.numbers(size, size * 0.8, 0.2), Fx.numbers(0, 0.3, 1),
		NumberRange.new(0.6, 1.0), speed, e)
end

function Fx.place(part, cf, size, opacity, base)
	if not part then
		return
	end
	part.CFrame = cf
	part.Size = Vector3.new(math.max(0.05, size.X), math.max(0.05, size.Y), math.max(0.05, size.Z))
	part.Transparency = 1 - (1 - (base or 0)) * math.clamp(opacity, 0, 1)
end

function Fx.hide(list)
	for _, part in list do
		part.Transparency = 1
	end
end

function Fx.orbit(angle, radius)
	return Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
end

-- X axis along the circle's tangent, Y up: a mesh band wraps around the centre.
function Fx.tangentFrame(pos, angle)
	return CFrame.fromMatrix(pos, Vector3.new(-math.sin(angle), 0, math.cos(angle)), Vector3.yAxis)
end

local function template(name)
	local library = ReplicatedStorage:FindFirstChild("Assets")
	library = library and library:FindFirstChild("PowerMoves")
	local item = library and library:FindFirstChild(name)
	return item and (item:IsA("MeshPart") and item or item:FindFirstChildWhichIsA("MeshPart", true))
end

function Fx.hasMesh(name)
	return template(name) ~= nil
end

-- Per-cast context: ground height, flat direction, and factories that register their parts for the budget.
function Fx.context(data, look, group, c)
	local ctx = { data = data, look = look, group = group, c = c, radius = data.Radius, parts = 0, fallback = 0 }
	local root = data.Caster:FindFirstChild("HumanoidRootPart")
	local flat = Vector3.new(data.Direction.X, 0, data.Direction.Z)
	ctx.dir = flat.Magnitude > 0.01 and flat.Unit or (root and root.CFrame.LookVector or -Vector3.zAxis)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { data.Caster, group, Kit.folder() }
	params.RespectCanCollide = true
	local hit = workspace:Raycast(data.Origin + Vector3.new(0, 4, 0), Vector3.new(0, -24, 0), params)
	local floorY = hit and hit.Position.Y or (data.Origin.Y - 2.7)
	ctx.center = Vector3.new(data.Origin.X, floorY, data.Origin.Z)
	ctx.caster = root and Vector3.new(root.Position.X, floorY, root.Position.Z) or ctx.center
	ctx.def = Definitions[data.Power][data.Key == "E" and 2 or 3]

	function ctx.bump(strength)
		if look.isOwn and look.bump then
			look.bump(strength)
		end
	end

	function ctx.part(shape, color, material, transparency)
		local part = Kit.safePart(Instance.new("Part"))
		part.Shape, part.Color, part.Material, part.Transparency = shape, color, material, transparency
		part.Size = Vector3.new(0.2, 0.2, 0.2)
		part.TopSurface, part.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		part.Parent = group
		ctx.parts += 1
		return part
	end

	-- Returns nil when the mesh is missing (counted as a fallback); callers skip nil parts.
	-- keepTexture: palette meshes (water and foam, blade and hilt) keep their baked colours instead of one flat tint.
	function ctx.mesh(name, color, material, transparency, keepTexture)
		local tpl = template(name)
		if not tpl then
			ctx.fallback += 1
			return nil
		end
		local part = Kit.safePart(tpl:Clone())
		part:ClearAllChildren()
		part.TextureID, part.Color, part.Material, part.Transparency = keepTexture and part.TextureID or "", keepTexture and Fx.WHITE or color, material, transparency
		part.Parent = group
		ctx.parts += 1
		return part
	end

	-- colors is a list of Color3 cycled over the copies.
	function ctx.meshes(count, name, colors, material, transparency)
		local list = {}
		for i = 1, count do
			local part = ctx.mesh(name, colors[(i - 1) % #colors + 1], material, transparency)
			if part then
				table.insert(list, part)
			end
		end
		return list
	end

	function ctx.anchor(center, footprint)
		local part = Kit.safePart(Instance.new("Part"))
		part.Size, part.Transparency, part.Parent = Vector3.new(footprint, 0.2, footprint), 1, group
		part.CFrame = CFrame.new(center + Vector3.new(0, 0.3, 0))
		ctx.parts += 1
		return part
	end

	local function flatGui(canvas)
		local part = Kit.safePart(Instance.new("Part"))
		part.Size, part.Transparency, part.Parent = Vector3.new(1, 0.1, 1), 1, group
		local gui = Instance.new("SurfaceGui")
		gui.Face, gui.SizingMode, gui.CanvasSize = Enum.NormalId.Top, Enum.SurfaceGuiSizingMode.FixedSize, canvas
		gui.LightInfluence, gui.Adornee, gui.Parent = 0, part, part
		ctx.parts += 1
		return part, gui
	end

	-- Solid ring (UIStroke circle). fill is the disc's background opacity.
	function ctx.ring(color, thickness, fill)
		local part, gui = flatGui(Vector2.new(512, 512))
		local frame = Instance.new("Frame")
		frame.AnchorPoint, frame.Position = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5)
		frame.Size = UDim2.new(1, -thickness * 2, 1, -thickness * 2)
		frame.BackgroundColor3, frame.BackgroundTransparency, frame.BorderSizePixel = color, 1, 0
		frame.Parent = gui
		local corner = Instance.new("UICorner")
		corner.CornerRadius, corner.Parent = UDim.new(0.5, 0), frame
		local stroke = Instance.new("UIStroke")
		stroke.Color, stroke.Thickness, stroke.Parent = color, thickness, frame
		local ring = { part = part }
		function ring.set(center, diameter, opacity)
			part.CFrame = CFrame.new(center + Vector3.new(0, 0.12, 0))
			part.Size = Vector3.new(math.max(0.1, diameter), 0.1, math.max(0.1, diameter))
			stroke.Transparency = 1 - math.clamp(opacity, 0, 1)
			frame.BackgroundTransparency = 1 - (fill or 0) * math.clamp(opacity, 0, 1)
		end
		return ring
	end

	-- Dashed ring: rounded dashes around a circle that can spin. dashLen and thick are fractions of the canvas.
	function ctx.dashRing(color, count, dashLen, thick)
		local part, gui = flatGui(Vector2.new(512, 512))
		local holder = Instance.new("Frame")
		holder.AnchorPoint, holder.Position, holder.Size = Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1)
		holder.BackgroundTransparency, holder.Parent = 1, gui
		local dashes = {}
		for i = 1, count do
			local a = (i - 1) / count * math.pi * 2
			local dash = Instance.new("Frame")
			dash.AnchorPoint, dash.Size = Vector2.new(0.5, 0.5), UDim2.fromScale(dashLen, thick)
			dash.Position = UDim2.fromScale(0.5 + math.cos(a) * 0.46, 0.5 + math.sin(a) * 0.46)
			dash.Rotation = math.deg(a) + 90
			dash.BackgroundColor3, dash.BackgroundTransparency, dash.BorderSizePixel = color, 1, 0
			local corner = Instance.new("UICorner")
			corner.CornerRadius, corner.Parent = UDim.new(0.5, 0), dash
			dash.Parent = holder
			dashes[i] = dash
		end
		local ring = { part = part }
		function ring.set(center, diameter, opacity, spin)
			part.CFrame = CFrame.new(center + Vector3.new(0, 0.12, 0))
			part.Size = Vector3.new(math.max(0.1, diameter), 0.1, math.max(0.1, diameter))
			holder.Rotation = spin or 0
			local transparency = 1 - math.clamp(opacity, 0, 1)
			for _, dash in dashes do
				dash.BackgroundTransparency = transparency
			end
		end
		return ring
	end

	-- Filled disc with an optional outline (soft warning disc).
	function ctx.disc(color, outline, fill)
		return ctx.ring(color, outline, fill)
	end

	return ctx
end

return Fx
