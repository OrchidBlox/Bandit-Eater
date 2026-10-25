local history = game:GetService("ChangeHistoryService")
-- MCP owns one recording around the command; standalone callers create one.
local recording
if not history:IsRecordingInProgress() then
	recording = assert(history:TryBeginRecording("BanditEaterNatureArena", "Arena: approved low-poly nature"))
end
local environment = workspace.BanditEaterPilot.Environment
local ok, result = pcall(function()
	local source = game.ServerScriptService.Server.Services.NatureArenaPolish:Clone()
	local nature = require(source)
	source:Destroy()
	assert(nature.Apply(environment), "Nature arena preflight failed")
	assert(nature.RefreshFacades(environment), "Nature facade migration failed")
	local treeSource = game.ServerScriptService.Server.Services.NatureArenaTrees:Clone()
	local trees = require(treeSource)
	treeSource:Destroy()
	assert(trees.Apply(environment), "Nature tree preflight failed")
	-- Migrate the first preview's noncolliding facade copies to visible collision.
	local decor = environment.GrasslandArena.NatureDecor
	for _, model in decor:GetChildren() do
		if model:IsA("Model") and string.sub(model.Name, 1, 5) == "Cliff" then
			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") then
					part.CanCollide = string.find(part.Name, "_Base_", 1, true) ~= nil
					part.CanQuery = true
				end
			end
		end
	end
	return { revision = environment.GrasslandArena:GetAttribute("NatureRevision"),
		decorRoots = #decor:GetChildren(), trees = #decor.Trees:GetChildren(),
		archivedRoots = #game.ServerStorage.PolishOld.Arena_Nature_v1:GetChildren() }
end)
if recording then
	history:FinishRecording(recording, ok and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
end
assert(ok, tostring(result))
return game:GetService("HttpService"):JSONEncode(result)
