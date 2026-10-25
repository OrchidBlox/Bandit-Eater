local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Shared = game:GetService("ReplicatedStorage").Shared
local Remotes = require(Shared.Remotes)
local Config = require(Shared.Config.Movement)
local Combat = require(script.Parent.PilotCombat)
local Service = {}
local states = {}

local function body(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
		or root.Anchored or humanoid.Sit or humanoid.PlatformStand then return end
	local mode = humanoid:GetState()
	if mode ~= Enum.HumanoidStateType.Running and mode ~= Enum.HumanoidStateType.RunningNoPhysics
		and mode ~= Enum.HumanoidStateType.Landed and mode ~= Enum.HumanoidStateType.Jumping
		and mode ~= Enum.HumanoidStateType.Freefall then return end
	return humanoid, root
end

local function grounded(character, humanoid, root)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	params.RespectCanCollide = true
	local distance = humanoid.HipHeight + root.Size.Y / 2 + 0.15
	local hit = workspace:Raycast(root.Position, Vector3.new(0, -distance, 0), params)
	return hit ~= nil and hit.Normal.Y > 0.4 and math.abs(root.AssemblyLinearVelocity.Y) < 4
end

function Service.Start()
	RunService.Heartbeat:Connect(function(dt)
		for _, player in Players:GetPlayers() do
			local character = player.Character
			local state = states[player]
			if not state or state.character ~= character then
				state = { character = character, available = false, groundTime = 0, airTime = 0, lastRequest = 0 }
				states[player] = state
			end
			local humanoid, root = body(character)
			if humanoid and grounded(character, humanoid, root) then
				state.airTime = 0
				state.groundTime += dt
				if state.groundTime >= Config.GroundResetTime then
					state.available = true
				end
			else
				state.airTime += dt
				state.groundTime = 0
				if not humanoid then
					state.available = false
				end
			end
		end
	end)
	Remotes.DoubleJump.OnServerEvent:Connect(function(player, character)
		local state = states[player]
		if not state or character ~= player.Character or character ~= state.character then return end
		local now = os.clock()
		if now - state.lastRequest < Config.RequestInterval then return end
		state.lastRequest = now
		local actor = Combat.Actors[player]
		if actor and (actor.Dead or now < (actor.Stunned or 0)) then return end
		local humanoid, root = body(character)
		if not humanoid or not state.available or state.airTime < 0.12
			or grounded(character, humanoid, root) then return end
		local mode = humanoid:GetState()
		if mode ~= Enum.HumanoidStateType.Jumping and mode ~= Enum.HumanoidStateType.Freefall then return end
		state.available, state.groundTime = false, 0
		local velocity = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, Config.DoubleJumpVelocity, velocity.Z)
		Remotes.DoubleJump:FireAllClients(character)
	end)
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
end

return Service
