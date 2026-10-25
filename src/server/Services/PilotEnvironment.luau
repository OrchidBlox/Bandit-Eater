local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")
local P = require(script.Parent.EnvironmentProps)
local Lobby = require(script.Parent.EnvironmentLobby)
local Arena = require(script.Parent.EnvironmentArena)
local NatureArenaPolish = require(script.Parent.NatureArenaPolish)
local NatureArenaTrees = require(script.Parent.NatureArenaTrees)
local NatureLobbyPolish = require(script.Parent.NatureLobbyPolish)
local Environment = { Version = 5 }
Environment.BanditPosition = Arena.BanditPosition
Environment.PlayerSpawnPosition = Arena.PlayerSpawnPosition

local function lighting()
	Lighting.ClockTime = 14
	Lighting.Brightness = 2.2
	Lighting.Ambient = Color3.fromRGB(145, 150, 135)
	Lighting.OutdoorAmbient = Color3.fromRGB(162, 175, 150)
	Lighting.ExposureCompensation = 0
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.6
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.35
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Name = "PilotAtmosphere"
	atmosphere.Density, atmosphere.Offset, atmosphere.Haze, atmosphere.Glare = 0.23, 0.1, 0.7, 0.1
	atmosphere.Color, atmosphere.Decay = Color3.fromRGB(207, 230, 248), Color3.fromRGB(171, 185, 162)
	atmosphere.Parent = Lighting
	local bloom = Lighting:FindFirstChild("PilotBloom") or Instance.new("BloomEffect")
	bloom.Name, bloom.Intensity, bloom.Size, bloom.Threshold = "PilotBloom", 0.06, 20, 2
	bloom.Parent = Lighting
	local grade = Lighting:FindFirstChild("PilotColor") or Instance.new("ColorCorrectionEffect")
	grade.Name, grade.Brightness, grade.Contrast, grade.Saturation = "PilotColor", 0, 0.02, 0.1
	grade.Parent = Lighting
end

function Environment.Build(root)
	lighting()
	local existing = root:FindFirstChild("Environment")
	if existing and existing:GetAttribute("Version") == Environment.Version then
		NatureArenaPolish.Apply(existing)
		NatureArenaTrees.Apply(existing)
		NatureLobbyPolish.Apply(existing)
		return existing
	end
	if existing then
		local backups = ServerStorage:FindFirstChild("EnvironmentBackups") or Instance.new("Folder")
		backups.Name, backups.Parent = "EnvironmentBackups", ServerStorage
		existing.Name = "Environment_" .. tostring(os.time())
		existing.Parent = backups
	end
	-- Keep the template baseplate/spawn available for undo, outside the playable scene.
	local originals = ServerStorage:FindFirstChild("EnvironmentOriginals") or Instance.new("Folder")
	originals.Name, originals.Parent = "EnvironmentOriginals", ServerStorage
	for _, name in { "Baseplate", "SpawnLocation" } do
		local old = workspace:FindFirstChild(name)
		if old and old:IsA("BasePart") then
			old.Parent = originals
		end
	end
	local model = P.Model(root, "Environment")
	model:SetAttribute("Version", Environment.Version)
	model:SetAttribute("Source", "Approved lobby and grassland-arena-v2 concepts")
	Arena.Build(model)
	Lobby.Build(model)
	local backdrop = P.Model(model, "Backdrop")
	local sea = P.Part(backdrop, "Ocean", Vector3.new(2600, 2, 2600), CFrame.new(0, -18, 0), Color3.fromRGB(65, 162, 192), Enum.Material.Glass, false)
	sea.Transparency, sea.Reflectance = 0.2, 0.12
	local rng = Random.new(181)
	for i = 1, 14 do
		local angle = i * math.pi * 2 / 14
		local radius = 800 + rng:NextNumber(0, 220)
		local height = rng:NextNumber(20, 60)
		local position = Vector3.new(math.cos(angle) * radius, height / 2 - 20, math.sin(angle) * radius)
		local size = Vector3.new(rng:NextNumber(28, 55), height, rng:NextNumber(25, 45))
		P.Part(backdrop, "DistantRockIsland", size, CFrame.new(position) * CFrame.Angles(0, angle, 0), Color3.fromRGB(136, 151, 147), Enum.Material.Slate, false)
		P.Part(backdrop, "DistantGrassCap", Vector3.new(size.X, 1, size.Z), CFrame.new(position + Vector3.new(0, size.Y / 2, 0)) * CFrame.Angles(0, angle, 0),
			Color3.fromRGB(111, 153, 72):Lerp(Color3.new(0, 0, 0), 0.28), Enum.Material.Grass, false)
	end
	NatureArenaPolish.Apply(model)
	NatureArenaTrees.Apply(model)
	NatureLobbyPolish.Apply(model)
	task.wait()
	return model
end

return Environment
