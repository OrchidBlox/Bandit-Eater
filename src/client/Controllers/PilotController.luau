-- Intentionally plain prototype UI; replace presentation without changing remote contracts.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local C = require(ReplicatedStorage.Shared.PilotConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local MoveIcons = require(ReplicatedStorage.Shared.Config.MoveIcons)
local Controller = {}
local state, buttons = {}, {}

local function powerName(id)
	local visual = id and Visuals.Powers[id]
	return visual and visual.DisplayName or id or "Empty"
end

local function send(action, value)
	Remotes.PilotInput:FireServer(action, value)
end

local function text(parent, name, size, position)
	local label = Instance.new("TextLabel")
	label.Name, label.Size, label.Position = name, size, position
	label.BackgroundColor3, label.BackgroundTransparency = Color3.fromRGB(22, 29, 40), 0.15
	label.TextColor3, label.Font, label.TextSize = Color3.new(1, 1, 1), Enum.Font.GothamBold, 15
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function button(parent, title, position, size, action, value)
	local b = Instance.new("TextButton")
	b.Name, b.Text, b.Position, b.Size = title, title, position, size
	b.BackgroundColor3, b.TextColor3, b.Font = Color3.fromRGB(48, 87, 116), Color3.new(1, 1, 1), Enum.Font.GothamBold
	b.TextSize, b.TextWrapped = 14, true
	b.Parent = parent
	if action == "Inhale" then
		b.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				send("Inhale")
			end
		end)
		b.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				send("InhaleEnd")
			end
		end)
	else
		b.Activated:Connect(function()
			send(action, value)
		end)
	end
	return b
end

