-- Shared authored geometry for the approved lobby / grassland references.
local ServerStorage = game:GetService("ServerStorage")
local P = {}
P.Colors = {
	Grass = Color3.fromRGB(91, 156, 49):Lerp(Color3.new(0, 0, 0), 0.28), Leaf = Color3.fromRGB(105, 174, 51),
	Stone = Color3.fromRGB(156, 163, 151), LightStone = Color3.fromRGB(190, 195, 180),
	Paving = Color3.fromRGB(210, 202, 178), Dirt = Color3.fromRGB(190, 161, 113),
	Metal = Color3.fromRGB(58, 77, 87), Trim = Color3.fromRGB(115, 138, 149),
	Cyan = Color3.fromRGB(66, 216, 255), Wood = Color3.fromRGB(130, 87, 44),
	Gold = Color3.fromRGB(255, 191, 72),
}

function P.Model(parent, name)
	local model = Instance.new("Model")
	model.Name, model.Parent = name, parent
	return model
end

function P.SmoothPlastic(root)
	local parts = root:IsA("BasePart") and { root } or root:GetDescendants()
	for _, part in parts do
		if part:IsA("BasePart") then
			-- Keep the intentional portal glass and light accents.
			if part.Material ~= Enum.Material.Neon and part.Material ~= Enum.Material.Glass then
				part.Material = Enum.Material.SmoothPlastic
			end
			for _, face in { "TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface" } do
				part[face] = Enum.SurfaceType.Smooth
			end
		end
	end
end

function P.Part(parent, name, size, cf, color, material, collide)
	local part = Instance.new("Part")
	part.Name, part.Size, part.CFrame = name, size, cf
	part.Color = color
	-- Classic studded toy-brick materials; keep the portal and water translucent.
	part.Material = (material == Enum.Material.Neon or material == Enum.Material.Glass)
		and material or Enum.Material.Plastic
	part.Anchored, part.CanCollide = true, collide == true
	part.CanTouch = false
	part.CanQuery = collide == true
	part.TopSurface = part.Material == Enum.Material.Plastic and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function P.Bounds(parent, center, width, depth)
	local model = P.Model(parent, "InvisibleBounds")
	-- Keep only the six safety colliders loaded during long-distance teleports.
	model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	-- Overlap every edge. Queryable walls also stop dash blockcasts and bots.
	for _, spec in {
		{ "West", Vector3.new(2, 164, depth + 4), Vector3.new(-width / 2 - 1, 78, 0) },
		{ "East", Vector3.new(2, 164, depth + 4), Vector3.new(width / 2 + 1, 78, 0) },
		{ "North", Vector3.new(width + 4, 164, 2), Vector3.new(0, 78, -depth / 2 - 1) },
		{ "South", Vector3.new(width + 4, 164, 2), Vector3.new(0, 78, depth / 2 + 1) },
		{ "Floor", Vector3.new(width + 4, 2, depth + 4), Vector3.new(0, -1.05, 0) },
		{ "Ceiling", Vector3.new(width + 4, 2, depth + 4), Vector3.new(0, 161, 0) },
	} do
		local part = P.Part(model, spec[1], spec[2], CFrame.new(center + spec[3]), P.Colors.Stone, nil, true)
		part.Transparency, part.CastShadow = 1, false
	end
	return model
end

function P.Disc(parent, name, center, radius, height, color, material, collide)
	local p = P.Part(parent, name, Vector3.new(height, radius * 2, radius * 2),
		CFrame.new(center) * CFrame.Angles(0, 0, math.pi / 2), color, material, collide)
	p.Shape = Enum.PartType.Cylinder
	p.RightSurface = p.Material == Enum.Material.Plastic and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
	return p
end

function P.Beam(parent, name, from, to, width, depth, color, material, collide)
	return P.Part(parent, name, Vector3.new(width, depth, (to - from).Magnitude),
		CFrame.lookAt((from + to) / 2, to), color, material, collide)
