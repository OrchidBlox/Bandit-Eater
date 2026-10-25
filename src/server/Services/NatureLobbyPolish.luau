-- Reuse the approved arena meshes around the lobby's protected gameplay layout.
local ServerStorage = game:GetService("ServerStorage")
local Nature = { Revision = 3 }
local TREES = { "TreeRoundA", "TreeRoundB", "TreeRoundC" }
local ROCKS = { "RockSmall", "RockMedium", "RockLarge" }
local PLANTS = { "BushA", "BushB", "FlowerClump" }
local COLORS = {
	Grass = Color3.fromRGB(111, 174, 74), Stone = Color3.fromRGB(173, 166, 148),
	Wood = Color3.fromRGB(122, 82, 54), Metal = Color3.fromRGB(68, 79, 84),
}
local REPLACE = {
	RaisedGarden = true, PlazaPaving = true, EntrancePaving = true, Bench = true,
	FencePost = true, FenceRail = true, PostCap = true,
}

local function library()
	local props = ServerStorage:FindFirstChild("MapProps")
	local folder = props and props:FindFirstChild("LowPolyNature")
	if not folder then return nil end
	local found = {}
	local function validated(name)
		local model = folder:FindFirstChild(name)
		if not model or not model:IsA("Model") or model:GetAttribute("ImportVerified") ~= true then return nil end
		local count = 0
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				if not part:IsA("MeshPart") or part.MeshId == "" then return nil end
				count += 1
			end
		end
		if count == 0 then return nil end
		return model
	end
	for _, names in { TREES, ROCKS } do
		for _, name in names do
			found[name] = validated(name)
			if not found[name] then return nil end
		end
	end
	local plants = true
	for _, name in PLANTS do
		found[name] = validated(name)
		if not found[name] then
			plants = false
		end
	end
	return found, plants
end

local function smooth(part)
	part.Material = Enum.Material.SmoothPlastic
	for _, face in { "Top", "Bottom", "Front", "Back", "Left", "Right" } do
		part[face .. "Surface"] = Enum.SurfaceType.Smooth
	end
end

local function part(parent, name, size, frame, color, material, collide)
	local result = Instance.new("Part")
	result.Name, result.Size, result.CFrame = name, size, frame
	result.Anchored, result.CanCollide, result.CanTouch, result.CanQuery = true, collide, false, collide
	smooth(result)
	result.Color, result.Material = color, material or Enum.Material.SmoothPlastic
	result.Parent = parent
	return result
end

local function mesh(source, parent, scale, frame)
	local model = source:Clone()
	model:ScaleTo(scale)
	model:PivotTo(frame)
	model:SetAttribute("TemplateName", source.Name)
	for _, item in model:GetDescendants() do
		if item:IsA("BasePart") then
			item.Anchored, item.CanCollide, item.CanTouch, item.CanQuery = true, false, false, false
			smooth(item)
		end
	end
	model.Parent = parent
	return model
end

local function treeBase(model)
	local beam = model:FindFirstChild("TrunkBase")
	if not beam or not beam:IsA("BasePart") then return nil end
	local a = beam.Position - beam.CFrame.LookVector * beam.Size.Z / 2
	local b = beam.Position + beam.CFrame.LookVector * beam.Size.Z / 2
	return a.Y < b.Y and a or b
end

local function restyle(copy)
	local pieces = copy:IsA("BasePart") and { copy } or copy:GetDescendants()
	for _, p in pieces do
		if p:IsA("BasePart") then
			smooth(p)
			if p.Name == "GrassBed" or p.Name == "GrassBlade" or p.Name == "FlowerStem" then
				p.Material, p.Color = Enum.Material.Grass, COLORS.Grass
			elseif p.Name == "StoneBed" then
				p.Color = COLORS.Stone
			elseif p.Name == "FenceRail" or p.Name == "FencePost" or p.Name == "SeatPlank" or p.Name == "BackPlank" then
				p.Color = COLORS.Wood
			elseif p.Name == "PostCap" or p.Name == "Leg" or p.Name == "BackSupport" then
				p.Color = COLORS.Metal
			elseif p.Name == "PlazaPaving" or p.Name == "EntrancePaving" then
				local variation = math.floor(p.Position.X * 7 + p.Position.Z * 3) % 9 - 4
				p.Color = Color3.fromRGB(195 + variation, 181 + variation, 155 + variation)
				p.CFrame += Vector3.new(0, 0.3, 0)
				p.CanCollide, p.CanQuery, p.CanTouch = true, true, false
			end
		end
	end
end

