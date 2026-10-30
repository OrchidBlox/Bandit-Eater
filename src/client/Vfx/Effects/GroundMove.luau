-- Dispatcher for the E and R presentations. Each move is its own module in Ground/, designed from its own concept
-- image; this file only picks one and runs it. Presentation only: the server owns hit areas, damage and timing.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Kit = require(script.Parent.Parent.Kit)
local Visuals = require(ReplicatedStorage.Shared.Config.PowerVisuals)
local Fx = require(script.Parent.Ground.Fx)

local G = script.Parent.Ground
local SlickGround = require(G.SlickGround)
local SlickWave = require(G.SlickWave)

-- Each entry is a Codex-mesh anime-slick config (ground = SlickGround, wave = SlickWave) with the older module as a
-- fallback that plays while the mesh is not installed in the place. Plain script entries are single modules.
local function ground(cfg, fallback)
	return { make = SlickGround.make, cfg = cfg, fallback = fallback }
end
local function wave(cfg, fallback)
	return { make = SlickWave.make, cfg = cfg, fallback = fallback }
end

local MOVES = {
	Wind = {
		E = wave({ mesh = "AirfrontFan", shape = Vector3.new(16, 1.2, 9), mode = "fan" }, G.WindAirfront),
		R = wave({ mesh = "CycloneColumn", shape = Vector3.new(7, 12, 7), mode = "column", spin = 5 }, G.WindCyclone),
	},
	Earth = {
		E = ground({ mesh = "StoneSpikes", shape = Vector3.new(6, 6, 6), mode = "ring", count = 7, inner = 4, height = 7, lean = 0.08, turn = 0.2, pulses = 1 }, G.EarthStoneField),
		R = ground({ mesh = "QuakePillars", shape = Vector3.new(9, 10, 9), mode = "ring", count = 6, inner = 3, height = 10, lean = 0.1, turn = 0, pulses = 2, ringFrac = 0.75, refRadius = 18 }, G.EarthQuake),
	},
	Water = {
		E = ground({ mesh = "WhirlpoolDisc", shape = Vector3.new(14, 1.5, 14), mode = "disc", turn = 1.2, pulses = 1 }, G.WaterWhirlpool),
		R = wave({ mesh = "TidalCrest", shape = Vector3.new(14, 8, 6), mode = "wall" }, G.WaterTidalWave),
	},
	Fire = { E = G.FireFlameField },
	Sword = {
		E = G.SwordDash,
		R = ground({ mesh = "FloatBlade", shape = Vector3.new(1, 6, 0.6), mode = "orbit", count = 10, height = 5, ringFrac = 0.7, turn = 3, refRadius = 13 }, G.SwordBladeStorm),
	},
	Shadow = {
		E = ground({ mesh = "SnareTendrils", shape = Vector3.new(8, 6, 8), mode = "ring", count = 5, inner = 3, height = 5.5, lean = 0.15, ringFrac = 0.6, turn = 0.8, pulses = 1 }, G.ShadowSnare),
		R = G.SwordDash,
	},
}
-- Sword fusions: E is the dash-slash (its own trail per power); R is each power's own finisher.
for _, fusion in { "Sword_Wind", "Sword_Earth", "Sword_Water", "Sword_Fire", "Sword_Shadow", "Sword_Sword" } do
	MOVES[fusion] = { E = G.SwordDash }
end
MOVES.Sword_Water.R = ground({ mesh = "WhirlpoolDisc", shape = Vector3.new(14, 1.5, 14), mode = "disc", turn = 2, pulses = 3 }, G.SwordBladeStorm)
MOVES.Sword_Earth.R = wave({ mesh = "SplitterRidge", shape = Vector3.new(6, 4, 10), mode = "row", count = 4 }, G.SwordCleaveWave)
MOVES.Sword_Fire.R = wave({ mesh = "FlameCluster", shape = Vector3.new(5, 9, 3), mode = "row", count = 4 }, G.SwordCleaveWave)
MOVES.Sword_Sword.R = wave({ mesh = "GoldWave", shape = Vector3.new(14, 5, 7), mode = "wall" }, G.SwordCleaveWave)
MOVES.Sword_Shadow.R = ground({ mesh = "EclipseDisc", shape = Vector3.new(12, 1, 12), mode = "disc", turn = 0.8, pulses = 1 }, G.ShadowNightfall)

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
	local update
	if typeof(module) == "table" then
		-- Slick config: use it when its mesh is installed, otherwise the older module.
		if Fx.hasMesh(module.cfg.mesh) then
			update = module.make(module.cfg)(ctx)
		else
			update = require(module.fallback)(ctx)
		end
	else
		update = require(module)(ctx)
	end
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
