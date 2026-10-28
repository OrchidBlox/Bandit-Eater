local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Kit = require(script.Parent.Parent.Vfx.Kit)
local Swallow = require(script.Parent.Parent.Vfx.Effects.PowerSwallow)
local C = Visuals.Swallow
local Controller = {}
local connections, states, seen = {}, {}, {}
local running = false
local stats = { started = 0, cleaned = 0, interrupted = 0, culled = 0, rejected = 0, failedLoads = 0 }
local MAX_EFFECTS = 6

local function finite(value)
	return type(value) == "number" and value == value and math.abs(value) < 1e10
end

local function stop(state, interrupted)
	if not state.active then return end
	if state.active.track then
		state.active.track:Stop(C.FadeOut)
	end
	if state.active.effect then
		state.active.effect:Destroy()
	end
	state.active = nil
	stats.cleaned += 1
	if interrupted then
		stats.interrupted += 1
	end
end

local function cleanup(caster)
	local state = states[caster]
	if not state then return end
	states[caster] = nil
	stop(state, true)
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
end

local function getState(caster)
	local humanoid = caster:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not humanoid or humanoid.Health <= 0 or not caster:IsDescendantOf(workspace) then return end
	local state = states[caster]
	if state and (state.humanoid ~= humanoid or state.animator ~= animator) then
		cleanup(caster)
		state = nil
	end
	if state then return state end
	state = { caster = caster, humanoid = humanoid, animator = animator, tracks = {}, animations = {},
		connections = {}, lastStart = -math.huge }
	states[caster] = state
	if caster == Players.LocalPlayer.Character and animator then
		for name, id in { Standing = C.AnimationId, Moving = C.MovingAnimationId } do
			if type(id) == "string" and string.match(id, "^rbxassetid://%d+$") then
				local animation = Instance.new("Animation")
				animation.Name, animation.AnimationId = "PowerSwallow" .. name, id
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
		cleanup(caster)
	end))
	table.insert(state.connections, caster.AncestryChanged:Connect(function()
		if not caster:IsDescendantOf(workspace) then
			cleanup(caster)
		end
	end))
	return state
end

local function playTrack(state, elapsed)
	local active = state.active
	if not active or state.caster ~= Players.LocalPlayer.Character then return end
	local root = state.caster:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then return end
	local velocity = root.AssemblyLinearVelocity
	local moving = Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 1.5
		or state.humanoid.FloorMaterial == Enum.Material.Air
	local track = moving and state.tracks.Moving or state.tracks.Standing
	if not track or track.Length <= 0 or active.track == track then return end
	if active.track then
		active.track:Stop(C.FadeOut)
	end
	active.track = track
	track:Play(C.FadeIn, 1, 1)
	track.TimePosition = math.clamp(elapsed, 0, math.max(0, track.Length - 0.001))
end

function Controller.Play(data)
	if type(data) ~= "table" or data.Effect ~= "PowerSwallow" or data.Phase ~= "Start"
		or typeof(data.Caster) ~= "Instance" or not data.Caster:IsA("Model")
		or type(data.Power) ~= "string" or not Visuals.Powers[data.Power]
		or (data.PreviousPower ~= nil and (type(data.PreviousPower) ~= "string" or not Visuals.Powers[data.PreviousPower]))
		or type(data.Token) ~= "string" or #data.Token == 0 or #data.Token > 80 or not finite(data.StartedAt) then
		stats.rejected += 1
		return
	end
	local now = workspace:GetServerTimeNow()
	local age = now - data.StartedAt
	if age < -0.25 or age >= C.Duration or seen[data.Token] then return end
	local state = getState(data.Caster)
	if not state or data.StartedAt < state.lastStart then return end
	seen[data.Token] = now + C.Duration + 1
	stop(state, true)
	state.lastStart = data.StartedAt
	local count = 0
	for _, other in states do
		if other.active and other.active.effect then
			count += 1
		end
	end
	local effect
	if count < MAX_EFFECTS then
		effect = Swallow.Play({ Caster = data.Caster, Power = data.Power, PreviousPower = data.PreviousPower,
			Token = data.Token, Elapsed = math.max(0, age) }, Kit.look(nil, 1, data.Caster == Players.LocalPlayer.Character))
	end
	if not effect then
		stats.culled += 1
	end
	state.active = { token = data.Token, started = data.StartedAt, effect = effect }
	stats.started += 1
	playTrack(state, math.max(0, age))
end

local function interrupt(caster, timestamp)
	local state = caster and states[caster]
	if state and state.active and (not finite(timestamp) or timestamp >= state.active.started) then
		stop(state, true)
	end
end

function Controller.debugStats()
	local result = table.clone(stats)
	result.active, result.effects, result.tracks, result.parts, result.connections = 0, 0, 0, 0, #connections
	for _, state in states do
		result.connections += #state.connections
		for _ in state.tracks do
			result.tracks += 1
		end
		if state.active then
			result.active += 1
			if state.active.effect then
				result.effects += 1
				for _, item in state.active.effect.group:GetDescendants() do
					if item:IsA("BasePart") then
						result.parts += 1
					end
				end
			end
		end
	end
	return result
end

function Controller.Stop()
	running = false
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
	for caster in states do
		cleanup(caster)
	end
	table.clear(seen)
end

function Controller.Start()
	if running then return end
	running = true
	table.insert(connections, Remotes.PilotVfx.OnClientEvent:Connect(function(data)
		if type(data) ~= "table" then return end
		if data.Effect == "PowerSwallow" then
			Controller.Play(data)
		elseif data.Phase == "Start" then
			interrupt(data.Caster, data.StartedAt)
		end
	end))
	table.insert(connections, Remotes.CombatAction.OnClientEvent:Connect(function(data)
		if type(data) == "table" and data.Phase == "Start" then
			interrupt(data.Character, data.Time)
		end
	end))
	table.insert(connections, RunService.RenderStepped:Connect(function(dt)
		local now = workspace:GetServerTimeNow()
		for token, expiry in seen do
			if now > expiry then
				seen[token] = nil
			end
		end
		for caster, state in states do
			if not caster:IsDescendantOf(workspace) or state.humanoid.Health <= 0
				or state.humanoid:FindFirstChildOfClass("Animator") ~= state.animator then
				cleanup(caster)
			elseif state.active then
				local age = now - state.active.started
				if age >= C.Duration then
					stop(state, false)
				else
					playTrack(state, math.max(0, age))
					if state.active.effect and not state.active.effect:Update(dt) then
						state.active.effect = nil
					end
				end
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
		for _, id in { C.AnimationId, C.MovingAnimationId } do
			if type(id) == "string" and string.match(id, "^rbxassetid://%d+$") then
				local animation = Instance.new("Animation")
				animation.AnimationId = id
				table.insert(assets, animation)
			end
		end
		for _, visual in Visuals.Powers do
			if visual.Icon ~= "" then
				local image = Instance.new("ImageLabel")
				image.Image = visual.Icon
				table.insert(assets, image)
			end
		end
		pcall(function()
			ContentProvider:PreloadAsync(assets)
		end)
		for _, asset in assets do
			asset:Destroy()
		end
	end)
end

return Controller
