-- Fire E Flame Field. Concept: a double golden ring with small flame ticks on the ground, then several squat, bouncy,
-- rounded flame blobs fill it and stay see-through; each server pulse flashes a ring. Embers drift up.
local Fx = require(script.Parent.Fx)
local backOut, place, orbit = Fx.backOut, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local dashed, outer, inner = ctx.dashRing(c.Highlight, 24, 0.07, 0.03), ctx.ring(c.Body, 14, 0.14), ctx.ring(c.Highlight, 6)
	local pulse = ctx.ring(c.Highlight, 16)
	local ticks = {}
	for i = 1, 14 do
		local mesh = ctx.mesh("Flame", i % 2 == 0 and c.Highlight or c.Body, Fx.NEON, 0)
		if mesh then
			table.insert(ticks, { part = mesh, angle = i * math.pi * 2 / 14 })
		end
	end
	local blobs = {}
	for i = 1, 5 do
		local angle = i * 2.399
		local dist = r * (0.3 + 0.5 * ((i * 0.41) % 1))
		local shell, core = ctx.mesh("Flame", c.Body, Fx.NEON, 0), ctx.mesh("Flame", c.Highlight, Fx.NEON, 0)
		if shell and core then
			table.insert(blobs, { shell = shell, core = core, pos = ctx.center + orbit(angle, dist), phase = i * 1.3 })
		end
	end
	local anchor = ctx.anchor(ctx.center, r * 1.4)
	local embers = Fx.emitter(anchor, Fx.Textures.Puff, ColorSequence.new(c.Highlight, c.Shade), Fx.numbers(0.9, 0.6, 0), Fx.numbers(0.1, 0.4, 1),
		NumberRange.new(0.8, 1.3), NumberRange.new(3, 7), { SpreadAngle = Vector2.new(15, 15), Acceleration = Vector3.new(0, 7, 0), LightEmission = 1, Shape = Enum.ParticleEmitterShape.Box })
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness, light.Parent = c.Body, 16, 0, anchor
	local started = false
	return function(p)
		if not p.active then
			dashed.set(ctx.center, r * 2, 0.45 + 0.5 * p.charge, p.elapsed * 30)
			outer.set(ctx.center, r * 2, 0.3 + 0.5 * p.charge)
			inner.set(ctx.center, r * 2 * (0.4 + 0.6 * p.charge), 0.2 + 0.5 * p.charge)
			pulse.set(ctx.center, 1, 0)
			for _, tick in ticks do
				place(tick.part, CFrame.new(ctx.center + orbit(tick.angle, r * 0.97)), Vector3.new(0.5, 1.4, 0.4) * p.charge, 1, 0)
			end
			return true
		end
		if not started then
			started = true
			embers.Rate = 14
			ctx.bump(0.025)
		end
		dashed.set(ctx.center, r * 2, 0.8 * p.fade, p.t * 40)
		outer.set(ctx.center, r * 2, 0.7 * p.fade)
		inner.set(ctx.center, r * 2 * 0.6, 0.4 * p.fade)
		local phase = (p.t % 0.2) / 0.2
		pulse.set(ctx.center, r * 2 * (0.3 + 0.7 * phase), (1 - phase) * 0.8 * p.fade)
		light.Brightness = 1.6 * p.fade
		for _, tick in ticks do
			local lick = 0.8 + 0.4 * math.sin(p.t * 12 + tick.angle * 3)
			place(tick.part, CFrame.new(ctx.center + orbit(tick.angle, r * 0.97) + Vector3.new(0, 0.6 * lick, 0)), Vector3.new(0.7, 1.7 * lick, 0.5), p.fade, 0)
		end
		for i, blob in blobs do
			local k = backOut((p.t - i * 0.03) / 0.25)
			local bounce = 1 + 0.18 * math.sin(p.t * 11 + blob.phase)
			local squash = 1 - 0.1 * math.sin(p.t * 11 + blob.phase)
			local sway = math.sin(p.t * 6 + blob.phase) * 0.15
			local pos = blob.pos + Vector3.new(0, 1.5 * k * bounce, 0)
			place(blob.shell, CFrame.new(pos) * CFrame.Angles(0, blob.phase, sway), Vector3.new(2.7 * squash, 3.1 * bounce, 2.2) * k, p.fade, 0)
			place(blob.core, CFrame.new(pos + Vector3.new(0, -0.2, 0.1)) * CFrame.Angles(0, blob.phase, sway), Vector3.new(1.6 * squash, 2.1 * bounce, 1.3) * k, p.fade, 0)
		end
		embers.Rate = 14 * p.fade
		return true
	end
end
