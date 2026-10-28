local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Config = require(ReplicatedStorage.Shared.Config.CombatActions)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Kit = require(script.Parent.Parent.Vfx.Kit)
local Effect = require(script.Parent.Parent.Vfx.Effects.CombatAction)
local Controller = {}
local connections, states, effects, cancelled, hits = {}, {}, {}, {}, {}
local started = false
local stats = { starts = 0, cancels = 0, hits = 0, effects = 0, culled = 0, rejected = 0,
	failedLoads = 0, fallbacks = 0, peakParts = 0 }

local function asset(id)
	return type(id) == "string" and string.match(id, "^rbxassetid://%d+$") ~= nil
end

local function valid(data)
	return type(data) == "table" and typeof(data.Character) == "Instance" and data.Character:IsA("Model")
		and type(data.Action) == "string" and Config.Durations[data.Action] ~= nil
		and (data.Phase == "Start" or data.Phase == "Cancel" or data.Phase == "Hit")
		and type(data.Token) == "string" and #data.Token > 0 and #data.Token <= 80
		and type(data.Time) == "number" and data.Time == data.Time
		and math.abs(workspace:GetServerTimeNow() - data.Time) <= Config.MaxEventAge
end

local function removeEffects(character)
	for index = #effects, 1, -1 do
		if effects[index].character == character then
			effects[index].effect:Destroy()
			table.remove(effects, index)
		end
	end
end

local function cancel(state)
	local active = state.active
	if active then
		for _, connection in active.connections do
			connection:Disconnect()
		end
		if active.track then
			active.track:Stop(Config.Fade)
		end
		state.active = nil
	end
end

local function cleanup(character)
	local state = states[character]
	if not state then return end
	states[character] = nil
	cancel(state)
	for _, connection in state.connections do
		connection:Disconnect()
	end
	for _, track in state.tracks do
		track:Stop(0)
		track:Destroy()
	end
	for _, animation in state.animations do
		animation:Destroy()
	end
	removeEffects(character)
end

local function getState(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not humanoid or humanoid.Health <= 0 or not animator or not character:IsDescendantOf(workspace) then return end
	local state = states[character]
	if state and state.animator ~= animator then
		cleanup(character)
		state = nil
	end
	if state then return state end
	local owner = Players:GetPlayerFromCharacter(character)
	state = { character = character, humanoid = humanoid, animator = animator,
		tracks = {}, animations = {}, connections = {}, lastStart = -math.huge,
		playLocally = not owner or owner == Players.LocalPlayer }
	states[character] = state
	if state.playLocally then
		local assets = table.clone(Config.Animations)
		for name, id in Config.MovingAnimations do
			assets[name .. "Moving"] = id
		end
		-- Every sword power shares one clip set, loaded once under the "Sword_" prefix.
		local swords = Config.SwordM1.Sword
		for name, id in swords.Animations do
			assets["Sword_" .. name] = id
		end
		for name, id in swords.MovingAnimations do
			assets["Sword_" .. name .. "Moving"] = id
		end
		for name, id in assets do
			if asset(id) then
				local animation = Instance.new("Animation")
				animation.Name, animation.AnimationId = "Combat" .. name, id
				local ok, track = pcall(function()
					return animator:LoadAnimation(animation)
				end)
				if ok then
					track.Priority, track.Looped = Enum.AnimationPriority.Action, false
					state.tracks[name], state.animations[name] = track, animation
				else
					stats.failedLoads += 1
					animation:Destroy()
				end
			end
		end
	end
	table.insert(state.connections, humanoid.Died:Connect(function()
		cleanup(character)
	end))
	table.insert(state.connections, animator.Destroying:Connect(function()
		cleanup(character)
	end))
	table.insert(state.connections, character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(workspace) then
			cleanup(character)
		end
	end))
	return state
end

