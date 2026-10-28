-- Shadow E Snare. Concept: a small violet sigil on the ground, then one thick glossy ribbon curls up in loops and
-- coils tight like stacked rings to wrap the target's ankles; white puffs and orbs around it. No black smoke.
local Fx = require(script.Parent.Fx)
local ease, backOut, place, orbit = Fx.ease, Fx.backOut, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local sigil, sigilInner = ctx.ring(c.Body, 12, 0.3), ctx.ring(c.Highlight, 6)
	local runes = ctx.dashRing(c.Highlight, 8, 0.09, 0.03)
	-- The ribbon is a chain of fat overlapping balls along a looping curve.
	local links = {}
	for i = 1, 28 do
		links[i] = ctx.part(Enum.PartType.Ball, i % 3 == 0 and c.Highlight or c.Body, Fx.SMOOTH, 0.05)
	end
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
			for i, link in links do
				local s = (i - 1) / (#links - 1)
				if s < 0.2 * p.charge + 0.02 then
					place(link, CFrame.new(ctx.center + Vector3.new(math.sin(s * 9) * 0.6, 0.3 + s * 9 * p.charge, math.cos(s * 9) * 0.6)), Vector3.one * 1.0, 1, 0.05)
				else
					link.Transparency = 1
				end
			end
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
		local reveal = ease(p.t / 0.3)
		-- Loops rise, then the whole ribbon tightens into a low coil around the centre (the ankle wrap).
		local coil = ease((p.t - 0.35) / 0.35)
		for i, link in links do
			local s = (i - 1) / (#links - 1)
			if s > reveal then
				link.Transparency = 1
			else
				local angle = s * math.pi * 5 + p.t * 3
				local loopR = r * (0.6 - 0.15 * s) * (1 - 0.62 * coil) * (0.55 + 0.45 * math.sin(s * math.pi))
				local height = (0.5 + s * 5.6) * (1 - 0.7 * coil)
				local size = (1.5 - 0.35 * s) * backOut(p.t / 0.25)
				place(link, CFrame.new(ctx.center + orbit(angle, math.max(loopR, 0.6)) + Vector3.new(0, height, 0)), Vector3.one * size, p.fade, 0.05)
			end
		end
		for i, orb in orbs do
			local angle = i * 2.1 + p.t * 3
			place(orb, CFrame.new(ctx.center + orbit(angle, r * 0.85) + Vector3.new(0, 1.5 + math.sin(p.t * 5 + i) * 0.5, 0)), Vector3.one * 0.9, p.fade, 0.15)
		end
		puffs.Rate = 16 * p.fade
		return true
	end
end
