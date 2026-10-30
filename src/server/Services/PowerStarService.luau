-- Server-owned roaming pickups. Combat.Bandits remains a compatibility registry only.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visual = require(ReplicatedStorage.Shared.PowerStarVisual)
local CollectionService = game:GetService("CollectionService")
local Stars = { MaxCount = 6 }
local rng = Random.new()
local warnedMissingTemplate = false
local function usable(record)
	local model = record and record.Model
	return model and model:IsDescendantOf(workspace) and model.PrimaryPart
		and model.PrimaryPart:IsDescendantOf(model)
end
local function prune(records)
	for index, record in records do
		if not usable(record) then
			if record.Model then
				record.Model:Destroy()
			end
			records[index] = nil
		end
	end
end
local function parameters(world)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { world.Environment }
	params.RespectCanCollide = true
	return params
end
local function valid(world, position)
	local floor = world.ArenaFloor
	local p = floor.CFrame:PointToObjectSpace(position)
	if math.abs(p.X) > floor.Size.X / 2 - 22 or math.abs(p.Z) > floor.Size.Z / 2 - 22 then
		return false
	end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { world.Environment }
	params.RespectCanCollide = true
	for _, part in workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(4, 4, 4), params) do
		if part ~= floor then
			return false
		end
	end
	return true
end
local function randomPosition(world, records)
	local floor = world.ArenaFloor
	for _ = 1, 100 do
		local position = floor.CFrame:PointToWorldSpace(Vector3.new(
			rng:NextNumber(-floor.Size.X / 2 + 24, floor.Size.X / 2 - 24), floor.Size.Y / 2 + 2.5,
			rng:NextNumber(-floor.Size.Z / 2 + 24, floor.Size.Z / 2 - 24)))
		local spaced = true
		for _, record in records do
			if (record.Model.PrimaryPart.Position - position).Magnitude < 18 then
				spaced = false
				break
			end
		end
		if spaced and valid(world, position) then
			return position
		end
	end
	return nil
end
function Stars.Spawn(world, records, index, powers)
	prune(records)
	if index < 1 or index > Stars.MaxCount or records[index] then
		return false
	end
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local folder = assets and assets:FindFirstChild("PowerStars")
	local template = folder and folder:FindFirstChild("Body")
	if not template or not template:IsA("MeshPart") then
		if not warnedMissingTemplate then
			warn("[PowerStarService] Missing Assets.PowerStars.Body MeshPart; star spawn deferred until installed.")
			warnedMissingTemplate = true
		end
		return false
	end
	warnedMissingTemplate = false
	local position = randomPosition(world, records)
	if not position then
		return false
	end
	local power = powers[rng:NextInteger(1, #powers)]
	local model = Instance.new("Model")
	model.Name = power .. "PowerStar"
	local body = Visual.Create(power, template)
	body.Parent = model
	model.PrimaryPart = body
	model:SetAttribute("PowerId", power)
	model:SetAttribute("IsPowerStar", true)
	CollectionService:AddTag(model, "PowerStar") -- StarController draws these on the client
	model:PivotTo(CFrame.new(position))
	model.Parent = world.Root
	local angle = rng:NextNumber(0, math.pi * 2)
	records[index] = { Model = model, Power = power, Variant = "Normal", IsPowerStar = true,
		Position = position, Direction = Vector3.new(math.cos(angle), 0, math.sin(angle)),
		Age = rng:NextNumber(0, 5), TurnAt = os.clock() + rng:NextNumber(1, 4) }
	return true
end
function Stars.Reserve(record, actor)
	local now = os.clock()
	if not usable(record) or (record.ReservedBy and record.ReservedBy ~= actor and now < record.ReservedUntil) then
		return false
	end
	record.ReservedBy, record.ReservedUntil = actor, now + 0.2
	record.Model:SetAttribute("Pulled", true) -- the client draws the inhale pull
	return true
end
function Stars.Release(records, actor)
	for _, record in records do
		if record.ReservedBy == actor then
			record.ReservedUntil = 0
		end
	end
end
function Stars.Step(world, records, dt)
	local now = os.clock()
	prune(records)
	for _, record in records do
		if record.ReservedBy and now < record.ReservedUntil then
			continue
		end
		if record.ReservedBy then
			record.ReservedBy, record.ReservedUntil = nil, nil
			record.Model:SetAttribute("Pulled", false)
			local position = record.Model.PrimaryPart.Position
			position = Vector3.new(position.X, world.ArenaFloor.Position.Y + world.ArenaFloor.Size.Y / 2 + 2.5, position.Z)
			if valid(world, position) then
				record.Position = position
			end
		end
		if now >= record.TurnAt then
			local angle = rng:NextNumber(-1, 1)
			record.Direction = CFrame.Angles(0, angle, 0):VectorToWorldSpace(record.Direction)
			record.TurnAt = now + rng:NextNumber(1.5, 4)
		end
		local delta = record.Direction * math.min(dt, 0.15) * 6
		local nextPosition = record.Position + delta
		if valid(world, nextPosition) and not workspace:Spherecast(record.Position, 1.8, delta, parameters(world)) then
			record.Position = nextPosition
		else
			record.Direction = -record.Direction
			record.TurnAt = now + 0.3
		end
		record.Age += dt
		record.Model:PivotTo(CFrame.new(record.Position))
	end
end
return Stars
