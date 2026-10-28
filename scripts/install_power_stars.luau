-- Studio Edit command, after syncing Shared.PowerStarVisual and inserting model 76772447924708
-- into ReplicatedStorage as BE_PowerStar_Import. Existing library is preserved for rollback.
local rs = game:GetService("ReplicatedStorage")
local ch = game:GetService("ChangeHistoryService")
assert(not game:GetService("RunService"):IsRunning(), "Install in Edit mode")
local imported = assert(rs:FindFirstChild("BE_PowerStar_Import"), "Insert model 76772447924708 first")
local source = assert(imported:FindFirstChildWhichIsA("MeshPart", true), "Imported body missing")
local factory = require(rs.Shared.PowerStarVisual)
local folder = Instance.new("Folder")
folder.Name = "PowerStars"
local template = source:Clone()
template:ClearAllChildren()
template.Name = "Body"
template.Size = Vector3.new(2.8748038, 2.7506738, 1.14)
template.CFrame = CFrame.identity
template.Anchored = true
template.CanCollide, template.CanTouch, template.CanQuery = false, false, false
template.Parent = folder
for _, power in { "Wind", "Earth", "Water", "Fire", "Sword", "Shadow" } do
	factory.Create(power, template).Parent = folder
end
local recording = ch:TryBeginRecording("PowerStarAssets")
local assets = rs:FindFirstChild("Assets") or Instance.new("Folder")
assets.Name, assets.Parent = "Assets", rs
local old = assets:FindFirstChild("PowerStars")
if old then
	old.Name = "PowerStarsPrevious_" .. os.time()
	old.Parent = game:GetService("ServerStorage")
end
folder.Parent = assets
imported:Destroy()
if recording then
	ch:FinishRecording(recording, Enum.FinishRecordingOperation.Commit)
end
print("Power Star library installed: six base powers, no fusion pickups")
