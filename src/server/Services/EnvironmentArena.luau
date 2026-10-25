local P = require(script.Parent.EnvironmentProps)
local C = P.Colors
local Arena = { SpanScale = 3 }

local function scaled(position)
	return Vector3.new(position.X * Arena.SpanScale, position.Y, position.Z * Arena.SpanScale)
end

function Arena.PlayerSpawnPosition(index)
	local angle = index * math.pi / 4
	return scaled(Vector3.new(math.cos(angle) * 52, 4, math.sin(angle) * 52))
end

function Arena.BanditPosition(index)
	if index == 7 then
		return scaled(Vector3.new(-15, 0, -46))
	elseif index == 8 then
		return scaled(Vector3.new(17, 0, 46))
	end
	local angle = index * math.pi / 3
	return scaled(Vector3.new(math.cos(angle) * 64, 0, math.sin(angle) * 64))
end

local function path(parent, points, width)
	for i = 1, #points - 1 do
		local a, b = scaled(points[i]), scaled(points[i + 1])
		P.Beam(parent, "DirtPath", a + Vector3.new(0, 0.025, 0), b + Vector3.new(0, 0.025, 0),
			width * 1.5, 0.04, C.Dirt, Enum.Material.Ground, false)
		P.Disc(parent, "PathJoin", a + Vector3.new(0, 0.025, 0), width * 0.75, 0.04, C.Dirt, Enum.Material.Ground, false)
	end
end

local function waterfall(parent)
	local m = P.Model(parent, "Waterfall")
	local top = Vector3.new(94, 17, -18)
	P.Part(m, "WaterfallLip", Vector3.new(12, 2, 15), CFrame.new(top - Vector3.new(0, 1, 0)), C.Stone, Enum.Material.Slate, false)
	for i = 1, 6 do
		local p = P.Part(m, "WaterRibbon", Vector3.new(1.7, 33 + i % 3, 0.3),
			CFrame.new(top + Vector3.new(i * 1.6 - 5, -16, 7)), Color3.fromRGB(100 + i * 7, 200 + i * 4, 238), Enum.Material.Glass, false)
		p.Transparency, p.CastShadow = 0.25 + i % 2 * 0.15, false
	end
	P.Disc(m, "FoamPool", Vector3.new(94, -15.7, -10), 9, 0.08, Color3.fromRGB(174, 234, 236), Enum.Material.SmoothPlastic, false).Transparency = 0.35
	local emitterPart = P.Part(m, "MistEmitter", Vector3.one, CFrame.new(94, -13, -10), Color3.new(1, 1, 1), nil, false)
	emitterPart.Transparency = 1
	local mist = Instance.new("ParticleEmitter")
	mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
	mist.Color = ColorSequence.new(Color3.fromRGB(203, 241, 240))
	mist.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 7) })
	mist.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1) })
	mist.Lifetime, mist.Rate, mist.Speed = NumberRange.new(1.5, 2.5), 5, NumberRange.new(1, 3)
	mist.SpreadAngle = Vector2.new(70, 70)
	mist.Parent = emitterPart
	local pivot = m:GetPivot()
	m:PivotTo(pivot + scaled(Vector3.new(94, 0, -18)) - Vector3.new(94, 0, -18))
end

