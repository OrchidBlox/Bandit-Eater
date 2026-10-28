-- Cosmetic factory only: spawn authority, capture and power grants belong to the server.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Visuals = require(script.Parent.Config.PowerVisuals)
local PowerStarVisual = {}
local basePowers = { Wind = true, Earth = true, Water = true, Fire = true, Sword = true, Shadow = true }

function PowerStarVisual.Create(power, template)
	assert(basePowers[power], "Only base powers have Power Stars")
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local folder = assets and assets:FindFirstChild("PowerStars")
	template = template or (folder and folder:FindFirstChild("Body"))
	assert(template and template:IsA("MeshPart"), "Power Star Body template missing")
	local visual = Visuals.Powers[power]
	local body = template:Clone()
	body:ClearAllChildren()
	body.Name = power
	body.Size = Vector3.new(2.8748038, 2.7506738, 1.14)
	body.CFrame = CFrame.identity
	body.Anchored = true
	body.CanCollide, body.CanTouch, body.CanQuery = false, false, false
	body.CastShadow = false
	body.Material = Enum.Material.SmoothPlastic
	body.TextureID = ""
	body.Color = visual.Body:Lerp(Color3.fromRGB(255, 229, 132), 0.25)
	body:SetAttribute("Power", power)
	body:SetAttribute("SourceAssetId", "76772447924708")
	for _, face in { Enum.NormalId.Front, Enum.NormalId.Back } do
		local gui = Instance.new("SurfaceGui")
		gui.Name = "Emblem" .. face.Name
		gui.Face = face
		gui.CanvasSize = Vector2.new(512, 512)
		gui.LightInfluence = 0
		gui.AlwaysOnTop = false
		local icon = Instance.new("ImageLabel")
		icon.Name = "PowerIcon"
		icon.BackgroundTransparency = 1
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.fromScale(0.5, 0.48)
		icon.Size = UDim2.fromScale(0.46, 0.48)
		icon.Image = visual.Icon
		icon.Parent = gui
		gui.Parent = body
	end
	return body
end

-- Optional display motion; caller supplies a stable base transform and elapsed seconds.
function PowerStarVisual.Pose(base, elapsed, phase)
	local t = elapsed + (phase or 0)
	return base * CFrame.new(0, math.abs(math.sin(t * 2.4)) * 0.65, 0)
		* CFrame.Angles(0, t * 0.65, math.sin(t * 2.4) * 0.08)
end

return PowerStarVisual
