-- Sword M1 slash trails. Each hit of the shared one-handed combo leaves its own cut in the wielder's power colours:
-- hit 1 a rising diagonal, hit 2 a flat backhand sweep, hit 3 an overhead chop. A thin crescent (the Codex "Slash"
-- mesh) sweeps along the swing's path with afterimages and speed streaks behind its edge. Presentation only.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local Kit = require(script.Parent.Parent.Kit)
local Effect = {}

local SWEEP, LIFETIME = 0.14, 0.34
local NEON, SMOOTH = Enum.Material.Neon, Enum.Material.SmoothPlastic
local WHITE = Color3.new(1, 1, 1)

-- Path of the cut in the wielder's frame (x right, y up, z forward): the crescent's radial direction turns through
-- `from` to `to` degrees in the plane of `a` and `b`, around a centre `lift` studs up.
local SWINGS = {
	M1_1 = { a = Vector3.new(0, 0, 1), b = Vector3.new(-0.62, 0.78, 0), from = -50, to = 130, lift = 1.0, size = 5.6 },
	M1_2 = { a = Vector3.new(0, 0, 1), b = Vector3.new(1, 0, 0), from = -105, to = 45, lift = 1.5, size = 6.0 },
	M1_3 = { a = Vector3.new(0, 0, 1), b = Vector3.new(0, 1, 0), from = 125, to = -35, lift = 1.2, size = 6.4 },
}

local function template()
	local library = ReplicatedStorage:FindFirstChild("Assets")
	library = library and library:FindFirstChild("PowerMoves")
	local item = library and library:FindFirstChild("Slash")
	return item and (item:IsA("MeshPart") and item or item:FindFirstChildWhichIsA("MeshPart", true))
end

local function ease(t)
	return math.sin(math.clamp(t, 0, 1) * math.pi / 2)
end

local function place(part, cf, size, opacity, base)
	part.CFrame = cf
	part.Size = Vector3.new(math.max(0.05, size.X), math.max(0.05, size.Y), math.max(0.05, size.Z))
	part.Transparency = 1 - (1 - (base or 0)) * math.clamp(opacity, 0, 1)
end

-- data: { Combo = "M1_1".."M1_3", Power = active power id, Root = CFrame of the wielder's root }
function Effect.Play(data, look)
	local swing, tpl = SWINGS[data.Combo], template()
	local colors = Visuals.Powers[data.Power]
	if not swing or not tpl or not colors or not look or look.distanceFactor <= 0 then
		return nil
	end
	local container = Instance.new("Folder")
	container.Name = "SwordSlash_" .. data.Combo
	container.Parent = Kit.folder()
	local parts = {}
	local function mesh(color, material, transparency)
		local part = Kit.safePart(tpl:Clone())
		part:ClearAllChildren()
		part.TextureID, part.Color, part.Material, part.Transparency, part.Parent = "", color, material, transparency, container
		table.insert(parts, part)
		return part
	end
	local function block(color, material)
		local part = Kit.safePart(Instance.new("Part"))
		part.Color, part.Material, part.Transparency, part.Size, part.Parent = color, material, 1, Vector3.one * 0.2, container
		table.insert(parts, part)
		return part
	end
	local rim, body, edge = mesh(colors.Shade, SMOOTH, 0.2), mesh(colors.Body:Lerp(colors.Highlight, 0.5), SMOOTH, 0), mesh(WHITE, NEON, 0)
	local ghosts = { mesh(colors.Highlight, NEON, 0.3), mesh(colors.Highlight, NEON, 0.4) }
	local streaks = {}
	for i = 1, 4 do
		streaks[i] = block(i % 2 == 0 and WHITE or colors.Highlight, NEON)
	end
	local glint = Kit.safePart(Instance.new("Part"))
	glint.Shape, glint.Color, glint.Material, glint.Transparency, glint.Size, glint.Parent = Enum.PartType.Ball, WHITE, NEON, 1, Vector3.one * 0.2, container
	table.insert(parts, glint)

	local flat = Vector3.new(data.Root.LookVector.X, 0, data.Root.LookVector.Z)
	flat = flat.Magnitude > 0.01 and flat.Unit or -Vector3.zAxis
	local frame = CFrame.lookAt(Vector3.zero, flat)
	local a, b = frame:VectorToWorldSpace(swing.a), frame:VectorToWorldSpace(swing.b).Unit
	local centre = data.Root.Position + Vector3.new(0, swing.lift, 0)
	local direction = swing.to > swing.from and 1 or -1

	local function pose(k)
		local phi = math.rad(swing.from + (swing.to - swing.from) * k)
		local radial = a * math.cos(phi) + b * math.sin(phi)
		local tangent = (-a * math.sin(phi) + b * math.cos(phi)) * direction
		local pos = centre + radial * swing.size * 0.62
		return CFrame.fromMatrix(pos, radial, tangent), pos, tangent
	end

	local effect = { container = container, sprites = parts, started = os.clock(), destroyed = false }
	function effect:Destroy()
		if self.destroyed then
			return
		end
		self.destroyed = true
		container:Destroy()
		table.clear(parts)
	end
	function effect:Update(now)
		if self.destroyed or not container.Parent then
			return false
		end
		local t = now - self.started
		if t >= LIFETIME then
			self:Destroy()
			return false
		end
		local k = ease(t / SWEEP)
		local orient, pos, tangent = pose(k)
		local opacity = math.clamp(1 - (t - SWEEP) / (LIFETIME - SWEEP), 0, 1)
		local size = swing.size * (0.85 + 0.25 * math.sin(math.clamp(t / SWEEP, 0, 1) * math.pi))
		place(rim, orient * CFrame.new(0, 0, 0.05), Vector3.new(size * 1.16, size * 1.16, 1.3), opacity, 0.2)
		place(body, orient, Vector3.new(size, size, 1.1), opacity, 0)
		place(edge, orient * CFrame.new(size * 0.04, 0, 0), Vector3.new(size * 0.92, size * 0.92, 0.3), opacity, 0)
		for i, ghost in ghosts do
			local gorient = pose(math.max(0, k - i * 0.22))
			place(ghost, gorient, Vector3.new(size * 0.96, size * 0.96, 0.22), opacity * (0.6 - i * 0.2) * (k > 0.08 and 1 or 0), 0.25)
		end
		for i, streak in streaks do
			local offset = a:Cross(b) * (i - 2.5) * 0.45
			local tail = -tangent * (1.8 + i * 0.5)
			place(streak, CFrame.lookAt(pos + tail * 0.5 + offset, pos + tail + offset), Vector3.new(0.08, 0.08, 2.2 + i * 0.4),
				opacity * math.clamp(k * 3, 0, 1), 0.05)
		end
		place(glint, CFrame.new(pos), Vector3.one * 1.8 * math.sin(math.clamp(t / SWEEP, 0, 1) * math.pi), opacity, 0.2)
		return true
	end
	return effect
end

return Effect
