local P = require(script.Parent.EnvironmentProps)
local C = P.Colors
-- Shorter travel distances while retaining the rectangular combat layout.
local Arena = { Width = 624, Depth = 380 }

local function scaled(position)
	return Vector3.new(position.X * Arena.Width / 182, position.Y, position.Z * Arena.Depth / 182)
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
	local top = Vector3.new(Arena.Width / 2 - 26, 24, -Arena.Depth * 0.18)
	P.Part(m, "WaterfallLip", Vector3.new(12, 2, 15), CFrame.new(top - Vector3.new(0, 1, 0)), C.Stone, Enum.Material.Slate, false)
	for i = 1, 6 do
		local p = P.Part(m, "WaterRibbon", Vector3.new(1.7, 23.8, 0.3),
			CFrame.new(top + Vector3.new(i * 1.6 - 5, -12, 7)), Color3.fromRGB(100 + i * 7, 200 + i * 4, 238), Enum.Material.Glass, false)
		p.Transparency, p.CastShadow = 0.25 + i % 2 * 0.15, false
	end
	P.Disc(m, "FoamPool", Vector3.new(top.X, 0.12, top.Z + 8), 9, 0.08, Color3.fromRGB(174, 234, 236), Enum.Material.SmoothPlastic, false).Transparency = 0.35
	local emitterPart = P.Part(m, "MistEmitter", Vector3.one, CFrame.new(top.X, 1, top.Z + 8), Color3.new(1, 1, 1), nil, false)
	emitterPart.Transparency = 1
	local mist = Instance.new("ParticleEmitter")
	mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
	mist.Color = ColorSequence.new(Color3.fromRGB(203, 241, 240))
	mist.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), NumberSequenceKeypoint.new(1, 7) })
	mist.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 1) })
	mist.Lifetime, mist.Rate, mist.Speed = NumberRange.new(1.5, 2.5), 5, NumberRange.new(1, 3)
	mist.SpreadAngle = Vector2.new(70, 70)
	mist.Parent = emitterPart
end