local function draw(character, kind, position)
	local camera = workspace.CurrentCamera
	if not camera or typeof(position) ~= "Vector3" or (camera.CFrame.Position - position).Magnitude > Config.EffectDistance
		or #effects >= Config.MaxEffects then
		stats.culled += 1
		return
	end
	local effect = Effect.Play({ Kind = kind, Position = position }, Kit.look(nil, 1, character == Players.LocalPlayer.Character))
	if effect then
		table.insert(effects, { character = character, effect = effect })
		stats.effects += 1
		local parts = 0
		for _, entry in effects do
			parts += #entry.effect.sprites
		end
		stats.peakParts = math.max(stats.peakParts, parts)
	end
end

local function phaseEffect(state, active, phase)
	if state.active ~= active or active.emitted[phase] then return end
	active.emitted[phase] = true
	local character, humanoid = state.character, state.humanoid
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") or humanoid.Health <= 0 then return end
	if phase == "Strike" then
		local power = character:GetAttribute("ActivePower")
		local sword = power and Config.SwordM1[power]
		local hand = character:FindFirstChild(not sword and active.action == "M1_1" and "LeftHand" or "RightHand")
		draw(character, "Swing", hand and hand:IsA("BasePart") and hand.Position or root.Position + root.CFrame.LookVector * 2)
	else
		local mode = humanoid:GetState()
		if humanoid.FloorMaterial == Enum.Material.Air or mode == Enum.HumanoidStateType.Jumping
			or mode == Enum.HumanoidStateType.Freefall then return end
		draw(character, phase, root.Position - Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2 - 0.25, 0))
	end
end

local function play(state, active, elapsed)
	if not state.playLocally then return end
	-- A fighter holding a sword uses that sword's combo clips; everyone else uses the fist combo.
	local power = state.character:GetAttribute("ActivePower")
	local key = power and Config.SwordM1[power] and "Sword_" .. active.action or active.action
	local root = state.character:FindFirstChild("HumanoidRootPart")
	local velocity = root and root:IsA("BasePart") and root.AssemblyLinearVelocity or Vector3.zero
	local moving = Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 1.5
		or state.humanoid.FloorMaterial == Enum.Material.Air
	local movingTrack = state.tracks[key .. "Moving"]
	if moving and movingTrack and movingTrack.Length > 0 then
		key ..= "Moving"
	end
	local track = state.tracks[key]
	if not track or track.Length <= 0 then return end
	if active.attempted and active.track == track then return end
	if active.track then
		for _, connection in active.connections do
			connection:Disconnect()
		end
		table.clear(active.connections)
		active.track:Stop(Config.Fade)
	end
	active.attempted, active.track = true, track
	for _, marker in { "Strike", "DashBurst", "DashBrake" } do
		table.insert(active.connections, track:GetMarkerReachedSignal(marker):Connect(function()
			phaseEffect(state, active, marker)
		end))
	end
	track:Play(Config.Fade, 1, 1)
	track.TimePosition = math.clamp(elapsed, 0, math.max(0, track.Length - 0.001))
end

function Controller.Play(data)
	if not valid(data) then
		stats.rejected += 1
		return
	end
	local character, token, now = data.Character, data.Token, workspace:GetServerTimeNow()
	if data.Phase == "Cancel" then
		cancelled[token] = now + Config.MaxEventAge
		local state = states[character]
		if state and state.active and state.active.token == token then
			local interrupted = now - state.active.started < Config.Durations[state.active.action] - Config.Fade
			cancel(state)
			if interrupted then
				removeEffects(character)
			end
			stats.cancels += 1
		end
		return
	end
	if cancelled[token] or not character:IsDescendantOf(workspace) then return end
	if data.Phase == "Hit" then
		local position = data.Position
		if typeof(position) ~= "Vector3" then
			stats.rejected += 1
			return
		end
		local key = token .. tostring(position)
		if hits[key] then return end
		hits[key] = now + Config.MaxEventAge
		stats.hits += 1
		draw(character, "Hit", position)
		return
	end
	local state = getState(character)
	if not state or data.Time < state.lastStart or (state.active and state.active.token == token) then return end
	local elapsed = math.max(0, now - data.Time)
	if elapsed >= Config.Durations[data.Action] then return end
	cancel(state)
	state.lastStart = data.Time
	local active = { token = token, action = data.Action, started = data.Time, emitted = {}, connections = {} }
	state.active = active
	stats.starts += 1
	play(state, active, elapsed)
