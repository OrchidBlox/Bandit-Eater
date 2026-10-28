-- Presentation-only meadow pass. Reuses approved Blender props; collision stays unchanged.
local ServerStorage = game:GetService("ServerStorage")
local MaterialService = game:GetService("MaterialService")
local Meadow = { Revision = 1 }
local GRASS = Color3.fromRGB(112, 157, 78)
local DIRT = Color3.fromRGB(184, 157, 112)
local TEXTURE = "rbxassetid://83475692374597"

local function smooth(part)
	part.Material = Enum.Material.SmoothPlastic
	if not part:IsA("MeshPart") and MaterialService:FindFirstChild("BE_MeadowMatte") then
		part.MaterialVariant = "BE_MeadowMatte"
	end
	for _, face in { "Top", "Bottom", "Left", "Right", "Front", "Back" } do
		part[face .. "Surface"] = Enum.SurfaceType.Smooth
	end
end

local function visual(part)
	part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
	part.CastShadow = false
end

local function plant(template, parent, position, scale, yaw)
	local model = template:Clone()
	model:ScaleTo(scale)
	model:PivotTo(CFrame.new(position) * CFrame.Angles(0, yaw, 0))
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			visual(part)
			smooth(part)
		end
	end
	model.Parent = parent
end

local function patch(parent, position, rx, rz, color, yaw)
	local part = Instance.new("Part")
	part.Name, part.Shape = "MeadowGroundPatch", Enum.PartType.Cylinder
	part.Size = Vector3.new(0.008, rx * 2, rz * 2)
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, yaw, math.pi / 2)
	part.Color = color
	smooth(part)
	visual(part)
	part.Parent = parent
end

