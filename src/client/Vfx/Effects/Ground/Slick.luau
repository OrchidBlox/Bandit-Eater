-- Bandit Eater's anime-slick kit for ground moves: sharp tapered flame wedges with a dark outline copy, thin speed bars,
-- a runic windup circle at the caster's feet, flung dark shards and radial impact lines. Everything is built through the
-- move's ctx so it counts toward the part budget. Presentation only; the server owns hit areas and damage.
local Fx = require(script.Parent.Fx)
local place = Fx.place

local Slick = {}
Slick.INK = Color3.fromRGB(34, 12, 10)

-- A thin neon bar from point a to point b.
function Slick.bar(part, a, b, thickness, opacity, base)
	if not part then
		return
	end
	local length = (b - a).Magnitude
	if length < 0.05 then
		part.Transparency = 1
		return
	end
	place(part, CFrame.lookAt((a + b) * 0.5, b), Vector3.new(thickness, thickness, length), opacity, base or 0)
end

function Slick.bars(ctx, count, color)
	local list = {}
	for i = 1, count do
		list[i] = ctx.part(Enum.PartType.Block, color, Fx.NEON, 1)
	end
	return list
end

-- Hard dark outline around everything under `holder` (one Highlight per effect keeps inside Roblox's 31-highlight limit).
function Slick.outline(holder, color)
	local highlight = Instance.new("Highlight")
	highlight.Name, highlight.Adornee, highlight.FillTransparency = "SlickOutline", holder, 1
	highlight.OutlineColor, highlight.OutlineTransparency, highlight.DepthMode = color or Slick.INK, 0, Enum.HighlightDepthMode.Occluded
	highlight.Parent = holder
	return highlight
end

-- Tapered flame wedge: element body plus a hot core. The mesh's tip is its +Y end; the wedge stands with its base at
-- `pos`, turned to `yaw`, leaning `lean` radians toward its own forward (-Z). Parts go under `holder` so one outline covers them.
function Slick.wedge(ctx, c, holder, meshName, shape)
	-- Three nested tongues, each narrower and shorter: red-orange outer, orange middle, pale-yellow hot core.
	meshName = meshName or "Flame"
	local wedge = { outer = ctx.mesh(meshName, c.Shade, Fx.NEON, 0), mid = ctx.mesh(meshName, c.Body, Fx.NEON, 0),
		core = ctx.mesh(meshName, c.Highlight, Fx.NEON, 0) }
	for _, part in { wedge.outer, wedge.mid, wedge.core } do
		part.Parent = holder or part.Parent
	end
	function wedge.set(pos, yaw, lean, height, width, opacity)
		local base = CFrame.new(pos) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(-lean, 0, 0)
		if shape then
			-- A full mesh (a flame cluster): scale it uniformly to `height`; nested copies give the red, orange and hot layers.
			local k = height / shape.Y
			place(wedge.outer, base * CFrame.new(0, height * 0.5, 0), shape * k, opacity, 0)
			place(wedge.mid, base * CFrame.new(0, height * 0.42, 0.03), shape * k * 0.74, opacity, 0)
			place(wedge.core, base * CFrame.new(0, height * 0.34, 0.06), shape * k * 0.46, opacity, 0)
			return
		end
		place(wedge.outer, base * CFrame.new(0, height * 0.5, 0), Vector3.new(width, height, width * 0.7), opacity, 0)
		place(wedge.mid, base * CFrame.new(0, height * 0.4, 0.02), Vector3.new(width * 0.66, height * 0.78, width * 0.5), opacity, 0)
		place(wedge.core, base * CFrame.new(0, height * 0.31, 0.04), Vector3.new(width * 0.34, height * 0.5, width * 0.28), opacity, 0)
	end
	function wedge.hide()
		wedge.outer.Transparency, wedge.mid.Transparency, wedge.core.Transparency = 1, 1, 1
	end
	return wedge
end

-- Three nested copies of one mesh (shade, body, hot core) laid flat or upright by the caller's CFrame; opacity 0..1.
function Slick.layers(ctx, c, holder, meshName)
	local set = { ctx.mesh(meshName, c.Shade, Fx.NEON, 0), ctx.mesh(meshName, c.Body, Fx.NEON, 0), ctx.mesh(meshName, c.Highlight, Fx.NEON, 0) }
	for _, part in set do
		part.Parent = holder or part.Parent
	end
	local scales = { 1, 0.78, 0.52 }
	function set.place(cf, size, opacity)
		for i, part in { set[1], set[2], set[3] } do
			place(part, cf, size * scales[i], opacity, 0)
		end
	end
	function set.hide()
		for i = 1, 3 do
			set[i].Transparency = 1
		end
	end
	return set
end

-- Runic windup circle: two rings, a spinning hexagram and spoke ticks. set(centre, radius, opacity, spin).
function Slick.runes(ctx, c)
	local outer, inner = ctx.ring(c.Highlight, 5, 0), ctx.ring(c.Body, 3, 0.1)
	local star = Slick.bars(ctx, 6, c.Highlight)
	local circle = {}
	function circle.set(centre, radius, opacity, spin)
		outer.set(centre, radius * 2, opacity)
		inner.set(centre, radius * 1.45, opacity * 0.8)
		local y = centre + Vector3.new(0, 0.16, 0)
		for i, part in star do
			-- Two triangles: points 1,3,5 and 2,4,6 around the circle.
			local tri = (i - 1) // 3
			local k = (i - 1) % 3
			local a1 = spin + tri * math.pi / 3 + k * math.pi * 2 / 3
			local a2 = a1 + math.pi * 2 / 3
			Slick.bar(part, y + Fx.orbit(a1, radius * 0.72), y + Fx.orbit(a2, radius * 0.72), 0.14, opacity)
		end
	end
	function circle.hide()
		outer.set(Vector3.zero, 0.1, 0)
		inner.set(Vector3.zero, 0.1, 0)
		Fx.hide(star)
	end
	return circle
end

-- Dark shards flung from a point: ballistic arcs with a tumble.
function Slick.shards(ctx, count, seed)
	local items = {}
	for i = 1, count do
		local part = ctx.mesh("Rock", i % 3 == 0 and Color3.fromRGB(90, 30, 20) or Slick.INK, Fx.SMOOTH, 0)
		if part then
			local angle = i * 2.399 + (seed or 0)
			local speed = 9 + (i * 5.3) % 9
			table.insert(items, { part = part, vx = math.cos(angle) * speed, vz = math.sin(angle) * speed, vy = 8 + (i * 3.7) % 9,
				size = 0.7 + (i * 0.37) % 0.9, spin = 4 + i % 5 })
		end
	end
	local list = { items = items }
	function list.update(origin, t, opacity)
		for _, s in items do
			local y = s.vy * t - 14 * t * t
			if y < -0.2 then
				s.part.Transparency = 1
			else
				place(s.part, CFrame.new(origin + Vector3.new(s.vx * t, math.max(y, 0) + 0.3, s.vz * t)) * CFrame.Angles(t * s.spin, t * s.spin * 0.7, 0),
					Vector3.one * s.size, opacity, 0)
			end
		end
	end
	return list
end

-- Radial impact lines: thin bars flaring outward from a centre in the ground plane; progress 0..1.
function Slick.burstLines(bars, centre, progress, innerR, outerR, opacity)
	local count = #bars
	for i, bar in bars do
		local a = (i - 1) / count * math.pi * 2 + 0.2
		local start = innerR + (outerR - innerR) * progress
		Slick.bar(bar, centre + Fx.orbit(a, start) + Vector3.new(0, 0.3, 0), centre + Fx.orbit(a, start + (outerR - innerR) * 0.35) + Vector3.new(0, 0.3, 0),
			0.16, opacity * (1 - progress), 0.05)
	end
end

return Slick
