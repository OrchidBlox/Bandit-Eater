-- One-handed sword clips (BE_SwordRig_SwordOneHand, build_sword_rig.py --onehand; owner-approved concept
-- docs/reference/sword-m1-onehand-concepts-v1-2026-10-29). Every sword power shares them. Earlier sets: the first
-- one-handed BE_SwordM1_Sword M1 114620290008582 / 130582779017206 / 90936461621693 (moving 95184168951056 /
-- 83617632377530 / 95335351109250) and the two-handed set 129293301004480 / 130407320980475 / 105576524921428
-- (moving 82490956624816 / 77362148225584 / 140518167709606, Ready 107881919413642, ReadyMoving 107127975680104).
-- FK-authored one-hand set (BE_SwordRig_SwordFK, roblox-animation method, 2026-10-30). Previous sets: one-hand IK 72670018414017 / 118829196559938 / 129888720665241
-- (moving 112378455881304 / 120156129228871 / 131711130057198, Ready 122687599909505, ReadyMoving 74205099586374); two-handed and first one-hand sets are listed in docs/animations.md.
local SWORD_CLIPS = {
	Animations = { M1_1 = "rbxassetid://119520592714669", M1_2 = "rbxassetid://100756639062539", M1_3 = "rbxassetid://93441918066279" },
	MovingAnimations = { M1_1 = "rbxassetid://77163557845826", M1_2 = "rbxassetid://133044354208208", M1_3 = "rbxassetid://105123217295450" },
	Ready = "rbxassetid://78784924631632", -- looping one-handed carry (standing), FK-authored
	ReadyMoving = "rbxassetid://138484378702206", -- same carry, upper body only, while running or airborne
}

local config = {
	-- FK fist combo (build_sword_rig.py --fist, roblox-animation method, 2026-10-30). Earlier IDs: 124340796371674 / 137589820930478 / 97511758227791 (moving 99026701617574 / 132325822094557 / 140611227228767).
	Animations = { M1_1 = "rbxassetid://114840764499664", M1_2 = "rbxassetid://127305833965693",
		M1_3 = "rbxassetid://115635517184706", Dash = "rbxassetid://108163526893560" },
	MovingAnimations = { M1_1 = "rbxassetid://106984870383750", M1_2 = "rbxassetid://100916820549531",
		M1_3 = "rbxassetid://96312761722418" },
	-- Every sword power shares the sword clip set above. Same lengths and strike times as the fist combo.
	SwordM1 = {},
	Durations = { M1_1 = 18 / 30, M1_2 = 18 / 30, M1_3 = 20 / 30, Dash = 15 / 30 },
	StrikeTimes = { M1_1 = 6 / 30, M1_2 = 6 / 30, M1_3 = 7 / 30 },
	DashBurstTime = 2 / 30,
	DashBrakeTime = 11 / 30,
	DashDistance = 20,
	DashCooldown = 3,
	DashInvulnerability = 0.2,
	M1Cooldown = 0.4,
	ComboReset = 1.2,
	Fade = 0.06,
	EffectDistance = 150,
	MaxEffects = 8,
	EffectLifetime = 0.4,
	MaxEventAge = 2,
}

for _, power in { "Sword", "Sword_Wind", "Sword_Earth", "Sword_Water", "Sword_Fire", "Sword_Shadow", "Sword_Sword" } do
	config.SwordM1[power] = SWORD_CLIPS
end

return config
