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

local function leaderboard(parent, position, modelName, titleText, caption)
	local model = P.Model(parent, modelName)
	local function part(name, size, offset, color, material, collide)
		local panel = P.Part(model, name, size, CFrame.new(position + offset), color, material, collide)
		if name == "Backboard" or name == "Title" or name == "BoardCaption" or name:match("^Row") then
			P.SmoothPlastic(panel)
		end
		return panel
	end
	part("Plinth", Vector3.new(28, 1.2, 9), Vector3.new(0, 0.6, 0), C.Stone, Enum.Material.Slate, true)
	part("Backboard", Vector3.new(24, 17, 2), Vector3.new(0, 9, 0), C.Metal, Enum.Material.Metal, true)
	for _, x in { -13, 13 } do
		part("Pillar", Vector3.new(2, 18, 3.5), Vector3.new(x, 9, 0), C.LightStone, Enum.Material.Concrete, true)
		part("CyanStrip", Vector3.new(0.4, 11, 0.2), Vector3.new(x, 8.5, 1.9), C.Cyan, Enum.Material.Neon, false)
	end
	part("TopFrame", Vector3.new(28, 1.4, 4), Vector3.new(0, 18, 0), C.Stone, Enum.Material.Slate, false)
	local title = part("Title", Vector3.new(23, 2.5, 0.2), Vector3.new(0, 15.8, 1.2), C.Metal, Enum.Material.Metal, false)
	P.Sign(title, titleText, Color3.fromRGB(205, 245, 255))
	for i = 1, 5 do
		local row = part("Row" .. i, Vector3.new(21, 2.1, 0.4), Vector3.new(0, 13.1 - (i - 1) * 2.5, 1.4), Color3.fromRGB(78, 94, 103), Enum.Material.Metal, false)
		P.Sign(row, i .. ".  --", i == 1 and C.Gold or Color3.fromRGB(223, 232, 231))
	end
	local foot = part("BoardCaption", Vector3.new(23, 1, 0.2), Vector3.new(0, 1.6, 1.4), C.Metal, Enum.Material.Metal, false)
	P.Sign(foot, caption, Color3.fromRGB(162, 199, 207))
end

local function teleporter(parent, position)
	local model = P.Model(parent, "ArenaGateway")
	local function part(name, size, offset, color, material, collide)
		return P.Part(model, name, size, CFrame.new(position + offset), color, material, collide)
	end
	part("Foundation", Vector3.new(25, 0.4, 19), Vector3.new(0, 0.2, 3), C.LightStone, nil, true)
	part("Platform", Vector3.new(21, 0.2, 16), Vector3.new(0, 0.5, 3), C.Metal, nil, true)
	for _, x in { -9, 9 } do
		part("SimplePost", Vector3.new(1.4, 12, 1.6), Vector3.new(x, 6.6, -3), C.LightStone, nil, true)
		part("PostLight", Vector3.new(0.22, 9, 0.15), Vector3.new(x, 6, -2.1), C.Cyan, Enum.Material.Neon, false)
	end
	local sign = part("ArenaSign", Vector3.new(19.4, 2.2, 1.6), Vector3.new(0, 12, -3), C.Metal, nil, true)
	P.Sign(sign, "FFA", Color3.fromRGB(205, 245, 255))
	local glass = part("PortalSurface", Vector3.new(16.5, 10.2, 0.12), Vector3.new(0, 5.8, -3), C.Cyan, Enum.Material.Glass, false)
	glass.Transparency, glass.CastShadow = 0.88, false
	for _, x in { -9.6, 9.6 } do
		part("PadLight", Vector3.new(0.25, 0.08, 14), Vector3.new(x, 0.65, 3), C.Cyan, Enum.Material.Neon, false)
	end
	for _, z in { -4, 10 } do
		part("PadLight", Vector3.new(19.4, 0.08, 0.25), Vector3.new(0, 0.65, z), C.Cyan, Enum.Material.Neon, false)
	end
	P.SmoothPlastic(model)
	local pad = P.Part(parent, "ArenaTeleportPad", Vector3.new(16, 0.4, 12),
		CFrame.new(position + Vector3.new(0, 0.7, 3)), C.Cyan, Enum.Material.Neon, false)
	pad.Transparency = 1
	pad:SetAttribute("Role", "ArenaEntry")
