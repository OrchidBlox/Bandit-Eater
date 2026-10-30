-- Sword E dash-slashes (Flash Step, Gale Rush, Tremor Charge, Tide Slide, Blaze Lunge, Umbra Step, Crown Rush).
-- The server moves the caster Range studs forward over DashTime; here the same easing places a head point along the
-- lane, and every power leaves its own kind of trail behind it (silver ghosts, wind helix, kicked-up stones, a water
-- wake, a flame comet, shadow clones, golden crown stars) plus a finishing cut. No cloud puffs: stars, shards, ribbons.
local Fx = require(script.Parent.Fx)
local place = Fx.place

local function lerp(a, b, t)
	return a + (b - a) * t
end

-- Each style builds its trail items. An item appears when the head passes `at` (0..1 along the lane), lives `life`
-- seconds and is posed by item.pose(item, age, lifeFraction, base, fwd, right) -> cframe, size, opacity.
local STYLES = {}

function STYLES.Sword(ctx, _, add)
	for i = 1, 3 do
		-- Silver afterimages of the lunging player, thin streaks either side.
		add({ part = ctx.part(Enum.PartType.Block, Fx.WHITE, Fx.NEON, 1), at = i * 0.28, life = 0.3, pose = function(_, _, k, base, fwd)
			return CFrame.lookAt(base + Vector3.new(0, 2.6, 0), base + Vector3.new(0, 2.6, 0) + fwd), Vector3.new(1.8, 4.8, 0.7), 0.45 * (1 - k), 0.5
		end })
	end
	for i = 1, 6 do
		local side = (i % 2 == 0 and 1 or -1) * (0.7 + 0.35 * (i % 3))
		add({ part = ctx.part(Enum.PartType.Block, Fx.WHITE, Fx.NEON, 1), at = 0.1 * i, life = 0.28, pose = function(_, _, k, base, fwd, right)
			return CFrame.lookAt(base + right * side + Vector3.new(0, 1.4 + 0.3 * i, 0), base + right * side + fwd + Vector3.new(0, 1.4 + 0.3 * i, 0)),
				Vector3.new(0.12, 0.12, 5 * (1 - k * 0.5)), 1 - k, 0
		end })
	end
end

function STYLES.Wind(ctx, c, add)
	for i = 1, 12 do
		add({ part = ctx.mesh("Leaf", i % 2 == 0 and c.Highlight or c.Body, Fx.SMOOTH, 0), at = i / 13, life = 0.55, pose = function(_, age, k, base, fwd, right)
			local a = i * 1.7 + age * 12
			local radius = lerp(1.4, 2.8, k)
			local pos = base + right * math.cos(a) * radius + Vector3.new(0, 1.6 + math.sin(a) * radius * 0.8 + k * 1.2, 0)
			return CFrame.lookAt(pos, pos + fwd:Lerp(right * math.cos(a + 1.6), 0.6)), Vector3.new(0.9, 0.3, 1.5) * (1 - k * 0.5), 1 - k * k, 0
		end })
	end
	for i = 1, 3 do
		-- Spiral ribbons riding the dash lane.
		add({ part = ctx.mesh("GustCurl", c.Highlight, Fx.NEON, 0.3), at = 0.15 * i, life = 0.4, pose = function(_, age, k, base, fwd)
			return CFrame.lookAt(base + Vector3.new(0, 1.8, 0), base + fwd + Vector3.new(0, 1.8, 0)) * CFrame.Angles(0, 0, age * 14 + i),
				Vector3.new(3.4, 3.4, 5.5) * (1 - k * 0.4), 1 - k, 0.3
		end })
	end
end

