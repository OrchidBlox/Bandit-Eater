-- Held swords. The server publishes each fighter's active power as the character attribute "ActivePower"; this
-- controller welds the matching sword (ReplicatedStorage.Assets.Swords) to the right hand and, for the local
-- player, plays the ready hold (when the sword clip set has one) while nothing else is using the arms. Presentation only: no hitboxes,
-- no damage, no movement.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage.Shared.Config.CombatActions)

local Controller = {}

-- Active power -> sword template in ReplicatedStorage.Assets.Swords (every one shares the same grip and blade length).
local SWORDS = {
	Sword = "Sword", Sword_Wind = "WindSword", Sword_Earth = "EarthSword", Sword_Water = "WaterSword",
	Sword_Fire = "FireSword", Sword_Shadow = "ShadowSword", Sword_Sword = "MasterSword",
}

-- Grip measured in Blender with the sword attached to the canonical rig (blender/anims/build_sword_rig.py ->
-- blender/review/BE_SwordRig_Sword_grip.json): the sword's frame relative to the RightHand part. Every sword
-- shares this grip and blade length, so one set of two-handed clips fits all of them.
local GRIP = CFrame.fromMatrix(Vector3.new(0.0002, -0.312, -0.0691),
	Vector3.new(0.004, -1, 0.0026), Vector3.new(0, -0.0026, -1), Vector3.new(1, 0.004, 0))

local READY_FADE, MOVING_SPEED = 0.15, 1.5

local connections = {}
local held = {} -- character -> { sword = MeshPart, power = string }
local ready = { character = nil, tracks = {} } -- local player's ready-hold tracks

local function clear(character)
	local entry = held[character]
	if entry then
		entry.sword:Destroy()
		held[character] = nil
	end
end

local function refresh(character)
	local power = character:GetAttribute("ActivePower")
	local name = power and SWORDS[power]
	local entry = held[character]
	if entry and entry.power == power then
		return
	end
	clear(character)
	local library = ReplicatedStorage:FindFirstChild("Assets")
	library = library and library:FindFirstChild("Swords")
	local template = name and library and library:FindFirstChild(name)
	local hand = character:FindFirstChild("RightHand")
	if not template or not hand then
		return
	end
	local sword = template:Clone()
	sword.Name = "HeldSword"
	-- A weld attaches the part's bounding-box centre, not its pivot. C1 = PivotOffset puts the grip (the pivot) in
	-- the hand instead of the middle of the blade.
	local weld = Instance.new("Weld")
	weld.Part0, weld.Part1, weld.C0, weld.C1 = hand, sword, GRIP, sword.PivotOffset
	weld.Parent = sword
	sword.Parent = character
	held[character] = { sword = sword, power = power }
end

local function stopReady()
	for _, track in ready.tracks do
		track:Stop(READY_FADE)
		track:Destroy()
	end
	table.clear(ready.tracks)
	ready.character = nil
end

-- Two-handed ready hold for the local player (the Animator replicates it to everyone else). It yields to any
-- other Action-or-higher track (M1, casts, swallow), and swaps to the upper-body variant while moving or airborne.
local function updateReady()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not held[character] or not animator or not root or humanoid.Health <= 0 or not character:IsDescendantOf(workspace) then
		if ready.character then
			stopReady()
		end
		return
	end
	if ready.character ~= character then
		stopReady()
		ready.character = character
		local set = Config.SwordM1.Sword
		for key, id in { Still = set.Ready, Moving = set.ReadyMoving } do
			local animation = Instance.new("Animation")
			animation.AnimationId = id
			local ok, track = pcall(function()
				return animator:LoadAnimation(animation)
			end)
			animation:Destroy()
			if ok then
				track.Priority, track.Looped = Enum.AnimationPriority.Action, true
				ready.tracks[key] = track
			end
		end
	end
	local busy = false
	for _, track in animator:GetPlayingAnimationTracks() do
		local priority = track.Priority.Value
		if track ~= ready.tracks.Still and track ~= ready.tracks.Moving and priority >= Enum.AnimationPriority.Action.Value
			and priority < Enum.AnimationPriority.Core.Value then
			busy = true
			break
		end
	end
	local velocity = root.AssemblyLinearVelocity
	local moving = Vector3.new(velocity.X, 0, velocity.Z).Magnitude > MOVING_SPEED or humanoid.FloorMaterial == Enum.Material.Air
	local want = not busy and (moving and ready.tracks.Moving or ready.tracks.Still) or nil
	for _, track in ready.tracks do
		if track == want and not track.IsPlaying then
			track:Play(READY_FADE, 1, 1)
		elseif track ~= want and track.IsPlaying then
			track:Stop(READY_FADE)
		end
	end
end

local function watch(character)
	if held[character] ~= nil then
		return
	end
	local hand = character:WaitForChild("RightHand", 10)
	if not hand or not character.Parent then
		return
	end
	table.insert(connections, character:GetAttributeChangedSignal("ActivePower"):Connect(function()
		refresh(character)
	end))
	table.insert(connections, character.Destroying:Connect(function()
		clear(character)
	end))
	refresh(character)
end

local function watchPlayer(player)
	table.insert(connections, player.CharacterAdded:Connect(watch))
	if player.Character then
		task.spawn(watch, player.Character)
	end
end

function Controller.Stop()
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
	stopReady()
	for character in held do
		clear(character)
	end
end

function Controller.Start()
	table.insert(connections, Players.PlayerAdded:Connect(watchPlayer))
	for _, player in Players:GetPlayers() do
		watchPlayer(player)
	end
	table.insert(connections, RunService.Heartbeat:Connect(updateReady))
end

return Controller
