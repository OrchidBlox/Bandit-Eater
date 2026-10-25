local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local Kit = require(script.Parent.Parent.Kit)
local Cartoon = require(script.Parent.Parent.Cartoon)
local Inhale = {}
local C = Config.Inhale

local function mouthFrame(caster)
	local root = caster:FindFirstChild("HumanoidRootPart")
	local head = caster:FindFirstChild("Head")
	local humanoid = caster:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then
		return nil
	end
	local position = head and head:IsA("BasePart") and head.Position or root.Position + Vector3.new(0, 1.5, 0)
	position += root.CFrame.LookVector * 0.85
	return CFrame.lookAt(position, position + root.CFrame.LookVector, root.CFrame.UpVector)
end

local function template()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local vfx = assets and assets:FindFirstChild("Vfx")
	local inhale = vfx and vfx:FindFirstChild("Inhale")
	return inhale and inhale:FindFirstChild("Crescent")
end

function Inhale.Play(data, look)
	if look.distanceFactor == 0 then
		return nil
	end
	local caster = data.Caster
	local initial = mouthFrame(caster)
	if not initial then
		return nil
	end
	local group = Instance.new("Folder")
	group.Name = "Inhale_" .. data.Token
	group:SetAttribute("Token", data.Token)
	local rings, sprites = {}, {}
	local source = template()
	for i = 1, C.Rings do
		local body = Kit.crescent(group, source, C.Body, 0.3)
		if body then
			local shade = Kit.crescent(group, source, C.Shade, 0.48)
			if shade then
				shade.part.Material = Enum.Material.SmoothPlastic
			end
			table.insert(rings, { body = body, shade = shade, phase = (i - 1) / C.Rings })
		end
	end
	for i = 1, C.Sprites do
		local star = i % 3 == 0
		local texture = star and Config.Textures.Star or Config.Textures.Puff
		local sprite = Cartoon.sprite(group, texture, star and C.Highlight or Color3.new(1, 1, 1))
		if sprite then
			sprite.index, sprite.star = i, star
			table.insert(sprites, sprite)
		end
	end
	if #rings == 0 and #sprites == 0 then
		group:Destroy()
		return nil
	end
	group.Parent = Kit.folder()
	local effect = { caster = caster, token = data.Token, started = os.clock(), group = group,
		rings = rings, sprites = sprites, frame = initial, stopped = false }

	function effect:Destroy()
		if self.destroyed then
			return
		end
		self.destroyed = true
		self.group:Destroy()
	end

	function effect:Stop(captured)
		if self.stopped or self.destroyed then
			return
		end
		self.stopped = true
		if not captured or #self.sprites == 0 then
			self:Destroy()
			return
		end
		self.popStarted = os.clock()
		for _, ring in self.rings do
			ring.body.part:Destroy()
			if ring.shade then
				ring.shade.part:Destroy()
			end
		end
		table.clear(self.rings)
		for i, sprite in self.sprites do
			if i > 6 then
				sprite.part:Destroy()
			elseif Config.Textures.Star ~= "" then
				sprite.image.Image = Config.Textures.Star
			end
		end
	end

	function effect:Update(now)
		if self.destroyed then
			return false
		end
		if not caster:IsDescendantOf(workspace) then
			self:Destroy()
			return false
		end
		local frame = mouthFrame(caster)
		if not frame or now - self.started > C.Lifetime then
			self:Destroy()
			return false
		end
		self.frame = frame
		if self.popStarted then
			local progress = (now - self.popStarted) / C.CaptureTime
			if progress >= 1 then
				self:Destroy()
				return false
			end
			for i = 1, math.min(6, #self.sprites) do
				local angle = i * math.pi / 3
				local radius = 0.25 + progress * 0.85
				Cartoon.placeSprite(self.sprites[i], frame * CFrame.new(math.cos(angle) * radius, math.sin(angle) * radius, -0.2),
					0.5 * Cartoon.pop(progress) * (1 - progress * 0.4), 1 - progress, i * 30 + progress * 65)
			end
			return true
		end
		local age = now - self.started
		for i, ring in self.rings do
			local progress = (age / 0.78 + ring.phase) % 1
			local distance = 0.4 + C.Range * (1 - progress)
			local diameter = (0.55 + 4.8 * (1 - progress)) * Cartoon.pop(progress)
			local ringFrame = frame * CFrame.new(0, 0, -distance) * CFrame.Angles(0, 0, age * 2.8 + i * 1.6)
			local opacity = Cartoon.envelope(progress)
			local scale = diameter / 4
			-- Imported MeshParts are box-centered; keep the authored ring center on the suction axis.
			ring.body.part.Size = ring.body.size * scale
			ring.body.part.CFrame = ringFrame * CFrame.new(-ring.body.pivot * scale)
			ring.body.part.Transparency = 1 - opacity * 0.72
			if ring.shade then
				ring.shade.part.Size = ring.shade.size * (scale * 1.06)
				ring.shade.part.CFrame = ringFrame * CFrame.new(0, 0, 0.06) * CFrame.new(-ring.shade.pivot * scale * 1.06)
				ring.shade.part.Transparency = 1 - opacity * 0.42
			end
		end
		for _, sprite in self.sprites do
			local i = sprite.index
			local progress = (age / (0.65 + i % 4 * 0.06) + i / C.Sprites) % 1
			local angle = i * 2.4 + age * 1.7
			local radius = (0.6 + i % 4 * 0.45) * (1 - progress)
			local distance = (12 + i % 5) * (1 - progress)
			local size = (sprite.star and 0.6 or 1.15) * (0.3 + 0.7 * (1 - progress)) * Cartoon.pop(progress)
			Cartoon.placeSprite(sprite, frame * CFrame.new(math.cos(angle) * radius, math.sin(angle) * radius, -distance),
				size, Cartoon.envelope(progress) * 0.85, i * 47 + age * 35)
		end
		return true
	end

	effect:Update(os.clock())
	return effect
end

return Inhale
