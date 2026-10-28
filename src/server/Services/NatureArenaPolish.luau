-- Approved Blender scenery, applied without rebuilding gameplay anchors.
local EnvironmentLighting = require(script.Parent.EnvironmentLighting)
local ServerStorage = game:GetService("ServerStorage")

local Nature = { Revision = 1, FacadeRevision = 2 }
local SIZES = {
	CliffStraightA = Vector3.new(48, 28, 12),
	CliffStraightB = Vector3.new(48, 24, 12),
	CliffCorner = Vector3.new(26, 30, 26),
	CliffEnd = Vector3.new(12, 24, 12),
	RockSmall = Vector3.new(12, 3, 8),
	RockMedium = Vector3.new(16, 3.3, 11),
	RockLarge = Vector3.new(20, 3.6, 13),
}
local ROCKS = { "RockSmall", "RockMedium", "RockLarge" }

local function templates()
	local props = ServerStorage:FindFirstChild("MapProps")
	local folder = props and props:FindFirstChild("LowPolyNature")
	if not folder then
		return nil
	end
	local result = {}
	for name in SIZES do
		local model = folder:FindFirstChild(name)
		if not model or not model:IsA("Model") then
			return nil
		end
		local count, bases = 0, 0
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				if not part:IsA("MeshPart") then
					return nil
				end
				count += 1
				if string.find(part.Name, "_Base_", 1, true) then
					bases += 1
				end
			end
		end
		if count ~= 2 or bases ~= 1 then
			return nil
		end
		result[name] = model
	end
	return result
end

local function sortedChildren(parent, name, className)
	local result = {}
	for _, child in parent:GetChildren() do
		if child.Name == name and child:IsA(className) then
			table.insert(result, child)
		end
	end
	table.sort(result, function(a, b)
		local pa = a:IsA("Model") and a:GetPivot().Position or a.Position
		local pb = b:IsA("Model") and b:GetPivot().Position or b.Position
		if pa.X == pb.X then
			return pa.Z < pb.Z
		end
		return pa.X < pb.X
	end)
	return result
end

local function cloneFitted(source, name, target, size, parent, cover)
	local model = source:Clone()
	local pivot = model:GetPivot()
	local factor = size / SIZES[name]
	model.PrimaryPart = nil
	model.Name = name
	model:SetAttribute("TemplateName", name)
	model:SetAttribute("Style", "LowPolyNature")
	if cover then
		model:SetAttribute("Role", "CombatCover")
	end
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			local relative = pivot:ToObjectSpace(part.CFrame)
			part.Size *= factor
			part.CFrame = target * CFrame.new(relative.Position * factor) * relative.Rotation
			part.Anchored, part.CanTouch = true, false
			-- Collision follows visible cover and the inward-facing wall facades.
			part.CanCollide = string.find(part.Name, "_Base_", 1, true) ~= nil
			part.CanQuery = true
			part.Material = Enum.Material.SmoothPlastic
		end
	end
	model.WorldPivot = target
	model.Parent = parent
	return model
end

local function inwardFrame(part, floor)
	local position = floor.CFrame:PointToObjectSpace(part.Position)
	local yaw
	if math.abs(position.X) / floor.Size.X > math.abs(position.Z) / floor.Size.Z then
		yaw = position.X > 0 and math.pi / 2 or -math.pi / 2
	else
		yaw = position.Z > 0 and 0 or math.pi
	end
	local base = part.Position - Vector3.new(0, part.Size.Y / 2, 0)
	local frame = CFrame.new(base) * floor.CFrame.Rotation * CFrame.Angles(0, yaw, 0)
	-- The retained solid wall core otherwise masks the recessed mesh facets.
	return frame + frame.LookVector * (part.Size.Z / 2 + 0.2)
end

local function cornerFrame(part, floor)
	local frame = inwardFrame(part, floor)
	local position = floor.CFrame:PointToObjectSpace(part.Position)
	local offset = floor.CFrame:VectorToWorldSpace(Vector3.new(
		-math.sign(position.X) * (part.Size.X / 2 + 0.2), 0,
		-math.sign(position.Z) * (part.Size.Z / 2 + 0.2)))
	local base = part.Position - Vector3.new(0, part.Size.Y / 2, 0)
	return CFrame.new(base + offset) * frame.Rotation
end

