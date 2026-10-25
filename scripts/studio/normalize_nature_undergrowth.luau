local folder = game.ServerStorage.MapProps.LowPolyNature
local specs = {
	BushA = {125190783968134, Vector3.new(4, 2, 3)},
	BushB = {136381056003772, Vector3.new(5, 2.4, 4)},
	FlowerClump = {106816410291370, Vector3.new(2, 1.2, 2)},
}
local colors = {Base_6FAE4A = Color3.fromRGB(111, 174, 74), Shade_4C8A3A = Color3.fromRGB(76, 138, 58),
	Stem_4C8A3A = Color3.fromRGB(76, 138, 58), Petal_F2E7CC = Color3.fromRGB(242, 231, 204)}
local results = {}
for name, spec in specs do
	local model = folder:FindFirstChild(name) or folder:FindFirstChild("BE_Nature_" .. name .. "_Import")
	assert(model and model:IsA("Model"), "Missing plant: " .. name)
	local _, size = model:GetBoundingBox()
	assert((size - spec[2]).Magnitude < 0.03, "Wrong plant dimensions")
	model:PivotTo(CFrame.new())
	local frame, normalized = model:GetBoundingBox()
	assert(math.abs(frame.Position.Y - normalized.Y / 2) < 0.01, "Wrong plant base pivot")
	local count = 0
	for _, p in model:GetDescendants() do
		if p:IsA("PackageLink") then
			p:Destroy()
		elseif p:IsA("BasePart") then
			assert(p:IsA("MeshPart"), "Unexpected plant part")
			local matched
			for role, color in colors do
				if string.sub(p.Name, -#role) == role then
					p.Color, matched = color, role
				end
			end
			assert(matched, "Unknown plant component")
			p.Material, p.TextureID, p.DoubleSided = Enum.Material.SmoothPlastic, "", true
			p.Anchored, p.CanCollide, p.CanQuery, p.CanTouch = true, false, false, false
			p:SetAttribute("NatureColorRole", matched)
			p:SetAttribute("SourceAssetId", spec[1])
			count += 1
		elseif p:IsA("LuaSourceContainer") then
			error("Unexpected script in imported plant")
		end
	end
	assert(count == 2, "Expected two plant color components")
	model.Name = name
	model:SetAttribute("SourceAssetId", spec[1])
	model:SetAttribute("TemplateName", name)
	model:SetAttribute("Style", "LowPolyNature")
	model:SetAttribute("ImportVerified", true)
	table.insert(results, {name = name, size = {normalized.X, normalized.Y, normalized.Z}, parts = count})
end
return game:GetService("HttpService"):JSONEncode(results)
