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
	return move(name, "Projectile", damage, 2.2, range, speed >= 60 and 2 or 2.5, 0.18, 0, { Speed = speed, Inhaleable = true })
end
return {
	Wind = {
		shot("Gust", 11, 65, 60),
		move("Airfront", "Cone", 8, 7, 23, 11.7, 0.25, 0.1, { Push = 24 }),
		move("Roaming Cyclone", "Wave", 24, 14, 39, 10.4, 0.65, 0.3, { Speed = 16, Pull = 18 }),
	},
	Earth = {
		shot("Rock Shot", 14, 42, 48),
		move("Stone Field", "Field", 10, 8, 20, 15.6, 0.4, 0.35),
		move("Quake", "Area", 28, 16, 18, 23.4, 0.8, 0.45, { Lift = 18 }),
	},
	Water = {
		shot("Water Shot", 12, 58, 58),
		move("Whirlpool", "Field", 8, 7, 21, 15.6, 0.3, 0.15, { Pull = 22 }),
		move("Tidal Wave", "Wave", 24, 14, 47, 13, 0.6, 0.25, { Speed = 30, Push = 22 }),
	},
	Fire = {
		shot("Fireball", 14, 52, 55),
		move("Flame Field", "Field", 9, 7, 21, 14.3, 0.3, 0, { Pulses = 3 }),
		move("Meteor Strike", "Projectile", 29, 15, 46, 6.5, 0.8, 0.35, { Speed = 34, Lift = 16 }),
	},
	Sword = {
		shot("Traveling Slash", 13, 60, 34),
		move("Flash Step", "Dash", 12, 7, 21, 7.8, 0.2, 0.25, { DashTime = 0.22, Lift = 22 }),
		move("Blade Storm", "Area", 27, 14, 12, 16.9, 0.55, 0.15, { Pulses = 3 }),
	},
	Shadow = {
		shot("Shadow Shot", 12, 46, 60),
		move("Shadow Snare", "Field", 9, 8, 25, 13, 0.6, 0.45),
		move("Umbral Blink", "Dash", 30, 16, 31, 9.1, 0.6, 0.4, { DashTime = 0.12 }),
	},
	Sword_Wind = {
		shot("Gale Edge", 12, 72, 42),
		move("Gale Rush", "Dash", 15, 7, 25, 7.8, 0.2, 0.1, { DashTime = 0.2, Push = 22 }),
		move("Skywheel", "Projectile", 26, 14, 38, 7.2, 0.5, 0.2, { Speed = 30, Lift = 14 }),
	},
	Sword_Earth = {
		shot("Stone Edge", 15, 38, 38),
		move("Tremor Charge", "Dash", 18, 9, 18, 8.5, 0.35, 0.35, { DashTime = 0.26, Push = 14 }),
		move("Mountain Splitter", "Wave", 27, 17, 39, 10.4, 0.9, 0.4, { Speed = 24, Lift = 20 }),
	},
	Sword_Water = {
		shot("Foam Edge", 12, 60, 44),
		move("Tide Slide", "Dash", 14, 7, 22, 7.8, 0.2, 0.12, { DashTime = 0.24, Pull = 12 }),
		move("Undertow Waltz", "Area", 26, 14, 13, 18.2, 0.5, 0.15, { Pulses = 3, Pull = 12 }),
	},
	Sword_Fire = {
		shot("Ember Edge", 14, 54, 40),
		move("Blaze Lunge", "Dash", 16, 8, 22, 7.8, 0.25, 0.1, { DashTime = 0.22 }),
		move("Furnace Cleave", "Wave", 30, 16, 39, 11.7, 0.7, 0.25, { Speed = 32, Push = 18 }),
	},
	Sword_Shadow = {
		shot("Dusk Edge", 13, 48, 48),
		move("Umbra Step", "Dash", 18, 8, 26, 7.8, 0.35, 0.25, { DashTime = 0.2 }),
		move("Eclipse Execution", "Field", 29, 17, 21, 15.6, 0.95, 0.4),
	},
	Sword_Sword = {
		shot("Crown Slash", 15, 48, 42),
		move("Crown Rush", "Dash", 17, 9, 23, 8.5, 0.3, 0.3, { DashTime = 0.22, Lift = 24 }),
		move("Grand Cleave", "Wave", 28, 18, 42, 11.7, 0.9, 0.4, { Speed = 28, Push = 24 }),
	},
}
