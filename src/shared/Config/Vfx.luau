return {
	Style = "chunky-cartoon",
	Textures = { Puff = "rbxassetid://71229989533127", Star = "rbxassetid://70777146536244" },
	Budget = { Parts = 40, Beams = 12, Emitters = 14, Lights = 3 },
	Inhale = {
		Lifetime = 2.4, CullDistance = 180, MaxConcurrent = 6,
		Rings = 4, Sprites = 14, Range = 16, CaptureTime = 0.28,
		Body = Color3.fromRGB(127, 232, 207),
		Highlight = Color3.fromRGB(232, 255, 248),
		Shade = Color3.fromRGB(47, 174, 147),
	},
}
