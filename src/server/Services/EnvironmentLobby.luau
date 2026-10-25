local P = require(script.Parent.EnvironmentProps)
local C = P.Colors
local Lobby = {}

local function planter(parent, center, size, seed)
	local model = P.Model(parent, "RaisedGarden")
	P.Part(model, "StoneBed", size, CFrame.new(center + Vector3.new(0, size.Y / 2, 0)), C.Stone, Enum.Material.Slate, true)
	P.Part(model, "GrassBed", Vector3.new(size.X - 1, 0.25, size.Z - 1), CFrame.new(center + Vector3.new(0, size.Y + 0.1, 0)), C.Grass, Enum.Material.Grass, false)
	P.Plants(model, center + Vector3.new(0, size.Y + 0.25, 0), seed, math.min(size.X, size.Z) * 0.43, 16)
	return center + Vector3.new(0, size.Y + 0.25, 0)
end

local function star(parent, cf, color, scale)
	for i = 1, 5 do
		local angle = i * math.pi * 2 / 5
		P.Part(parent, "StarPoint", Vector3.new(0.7, 1.7, 0.5) * scale,
			cf * CFrame.Angles(0, 0, angle) * CFrame.new(0, 0.45 * scale, 0), color, Enum.Material.Neon, false)
	end
end

local function kiosk(parent, position)
	local model = P.Model(parent, "CosmeticsKiosk")
	local function part(name, size, offset, color, material, collide)
		return P.Part(model, name, size, CFrame.new(position + offset), color, material, collide)
	end
	part("Foundation", Vector3.new(28, 0.8, 17), Vector3.new(0, 0.4, 0), C.Stone, Enum.Material.Slate, true)
	part("BackWall", Vector3.new(25, 12, 1), Vector3.new(0, 6, -6), C.Metal, Enum.Material.Concrete, true)
	part("WarmInterior", Vector3.new(23, 10, 0.4), Vector3.new(0, 6, -5.4), C.Wood, Enum.Material.WoodPlanks, false)
	for _, x in { -12, 12 } do
		part("SideWall", Vector3.new(1.8, 12, 13), Vector3.new(x, 6, 0), C.Stone, Enum.Material.Concrete, true)
		part("FrontPost", Vector3.new(2, 13, 2), Vector3.new(x, 6.5, 5.8), C.LightStone, Enum.Material.Slate, true)
		for _, y in { 1.5, 9.8 } do
			part("PostBand", Vector3.new(2.5, 0.65, 2.5), Vector3.new(x, y, 5.8), C.Trim, Enum.Material.Metal, false)
		end
	end
	part("CounterBase", Vector3.new(24, 3.6, 3), Vector3.new(0, 2.2, 5.7), C.Stone, Enum.Material.Concrete, true)
	part("CounterTop", Vector3.new(26, 0.7, 4.4), Vector3.new(0, 4.3, 5.7), C.Wood, Enum.Material.WoodPlanks, true)
	part("CounterTrim", Vector3.new(24, 0.22, 0.16), Vector3.new(0, 3.7, 7.3), C.Gold, Enum.Material.Metal, false)
	for _, y in { 4.6, 7.8 } do
		part("DisplayShelf", Vector3.new(22, 0.4, 3.5), Vector3.new(0, y, -3.8), C.Wood, Enum.Material.WoodPlanks, false)
		P.Glow(model, "ShelfLight", Vector3.new(20, 0.14, 0.12), CFrame.new(position + Vector3.new(0, y + 2.1, -4.9)), C.Gold)
	end
	for i, color in { Color3.fromRGB(255, 221, 70), Color3.fromRGB(255, 105, 170), Color3.fromRGB(80, 255, 185) } do
		local x = (i - 2) * 7
		star(model, CFrame.new(position + Vector3.new(x, 6.1, -2.5)), color, 0.85)
		star(model, CFrame.new(position + Vector3.new(x, 9.2, -2.5)), color, 0.65)
		P.Disc(model, "DisplayPlinth", position + Vector3.new(x, 4.7, 5.7), 1.5, 0.22, C.Metal, Enum.Material.Metal, false)
		star(model, CFrame.new(position + Vector3.new(x, 5.8, 5.7)), color, 0.65)
	end
	part("RoofEdge", Vector3.new(29, 1, 18), Vector3.new(0, 13, 0), C.Wood, Enum.Material.WoodPlanks, true)
	part("RoofSlab", Vector3.new(27.5, 0.8, 16.5), Vector3.new(0, 13.8, 0), C.Metal, Enum.Material.Slate, false)
	for i = -5, 5 do
		part("RoofRib", Vector3.new(0.22, 0.15, 15.8), Vector3.new(i * 2.45, 14.27, 0), C.Trim, Enum.Material.Metal, false)
	end
	part("SignFrame", Vector3.new(25, 3.8, 0.9), Vector3.new(0, 11, 7.6), C.Trim, Enum.Material.Metal, false)
	local sign = part("CosmeticsSign", Vector3.new(23.8, 3, 1), Vector3.new(0, 11, 8), C.Metal, Enum.Material.Metal, false)
	P.Sign(sign, "COSMETICS", Color3.fromRGB(205, 245, 255))
	P.Glow(model, "AwningLight", Vector3.new(21, 0.2, 0.3), CFrame.new(position + Vector3.new(0, 9.2, 7)), C.Gold)
	local info = part("ShopPlaque", Vector3.new(15, 1.2, 0.2), Vector3.new(0, 2.4, 7.3), C.Metal, Enum.Material.Metal, false)
	P.Sign(info, "STAR COLORS  /  COSMETIC ONLY", C.Gold)
	local glow = Instance.new("PointLight")
	glow.Color, glow.Range, glow.Brightness = C.Gold, 22, 1
	glow.Parent = sign
	P.SmoothPlastic(model)
