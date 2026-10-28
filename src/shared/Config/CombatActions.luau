local SWORD_CLIPS = {
	Animations = { M1_1 = "rbxassetid://129293301004480", M1_2 = "rbxassetid://130407320980475", M1_3 = "rbxassetid://105576524921428" },
	MovingAnimations = { M1_1 = "rbxassetid://82490956624816", M1_2 = "rbxassetid://77362148225584", M1_3 = "rbxassetid://140518167709606" },
	Ready = "rbxassetid://107881919413642", -- looping two-handed ready stance (standing)
	ReadyMoving = "rbxassetid://107127975680104", -- same hold, upper body only, while running or airborne
}

local config = {
	Animations = { M1_1 = "rbxassetid://124340796371674", M1_2 = "rbxassetid://137589820930478",
		M1_3 = "rbxassetid://97511758227791", Dash = "rbxassetid://108163526893560" },
	MovingAnimations = { M1_1 = "rbxassetid://99026701617574", M1_2 = "rbxassetid://132325822094557",
		M1_3 = "rbxassetid://140611227228767" },
	-- Two-handed sword clips (BE_SwordRig_Sword, authored with the sword attached; build_sword_rig.py). Every sword
	-- power shares them (owner, 2026-10-28). Same lengths and strike times as the fist combo, so gameplay is unchanged.
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
