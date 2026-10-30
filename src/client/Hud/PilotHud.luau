local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local C = require(ReplicatedStorage.Shared.PilotConfig)
local HudAssets = require(ReplicatedStorage.Shared.Config.HudAssets)
local MoveIcons = require(ReplicatedStorage.Shared.Config.MoveIcons)
local PowerVisuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)

local PilotHud = {}
PilotHud.__index = PilotHud

local NAVY = Color3.fromRGB(20, 33, 61)
local WHITE = Color3.new(1, 1, 1)
local GOLD = Color3.fromRGB(255, 216, 77)
local EMPTY_ACTIONS = {}

local function addCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

-- Clock-style cooldown shade. Two half-frames (right then left) each hold a double-width dark frame whose UIGradient
-- has a hard edge through the centre; turning the gradient sweeps the shaded wedge clockwise from the top.
-- Returns set(fraction): 0 shows nothing, 1 covers the whole button.
local function radialWipe(parent)
	local gradients = {}
	for index, half in { "Right", "Left" } do
		local holder = Instance.new("Frame")
		holder.Name, holder.BackgroundTransparency, holder.ClipsDescendants = half .. "Half", 1, true
		holder.Size, holder.Position = UDim2.fromScale(0.5, 1), UDim2.fromScale(index == 1 and 0.5 or 0, 0)
		holder.ZIndex, holder.Parent = 4, parent
		local shade = Instance.new("Frame")
		shade.Name, shade.BackgroundColor3, shade.BorderSizePixel = "Shade", Color3.fromRGB(8, 16, 31), 0
		shade.Size, shade.Position, shade.ZIndex, shade.Parent = UDim2.fromScale(2, 1), UDim2.fromScale(index == 1 and -1 or 0, 0), 4, holder
		local gradient = Instance.new("UIGradient")
		gradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.22), NumberSequenceKeypoint.new(0.5, 0.22),
			NumberSequenceKeypoint.new(0.501, 1), NumberSequenceKeypoint.new(1, 1) })
		gradient.Parent = shade
		gradients[index] = gradient
	end
	return function(fraction)
		local s = math.clamp(fraction, 0, 1)
		gradients[1].Rotation = math.min(s, 0.5) * 360
		gradients[2].Rotation = 180 + math.max(s - 0.5, 0) * 360
	end
end

local function imageObject(className, parent, name, asset, sliced)
	local object = Instance.new(className)
	object.Name = name
	object.BackgroundTransparency = asset and asset.Image and 1 or 0
	object.BackgroundColor3 = NAVY
	object.BorderSizePixel = 0
	object.Image = asset and asset.Image or ""
	object.ScaleType = sliced and Enum.ScaleType.Slice or Enum.ScaleType.Fit
	if sliced and asset and asset.Size then
		local inset = math.floor(math.min(asset.Size.X, asset.Size.Y) * 0.32)
		object.SliceCenter = Rect.new(inset, inset, asset.Size.X - inset, asset.Size.Y - inset)
		-- Slice corners draw at source-pixel size; scale them with the displayed height so a frame shown smaller (or
		-- larger) than its art is resized evenly instead of having its middle (and any socket in it) stretched.
		local function fitSlices()
			if object.AbsoluteSize.Y > 0 then
				object.SliceScale = object.AbsoluteSize.Y / asset.Size.Y
			end
		end
		object:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitSlices)
		fitSlices()
	end
	if not sliced and asset and asset.Size and asset.Size.Y > 0 then
		-- Lock to the art's own proportions so no layout (wide, tall or phone) can stretch an icon or frame.
		local lock = Instance.new("UIAspectRatioConstraint")
		lock.AspectRatio = asset.Size.X / asset.Size.Y
		lock.AspectType = Enum.AspectType.FitWithinMaxSize
		lock.DominantAxis = Enum.DominantAxis.Width
		lock.Parent = object
	end
	if object.BackgroundTransparency == 0 then
		addCorner(object, 14)
	end
	object.Parent = parent
	return object
end

local function frameImage(parent, name, assetName, sliced)
	return imageObject("ImageLabel", parent, name, HudAssets.Frames[assetName], sliced)
end

local function iconImage(parent, name, assetName)
	return imageObject("ImageLabel", parent, name, HudAssets.Icons[assetName], false)
end

local function actionButton(parent, name, assetName)
	local button = imageObject("ImageButton", parent, name, HudAssets.Frames[assetName], false)
	button.AutoButtonColor = false
	button.Selectable = false
	return button