end

local function leaderboard(parent, position)
	local model = P.Model(parent, "Leaderboard")
	local function part(name, size, offset, color, material, collide)
		return P.Part(model, name, size, CFrame.new(position + offset), color, material, collide)
	end
	part("Plinth", Vector3.new(28, 1.2, 9), Vector3.new(0, 0.6, 0), C.Stone, Enum.Material.Slate, true)
	part("Backboard", Vector3.new(24, 17, 2), Vector3.new(0, 9, 0), C.Metal, Enum.Material.Metal, true)
	for _, x in { -13, 13 } do
		part("Pillar", Vector3.new(2, 18, 3.5), Vector3.new(x, 9, 0), C.LightStone, Enum.Material.Concrete, true)
		part("CyanStrip", Vector3.new(0.4, 11, 0.2), Vector3.new(x, 8.5, 1.9), C.Cyan, Enum.Material.Neon, false)
	end
	part("TopFrame", Vector3.new(28, 1.4, 4), Vector3.new(0, 18, 0), C.Stone, Enum.Material.Slate, false)
	local title = part("Title", Vector3.new(23, 2.5, 0.2), Vector3.new(0, 15.8, 1.2), C.Metal, Enum.Material.Metal, false)
	P.Sign(title, "LEADERBOARD", Color3.fromRGB(205, 245, 255))
	for i = 1, 5 do
		local row = part("Row" .. i, Vector3.new(21, 2.1, 0.4), Vector3.new(0, 13.1 - (i - 1) * 2.5, 1.4), Color3.fromRGB(78, 94, 103), Enum.Material.Metal, false)
		P.Sign(row, i .. ".  --", i == 1 and C.Gold or Color3.fromRGB(223, 232, 231))
	end
	local foot = part("BoardCaption", Vector3.new(23, 1, 0.2), Vector3.new(0, 1.6, 1.4), C.Metal, Enum.Material.Metal, false)
	P.Sign(foot, "SERVER WINS", Color3.fromRGB(162, 199, 207))
end

