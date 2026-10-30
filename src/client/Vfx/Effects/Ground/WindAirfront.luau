-- Wind E Airfront. The server move is a forward push cone (range and width from the move config), so the picture
-- is a gust that pushes outward: three curled mint fronts sweep along the cone with leaves, speed streaks and
-- puffs, after a streaked ground warning. It never draws anything behind the caster.
local Fx = require(script.Parent.Fx)
local ease, place = Fx.ease, Fx.place

return function(ctx)
	local c = ctx.c
	local range = ctx.def.Range
	local width = ctx.radius * 2
	local fronts = ctx.meshes(3, "WindFront", { c.Body, c.Highlight, c.Body }, Fx.NEON, 0.25)
	local leaves = ctx.meshes(6, "Leaf", { Color3.fromRGB(104, 181, 74) }, Fx.SMOOTH, 0)
	local warn = {}
	for i = 1, 5 do
		warn[i] = ctx.part(Enum.PartType.Block, c.Highlight, Fx.NEON, 1)
	end
	-- Thin speed streaks along the cone (anime-slick accent over the chunky fronts).
	local streaks = {}
	for i = 1, 7 do
		streaks[i] = ctx.part(Enum.PartType.Block, Fx.WHITE, Fx.NEON, 1)
	end
	local trail = ctx.anchor(ctx.caster, 2)
	local puff = Fx.puffs(trail, Fx.WHITE, c.Body, 2.4, { SpreadAngle = Vector2.new(25, 25), Drag = 2, Shape = Enum.ParticleEmitterShape.Box })
	local cf0 = CFrame.lookAt(ctx.caster, ctx.caster + ctx.dir)
	local started = false
	return function(p)
		if not p.active then
			-- Radial warning lines across the real hit fan (server test: within range and dot > 0.6, about 53 degrees each side).
			for i, line in warn do
				local angle = math.rad((i - 3) * 26)
				place(line, cf0 * CFrame.Angles(0, -angle, 0) * CFrame.new(0, 0.12, -range * 0.5), Vector3.new(0.18 + 0.2 * p.charge, 0.08, range * 0.9),
					0.3 + 0.5 * p.charge, 0.2)
			end
			return true
		end
		if not started then
			started = true
			puff.Rate = 36
			ctx.bump(0.025)
		end
		Fx.hide(warn)
		for i, front in fronts do
			local k = ease((p.t - (i - 1) * 0.1) / 0.5)
			local d = 2 + k * (range - 2)
			local w = math.min(1.6 * d * 0.92, width * 1.5) -- chord of the hit fan at this distance
			place(front, cf0 * CFrame.new(0, 1.2 + i * 0.7 + math.sin(p.t * 8 + i) * 0.35, -d) * CFrame.Angles(0, 0, math.sin(p.t * 6 + i) * 0.08),
				Vector3.new(w, 2.4, 1.0), p.fade * (1 - k * 0.6), 0.25)
		end
		for i, streak in streaks do
			local lateral = (i - 4) * width * 0.11
			local k = ease((p.t - 0.02 * i) / 0.4)
			local head = 2 + k * (range - 2)
			local length = 2.6 + (i % 3)
			place(streak, cf0 * CFrame.new(lateral, 1.0 + (i % 3) * 0.7, -head + length * 0.5), Vector3.new(0.1, 0.1, length), p.fade * (1 - k * 0.7), 0.1)
		end
		for i, leaf in leaves do
			local k = ease((p.t - i * 0.03) / 0.55)
			place(leaf, cf0 * CFrame.new((i - 3.5) * 1.6 * (0.4 + k), 1.4 + math.sin(p.t * 9 + i * 2) * 0.8, -k * range) * CFrame.Angles(p.t * 9 + i, p.t * 7, 0),
				Vector3.new(1.1, 0.3, 1.8), p.fade, 0)
		end
		trail.CFrame = cf0 * CFrame.new(0, 0.5, -ease(p.t / 0.5) * range)
		puff.Rate = 36 * p.fade
		return true
	end
end
