local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Faces = require(ReplicatedStorage.Shared.PilotSkyConfig)
local Controller = {}
local started = false

function Controller.Start()
	if started then
		return
	end
	started = true
	task.spawn(function()
		local assets = {}
		for _, asset in Faces do
			table.insert(assets, asset)
		end
		-- New uploads can still be processing. Keep the existing sky until all load.
		task.spawn(function()
			pcall(function()
				ContentProvider:PreloadAsync(assets)
			end)
		end)
		for _ = 1, 150 do
			local ready = true
			for _, asset in assets do
				ready = ready and ContentProvider:GetAssetFetchStatus(asset) == Enum.AssetFetchStatus.Success
			end
			if ready then
				local sky = Instance.new("Sky")
				sky.Name = "PilotCloudSky"
				for property, asset in Faces do
					sky[property] = asset
				end
				sky.CelestialBodiesShown, sky.StarCount = false, 0
				for _, previous in Lighting:GetChildren() do
					if previous:IsA("Sky") then
						previous:Destroy()
					end
				end
				sky.Parent = Lighting
				return
			end
			task.wait(2)
		end
		warn("[PilotSky] Cloud textures unavailable; keeping the existing sky.")
	end)
end

return Controller