end

function Lobby.Build(parent)
	local model = P.Model(parent, "Lobby")
	local center = Vector3.new(-20, 0, 12000)
	local function at(x, z)
		return center + Vector3.new(x * 0.65, 0, z * 0.6)
	end
	model:SetAttribute("Width", 156)
	model:SetAttribute("Depth", 112)
	P.Part(model, "LobbyFloor", Vector3.new(156, 3, 112), CFrame.new(center + Vector3.new(0, -1.5, 0)), C.Grass, nil, true)
	P.Part(model, "IslandBase", Vector3.new(156, 16, 112), CFrame.new(center + Vector3.new(0, -11, 0)), C.Stone, nil, true)
	P.Bounds(model, center, 156, 112)
	local rng = Random.new(137)
	for x = -13, 13 do
		for z = -9, 9 do
			local shade = rng:NextInteger(-6, 6)
			P.Part(model, "PlazaPaving", Vector3.new(7.94 * 0.65, 0.16, 7.94 * 0.6),
				CFrame.new(at(x * 8, z * 8) + Vector3.new(0, 0.04, 0)),
				Color3.fromRGB(210 + shade, 202 + shade, 178 + shade), nil, false)
		end
	end
	task.wait()
	-- A wide clear route joins the entrance, spawn and small walk-on portal.
	P.Part(model, "EntrancePaving", Vector3.new(20, 0.16, 12), CFrame.new(at(0, 82) + Vector3.new(0, 0.04, 0)), C.Paving, nil, false)
	teleporter(model, at(0, -62))
	leaderboard(model, at(-80, -50), "Leaderboard", "SERVER WINS", "PLAYERS IN THIS SERVER")
	leaderboard(model, at(80, -50), "KOLeaderboard", "SERVER KOs", "TOTAL KOs / THIS SERVER")
	for _, x in { -104, 104 } do
		for _, z in { -76, 76 } do
			local top = planter(model, at(x, z), Vector3.new(20, 0.8, 20), math.floor(x + z + 400))
			P.Tree(model, top, 0.85, x * 0.02 + z * 0.01)
		end
		for _, z in { -16, 24 } do
			local top = planter(model, at(x, z), Vector3.new(17, 0.8, 14), math.floor(x + z + 600))
			P.Rock(model, top, 0.55, z * 0.1, false, 0.65)
		end
	end
	for _, x in { -62, 62 } do
		local top = planter(model, at(x, 80), Vector3.new(30, 0.7, 10), x + 800)
		P.Rock(model, top, 0.6, x * 0.01, false, 0.65)
	end
	for _, x in { -103, 103 } do
		P.Bench(model, at(x, 4), x < 0 and math.pi / 2 or -math.pi / 2)
	end
	for _, x in { -62, 62 } do
		P.Bench(model, at(x, 67), 0)
		P.Bench(model, at(x, -77), math.pi)
	end
	P.Fence(model, at(-118, -90), at(-118, 90))
	P.Fence(model, at(118, -90), at(118, 90))
	P.Fence(model, at(-118, -90), at(118, -90))
	P.Fence(model, at(-118, 90), at(118, 90))
	for _, offset in {
		Vector3.new(-20, 0, -56), Vector3.new(20, 0, -56),
		Vector3.new(-54, 0, -50), Vector3.new(54, 0, -50),
		Vector3.new(-92, 0, -30), Vector3.new(92, 0, -30),
		Vector3.new(-92, 0, 47), Vector3.new(92, 0, 47),
		Vector3.new(-22, 0, 86), Vector3.new(22, 0, 86),
	} do
		P.Lamp(model, at(offset.X, offset.Z), 0.85)
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name, spawn.Size, spawn.CFrame = "PilotLobbySpawn", Vector3.new(8, 1, 8), CFrame.new(at(0, -10) + Vector3.new(0, 0.5, 0))
	spawn.Anchored, spawn.Neutral, spawn.Duration = true, true, 0
	spawn.Transparency, spawn.CanCollide, spawn.CanTouch = 1, false, false
	spawn.Parent = model
	task.wait()
	return model
end

return Lobby