local function planting(garden, sources)
	local old = garden:FindFirstChild("GardenPlants")
	if old then
		old:Destroy() -- Only an unparented replacement's cloned plants.
	end
	local bed = garden.GrassBed
	local group = Instance.new("Model")
	group.Name, group.Parent = "GardenPlants", garden
	local x, z = bed.Size.X / 2 - 2.8, bed.Size.Z / 2 - 2.7
	for i, offset in { Vector3.new(-x, 0, -z), Vector3.new(x, 0, z), Vector3.new(-x, 0, z), Vector3.new(x, 0, -z) } do
		local name = i % 2 == 0 and "BushA" or "BushB"
		mesh(sources[name], group, 0.68 + i * 0.035,
			bed.CFrame * CFrame.new(offset.X, bed.Size.Y / 2, offset.Z) * CFrame.Angles(0, i * 0.7, 0))
	end
	for i = 1, 8 do
		local side = i <= 4 and -1 or 1
		local xOffset = ((i - 1) % 4 / 3 * 2 - 1) * (bed.Size.X / 2 - 1.35)
		mesh(sources.FlowerClump, group, 0.85,
			bed.CFrame * CFrame.new(xOffset, bed.Size.Y / 2, side * (bed.Size.Z / 2 - 1.35)) * CFrame.Angles(0, i, 0))
	end
end

local function withinFloor(model, floor)
	local frame, size = model:GetBoundingBox()
	for _, x in { -1, 1 } do
		for _, y in { -1, 1 } do
			for _, z in { -1, 1 } do
				local q = floor.CFrame:PointToObjectSpace(frame:PointToWorldSpace(size * Vector3.new(x, y, z) / 2))
				if math.abs(q.X) > floor.Size.X / 2 + 0.01 or math.abs(q.Z) > floor.Size.Z / 2 + 0.01 then return false end
			end
		end
	end
	return true
end

