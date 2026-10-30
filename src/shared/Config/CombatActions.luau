-- One-handed sword clips (BE_SwordRig_SwordOneHand, build_sword_rig.py --onehand; owner-approved concept
-- docs/reference/sword-m1-onehand-concepts-v1-2026-10-29). Every sword power shares them. Earlier sets: the first
-- one-handed BE_SwordM1_Sword M1 114620290008582 / 130582779017206 / 90936461621693 (moving 95184168951056 /
-- 83617632377530 / 95335351109250) and the two-handed set 129293301004480 / 130407320980475 / 105576524921428
-- (moving 82490956624816 / 77362148225584 / 140518167709606, Ready 107881919413642, ReadyMoving 107127975680104).
local SWORD_CLIPS = {
	Animations = { M1_1 = "rbxassetid://72670018414017", M1_2 = "rbxassetid://118829196559938", M1_3 = "rbxassetid://129888720665241" },
	MovingAnimations = { M1_1 = "rbxassetid://112378455881304", M1_2 = "rbxassetid://120156129228871", M1_3 = "rbxassetid://131711130057198" },
	Ready = "rbxassetid://122687599909505", -- looping one-handed carry (standing)
	ReadyMoving = "rbxassetid://74205099586374", -- same carry, upper body only, while running or airborne
}

local config = {
	Animations = { M1_1 = "rbxassetid://124340796371674", M1_2 = "rbxassetid://137589820930478",
		M1_3 = "rbxassetid://97511758227791", Dash = "rbxassetid://108163526893560" },
	MovingAnimations = { M1_1 = "rbxassetid://99026701617574", M1_2 = "rbxassetid://132325822094557",
		M1_3 = "rbxassetid://140611227228767" },
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