end

local function addText(parent, name, text, zIndex, minSize, maxSize)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Text = text or ""
	label.TextColor3 = WHITE
	label.Font = Enum.Font.FredokaOne
	label.TextScaled = true
	label.TextWrapped = true
	label.ZIndex = zIndex or 2
	label.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Color = NAVY
	stroke.Thickness = 2.5
	stroke.Parent = label
	local constraint = Instance.new("UITextSizeConstraint")
	constraint.MinTextSize = minSize or 10
	constraint.MaxTextSize = maxSize or 28
	constraint.Parent = label
	return label
end

local function setImage(label, image)
	label.Image = image or ""
	label.Visible = image ~= nil and image ~= ""
end

local function connectAction(button, callback)
	button.Activated:Connect(function()
		if callback then
			callback()
		end
	end)
end

local function powerName(id)
	local visual = id and PowerVisuals.Powers[id]
	return visual and visual.DisplayName or id or "Empty"
end

function PilotHud.new(gui)
	local self = setmetatable({}, PilotHud)
	self.Gui, self.Actions, self.State = gui, EMPTY_ACTIONS, {}
	self.Compact, self.Gamepad = false, false

	local root = Instance.new("Frame")
	root.Name, root.Size, root.BackgroundTransparency = "HudContainer", UDim2.fromScale(1, 1), 1
	root.Parent = gui
	self.Root = root
	local scale = Instance.new("UIScale")
	scale.Name, scale.Parent = "ResponsiveScale", root
	self.Scale = scale

	local health = frameImage(root, "Health", "health_track", true)
	health.ZIndex = 1
	self.Health = health
	local fillClip = Instance.new("Frame")
	fillClip.Name, fillClip.BackgroundTransparency, fillClip.ClipsDescendants = "FillClip", 1, true
	fillClip.Position, fillClip.Size, fillClip.ZIndex = UDim2.fromOffset(56, 18), UDim2.fromOffset(402, 58), 2
	fillClip.Parent = health
	self.HealthFillClip = fillClip
	local healthFill = frameImage(fillClip, "Fill", "health_fill", true)
	healthFill.Position, healthFill.Size, healthFill.ZIndex = UDim2.fromOffset(-1, 0), UDim2.fromOffset(404, 58), 2
	local heart = iconImage(health, "Heart", "heart")
	heart.Position, heart.Size, heart.ZIndex = UDim2.fromOffset(-20, -13), UDim2.fromOffset(118, 104), 4
	local hpText = addText(health, "Value", "100", 5, 18, 40)
	hpText.Position, hpText.Size = UDim2.fromOffset(102, 18), UDim2.fromOffset(320, 55)
	self.HpText = hpText

	local currency = frameImage(root, "Currency", "currency_pill", false) -- the coin socket must never stretch
	currency.ZIndex = 1
	self.Currency = currency
	local coin = iconImage(currency, "Coin", "coin")
	coin.Position, coin.Size, coin.ZIndex = UDim2.fromOffset(-8, -6), UDim2.fromOffset(92, 92), 3
	local coinsText = addText(currency, "Value", "0", 3, 16, 34)
	coinsText.Position, coinsText.Size, coinsText.TextXAlignment = UDim2.fromOffset(78, 13), UDim2.new(1, -94, 0, 60), Enum.TextXAlignment.Left
	self.CoinsText = coinsText

	local board = frameImage(root, "Leaderboard", "leaderboard_card", false)
	board.ZIndex = 1
	self.Board = board
	local crown = iconImage(board, "Crown", "crown")
	crown.Position, crown.Size, crown.ZIndex = UDim2.fromOffset(25, 13), UDim2.fromOffset(50, 42), 3
	local boardTitle = addText(board, "Title", "FFA KOs", 3, 14, 27)
	boardTitle.Position, boardTitle.Size = UDim2.fromOffset(76, 12), UDim2.new(1, -96, 0, 46)
	self.BoardTitle = boardTitle
	self.BoardRows = {}
	for i = 1, 5 do
		local row = addText(board, "Row" .. i, "", 3, 10, 20)
		row.Position, row.Size, row.TextXAlignment = UDim2.fromOffset(35, 58 + (i - 1) * 40), UDim2.new(1, -70, 0, 35), Enum.TextXAlignment.Left
		self.BoardRows[i] = row
	end

	local prompt = frameImage(root, "Prompt", "prompt_banner", true)
	-- Stretch only the plain middle: start the slice after the key socket so the socket keeps its shape.
	prompt.SliceCenter = Rect.new(150, 40, 457, 86)
	prompt.ZIndex = 2
	self.Prompt = prompt
	local promptKey = frameImage(prompt, "KeyChip", "key_chip", false)
	promptKey.Position, promptKey.Size, promptKey.ZIndex = UDim2.fromOffset(10, 12), UDim2.fromOffset(64, 62), 3
	local promptKeyText = addText(promptKey, "Key", "F", 4, 14, 30)
	promptKeyText.Size = UDim2.fromScale(1, 1)
	local promptText = addText(prompt, "Message", "", 3, 11, 23)
	promptText.Position, promptText.Size, promptText.TextXAlignment = UDim2.fromOffset(82, 12), UDim2.new(1, -98, 1, -24), Enum.TextXAlignment.Left
	self.PromptText = promptText

	self.Slots = {}
	for i, assetName in { "slot_active", "slot_bench" } do
		local slot = frameImage(root, i == 1 and "ActiveSlot" or "BenchSlot", assetName, false)
		slot.ZIndex = 2
		local icon = Instance.new("ImageLabel")
		icon.Name, icon.BackgroundTransparency, icon.ScaleType = "PowerIcon", 1, Enum.ScaleType.Fit
		icon.Position, icon.Size, icon.ZIndex = UDim2.fromScale(0.18, 0.12), UDim2.fromScale(0.64, 0.61), 3
		icon.Parent = slot
		local label = addText(slot, "PowerName", "Empty", 4, 10, i == 1 and 25 or 20)
		label.Position, label.Size = UDim2.fromScale(0.1, 0.72), UDim2.fromScale(0.8, 0.2)
		self.Slots[i] = { Frame = slot, Icon = icon, Label = label }
	end
	self.Slots[2].Frame.ImageTransparency, self.Slots[2].Icon.ImageTransparency = 0.16, 0.22

	local swap = actionButton(root, "Swap", "key_chip")
	swap.ZIndex = 4
	local swapText = addText(swap, "Key", "X", 5, 14, 30)
	swapText.Size = UDim2.fromScale(1, 1)
	self.Swap = swap
	connectAction(swap, function()
		local callback = self.Actions.Swap
		if callback then
			callback()
		end
	end)

	-- Plain-language slots: tags over the tiles, a fusion socket between them, a swallow preview and a recipe guide.
	self.Tags = {}
	for i, text in { "IN HAND", "BACKUP" } do
		local tag = addText(root, i == 1 and "HandTag" or "BackupTag", text, 3, 10, 22)
		tag.TextColor3 = i == 1 and GOLD or Color3.fromRGB(184, 198, 234)
		self.Tags[i] = tag
	end
	local plus = addText(root, "FusionPlus", "+", 3, 20, 54)
	plus.TextTransparency = 0.35
	local hint = addText(root, "FusionHint", "", 3, 9, 17)
	hint.TextColor3 = Color3.fromRGB(184, 198, 234)
	local fuse = actionButton(root, "FuseBridge", "move_button")
	fuse.ImageColor3, fuse.ZIndex = GOLD, 5
	local fuseKey = addText(fuse, "Key", "V", 6, 11, 24)
	fuseKey.Position, fuseKey.Size = UDim2.fromScale(0.03, 0.02), UDim2.fromScale(0.28, 0.22)
	local fuseTitle = addText(fuse, "Title", "FUSE", 6, 12, 34)
	fuseTitle.Position, fuseTitle.Size = UDim2.fromScale(0.14, 0.2), UDim2.fromScale(0.72, 0.28)
	local fuseRecipe = addText(fuse, "Recipe", "", 6, 7, 15)
	fuseRecipe.Position, fuseRecipe.Size = UDim2.fromScale(0.08, 0.5), UDim2.fromScale(0.84, 0.18)
	local fuseResult = addText(fuse, "Result", "", 6, 8, 20)
	fuseResult.TextColor3 = Color3.fromRGB(255, 244, 168)
	fuseResult.Position, fuseResult.Size = UDim2.fromScale(0.08, 0.68), UDim2.fromScale(0.84, 0.22)
	self.Bridge = { Plus = plus, Hint = hint, Fuse = fuse, Recipe = fuseRecipe, Result = fuseResult }
	connectAction(fuse, function()
		local callback = self.Actions.Fuse
		if callback then
			callback()
		end
	end)

	-- Swallow preview: where each power goes before the player swallows.
	local preview = Instance.new("Frame")
	preview.Name, preview.BackgroundColor3, preview.BackgroundTransparency, preview.BorderSizePixel = "SwallowPreview", Color3.fromRGB(14, 26, 54), 0.08, 0
	preview.ZIndex, preview.Visible, preview.Parent = 3, false, root
	addCorner(preview, 16)
	local previewStroke = Instance.new("UIStroke")
	previewStroke.Color, previewStroke.Thickness, previewStroke.Parent = GOLD, 3, preview
	self.Preview = { Frame = preview, Cells = {} }
	for i = 1, 3 do
		local icon = Instance.new("ImageLabel")
		icon.Name, icon.BackgroundTransparency, icon.ScaleType, icon.ZIndex = "Icon" .. i, 1, Enum.ScaleType.Fit, 4
		icon.Position, icon.Size, icon.Parent = UDim2.fromOffset(14 + (i - 1) * 176, 8), UDim2.fromOffset(52, 52), preview
		local cross = addText(icon, "Cross", "X", 6, 20, 52)
		cross.TextColor3, cross.Size, cross.Visible = Color3.fromRGB(255, 90, 95), UDim2.fromScale(1, 1), false
		local label = addText(preview, "Label" .. i, "", 4, 9, 18)
		label.Position, label.Size = UDim2.fromOffset(70 + (i - 1) * 176, 8), UDim2.fromOffset(100, 52)
		label.TextXAlignment = Enum.TextXAlignment.Left
		self.Preview.Cells[i] = { Icon = icon, Cross = cross, Label = label }
	end

	-- Fusion Guide window: every recipe in one place.
	local guide = Instance.new("Frame")
	guide.Name, guide.BackgroundColor3, guide.BorderSizePixel, guide.ZIndex, guide.Visible = "FusionGuide", Color3.fromRGB(14, 26, 54), 0, 20, false
	guide.Size, guide.Parent = UDim2.fromOffset(600, 500), root
	addCorner(guide, 22)
	local guideStroke = Instance.new("UIStroke")
	guideStroke.Color, guideStroke.Thickness, guideStroke.Parent = GOLD, 4, guide
	local header = Instance.new("Frame")
	header.Name, header.BackgroundColor3, header.BorderSizePixel, header.Size, header.ZIndex, header.Parent = "Header", Color3.fromRGB(37, 130, 235), 0, UDim2.new(1, 0, 0, 70), 21, guide
	addCorner(header, 22)
	local guideTitle = addText(header, "Title", "FUSION GUIDE", 22, 16, 40)
	guideTitle.Position, guideTitle.Size = UDim2.fromOffset(24, 8), UDim2.new(1, -110, 1, -16)
	guideTitle.TextXAlignment = Enum.TextXAlignment.Left
	local close = Instance.new("TextButton")
	close.Name, close.Text, close.Font, close.TextScaled, close.TextColor3 = "Close", "X", Enum.Font.FredokaOne, true, WHITE
	close.BackgroundColor3, close.AutoButtonColor, close.ZIndex = Color3.fromRGB(235, 70, 70), false, 23
	close.Size, close.Position, close.AnchorPoint, close.Parent = UDim2.fromOffset(46, 46), UDim2.new(1, -16, 0, 12), Vector2.new(1, 0), guide
	addCorner(close, 10)
	local closeStroke = Instance.new("UIStroke")
	closeStroke.Color, closeStroke.Thickness, closeStroke.Parent = Color3.fromRGB(255, 160, 40), 3, close
	for i, id in { "Wind", "Earth", "Water", "Fire", "Shadow" } do
		local row = Instance.new("Frame")
		row.Name, row.BackgroundColor3, row.BackgroundTransparency, row.BorderSizePixel = "Recipe" .. id, Color3.fromRGB(26, 44, 88), 0.1, 0
		row.Position, row.Size, row.ZIndex, row.Parent = UDim2.fromOffset(20, 84 + (i - 1) * 74), UDim2.new(1, -40, 0, 66), 21, guide
		addCorner(row, 14)
		local function piece(name, x, power)
			local visual = PowerVisuals.Powers[power]
			local icon = Instance.new("ImageLabel")
			icon.Name, icon.BackgroundTransparency, icon.ScaleType, icon.ZIndex = name, 1, Enum.ScaleType.Fit, 22
			icon.Position, icon.Size, icon.Image, icon.Parent = UDim2.fromOffset(x, 6), UDim2.fromOffset(54, 54), visual and visual.Icon or "", row
		end
		local function sign(text, x)
			local label = addText(row, "Sign", text, 22, 12, 36)
			label.Position, label.Size = UDim2.fromOffset(x, 8), UDim2.fromOffset(34, 50)
		end
		piece("Sword", 16, "Sword")
		sign("+", 72)
		piece("Element", 108, id)
		sign("=", 164)
		piece("Result", 202, "Sword_" .. id)
		local name = addText(row, "ResultName", PowerVisuals.Powers["Sword_" .. id].DisplayName, 22, 12, 28)
		name.Position, name.Size, name.TextXAlignment = UDim2.fromOffset(266, 8), UDim2.new(1, -280, 0, 50), Enum.TextXAlignment.Left
	end
	local footer = addText(guide, "Footer", "Fusions last until you are knocked out.", 22, 10, 22)
	footer.Position, footer.Size = UDim2.fromOffset(20, 84 + 5 * 74 + 4), UDim2.new(1, -40, 0, 34)
	self.Guide = guide
	close.Activated:Connect(function()
		guide.Visible = false
	end)
	local guideButton = actionButton(root, "GuideButton", "key_chip")
	guideButton.ZIndex = 4
	local guideText = addText(guideButton, "Key", "?", 5, 14, 30)
	guideText.Size = UDim2.fromScale(1, 1)
	self.GuideButton = guideButton
	connectAction(guideButton, function()
		guide.Visible = not guide.Visible
	end)

	self.MoveButtons = {}
	for i, key in { "1", "2", "3" } do
		local button = actionButton(root, "Move" .. i, "move_button")
		button.ZIndex = 2
		local icon = Instance.new("ImageLabel")
		icon.Name, icon.BackgroundTransparency, icon.ScaleType = "MoveIcon", 1, Enum.ScaleType.Fit
		icon.Position, icon.Size, icon.ZIndex = UDim2.fromScale(0.16, 0.12), UDim2.fromScale(0.68, 0.57), 3
		icon.Parent = button
		local name = addText(button, "MoveName", "", 4, 8, 16)
		name.Position, name.Size = UDim2.fromScale(0.12, 0.66), UDim2.fromScale(0.76, 0.17)
		local keyLabel = addText(button, "Key", key, 6, 11, 24)
		keyLabel.Position, keyLabel.Size = UDim2.fromScale(0.03, 0.02), UDim2.fromScale(0.28, 0.22)
		local cooldownClip = Instance.new("Frame")
		cooldownClip.Name, cooldownClip.BackgroundTransparency, cooldownClip.ClipsDescendants = "CooldownClip", 1, true
		cooldownClip.Size, cooldownClip.ZIndex, cooldownClip.Parent = UDim2.fromScale(1, 1), 4, button
		addCorner(cooldownClip, 18)
		local wipe = radialWipe(cooldownClip)
		local seconds = addText(button, "CooldownSeconds", "", 7, 15, 34)
		seconds.Position, seconds.Size = UDim2.fromScale(0.16, 0.25), UDim2.fromScale(0.68, 0.36)
		self.MoveButtons[i] = { Button = button, Icon = icon, Name = name, Key = keyLabel, Clip = cooldownClip, Wipe = wipe, Seconds = seconds }
		connectAction(button, function()
			local callback = self.Actions.Move
			if callback then
				callback(i)
			end
		end)
	end

	local m1 = actionButton(root, "M1", "round_button")
	m1.ZIndex = 2
	local m1Icon = iconImage(m1, "Icon", "m1")
	m1Icon.Position, m1Icon.Size, m1Icon.ZIndex = UDim2.fromScale(0.22, 0.1), UDim2.fromScale(0.56, 0.64), 3
	local m1Text = addText(m1, "Label", "M1", 4, 13, 30)
	m1Text.Position, m1Text.Size = UDim2.fromScale(0.22, 0.68), UDim2.fromScale(0.56, 0.2)
	self.M1 = m1
	connectAction(m1, function()
		local callback = self.Actions.M1
		if callback then
			callback()
		end
	end)

	self.SmallButtons = {}
	for _, def in { { "Dash", "dash", "DASH" }, { "Inhale", "inhale", "INHALE" }, { "Swallow", "star", "SWALLOW" }, { "Spit", "star", "SPIT" } } do
		local button = actionButton(root, def[1], "small_button")
		button.ZIndex = 2
		local icon = iconImage(button, "Icon", def[2])
		icon.Position, icon.Size, icon.ZIndex = UDim2.fromScale(0.2, 0.1), UDim2.fromScale(0.6, 0.58), 3
		local label = addText(button, "Label", def[3], 4, 9, 18)
		label.Position, label.Size = UDim2.fromScale(0.1, 0.67), UDim2.fromScale(0.8, 0.18)
		self.SmallButtons[def[1]] = { Button = button, Label = label }
	end
	for _, id in { "Dash", "Swallow", "Spit" } do
		connectAction(self.SmallButtons[id].Button, function()
			local callback = self.Actions[id]
			if callback then
				callback()
			end
		end)
	end
	local inhale = self.SmallButtons.Inhale.Button
	inhale.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			local callback = self.Actions.Inhale
			if callback then
				callback()
			end
		end
	end)
	inhale.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			local callback = self.Actions.InhaleEnd
			if callback then
				callback()
			end
		end
	end)

	self.ResizeConnection = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:Layout()
	end)
	self.InputConnection = UIS.LastInputTypeChanged:Connect(function(inputType)
		local gamepad = tostring(inputType):find("Gamepad") ~= nil
		if gamepad ~= self.Gamepad then
			self.Gamepad = gamepad
			self:Update(self.State)
		end
	end)
	gui.Destroying:Once(function()
		self.ResizeConnection:Disconnect()
		self.InputConnection:Disconnect()
	end)
	self:Layout()
	return self
