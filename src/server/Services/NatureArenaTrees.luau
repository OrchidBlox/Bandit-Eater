-- Replace the five arena tree visuals and keep their trunks clear of paths.
local ServerStorage = game:GetService("ServerStorage")

local Trees = { Revision = 2 }
local PATH_CLEARANCE = 3.5
local CLEARANCE_EPSILON = 0.02
local VARIANTS = { "TreeRoundA", "TreeRoundB", "TreeRoundC" }
local SIZES = {
	TreeRoundA = Vector3.new(22, 27, 20),
	TreeRoundB = Vector3.new(20, 25, 18),
	TreeRoundC = Vector3.new(24, 29, 22),
}
local ROLES = { "LeafBase_6FAE4A", "LeafShade_4C8A3A", "TrunkBase_7A5236", "TrunkShade_62412C" }

local function approvedTemplates()
	local props = ServerStorage:FindFirstChild("MapProps")
	local folder = props and props:FindFirstChild("LowPolyNature")
	if not folder then
		return nil
	end
	local result = {}
	for _, name in VARIANTS do
		local model = folder:FindFirstChild(name)
		if not model or not model:IsA("Model") then
			return nil
		end
		local count, roles = 0, {}
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				if not part:IsA("MeshPart") or part.MeshId == "" then
					return nil
				end
				count += 1
				for _, role in ROLES do
					if string.sub(part.Name, -#role) == role then
						roles[role] = (roles[role] or 0) + 1
					end
				end
			end
		end
		if count ~= 4 then
			return nil
		end
		for _, role in ROLES do
			if roles[role] ~= 1 then
				return nil
			end
		end
		local pivot = model:GetPivot()
		local bounds, size = model:GetBoundingBox()
		local relative = pivot:ToObjectSpace(bounds)
		local expected = SIZES[name]
		-- Imported templates must already be upright, one stud per source unit,
		-- with their origin centred on the bottom of the measured bounds.
		if pivot.Position.Magnitude > 0.01 or pivot.UpVector:Dot(Vector3.yAxis) < 0.9999
			or (size - expected).Magnitude > 0.03
			or math.abs(relative.Position.Y - size.Y / 2) > 0.01
			or math.abs(relative.Position.X) > 0.01 or math.abs(relative.Position.Z) > 0.01 then
			return nil
		end
		result[name] = model
	end
	return result
end

local function oldPlacement(model)
	local beam = model:FindFirstChild("TrunkBase")
	if not beam or not beam:IsA("BasePart") then
		return nil
	end
	-- P.Beam's length is local Z and its LookVector points toward the upper end.
	local a = beam.Position - beam.CFrame.LookVector * beam.Size.Z / 2
	local b = beam.Position + beam.CFrame.LookVector * beam.Size.Z / 2
	local base, tip = a, b
	if b.Y < a.Y then
		base, tip = b, a
	end
	local direction = Vector3.new(tip.X - base.X, 0, tip.Z - base.Z)
	if direction.Magnitude < 0.0001 then
		local right = model:GetPivot().RightVector
		direction = Vector3.new(right.X, 0, right.Z)
	end
	-- The original TrunkBase leans along its origin's positive local X axis.
	local yaw = math.atan2(-direction.Z, direction.X)
	return { model = model, base = base, yaw = yaw }
end

local function archiveFor(decor)
	local old = ServerStorage:FindFirstChild("PolishOld")
	if old then
		for _, candidate in old:GetChildren() do
			if candidate:GetFullName() == decor:GetAttribute("ArchivePath") then
				return candidate
			end
		end
	end
	return nil
end

local function pathCorrection(position, path)
	local q = path.CFrame:PointToObjectSpace(position)
	if math.abs(q.Z) <= path.Size.Z / 2 + PATH_CLEARANCE
		and math.abs(q.X) < path.Size.X / 2 + PATH_CLEARANCE then
		local sign = q.X < 0 and -1 or 1
		local distance = path.Size.X / 2 + PATH_CLEARANCE + CLEARANCE_EPSILON - math.abs(q.X)
		local normal = path.CFrame.RightVector
		return Vector3.new(normal.X, 0, normal.Z).Unit * sign * distance
	end
	return nil
end

local function clearPosition(position, paths)
	local result = position
	for _ = 1, 4 do
		local shortest
		for _, path in paths do
			local correction = pathCorrection(result, path)
			if correction and (not shortest or correction.Magnitude < shortest.Magnitude) then
				shortest = correction
			end
		end
		if not shortest then
			break
		end
		result += shortest
	end
	for _, path in paths do
		if pathCorrection(result, path) then
			return nil
		end
	end
	return result
end

local function planPathClearance(arena, group)
	local pathsFolder, originalTrees = arena:FindFirstChild("Paths"), arena:FindFirstChild("Trees")
	if not pathsFolder or not originalTrees then
		return nil
	end
	local paths, colliders, models = {}, {}, {}
	for _, path in pathsFolder:GetChildren() do
		if path.Name == "DirtPath" and path:IsA("BasePart") then
			table.insert(paths, path)
		end
	end
	for _, collider in originalTrees:GetChildren() do
		if collider.Name == "TreeTrunkCollision" and collider:IsA("BasePart") then
			table.insert(colliders, collider)
		end
	end
	for _, model in group:GetChildren() do
		if model:IsA("Model") then
			table.insert(models, model)
		end
	end
	if #paths == 0 or #colliders ~= 5 or #models ~= 5 then
		return nil
	end
	local moves, usedColliders = {}, {}
	for _, model in models do
		local pivot = model:GetPivot()
		local cleared = clearPosition(pivot.Position, paths)
		if not cleared then
			return nil
		end
		local offset = cleared - pivot.Position
		if offset.Magnitude > 0.0001 then
			local matched, matches = nil, 0
			for _, collider in colliders do
				local delta = collider.Position - pivot.Position
				if Vector3.new(delta.X, 0, delta.Z).Magnitude < 0.1 then
					matched, matches = collider, matches + 1
				end
			end
			if matches ~= 1 or usedColliders[matched] then
				return nil
			end
			usedColliders[matched] = true
			table.insert(moves, { model = model, target = pivot + offset, oldCollider = matched,
				colliderParent = matched.Parent, colliderFrame = matched.CFrame + offset })
		end
	end
	-- No live instance moves until every tree has a clear position and a matched
	-- original collider. Only the affected colliders receive replacement clones.
	for _, move in moves do
		local replacement = move.oldCollider:Clone()
		if not replacement then
			for _, staged in moves do
				if staged.newCollider then
					staged.newCollider:Destroy()
				end
			end
			return nil
		end
		replacement.CFrame = move.colliderFrame
		move.newCollider = replacement
	end
	return moves
end

local function commitPathClearance(group, archive, moves)
	for _, move in moves do
		move.model:PivotTo(move.target)
		move.oldCollider.Parent = archive
		move.newCollider.Parent = move.colliderParent
	end
	group:SetAttribute("TreeRevision", Trees.Revision)
end

function Trees.ClearPaths(environment)
	local arena = environment and environment:FindFirstChild("GrasslandArena")
	local decor = arena and arena:FindFirstChild("NatureDecor")
	local group = decor and decor:FindFirstChild("Trees")
	if not group or not group:IsA("Model") then
		return false
	end
	if group:GetAttribute("TreeRevision") == Trees.Revision then
		return true
	end
	if group:GetAttribute("TreeRevision") ~= 1 then
		return false
	end
	local archive = archiveFor(decor)
	if not archive then
		return false
	end
	local moves = planPathClearance(arena, group)
	if not moves then
		return false
	end
	commitPathClearance(group, archive, moves)
	return true
end

function Trees.Apply(environment)
	local arena = environment and environment:FindFirstChild("GrasslandArena")
	local decor = arena and arena:FindFirstChild("NatureDecor")
	local originalTrees = arena and arena:FindFirstChild("Trees")
	local floor = arena and arena:FindFirstChild("ArenaFloor")
	if not decor or not originalTrees or not floor or not floor:IsA("BasePart") then
		return false
	end
	local existing = decor:FindFirstChild("Trees")
	if existing then
		return Trees.ClearPaths(environment)
	end
	local sources = approvedTemplates()
	local archive = archiveFor(decor)
	if not sources or not archive then
		return false
	end
	local placements = {}
	for _, model in originalTrees:GetChildren() do
		if model.Name == "GrasslandOak" and model:IsA("Model") then
			local placement = oldPlacement(model)
			if not placement then
				return false
			end
			table.insert(placements, placement)
		end
	end
	if #placements ~= 5 then
		return false
	end
	table.sort(placements, function(a, b)
		if a.base.X == b.base.X then
			return a.base.Z < b.base.Z
		end
		return a.base.X < b.base.X
	end)
	local staged = Instance.new("Model")
	staged.Name = "Trees"
	staged:SetAttribute("Style", "LowPolyNature")
	local groundY = floor.Position.Y + floor.Size.Y / 2
	local ok, failure = pcall(function()
		for i, placement in placements do
			local name = VARIANTS[(i - 1) % #VARIANTS + 1]
			local model = sources[name]:Clone()
			model.Name = name
			model.Parent = staged
			model:SetAttribute("TemplateName", name)
			model:SetAttribute("SourceOldTreeIndex", i)
			model:SetAttribute("Style", "LowPolyNature")
			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
					part.CastShadow = true
					part.Material = Enum.Material.SmoothPlastic
				end
			end
			model:PivotTo(CFrame.new(placement.base.X, groundY, placement.base.Z) * CFrame.Angles(0, placement.yaw, 0))
		end
	end)
	if not ok then
		staged:Destroy()
		error(failure)
	end
	local moves = planPathClearance(arena, staged)
	if not moves then
		staged:Destroy()
		return false
	end
	for _, placement in placements do
		placement.model.Parent = archive
	end
	commitPathClearance(staged, archive, moves)
	staged.Parent = decor
	return true
end

return Trees
