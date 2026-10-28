-- Shared by initial world setup and nature polish so the look does not depend on build order.
local Lighting = game:GetService("Lighting")
local EnvironmentLighting = {}

local function effect(name, className)
	local current = Lighting:FindFirstChild(name)
	if current and current:IsA(className) then return current end
	local created = Instance.new(className)
	created.Name, created.Parent = name, Lighting
	return created
end

function EnvironmentLighting.Apply()
	local softLightingApplied = pcall(function()
		Lighting.LightingStyle = Enum.LightingStyle.Soft
		Lighting.PrioritizeLightingQuality = true
	end)
	Lighting:SetAttribute("NatureShadowMapApplied", softLightingApplied)
	Lighting.ClockTime, Lighting.Brightness = 16.5, 2.5
	Lighting.Ambient = Color3.fromRGB(125, 143, 160)
	Lighting.OutdoorAmbient = Color3.fromRGB(160, 176, 192)
	Lighting.ExposureCompensation, Lighting.GlobalShadows = 0, true
	Lighting.ShadowSoftness = 0.75
	Lighting.EnvironmentDiffuseScale, Lighting.EnvironmentSpecularScale = 0.6, 0.25
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or effect("PilotAtmosphere", "Atmosphere")
	atmosphere.Name = "PilotAtmosphere"
	atmosphere.Density, atmosphere.Offset = 0.3, 0.1
	atmosphere.Haze, atmosphere.Glare = 1, 0
	atmosphere.Color = Color3.fromRGB(214, 232, 240)
	atmosphere.Decay = Color3.fromRGB(190, 205, 220)
	local bloom = effect("PilotBloom", "BloomEffect")
	-- Gentle highlights keep the cyan gate and white combat puffs from washing out.
	bloom.Enabled, bloom.Intensity, bloom.Size, bloom.Threshold = true, 0.08, 20, 2
	local grade = effect("PilotColor", "ColorCorrectionEffect")
	grade.Enabled = true
	grade.Brightness, grade.Contrast, grade.Saturation = 0, 0.05, 0
	grade.TintColor = Color3.fromRGB(255, 253, 248)
	return softLightingApplied
end

return EnvironmentLighting
