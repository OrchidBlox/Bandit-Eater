-- Sword E Rising Slash (server cone: short, forward, lifts targets). Chunky-cartoon crescent with anime-slick
-- accents as a style test: a long cut sweeps up through the cone, silver afterimages trail behind it, thin speed
-- streaks follow, a ground slash line flashes at the start and radial hit lines burst at the peak.
local Fx = require(script.Parent.Fx)
local ease, place = Fx.ease, Fx.place

return function(ctx)
	local c = ctx.c
	local range = ctx.def.Range
	local SILVER = Color3.fromRGB(246, 249, 255)
	local rim = ctx.mesh("Slash", c.Shade, Fx.SMOOTH, 0.25)
	local core = ctx.mesh("Slash", SILVER, Fx.SMOOTH, 0)
	local edge = ctx.mesh("Slash", Fx.WHITE, Fx.NEON, 0)
	local ghosts = ctx.meshes(2, "Slash", { Color3.fromRGB(196, 222, 255) }, Fx.NEON, 0.2)
	local groundLine = ctx.part(Enum.PartType.Block, Fx.WHITE, Fx.NEON, 1)
	local streaks = {}
	for i = 1, 6 do
		streaks[i] = ctx.part(Enum.PartType.Block, Fx.WHITE, Fx.NEON, 1)
	end
	local rays = {}
	for i = 1, 8 do
		rays[i] = ctx.part(Enum.PartType.Block, Fx.WHITE, Fx.NEON, 1)
	end
	local glint = ctx.part(Enum.PartType.Ball, Fx.WHITE, Fx.NEON, 0.2)
	local anchor = ctx.anchor(ctx.caster, 2)
	local pop = Fx.stars(anchor, Fx.WHITE, 1.4, NumberRange.new(10, 22), { SpreadAngle = Vector2.new(90, 90) })
	local dust = Fx.puffs(anchor, Fx.WHITE, c.Highlight, 1.8)
	local cf0 = CFrame.lookAt(ctx.caster, ctx.caster + ctx.dir)
	local fwd = cf0.LookVector
	local SWEEP = 0.26
	local started, popped = false, false

	-- Pose of the cut at sweep progress k: low in front, up and over toward the caster's back.
	local function pose(k)
		local phi = math.rad(-60 + 205 * k)
		local radial = fwd * math.cos(phi) + Vector3.yAxis * math.sin(phi)
		local tangent = -fwd * math.sin(phi) + Vector3.yAxis * math.cos(phi)
		local pos = ctx.caster + Vector3.new(0, 2.0, 0) + radial * math.min(range, 6.2)
		return CFrame.fromMatrix(pos, radial, tangent), pos, tangent
	end

	return function(p)
		if not p.active then
			-- Ground warning across the real hit fan (server test: within range and dot > 0.6, about 53 degrees each side).
			for i = 1, 3 do
				local angle = math.rad((i - 2) * 45)
				place(streaks[i], cf0 * CFrame.Angles(0, -angle, 0) * CFrame.new(0, 0.12, -range * 0.5), Vector3.new(0.12, 0.08, range * 0.95),
					0.3 + 0.6 * p.charge, 0.1)
			end
			return true
		end
		if not started then
			started = true
			ctx.bump(0.035)
		end
		local k = ease(p.t / SWEEP)
		local orient, pos, tangent = pose(k)
		local opacity = p.fade * math.clamp(1 - (p.t - SWEEP) / 0.2, 0, 1)
		-- Long, thin-edged cut: wide arc, thin thickness (sharper than the chunky Q crescents).
		local size = 7.0 * (0.85 + 0.25 * math.sin(math.clamp(p.t / SWEEP, 0, 1) * math.pi))
		place(rim, orient * CFrame.new(0, 0, 0.05), Vector3.new(size * 1.16, size * 1.16, 1.4), opacity, 0.25)
		place(core, orient, Vector3.new(size, size, 1.3), opacity, 0)
		place(edge, orient * CFrame.new(size * 0.04, 0, 0), Vector3.new(size * 0.92, size * 0.92, 0.35), opacity, 0)
		-- Afterimages: the same cut at earlier points of the sweep, fading.
		for i, ghost in ghosts do
			local gorient = pose(math.max(0, k - i * 0.2))
			place(ghost, gorient, Vector3.new(size * 0.96, size * 0.96, 0.25), opacity * (0.55 - i * 0.2) * (k > 0.08 and 1 or 0), 0.2)
		end
		-- Speed streaks trailing behind the edge along the swing's tangent.
		for i, streak in streaks do
			local offset = Vector3.new((i - 3.5) * 0.55, 0, 0)
			local tail = -tangent * (2.4 + i * 0.5)
			place(streak, CFrame.lookAt(pos + tail * 0.5 + offset, pos + tail + offset), Vector3.new(0.09, 0.09, 2.6 + i * 0.5),
				opacity * math.clamp(k * 3, 0, 1), 0.05)
		end
		-- Flash line along the ground at the start of the swing.
		place(groundLine, cf0 * CFrame.new(0, 0.14, -range * 0.5), Vector3.new(0.3, 0.08, range * 0.95), math.max(0, 1 - p.t * 5) * p.fade, 0)
		-- Radial hit lines and a glint burst at the peak of the sweep.
		local peak = math.clamp((p.t - SWEEP * 0.75) / 0.12, 0, 1)
		for i, ray in rays do
			local angle = i * math.pi / 4
			local dir = (orient.UpVector * math.cos(angle) + orient.RightVector * math.sin(angle)).Unit
			place(ray, CFrame.lookAt(pos + dir * (1.2 + peak * 1.6), pos + dir * (2.4 + peak * 2.4)), Vector3.new(0.08, 0.08, 1.6 * (1 - peak * 0.4)),
				peak > 0 and (1 - peak) * p.fade or 0, 0.05)
		end
		place(glint, CFrame.new(pos), Vector3.one * 2.2 * math.sin(math.clamp(p.t / SWEEP, 0, 1) * math.pi), opacity, 0.2)
		anchor.CFrame = CFrame.new(pos)
		dust.Rate = p.t < SWEEP + 0.05 and 40 or 0
		if not popped and p.t > SWEEP * 0.75 then
			popped = true
			pop:Emit(8)
		end
		return true
	end
end
