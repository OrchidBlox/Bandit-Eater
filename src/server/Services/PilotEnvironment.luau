local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")
local P = require(script.Parent.EnvironmentProps)
local Lobby = require(script.Parent.EnvironmentLobby)
local Arena = require(script.Parent.EnvironmentArena)
local NatureArenaPolish = require(script.Parent.NatureArenaPolish)
local NatureArenaTrees = require(script.Parent.NatureArenaTrees)
local NatureLobbyPolish = require(script.Parent.NatureLobbyPolish)
local Environment = { Version = 12, Elevation = 180, LobbyLift = 60 }

function Environment.BanditPosition(index)
	return Arena.BanditPosition(index) + Vector3.new(0, Environment.Elevation, 0)
end

function Environment.PlayerSpawnPosition(index)
	return Arena.PlayerSpawnPosition(index) + Vector3.new(0, Environment.Elevation, 0)
end

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
	model:SetAttribute("Elevation", Environment.Elevation)
	model:SetAttribute("LobbyElevation", Environment.Elevation + Environment.LobbyLift)
	model:SetAttribute("Source", "Approved lobby and grassland-arena-v2 concepts")
	Arena.Build(model)
	local lobby = Lobby.Build(model)
	lobby:PivotTo(lobby:GetPivot() + Vector3.new(0, Environment.LobbyLift, 0))
	model:PivotTo(model:GetPivot() + Vector3.new(0, Environment.Elevation, 0))
	NatureArenaPolish.Apply(model)
	NatureArenaTrees.Apply(model)
	NatureLobbyPolish.Apply(model)
	task.wait()
	return model
end

return Environment
