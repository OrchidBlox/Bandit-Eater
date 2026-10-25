-- Run once in Studio Edit after inserting the seven group-owned FBX models.
local folder = game:GetService("ServerStorage"):WaitForChild("MapProps"):WaitForChild("LowPolyNature")
local specs = {
	CliffStraightA = { 106682946832392, Vector3.new(48, 28, 12) },
	CliffStraightB = { 72135883362231, Vector3.new(48, 24, 12) },
	CliffCorner = { 112073249066625, Vector3.new(26, 30, 26) },
	CliffEnd = { 126597751109815, Vector3.new(12, 24, 12) },
	RockSmall = { 118888082757921, Vector3.new(12, 3, 8) },
	RockMedium = { 139537776658541, Vector3.new(16, 3.3, 11) },
	RockLarge = { 124517673828669, Vector3.new(20, 3.6, 13) },
}
local report = {}
for name, spec in specs do
	local model = folder:FindFirstChild(name) or folder:FindFirstChild("BE_Nature_" .. name .. "_Import")
	assert(model and model:IsA("Model"), "Missing imported template " .. name)
	local _, size = model:GetBoundingBox()
	assert((size - spec[2]).Magnitude < 0.01, "Unexpected import scale/axes: " .. name .. " " .. tostring(size))
	model:PivotTo(CFrame.new())
	local cf, normalizedSize = model:GetBoundingBox()
	assert(math.abs(cf.Position.Y - normalizedSize.Y / 2) < 0.01, "Expected base pivot: " .. name)
	local meshes = 0
	for _, part in model:GetDescendants() do
		if part:IsA("PackageLink") then
			part:Destroy()
		elseif part:IsA("BasePart") then
			assert(part:IsA("MeshPart"), "Unexpected non-mesh part")
			meshes += 1
			local shade = part.Name:find("Shade_5F6672", 1, true) ~= nil
			assert(shade or part.Name:find("Base_8A8F99", 1, true), "Unknown colour component")
			part.Color = shade and Color3.fromRGB(95, 102, 114) or Color3.fromRGB(138, 143, 153)
			part.Material = Enum.Material.SmoothPlastic
			part.Anchored, part.CanCollide, part.CanQuery, part.CanTouch = true, false, false, false
			part.TextureID = ""
			part.DoubleSided = true
			part.CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition
			part:SetAttribute("NatureColorRole", shade and "Shade" or "Base")
			part:SetAttribute("SourceAssetId", spec[1])
		elseif part:IsA("LuaSourceContainer") then
			error("Unexpected script in authored mesh import")
		end
	end
	assert(meshes == 2, "Expected two material components: " .. name)
	model.Name = name
	model:SetAttribute("SourceAssetId", spec[1])
	model:SetAttribute("Style", "LowPolyNature")
	model:SetAttribute("TemplateName", name)
	model:SetAttribute("ImportVerified", true)
	table.insert(report, { name = name, size = {normalizedSize.X, normalizedSize.Y, normalizedSize.Z},
		baseY = cf.Position.Y - normalizedSize.Y / 2, meshParts = meshes, sourceAssetId = spec[1] })
end
return game:GetService("HttpService"):JSONEncode(report)
