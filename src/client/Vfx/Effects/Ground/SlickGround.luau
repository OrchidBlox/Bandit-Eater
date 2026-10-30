-- Anime-slick field and area moves, driven by a config table: the windup draws the exact server circle with a runic
-- circle at the caster's feet, then a ring (and a smaller inner ring) of Codex-built hero meshes rises in three nested
-- tints under one hard outline, with spiral speed bars, flung shards, a pulse ring per server pulse and star sparks.
-- cfg: mesh, shape (native size), mode "ring" (upright clusters), "disc" (flat spinner) or "orbit" (blades circling),
-- count, inner, height, lean, turn (rad/s), pulses, floor (dark disc), dust.
local Fx = require(script.Parent.Fx)
local Slick = require(script.Parent.Slick)
local backOut, orbit = Fx.backOut, Fx.orbit

local SlickGround = {}

function SlickGround.make(cfg)
	return function(ctx)
		local c, r = ctx.c, ctx.radius
		local size = math.max(1, r / (cfg.refRadius or 11))
		local centre = ctx.center
		local area, glow, dashed = ctx.ring(c.Highlight, 7, 0.06), ctx.ring(c.Body, 16, 0.12), ctx.dashRing(c.Highlight, 28, 0.06, 0.03)
		local scorch = ctx.ring(Slick.INK, 0, 0.5)
		local pulse = ctx.ring(c.Highlight, 12)
		local runes = Slick.runes(ctx, c)
		local spokes = Slick.bars(ctx, 12, c.Highlight)
		local holder = Instance.new("Model")
		holder.Name, holder.Parent = "Hero", ctx.group
		Slick.outline(holder)
		local outer, inner, disc = {}, {}, nil
		if cfg.mode == "disc" then
			disc = Slick.layers(ctx, c, holder, cfg.mesh)
		else
			for i = 1, cfg.count or 9 do
				outer[i] = Slick.wedge(ctx, c, holder, cfg.mesh, cfg.shape)
			end
			for i = 1, cfg.inner or 0 do
				inner[i] = Slick.wedge(ctx, c, holder, cfg.mesh, cfg.shape)
			end
		end
		local spirals = Slick.bars(ctx, 8, c.Highlight)
		local shards = Slick.shards(ctx, 8)
		local anchor = ctx.anchor(centre, r * 1.4)
		local sparks = Fx.stars(anchor, c.Highlight, 1.1, NumberRange.new(12, 22), { SpreadAngle = Vector2.new(25, 25), Shape = Enum.ParticleEmitterShape.Box,
			Acceleration = Vector3.new(0, 6, 0) })
		local light = Instance.new("PointLight")
		light.Color, light.Range, light.Brightness, light.Parent = c.Body, 18, 0, anchor
		local started = false
		local baseH = (cfg.height or 9) * size
		return function(p)
			if not p.active then
				local k = 0.35 + 0.65 * p.charge
				area.set(centre, r * 2, k)
				glow.set(centre, r * 2, 0.3 + 0.5 * p.charge)
				dashed.set(centre, r * 2 * 0.82, 0.3 + 0.6 * p.charge, p.elapsed * -35)
				scorch.set(centre, r * 2, 0.15 + 0.3 * p.charge)
				pulse.set(centre, 1, 0)
				for i, spoke in spokes do
					local a = (i - 1) / #spokes * math.pi * 2 + p.elapsed * 0.6
					Slick.bar(spoke, centre + orbit(a, r * 0.35) + Vector3.new(0, 0.14, 0), centre + orbit(a, r * (0.35 + 0.6 * p.charge)) + Vector3.new(0, 0.14, 0),
						0.12, 0.35 + 0.5 * p.charge)
				end
				runes.set(ctx.caster, 3.2, 0.4 + 0.6 * p.charge, p.elapsed * 3)
				if disc then
					disc.hide()
				end
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
				sparks.Rate = 16
				ctx.bump(0.03)
			end
			local fade = p.fade
			area.set(centre, r * 2, 0.8 * fade)
			glow.set(centre, r * 2, 0.5 * fade)
			dashed.set(centre, r * 2 * 0.82, 0.7 * fade, p.t * -60)
			scorch.set(centre, r * 2, 0.5 * fade)
			local pulses = cfg.pulses or 3
			local period = 0.6 / pulses
			local phase = (p.t % period) / period
			pulse.set(centre, r * 2 * (0.25 + 0.75 * phase), (1 - phase) * 0.9 * fade)
			light.Brightness = 1.8 * fade
			local turn = p.t * (cfg.turn or 1.5)
			if disc then
				-- Flat spinner stretched to the whole circle, rising out of the floor.
				local grow = backOut(p.t / 0.25)
				local spin = CFrame.Angles(0, turn * 2.2, 0)
				disc.place(CFrame.new(centre + Vector3.new(0, 0.5 + 0.6 * math.min(1, grow), 0)) * spin,
					Vector3.new(r * 2, (cfg.shape.Y or 1.5) * size, r * 2) * math.max(grow, 0.02), fade)
			end
			for i, wedge in outer do
				local a = (i - 1) / #outer * math.pi * 2 + turn
				local grow = backOut((p.t - i * 0.012) / 0.2)
				local height = (baseH + 0.28 * baseH * math.sin(i * 1.9 + p.t * 9)) * math.max(grow, 0.02)
				if cfg.mode == "orbit" then
					local bob = 1.6 + 1.2 * math.sin(i * 1.3 + p.t * 5)
					wedge.set(centre + orbit(a, r * (cfg.ringFrac or 0.7)) + Vector3.new(0, bob, 0), a + math.pi / 2, 0, height, 0, fade)
				else
					wedge.set(centre + orbit(a, r * (cfg.ringFrac or 0.94)), a + math.pi, cfg.lean or 0.35, height, 0, fade)
				end
			end
			for i, wedge in inner do
				local a = (i - 1) / #inner * math.pi * 2 - turn * 1.3
				local grow = backOut((p.t - 0.05 - i * 0.015) / 0.2)
				local height = (baseH * 0.65 + 0.2 * baseH * math.sin(i * 2.3 + p.t * 11)) * math.max(grow, 0.02)
				wedge.set(centre + orbit(a, r * 0.52), a + math.pi, (cfg.lean or 0.35) * 0.8, height, 0, fade)
			end
			for i, bar in spirals do
				local a = (i - 1) / #spirals * math.pi * 2 + turn * 2.2
				local y = 1.2 + ((p.t * 3 + i * 0.37) % 1) * 5
				Slick.bar(bar, centre + orbit(a, r * 0.98) + Vector3.new(0, y, 0), centre + orbit(a + 0.4, r * 0.98) + Vector3.new(0, y + 0.3, 0), 0.13, fade * 0.9, 0.05)
			end
			shards.update(centre + orbit(0, r * 0.9), p.t, fade)
			sparks.Rate = 16 * fade
			return true
		end
	end
end

return SlickGround