-- Upgrade only the planting after the owner approves a new mesh set.
function Nature.ApplyPlants(environment)
	local lobby = environment and environment:FindFirstChild("Lobby")
	local decor = lobby and lobby:FindFirstChild("NatureDecor")
	if not decor then return false end
	if decor:GetAttribute("PlantRevision") == 2 then return true end
	local sources, ready = library()
	if not ready then return false end
	local archiveRoot = ServerStorage:FindFirstChild("PolishOld")
	local archive = archiveRoot and archiveRoot:FindFirstChild("Lobby_Nature_v1")
	if not archive then return false end
	local plans = {}
	local ok, failure = pcall(function()
		for _, garden in decor:GetChildren() do
			if garden.Name == "RaisedGarden" or garden.Name == "PortalGarden" then
				assert(garden:FindFirstChild("GrassBed"), "Missing garden surface")
				local copy = garden:Clone()
				table.insert(plans, { original = garden, copy = copy })
				planting(copy, sources)
			end
		end
		assert(#plans == 12, "Expected twelve lobby gardens")
	end)
	if not ok then
		for _, plan in plans do
			plan.copy:Destroy()
		end
		error(failure)
	end
	for _, plan in plans do
		local old = plan.original:FindFirstChild("GardenPlants")
		if old then
			old.Parent = archive
		end
		plan.copy.GardenPlants.Parent = plan.original
		plan.copy:Destroy()
	end
	decor:SetAttribute("UsesUndergrowthMeshes", true)
	decor:SetAttribute("PlantRevision", 2)
	decor:SetAttribute("BushCount", 48)
	decor:SetAttribute("FlowerClumpCount", 96)
	decor:SetAttribute("ArchivedRoots", #archive:GetChildren())
	return true
end

function Nature.Apply(environment)
	local lobby = environment and environment:FindFirstChild("Lobby")
	local floor = lobby and lobby:FindFirstChild("LobbyFloor")
	if not floor or not floor:IsA("BasePart") then return false end
	local existing = lobby:FindFirstChild("NatureDecor")
	if existing then
		local revision = existing:GetAttribute("Revision")
		if revision == Nature.Revision then
			Nature.ApplyPlants(environment)
			return true
		end
		if revision ~= 1 and revision ~= 2 then return false end
		local grass = existing:FindFirstChild("TexturedGrass")
		if not grass or not grass:IsA("BasePart") then return false end
		for _, paving in existing:GetChildren() do
			if paving:IsA("BasePart") and (paving.Name == "PlazaPaving" or paving.Name == "EntrancePaving") then
				if revision == 1 then
					paving.CFrame += Vector3.new(0, 0.3, 0)
				end
				paving.CanCollide, paving.CanQuery, paving.CanTouch = true, true, false
			end
		end
		if revision == 1 then
			grass.Size = Vector3.new(grass.Size.X, 0.3, grass.Size.Z)
			grass.CFrame = floor.CFrame * CFrame.new(0, floor.Size.Y / 2 + 0.15, 0)
		end
		existing:SetAttribute("Revision", Nature.Revision)
		return true
	end
	local sources, usePlants = library()
	if not sources then return false end
	local trees, rocks, gardens, originals = {}, {}, {}, {}
	for _, child in lobby:GetChildren() do
		if child.Name == "GrasslandOak" then
			local base = treeBase(child)
			if not base then return false end
			table.insert(trees, { old = child, base = base })
		elseif child.Name == "GrasslandRock" then table.insert(rocks, child)
		elseif child.Name == "RaisedGarden" then
			if not child:FindFirstChild("GrassBed") or not child:FindFirstChild("StoneBed") then return false end
			table.insert(gardens, child)
		end
		if REPLACE[child.Name] or child.Name == "GrasslandOak" or child.Name == "GrasslandRock" then
			table.insert(originals, child)
		end
	end
	if #trees ~= 4 or #rocks ~= 6 or #gardens ~= 10 then return false end
	table.sort(trees, function(a, b)
		return a.base.X == b.base.X and a.base.Z < b.base.Z or a.base.X < b.base.X
	end)
	table.sort(rocks, function(a, b)
		local aPos, bPos = a:GetPivot().Position, b:GetPivot().Position
		return aPos.X == bPos.X and aPos.Z < bPos.Z or aPos.X < bPos.X
	end)
	local staged = Instance.new("Model")
	staged.Name = "NatureDecor"
	local ok, failure = pcall(function()
		for _, old in originals do
			if REPLACE[old.Name] then
				local copy = old:Clone()
				restyle(copy)
				if old.Name == "RaisedGarden" and usePlants then
					planting(copy, sources)
				end
				copy.Parent = staged
			end
		end
		for i, tree in trees do
			local model = mesh(sources[TREES[(i - 1) % #TREES + 1]], staged, 0.85, CFrame.new(tree.base))
			assert(withinFloor(model, floor), "Corner tree extends outside lobby bounds")
		end
		for i, old in rocks do
			local nearest, distance = nil, math.huge
			for _, garden in gardens do
				local d = (garden.GrassBed.Position - old:GetPivot().Position).Magnitude
				if d < distance then
					nearest, distance = garden, d
				end
			end
			assert(nearest and distance < 8, "Rock has no matching garden")
			local bed = nearest.GrassBed
			local source = sources[ROCKS[(i - 1) % #ROCKS + 1]]
			local _, dimensions = source:GetBoundingBox()
			local scale = math.min((bed.Size.X - 4) / dimensions.X, (bed.Size.Z - 4) / dimensions.Z, 0.8)
			local model = mesh(source, staged, scale, bed.CFrame * CFrame.new(0, bed.Size.Y / 2, 0))
			-- Narrow beds limit the footprint, while a modest height keeps the rock readable.
			local vertical = math.max(2.1, dimensions.Y * scale) / (dimensions.Y * scale)
			local pivot = model:GetPivot()
			for _, piece in model:GetDescendants() do
				if piece:IsA("BasePart") then
					local relative = pivot:ToObjectSpace(piece.CFrame)
					piece.Size *= Vector3.new(1, vertical, 1)
					piece.CFrame = pivot * CFrame.new(relative.Position * Vector3.new(1, vertical, 1)) * relative.Rotation
				end
			end
			assert(withinFloor(model, floor), "Rock extends outside lobby bounds")
		end
		local ground = floor.CFrame * CFrame.new(0, floor.Size.Y / 2, 0)
		part(staged, "TexturedGrass", Vector3.new(floor.Size.X, 0.3, floor.Size.Z), ground * CFrame.new(0, 0.15, 0), COLORS.Grass, Enum.Material.Grass, false)
		for i, x in { -30, 30 } do
			local frame = ground * CFrame.new(x, 0, -46)
			local garden = Instance.new("Model")
			garden.Name = "PortalGarden"
			part(garden, "StoneBed", Vector3.new(16, 0.8, 15), frame * CFrame.new(0, 0.4, 0), COLORS.Stone, nil, true)
			part(garden, "GrassBed", Vector3.new(14.8, 0.2, 13.8), frame * CFrame.new(0, 0.85, 0), COLORS.Grass, Enum.Material.Grass, false)
			if usePlants then
				planting(garden, sources)
			end
			garden.Parent = staged
			local yaw = i == 1 and -0.22 or 0.18
			local model = mesh(sources[TREES[i + 1]], staged, 0.65,
				frame * CFrame.new(0, 0.95, 0) * CFrame.Angles(0, yaw, 0))
			assert(withinFloor(model, floor), "Portal tree extends outside lobby bounds")
			local collider = part(staged, "TreeTrunkCollision", Vector3.new(1.43, 5.85, 1.43), frame * CFrame.new(0, 3.875, 0), COLORS.Wood, nil, true)
			collider.Transparency, collider.CastShadow = 1, false
		end
	end)
	if not ok then
		staged:Destroy()
		error(failure)
	end
	staged:SetAttribute("Revision", Nature.Revision)
	staged:SetAttribute("Style", "LowPolyNature")
	staged:SetAttribute("TreeCount", 6)
	staged:SetAttribute("RockCount", 6)
	staged:SetAttribute("GardenCount", 12)
	staged:SetAttribute("UsesUndergrowthMeshes", usePlants)
	if usePlants then
		staged:SetAttribute("PlantRevision", 2)
		staged:SetAttribute("BushCount", 48)
		staged:SetAttribute("FlowerClumpCount", 96)
	end
	local archiveRoot = ServerStorage:FindFirstChild("PolishOld") or Instance.new("Folder")
	archiveRoot.Name, archiveRoot.Parent = "PolishOld", ServerStorage
	local archive = Instance.new("Folder")
	archive.Name = "Lobby_Nature_v1"
	archive.Parent = archiveRoot
	for _, old in originals do
		old.Parent = archive
	end
	staged:SetAttribute("ArchivedRoots", #originals)
	staged.Parent = lobby
	return true
end

return Nature