local function supportedGrassCap(original, cliffs, index)
	local closest, distance
	for _, core in cliffs:GetChildren() do
		if core.Name == "BoundaryWallCore" and core:IsA("BasePart") then
			local position = core.CFrame:PointToObjectSpace(original.Position)
			local dx = math.max(0, math.abs(position.X) - core.Size.X / 2)
			local dz = math.max(0, math.abs(position.Z) - core.Size.Z / 2)
			local d = dx * dx + dz * dz
			if not distance or d < distance then
				closest, distance = core, d
			end
		end
	end
	assert(closest, "Nature grass caps require the retained wall cores")
	local cap = original:Clone()
	cap.Name = "CliffGrassCap"
	local top = closest.Position.Y + closest.Size.Y / 2
	cap.CFrame = CFrame.new(original.Position.X, top + cap.Size.Y / 2, original.Position.Z) * original.CFrame.Rotation
	cap.Color, cap.Material = Color3.fromRGB(92, 152, 66), Enum.Material.Grass
	cap.TopSurface = Enum.SurfaceType.Smooth
	cap:SetAttribute("SourceOldCapIndex", index)
	cap:SetAttribute("Style", "LowPolyNature")
	return cap
end

function Nature.RefreshFacades(environment)
	local arena = environment and environment:FindFirstChild("GrasslandArena")
	local decor = arena and arena:FindFirstChild("NatureDecor")
	local floor = arena and arena:FindFirstChild("ArenaFloor")
	local cliffs = arena and arena:FindFirstChild("BoundaryCliffs")
	local old = ServerStorage:FindFirstChild("PolishOld")
	if not decor or not floor or not floor:IsA("BasePart") or not cliffs or not old then
		return false
	end
	if decor:GetAttribute("NatureFacadeRevision") == Nature.FacadeRevision then
		return true
	end
	local archivePath = decor:GetAttribute("ArchivePath")
	local archive
	for _, candidate in old:GetChildren() do
		if candidate:GetFullName() == archivePath then
			archive = candidate
			break
		end
	end
	if not archive then
		return false
	end
	local originals = sortedChildren(archive, "WeatheredCliff", "BasePart")
	local corners = sortedChildren(cliffs, "WallCorner", "BasePart")
	local oldCaps = sortedChildren(cliffs, "GrassyCliffTop", "BasePart")
	local faces, cornerModels = {}, {}
	for _, model in decor:GetChildren() do
		if model:IsA("Model") then
			if model.Name == "CliffStraightA" or model.Name == "CliffStraightB" then
				table.insert(faces, model)
			elseif model.Name == "CliffCorner" then
				table.insert(cornerModels, model)
			end
		end
	end
	if #faces ~= #originals or #cornerModels ~= #corners or #oldCaps ~= #originals then
		return false
	end
	local moves = {}
	local function planMoves(models, oldParts, attribute, frameFor)
		local used = {}
		for _, model in models do
			local index = model:GetAttribute(attribute)
			if index then
				if not oldParts[index] or used[index] then
					return false
				end
				used[index] = true
				table.insert(moves, { model, frameFor(oldParts[index], floor), attribute, index })
			end
		end
		for _, model in models do
			if not model:GetAttribute(attribute) then
				local index, distance
				local position = model:GetPivot().Position
				for candidate, part in oldParts do
					if not used[candidate] then
						local d = (position.X - part.Position.X) ^ 2 + (position.Z - part.Position.Z) ^ 2
						if not distance or d < distance then
							index, distance = candidate, d
						end
					end
				end
				if not index then
					return false
				end
				used[index] = true
				table.insert(moves, { model, frameFor(oldParts[index], floor), attribute, index })
			end
		end
		return true
	end
	if not planMoves(faces, originals, "FacadeIndex", inwardFrame)
		or not planMoves(cornerModels, corners, "CornerIndex", cornerFrame) then
		return false
	end
	local caps = {}
	local ok, failure = pcall(function()
		for i, original in oldCaps do
			table.insert(caps, supportedGrassCap(original, cliffs, i))
		end
	end)
	if not ok then
		for _, cap in caps do
			cap:Destroy()
		end
		error(failure)
	end
	for _, move in moves do
		move[1]:PivotTo(move[2])
		move[1]:SetAttribute(move[3], move[4])
	end
	for i, original in oldCaps do
		original.Parent = archive
		caps[i].Parent = decor
	end
	decor:SetAttribute("NatureFacadeRevision", Nature.FacadeRevision)
	return true
end

function Nature.ApplyLighting()
	return EnvironmentLighting.Apply()
end

