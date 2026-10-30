-- Water R Tidal Wave. Concept: a glowing ground strip with chevrons shows the path, then one broad plump curling wave
-- rolls forward with thick foam scallops along the crest and spray; the caster stays visible beside it.
local Fx = require(script.Parent.Fx)
local Kit = require(script.Parent.Parent.Parent.Kit)
local backOut, place = Fx.backOut, Fx.place

return function(ctx)
	local c, r = ctx.c, ctx.radius
	local range = ctx.def.Range
	local width = r * 2
	local cf0 = CFrame.lookAt(ctx.caster, ctx.caster + ctx.dir)

	-- Strip telegraph: a SurfaceGui whose canvas matches the strip's aspect so chevrons keep their shape.
	local strip = Kit.safePart(Instance.new("Part"))
	strip.Size, strip.Transparency, strip.Parent = Vector3.new(width, 0.1, range), 1, ctx.group
	ctx.parts += 1
	local gui = Instance.new("SurfaceGui")
	gui.Face, gui.SizingMode, gui.LightInfluence, gui.Adornee, gui.Parent = Enum.NormalId.Top, Enum.SurfaceGuiSizingMode.FixedSize, 0, strip, strip
	local ppu = 24
	gui.CanvasSize = Vector2.new(width * ppu, range * ppu)
	local body = Instance.new("Frame")
	body.Size, body.BackgroundColor3, body.BackgroundTransparency, body.BorderSizePixel = UDim2.fromScale(1, 1), c.Body, 0.82, 0
	body.Parent = gui
	local edge = Instance.new("UIStroke")
	edge.Color, edge.Thickness, edge.Parent = c.Highlight, 10, body
	local chevrons = {}
	for i = 1, 4 do
		for side = -1, 1, 2 do
			local arm = Instance.new("Frame")
			arm.AnchorPoint, arm.Size = Vector2.new(0.5, 0.5), UDim2.fromOffset(width * ppu * 0.2, 12)
			arm.Position = UDim2.fromScale(0.5, 1 - i / 5)
			arm.Rotation = side * 35
			arm.BackgroundColor3, arm.BorderSizePixel, arm.Parent = c.Highlight, 0, body
			table.insert(chevrons, arm)
		end
	end

	local wave = ctx.mesh("TidalWave", Fx.WHITE, Fx.SMOOTH, 0, true)
	local mover = ctx.anchor(ctx.caster, 2)
	local spray = Fx.puffs(mover, Fx.WHITE, c.Highlight, 2.8, { SpreadAngle = Vector2.new(50, 50), Drag = 2 })
	local drops = Fx.stars(mover, c.Highlight, 1.0, NumberRange.new(6, 14), { SpreadAngle = Vector2.new(60, 60) })
	local started, crashed = false, false
	return function(p)
		if not p.active then
			strip.CFrame = cf0 * CFrame.new(0, 0.12, -range / 2)
			body.BackgroundTransparency = 1 - (0.12 + 0.2 * p.charge)
			edge.Transparency = 1 - (0.4 + 0.5 * p.charge)
			for _, arm in chevrons do
				arm.BackgroundTransparency = 1 - (0.3 + 0.6 * p.charge)
			end
			return true
		end
		if not started then
			started = true
			spray.Rate, drops.Rate = 40, 10
			ctx.bump(0.035)
		end
		local speed = ctx.data.Speed > 0 and ctx.data.Speed or 30
		local d = math.min(range, p.t * speed) + 1
		local rise = backOut(p.t / 0.3)
		-- Strip fades as the wave passes over it.
		body.BackgroundTransparency = 1 - 0.15 * math.max(0, 1 - p.t * 2) * p.fade
		edge.Transparency = 1 - 0.6 * math.max(0, 1 - p.t * 2) * p.fade
		for _, arm in chevrons do
			arm.BackgroundTransparency = 1 - 0.5 * math.max(0, 1 - p.t * 2) * p.fade
		end
		local height = 7.5 * rise
		local face = cf0 * CFrame.new(0, height * 0.5 - 0.3, -d) * CFrame.Angles(math.sin(p.t * 7) * 0.05, 0, 0)
		-- The mesh is 12 wide, 7 tall and 6 deep: stretch only its width to the server wave strip.
		place(wave, face, Vector3.new(width, 7.5 * math.max(rise, 0.05), 6.4 * math.max(rise, 0.3)), p.fade, 0)
		mover.CFrame = cf0 * CFrame.new(0, 1, -d + 1.5)
		spray.Rate = 40 * p.fade
		if d >= range and not crashed then
			crashed = true
			spray:Emit(30)
			drops:Emit(10)
		end
		return true
	end
end
