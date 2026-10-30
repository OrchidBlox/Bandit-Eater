-- Fire E Flame Field (anime-slick). The windup draws the exact server circle on the floor with a runic circle at the
-- caster's feet; the release raises a ring of tall, sharp, outlined flame wedges that lean and turn clockwise, with an
-- inner counter-turning ring, thin spiral speed bars, dark shards and a hard pulse ring per server pulse.
local Fx = require(script.Parent.Fx)
local Slick = require(script.Parent.Slick)
local backOut, orbit = Fx.backOut, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local size = math.max(1, r / 11) -- flame height scales with the hit radius so bigger fields get taller fire
	local area, areaGlow, dashed = ctx.ring(c.Highlight, 7, 0.06), ctx.ring(c.Body, 16, 0.12), ctx.dashRing(c.Highlight, 28, 0.06, 0.03)
	local scorch = ctx.ring(Slick.INK, 0, 0.5)
	local pulse = ctx.ring(c.Highlight, 12)
	local runes = Slick.runes(ctx, c)
	local spokes = Slick.bars(ctx, 12, c.Highlight)
	local flames = Instance.new("Model")
	flames.Name, flames.Parent = "Flames", ctx.group
	Slick.outline(flames)
	local outer, inner = {}, {}
	local cluster = Vector3.new(5, 9, 3)
	for i = 1, 9 do
		outer[i] = Slick.wedge(ctx, c, flames, "FlameCluster", cluster)
	end
	for i = 1, 5 do
		inner[i] = Slick.wedge(ctx, c, flames, "FlameCluster", cluster)
	end
	local spirals = Slick.bars(ctx, 8, c.Highlight)
	local shards = Slick.shards(ctx, 8)
	local anchor = ctx.anchor(ctx.center, r * 1.4)
	local sparks = Fx.stars(anchor, c.Highlight, 1.1, NumberRange.new(12, 22), { SpreadAngle = Vector2.new(25, 25), Shape = Enum.ParticleEmitterShape.Box,
		Acceleration = Vector3.new(0, 6, 0) })
	local smoke = Fx.emitter(anchor, Fx.Textures.Puff, ColorSequence.new(Color3.fromRGB(70, 28, 22), Color3.fromRGB(36, 14, 12)), Fx.numbers(2.2, 3.6, 4.4),
		Fx.numbers(0.55, 0.8, 1), NumberRange.new(0.8, 1.3), NumberRange.new(2, 5), { SpreadAngle = Vector2.new(20, 20), Shape = Enum.ParticleEmitterShape.Box,
			Acceleration = Vector3.new(0, 4, 0) })
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness, light.Parent = c.Body, 18, 0, anchor
	local started = false
	return function(p)
		if not p.active then
			-- Windup: the exact hit circle, spokes toward the rim, runes under the caster.
			local k = 0.35 + 0.65 * p.charge
			area.set(ctx.center, r * 2, k)
			areaGlow.set(ctx.center, r * 2, 0.3 + 0.5 * p.charge)
			dashed.set(ctx.center, r * 2 * 0.82, 0.3 + 0.6 * p.charge, p.elapsed * -35)
			scorch.set(ctx.center, r * 2, 0.15 + 0.3 * p.charge)
			pulse.set(ctx.center, 1, 0)
			for i, spoke in spokes do
				local a = (i - 1) / #spokes * math.pi * 2 + p.elapsed * 0.6
				Slick.bar(spoke, ctx.center + orbit(a, r * 0.35) + Vector3.new(0, 0.14, 0), ctx.center + orbit(a, r * (0.35 + 0.6 * p.charge)) + Vector3.new(0, 0.14, 0),
					0.12, 0.35 + 0.5 * p.charge)
			end
			runes.set(ctx.caster, 3.2, 0.4 + 0.6 * p.charge, p.elapsed * 3)
			for _, wedge in outer do
				wedge.hide()
			end
			for _, wedge in inner do
				wedge.hide()
			end
			return true
		end
		if not started then
			started = true
			runes.hide()
			Fx.hide(spokes)
			sparks.Rate, smoke.Rate = 18, 7
			ctx.bump(0.03)
		end
		local fade = p.fade
		area.set(ctx.center, r * 2, 0.8 * fade)
		areaGlow.set(ctx.center, r * 2, 0.5 * fade)
		dashed.set(ctx.center, r * 2 * 0.82, 0.7 * fade, p.t * -60)
		scorch.set(ctx.center, r * 2, 0.5 * fade)
		-- One hard ring flash per server pulse (three pulses, 0.2 s apart).
		local phase = (p.t % 0.2) / 0.2
		pulse.set(ctx.center, r * 2 * (0.25 + 0.75 * phase), (1 - phase) * 0.9 * fade)
		light.Brightness = 1.8 * fade
		local turn = p.t * 1.5
		for i, wedge in outer do
			local a = (i - 1) / #outer * math.pi * 2 + turn
			local grow = backOut((p.t - i * 0.012) / 0.2)
			local height = (9 + 2.5 * math.sin(i * 1.9 + p.t * 9)) * size * math.max(grow, 0.02)
			wedge.set(ctx.center + orbit(a, r * 0.94), a + math.pi, 0.35, height, 0, fade)
		end
		for i, wedge in inner do
			local a = (i - 1) / #inner * math.pi * 2 - turn * 1.3
			local grow = backOut((p.t - 0.05 - i * 0.015) / 0.2)
			local height = (6 + 1.6 * math.sin(i * 2.3 + p.t * 11)) * size * math.max(grow, 0.02)
			wedge.set(ctx.center + orbit(a, r * 0.52), a + math.pi, 0.3, height, 0, fade)
		end
		-- Spiral speed bars hugging the ring, rising as they turn.
		for i, bar in spirals do
			local a = (i - 1) / #spirals * math.pi * 2 + turn * 2.2
			local y = 1.2 + ((p.t * 3 + i * 0.37) % 1) * 5
			Slick.bar(bar, ctx.center + orbit(a, r * 0.98) + Vector3.new(0, y, 0), ctx.center + orbit(a + 0.4, r * 0.98) + Vector3.new(0, y + 0.3, 0), 0.13, fade * 0.9, 0.05)
		end
		shards.update(ctx.center + orbit(0, r * 0.9), p.t, fade)
		sparks.Rate, smoke.Rate = 18 * fade, 7 * fade
		return true
	end
end