function Lobby.Build(parent)
	local model = P.Model(parent, "Lobby")
	local center = Vector3.new(-20, 0, 158)
	local rng = Random.new(137)
	P.Part(model, "LobbyFloor", Vector3.new(140, 3, 104), CFrame.new(center + Vector3.new(0, -1.5, 0)), C.Grass, Enum.Material.Grass, true)
	P.Part(model, "IslandBase", Vector3.new(142, 16, 106), CFrame.new(center + Vector3.new(0, -11, 0)), C.Stone, Enum.Material.Slate, true)
	for x = -7, 7 do
		for z = -5, 5 do
			local shade = rng:NextInteger(-8, 8)
			P.Part(model, "PlazaPaving", Vector3.new(7.92, 0.16, 7.92), CFrame.new(center + Vector3.new(x * 8, 0.04, z * 8)),
				Color3.fromRGB(210 + shade, 202 + shade, 178 + shade), Enum.Material.Limestone, false)
		end
	end
	task.wait()
	for i = 1, 24 do
		local x = -91 + i * 6
		P.Part(model, "FrontCliff", Vector3.new(7, 17 + i % 3, 8), CFrame.new(x, -9, 211 + i % 2), C.Stone, Enum.Material.Slate, false)
	end
	for _, x in { -89, 49 } do
		for i = 1, 16 do
			P.Part(model, "SideCliff", Vector3.new(7, 14 + i % 4, 7), CFrame.new(x, -8, 111 + i * 6), C.Stone, Enum.Material.Slate, false)
		end
	end
	P.Portal(model, Vector3.new(-20, 0, 125), 1.05, "ARENA")
	P.Disc(model, "PortalFoundation", Vector3.new(-20, 0.06, 134), 13, 0.25, C.Stone, Enum.Material.Slate, false)
	P.Disc(model, "PortalOuterRing", Vector3.new(-20, 0.2, 134), 11.5, 0.15, C.Trim, Enum.Material.Metal, false)
	P.Disc(model, "PortalCyanRing", Vector3.new(-20, 0.29, 134), 10.5, 0.08, C.Cyan, Enum.Material.Neon, false)
	P.Disc(model, "PortalInnerPlate", Vector3.new(-20, 0.35, 134), 9.5, 0.06, C.Metal, Enum.Material.Metal, false)
	P.Disc(model, "PortalCore", Vector3.new(-20, 0.4, 134), 7.7, 0.06, C.Cyan, Enum.Material.Neon, false).Transparency = 0.35
	local pad = P.Part(model, "ArenaTeleportPad", Vector3.new(12, 0.4, 10), CFrame.new(-20, 0.2, 135), C.Cyan, Enum.Material.Neon, false)
	pad.Transparency = 1
	pad:SetAttribute("Role", "ArenaEntry")
	for _, part in model:GetChildren() do
		if part:IsA("BasePart") and (part.Name:match("^Portal") or part == pad) then
			P.SmoothPlastic(part)
		end
	end
	kiosk(model, Vector3.new(-62, 0, 137))
	leaderboard(model, Vector3.new(24, 0, 130))
	local gardens = {
		{ Vector3.new(-73, 0, 177), Vector3.new(18, 0.8, 19) },
		{ Vector3.new(31, 0, 177), Vector3.new(17, 0.8, 19) },
		{ Vector3.new(-23, 0, 177), Vector3.new(17, 0.8, 11) },
		{ Vector3.new(-44, 0, 117), Vector3.new(13, 0.8, 12) },
		{ Vector3.new(1, 0, 117), Vector3.new(13, 0.8, 12) },
	}
	for i, garden in gardens do
		local top = planter(model, garden[1], garden[2], i * 61)
		if i ~= 3 then
			P.Tree(model, top, i < 3 and 0.7 or 0.8, i * 1.3)
		else
			P.Rock(model, top, 0.44, 0.7, false)
		end
	end
	P.Bench(model, Vector3.new(26, 0, 163), -math.pi / 2)
	P.Bench(model, Vector3.new(-68, 0, 164), math.pi / 2)
	P.Bench(model, Vector3.new(-22, 0, 189), 0)
	P.Fence(model, Vector3.new(-86, 0, 202), Vector3.new(-34, 0, 202))
	P.Fence(model, Vector3.new(-9, 0, 202), Vector3.new(46, 0, 202))
	P.Fence(model, Vector3.new(-86, 0, 156), Vector3.new(-86, 0, 201))
	P.Fence(model, Vector3.new(46, 0, 150), Vector3.new(46, 0, 201))
	for _, v in { Vector3.new(-36, 0, 132), Vector3.new(-4, 0, 132), Vector3.new(-42, 0, 160),
		Vector3.new(7, 0, 162), Vector3.new(-35, 0, 194), Vector3.new(-7, 0, 194), Vector3.new(-81, 0, 190), Vector3.new(42, 0, 190) } do
		P.Lamp(model, v, 0.95)
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name, spawn.Size, spawn.CFrame = "PilotLobbySpawn", Vector3.new(8, 1, 8), CFrame.new(0, 0.5, 155)
	spawn.Anchored, spawn.Neutral, spawn.Duration = true, true, 0
	spawn.Transparency, spawn.CanCollide, spawn.CanTouch = 1, false, false
	spawn.Parent = model
	-- Keep the human-scale lobby beyond the enlarged arena, moving its anchors together.
	model:PivotTo(model:GetPivot() + Vector3.new(0, 0, 240))
	task.wait()
	return model
end

return Lobby
