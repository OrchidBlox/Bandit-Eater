-- Anime-slick waves, cones and moving walls, driven by a config table. The windup draws the exact band (or fan) the
-- server will sweep; the release rolls a Codex-built hero mesh forward at the server wave's speed in three nested tints
-- under one hard outline, trailing thin speed bars, with radial hit lines and shards at the leading edge.
-- cfg: mesh, shape (native size), mode "wall" (one mesh stretched to the width, travelling), "row" (several copies
-- across the width, travelling), "column" (one tall mesh that spins while travelling) or "fan" (grows forward and stays
-- near the caster); height scale, spin, count (row).
local Fx = require(script.Parent.Fx)
local Slick = require(script.Parent.Slick)
local place, ease, backOut = Fx.place, Fx.ease, Fx.backOut

local SlickWave = {}

function SlickWave.make(cfg)
	return function(ctx)
		local c, r = ctx.c, ctx.radius
		local def = ctx.def
		local range = def.Range
		local width = r * 2
		local cf0 = CFrame.lookAt(ctx.caster, ctx.caster + ctx.dir)
		local holder = Instance.new("Model")
		holder.Name, holder.Parent = "Hero", ctx.group
		Slick.outline(holder)
		local heroes = {}
		local count = cfg.mode == "row" and (cfg.count or 5) or 1
		for i = 1, count do
			heroes[i] = Slick.layers(ctx, c, holder, cfg.mesh)
		end
		local ghosts = {}
		if cfg.mode == "fan" then
			for i = 1, 2 do
				ghosts[i] = Slick.layers(ctx, c, holder, cfg.mesh)
			end
		end
		local lane = ctx.part(Enum.PartType.Block, c.Body, Fx.NEON, 1)
		local edges = { ctx.part(Enum.PartType.Block, c.Highlight, Fx.NEON, 1), ctx.part(Enum.PartType.Block, c.Highlight, Fx.NEON, 1) }
		local chevrons = Slick.bars(ctx, 5, c.Highlight)
		local fanLines = Slick.bars(ctx, 5, c.Highlight)
		local speedBars = Slick.bars(ctx, 8, c.Highlight)
		local lines = Slick.bars(ctx, 10, c.Highlight)
		local runes = Slick.runes(ctx, c)
		local shards = Slick.shards(ctx, 8)
		local anchor = ctx.anchor(ctx.caster, 2)
		local sparks = Fx.stars(anchor, c.Highlight, 1.1, NumberRange.new(10, 20), { SpreadAngle = Vector2.new(50, 50) })
		local started = false

		return function(p)
			if not p.active then
				-- Telegraph: a band for waves and walls, a fan of lines for cones.
				local k = 0.35 + 0.65 * p.charge
				if cfg.mode == "fan" then
					lane.Transparency = 1
					for i, line in fanLines do
						local angle = math.rad((i - 3) * 31)
						Slick.bar(line, ctx.caster + Vector3.new(0, 0.14, 0), ctx.caster + (CFrame.Angles(0, -angle, 0) * ctx.dir) * range * k + Vector3.new(0, 0.14, 0), 0.18, 0.4 + 0.5 * p.charge)
					end
				else
					place(lane, cf0 * CFrame.new(0, 0.12, -range * 0.5), Vector3.new(width, 0.05, range), 0.25 + 0.4 * p.charge, 0.1)
					for i, edge in edges do
						place(edge, cf0 * CFrame.new((i == 1 and -1 or 1) * width * 0.5, 0.15, -range * 0.5), Vector3.new(0.22, 0.08, range), 0.5 + 0.5 * p.charge, 0)
					end
					for i, chevron in chevrons do
						local z = range * (i / 6)
						Slick.bar(chevron, ctx.caster + ctx.dir * z + cf0.RightVector * width * 0.2 + Vector3.new(0, 0.16, 0), ctx.caster + ctx.dir * z - cf0.RightVector * width * 0.2 + Vector3.new(0, 0.16, 0),
							0.14, 0.3 + 0.5 * p.charge)
					end
				end
				runes.set(ctx.caster, 3.2, 0.4 + 0.6 * p.charge, p.elapsed * 3)
				for _, hero in heroes do
					hero.hide()
				end
				for _, ghost in ghosts do
					ghost.hide()
				end
				return true
			end
			if not started then
				started = true
				runes.hide()
				Fx.hide(chevrons)
				Fx.hide(fanLines)
				sparks.Rate = 22
				ctx.bump(0.04)
			end
			local fade = p.fade
			lane.Transparency = 1
			Fx.hide(edges)
			local speed = ctx.data.Speed > 0 and ctx.data.Speed or 30
			local travelled = cfg.mode == "fan" and range * 0.55 or math.min(range, p.t * speed)
			local front = ctx.caster + ctx.dir * (1.5 + travelled)
			local rise = backOut(p.t / 0.22)
			local shape = cfg.shape
			if cfg.mode == "wall" then
				local scaleX = width / shape.X
				heroes[1].place(cf0 * CFrame.new(0, 0, -(1.5 + travelled)) * CFrame.new(0, (shape.Y * scaleX * 0.5 * (cfg.height or 1)) * math.max(rise, 0.1), 0),
					Vector3.new(width, shape.Y * scaleX * (cfg.height or 1) * math.max(rise, 0.1), shape.Z * scaleX), fade)
			elseif cfg.mode == "row" then
				local each = width / count
				local k = each / shape.X
				for i, hero in heroes do
					local lateral = ((i - 0.5) / count - 0.5) * (width - each)
					local lead = 1 - math.abs(i - (count + 1) / 2) / count
					hero.place(cf0 * CFrame.new(lateral, shape.Y * k * 0.5 * math.max(rise, 0.1), -(1.5 + travelled) + (1 - lead) * 2.2),
						Vector3.new(shape.X * k, shape.Y * k * (0.8 + 0.4 * lead) * math.max(rise, 0.1), shape.Z * k), fade)
				end
			elseif cfg.mode == "column" then
				local k = (cfg.height or 1) * math.max(1, r / 8)
				heroes[1].place(CFrame.new(front + Vector3.new(0, shape.Y * k * 0.5 * math.max(rise, 0.1), 0)) * CFrame.Angles(0, p.t * (cfg.spin or 4), 0),
					Vector3.new(shape.X * k, shape.Y * k * math.max(rise, 0.1), shape.Z * k), fade)
			else
				-- Fan: grows forward over the first 0.25 s, with two lagging ghosts behind it.
				local grow = ease(p.t / 0.25)
				local k = (range / shape.Z) * math.max(grow, 0.05)
				heroes[1].place(cf0 * CFrame.new(0, 1.4, -shape.Z * k * 0.5), Vector3.new(shape.X * k * (width / shape.X) * 0.7, shape.Y, shape.Z * k), fade)
				for i, ghost in ghosts do
					local g = ease((p.t - i * 0.05) / 0.25)
					ghost.place(cf0 * CFrame.new(0, 1.4 + i * 0.4, -shape.Z * (range / shape.Z) * g * 0.5),
						Vector3.new(shape.X * (range / shape.Z) * g * (width / shape.X) * 0.7, shape.Y, shape.Z * (range / shape.Z) * g), fade * (0.5 - i * 0.15))
				end
			end
			-- Speed bars streaming behind the leading edge.
			for i = 1, #speedBars do
				local lateral = ((i - 0.5) / #speedBars - 0.5) * width * 0.9
				local from = ctx.caster + ctx.dir * (1.5 + travelled - 1 - (i % 3)) + cf0.RightVector * lateral + Vector3.new(0, 1 + (i % 4) * 0.9, 0)
				Slick.bar(speedBars[i], from, from - ctx.dir * (5 + (i % 3) * 2), 0.12, fade * 0.8, 0.05)
			end
			-- Radial hit lines flare ahead of the wave once it is moving.
			local flare = math.clamp(p.t / 0.3, 0, 1)
			Slick.burstLines(lines, front, flare, 1.5, 6, fade * 0.8)
			shards.update(front, p.t, fade)
			anchor.CFrame = CFrame.new(front + Vector3.new(0, 1.2, 0))
			sparks.Rate = 22 * fade
			return true
		end
	end
end

return SlickWave