end

function PilotHud:SetActions(callbacks)
	self.Actions = callbacks or EMPTY_ACTIONS
end

-- Places the two tiles with the fusion socket between them: In Hand, [socket + swap], Backup.
function PilotHud:LayoutTray(x, y, handW, handH, backW, backH, gap)
	local hand, back = self.Slots[1].Frame, self.Slots[2].Frame
	hand.Position, hand.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(handW, handH)
	local backX, backY = x + handW + gap, y + (handH - backH)
	back.Position, back.Size = UDim2.fromOffset(backX, backY), UDim2.fromOffset(backW, backH)
	local centre = x + handW + gap * 0.5
	local fuseW = math.min(gap - 6, 132)
	self.Tags[1].Position, self.Tags[1].Size = UDim2.fromOffset(x, y - 28), UDim2.fromOffset(handW, 26)
	self.Tags[2].Position, self.Tags[2].Size = UDim2.fromOffset(backX, backY - 28), UDim2.fromOffset(backW, 26)
	local fuse = self.Bridge.Fuse
	fuse.Position, fuse.Size = UDim2.fromOffset(centre - fuseW * 0.5, y + 2), UDim2.fromOffset(fuseW, fuseW * 0.83)
	self.Bridge.Plus.Position, self.Bridge.Plus.Size = UDim2.fromOffset(centre - 24, y + 6), UDim2.fromOffset(48, 48)
	self.Bridge.Hint.Position, self.Bridge.Hint.Size = UDim2.fromOffset(centre - gap * 0.5 + 2, y + 54), UDim2.fromOffset(gap - 4, 40)
	self.Swap.Position, self.Swap.Size = UDim2.fromOffset(centre - 54, y + handH - 66), UDim2.fromOffset(58, 58)
	self.GuideButton.Position, self.GuideButton.Size = UDim2.fromOffset(centre + 8, y + handH - 66), UDim2.fromOffset(46, 46)
	self.Preview.Frame.Position, self.Preview.Frame.Size = UDim2.fromOffset(x + (handW + gap + backW) * 0.5 - 270, y - 190), UDim2.fromOffset(540, 68)
