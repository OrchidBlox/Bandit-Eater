local Kit = require(script.Parent.Kit)
local Cartoon = {}

function Cartoon.sprite(parent, texture, color)
	return Kit.sprite(parent, texture, color)
end

function Cartoon.envelope(progress)
	return math.clamp(progress / 0.12, 0, 1) * math.clamp((1 - progress) / 0.2, 0, 1)
end

function Cartoon.pop(progress)
	-- A twenty-percent overshoot settles into the final scale.
	return 1 + 0.2 * math.sin(math.clamp(progress, 0, 1) * math.pi)
end

function Cartoon.placeSprite(sprite, frame, size, opacity, rotation)
	sprite.part.CFrame = frame
	sprite.gui.Size = UDim2.fromScale(size, size)
	sprite.image.ImageTransparency = 1 - math.clamp(opacity, 0, 1)
	sprite.image.Rotation = rotation
end

return Cartoon
