-- Match the lobby gardens and plaza to the painted cartoon meadow.
-- All replacements preserve dimensions, transforms and collision flags.
local ServerStorage = game:GetService("ServerStorage")
local MaterialService = game:GetService("MaterialService")
local LobbyMeadow = {}
local NAMES = { TexturedGrass = true, GrassBed = true, StoneBed = true,
	PlazaPaving = true, EntrancePaving = true }

function LobbyMeadow.Apply(environment)
	local lobby = environment:FindFirstChild("Lobby")
	local decor = lobby and lobby:FindFirstChild("NatureDecor")
	local floor = lobby and lobby:FindFirstChild("LobbyFloor")
	if not decor or not floor then return false end
	if decor:GetAttribute("MeadowRevision") == 1 then return true end
	local replacements = {}
	for _, original in decor:GetDescendants() do
		if not original:IsA("BasePart") or not NAMES[original.Name] then continue end
		local copy = original:Clone()
		copy.Material = Enum.Material.SmoothPlastic
		if MaterialService:FindFirstChild("BE_MeadowMatte") then
			copy.MaterialVariant = "BE_MeadowMatte"
		end
		for _, face in { "Top", "Bottom", "Left", "Right", "Front", "Back" } do
			copy[face .. "Surface"] = Enum.SurfaceType.Smooth
		end
		if original.Name == "TexturedGrass" or original.Name == "GrassBed" then
			copy.Color = Color3.fromRGB(112, 157, 78)
			local texture = Instance.new("Texture")
			texture.Name, texture.Face = "PaintedMeadow", Enum.NormalId.Top
			texture.Texture = "rbxassetid://83475692374597"
			texture.StudsPerTileU, texture.StudsPerTileV = 48, 48
			texture.Transparency = 0.45
			texture.Parent = copy
		elseif original.Name == "StoneBed" then
			copy.Color = Color3.fromRGB(165, 168, 151)
		else
			local p = floor.CFrame:PointToObjectSpace(original.Position)
			local variation = (math.floor(p.X * 3) + math.floor(p.Z * 7)) % 5 - 2
			-- Quiet limestone variation, with a warmer central approach to the gate.
			local center = math.abs(p.X) < 12 and 5 or 0
			copy.Color = Color3.fromRGB(199 + variation * 2 + center,
				190 + variation * 2 + center, 166 + variation * 2 + center)
		end
		table.insert(replacements, { original = original, copy = copy, parent = original.Parent })
	end
	if #replacements == 0 then return false end
	local root = ServerStorage:FindFirstChild("PolishOld") or Instance.new("Folder")
	root.Name, root.Parent = "PolishOld", ServerStorage
	local archive = Instance.new("Folder")
	archive.Name, archive.Parent = "LobbyMeadow_" .. os.time(), root
	for i, item in replacements do
		item.original:SetAttribute("MeadowOriginalParent", item.parent:GetFullName())
		item.original.Parent = archive
		item.copy.Parent = item.parent
		if i % 100 == 0 then
			task.wait()
		end
	end
	decor:SetAttribute("MeadowRevision", 1)
	decor:SetAttribute("MeadowArchive", archive:GetFullName())
	decor:SetAttribute("MeadowSurfaceCount", #replacements)
	return true
end

return LobbyMeadow