end

function PilotHud:Layout()
	local size = self.Gui.AbsoluteSize
	if size.X < 200 or size.Y < 200 then return end
	self.Compact = UIS.TouchEnabled or size.X < 700
	local baseScale = math.min(size.X / 1920, size.Y / 1080)
	local scale = math.clamp(baseScale * (self.Compact and 1.2 or 1), 0.5, 1.3)
	self.Scale.Scale = scale
	local width, height = size.X / scale, size.Y / scale
	self.Health.Position, self.Health.Size = UDim2.fromOffset(28, 18), UDim2.fromOffset(480, 92)
	self.Currency.Position, self.Currency.Size = UDim2.fromOffset(36, 112), UDim2.fromOffset(224, 80)
	self.Board.Position, self.Board.Size = UDim2.fromOffset(width - 398, 24), UDim2.fromOffset(370, 264)
	if self.Compact then
		self.Health.Position = UDim2.fromOffset(16, 12)
		self.Currency.Position = UDim2.fromOffset(18, 112)
		self.Prompt.Position, self.Prompt.Size = UDim2.fromOffset(math.max(12, width * 0.5 - 300), height - 188), UDim2.fromOffset(600, 86)
		self:LayoutTray(18, height - 178, 150, 134, 126, 122, 100)
		local actionX = width - 304
		self.M1.Position, self.M1.Size = UDim2.fromOffset(actionX, height - 178), UDim2.fromOffset(112, 108)
		self.SmallButtons.Dash.Button.Position = UDim2.fromOffset(actionX + 118, height - 163)
		self.SmallButtons.Inhale.Button.Position = UDim2.fromOffset(actionX + 202, height - 163)
		for _, id in { "Dash", "Inhale" } do
			self.SmallButtons[id].Button.Size = UDim2.fromOffset(80, 80)
		end
		for i, move in self.MoveButtons do
			move.Button.Position, move.Button.Size = UDim2.fromOffset(width - 286 + (i - 1) * 92, height - 282), UDim2.fromOffset(88, 80)
		end
		for i, id in { "Swallow", "Spit" } do
			self.SmallButtons[id].Button.Position = UDim2.fromOffset(math.max(12, width * 0.5 - 300) - 84 * (3 - i), height - 280)
			self.SmallButtons[id].Button.Size = UDim2.fromOffset(80, 80)
		end
	else
		self.HealthFillClip.Position = UDim2.fromOffset(56, 18)
		self.Prompt.Position, self.Prompt.Size = UDim2.fromOffset(width * 0.5 - 310, height - 350), UDim2.fromOffset(620, 104)
		self:LayoutTray(width * 0.5 - 245, height - 238, 184, 164, 148, 143, 134)
		self.M1.Position, self.M1.Size = UDim2.fromOffset(30, height - 224), UDim2.fromOffset(184, 178)
		self.SmallButtons.Dash.Button.Position = UDim2.fromOffset(225, height - 172)
		self.SmallButtons.Inhale.Button.Position = UDim2.fromOffset(345, height - 172)
		for _, id in { "Dash", "Inhale" } do
			self.SmallButtons[id].Button.Size = UDim2.fromOffset(112, 108)
		end
		for i, move in self.MoveButtons do
			move.Button.Position, move.Button.Size = UDim2.fromOffset(width - 492 + (i - 1) * 158, height - 188), UDim2.fromOffset(146, 121)
		end
		for i, id in { "Swallow", "Spit" } do
			self.SmallButtons[id].Button.Position, self.SmallButtons[id].Button.Size = UDim2.fromOffset(width * 0.5 - 326 - (3 - i) * 104, height - 340), UDim2.fromOffset(96, 92)
		end
	end
	local guideWidth = math.min(600, width - 24)
	self.Guide.Size = UDim2.fromOffset(guideWidth, 500)
	self.Guide.Position = UDim2.fromOffset((width - guideWidth) * 0.5, math.max(8, (height - 500) * 0.5))
	self:Update(self.State)
