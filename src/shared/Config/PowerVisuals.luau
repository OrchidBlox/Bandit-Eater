-- Shared visual identity. Published under the experience owner.
local icons = {
	Wind = "127320336061449", Earth = "115503973262283", Water = "132075750363145",
	Fire = "138192374849125", Sword = "136252600941129", Shadow = "139922773922773",
	["Wind Sword"] = "81295627407302", ["Earth Sword"] = "91523572995838",
	["Water Sword"] = "99814366776493", ["Fire Sword"] = "83994361002930",
	["Shadow Sword"] = "95378118481294", ["Master Sword"] = "105078622955025",
}
local function visual(displayName, glyph, body, highlight, shade, accent)
	return { DisplayName = displayName, Glyph = glyph, Icon = "rbxassetid://" .. icons[displayName], Body = body,
		Highlight = highlight, Shade = shade, Accent = accent or highlight }
end

local wind = { Color3.fromRGB(127, 232, 207), Color3.fromRGB(232, 255, 248), Color3.fromRGB(47, 174, 147) }
local earth = { Color3.fromRGB(185, 132, 67), Color3.fromRGB(235, 196, 140), Color3.fromRGB(107, 68, 35) }
local water = { Color3.fromRGB(63, 182, 255), Color3.fromRGB(189, 235, 255), Color3.fromRGB(30, 111, 224) }
local fire = { Color3.fromRGB(255, 138, 31), Color3.fromRGB(255, 211, 77), Color3.fromRGB(224, 72, 27) }
local sword = { Color3.fromRGB(201, 211, 222), Color3.new(1, 1, 1), Color3.fromRGB(110, 127, 148) }
local shadow = { Color3.fromRGB(155, 92, 255), Color3.fromRGB(217, 194, 255), Color3.fromRGB(90, 45, 181) }

return {
	Powers = {
		Wind = visual("Wind", "rolling-air-curl", wind[1], wind[2], wind[3]),
		Earth = visual("Earth", "faceted-boulder", earth[1], earth[2], earth[3]),
		Water = visual("Water", "water-drop", water[1], water[2], water[3]),
		Fire = visual("Fire", "three-lobed-flame", fire[1], fire[2], fire[3]),
		Sword = visual("Sword", "broad-upright-sword", sword[1], sword[2], sword[3]),
		Shadow = visual("Shadow", "crescent-and-orb", shadow[1], shadow[2], shadow[3]),
		Sword_Wind = visual("Wind Sword", "sword-with-air-curl", wind[1], wind[2], wind[3], sword[1]),
		Sword_Earth = visual("Earth Sword", "ochre-faceted-sword", earth[1], earth[2], earth[3]),
		Sword_Water = visual("Water Sword", "wave-blade", water[1], water[2], water[3], sword[1]),
		Sword_Fire = visual("Fire Sword", "flame-blade", fire[1], fire[2], fire[3]),
		Sword_Shadow = visual("Shadow Sword", "violet-sword-with-curl", shadow[1], shadow[2], shadow[3]),
		Sword_Sword = visual("Master Sword", "single-sword-with-gold-crown", sword[1], sword[2], sword[3], Color3.fromRGB(255, 211, 77)),
	},
	Swallow = {
		AnimationId = "rbxassetid://134771684679502",
		MovingAnimationId = "rbxassetid://99253369218549",
		FadeIn = 0.08, FadeOut = 0.12,
		Duration = 24 / 30, Gulp = 8 / 30, PowerPop = 12 / 30, Equip = 18 / 30, Recover = 21 / 30,
		CullDistance = 150, MaxParts = 11,
	},
}
