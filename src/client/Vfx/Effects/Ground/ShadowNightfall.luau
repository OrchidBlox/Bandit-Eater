-- Shadow R Nightfall. Concept: a broad lavender warning disc of concentric rings, then a large rounded violet crescent
-- (a thick U) drops onto it and bursts into a soft purple dome with a ring of white puffs and stars. Short-lived,
-- and the target stays visible inside the translucent dome (never a blackout). The crescent is the Codex ChunkyCrescent.
local Fx = require(script.Parent.Fx)
local ease, place, orbit = Fx.ease, Fx.place, Fx.orbit

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local disc, mid, core = ctx.ring(c.Highlight, 12, 0.3), ctx.ring(c.Body, 10, 0.25), ctx.ring(c.Highlight, 8, 0.35)
	local flash = ctx.ring(c.Highlight, 24)
	local rim = ctx.mesh("ChunkyCrescent", c.Shade, Fx.SMOOTH, 0.1)
	local body = ctx.mesh("ChunkyCrescent", c.Body, Fx.SMOOTH, 0)
	local shine = ctx.mesh("ChunkyCrescent", c.Highlight, Fx.NEON, 0.45)
	local dome = ctx.part(Enum.PartType.Ball, c.Body, Fx.NEON, 0.55)
	local anchor = ctx.anchor(ctx.center, r)
	local cloud = Fx.puffs(anchor, Fx.WHITE, c.Highlight, 3.8, { SpreadAngle = Vector2.new(75, 75), Drag = 3 })
	local sparkles = Fx.stars(anchor, c.Highlight, 1.6, NumberRange.new(14, 26), { SpreadAngle = Vector2.new(60, 60), Shape = Enum.ParticleEmitterShape.Box })
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness, light.Parent = c.Body, 22, 0, anchor
	local height, landedFx = 15, false
	local function crescent(cf, size, opacity)
		-- Plane vertical, convex edge down (a U), facing the cast direction. The mesh's opening points toward -X.
		local orient = cf * CFrame.Angles(0, 0, -math.pi / 2)
		place(rim, orient, Vector3.new(size * 1.12, size * 1.12, size * 0.5), opacity, 0.1)
		place(body, orient, Vector3.new(size, size, size * 0.42), opacity, 0)
		place(shine, orient * CFrame.new(0, 0, size * 0.18), Vector3.new(size * 0.82, size * 0.82, size * 0.2), opacity, 0.45)
	end
	return function(p)
		local facing = CFrame.lookAt(ctx.center, ctx.center + ctx.dir)
		if not p.active then
			disc.set(ctx.center, r * 2, 0.3 + 0.6 * p.charge)
			mid.set(ctx.center, r * 1.3, 0.3 + 0.5 * p.charge)
			core.set(ctx.center, r * 0.6 * (1 + 0.1 * math.sin(p.elapsed * 12)), 0.3 + 0.6 * p.charge)
			flash.set(ctx.center, 1, 0)
			-- The crescent gathers high above, growing as the warning fills.
			crescent(facing * CFrame.new(0, height, 0), r * 0.9 * (0.2 + 0.6 * p.charge), p.charge * 0.85)
			dome.Transparency = 1
			return true
		end
		local drop = ease(p.t / 0.22)
		local landed = p.t >= 0.22
		if landed and not landedFx then
			landedFx = true
			for i = 1, 8 do
				anchor.CFrame = CFrame.new(ctx.center + orbit(i * math.pi / 4, r * 0.8) + Vector3.new(0, 0.6, 0))
				cloud:Emit(4)
			end
			anchor.CFrame = CFrame.new(ctx.center + Vector3.new(0, 0.3, 0))
			sparkles:Emit(10)
			ctx.bump(0.05)
		end
		light.Brightness = (landed and 2.5 or 1) * p.fade
		disc.set(ctx.center, r * 2, (landed and 0.3 or 0.9) * p.fade)
		mid.set(ctx.center, r * 1.3, (landed and 0.3 or 0.8) * p.fade)
		core.set(ctx.center, r * 0.6, (landed and 0.3 or 0.9) * p.fade)
		local fall = height * (1 - drop * drop)
		local squash = landed and math.max(0, 1 - (p.t - 0.22) * 5) or 1
		crescent(facing * CFrame.new(0, fall + 2, 0), r * 1.35 * (0.55 + 0.45 * squash), p.fade * (1 - ease((p.t - 0.3) / 0.25)))
		if landed then
			local k = ease((p.t - 0.22) / 0.3)
			flash.set(ctx.center, r * 2 * k, (1 - k) * p.fade)
			-- Soft dome splash, half-buried so only the cap shows; short-lived.
			place(dome, CFrame.new(ctx.center), Vector3.one * r * 1.9 * k, p.fade * math.clamp(1 - (p.t - 0.35) / 0.4, 0, 1), 0.55)
		else
			dome.Transparency = 1
		end
		return true
	end
end
