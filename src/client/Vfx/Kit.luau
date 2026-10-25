local Kit = {}
local folder

function Kit.setFolder(value)
	folder = value
end

function Kit.folder()
	if not folder or not folder.Parent then
		folder = Instance.new("Folder")
		folder.Name, folder.Parent = "PilotVfx", workspace
	end
	return folder
end

function Kit.look(palette, distanceFactor, isOwn)
	return { palette = palette, distanceFactor = distanceFactor or 1, isOwn = isOwn == true }
end

function Kit.safePart(part)
	part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
	part.CastShadow = false
	return part
end

function Kit.sprite(parent, texture, color)
	if type(texture) ~= "string" or not string.match(texture, "^rbxassetid://%d+$") then
		return nil
	end
	local carrier = Kit.safePart(Instance.new("Part"))
	carrier.Name, carrier.Size, carrier.Transparency = "Sprite", Vector3.new(0.05, 0.05, 0.05), 1
	local gui = Instance.new("BillboardGui")
	gui.Name, gui.AlwaysOnTop, gui.LightInfluence = "SpriteImage", false, 0
	gui.Size, gui.MaxDistance, gui.Adornee = UDim2.fromScale(1, 1), 180, carrier
	local label = Instance.new("ImageLabel")
	label.Name, label.BackgroundTransparency = "Image", 1
	label.Size, label.Image, label.ImageColor3 = UDim2.fromScale(1, 1), texture, color
	label.ImageTransparency = 1
	label.Parent, gui.Parent, carrier.Parent = gui, carrier, parent
	return { part = carrier, gui = gui, image = label }
end

function Kit.crescent(parent, template, color, transparency)
	if not template then
		return nil
	end
	local mesh = template:IsA("MeshPart") and template or template:FindFirstChildWhichIsA("MeshPart", true)
	if not mesh or mesh.MeshId == "" then
		return nil
	end
	local copy = Kit.safePart(mesh:Clone())
	for _, child in copy:GetChildren() do
		child:Destroy()
	end
	copy.Name, copy.Color, copy.Transparency = "Crescent", color, transparency
	copy.Material, copy.Parent = Enum.Material.Neon, parent
	return { part = copy, size = copy.Size, pivot = copy.PivotOffset.Position }
end

return Kit
