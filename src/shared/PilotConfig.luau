-- Prototype values only: balance, move names and cosmetics need owner playtesting.
local C = {
	MatchSeconds = 90, IntermissionSeconds = 12, ResultsSeconds = 8,
	MaxHealth = 100, WalkSpeed = 20, BotFill = 4, BanditRespawn = 8,
	ShieldDuration = 1, ShieldCooldown = 5, ShieldReduction = 0.65,
	InhaleDuration = 0.7, InhaleCooldown = 3, InhaleRange = 19,
	SwapCooldown = 1.5, SwallowProtection = 0.4,
	BaseIds = { "Wind", "Earth", "Water", "Fire", "Sword", "Shadow" },
	Powers = {}, Fusions = {},
	Skins = {
		Default = { Price = 0, Color = Color3.fromRGB(255, 221, 70) },
		Rose = { Price = 75, Color = Color3.fromRGB(255, 105, 170) },
		Mint = { Price = 75, Color = Color3.fromRGB(80, 255, 185) },
	},
}
local definitions = {
	Wind = { Color3.fromRGB(160, 245, 220), "Gust", "Vortex", "Cyclone" },
	Earth = { Color3.fromRGB(173, 120, 65), "Rock Shot", "Stone Field", "Quake" },
	Water = { Color3.fromRGB(65, 170, 255), "Water Shot", "Whirlpool", "Tidal Wave" },
	Fire = { Color3.fromRGB(255, 100, 40), "Fireball", "Flame Field", "Eruption" },
	Sword = { Color3.fromRGB(210, 220, 240), "Slash", "Blade Guard", "Blade Storm" },
	Shadow = { Color3.fromRGB(150, 80, 220), "Shadow Shot", "Shadow Snare", "Nightfall" },
}
for id, d in definitions do
	C.Powers[id] = { Color = d[1], Moves = {
			{ Name = d[2], Kind = id == "Sword" and "Melee" or "Projectile", Damage = 13, Cooldown = 2, Range = 55, Stun = 0, PvpDamage = 1, PvpCooldown = 1, PvpStun = 1 },
			{ Name = d[3], Kind = id == "Sword" and "Guard" or "Field", Damage = 8, Cooldown = 7, Range = 20, Stun = 0.35, PvpDamage = 1, PvpCooldown = 1, PvpStun = 1 },
			{ Name = d[4], Kind = "Signature", Damage = 25, Cooldown = 14, Range = 18, Stun = 0.5, PvpDamage = 1, PvpCooldown = 1, PvpStun = 1 },
		} }
end
for _, id in C.BaseIds do
	local pair = { "Sword", id }
	table.sort(pair)
	local result = "Sword_" .. id
	C.Fusions[table.concat(pair, "+")] = result
	C.Powers[result] = { Color = C.Powers[id].Color, Moves = {
			table.clone(C.Powers.Sword.Moves[1]), table.clone(C.Powers[id].Moves[2]),
			{ Name = id .. " Blade Burst", Kind = "Signature", Damage = 25, Cooldown = 14, Range = 18, Stun = 0.5, PvpDamage = 1, PvpCooldown = 1, PvpStun = 1 },
		} }
end

function C.Fusion(a, b)
	if not a or not b then
		return nil
	end
	local pair = { a, b }
	table.sort(pair)
	return C.Fusions[table.concat(pair, "+")]
end
return C