end

function Controller.debugStats()
	local result = table.clone(stats)
	result.characters, result.tracks, result.active, result.connections, result.parts = 0, 0, 0, #connections, 0
	for _, state in states do
		result.characters += 1
		result.connections += #state.connections
		for _ in state.tracks do
			result.tracks += 1
		end
		if state.active then
			result.active += 1
			result.connections += #state.active.connections
		end
	end
	for _, entry in effects do
		result.parts += #entry.effect.sprites
	end
	return result
end

function Controller.Stop()
	started = false
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
	for character in states do
		cleanup(character)
	end
	for _, entry in effects do
		entry.effect:Destroy()
	end
	table.clear(effects)
	table.clear(cancelled)
	table.clear(hits)
end

function Controller.Start()
	if started then return end
	started = true
	local function prepareCharacter(character)
		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid", 5)
			if humanoid then
				humanoid:WaitForChild("Animator", 5)
			end
			if started and Players.LocalPlayer.Character == character then
				getState(character)
			end
		end)
	end
	table.insert(connections, Players.LocalPlayer.CharacterAdded:Connect(prepareCharacter))
	if Players.LocalPlayer.Character then
		prepareCharacter(Players.LocalPlayer.Character)
	end
	table.insert(connections, Remotes.CombatAction.OnClientEvent:Connect(Controller.Play))
	table.insert(connections, RunService.RenderStepped:Connect(function()
		local now = workspace:GetServerTimeNow()
		for token, expiry in cancelled do
			if now > expiry then
				cancelled[token] = nil
			end
		end
		for token, expiry in hits do
			if now > expiry then
				hits[token] = nil
			end
		end
		for _, state in states do
			if state.humanoid.Health <= 0 or not state.character:IsDescendantOf(workspace)
				or state.humanoid:FindFirstChildOfClass("Animator") ~= state.animator then
				cleanup(state.character)
				continue
			end
			local active = state.active
			if not active then continue end
			local elapsed = math.max(0, now - active.started)
			if state.humanoid.Health <= 0 or not state.character:IsDescendantOf(workspace) then
				cleanup(state.character)
			elseif elapsed >= Config.Durations[active.action] then
				if state.playLocally and not active.attempted then
					stats.fallbacks += 1
				end
				cancel(state)
			else
				play(state, active, elapsed)
				if active.action == "Dash" then
					if elapsed >= Config.DashBurstTime then
						phaseEffect(state, active, "DashBurst")
					end
					if elapsed >= Config.DashBrakeTime then
						phaseEffect(state, active, "DashBrake")
					end
				elseif elapsed >= Config.StrikeTimes[active.action] then
					phaseEffect(state, active, "Strike")
				end
			end
		end
		for index = #effects, 1, -1 do
			if not effects[index].effect:Update(os.clock()) then
				table.remove(effects, index)
			end
		end
	end))
	table.insert(connections, script.Destroying:Connect(Controller.Stop))
	table.insert(connections, script.AncestryChanged:Connect(function()
		if not script:IsDescendantOf(game) then
			Controller.Stop()
		end
	end))
	task.spawn(function()
		local assets = {}
		local ids = table.clone(Config.Animations)
		for name, id in Config.MovingAnimations do
			ids[name .. "Moving"] = id
		end
		for _, id in ids do
			if asset(id) then
				local animation = Instance.new("Animation")
				animation.AnimationId = id
				table.insert(assets, animation)
			end
		end
		pcall(function()
			ContentProvider:PreloadAsync(assets)
		end)
		for _, animation in assets do
			animation:Destroy()
		end
	end)
end

return Controller