function STYLES.Earth(ctx, c, add)
	for i = 1, 7 do
		local side = (i % 2 == 0 and 1 or -1) * (1 + (i % 3) * 0.9)
		add({ part = ctx.mesh("Rock", i % 2 == 0 and c.Highlight or c.Body, Fx.SMOOTH, 0), at = i / 8, life = 0.7, pose = function(_, age, k, base, fwd, right)
			local lift = math.max(0, 7 * age * (1 - age / 0.55))
			local pos = base + right * side * (1 + age * 3) - fwd * age * 3 + Vector3.new(0, 0.5 + lift, 0)
			return CFrame.new(pos) * CFrame.Angles(age * 9 + i, age * 7, i), Vector3.one * (1.1 + 0.35 * (i % 3)) * (1 - math.max(0, k - 0.8) * 5), 1, 0
		end })
	end
	for i = 1, 5 do
		-- Cracked ridge of ground behind the charge.
		add({ part = ctx.part(Enum.PartType.Block, Color3.fromRGB(88, 56, 30), Fx.SMOOTH, 1), at = i / 6, life = 0.9, pose = function(_, _, k, base, fwd)
			return CFrame.lookAt(base + Vector3.new(0, 0.1, 0), base + fwd) * CFrame.Angles(0, (i - 3) * 0.35, 0), Vector3.new(0.3, 0.08, 4 + i), 1 - k * k, 0
		end })
	end
end

function STYLES.Water(ctx, c, add)
	for i = 1, 10 do
		local side = (i % 2 == 0 and 1 or -1)
		add({ part = ctx.mesh("Droplet", i % 3 == 0 and Fx.WHITE or c.Highlight, Fx.SMOOTH, 0), at = i / 11, life = 0.55, pose = function(_, age, k, base, _, right)
			local pos = base + right * side * (1 + age * 6) + Vector3.new(0, 0.8 + 6 * age * (1 - age / 0.5), 0)
			return CFrame.lookAt(pos, pos + right * side + Vector3.new(0, 1 - age * 4, 0)), Vector3.new(0.7, 1.2, 0.7) * (1 - k * 0.4), 1 - k * k, 0
		end })
	end
	for i = 1, 4 do
		-- Flowing wake ribbon hugging the ground.
		add({ part = ctx.part(Enum.PartType.Block, c.Body, Fx.NEON, 1), at = i * 0.2, life = 0.6, pose = function(_, age, k, base, fwd)
			return CFrame.lookAt(base + Vector3.new(0, 0.3 + 0.2 * math.sin(age * 12 + i), 0), base + fwd), Vector3.new(2.6 + 2.2 * k, 0.15, 5), 0.8 * (1 - k), 0.25
		end })
	end
end

