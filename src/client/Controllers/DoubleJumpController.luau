local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Shared = game:GetService("ReplicatedStorage").Shared
local Remotes = require(Shared.Remotes)
local Config = require(Shared.Config.Movement)
local Controller = {}
local connections = {}
local held = false

function Controller.Stop()
	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)
	held = false
end

function Controller.Start()
	if #connections > 0 then return end
	table.insert(connections, UIS.JumpRequest:Connect(function()
		if held or UIS:GetFocusedTextBox() then return end
		held = true -- JumpRequest can repeat while a single press is held.
		local character = Players.LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end
		local mode = humanoid:GetState()
		if humanoid.FloorMaterial == Enum.Material.Air
			and (mode == Enum.HumanoidStateType.Jumping or mode == Enum.HumanoidStateType.Freefall) then
			Remotes.DoubleJump:FireServer(character)
		end
	end))
	table.insert(connections, UIS.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA
			or input.UserInputType == Enum.UserInputType.Touch then
			held = false
		end
	end))
	table.insert(connections, UIS.WindowFocusReleased:Connect(function()
		held = false
	end))
	table.insert(connections, Players.LocalPlayer.CharacterAdded:Connect(function()
		held = false
	end))
	table.insert(connections, Remotes.DoubleJump.OnClientEvent:Connect(function(character)
		if character ~= Players.LocalPlayer.Character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or humanoid.Health <= 0 or not root or humanoid.FloorMaterial ~= Enum.Material.Air then return end
		-- Apply the approved impulse on the owning client as well as the server.
		local velocity = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(velocity.X, Config.DoubleJumpVelocity, velocity.Z)
	end))
	table.insert(connections, script.Destroying:Connect(Controller.Stop))
end

return Controller
