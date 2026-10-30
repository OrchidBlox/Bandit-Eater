-- Earth R Quake. Concept: a committed stomp under the caster, cracks spidering across the ground, golden dashed
-- shock rings rolling outward, big rocks launched out and falling, dust puffs along the edge.
local Fx = require(script.Parent.Fx)
local ease, place, orbit = Fx.ease, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local center = ctx.caster
	local foot = ctx.dashRing(c.Highlight, 10, 0.16, 0.05)
	local warn = ctx.dashRing(c.Body, 22, 0.09, 0.025)
	local waves = { ctx.dashRing(c.Highlight, 26, 0.08, 0.035), ctx.dashRing(c.Body, 26, 0.08, 0.03), ctx.ring(c.Highlight, 16) }
	local crack = ctx.mesh("GroundCrack", Color3.fromRGB(88, 56, 30), Fx.SMOOTH, 1)
	local rocks = {}
	local function add(size, speed, angle, tint, hop)
		local part = ctx.mesh("Rock", tint, Fx.SMOOTH, 0)
		if part then
			table.insert(rocks, { part = part, size = size, speed = speed, angle = angle, hop = hop })
		end
	end
	for i = 1, 6 do
		add(Vector3.new(3.0, 2.7, 2.8), 0.55 + (i % 3) * 0.12, i * 1.05, i % 2 == 0 and c.Highlight or c.Body, 9)
	end
	for i = 1, 8 do
		add(Vector3.new(1.3, 1.1, 1.2), 0.4 + (i % 4) * 0.15, i * 0.8 + 0.3, c.Shade, 6)
	end
	local edge = ctx.anchor(center, 2)
	local dust = Fx.puffs(edge, Color3.fromRGB(240, 226, 200), Color3.fromRGB(185, 150, 100), 3.4, { SpreadAngle = Vector2.new(70, 70), Drag = 3 })
	local debris = Fx.stars(edge, c.Highlight, 1.1, NumberRange.new(10, 20), { SpreadAngle = Vector2.new(60, 60) })
	local started = false
	return function(p)
		if not p.active then
			foot.set(center, 4 + 3 * p.charge, 0.5 + 0.5 * p.charge, p.elapsed * -60)
			warn.set(center, r * 2, 0.2 + 0.35 * p.charge, p.elapsed * 12)
			for _, w in waves do
				w.set(center, 1, 0, 0)
			end
			place(crack, CFrame.new(center + Vector3.new(0, 0.12, 0)), Vector3.new(3 * p.charge, 0.25, 3 * p.charge), 1, 0)
			for _, rock in rocks do
				rock.part.Transparency = 1
			end
			return true
		end
		if not started then
			started = true
			ctx.bump(0.06)
		end
		local k = ease(p.t / 0.42)
		foot.set(center, 7 * (1 - k * 0.5), math.max(0, 1 - p.t * 3) * p.fade, 0)
		warn.set(center, r * 2, math.max(0, 0.55 - p.t) * p.fade, 0)
		for i, w in waves do
			local kk = ease((p.t - (i - 1) * 0.08) / 0.4)
			w.set(center, math.max(1, r * 2 * kk), (1 - kk) * p.fade * (i == 3 and 0.85 or 1), p.t * (i == 1 and 70 or -70))
		end
		place(crack, CFrame.new(center + Vector3.new(0, 0.12, 0)), Vector3.new(r * 1.9 * math.max(k, 0.05), 0.25, r * 1.9 * math.max(k, 0.05)),
			p.fade * math.clamp(1.6 - p.t, 0, 1), 0)
		edge.CFrame = CFrame.new(center + orbit(p.t * 14, r * k) + Vector3.new(0, 0.4, 0))
		local alive = p.t < 0.42
		dust.Rate, debris.Rate = alive and 70 or 0, alive and 16 or 0
		for _, rock in rocks do
			local travel = math.clamp(p.t / 0.8, 0, 1)
			local d = r * 0.92 * ease(travel) * rock.speed
			local hop = math.sin(travel * math.pi) * rock.hop
			place(rock.part, CFrame.new(center + orbit(rock.angle, d) + Vector3.new(0, 0.5 + hop, 0)) * CFrame.Angles(p.t * 6 + rock.angle, p.t * 4, 0),
				rock.size, p.fade, 0)
		end
		return true
	end
end
