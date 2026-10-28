-- Fire R Eruption. Concept: a double ring warning on the ground, then one big rounded flame geyser with fat lobes,
-- an outward ring of white cloud puffs, a few small stones and sparse stars. No dark smoke.
local Fx = require(script.Parent.Fx)
local ease, backOut, place, orbit = Fx.ease, Fx.backOut, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local outerDash, innerDash = ctx.dashRing(c.Body, 22, 0.08, 0.03), ctx.dashRing(c.Highlight, 14, 0.1, 0.028)
	local outer = ctx.ring(c.Body, 12, 0.14)
	local flash = ctx.ring(c.Highlight, 26)
	local core = ctx.mesh("Flame", c.Highlight, Fx.NEON, 0)
	local shell = ctx.mesh("Flame", c.Body, Fx.NEON, 0)
	local skin = ctx.mesh("Flame", c.Shade, Fx.SMOOTH, 0.15)
	local lobes = {}
	for i = 1, 6 do
		local lobe = ctx.mesh("Flame", i % 2 == 0 and c.Highlight or c.Body, Fx.NEON, 0.05)
		if lobe then
			table.insert(lobes, { part = lobe, angle = i * math.pi * 2 / 6 + 0.3, i = i })
		end
	end
	local stones = {}
	for i = 1, 5 do
		local stone = ctx.mesh("Rock", Color3.fromRGB(118, 112, 104), Fx.SMOOTH, 0)
		if stone then
			table.insert(stones, { part = stone, angle = i * 1.26, speed = 0.7 + (i % 3) * 0.2 })
		end
	end
	local anchor = ctx.anchor(ctx.center, r)
	local cloud = Fx.puffs(anchor, Fx.WHITE, Color3.fromRGB(255, 236, 205), 4.2, { SpreadAngle = Vector2.new(75, 75), Drag = 3 })
	local sparks = Fx.stars(anchor, c.Highlight, 1.5, NumberRange.new(14, 26), { SpreadAngle = Vector2.new(35, 35), Shape = Enum.ParticleEmitterShape.Box })
	local embers = Fx.emitter(anchor, Fx.Textures.Puff, ColorSequence.new(c.Highlight, c.Shade), Fx.numbers(1.4, 1.0, 0), Fx.numbers(0.1, 0.4, 1),
		NumberRange.new(0.5, 0.9), NumberRange.new(8, 18), { SpreadAngle = Vector2.new(25, 25), LightEmission = 1, Acceleration = Vector3.new(0, 6, 0), Shape = Enum.ParticleEmitterShape.Box })
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness, light.Parent = c.Body, 24, 0, anchor
	local started, height = false, 12
	return function(p)
		if not p.active then
			outerDash.set(ctx.center, r * 2, 0.4 + 0.5 * p.charge, p.elapsed * 25)
			innerDash.set(ctx.center, r * 1.2 * (1 - 0.3 * p.charge), 0.3 + 0.6 * p.charge, p.elapsed * -35)
			outer.set(ctx.center, r * 2, 0.2 + 0.4 * p.charge)
			flash.set(ctx.center, 1, 0)
			-- Seedling flame gathers in the middle during the windup.
			local s = 0.1 + 0.25 * p.charge
			place(shell, CFrame.new(ctx.center + Vector3.new(0, 1.3 * s * 3, 0)), Vector3.new(3, 3.4, 2.4) * s, 1, 0)
			return true
		end
		if not started then
			started = true
			-- Cloud ring: puffs burst outward from points around the rim.
			for i = 1, 8 do
				anchor.CFrame = CFrame.new(ctx.center + orbit(i * math.pi / 4, r * 0.75) + Vector3.new(0, 0.6, 0))
				cloud:Emit(4)
			end
			anchor.CFrame = CFrame.new(ctx.center + Vector3.new(0, 0.3, 0))
			sparks:Emit(7)
			embers.Rate = 30
			ctx.bump(0.05)
		end
		outerDash.set(ctx.center, r * 2, math.max(0, 0.9 - p.t * 1.6) * p.fade, p.t * 60)
		innerDash.set(ctx.center, r * 1.2, math.max(0, 0.9 - p.t * 1.6) * p.fade, p.t * -80)
		outer.set(ctx.center, r * 2, math.max(0, 0.6 - p.t * 1.4) * p.fade)
		local erupt = backOut(p.t / 0.28)
		local settle = 1 + 0.07 * math.sin(p.t * 14)
		local g = math.max(0.02, erupt) * settle
		flash.set(ctx.center, r * 2 * ease(p.t / 0.3), math.max(0, 1 - p.t * 3) * p.fade)
		light.Brightness = 3 * p.fade
		place(skin, CFrame.new(ctx.center + Vector3.new(0, height * 0.5 * g, 0)), Vector3.new(r * 0.78, height * g, r * 0.62), p.fade, 0.15)
		place(shell, CFrame.new(ctx.center + Vector3.new(0, height * 0.46 * g, 0)), Vector3.new(r * 0.6, height * 0.9 * g, r * 0.48), p.fade, 0)
		place(core, CFrame.new(ctx.center + Vector3.new(0, height * 0.36 * g, 0.2)), Vector3.new(r * 0.36, height * 0.62 * g, r * 0.3), p.fade, 0)
		for _, lobe in lobes do
			local lg = backOut((p.t - 0.02 * lobe.i) / 0.25) * settle
			place(lobe.part, CFrame.new(ctx.center + orbit(lobe.angle, r * 0.45) + Vector3.new(0, 2.6 * lg, 0)) * CFrame.Angles(0, lobe.angle, math.sin(p.t * 10 + lobe.i) * 0.15),
				Vector3.new(r * 0.3, 5.2 * lg, r * 0.24), p.fade, 0.05)
		end
		for _, stone in stones do
			local travel = math.clamp(p.t / 0.7, 0, 1)
			local hop = math.sin(travel * math.pi) * (5 + stone.speed * 3)
			place(stone.part, CFrame.new(ctx.center + orbit(stone.angle, r * 0.85 * ease(travel) * stone.speed) + Vector3.new(0, 0.4 + hop, 0)) * CFrame.Angles(p.t * 6, p.t * 5, 0),
				Vector3.new(1.4, 1.2, 1.3), p.fade, 0)
		end
		embers.Rate = 30 * p.fade
		return true
	end
end