end

function P.Sign(part, message, color, face, textSize)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Sign"
	gui.Face = face or Enum.NormalId.Back
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 35
	gui.LightInfluence = 0
	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(0.94, 0.9)
	text.Position = UDim2.fromScale(0.03, 0.05)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = color or Color3.new(1, 1, 1)
	text.TextScaled = textSize == nil
	text.TextSize = textSize or 24
	text.TextWrapped = true
	text.Text = message
	text.Parent, gui.Parent = gui, part
	return text
end

function P.Glow(parent, name, size, cf, color)
	local p = P.Part(parent, name, size, cf, color or P.Colors.Cyan, Enum.Material.Neon, false)
	p.CastShadow = false
	return p
end

function P.Lamp(parent, position, scale)
	local m = P.Model(parent, "PathLamp")
	local s = scale or 1
	local function block(name, size, offset, color, material)
		return P.Part(m, name, size * s, CFrame.new(position + offset * s), color, material, false)
	end
	block("Foot", Vector3.new(2.4, 0.5, 2.4), Vector3.new(0, 0.25, 0), P.Colors.Stone, Enum.Material.Slate)
	block("Stem", Vector3.new(0.8, 3, 0.8), Vector3.new(0, 1.9, 0), P.Colors.Metal, Enum.Material.Metal)
	local lens = block("CyanLens", Vector3.new(1, 2.3, 1), Vector3.new(0, 4, 0), P.Colors.Cyan, Enum.Material.Neon)
	for _, y in { 2.8, 5.2 } do
		block("Cap", Vector3.new(1.8, 0.5, 1.8), Vector3.new(0, y, 0), P.Colors.Trim, Enum.Material.Metal)
	end
	for _, x in { -0.65, 0.65 } do
		for _, z in { -0.65, 0.65 } do
			block("Frame", Vector3.new(0.2, 2.5, 0.2), Vector3.new(x, 4, z), P.Colors.Metal, Enum.Material.Metal)
		end
	end
	local light = Instance.new("PointLight")
	light.Color, light.Brightness, light.Range = P.Colors.Cyan, 0.65, 12 * s
	light.Parent = lens
	return m
end

function P.Fence(parent, a, b)
	local length = (b - a).Magnitude
	local count = math.max(1, math.ceil(length / 12))
	for i = 0, count do
		local p = a:Lerp(b, i / count)
		P.Part(parent, "FencePost", Vector3.new(0.7, 4, 0.7), CFrame.new(p + Vector3.new(0, 2, 0)), P.Colors.Wood, Enum.Material.Wood, true)
		P.Part(parent, "PostCap", Vector3.new(1, 0.3, 1), CFrame.new(p + Vector3.new(0, 4, 0)), P.Colors.Metal, Enum.Material.Metal, false)
	end
	for _, height in { 1.5, 3.1 } do
		P.Beam(parent, "FenceRail", a + Vector3.new(0, height, 0), b + Vector3.new(0, height, 0), 0.5, 0.55, P.Colors.Wood, Enum.Material.Wood, true)
	end
end

function P.Bench(parent, position, angle)
	local m = P.Model(parent, "Bench")
	local cf = CFrame.new(position) * CFrame.Angles(0, angle or 0, 0)
	for _, x in { -3.8, 3.8 } do
		P.Part(m, "Leg", Vector3.new(0.5, 2.4, 2.8), cf * CFrame.new(x, 1.2, 0), P.Colors.Metal, Enum.Material.Metal, true)
		P.Part(m, "BackSupport", Vector3.new(0.5, 4.3, 0.5), cf * CFrame.new(x, 2.15, -1.1), P.Colors.Metal, Enum.Material.Metal, false)
	end
	for _, z in { -0.9, 0, 0.9 } do
		P.Part(m, "SeatPlank", Vector3.new(9.4, 0.35, 0.8), cf * CFrame.new(0, 2.4, z), P.Colors.Wood, Enum.Material.WoodPlanks, true)
	end
	for _, y in { 3.2, 4 } do
		P.Part(m, "BackPlank", Vector3.new(9.4, 0.65, 0.35), cf * CFrame.new(0, y, -1.1), P.Colors.Wood, Enum.Material.WoodPlanks, false)
	end
