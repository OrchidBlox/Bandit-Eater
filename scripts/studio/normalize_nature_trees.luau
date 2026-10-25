local folder = game.ServerStorage.MapProps.LowPolyNature
local specs = {
	TreeRoundA = {89085584690121, Vector3.new(22,27,20)},
	TreeRoundB = {81178575091325, Vector3.new(20,25,18)},
	TreeRoundC = {73468058864125, Vector3.new(24,29,22)},
}
local colors = {LeafBase_6FAE4A=Color3.fromRGB(111,174,74), LeafShade_4C8A3A=Color3.fromRGB(76,138,58),
	TrunkBase_7A5236=Color3.fromRGB(122,82,54), TrunkShade_62412C=Color3.fromRGB(98,65,44)}
local results = {}
for name, spec in specs do
	local m = folder:FindFirstChild(name) or folder:FindFirstChild("BE_Nature_"..name.."_Import")
	assert(m and m:IsA("Model"), "Missing tree "..name)
	local _,size=m:GetBoundingBox()
	assert((size-spec[2]).Magnitude<0.03,"Wrong tree import dimensions")
	m:PivotTo(CFrame.new())
	local cf,normalized=m:GetBoundingBox()
	assert(math.abs(cf.Position.Y-normalized.Y/2)<0.01,"Wrong tree base pivot")
	local count=0
	for _,p in m:GetDescendants() do
		if p:IsA("PackageLink") then p:Destroy()
		elseif p:IsA("BasePart") then
			assert(p:IsA("MeshPart"),"Unexpected tree part")
			local matched
			for role,color in colors do
				if string.sub(p.Name,-#role)==role then
					p.Color=color
					matched=role
				end
			end
			assert(matched,"Unknown tree material component")
			p.Material=Enum.Material.SmoothPlastic
			p.TextureID=""
			p.DoubleSided=true
			p.Anchored,p.CanCollide,p.CanQuery,p.CanTouch=true,false,false,false
			p:SetAttribute("NatureColorRole",matched)
			p:SetAttribute("SourceAssetId",spec[1])
			count+=1
		elseif p:IsA("LuaSourceContainer") then
			error("Unexpected script")
		end
	end
	assert(count==4,"Expected four tree colour components")
	m.Name=name
	m:SetAttribute("SourceAssetId",spec[1])
	m:SetAttribute("TemplateName",name)
	m:SetAttribute("Style","LowPolyNature")
	m:SetAttribute("ImportVerified",true)
	table.insert(results,{name=name,size={normalized.X,normalized.Y,normalized.Z},baseY=cf.Position.Y-normalized.Y/2,parts=count})
end
return game:GetService("HttpService"):JSONEncode(results)
