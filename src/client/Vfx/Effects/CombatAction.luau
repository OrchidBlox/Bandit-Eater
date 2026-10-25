local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config.CombatActions)
local Textures = require(ReplicatedStorage.Shared.Config.Vfx).Textures
local Kit = require(script.Parent.Parent.Kit)
local Cartoon = require(script.Parent.Parent.Cartoon)
local Effect = {}

local function finite(vector)
	return typeof(vector) == "Vector3" and vector.X == vector.X and vector.Y == vector.Y and vector.Z == vector.Z
		and math.abs(vector.X) < 1e7 and math.abs(vector.Y) < 1e7 and math.abs(vector.Z) < 1e7
end

function Effect.Play(data, look)
	if type(data) ~= "table" or not finite(data.Position) or not look or look.distanceFactor <= 0 then return end
	local kind = data.Kind
	if kind ~= "Swing" and kind ~= "Hit" and kind ~= "DashBurst" and kind ~= "DashBrake" then return end
	local container = Instance.new("Folder")
	container.Name = "CombatAction_" .. kind
	container.Parent = Kit.folder()
	local effect = { container = container, sprites = {}, started = os.clock(), lifetime = Config.EffectLifetime,
		position = data.Position, destroyed = false }
	local count = kind == "Hit" and 5 or kind == "DashBurst" and 3 or kind == "DashBrake" and 2 or 1
	for i = 1, count do
		local star = kind == "Hit" and i > 3
		local sprite = Cartoon.sprite(container, star and Textures.Star or Textures.Puff,
			star and Color3.fromRGB(255, 221, 70) or Color3.new(1, 1, 1))
		if sprite then
			local angle = (i - 1) * math.pi * 2 / count
			sprite.offset = Vector3.new(math.cos(angle), star and 0.8 or 0.25, math.sin(angle))
			sprite.scale = star and 0.55 or kind == "DashBurst" and 1.35 or kind == "Swing" and 0.65 or 1
			sprite.star = star
			table.insert(effect.sprites, sprite)
		end
	end
	function effect:Destroy()
		if self.destroyed then return end
		self.destroyed = true
		self.container:Destroy()
		table.clear(self.sprites)
	end
	function effect:Update(now)
		if self.destroyed or not self.container.Parent then return false end
		local progress = (now - self.started) / self.lifetime
		if progress >= 1 then
			self:Destroy()
			return false
		end
		for _, sprite in self.sprites do
			local offset = sprite.offset * (0.15 + progress * (sprite.star and 1.5 or 0.7))
			local size = sprite.scale * Cartoon.pop(progress) * (1 - progress * 0.35)
			Cartoon.placeSprite(sprite, CFrame.new(self.position + offset), size,
				Cartoon.envelope(progress) * 0.9, sprite.star and progress * 70 or progress * 12)
		end
		return true
	end
	return effect
end

return Effect