function STYLES.Fire(ctx, c, add)
	for i = 1, 9 do
		add({ part = ctx.mesh("FlameBlob", i % 2 == 0 and c.Highlight or c.Body, Fx.NEON, 0.1), at = i / 10, life = 0.5, pose = function(_, age, k, base, fwd)
			local pos = base + Vector3.new(0, 1.4 + age * 3, 0)
			return CFrame.lookAt(pos, pos + fwd) * CFrame.Angles(math.rad(-90), 0, 0), Vector3.new(2.4, 3.2, 2.4) * (1 - k * k) + Vector3.one * 0.1, 1 - k * 0.3, 0.1
		end })
	end
	for i = 1, 8 do
		-- Scorched footprints that glow, then cool off.
		add({ part = ctx.part(Enum.PartType.Cylinder, c.Shade, Fx.NEON, 1), at = i / 9, life = 1.0, pose = function(_, _, k, base)
			return CFrame.new(base + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(0.1, 2.0, 2.0), 0.85 * (1 - k), 0
		end })
	end
end

function STYLES.Shadow(ctx, c, add)
	for i = 1, 3 do
		-- Translucent clones of the player left along the lane.
		add({ part = ctx.part(Enum.PartType.Block, c.Body, Fx.NEON, 1), at = i * 0.25, life = 0.45, pose = function(_, _, k, base, fwd)
			return CFrame.lookAt(base + Vector3.new(0, 2.6, 0), base + Vector3.new(0, 2.6, 0) + fwd), Vector3.new(1.9, 4.9, 1.0), 0.6 * (1 - k), 0.2
		end })
	end
	for i = 1, 6 do
		add({ part = ctx.mesh("ShadowOrb", c.Shade, Fx.SMOOTH, 0.2), at = i / 7, life = 0.6, pose = function(_, age, k, base, _, right)
			local pos = base + right * math.sin(i * 2 + age * 5) * 1.4 + Vector3.new(0, 1.6 + age * 2, 0)
			return CFrame.new(pos), Vector3.one * 2.2 * (1 - k), 0.8 * (1 - k), 0.2
		end })
	end
	for i = 1, 5 do
		add({ part = ctx.part(Enum.PartType.Block, c.Highlight, Fx.NEON, 1), at = 0.12 * i, life = 0.3, pose = function(_, _, k, base, fwd, right)
			local off = (i - 3) * 0.7
			return CFrame.lookAt(base + right * off + Vector3.new(0, 2 + off * 0.3, 0), base + right * off + fwd + Vector3.new(0, 2 + off * 0.3, 0)),
				Vector3.new(0.1, 0.1, 6), 1 - k, 0
		end })
	end
end

function STYLES.Master(ctx, c, add)
	for i = 1, 3 do
		add({ part = ctx.part(Enum.PartType.Block, c.Body, Fx.NEON, 1), at = i * 0.22, life = 0.4, pose = function(_, _, k, base, fwd)
			return CFrame.lookAt(base + Vector3.new(0, 2.6, 0), base + Vector3.new(0, 2.6, 0) + fwd), Vector3.new(2.2, 4.8, 0.9), 0.4 * (1 - k), 0.4
		end })
	end
	for i = 1, 8 do
		add({ part = ctx.part(Enum.PartType.Ball, i % 2 == 0 and Fx.WHITE or c.Highlight, Fx.NEON, 1), at = i / 9, life = 0.5, pose = function(_, age, k, base, _, right)
			local pos = base + right * math.sin(i * 1.9) * 1.8 + Vector3.new(0, 1.4 + age * 3 + math.cos(i) * 0.6, 0)
			return CFrame.new(pos), Vector3.one * 0.7 * (1 - k), 1 - k, 0
		end })
	end
	for i = 1, 4 do
		add({ part = ctx.part(Enum.PartType.Block, Fx.WHITE, Fx.NEON, 1), at = 0.12 + 0.2 * i, life = 0.3, pose = function(_, _, k, base, fwd, right)
			local off = (i - 2.5) * 0.9
			return CFrame.lookAt(base + right * off + Vector3.new(0, 1.8, 0), base + right * off + fwd + Vector3.new(0, 1.8, 0)), Vector3.new(0.25, 0.25, 7), 1 - k, 0
		end })
	end
end

local STYLE_OF = { Sword = "Sword", Shadow = "Shadow", Sword_Wind = "Wind", Sword_Earth = "Earth", Sword_Water = "Water", Sword_Fire = "Fire",
	Sword_Shadow = "Shadow", Sword_Sword = "Master" }
-- Finishing cut per style: mesh, scale, tilt (radians about the travel axis).
local FINISH = { Sword = { "Slash", 8, 0.0 }, Wind = { "Slash", 6, 0.5 }, Earth = { "ChunkyCrescent", 6, 0.0 }, Water = { "Slash", 7, -0.4 },
	Fire = { "ChunkyCrescent", 7, 0.0 }, Shadow = { "Slash", 8, 0.3 }, Master = { "ChunkyCrescent", 9, 0.0 } }

return function(ctx)
	local c, def = ctx.c, ctx.def
	local style = STYLE_OF[ctx.data.Power] or "Sword"
	local range, dashTime = def.Range, def.DashTime
	local S = math.max(1, ctx.radius / 6) -- bigger dashes get a bigger finishing cut
	local fwd = ctx.dir
	local right = fwd:Cross(Vector3.yAxis)
	local floor = ctx.caster
	local cf0 = CFrame.lookAt(floor, floor + fwd)
	local items = {}
	STYLES[style](ctx, c, function(item)
		if item.part then
			table.insert(items, item)
		end
	end)
	local lane = ctx.part(Enum.PartType.Block, c.Highlight, Fx.NEON, 1)
	local endMark = ctx.part(Enum.PartType.Cylinder, c.Highlight, Fx.NEON, 1)
	local fin = FINISH[style]
	-- Codex anime-slick crescents when installed (SlashCrescent 6x1x9, DarkCrescent 8x1.5x10); the older meshes otherwise.
	local newName = style == "Shadow" and "DarkCrescent" or "SlashCrescent"
	local useNew = Fx.hasMesh(newName)
	local native = newName == "DarkCrescent" and Vector3.new(8, 1.5, 10) or Vector3.new(6, 1, 9)
	if useNew then
		fin = { newName, fin[2], fin[3] }
	end
	local cutRim = ctx.mesh(fin[1], c.Shade, Fx.SMOOTH, 0.2)
	local cut = ctx.mesh(fin[1], c.Body, Fx.SMOOTH, 0)
	local cutGlow = ctx.mesh(fin[1], c.Highlight, Fx.NEON, 0.35)
	local anchor = ctx.anchor(floor, 2)
	local sparks = Fx.stars(anchor, c.Accent or c.Highlight, 1.0, NumberRange.new(10, 22), { SpreadAngle = Vector2.new(25, 25) })
	local started, cutAt = false, nil

	local function head(t)
		local x = math.clamp(t / dashTime, 0, 1)
		return floor + fwd * range * (1 - (1 - x) ^ 2)
	end

	return function(p)
		if not p.active then
			place(lane, cf0 * CFrame.new(0, 0.12, -range * 0.5), Vector3.new(0.35, 0.08, range), 0.3 + 0.5 * p.charge, 0.1)
			place(endMark, CFrame.new(floor + fwd * range + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.pi / 2), Vector3.new(0.08, 3.4, 3.4), 0.2 + 0.4 * p.charge, 0.2)
			for _, item in items do
				item.part.Transparency = 1
			end
			return true
		end
		if not started then
			started = true
			ctx.bump(0.04)
		end
		lane.Transparency, endMark.Transparency = 1, 1
		local now = head(p.t)
		anchor.CFrame = CFrame.new(now + Vector3.new(0, 1.5, 0), now + Vector3.new(0, 1.5, 0) - fwd)
		sparks.Rate = p.t < dashTime and 60 or 0
		local progress = math.clamp(p.t / dashTime, 0, 1)
		for _, item in items do
			local bornAt = item.at * dashTime
			local age = p.t - bornAt
			if age < 0 or age > item.life then
				item.part.Transparency = 1
			else
				item.born = item.born or head(bornAt)
				local k = age / item.life
				local cf, size, opacity, base = item.pose(item, age, k, item.born, fwd, right)
				place(item.part, cf, size, opacity * p.fade, base)
			end
		end
		-- Finishing cut once the dash ends: convex edge leads, flashes and fades.
		if progress >= 0.75 then
			cutAt = cutAt or p.t
			local k = (p.t - cutAt) / 0.28
			local size = fin[2] * S * (0.5 + 0.5 * Fx.backOut(k))
			local pos = floor + fwd * range + Vector3.new(0, 2.6, 0)
			local opacity = p.fade * math.clamp(1 - k, 0, 1)
			if useNew then
				-- The crescent lies flat with its convex edge forward; roll it upright so it slices across the dash lane.
				local cf = CFrame.lookAt(pos, pos + fwd) * CFrame.Angles(0, 0, math.pi / 2 + fin[3])
				local scale = size / 6
				place(cutRim, cf, native * scale * 1.1, opacity, 0.2)
				place(cut, cf, native * scale, opacity, 0)
				place(cutGlow, cf, native * scale * 0.7, opacity, 0.35)
			else
				local cf = CFrame.lookAt(pos, pos + fwd) * CFrame.Angles(0, math.pi / 2, fin[3])
				place(cutRim, cf, Vector3.new(size * 1.1, size * 1.1, 1.6), opacity, 0.2)
				place(cut, cf, Vector3.new(size, size, 1.2), opacity, 0)
				place(cutGlow, cf * CFrame.new(0, 0, 0.3), Vector3.new(size * 0.8, size * 0.8, 0.6), opacity, 0.35)
			end
		else
			for _, part in { cutRim, cut, cutGlow } do
				part.Transparency = 1
			end
		end
		return true
	end
end
