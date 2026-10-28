-- Run only as a temporary Script in a Studio Play server. Removes its isolated fixtures.
local RunService = game:GetService("RunService")
assert(RunService:IsStudio() and RunService:IsRunning(), "Studio Play only")
local Service = require(game.ServerScriptService.Server.Services.PowerMoveService)
local Config = require(game.ReplicatedStorage.Shared.PilotConfig)
local fixture = Instance.new("Folder")
fixture.Name = "PowerMoveTestFixtures"
fixture.Parent = workspace
local function actor(name, position)
	local model = Instance.new("Model")
	model.Name = name
	local root = Instance.new("Part")
	root.Name, root.Size, root.Anchored = "HumanoidRootPart", Vector3.new(2, 2, 1), true
	root.CFrame, root.Parent = CFrame.new(position), model
	model.PrimaryPart, model.Parent = root, fixture
	return { Model = model, HP = 100, Active = true, Inhales = 0 }
end
local source = actor("CastFixture", Vector3.new(0, 2000, 0))
local target = actor("CatchFixture", Vector3.new(0, 2000, -8))
target.Model.PrimaryPart.CFrame = CFrame.lookAt(target.Model.PrimaryPart.Position, source.Model.PrimaryPart.Position)
local hits = 0
local combat = { Enabled = true, Actors = { source, target } }
combat.Root = function(a) return a.Model.PrimaryPart end
combat.Alive = function(a) return a.Active and a.HP > 0 end
combat.Damage = function(_, _, amount)
	hits += 1
	return amount
end
combat.LineClear = function(from, to, excluded)
	local p = RaycastParams.new()
	p.FilterType = Enum.RaycastFilterType.Exclude
	p.FilterDescendantsInstances = excluded
	return workspace:Raycast(from, to - from, p) == nil
end
local result = { caught = 0, assertions = 0 }
local ok, err = pcall(function()
	for id, power in Config.Powers do
		target.Held, target.Inhaling, target.InhaleCatchUntil = nil, true, os.clock() + 2
		Service.Cast(combat, source, id, 1, power.Moves[1])
		task.wait(0.6)
		assert(target.Held and target.Held.Power == id, "Q capture failed: " .. id)
		assert(hits == 0, "Captured projectile dealt damage")
		result.caught += 1
	end
	target.Held, target.InhaleCatchUntil = nil, os.clock() - 1
	Service.Cast(combat, source, "Fire", 1, Config.Powers.Fire.Moves[1])
	task.wait(0.6)
	assert(not target.Held and hits == 1, "Expired catch protected target")
	result.assertions += 1
	target.Inhaling = false
	local wall = Instance.new("Part")
	wall.Anchored, wall.Size, wall.CFrame = true, Vector3.new(10, 10, 0.5), CFrame.new(0, 2000, -1.5)
	wall.Parent = fixture
	Service.Cast(combat, source, "Wind", 1, Config.Powers.Wind.Moves[1])
	task.wait(0.6)
	assert(hits == 1, "Projectile skipped nearby wall")
	wall:Destroy()
	result.assertions += 1
	Service.Cast(combat, source, "Fire", 3, Config.Powers.Fire.Moves[3])
	Service.Cancel(source)
	task.wait(1)
	assert(hits == 1, "Cancelled delayed cast dealt damage")
	result.assertions += 1
end)
Service.Cancel(source)
source.Active, target.Active = false, false
fixture:Destroy()
script:SetAttribute("Result", game:GetService("HttpService"):JSONEncode(result))
script:SetAttribute("Passed", ok)
if not ok then script:SetAttribute("Error", tostring(err)) end
