local World = {}
local yellow = Color3.fromRGB(250, 207, 65)

function World.Part(parent, name, size, cf, color, collide)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
	p.Anchored, p.CanCollide = true, collide == true
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

function World.Label(part, text)
	local gui = Instance.new("BillboardGui")
	gui.Size, gui.StudsOffset, gui.MaxDistance = UDim2.fromScale(9, 2), Vector3.new(0, 4, 0), 110
	local label = Instance.new("TextLabel")
	label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
	label.Text, label.TextScaled, label.TextColor3 = text, true, Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.3
	label.Parent, gui.Parent = gui, part
end

function World.Dummy(parent, name, position, color, variant)
	local m = Instance.new("Model")
	m.Name = name
	local root = World.Part(m, "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(position + Vector3.new(0, 3, 0)), yellow, false)
	root.Transparency = 1
	m.PrimaryPart = root
	World.Part(m, "Torso", Vector3.new(2, 2, 1), root.CFrame, yellow, false)
	World.Part(m, "Head", Vector3.new(1.5, 1.5, 1.5), root.CFrame * CFrame.new(0, 1.75, 0), yellow, false)
	for _, x in { -1.5, 1.5 } do
		World.Part(m, "Arm", Vector3.new(1, 2, 1), root.CFrame * CFrame.new(x, 0, 0), yellow, false)
	end
	for _, x in { -0.5, 0.5 } do
		World.Part(m, "Leg", Vector3.new(1, 2, 1), root.CFrame * CFrame.new(x, -2, 0), yellow, false)
	end
	local tell = World.Part(m, "PowerTell", Vector3.new(1.7, 0.4, 1.7), root.CFrame * CFrame.new(0, 2.8, 0), color, false)
	tell.Material = Enum.Material.Neon
	if name == "Sword" then
		World.Part(m, "Blade", Vector3.new(0.3, 4, 0.7), root.CFrame * CFrame.new(2, 0.8, 0), color, false)
	elseif name == "Earth" then
		tell.Size = Vector3.new(2, 1.5, 2)
	elseif name == "Water" or name == "Shadow" then
		tell.Shape = Enum.PartType.Ball
		tell.Size = Vector3.new(1.5, 1.5, 1.5)
	elseif name == "Fire" then
		tell.CFrame *= CFrame.Angles(0, 0, math.pi / 4)
		tell.Size = Vector3.new(1, 2, 1)
	end
	m:SetAttribute("PowerId", name)
	m:SetAttribute("Variant", variant or "Normal")
	World.Label(root, (variant and variant ~= "Normal" and variant .. " " or "") .. name)
	m.Parent = parent
	return m
end

function World.Build()
	local environment = require(script.Parent.PilotEnvironment)
	local folder = workspace:FindFirstChild("BanditEaterPilot")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "BanditEaterPilot"
		folder.Parent = workspace
	end
	World.Root = folder
	local scenery = environment.Build(folder)
	World.Environment = scenery
	World.ArenaFloor = scenery:FindFirstChild("ArenaFloor", true)
	World.Spawn = scenery:FindFirstChild("PilotLobbySpawn", true)
	World.ArenaTeleportPad = scenery:FindFirstChild("ArenaTeleportPad", true)
	World.Leaderboard = scenery.Lobby.Leaderboard
	World.KOLeaderboard = scenery.Lobby.KOLeaderboard
	World.BanditPosition = environment.BanditPosition
	World.PlayerSpawnPosition = environment.PlayerSpawnPosition
	World.LobbyPosition = World.Spawn.Position + Vector3.new(0, 4.5, 0)
end
return World
