-- Presentation only. The caller owns authoritative slot updates and animation playback.
-- Play({Caster, Power, PreviousPower?, Token?, Elapsed?, Scale?}, look), then Update(dt).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local Textures = require(ReplicatedStorage.Shared.Config.Vfx).Textures
local Kit = require(script.Parent.Parent.Kit)
local Cartoon = require(script.Parent.Parent.Cartoon)
local PowerSwallow = {}
local C = Visuals.Swallow

local function finite(number)
	return type(number) == "number" and number == number and math.abs(number) < 1e7
end

local function frames(caster)
	if not caster:IsDescendantOf(workspace) then return end
	local humanoid = caster:FindFirstChildOfClass("Humanoid")
	local root = caster:FindFirstChild("HumanoidRootPart")
	local torso = caster:FindFirstChild("UpperTorso") or caster:FindFirstChild("Torso")
	local head = caster:FindFirstChild("Head")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart")
		or not torso or not torso:IsA("BasePart") or not head or not head:IsA("BasePart") then return end
	local chest = torso.Position + root.CFrame.LookVector * (torso.Size.Z / 2 + 0.18)
	local mouth = head.Position + root.CFrame.LookVector * (head.Size.Z / 2 + 0.15) - root.CFrame.UpVector * 0.15
	if not finite(chest.X) or not finite(chest.Y) or not finite(chest.Z) then return end
	return CFrame.lookAt(chest, chest + root.CFrame.LookVector, root.CFrame.UpVector), mouth
end

local function fraction(age, first, last)
	return math.clamp((age - first) / (last - first), 0, 1)
end

local function smooth(alpha)
	return alpha * alpha * (3 - 2 * alpha)
end

local function halo(parent, color)
	-- A short, compact elliptical halo, not a bubble or protective shell.
	local part = Kit.safePart(Instance.new("Part"))
	part.Name, part.Size, part.Transparency = "PowerHalo", Vector3.one * 0.05, 1
	local gui = Instance.new("BillboardGui")
	gui.Name, gui.Adornee, gui.AlwaysOnTop, gui.LightInfluence = "Halo", part, false, 0
	gui.Size, gui.MaxDistance = UDim2.fromScale(2.2, 0.6), C.CullDistance
	local frame = Instance.new("Frame")
	frame.Size, frame.Position, frame.BackgroundTransparency = UDim2.fromScale(0.9, 0.8), UDim2.fromScale(0.05, 0.1), 1
	local corner = Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(1, 0), frame
	local stroke = Instance.new("UIStroke")
	stroke.Color, stroke.Thickness, stroke.Transparency, stroke.Parent = color, 3, 1, frame
	frame.Parent, gui.Parent, part.Parent = gui, part, parent
	return { part = part, gui = gui, stroke = stroke }
end