end

local function template(parent, name, position, scale, angle)
	local library = ServerStorage:FindFirstChild("EnvironmentAssets")
	local source = library and library:FindFirstChild(name)
	if not source then
		return nil
	end
	local m = source:Clone()
	local cf = CFrame.new(position) * CFrame.Angles(0, angle or 0, 0)
	if m:IsA("Model") then
		m:ScaleTo(scale or 1)
		m:PivotTo(cf)
	else
		m.Size *= scale or 1
		m.CFrame = cf * CFrame.new(0, m.Size.Y / 2, 0)
	end
	for _, v in m:GetDescendants() do
		if v:IsA("BasePart") then
			v.Anchored, v.CanCollide, v.CanTouch, v.CanQuery = true, false, false, false
		end
	end
	if m:IsA("BasePart") then
		m.Anchored, m.CanCollide, m.CanTouch, m.CanQuery = true, false, false, false
	end
	m.Parent = parent
	return m
end

function P.Tree(parent, position, scale, angle)
	local s = scale or 1
	local m = P.Model(parent, "GrasslandOak")
	m:SetAttribute("Construction", "Roblox parts; no tree mesh")
	local origin = CFrame.new(position) * CFrame.Angles(0, angle or 0, 0)
	local function point(x, y, z)
		return origin:PointToWorldSpace(Vector3.new(x, y, z) * s)
	end
	local function branch(name, a, b, width, color)
		P.Beam(m, name, a, b, width * s, width * s, color or P.Colors.Wood, Enum.Material.Wood, false)
	end
	branch("TrunkBase", point(0, 0, 0), point(0.3, 6.5, 0), 2.4)
	branch("TrunkMiddle", point(0.3, 6, 0), point(-0.25, 12, 0.3), 1.9)
	branch("TrunkCrown", point(-0.25, 11, 0.3), point(0.8, 18.5, 0), 1.2)
	for i = 1, 5 do
		local theta = i * math.pi * 2 / 5
		local x, z = math.cos(theta), math.sin(theta)
		branch("RootFlare", point(x * 0.3, 2, z * 0.3), point(x * 2.6, 0.2, z * 2.6), 0.85, Color3.fromRGB(108, 77, 45))
		branch("MainBranch", point(0, 8 + i % 3, 0), point(x * 4, 14 + i % 3, z * 4), 1.0)
		branch("BranchTip", point(x * 4, 14 + i % 3, z * 4), point(x * 7, 17 + i % 3, z * 7), 0.58)
		branch("TwigFork", point(x * 4, 14 + i % 3, z * 4), point(x * 5 - z * 2, 18, z * 5 + x * 2), 0.42)
	end
	-- Each crown cluster is a broad octagonal mass assembled from beveled blocks,
	-- with smaller offset upper layers instead of one smooth sphere.
	local clusters = {
		{ 0, 20, 0, 9.5, 5.5 }, { -5.7, 17.5, -2.5, 8.2, 5 },
		{ 5.6, 18.2, -3.6, 8.5, 5.2 }, { -4.2, 18.3, 5, 8.0, 4.8 },
		{ 4.8, 17.3, 4.5, 8.4, 5.2 }, { 0.5, 21.9, -1.4, 7.0, 3.8 },
	}
	for i, c in clusters do
		local center = point(c[1], c[2], c[3])
		local cf = CFrame.new(center) * origin.Rotation * CFrame.Angles(0, i * 0.43, 0)
		local color = Color3.fromRGB(100 + i % 3 * 10, 166 + i % 3 * 11, 48 + i % 2 * 9)
		P.Part(m, "LeafCluster", Vector3.new(c[4], c[5], c[4] * 0.65) * s, cf, color, Enum.Material.Grass, false)
		P.Part(m, "LeafCluster", Vector3.new(c[4] * 0.65, c[5], c[4]) * s, cf, color, Enum.Material.Grass, false)
		P.Part(m, "SunlitCrown", Vector3.new(c[4] * 0.72, c[5] * 0.5, c[4] * 0.72) * s,
			cf * CFrame.new(0.4 * s, c[5] * 0.48 * s, -0.3 * s) * CFrame.Angles(0, 0.25, 0),
			Color3.fromRGB(129 + i % 2 * 10, 191 + i % 2 * 12, 65), Enum.Material.Grass, false)
		for side = 1, 4 do
			local theta = side * math.pi / 2 + math.pi / 4
			P.Part(m, "CanopyCorner", Vector3.new(c[4] * 0.36, c[5] * 0.82, c[4] * 0.36) * s,
				cf * CFrame.new(math.cos(theta) * c[4] * 0.35 * s, -0.15 * s, math.sin(theta) * c[4] * 0.35 * s)
					* CFrame.Angles(0, math.pi / 4, 0), color, Enum.Material.Grass, false)
		end
	end
	P.Part(parent, "TreeTrunkCollision", Vector3.new(2.2, 9, 2.2) * s, CFrame.new(position + Vector3.new(0, 4.5, 0) * s), P.Colors.Wood, Enum.Material.Wood, true).Transparency = 1
	return m
