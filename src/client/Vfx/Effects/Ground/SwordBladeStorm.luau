-- Sword R Blade Storm. Concept: a segmented white ground ring, then several chunky rounded silver blades orbit and
-- sweep in a compact circle around the caster with white wind trails, stars and a flash ring.
local Fx = require(script.Parent.Fx)
local ease, backOut, place, orbit = Fx.ease, Fx.backOut, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local center = ctx.caster
	local segments, inner = ctx.dashRing(Fx.WHITE, 12, 0.13, 0.034), ctx.dashRing(c.Highlight, 8, 0.1, 0.028)
	local slashRing = ctx.ring(Fx.WHITE, 24)
	local blades = {}
	for i = 1, 5 do
		local blade = ctx.mesh("Sword", Color3.fromRGB(240, 245, 252), Fx.SMOOTH, 0)
		if blade then
			local trailPart = ctx.anchor(center, 0.4)
			table.insert(blades, { part = blade, trail = trailPart, puff = Fx.puffs(trailPart, Fx.WHITE, c.Highlight, 1.8, { SpreadAngle = Vector2.new(15, 15), Drag = 2 }),
				phase = i * math.pi * 2 / 5, tier = i % 2 })
		end
	end
	local burst = ctx.anchor(center, 2)
	local pop = Fx.stars(burst, Fx.WHITE, 1.4, NumberRange.new(14, 24), { SpreadAngle = Vector2.new(180, 180) })
	local started = false
	return function(p)
		if not p.active then
			segments.set(center, r * 2, 0.45 + 0.5 * p.charge, p.elapsed * 30)
			inner.set(center, r * 2 * (1 - 0.4 * p.charge), 0.25 + 0.6 * p.charge, p.elapsed * -45)
			slashRing.set(center, 1, 0)
			for _, blade in blades do
				blade.part.Transparency = 1
			end
			return true
		end
		if not started then
			started = true
			for _, blade in blades do
				blade.puff.Rate = 40
			end
			pop:Emit(10)
			ctx.bump(0.04)
		end
		segments.set(center, r * 2, 0.55 * p.fade, p.t * 90)
		inner.set(center, r * 2 * 0.62, 0.3 * p.fade, p.t * -120)
		local k = ease(p.t / 0.18)
		local spin = p.t * 12 + backOut(p.t / 0.3)
		slashRing.set(center, r * 2 * 0.86 * k, (1 - k * 0.7) * p.fade * 0.85)
		local retract = ease((p.t - 0.55) / 0.3)
		for _, blade in blades do
			local angle = spin + blade.phase
			local pos = center + orbit(angle, r * (0.55 + 0.2 * blade.tier) * k * (1 - 0.6 * retract)) + Vector3.new(0, 1.6 + blade.tier * 1.2 + math.sin(p.t * 8 + blade.phase) * 0.4, 0)
			local tangent = Vector3.new(-math.sin(angle), 0, math.cos(angle))
			local radial = Vector3.new(math.cos(angle), 0, math.sin(angle))
			-- Blade lies flat along the tangent; fat and chunky, tip leading the sweep.
			place(blade.part, CFrame.fromMatrix(pos, radial, tangent), Vector3.new(2.0, 7.0, 1.3) * math.max(k, 0.05), p.fade, 0)
			blade.trail.CFrame = CFrame.new(pos - tangent * 2)
			blade.puff.Rate = 40 * p.fade * (1 - retract)
		end
		return true
	end
end
