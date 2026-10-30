-- Earth E Stone Field. Concept: golden dashed ring on dusty ground with small pebbles, then chunky faceted stones
-- of mixed sizes shove up out of the ground in a stagger with dust puffs, and stay low (nothing blocks sight).
local Fx = require(script.Parent.Fx)
local ease, backOut, place, orbit = Fx.ease, Fx.backOut, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local dashed, patch = ctx.dashRing(c.Highlight, 20, 0.1, 0.03), ctx.ring(c.Body, 6, 0.2)
	-- Mixed sizes: a few tall boulders in the middle ring, medium stones around them, small pebbles scattered.
	local stones = {}
	local function add(size, dist, angle, delay, tint, meshName)
		local part = ctx.mesh(meshName or "Rock", tint, Fx.SMOOTH, 0)
		if part then
			table.insert(stones, { part = part, pos = ctx.center + orbit(angle, dist), size = size, delay = delay, yaw = angle * 3 })
		end
	end
	for i = 1, 3 do
		add(Vector3.new(3.8, 5.6, 3.6), r * 0.3, i * 2.1 + 0.4, 0.02 * i, c.Body, "StoneTall")
	end
	for i = 1, 6 do
		add(Vector3.new(2.8, 3.2, 2.6), r * 0.62, i * 1.05 + 0.2, 0.05 + 0.025 * i, i % 2 == 0 and c.Highlight or c.Body)
	end
	for i = 1, 7 do
		add(Vector3.new(1.2, 1.1, 1.1), r * (0.45 + 0.4 * ((i * 0.37) % 1)), i * 0.9, 0.08 + 0.02 * i, c.Shade)
	end
	local cracks = {}
	for i = 1, 6 do
		cracks[i] = ctx.part(Enum.PartType.Block, Color3.fromRGB(88, 56, 30), Fx.SMOOTH, 1)
	end
	local anchor = ctx.anchor(ctx.center, r * 1.3)
	local dust = Fx.puffs(anchor, Color3.fromRGB(240, 226, 200), Color3.fromRGB(185, 150, 100), 2.6, { SpreadAngle = Vector2.new(70, 70), Drag = 3, Shape = Enum.ParticleEmitterShape.Box })
	local chips = Fx.stars(anchor, c.Highlight, 1.0, NumberRange.new(10, 18), { SpreadAngle = Vector2.new(60, 60), Shape = Enum.ParticleEmitterShape.Box })
	local started = false
	return function(p)
		if not p.active then
			dashed.set(ctx.center, r * 2, 0.45 + 0.45 * p.charge, p.elapsed * 15)
			patch.set(ctx.center, r * 2, 0.35 + 0.4 * p.charge)
			-- A few pebbles tremble early so the field reads as about to erupt.
			for i, stone in stones do
				if stone.size.Y < 2 then
					place(stone.part, CFrame.new(stone.pos + Vector3.new(0, 0.3 + 0.1 * math.sin(p.elapsed * 30 + i), 0)), stone.size * 0.5 * p.charge, 1, 0)
				else
					stone.part.Transparency = 1
				end
			end
			return true
		end
		if not started then
			started = true
			dust:Emit(22)
			chips:Emit(8)
			ctx.bump(0.035)
		end
		dashed.set(ctx.center, r * 2, 0.7 * p.fade, p.t * 20)
		patch.set(ctx.center, r * 2, 0.55 * p.fade)
		for i, crack in cracks do
			local a = i * 1.047
			local len = r * 0.55 * ease(p.t / 0.2)
			place(crack, CFrame.new(ctx.center + orbit(a, len * 0.6) + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, -a, 0), Vector3.new(len, 0.06, 0.22), p.fade * math.max(0, 1 - p.t * 1.1), 0)
		end
		local sink = ease((p.t - 0.6) / 0.3)
		for _, stone in stones do
			local k = backOut((p.t - stone.delay) / 0.24)
			local rise = k * (1 - sink)
			local height = stone.size.Y
			place(stone.part, CFrame.new(stone.pos + Vector3.new(0, height * (rise - 1) * 0.5 + 0.25, 0)) * CFrame.Angles(0, stone.yaw, 0.1 * (1 - rise)),
				stone.size * math.clamp(0.35 + 0.65 * rise, 0.2, 1.3), 1, 0)
		end
		return true
	end
end
