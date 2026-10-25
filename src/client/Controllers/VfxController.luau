local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Kit = require(script.Parent.Parent.Vfx.Kit)
local Inhale = require(script.Parent.Parent.Vfx.Effects.Inhale)
local Controller = {}
local active, stopped = {}, {}
local connections = {}
local running = false
local counters = { started = 0, cleaned = 0, culled = 0, rejected = 0, failed = 0, peakParts = 0 }

local function valid(data)
	return type(data) == "table" and data.Effect == "Inhale"
		and (data.Phase == "Start" or data.Phase == "Stop")
		and typeof(data.Caster) == "Instance" and data.Caster:IsA("Model")
		and type(data.Token) == "string" and #data.Token > 0 and #data.Token <= 80
		and type(data.Captured) == "boolean"
end

local function distance(caster)
	local root = caster:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not root or not root:IsA("BasePart") or not camera then
		return math.huge
	end
	return (root.Position - camera.CFrame.Position).Magnitude
end

local function remove(caster)
	local effect = active[caster]
	if effect then
		effect:Destroy()
		active[caster] = nil
		counters.cleaned += 1
	end
end

function Controller.Play(name, data, isOwn)
	if name ~= "Inhale" or not valid(data) then
		counters.rejected += 1
		return
	end
	local caster, token = data.Caster, data.Token
	if data.Phase == "Stop" then
		stopped[token] = os.clock() + Config.Inhale.Lifetime
		local effect = active[caster]
		if effect and effect.token == token then
			effect:Stop(data.Captured)
			if effect.destroyed then
				remove(caster)
			end
		end
		return
	end
	if stopped[token] or not caster:IsDescendantOf(workspace) then
		return
	end
	local previous = active[caster]
	if previous and previous.token == token then
		return
	end
	if distance(caster) > Config.Inhale.CullDistance then
		counters.culled += 1
		return
	end
	local count = 0
	for _ in active do
		count += 1
	end
	if not previous and count >= Config.Inhale.MaxConcurrent then
		counters.culled += 1
		return
	end
	remove(caster)
	local ok, effect = pcall(Inhale.Play, data, Kit.look(Config.Inhale, 1, isOwn))
	if ok and effect then
		active[caster] = effect
		counters.started += 1
		counters.peakParts = math.max(counters.peakParts, Controller.debugStats().parts)
	elseif not ok then
		counters.failed += 1
	end
end

function Controller.debugStats()
	local stats = table.clone(counters)
	stats.active, stats.parts, stats.beams, stats.emitters, stats.connections = 0, 0, 0, 0, #connections
	for _ in active do
		stats.active += 1
	end
	local folder = workspace:FindFirstChild("PilotVfx")
	if folder then
		for _, item in folder:GetDescendants() do
			if item:IsA("BasePart") then
				stats.parts += 1
			elseif item:IsA("Beam") then
				stats.beams += 1
			elseif item:IsA("ParticleEmitter") then
				stats.emitters += 1
			end
		end
	end
	return stats
end

function Controller.Stop()
	running = false
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
	for caster in active do
		remove(caster)
	end
	table.clear(stopped)
end

function Controller.Start()
	if running then
		return
	end
	running = true
	task.spawn(function()
		local assets = {}
		local imageLabels = {}
		for _, image in Config.Textures do
			if string.match(image, "^rbxassetid://%d+$") then
				local label = Instance.new("ImageLabel")
				label.Image = image
				table.insert(imageLabels, label)
				table.insert(assets, label)
			end
		end
		local root = ReplicatedStorage:FindFirstChild("Assets")
		local vfx = root and root:FindFirstChild("Vfx")
		local inhale = vfx and vfx:FindFirstChild("Inhale")
		if inhale then
			table.insert(assets, inhale)
		end
		pcall(function()
			ContentProvider:PreloadAsync(assets)
		end)
		for _, label in imageLabels do
			label:Destroy()
		end
	end)
	table.insert(connections, Remotes.PilotVfx.OnClientEvent:Connect(function(data)
		local isOwn = type(data) == "table" and data.Caster == Players.LocalPlayer.Character
		Controller.Play("Inhale", data, isOwn)
	end))
	table.insert(connections, RunService.RenderStepped:Connect(function()
		local now = os.clock()
		for token, expiry in stopped do
			if now >= expiry then
				stopped[token] = nil
			end
		end
		for caster, effect in active do
			if distance(caster) > Config.Inhale.CullDistance then
				remove(caster)
				counters.culled += 1
			else
				local ok, alive = pcall(effect.Update, effect, now)
				if not ok then
					counters.failed += 1
				end
				if not ok or not alive then
					remove(caster)
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
end

return Controller