function PowerSwallow.Play(data, look)
	if type(data) ~= "table" or type(look) ~= "table" or not finite(look.distanceFactor)
		or look.distanceFactor <= 0 or typeof(data.Caster) ~= "Instance" or not data.Caster:IsA("Model")
		or type(data.Power) ~= "string" then return end
	local power = Visuals.Powers[data.Power]
	local previous = data.PreviousPower ~= nil and Visuals.Powers[data.PreviousPower] or nil
	if not power or (data.PreviousPower ~= nil and (type(data.PreviousPower) ~= "string" or not previous)) then return end
	if data.Token ~= nil and (type(data.Token) ~= "string" or #data.Token > 80) then return end
	if data.Scale ~= nil and not finite(data.Scale) then return end
	if data.Elapsed ~= nil and (not finite(data.Elapsed) or data.Elapsed < 0 or data.Elapsed >= C.Duration) then return end
	local initial = frames(data.Caster)
	local camera = workspace.CurrentCamera
	if not initial or not camera or (camera.CFrame.Position - initial.Position).Magnitude > C.CullDistance then return end
	local group = Instance.new("Folder")
	group.Name = "PowerSwallow_" .. (data.Token or data.Power)
	local effect = { caster = data.Caster, token = data.Token, group = group,
		elapsed = data.Elapsed or 0, scale = math.clamp(data.Scale or 1, 0.5, 1.5), sprites = {}, destroyed = false }
	-- Missing icons remain absent; never substitute a different power's glyph.
	effect.emblem = Cartoon.sprite(group, power.Icon, Color3.new(1, 1, 1))
	effect.previous = previous and Cartoon.sprite(group, previous.Icon, Color3.new(1, 1, 1)) or nil
	effect.halo = halo(group, power.Highlight)
	for i = 1, 8 do
		local star = i > 5
		local sprite = Cartoon.sprite(group, star and Textures.Star or Textures.Puff,
			star and (i == 8 and power.Accent or power.Body) or Color3.new(1, 1, 1))
		if sprite then
			sprite.index, sprite.star = i, star
			table.insert(effect.sprites, sprite)
		end
	end
	group.Parent = Kit.folder()
	Debris:AddItem(group, C.Duration + 0.5) -- Hard cleanup if the owning controller is interrupted.

	function effect:Destroy()
		if self.destroyed then return end
		self.destroyed = true
		self.group:Destroy()
		table.clear(self.sprites)
		self.emblem, self.previous, self.halo = nil, nil, nil
	end

	function effect:Update(dt)
		if self.destroyed then return false end
		if not finite(dt) or dt < 0 then
			self:Destroy()
			return false
		end
		self.elapsed += dt
		local age = self.elapsed
		local frame, mouth = frames(self.caster)
		local currentCamera = workspace.CurrentCamera
		if age >= C.Duration or not self.group.Parent or not frame or not currentCamera
			or (currentCamera.CFrame.Position - frame.Position).Magnitude > C.CullDistance then
			self:Destroy()
			return false
		end
		local scale = self.scale
		local gather = fraction(age, 0, C.Gulp)
		local gulp = fraction(age, C.Gulp, C.PowerPop)
		local pop = fraction(age, C.PowerPop, C.Equip)
		local equip = fraction(age, C.Equip, C.Recover)
		local fade = 1 - fraction(age, C.Recover, C.Duration)
		local chest = frame.Position
		if self.emblem then
			local position, size, opacity
			if age < C.PowerPop then
				local start = chest + frame.LookVector * 0.8 - frame.UpVector * 0.35
				position = start:Lerp(mouth, smooth(gather))
				size, opacity = 0.85 * (1 - gulp), 1 - gulp
			else
				position = chest:Lerp(chest + frame.RightVector * 1.6 + frame.UpVector * 0.85, smooth(equip))
				size, opacity = (1.15 - equip * 0.25) * Cartoon.pop(pop), math.min(1, pop * 5) * fade
			end
			Cartoon.placeSprite(self.emblem, CFrame.new(position), math.max(0.02, size * scale), opacity, 0)
		end
		if self.previous then
			local position = chest:Lerp(chest - frame.RightVector * 1.6 + frame.UpVector * 0.85, smooth(equip))
			Cartoon.placeSprite(self.previous, CFrame.new(position), 0.75 * scale,
				age >= C.Equip and math.min(1, equip * 5) * fade or 0, 0)
		end
		local haloOpacity = age >= C.PowerPop and age < C.Recover and Cartoon.envelope(fraction(age, C.PowerPop, C.Recover)) * 0.7 or 0
		self.halo.part.CFrame = frame
		self.halo.gui.Size = UDim2.fromScale(2.25 * scale * Cartoon.pop(pop), 0.65 * scale)
		self.halo.stroke.Transparency = 1 - haloOpacity
		for _, sprite in self.sprites do
			local index = sprite.index
			local position, size, opacity
			if index <= 2 then
				local side = index == 1 and -1 or 1
				position = (chest + frame.RightVector * side * 1.25 - frame.UpVector * 0.3):Lerp(mouth, smooth(gather))
				size, opacity = 0.6 * scale * (1 - gather * 0.6), age < C.Gulp and Cartoon.envelope(gather) or 0
			else
				local progress = fraction(age, C.PowerPop, C.Duration)
				local angle = (index - 3) * math.pi * 2 / 6 + 0.4
				local radius = (0.55 + smooth(progress) * 1.3) * scale
				position = chest + frame.RightVector * math.cos(angle) * radius + frame.UpVector * math.sin(angle) * radius
				size = (sprite.star and 0.4 or 0.7) * scale * Cartoon.pop(progress) * (1 - progress * 0.3)
				opacity = age >= C.PowerPop and Cartoon.envelope(progress) * 0.85 or 0
			end
			Cartoon.placeSprite(sprite, CFrame.new(position), math.max(0.02, size), opacity, sprite.star and pop * 40 or 0)
		end
		return true
	end

	effect:Update(0)
	return effect
end

return PowerSwallow
