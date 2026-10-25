-- One area recording; Studio MCP already wraps this command when invoked there.
local history = game:GetService("ChangeHistoryService")
local recording
if not history:IsRecordingInProgress() then
	recording = assert(history:TryBeginRecording("BanditEaterNatureLobby", "Lobby: low-poly nature"))
end
local ok, result = pcall(function()
	local source = game.ServerScriptService.Server.Services.NatureLobbyPolish:Clone()
	local polish = require(source)
	source:Destroy()
	assert(polish.Apply(workspace.BanditEaterPilot.Environment), "Lobby preflight failed")
	local decor = workspace.BanditEaterPilot.Environment.Lobby.NatureDecor
	return { attributes = decor:GetAttributes(),
		archivedRoots = #game.ServerStorage.PolishOld.Lobby_Nature_v1:GetChildren() }
end)
if recording then
	history:FinishRecording(recording, ok and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
end
assert(ok, tostring(result))
return game:GetService("HttpService"):JSONEncode(result)