end

function P.Rock(parent, position, scale, angle, cover, heightScale)
	local s = scale or 1
	local cf = CFrame.new(position) * CFrame.Angles(0, angle or 0, 0)
	local m = template(parent, "GrasslandRock", position, s, angle)
	if not m then
		m = P.Model(parent, "GrasslandRock")
		for i = 1, 3 do
			P.Part(m, "Stone", Vector3.new(7, 4 + i, 8) * s, cf * CFrame.new(Vector3.new((i - 2) * 4, (4 + i) / 2, 0) * s)
				* CFrame.Angles(0.05, i * 0.5, 0.04), P.Colors.Stone, Enum.Material.Slate, false)
		end
	end
	if heightScale and heightScale ~= 1 then
		for _, part in m:GetDescendants() do
			if part:IsA("BasePart") then
				local relative = cf:ToObjectSpace(part.CFrame)
				local offset = relative.Position
				part.Size = Vector3.new(part.Size.X, part.Size.Y * heightScale, part.Size.Z)
				part.CFrame = cf * CFrame.new(offset.X, offset.Y * heightScale, offset.Z) * relative.Rotation
			end
		end
	end
	if cover then
		-- Use the visible stones for collision, so landing on the rock cannot sink
		-- through its surface or hit a taller invisible box.
		for _, part in m:GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide, part.CanQuery = true, true
			end
		end
		m:SetAttribute("Role", "CombatCover")
	end
	return m
end

function P.Plants(parent, position, seed, radius, count)
	local rng = Random.new(seed)
	local m = P.Model(parent, "GardenPlants")
	for i = 1, count do
		local theta = rng:NextNumber(0, math.pi * 2)
		local r = math.sqrt(rng:NextNumber()) * radius
		local p = position + Vector3.new(math.cos(theta) * r, 0, math.sin(theta) * r)
		local height = rng:NextNumber(0.4, 1.1)
		for j = 1, 3 do
			P.Part(m, "GrassBlade", Vector3.new(0.22, height, 0.08), CFrame.new(p + Vector3.new(0, height / 2, 0))
				* CFrame.Angles(0, j * 2, (j - 2) * 0.3), Color3.fromRGB(103, 162 + i % 4 * 10, 59):Lerp(Color3.new(0, 0, 0), 0.28), Enum.Material.Grass, false)
		end
		if i % 4 == 0 then
			P.Part(m, "FlowerStem", Vector3.new(0.08, 1.2, 0.08), CFrame.new(p + Vector3.new(0, 0.6, 0)), P.Colors.Leaf, Enum.Material.Grass, false)
			for j = 1, 4 do
				local a = j * math.pi / 2
				local petal = P.Part(m, "Petal", Vector3.new(0.35, 0.12, 0.35), CFrame.new(p + Vector3.new(math.cos(a) * 0.2, 1.2, math.sin(a) * 0.2)), Color3.fromRGB(255, 248, 208), nil, false)
				petal.Shape = Enum.PartType.Ball
			end
		end
	end
	return m
