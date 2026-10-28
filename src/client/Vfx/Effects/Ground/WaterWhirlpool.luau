-- Water E Whirlpool. Concept: a shallow broad blue basin, thick spiral arms of water turning inward, foam at the rim,
-- droplets flicking up. Footprint is the server field radius; inward motion sells the pull.
local Fx = require(script.Parent.Fx)
local ease, place, orbit = Fx.ease, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local basin, deep = ctx.ring(c.Body, 16, 0.55), ctx.ring(c.Shade, 8, 0.3)
	local outline = ctx.ring(Fx.WHITE, 8)
	-- Three spiral arms drawn as chains of beads shrinking toward the centre.
	local arms = {}
	for a = 1, 3 do
		for i = 1, 8 do
			local bead = ctx.part(Enum.PartType.Ball, i % 2 == 0 and c.Highlight or Fx.WHITE, Fx.SMOOTH, 0.05)
			table.insert(arms, { part = bead, arm = a, u = (i - 1) / 7 })
		end
	end
	local foam = {}
	for i = 1, 10 do
		foam[i] = ctx.part(Enum.PartType.Ball, Fx.WHITE, Fx.SMOOTH, 0)
	end
	local anchor = ctx.anchor(ctx.center, r * 0.6)
	local splash = Fx.puffs(anchor, Fx.WHITE, c.Highlight, 2.0, { SpreadAngle = Vector2.new(60, 60), Drag = 2, Shape = Enum.ParticleEmitterShape.Box })
	local drops = Fx.stars(anchor, c.Body, 0.9, NumberRange.new(8, 14), { Shape = Enum.ParticleEmitterShape.Box })
	local started = false
	return function(p)
		if not p.active then
			outline.set(ctx.center, r * 2, 0.3 + 0.55 * p.charge)
			basin.set(ctx.center, r * 2 * ease(p.charge), 0.5 * p.charge)
			deep.set(ctx.center, 1, 0)
			for _, arm in arms do
				arm.part.Transparency = 1
			end
			Fx.hide(foam)
			return true
		end
		if not started then
			started = true
			splash.Rate, drops.Rate = 14, 5
			ctx.bump(0.02)
		end
		local grow = ease(p.t / 0.25)
		outline.set(ctx.center, r * 2 * grow, 0.85 * p.fade)
		basin.set(ctx.center, r * 2 * grow, 0.95 * p.fade)
		deep.set(ctx.center, r * 1.1 * grow, 0.85 * p.fade)
		for _, arm in arms do
			local angle = arm.arm * math.pi * 2 / 3 + arm.u * 2.7 - p.t * 3.2
			local radius = r * (0.92 - 0.78 * arm.u) * grow
			local size = (1.5 - 0.9 * arm.u) * grow
			place(arm.part, CFrame.new(ctx.center + orbit(angle, radius) + Vector3.new(0, 0.3, 0)), Vector3.new(size, size * 0.7, size), p.fade, 0.05)
		end
		for i, bead in foam do
			local angle = i * math.pi * 2 / #foam + p.t * 1.6
			local radius = r * (0.99 + 0.03 * math.sin(p.t * 8 + i))
			place(bead, CFrame.new(ctx.center + orbit(angle, radius) + Vector3.new(0, 0.5 + 0.3 * math.sin(p.t * 9 + i * 2), 0)),
				Vector3.new(1.8, 1.4, 1.8) * grow, p.fade, 0)
		end
		splash.Rate = 14 * p.fade
		return true
	end
end
