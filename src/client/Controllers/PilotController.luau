local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")

local C = require(ReplicatedStorage.Shared.PilotConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local PilotHud = require(script.Parent.Parent.Hud.PilotHud)

local Controller = {}
local state = {}

local function send(action, value)
	Remotes.PilotInput:FireServer(action, value)
end

local function powerName(id)
	local power = id and C.Powers[id]
	return power and power.Name or id or "Empty"
end

local function promptFor(snapshot, revealUntil, revealResult)
	local slots = snapshot.Slots or {}
	local bench = slots[3 - (snapshot.Slot or 1)]
	local heldPrompt = snapshot.Held and ("Holding " .. powerName(snapshot.Held) .. " Power Star: G to equip; T to spit."
		.. (bench and " Swallow replaces bench: " .. powerName(bench) .. "." or " Current active moves to bench."))
	local prompt = snapshot.Active and (heldPrompt
		or snapshot.Inhaling and (snapshot.InhaleTarget and "Pulling " .. powerName(snapshot.InhaleTarget) .. " Power Star - keep holding F!"
			or "INHALING - face a nearby bouncing Power Star.")
		or snapshot.InhaleMessage or "F: briefly catch a front shot; hold to pull Power Stars. G equips; T spits.")
		or "Step on the glowing FFA pad to jump into the fight."
	if os.clock() < revealUntil then
		prompt = "Mystery: " .. C.BaseIds[math.random(1, #C.BaseIds)] .. " ..."
	elseif revealUntil > 0 and os.clock() < revealUntil + 1 then
		prompt = "Mystery revealed: " .. revealResult
	end
	return prompt
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name = "PilotHUD"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 10
	gui.IgnoreGuiInset = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	local hud = PilotHud.new(gui)
	hud:SetActions({
		M1 = function()
			if state.Active then
				send("M1")
			end
		end,
		Dash = function()
			if state.Active then
				send("Dash")
			end
		end,
		Inhale = function()
			if state.Active then
				send("Inhale")
			end
		end,
		InhaleEnd = function()
			send("InhaleEnd")
		end,
		Swap = function()
			if state.Active then
				send("Swap")
			end
		end,
		Move = function(index)
			if state.Active then
				send("Move", index)
			end
		end,
		Swallow = function()
			if state.Active then
				send("Swallow")
			end
		end,
		Spit = function()
			if state.Active then
				send("Spit")
			end
		end,
		Fuse = function()
			if state.Active then
				send("Fuse")
			end
		end,
	})

	local mappings = {
		{ Action = "M1", Inputs = { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 } },
		{ Action = "Dash", Inputs = { Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonB } },
		{ Action = "Inhale", Inputs = { Enum.KeyCode.F, Enum.KeyCode.ButtonL2 } },
		{ Action = "Swap", Inputs = { Enum.KeyCode.X, Enum.KeyCode.ButtonY } },
		{ Action = "Move", Value = 1, Inputs = { Enum.KeyCode.One, Enum.KeyCode.ButtonX } },
		{ Action = "Move", Value = 2, Inputs = { Enum.KeyCode.Two, Enum.KeyCode.ButtonR1 } },
		{ Action = "Move", Value = 3, Inputs = { Enum.KeyCode.Three, Enum.KeyCode.DPadUp } },
		{ Action = "Swallow", Inputs = { Enum.KeyCode.G, Enum.KeyCode.DPadDown } },
		{ Action = "Spit", Inputs = { Enum.KeyCode.T, Enum.KeyCode.DPadRight } },
		{ Action = "Fuse", Inputs = { Enum.KeyCode.V, Enum.KeyCode.DPadLeft } },
	}
	for i, mapping in mappings do
		CAS:BindAction("Pilot" .. i, function(_, inputState)
			if mapping.Action == "Inhale" and (inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel) then
				send("InhaleEnd")
			end
			if UIS:GetFocusedTextBox() or not state.Active then
				return Enum.ContextActionResult.Pass
			end
			if inputState == Enum.UserInputState.Begin then
				send(mapping.Action, mapping.Value)
			end
			return Enum.ContextActionResult.Sink
		end, false, table.unpack(mapping.Inputs))
	end

	local revealUntil, revealResult = 0, ""
	Remotes.PilotReveal.OnClientEvent:Connect(function(power)
		revealUntil, revealResult = os.clock() + 1.2, power
	end)
	Remotes.PilotState.OnClientEvent:Connect(function(snapshot)
		state = snapshot
		state.Prompt = promptFor(state, revealUntil, revealResult)
		hud:Update(state)
	end)
end

return Controller