end

function P.Portal(parent, origin, scale, title)
	local m = P.Model(parent, "ArenaGateway")
	local s = scale or 1
	local function part(name, size, pos, color, material, collide)
		return P.Part(m, name, size * s, CFrame.new(origin + pos * s), color, material, collide)
	end
	-- Angular arch with solid posts and unobstructed opening.
	for _, side in { -1, 1 } do
		part("Footing", Vector3.new(6, 2, 7), Vector3.new(side * 11, 1, 0), P.Colors.Stone, Enum.Material.Slate, true)
		part("OuterPillar", Vector3.new(4, 15, 4), Vector3.new(side * 11, 8.5, 0), P.Colors.Stone, Enum.Material.Concrete, true)
		part("InsetPillar", Vector3.new(2.5, 13, 4.4), Vector3.new(side * 10.7, 8.7, 0), P.Colors.Metal, Enum.Material.Metal, false)
		part("InnerCyan", Vector3.new(0.35, 11, 0.3), Vector3.new(side * 9.2, 9, 2.4), P.Colors.Cyan, Enum.Material.Neon, false)
		local a = origin + Vector3.new(side * 11, 15.5, 0) * s
		local b = origin + Vector3.new(side * 7.5, 19.5, 0) * s
		P.Beam(m, "Chamfer", a, b, 4 * s, 4 * s, P.Colors.Stone, Enum.Material.Concrete, true)
		P.Beam(m, "LightChamfer", a + Vector3.new(-side * 1.7, 0, 2.3) * s, b + Vector3.new(0, -1.3, 2.3) * s, 0.35 * s, 0.35 * s, P.Colors.Cyan, Enum.Material.Neon, false)
		for _, y in { 3, 13 } do
			part("PillarCollar", Vector3.new(4.8, 0.8, 5), Vector3.new(side * 11, y, 0), P.Colors.Trim, Enum.Material.Metal, false)
		end
	end
	part("ArchLintel", Vector3.new(17, 4.2, 4.5), Vector3.new(0, 20, 0), P.Colors.Stone, Enum.Material.Concrete, true)
	part("TopLight", Vector3.new(15, 0.4, 0.35), Vector3.new(0, 17.7, 2.4), P.Colors.Cyan, Enum.Material.Neon, false)
	local sign = part("ArenaSign", Vector3.new(15.2, 3.1, 0.6), Vector3.new(0, 20, 2.6), P.Colors.Metal, Enum.Material.Metal, false)
	P.Sign(sign, title or "ARENA", Color3.fromRGB(195, 246, 255))
	local glass = part("PortalSurface", Vector3.new(17, 16, 0.15), Vector3.new(0, 8, 0), P.Colors.Cyan, Enum.Material.Glass, false)
	glass.Transparency = 0.84
	glass.CastShadow = false
	for i = 1, 5 do
		local line = part("PortalShimmer", Vector3.new(16, 0.035, 0.05), Vector3.new(0, i * 2.7, 0.15), Color3.fromRGB(162, 244, 255), Enum.Material.Neon, false)
		line.Transparency = 0.65
	end
	P.SmoothPlastic(m)
	return m
end

return P
