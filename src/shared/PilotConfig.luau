-- Prototype values only: balance, move names and cosmetics need owner playtesting.
local C = {
	MatchSeconds = 90, IntermissionSeconds = 12, ResultsSeconds = 8,
	MaxHealth = 100, WalkSpeed = 20, BotFill = 0, --[[ bots paused for VFX review 2026-10-28; was 4 ]] BanditRespawn = 8,
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
local MoveSets = require(script.Parent.Config.PowerMoves)
local Visuals = require(script.Parent.Config.PowerVisuals)
for id, moves in MoveSets do
    C.Powers[id] = { Color = Visuals.Powers[id].Body, Name = Visuals.Powers[id].DisplayName, Moves = moves }
end
for _, id in C.BaseIds do
    local pair = { "Sword", id }
    table.sort(pair)
    C.Fusions[table.concat(pair, "+")] = "Sword_" .. id
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