end

local function previewCell(cell, id, text, lost)
	local visual = id and PowerVisuals.Powers[id]
	cell.Icon.Visible, cell.Label.Visible = id ~= nil, id ~= nil
	if not id then
		return
	end
	cell.Icon.Image = visual and visual.Icon or ""
	cell.Icon.ImageColor3 = lost and Color3.fromRGB(110, 110, 120) or WHITE
	cell.Cross.Visible = lost
	cell.Label.Text = string.format("%s\n%s", powerName(id), text)
	cell.Label.TextColor3 = lost and Color3.fromRGB(255, 150, 150) or WHITE
end

-- In Hand / Backup tags, the fusion socket (a quiet "+" until the pair can fuse), and the swallow preview.
function PilotHud:UpdateLoadout(activeMatch, active, bench, held)
	for _, tag in self.Tags do
		tag.Visible = activeMatch
	end
	local fusion = active and bench and C.Fusion(active, bench)
	local bridge = self.Bridge
	bridge.Fuse.Visible = activeMatch and fusion ~= nil
	bridge.Plus.Visible = activeMatch and fusion == nil
	bridge.Hint.Visible = activeMatch and fusion == nil
	bridge.Hint.Text = active and bench and "Sword + any element fuses" or ""
	if fusion then
		bridge.Recipe.Text = powerName(active) .. " + " .. powerName(bench)
		bridge.Result.Text = "= " .. powerName(fusion)
	end
	self.GuideButton.Visible = activeMatch
	if not activeMatch then
		self.Guide.Visible = false
	end
	-- Swallowing puts the star In Hand, moves the current power to Backup and loses the old Backup power.
	local showPreview = activeMatch and held ~= nil and held ~= "Mystery"
	self.Preview.Frame.Visible = showPreview
	if showPreview then
		local cells = self.Preview.Cells
		previewCell(cells[1], held, "-> IN HAND", false)
		previewCell(cells[2], active, "-> BACKUP", false)
		previewCell(cells[3], bench and active and bench or nil, "LOST", true)
	end