function Controller.Start()
	local gui = Instance.new("ScreenGui")
	gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "PilotHUD", false, 10
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	local top = text(gui, "Status", UDim2.fromScale(0.7, 0.07), UDim2.fromScale(0.15, 0))
	local loadout = text(gui, "Loadout", UDim2.fromScale(0.7, 0.08), UDim2.fromScale(0.15, 0.075))
	loadout.Text = ""
	local slotLabels, slotIcons = {}, {}
	for i, title in { "Active", "Bench" } do
		local slot = Instance.new("Frame")
		slot.Name, slot.BackgroundTransparency = title, 1
		slot.Size, slot.Position = UDim2.fromScale(0.5, 1), UDim2.fromScale((i - 1) * 0.5, 0)
		slot.Parent = loadout
		local icon = Instance.new("ImageLabel")
		icon.Name, icon.BackgroundTransparency, icon.ScaleType = "PowerIcon", 1, Enum.ScaleType.Fit
		icon.Size, icon.Position = UDim2.fromScale(0.15, 0.8), UDim2.fromScale(0.02, 0.1)
		icon.Parent = slot
		local label = text(slot, "PowerName", UDim2.fromScale(0.8, 1), UDim2.fromScale(0.18, 0))
		label.BackgroundTransparency, label.TextScaled = 1, true
		local bounds = Instance.new("UITextSizeConstraint")
		bounds.MinTextSize, bounds.MaxTextSize, bounds.Parent = 10, 15, label
		label.Text = title .. ": Empty"
		slotLabels[i], slotIcons[i] = label, icon
	end
	local prompt = text(gui, "Prompt", UDim2.fromScale(0.7, 0.07), UDim2.fromScale(0.15, 0.16))
	local queue = button(gui, "Join arena", UDim2.fromScale(0.38, 0.25), UDim2.fromScale(0.24, 0.08), "Queue")
	local board = text(gui, "Board", UDim2.fromScale(0.2, 0.31), UDim2.fromScale(0.01, 0.25))
	board.TextSize = 13
	local results = text(gui, "Results", UDim2.fromScale(0.5, 0.38), UDim2.fromScale(0.25, 0.25))
	results.Visible = false
	local shop = Instance.new("Frame")
	shop.Name, shop.Size, shop.Position, shop.BackgroundTransparency = "Cosmetics", UDim2.fromScale(0.2, 0.3), UDim2.fromScale(0.79, 0.25), 1
	shop.Parent = gui
	shop.Visible = false -- Cosmetics are hidden for the current lobby revision.
	local shopButtons = {}
	for i, id in { "Default", "Rose", "Mint" } do
		shopButtons[id] = button(shop, id, UDim2.fromScale(0, (i - 1) / 3), UDim2.fromScale(1, 0.3), "Shop", id)
	end
	local actions = Instance.new("Frame")
	actions.Name, actions.Size, actions.Position, actions.BackgroundTransparency = "Actions", UDim2.fromScale(0.58, 0.26), UDim2.fromScale(0.23, 0.73), 1
	actions.Parent = gui
	local defs = {
		{ "M1 [Click / RT]", "M1" }, { "Dash [Shift / B]", "Dash" },
		{ "Inhale [hold F / LT]", "Inhale" }, { "Swap [X / Y]", "Swap" },
		{ "Q / X", "Move", 1 }, { "E / RB", "Move", 2 }, { "R / D-up", "Move", 3 },
		{ "Swallow [G / D-down]", "Swallow" }, { "Spit [T / D-right]", "Spit" },
	}
	local moveIcons, moveLabels = {}, {}
	for i, d in defs do
		local col, row = (i - 1) % 5, math.floor((i - 1) / 5)
		buttons[i] = button(actions, d[1], UDim2.fromScale(col * 0.2, row * 0.5), UDim2.fromScale(0.19, 0.46), d[2], d[3])
		if d[2] == "Move" then
			buttons[i].Text = ""
			local icon = Instance.new("ImageLabel")
			icon.Name, icon.BackgroundTransparency, icon.ScaleType = "MoveIcon", 1, Enum.ScaleType.Fit
			icon.Size, icon.Position = UDim2.fromScale(0.28, 0.68), UDim2.fromScale(0.03, 0.16)
			icon.Image, icon.Active = "", false
			icon.Parent = buttons[i]
			local label = text(buttons[i], "MoveName", UDim2.fromScale(0.65, 0.9), UDim2.fromScale(0.33, 0.05))
			label.BackgroundTransparency, label.TextScaled, label.Active = 1, true, false
			label.Text = d[1]
			local bounds = Instance.new("UITextSizeConstraint")
			bounds.MinTextSize, bounds.MaxTextSize, bounds.Parent = 10, 14, label
			moveIcons[i], moveLabels[i] = icon, label
		end
	end
	local fuse = button(gui, "Fuse [V / D-left]", UDim2.fromScale(0.35, 0.64), UDim2.fromScale(0.3, 0.07), "Fuse")
	local compact = false
	local function refreshActions()
		local slots = state.Slots or {}
		local active = slots[state.Slot or 1]
		for i, d in defs do
			local key = d[2] == "Move" and active and active .. d[3] or d[2]
			local cd = (state.Cooldowns or {})[key] or 0
			local name = d[2] == "Move" and active and C.Powers[active].Moves[d[3]].Name or (compact and d[2] or d[1])
			buttons[i].Text = name .. (cd > 0 and string.format(" %.1fs", cd) or "")
			if moveLabels[i] then
				buttons[i].Text = ""
				moveLabels[i].Text = (compact and ({ "Q", "E", "R" })[d[3]] or d[1]) .. "\n" .. name .. (cd > 0 and string.format("\n%.1fs", cd) or "")
				local icons = active and MoveIcons[active]
				local image = icons and icons[d[3]] or ""
				moveIcons[i].Image = image
				moveIcons[i].Visible = image ~= ""
				moveIcons[i].ImageTransparency = cd > 0 and 0.35 or 0
				moveLabels[i].Position = UDim2.fromScale(image ~= "" and 0.33 or 0.03, 0.05)
				moveLabels[i].Size = UDim2.fromScale(image ~= "" and 0.65 or 0.94, 0.9)
			end
			if d[2] == "Inhale" and state.Inhaling then
				buttons[i].Text = compact and "Hold inhale" or "INHALING - keep holding"
			end
			buttons[i].BackgroundColor3 = cd > 0 and Color3.fromRGB(55, 57, 65) or Color3.fromRGB(48, 87, 116)
			buttons[i].Visible = (d[2] ~= "Swap" or slots[2] ~= nil) and ((d[2] ~= "Swallow" and d[2] ~= "Spit") or state.Held ~= nil)
		end
	end
	local function layout()
		local size = gui.AbsoluteSize
		if size.X <= 0 or size.Y <= 0 then
			return
		end
		compact = UIS.TouchEnabled or size.X < 700
		board.Visible = not (compact and state.Active)
		if compact then
			local width = math.min(size.X * 0.62, 360)
			local cellHeight = math.clamp(size.Y * 0.07, 48, 60)
			local height = cellHeight * 3 + 12
			local left = size.X - width - 12
			local y = math.max(110, size.Y - height - 136)
			actions.Position, actions.Size = UDim2.fromOffset(left, y), UDim2.fromOffset(width, height)
			for i, b in buttons do
				b.Position = UDim2.fromOffset(((i - 1) % 3) * (width + 6) / 3, math.floor((i - 1) / 3) * (cellHeight + 6))
				b.Size = UDim2.fromOffset((width - 12) / 3, cellHeight)
				b.TextSize = 12
			end
			top.Position, top.Size, top.TextSize = UDim2.fromOffset(12, 0), UDim2.new(1, -24, 0, 24), 12
			loadout.Position, loadout.Size = UDim2.fromOffset(12, 28), UDim2.new(1, -24, 0, 34)
			prompt.Position, prompt.Size, prompt.TextSize = UDim2.fromOffset(12, 66), UDim2.new(1, -24, 0, 38), 12
			fuse.Position, fuse.Size = UDim2.fromOffset(12, y), UDim2.fromOffset(math.min(120, left - 24), 44)
			fuse.Text = "Fuse"
		else
			actions.Position, actions.Size = UDim2.fromScale(0.23, 0.73), UDim2.fromScale(0.58, 0.26)
			for i, b in buttons do
				b.Position = UDim2.fromScale(((i - 1) % 5) * 0.2, math.floor((i - 1) / 5) * 0.5)
				b.Size, b.TextSize = UDim2.fromScale(0.19, 0.46), 14
			end
			top.Position, top.Size, top.TextSize = UDim2.fromScale(0.15, 0), UDim2.fromScale(0.7, 0.07), 15
			loadout.Position, loadout.Size = UDim2.fromScale(0.15, 0.075), UDim2.fromScale(0.7, 0.08)
			prompt.Position, prompt.Size, prompt.TextSize = UDim2.fromScale(0.15, 0.16), UDim2.fromScale(0.7, 0.07), 15
			fuse.Position, fuse.Size = UDim2.fromScale(0.35, 0.64), UDim2.fromScale(0.3, 0.07)
			fuse.Text = "Fuse [V / D-left]"
		end
		refreshActions()
	end
	-- ScreenGui size follows viewport and safe insets, including camera replacement.
	local resizeConnection = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	gui.Destroying:Once(function()
		resizeConnection:Disconnect()
	end)
	layout()
	local mappings = {
		{ Action = "M1", Inputs = { Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2 } },
		{ Action = "Dash", Inputs = { Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonB } },
		{ Action = "Inhale", Inputs = { Enum.KeyCode.F, Enum.KeyCode.ButtonL2 } },
		{ Action = "Swap", Inputs = { Enum.KeyCode.X, Enum.KeyCode.ButtonY } },
		{ Action = "Move", Value = 1, Inputs = { Enum.KeyCode.Q, Enum.KeyCode.ButtonX } },
		{ Action = "Move", Value = 2, Inputs = { Enum.KeyCode.E, Enum.KeyCode.ButtonR1 } },
		{ Action = "Move", Value = 3, Inputs = { Enum.KeyCode.R, Enum.KeyCode.DPadUp } },
		{ Action = "Swallow", Inputs = { Enum.KeyCode.G, Enum.KeyCode.DPadDown } },
		{ Action = "Spit", Inputs = { Enum.KeyCode.T, Enum.KeyCode.DPadRight } },
		{ Action = "Fuse", Inputs = { Enum.KeyCode.V, Enum.KeyCode.DPadLeft } },
	}
	for i, mapping in mappings do
		CAS:BindAction("Pilot" .. i, function(_, inputState)
			-- Release must reach the server even if chat gained focus mid-inhale.
			if mapping.Action == "Inhale" and (inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel) then
				send("InhaleEnd")
			end
			if UIS:GetFocusedTextBox() or not state.Active or state.Phase ~= "Match" then
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
		local inMatch = state.Active and state.Phase == "Match"
		local slots = state.Slots
		local active = slots[state.Slot]
		board.Visible = not (compact and state.Active)
		top.Text = string.format(compact and "%s %ds | HP %d | %d coins" or "BANDIT EATER | %s %ds | HP %d | %d coins", state.Phase, state.Seconds, state.HP, state.Coins)
		local bench = slots[3 - state.Slot]
		slotLabels[1].Text = "Active: " .. powerName(active) .. (state.Title and not compact and " | Arena Winner" or "")
		slotLabels[2].Text = "Bench: " .. powerName(bench)
		for i, id in { active or "", bench or "" } do
			local visual = Visuals.Powers[id]
			slotIcons[i].Image, slotIcons[i].Visible = visual and visual.Icon or "", visual ~= nil
		end
		local heldPrompt = state.Held and ("Holding " .. powerName(state.Held) .. " Power Star: G to equip; T to spit."
			.. (bench and " Swallow replaces bench: " .. powerName(bench) .. "." or " Current active moves to bench."))
		prompt.Text = inMatch and (heldPrompt
			or state.Inhaling and (state.InhaleTarget and "Pulling " .. powerName(state.InhaleTarget) .. " Power Star - keep holding F!"
				or "INHALING - face a nearby bouncing Power Star.")
			or state.InhaleMessage or "F: briefly catch a front shot; hold to pull Power Stars. G equips; T spits.")
		or (state.Queued and "Joining the next round when it opens."
			or "Walk onto the glowing ARENA pad to join the live server match.")
		if os.clock() < revealUntil then
			prompt.Text = "Mystery: " .. C.BaseIds[math.random(1, #C.BaseIds)] .. " ..."
		elseif revealUntil > 0 and os.clock() < revealUntil + 1 then
			prompt.Text = "Mystery revealed: " .. revealResult
		end
		queue.Visible = not state.Active
		queue.Text = not state.Ready and "Loading save..." or state.Queued and "Queued - click to cancel"
			or state.Phase == "Match" and "Join live arena" or "Join next round"
		shop.Visible, actions.Visible = false, inMatch
		fuse.Visible = inMatch and C.Fusion(slots[1], slots[2]) ~= nil
		refreshActions()
		for id, b in shopButtons do
			b.Text = id .. (state.Skin == id and " (equipped)" or state.Cosmetics[id] and " - equip" or " - " .. C.Skins[id].Price .. " coins")
		end
		local lines = { state.Active and "MATCH KOs" or "SERVER LEADERBOARD" }
		for i, row in (state.Active and state.Rows or state.Board) do
			if i > 5 then
				break
			end
			table.insert(lines, row.Name .. ": " .. (state.Active and row.Score or row.Wins) .. (state.Active and "" or " wins"))
		end
		board.Text = table.concat(lines, "\n")
		results.Visible = state.Phase == "Results" and state.Active
		results.Text = "MATCH RESULTS\n" .. table.concat(lines, "\n") .. "\nEarned " .. state.Payout .. " coins\nParticipation required: 20 damage or 2 inhales."
	end)
end
return Controller
