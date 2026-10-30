-- Shadow E Snare. Concept: a small violet sigil on the ground, one thick glossy ribbon curls up in loops, then coils
-- into soft stacked rings around the target's ankles; white puffs and orbs around it. No black smoke. The ribbon and
-- the ring stack are Codex meshes (RibbonLoop, RingStack).
local Fx = require(script.Parent.Fx)
local ease, backOut, place, orbit = Fx.ease, Fx.backOut, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local sigil, sigilInner = ctx.ring(c.Body, 12, 0.3), ctx.ring(c.Highlight, 6)
	local runes = ctx.dashRing(c.Highlight, 8, 0.09, 0.03)
	local ribbonA = ctx.mesh("RibbonLoop", c.Body, Fx.SMOOTH, 0.05)
	local ribbonB = ctx.mesh("RibbonLoop", c.Highlight, Fx.NEON, 0.25)
	local coil = ctx.mesh("RingStack", c.Body, Fx.SMOOTH, 0.05)
	local coilGlow = ctx.mesh("RingStack", c.Highlight, Fx.NEON, 0.35)
	local orbs = {}
	for i = 1, 3 do
		orbs[i] = ctx.part(Enum.PartType.Ball, c.Highlight, Fx.NEON, 0.15)
	end
	local anchor = ctx.anchor(ctx.center, r * 1.2)
	local puffs = Fx.puffs(anchor, Fx.WHITE, c.Highlight, 2.0, { SpreadAngle = Vector2.new(60, 60), Drag = 2, Shape = Enum.ParticleEmitterShape.Box })
	local sparkles = Fx.stars(anchor, c.Highlight, 0.9, NumberRange.new(5, 10), { Shape = Enum.ParticleEmitterShape.Box })
	local started = false
	return function(p)
		if not p.active then
			sigil.set(ctx.center, r * 2, 0.35 + 0.5 * p.charge)
			sigilInner.set(ctx.center, r * 2 * 0.55, 0.25 + 0.6 * p.charge)
			runes.set(ctx.center, r * 2 * 0.8, 0.3 + 0.6 * p.charge, p.elapsed * -50)
			-- A small ribbon sprout curls up from the sigil.
			local s = 0.12 + 0.28 * p.charge
			place(ribbonA, CFrame.new(ctx.center + Vector3.new(0, 4 * s, 0)) * CFrame.Angles(0, p.elapsed * 2, 0), Vector3.new(6, 8, 4) * s, 1, 0.05)
			if ribbonB then
				ribbonB.Transparency = 1
			end
			Fx.hide({ coil, coilGlow })
			Fx.hide(orbs)
			return true
		end
		if not started then
			started = true
			puffs.Rate, sparkles.Rate = 16, 6
			ctx.bump(0.025)
		end
		sigil.set(ctx.center, r * 2, 0.55 * p.fade)
		sigilInner.set(ctx.center, r * 2 * 0.55, 0.35 * p.fade)
		runes.set(ctx.center, r * 2 * 0.8, 0.7 * p.fade, p.t * -60)
		local rise = backOut(p.t / 0.3)
		local wrap = ease((p.t - 0.35) / 0.35)
		-- Ribbons rise and twist, then collapse downward as the coil forms.
		local height = 8 * rise * (1 - 0.82 * wrap)
		local width = (r * 0.95) * (1 - 0.5 * wrap)
		place(ribbonA, CFrame.new(ctx.center + Vector3.new(0, height * 0.5, 0)) * CFrame.Angles(0, p.t * 3, 0),
			Vector3.new(width, math.max(height, 0.1), width * 0.67), p.fade * (1 - wrap), 0.05)
		place(ribbonB, CFrame.new(ctx.center + Vector3.new(0, height * 0.5, 0)) * CFrame.Angles(0, -p.t * 2.4 + 2, 0),
			Vector3.new(width * 0.85, math.max(height * 0.92, 0.1), width * 0.58), p.fade * (1 - wrap), 0.25)
		-- The coil of stacked rings closes around the ankles (the snared target stands in the opening).
		local ring = backOut((p.t - 0.4) / 0.25)
		local size = math.min(r * 0.9, 5) / 2.3
		place(coil, CFrame.new(ctx.center + Vector3.new(0, 1.4 * size * math.max(ring, 0.05), 0)) * CFrame.Angles(0, p.t * 1.5, 0),
			Vector3.new(4.6, 2.8, 4.6) * size * math.max(ring, 0.02), p.fade * math.clamp(ring, 0, 1), 0.05)
		place(coilGlow, CFrame.new(ctx.center + Vector3.new(0, 1.4 * size * math.max(ring, 0.05), 0)) * CFrame.Angles(0, p.t * 1.5, 0),
			Vector3.new(4.6, 2.8, 4.6) * size * math.max(ring, 0.02) * 1.08, p.fade * math.clamp(ring, 0, 1), 0.35)
		for i, orb in orbs do
			place(orb, CFrame.new(ctx.center + orbit(i * 2.1 + p.t * 3, r * 0.85) + Vector3.new(0, 1.5 + math.sin(p.t * 5 + i) * 0.5, 0)), Vector3.one * 0.9, p.fade, 0.15)
		end
		puffs.Rate = 16 * p.fade
		return true
	end
end