function Arena.Build(parent)
	local model = P.Model(parent, "GrasslandArena")
	local rng = Random.new(218)
	model:SetAttribute("Width", Arena.Width)
	model:SetAttribute("Depth", Arena.Depth)
	model:SetAttribute("Footprint", "Rectangle")
	P.Part(model, "ArenaFloor", Vector3.new(Arena.Width, 3, Arena.Depth), CFrame.new(0, -1.5, 0), C.Grass, Enum.Material.Plastic, true)
	P.Part(model, "IslandBedrock", Vector3.new(Arena.Width, 24, Arena.Depth), CFrame.new(0, -15, 0), C.Stone, Enum.Material.Slate, true)
	local cliffs = P.Model(model, "BoundaryCliffs")
	for _, side in {
		{ Vector3.new(0, 0, -Arena.Depth / 2), Arena.Width, 0 },
		{ Vector3.new(0, 0, Arena.Depth / 2), Arena.Width, 0 },
		{ Vector3.new(-Arena.Width / 2, 0, 0), Arena.Depth, math.pi / 2 },
		{ Vector3.new(Arena.Width / 2, 0, 0), Arena.Depth, math.pi / 2 },
	} do
		local origin, length, angle = side[1], side[2], side[3]
		local count = math.ceil(length / 52)
		-- An odd number keeps the three-panel viewing opening centered.
		if count % 2 == 0 then
			count += 1
		end
		local segment = length / count
		local sideFrame = CFrame.new(origin) * CFrame.Angles(0, angle, 0)
		-- Solid, overlapping wall courses seal the joins beneath the stepped faces.
		local viewingSide = origin.Z > 0 and angle == 0
		local viewingWidth = segment * 3
		if viewingSide then
			local courseLength = (length + 24 - viewingWidth) / 2
			for _, sign in { -1, 1 } do
				P.Part(cliffs, "BoundaryWallCore", Vector3.new(courseLength, 26, 24),
					sideFrame * CFrame.new(sign * (viewingWidth + courseLength) / 2, 7, 0), C.Stone, nil, true)
			end
			P.Part(cliffs, "ViewingWall", Vector3.new(viewingWidth + 1, 9, 24),
				sideFrame * CFrame.new(0, -1.5, 0), C.Stone, nil, true)
			local rail = P.Part(cliffs, "ViewingGlass", Vector3.new(viewingWidth, 4, 0.4),
				sideFrame * CFrame.new(0, 5, 0), C.Cyan, Enum.Material.Glass, true)
			rail.Transparency, rail.CastShadow = 0.85, false
		else
			P.Part(cliffs, "BoundaryWallCore", Vector3.new(length + 24, 26, 24),
				sideFrame * CFrame.new(0, 7, 0), C.Stone, Enum.Material.Plastic, true)
		end
		for i = 1, count do
			local height = rng:NextNumber(20, 28)
			local along = -length / 2 + (i - 0.5) * segment
			if viewingSide and math.abs(along) < viewingWidth / 2 then
				continue
			end
			local cf = sideFrame * CFrame.new(along, height / 2 - 3, 0)
			local shade = rng:NextInteger(-10, 10)
			P.Part(cliffs, "WeatheredCliff", Vector3.new(segment + 1, height + 6, 24), cf,
				Color3.fromRGB(156 + shade, 163 + shade, 149 + shade), Enum.Material.Slate, true)
			P.Part(cliffs, "GrassyCliffTop", Vector3.new(segment + 1.1, 0.65, 24.1), cf * CFrame.new(0, (height + 6) / 2, 0),
				Color3.fromRGB(91 + shade, 150 + shade, 49):Lerp(Color3.new(0, 0, 0), 0.28), Enum.Material.Grass, true)
		end
	end
	P.Bounds(model, Vector3.zero, Arena.Width, Arena.Depth)
	for _, x in { -Arena.Width / 2, Arena.Width / 2 } do
		for _, z in { -Arena.Depth / 2, Arena.Depth / 2 } do
			P.Part(cliffs, "WallCorner", Vector3.new(26, 36, 26), CFrame.new(x, 12, z), C.Stone, Enum.Material.Plastic, true)
			P.Part(cliffs, "CornerGrassCap", Vector3.new(26.1, 0.65, 26.1), CFrame.new(x, 30.325, z), C.Grass, Enum.Material.Plastic, true)
		end
	end
	task.wait()
	local paths = P.Model(model, "Paths")
	local loop = {
		Vector3.new(-68, 0, -58), Vector3.new(68, 0, -58), Vector3.new(73, 0, -50),
		Vector3.new(73, 0, 50), Vector3.new(68, 0, 58), Vector3.new(-68, 0, 58),
		Vector3.new(-73, 0, 50), Vector3.new(-73, 0, -50), Vector3.new(-68, 0, -58),
	}
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
	-- More cover for the enlarged field, still low enough to jump and see across.
	local rocks = {
		{ Vector3.new(-26, 0, -9), 1.2, 0.45 },
		{ Vector3.new(28, 0, 15), 1.1, -0.35 },
		{ Vector3.new(1, 0, -31), 1.0, 0.9 },
		{ Vector3.new(-48, 0, 35), 1.15, -0.6 },
		{ Vector3.new(49, 0, -34), 1.2, 0.3 },
		{ Vector3.new(-12, 0, 39), 1.05, 1.1 },
		{ Vector3.new(9, 0, -66), 1.15, 0.7 },
		{ Vector3.new(-51, 0, -34), 1.1, -0.25 },
		{ Vector3.new(53, 0, 38), 1.2, 0.6 },
	}
	for _, rock in rocks do
		P.Rock(cover, scaled(rock[1]), rock[2], rock[3], true, 0.42)
	end
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