end

function PilotHud:Update(state)
	self.State = state or self.State
	state = self.State
	local activeMatch = state.Active == true
	local slots = state.Slots or {}
	local slotIndex = state.Slot or 1
	local active, bench = slots[slotIndex], slots[3 - slotIndex]
	local hp = math.max(0, state.HP or 0)
	local hpRatio = math.clamp(hp / C.MaxHealth, 0, 1)
	self.HpText.Text = tostring(math.floor(hp + 0.5))
	local fillWidth, fillHeight = 402, 58
	self.HealthFillClip.Size = UDim2.fromOffset(fillWidth * hpRatio, fillHeight)
	self.CoinsText.Text, self.Health.Visible = tostring(state.Coins or 0), activeMatch
	self.Board.Visible = not (self.Compact and activeMatch)
	self.BoardTitle.Text = activeMatch and "FFA KOs" or "SERVER LEADERBOARD"
	local rows = activeMatch and state.Rows or state.Board
	for i, label in self.BoardRows do
		local row = rows and rows[i]
		label.Visible = row ~= nil
		if row then
			local score = activeMatch and row.Score or row.Session
			label.Text = string.format("%d   %s     %s%s", i, row.Name or "", tostring(score or 0), activeMatch and "" or " KOs")
		end
	end
	self.PromptText.Text = state.Prompt or ""
	for i, id in { active, bench } do
		local slot, visual = self.Slots[i], id and PowerVisuals.Powers[id]
		slot.Label.Text = id and powerName(id) or (i == 2 and "Swallow a star" or "Empty")
		setImage(slot.Icon, visual and visual.Icon)
	end
	self.Swap.Visible, self.Swap.Active = activeMatch and bench ~= nil, activeMatch and bench ~= nil
	self.M1.Visible = activeMatch
	self.SmallButtons.Dash.Button.Visible, self.SmallButtons.Inhale.Button.Visible = activeMatch, activeMatch
	self.Slots[1].Frame.Visible, self.Slots[2].Frame.Visible = activeMatch, activeMatch
	local keyNames = self.Gamepad and { "X", "RB", "D-UP" } or { "1", "2", "3" }
	for i, move in self.MoveButtons do
		move.Button.Visible = activeMatch
		local power = active and C.Powers[active]
		local moveConfig = power and power.Moves[i]
		local icons = active and MoveIcons[active]
		setImage(move.Icon, icons and icons[i])
		move.Name.Text, move.Key.Text = moveConfig and moveConfig.Name or "Empty", keyNames[i]
		local remaining = active and (state.Cooldowns or {})[active .. i] or 0
		remaining = math.max(0, remaining or 0)
		local total = moveConfig and moveConfig.Cooldown or 0
		local ratio = total > 0 and math.clamp(remaining / total, 0, 1) or 0
		move.Clip.Visible = ratio > 0
			move.Wipe(ratio)
		move.Seconds.Visible, move.Seconds.Text = remaining > 0, remaining > 0 and string.format("%.1f", remaining) or ""
	end
	local held = state.Held ~= nil
	self.SmallButtons.Swallow.Button.Visible = activeMatch and held
	self.SmallButtons.Spit.Button.Visible = activeMatch and held
	self:UpdateLoadout(activeMatch, active, bench, state.Held)
	self.SmallButtons.Inhale.Label.Text = state.Inhaling and "HOLD" or "INHALE"
	self.SmallButtons.Inhale.Button.ImageColor3 = state.Inhaling and Color3.fromRGB(255, 235, 110) or WHITE
	for id, cooldownKey in { M1 = "M1", Dash = "Dash", Inhale = "Inhale" } do
		local button = id == "M1" and self.M1 or self.SmallButtons[id].Button
		button.ImageTransparency = ((state.Cooldowns or {})[cooldownKey] or 0) > 0 and 0.35 or 0
	end
end

return PilotHud