function Meadow.Apply(environment)
	local arena = environment:FindFirstChild("GrasslandArena")
	local library = ServerStorage:FindFirstChild("MapProps")
	library = library and library:FindFirstChild("LowPolyNature")
	if not arena or not library then return false end
	local existing = arena:FindFirstChild("MeadowDecor")
	if existing then return existing:GetAttribute("Revision") == Meadow.Revision end
	local floor, paths, nature = arena:FindFirstChild("ArenaFloor"), arena:FindFirstChild("Paths"), arena:FindFirstChild("NatureDecor")
	if not floor or not paths or not nature then return false end
	for _, name in { "BushA", "BushB", "FlowerClump" } do
		local source = library:FindFirstChild(name)
		if not source or source:GetAttribute("ImportVerified") ~= true then return false end
	end
	local oldGrass = nature:FindFirstChild("ArenaGrassSurface")
	if not oldGrass then return false end
	local staged = Instance.new("Model")
	staged.Name = "MeadowDecor"
	staged:SetAttribute("Revision", Meadow.Revision)
	local surface = oldGrass:Clone()
	surface.Name = "PaintedGrassSurface"
	smooth(surface)
	visual(surface)
	surface.Color = GRASS
	local texture = Instance.new("Texture")
	texture.Name, texture.Face, texture.Texture = "PaintedMeadow", Enum.NormalId.Top, TEXTURE
	texture.StudsPerTileU, texture.StudsPerTileV, texture.Transparency = 48, 48, 0.45
	texture.Parent, surface.Parent = surface, staged
	local groundY = floor.Position.Y + floor.Size.Y / 2
	local pathParts = {}
	for _, path in paths:GetChildren() do
		if path:IsA("BasePart") then
			table.insert(pathParts, path)
			local shoulder = path:Clone()
			shoulder.Name = "SoftPathShoulder"
			if path.Shape == Enum.PartType.Cylinder then
				shoulder.Size += Vector3.new(0, 2.4, 2.4)
			else
				shoulder.Size += Vector3.new(2.4, 0, 0.6)
			end
			shoulder.CFrame -= Vector3.new(0, 0.022, 0)
			shoulder.Color = DIRT:Lerp(GRASS, 0.55)
			smooth(shoulder)
			visual(shoulder)
			shoulder.Parent = staged
		end
	end
	local function clear(position, radius)
		local q = floor.CFrame:PointToObjectSpace(position)
		if math.abs(q.X) + radius > floor.Size.X / 2 - 17 or math.abs(q.Z) + radius > floor.Size.Z / 2 - 17 then return false end
		for _, path in pathParts do
			local p = path.CFrame:PointToObjectSpace(position)
			if path.Shape == Enum.PartType.Cylinder then
				if Vector2.new(p.Y, p.Z).Magnitude < path.Size.Y / 2 + radius + 3 then return false end
			elseif math.abs(p.X) < path.Size.X / 2 + radius + 3 and math.abs(p.Z) < path.Size.Z / 2 + radius + 3 then
				return false
			end
		end
		local clearings = arena:FindFirstChild("BanditClearings")
		if clearings then
			for _, clearing in clearings:GetChildren() do
				if clearing:IsA("BasePart") then
					local d = position - clearing.Position
					if Vector2.new(d.X, d.Z).Magnitude < 17 + radius then return false end
				end
			end
		end
		return true
	end
	local rng = Random.new(251025)
	local centers = {}
	-- Irregular planting pockets at the wall base; leave the middle as playable meadow.
	for _, side in { -1, 1 } do
		for i = 1, 8 do
			table.insert(centers, floor.Position + Vector3.new((-0.43 + (i - 1) * 0.12) * floor.Size.X,
				0, side * (floor.Size.Z / 2 - rng:NextNumber(29, 37))))
		end
		for i = 1, 4 do
			table.insert(centers, floor.Position + Vector3.new(side * (floor.Size.X / 2 - 32), 0,
				(-0.32 + (i - 1) * 0.21) * floor.Size.Z))
		end
	end
	for _, model in nature:GetChildren() do
		if model:IsA("Model") and string.find(model.Name, "Rock") then
			table.insert(centers, model:GetPivot().Position + Vector3.new(7, 0, 5))
		end
	end
	local trees = nature:FindFirstChild("Trees")
	if trees then
		for _, model in trees:GetChildren() do
			if model:IsA("Model") then
				table.insert(centers, model:GetPivot().Position + Vector3.new(-7, 0, -4))
			end
		end
	end
	local count = 0
	for _, center in centers do
		center = Vector3.new(center.X, groundY, center.Z)
		if not clear(center, 10) then continue end
		count += 1
		local cluster = Instance.new("Model")
		cluster.Name = "MeadowPocket" .. count
		for i = 1, 3 do
			local offset = Vector3.new(rng:NextNumber(-3, 3), 0.021 + i * 0.009, rng:NextNumber(-2, 2))
			patch(cluster, center + offset, rng:NextNumber(3.5, 5.5), rng:NextNumber(2.5, 4),
				GRASS:Lerp(Color3.fromRGB(91, 137, 65), 0.25 + i * 0.08), rng:NextNumber(0, math.pi))
		end
		for i = 1, 2 do
			plant(library[i == 1 and "BushA" or "BushB"], cluster,
				center + Vector3.new((i - 1.5) * 4, 0.06, rng:NextNumber(-1, 1)), rng:NextNumber(0.45, 0.7), rng:NextNumber(0, 6.28))
			plant(library.FlowerClump, cluster, center + Vector3.new((i - 1.5) * 4, 0.06, 3),
				rng:NextNumber(0.65, 0.95), rng:NextNumber(0, 6.28))
		end
		cluster.Parent = staged
	end
	staged:SetAttribute("PocketCount", count)
	local archiveRoot = ServerStorage:FindFirstChild("PolishOld") or Instance.new("Folder")
	archiveRoot.Name, archiveRoot.Parent = "PolishOld", ServerStorage
	local archive = Instance.new("Folder")
	archive.Name, archive.Parent = "ArenaMeadow_" .. os.time(), archiveRoot
	paths:Clone().Parent = archive
	oldGrass.Parent = archive
	for _, path in pathParts do
		smooth(path)
		path.Color = DIRT
	end
	staged:SetAttribute("ArchivePath", archive:GetFullName())
	staged.Parent = arena
	return true
end

return Meadow
