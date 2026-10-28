-- Prototype tuning: distinct jobs per kit; all Q attacks are inhaleable projectiles.
local function move(name, kind, damage, cooldown, range, radius, delay, stun, extra)
	local result = { Name = name, Kind = kind, Damage = damage, Cooldown = cooldown, Range = range,
		Radius = radius, Delay = delay, Stun = stun, PvpDamage = 1, PvpCooldown = 1, PvpStun = 1 }
	for key, value in extra or {} do
		result[key] = value
	end
	return result
end
local function shot(name, damage, speed, range)
	return move(name, "Projectile", damage, 2.2, range, 2.5, 0.18, 0, { Speed = speed, Inhaleable = true })
end
return {
	Wind = {
		shot("Gust", 11, 65, 60),
		move("Airfront", "Cone", 8, 7, 14, 9, 0.25, 0.1, { Push = 24 }),
		move("Cyclone", "Field", 24, 14, 13, 10, 0.65, 0.3, { Pull = 18 }),
	},
	Earth = {
		shot("Rock Shot", 16, 42, 48),
		move("Stone Field", "Field", 10, 8, 12, 8, 0.4, 0.35),
		move("Quake", "Area", 28, 16, 14, 14, 0.8, 0.45, { Lift = 18 }),
	},
	Water = {
		shot("Water Shot", 12, 58, 58),
		move("Whirlpool", "Field", 8, 7, 14, 8, 0.3, 0.15, { Pull = 22 }),
		move("Tidal Wave", "Wave", 24, 14, 30, 7, 0.6, 0.25, { Speed = 30, Push = 22 }),
	},
	Fire = {
		shot("Fireball", 14, 52, 55),
		move("Flame Field", "Field", 9, 7, 13, 7, 0.3, 0, { Pulses = 3 }),
		move("Eruption", "Field", 29, 15, 15, 9, 0.8, 0.35, { Lift = 16 }),
	},
	Sword = {
		shot("Traveling Slash", 13, 60, 34),
		move("Rising Slash", "Cone", 12, 7, 7, 5, 0.22, 0.25, { Lift = 26 }),
		move("Blade Storm", "Area", 27, 14, 9, 9, 0.55, 0.15, { Pulses = 3 }),
	},
	Shadow = {
		shot("Shadow Shot", 12, 46, 60),
		move("Shadow Snare", "Field", 9, 8, 17, 6, 0.6, 0.45),
		move("Nightfall", "Field", 30, 16, 20, 10, 1, 0.4),
	},
	Sword_Wind = {
		shot("Gale Edge", 12, 72, 42),
		move("Crosswind Cut", "Cone", 15, 7, 10, 6, 0.22, 0.1, { Push = 26 }),
		move("Skywheel", "Area", 26, 14, 11, 11, 0.5, 0.2, { Pulses = 2, Lift = 14 }),
	},
	Sword_Earth = {
		shot("Stone Edge", 17, 38, 38),
		move("Fault Cleave", "Cone", 18, 9, 10, 5, 0.55, 0.35, { Push = 16 }),
		move("Mountain Splitter", "Wave", 32, 17, 25, 5, 0.9, 0.4, { Speed = 24, Lift = 20 }),
	},
	Sword_Water = {
		shot("Foam Edge", 12, 60, 44),
		move("Flowing Cut", "Cone", 14, 7, 9, 6, 0.25, 0.12, { Pull = 14 }),
		move("Undertow Waltz", "Area", 26, 14, 10, 10, 0.5, 0.15, { Pulses = 3, Pull = 12 }),
	},
	Sword_Fire = {
		shot("Ember Edge", 14, 54, 40),
		move("Branding Cleave", "Cone", 16, 8, 8, 6, 0.3, 0.1, { Pulses = 2 }),
		move("Furnace Cleave", "Wave", 30, 16, 24, 6, 0.7, 0.25, { Speed = 32, Push = 18 }),
	},
	Sword_Shadow = {
		shot("Dusk Edge", 13, 48, 48),
		move("Echo Cut", "Cone", 18, 8, 10, 6, 0.65, 0.25, { Pulses = 2 }),
		move("Eclipse Execution", "Field", 31, 17, 14, 8, 0.95, 0.4),
	},
	Sword_Sword = {
		shot("Crown Slash", 16, 48, 42),
		move("Rising Cleave", "Cone", 18, 9, 8, 6, 0.4, 0.3, { Lift = 30 }),
		move("Grand Cleave", "Wave", 34, 18, 26, 6, 0.9, 0.4, { Speed = 28, Push = 24 }),
	},
}
