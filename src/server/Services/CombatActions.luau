-- Server-owned action timing. Animation markers are presentation, never damage requests.
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config.CombatActions)
local Remotes = require(Shared.Remotes)
local Actions = {}

local function send(state, phase, position)
	Remotes.CombatAction:FireAllClients({ Character = state.model, Action = state.name,
		Phase = phase, Token = state.token, Time = state.time, Position = position })
end

function Actions.Cancel(actor)
	local state = actor.CombatAction
	if not state then
		return
	end
	actor.CombatAction = nil
	if state.cleanup then
		state.cleanup()
	end
	if state.model.Parent then
		state.model:SetAttribute("CombatActionUntil", nil)
		state.model:SetAttribute("CombatActionName", nil)
	end
	send(state, "Cancel")
end

local function valid(combat, actor, state)
	return combat.Enabled and combat.Alive(actor) and not actor.Dead and not actor.Inhaling
		and actor.Model == state.model and state.model.Parent ~= nil and actor.CombatAction == state
		and combat.Root(actor) == state.root
		and os.clock() >= (actor.Stunned or 0)
end

local function begin(actor, name)
	Actions.Cancel(actor)
	local state = { model = actor.Model, name = name, token = HttpService:GenerateGUID(false),
		time = workspace:GetServerTimeNow(), root = actor.Model:FindFirstChild("HumanoidRootPart") }
	actor.CombatAction = state
	state.model:SetAttribute("CombatActionUntil", state.time + Config.Durations[name])
	state.model:SetAttribute("CombatActionName", name)
	send(state, "Start")
	task.delay(Config.Durations[name], function()
		if actor.CombatAction == state then
			Actions.Cancel(actor)
		end
	end)
	return state
end

function Actions.M1(combat, actor)
	if actor.CombatAction and actor.CombatAction.name == "Dash" then
		return
	end
	if not combat.Ready(actor, "M1", Config.M1Cooldown) then
		return
	end
	local now = os.clock()
	actor.Combo = now - (actor.LastM1At or -math.huge) > Config.ComboReset and 1 or (actor.Combo or 0) % 3 + 1
	actor.LastM1At = now
	local combo = actor.Combo
	local name = "M1_" .. combo
	local state = begin(actor, name)
	task.delay(Config.StrikeTimes[name], function()
		if not valid(combat, actor, state) then
			if actor.CombatAction == state then
				Actions.Cancel(actor)
			end
			return
		end
		local root = combat.Root(actor)
		local center = root.Position + root.CFrame.LookVector * 4
		for _, target in combat.Actors do
			local targetRoot = combat.Root(target)
			if target ~= actor and combat.Alive(target) and (targetRoot.Position - center).Magnitude <= 4
				and combat.LineClear(root.Position, targetRoot.Position, { state.model, target.Model }) then
				local actual = combat.Damage(actor, target, combo == 3 and 9 or 6, 0, combo == 3, true)
				if actual and actual > 0 then
					send(state, "Hit", targetRoot.Position + Vector3.new(0, 1, 0))
				end
			end
		end
	end)
end

function Actions.Dash(combat, actor)
	if not combat.Ready(actor, "Dash", Config.DashCooldown) then
		return
	end
	local root = combat.Root(actor)
	local humanoid = actor.Model:FindFirstChildOfClass("Humanoid")
	if root.Anchored or (humanoid and (humanoid.Sit or humanoid.PlatformStand)) then
		return
	end
	local look = root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.01 then
		return
	end
	local direction = flat.Unit
	local state = begin(actor, "Dash")
	task.delay(Config.DashBurstTime, function()
		if not valid(combat, actor, state) then
			if actor.CombatAction == state then
				Actions.Cancel(actor)
			end
			return
		end
		actor.Invulnerable = os.clock() + Config.DashInvulnerability
		local autoRotate = humanoid and humanoid.AutoRotate
		if humanoid then
			humanoid.AutoRotate = false
		end
		local owned = pcall(function()
			root:SetNetworkOwner(nil)
		end)
		local connection
		local cleaned = false
		local function cleanup()
			if cleaned then
				return
			end
			cleaned = true
			if connection then
				connection:Disconnect()
			end
			if humanoid and humanoid.Parent then
				humanoid.AutoRotate = autoRotate
			end
			if owned and root.Parent then
				pcall(function()
					root:SetNetworkOwnershipAuto()
				end)
			end
		end
		state.cleanup = cleanup
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { state.model }
		params.RespectCanCollide = true
		local elapsed = 0
		local duration = Config.DashBrakeTime - Config.DashBurstTime
		-- Fast launch, then ease into the brake pose instead of stopping at full speed.
		local function travelAt(time)
			local alpha = math.clamp(time / duration, 0, 1)
			return Config.DashDistance * (1 - (1 - alpha) ^ 2)
		end
		connection = RunService.Heartbeat:Connect(function(dt)
			if not valid(combat, actor, state) or root.Anchored then
				cleanup()
				if actor.CombatAction == state then
					Actions.Cancel(actor)
				end
				return
			end
			local stepTime = math.min(dt, duration - elapsed)
			local step = travelAt(elapsed + stepTime) - travelAt(elapsed)
			local hit = workspace:Blockcast(root.CFrame, Vector3.new(3, 4, 2), direction * (step + 0.1), params)
			local distance = hit and math.clamp(hit.Distance - 0.1, 0, step) or step
			local velocity = root.AssemblyLinearVelocity
			root.AssemblyLinearVelocity = Vector3.new(0, velocity.Y, 0)
			state.model:PivotTo(state.model:GetPivot() + direction * distance)
			elapsed += stepTime
			if hit or elapsed >= duration then
				cleanup()
			end
		end)
	end)
end

return Actions