function Nature.Apply(environment)
	local sources = templates()
	local arena = environment and environment:FindFirstChild("GrasslandArena")
	if not sources or not arena then
		return false
	end
	local floor = arena:FindFirstChild("ArenaFloor")
	local cliffs = arena:FindFirstChild("BoundaryCliffs")
	local cover = arena:FindFirstChild("CombatCover")
	if not floor or not floor:IsA("BasePart") or not cliffs or not cover
		or not arena:FindFirstChild("BanditClearings") or not arena:FindFirstChild("InvisibleBounds") then
		return false
	end
	local existing = arena:FindFirstChild("NatureDecor")
	if arena:GetAttribute("NatureRevision") == Nature.Revision and existing then
		Nature.ApplyLighting()
		return true
	elseif existing then
		-- An unfinished or different revision requires an explicit migration.
		return false
	end
	local oldCliffs = sortedChildren(cliffs, "WeatheredCliff", "BasePart")
	local oldRocks = sortedChildren(cover, "GrasslandRock", "Model")
	local oldCaps = sortedChildren(cliffs, "GrassyCliffTop", "BasePart")
	if #oldCliffs == 0 or #oldRocks == 0 or #oldCaps ~= #oldCliffs then
		return false
	end
	local decor = Instance.new("Model")
	decor.Name = "NatureDecor"
	decor:SetAttribute("Style", "LowPolyNature")
	decor:SetAttribute("NatureRevision", Nature.Revision)
	decor:SetAttribute("NatureFacadeRevision", Nature.FacadeRevision)
	local ok, failure = pcall(function()
		for i, part in oldCliffs do
			local name = i % 2 == 1 and "CliffStraightA" or "CliffStraightB"
			local model = cloneFitted(sources[name], name, inwardFrame(part, floor),
				Vector3.new(part.Size.X + 0.1, part.Size.Y, part.Size.Z + 0.4), decor, false)
			model:SetAttribute("FacadeIndex", i)
		end
		for i, part in sortedChildren(cliffs, "WallCorner", "BasePart") do
			local model = cloneFitted(sources.CliffCorner, "CliffCorner", cornerFrame(part, floor),
				Vector3.new(part.Size.X + 0.4, part.Size.Y, part.Size.Z + 0.4), decor, false)
			model:SetAttribute("CornerIndex", i)
		end
		for i, cap in oldCaps do
			supportedGrassCap(cap, cliffs, i).Parent = decor
		end
		local viewingWall, glass = cliffs:FindFirstChild("ViewingWall"), cliffs:FindFirstChild("ViewingGlass")
		if viewingWall and viewingWall:IsA("BasePart") and glass and glass:IsA("BasePart") then
			-- Entire end-cap footprint stays outside the original glass opening.
			for _, sign in { -1, 1 } do
				local base = viewingWall.CFrame * CFrame.new(sign * (glass.Size.X / 2 + 6.2), -viewingWall.Size.Y / 2, 0)
				cloneFitted(sources.CliffEnd, "CliffEnd", base * CFrame.Angles(0, sign * math.pi / 2, 0),
					Vector3.new(viewingWall.Size.Z, 26, 12), decor, false)
			end
		end
		local groundY = floor.Position.Y + floor.Size.Y / 2
		for i, model in oldRocks do
			local cf = model:GetBoundingBox()
			local name = ROCKS[(i - 1) % #ROCKS + 1]
			local target = CFrame.new(cf.Position.X, groundY, cf.Position.Z) * CFrame.Angles(0, i * 0.73, 0)
			cloneFitted(sources[name], name, target, SIZES[name], decor, true)
		end
		local grass = Instance.new("Part")
		grass.Name = "ArenaGrassSurface"
		grass.Size = Vector3.new(floor.Size.X, 0.02, floor.Size.Z)
		grass.CFrame = floor.CFrame * CFrame.new(0, floor.Size.Y / 2 + 0.005, 0)
		grass.Color, grass.Material = Color3.fromRGB(92, 152, 66), Enum.Material.Grass
		grass.Anchored, grass.CanCollide, grass.CanQuery, grass.CanTouch = true, false, false, false
		grass.TopSurface, grass.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
		grass.Parent = decor
	end)
	if not ok then
		decor:Destroy()
		error(failure)
	end
	-- All replacement geometry is ready before the originals leave the workspace.
	local old = ServerStorage:FindFirstChild("PolishOld") or Instance.new("Folder")
	old.Name, old.Parent = "PolishOld", ServerStorage
	local archiveName, suffix = "Arena_Nature_v1", 1
	while old:FindFirstChild(archiveName) do
		suffix += 1
		archiveName = "Arena_Nature_v1_" .. suffix
	end
	local archive = Instance.new("Folder")
	archive.Name, archive.Parent = archiveName, old
	for _, part in oldCliffs do
		part.Parent = archive
	end
	for _, model in oldRocks do
		model.Parent = archive
	end
	for _, cap in oldCaps do
		cap.Parent = archive
	end
	decor:SetAttribute("ArchivePath", archive:GetFullName())
	decor.Parent = arena
	arena:SetAttribute("NatureRevision", Nature.Revision)
	Nature.ApplyLighting()
	return true
end

return Nature
