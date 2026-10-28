-- Wind R Cyclone. Concept: broad dashed warning ring with swooshes around the caster, then a tall plump tornado of
-- three thick spiralling mint bands with white puffs and grey rock chips. Hit area is the server field radius.
local Fx = require(script.Parent.Fx)
local backOut, place, orbit = Fx.backOut, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local dashed, solid = ctx.dashRing(c.Body, 16, 0.12, 0.03), ctx.ring(c.Highlight, 6)
	-- Approved Codex tornado mesh (three intertwined plump bands): one outer and one counter-rotating inner copy.
	local hero = ctx.mesh("TornadoBands", c.Body, Fx.NEON, 0.3)
	local inner = ctx.mesh("TornadoBands", c.Highlight, Fx.NEON, 0.4)
	local bands = { hero, inner }
	local chips = ctx.meshes(5, "Rock", { Color3.fromRGB(125, 118, 108) }, Fx.SMOOTH, 0)
	local swooshes = {}
	for i = 1, 6 do
		local sprite = require(script.Parent.Parent.Parent.Cartoon).sprite(ctx.group, i % 2 == 0 and Fx.Textures.Star or Fx.Textures.Puff,
			i % 2 == 0 and c.Highlight or Fx.WHITE)
		if sprite then
			table.insert(swooshes, sprite)
			ctx.parts += 1
		end
	end
	local base = ctx.anchor(ctx.center, r * 1.4)
	local dust = Fx.puffs(base, Fx.WHITE, c.Body, 2.8, { SpreadAngle = Vector2.new(30, 30), Drag = 1, Shape = Enum.ParticleEmitterShape.Box })
	local sparkle = Fx.stars(base, c.Highlight, 1.1, NumberRange.new(4, 9), { Acceleration = Vector3.new(0, 4, 0), Shape = Enum.ParticleEmitterShape.Box })
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness, light.Parent = c.Body, 18, 0, base
	local height, started = 12, false
	local cartoon = require(script.Parent.Parent.Parent.Cartoon)
	return function(p)
		if not p.active then
			dashed.set(ctx.center, r * 2, 0.4 + 0.5 * p.charge, p.elapsed * -40)
			solid.set(ctx.center, r * 2 * (1 - 0.4 * p.charge), 0.25 + 0.5 * p.charge)
			Fx.hide(bands)
			for i, s in swooshes do
				local a = i * 1.05 + p.elapsed * 9
				cartoon.placeSprite(s, CFrame.new(ctx.caster + orbit(a, 2.6 * (1 - 0.3 * p.charge)) + Vector3.new(0, 1.5 + math.sin(a) * 0.9, 0)),
					1.1, p.charge * 0.9, i * 40)
			end
			return true
		end
		if not started then
			started = true
			dust.Rate, sparkle.Rate = 24, 8
			for _, s in swooshes do
				s.image.ImageTransparency = 1
			end
			ctx.bump(0.035)
		end
		local grow = backOut(p.t / 0.45)
		dashed.set(ctx.center, r * 2, math.max(0.3, 0.9 - p.t) * p.fade, p.t * -60)
		solid.set(ctx.center, r * 2 * 0.62, 0.35 * p.fade)
		light.Brightness = 1.6 * p.fade
		if hero then
			place(hero, CFrame.new(ctx.center + Vector3.new(0, height * 0.5 * grow, 0)) * CFrame.Angles(0, p.t * 3.2, 0),
				Vector3.new(r * 1.7, height * grow, r * 1.7), p.fade, 0.3)
		end
		if inner then
			place(inner, CFrame.new(ctx.center + Vector3.new(0, height * 0.46 * grow, 0)) * CFrame.Angles(0, -p.t * 4.4, 0),
				Vector3.new(r * 1.1, height * 0.9 * grow, r * 1.1), p.fade, 0.4)
		end
		for i, chip in chips do
			local angle = p.t * 5 + i * 1.26
			local y = (p.t * 5 + i * 2.3) % height
			local R = r * (0.4 + 0.45 * y / height)
			place(chip, CFrame.new(ctx.center + orbit(angle, R) + Vector3.new(0, y, 0)) * CFrame.Angles(p.t * 6 + i, p.t * 4, 0),
				Vector3.new(1.2, 1.1, 1.2) * grow, p.fade, 0)
		end
		dust.Rate = 24 * p.fade
		return true
	end
end
