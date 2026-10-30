-- Water E Whirlpool. Concept: a shallow broad blue basin with a foam rim and thick white spiral arms turning inward,
-- droplets flicking up. The hero is the Codex WhirlpoolBasin mesh (water and foam baked in); its footprint is the
-- server field radius, and rings and sprites sell the inward pull.
local Fx = require(script.Parent.Fx)
local Cartoon = require(script.Parent.Parent.Parent.Cartoon)
local ease, place, orbit = Fx.ease, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local outline, basin = ctx.ring(Fx.WHITE, 8), ctx.ring(c.Body, 16, 0.55)
	local pulls = { ctx.ring(c.Highlight, 7), ctx.ring(c.Highlight, 7), ctx.ring(Fx.WHITE, 5) }
	local hero = ctx.mesh("WhirlpoolBasin", Fx.WHITE, Fx.SMOOTH, 0, true)
	local sprites = {}
	for i = 1, 9 do
		local sprite = Cartoon.sprite(ctx.group, i % 3 == 0 and Fx.Textures.Star or Fx.Textures.Puff, i % 3 == 0 and c.Highlight or Fx.WHITE)
		if sprite then
			table.insert(sprites, sprite)
			ctx.parts += 1
		end
	end
	local anchor = ctx.anchor(ctx.center, r * 0.6)
	local splash = Fx.puffs(anchor, Fx.WHITE, c.Highlight, 2.0, { SpreadAngle = Vector2.new(60, 60), Drag = 2, Shape = Enum.ParticleEmitterShape.Box })
	local drops = Fx.stars(anchor, c.Body, 0.9, NumberRange.new(8, 14), { Shape = Enum.ParticleEmitterShape.Box })
	local started = false
	return function(p)
		if not p.active then
			outline.set(ctx.center, r * 2, 0.3 + 0.55 * p.charge)
			basin.set(ctx.center, r * 2 * ease(p.charge), 0.5 * p.charge)
			for _, ring in pulls do
				ring.set(ctx.center, 1, 0)
			end
			if hero then
				hero.Transparency = 1
			end
			return true
		end
		if not started then
			started = true
			splash.Rate, drops.Rate = 14, 5
			ctx.bump(0.02)
		end
		local grow = ease(p.t / 0.25)
		outline.set(ctx.center, r * 2 * grow, 0.5 * p.fade)
		basin.set(ctx.center, r * 2 * grow, 0.35 * p.fade)
		for i, ring in pulls do
			local phase = (p.t * 1.6 + i / #pulls) % 1
			ring.set(ctx.center, r * 2 * (1 - 0.8 * phase), (1 - phase) * 0.7 * p.fade * grow)
		end
		-- The basin turns slowly so the swirl arms read as pulling inward.
		place(hero, CFrame.new(ctx.center + Vector3.new(0, 0.45 * grow, 0)) * CFrame.Angles(0, -p.t * 1.5, 0),
			Vector3.new(r * 2, 0.9 * math.max(grow, 0.05), r * 2) * math.max(grow, 0.05), p.fade, 0)
		for i, sprite in sprites do
			local phase = (p.t * 0.9 + i / #sprites) % 1
			local angle = i * 2.4 + p.t * 5 * (1.4 - phase)
			Cartoon.placeSprite(sprite, CFrame.new(ctx.center + orbit(angle, r * (1 - phase * 0.9)) + Vector3.new(0, 0.9 + phase, 0)),
				1.3 - phase * 0.7, (1 - phase) * p.fade * 0.9, i * 50)
		end
		splash.Rate = 14 * p.fade
		return true
	end
end
