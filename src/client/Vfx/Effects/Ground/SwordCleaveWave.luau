-- Sword fusion R waves (Mountain Splitter, Furnace Cleave, Grand Cleave). A row of fat standing crescents (the Codex
-- ChunkyCrescent) spans the server wave's width and rolls forward along its range, tinted in the fusion's palette,
-- with a streaked ground strip as the telegraph and puffs, stars and element chips behind the leading edge.
local Fx = require(script.Parent.Fx)
local place = Fx.place

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local range = ctx.def.Range
	local width = r * 2
	local cf0 = CFrame.lookAt(ctx.caster, ctx.caster + ctx.dir)
	local count = math.clamp(math.ceil(width / 3.2), 3, 5)
	local crescents = {}
	for i = 1, count do
		local lead = 1 - math.abs(i - (count + 1) / 2) / count -- centre crescents lead and are taller
		table.insert(crescents, {
			rim = ctx.mesh("ChunkyCrescent", c.Shade, Fx.SMOOTH, 0.15),
			body = ctx.mesh("ChunkyCrescent", c.Body, Fx.SMOOTH, 0),
			shine = ctx.mesh("ChunkyCrescent", c.Highlight, Fx.NEON, 0.4),
			x = ((i - 1) / (count - 1) - 0.5) * (width - 3.6), lead = lead,
		})
	end
	local lines = {}
	for i = 1, 5 do
		lines[i] = ctx.part(Enum.PartType.Block, c.Highlight, Fx.NEON, 1)
	end
	local mover = ctx.anchor(ctx.caster, 2)
	local puffs = Fx.puffs(mover, Fx.WHITE, c.Highlight, 2.6, { SpreadAngle = Vector2.new(50, 50), Drag = 2 })
	local sparks = Fx.stars(mover, c.Accent or c.Highlight, 1.1, NumberRange.new(8, 16), { SpreadAngle = Vector2.new(60, 60) })
	local started = false
	return function(p)
		if not p.active then
			for i, line in lines do
				local lateral = (i - 3) * width * 0.22
				place(line, cf0 * CFrame.new(lateral, 0.12, -range * 0.5), Vector3.new(0.2 + 0.4 * p.charge, 0.08, range * 0.92), 0.25 + 0.55 * p.charge, 0.1)
			end
			for _, cr in crescents do
				Fx.hide({ cr.rim, cr.body, cr.shine })
			end
			return true
		end
		if not started then
			started = true
			puffs.Rate, sparks.Rate = 40, 10
			ctx.bump(0.05)
		end
		Fx.hide(lines)
		local speed = ctx.data.Speed > 0 and ctx.data.Speed or 26
		local d = math.min(range, p.t * speed) + 1.5
		local rise = Fx.backOut(p.t / 0.25)
		for _, cr in crescents do
			local size = (5.5 + 2.5 * cr.lead) * math.max(rise, 0.05)
			local trail = (1 - cr.lead) * 2.2
			-- Convex edge leads: the mesh's +X (convex) maps to the travel direction (-Z); its thickness becomes the width.
			local orient = cf0 * CFrame.new(cr.x, size * 0.45, -d + trail) * CFrame.Angles(0, math.pi / 2, 0)
			place(cr.rim, orient, Vector3.new(size * 1.1, size * 1.1, 2.4), p.fade, 0.15)
			place(cr.body, orient, Vector3.new(size, size, 2.0), p.fade, 0)
			place(cr.shine, orient * CFrame.new(0, 0, 0.5), Vector3.new(size * 0.8, size * 0.8, 0.8), p.fade, 0.4)
		end
		mover.CFrame = cf0 * CFrame.new(0, 1, -d + 2)
		puffs.Rate, sparks.Rate = 40 * p.fade, 10 * p.fade
		return true
	end
end