function Arena.Build(parent)
	local model = P.Model(parent, "GrasslandArena")
	local rng = Random.new(218)
	model:SetAttribute("SpanScale", Arena.SpanScale)
	P.Disc(model, "ArenaFloor", Vector3.new(0, -1.5, 0), 91 * Arena.SpanScale, 3, C.Grass, Enum.Material.Grass, true)
	-- Flat studded strips display classic studs reliably over the cylinder floor.
	-- Stay below the dirt-path surface, with the original floor providing collision.
	local grassRadius = 91 * Arena.SpanScale
	for z = -grassRadius + 5, grassRadius - 5, 8 do
		local halfWidth = math.floor(math.sqrt(grassRadius * grassRadius - (math.abs(z) + 4) ^ 2) / 4) * 4
		P.Part(model, "ArenaGrassStuds", Vector3.new(halfWidth * 2, 0.02, 8), CFrame.new(0, 0, z), C.Grass, Enum.Material.Plastic, false)
	end
	P.Disc(model, "IslandBedrock", Vector3.new(0, -11, 0), 94 * Arena.SpanScale, 20, C.Stone, Enum.Material.Slate, true)
	local cliffs = P.Model(model, "BoundaryCliffs")
	for i = 1, 42 do
		local theta = i * math.pi * 2 / 42
		local radius = 88 + rng:NextNumber(-1, 3)
		local height = rng:NextNumber(10, 23)
		local center = scaled(Vector3.new(math.cos(theta) * radius, height / 2 - 3, math.sin(theta) * radius))
		local cf = CFrame.new(center) * CFrame.Angles(0, -theta, 0)
		local shade = rng:NextInteger(-10, 10)
		P.Part(cliffs, "WeatheredCliff", Vector3.new(18 * Arena.SpanScale, height + 6, 15 * Arena.SpanScale), cf,
			Color3.fromRGB(156 + shade, 163 + shade, 149 + shade), Enum.Material.Slate, true)
		P.Part(cliffs, "GrassyCliffTop", Vector3.new(18.1 * Arena.SpanScale, 0.65, 15.1 * Arena.SpanScale), cf * CFrame.new(0, (height + 6) / 2, 0),
			Color3.fromRGB(91 + shade, 150 + shade, 49):Lerp(Color3.new(0, 0, 0), 0.28), Enum.Material.Grass, true)
		P.Part(cliffs, "LowerCrag", Vector3.new(16 * Arena.SpanScale, 14, 14 * Arena.SpanScale), CFrame.new(center.X * 1.06, -11, center.Z * 1.06)
			* CFrame.Angles(0.08, -theta + 0.25, 0.1), C.Stone, Enum.Material.Slate, false)
	end
	task.wait()
	local paths = P.Model(model, "Paths")
	local loop = {}
	for i = 0, 48 do
		local angle = i * math.pi * 2 / 48
		local radius = 59 + math.sin(angle * 3) * 2.5
		table.insert(loop, Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius))
	end
	path(paths, loop, 6)
	path(paths, { Vector3.new(-52, 0, -32), Vector3.new(-33, 0, -24), Vector3.new(-21, 0, -5), Vector3.new(-12, 0, 12), Vector3.new(4, 0, 37), Vector3.new(12, 0, 58) }, 4.5)
	path(paths, { Vector3.new(-54, 0, 26), Vector3.new(-33, 0, 18), Vector3.new(-12, 0, 12), Vector3.new(14, 0, 8), Vector3.new(36, 0, -13), Vector3.new(52, 0, -31) }, 4.5)
	local stations = P.Model(model, "BanditClearings")
	for i = 1, 6 do
		local p = Arena.BanditPosition(i)
		P.Disc(stations, "PowerClearing" .. i, p + Vector3.new(0, 0.06, 0), 10.5, 0.08, C.Dirt, Enum.Material.Ground, false)
		local marker = P.Part(stations, "BanditSpawn" .. i, Vector3.one, CFrame.new(p), C.Grass, nil, false)
		marker.Transparency = 1
		marker:SetAttribute("SpawnIndex", i)
	end
	local cover = P.Model(model, "CombatCover")
	P.Rock(cover, scaled(Vector3.new(-26, 0, -9)), 1.05, 0.45, true, 0.4)
	P.Rock(cover, scaled(Vector3.new(28, 0, 15)), 0.95, -0.35, true, 0.4)
	P.Rock(cover, scaled(Vector3.new(1, 0, -31)), 0.85, 0.9, true, 0.4)
	local trees = P.Model(model, "Trees")
	local positions = {
		Vector3.new(-53, 0, -49), Vector3.new(39, 0, -59), Vector3.new(70, 0, 8),
		Vector3.new(42, 0, 57), Vector3.new(-67, 0, 18),
	}
	for i, position in positions do
		P.Tree(trees, scaled(position), 1.05 + i % 3 * 0.08, i * 1.8)
		P.Plants(trees, scaled(position), 200 + i, 5.5, 10)
	end
	-- Sparse flowers at the perimeter, never a wall of props through combat lanes.
	for i = 1, 12 do
		local angle = (i + 0.35) * math.pi / 6
		local p = Vector3.new(math.cos(angle) * 75, 0.05, math.sin(angle) * 75)
		P.Plants(model, scaled(p), 600 + i, 4, 5)
	end
	waterfall(model)
	task.wait()
	return model
end

return Arena
