-- Dispatcher for the E and R presentations. Each move is its own module in Ground/, designed from its own concept
-- image; this file only picks one and runs it. Presentation only: the server owns hit areas, damage and timing.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Kit = require(script.Parent.Parent.Kit)
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local Fx = require(script.Parent.Ground.Fx)

local MOVES = {
	Wind = { E = script.Parent.Ground.WindAirfront, R = script.Parent.Ground.WindCyclone },
	Earth = { E = script.Parent.Ground.EarthStoneField, R = script.Parent.Ground.EarthQuake },
	Water = { E = script.Parent.Ground.WaterWhirlpool, R = script.Parent.Ground.WaterTidalWave },
	Fire = { E = script.Parent.Ground.FireFlameField, R = script.Parent.Ground.FireEruption },
	Sword = { E = script.Parent.Ground.SwordRisingSlash, R = script.Parent.Ground.SwordBladeStorm },
	Shadow = { E = script.Parent.Ground.ShadowSnare, R = script.Parent.Ground.ShadowNightfall },
}

local Ground = {}

function Ground.Supports(power, key)
	return MOVES[power] ~= nil and MOVES[power][key] ~= nil
end

function Ground.Play(data, look)
	local module = MOVES[data.Power] and MOVES[data.Power][data.Key]
	local c = Visuals.Powers[data.Power]
	if not module or not c or look.distanceFactor == 0 then
		return nil
	end
	local group = Instance.new("Folder")
	group.Name = "Ground_" .. data.Token
	group.Parent = Kit.folder()
	Debris:AddItem(group, data.Duration + 2)
	local ctx = Fx.context(data, look, group, c)
	local update = require(module)(ctx)
	local e = { group = group, position = ctx.center, caster = data.Caster, partCount = ctx.parts, meshFallbacks = ctx.fallback }
	function e:Destroy()
		if self.destroyed then
			return
		end
		self.destroyed = true
		group:Destroy()
	end
	function e:Release() end
	function e:Stop(impact)
		if not impact then
			self:Destroy()
		end
	end
	function e:Update(now)
		if self.destroyed or not group.Parent then
			return false
		end
		local elapsed = math.max(0, now - data.StartedAt)
		if now > data.StartedAt + data.Duration + 0.25 then
			return false
		end
		local delay = data.Delay or 0.3
		local active = elapsed >= delay
		return update({
			now = now, elapsed = elapsed, charge = math.clamp(elapsed / math.max(0.01, delay), 0, 1),
			active = active, t = active and elapsed - delay or 0,
			fade = math.clamp((data.StartedAt + data.Duration - now) / 0.3, 0, 1),
		})
	end
	return e
end

return Ground
