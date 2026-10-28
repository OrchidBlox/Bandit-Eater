-- Edit-mode installer. First insert the seven BE_PowerMesh_* model assets
-- listed in docs/power-mesh-installed.md into Workspace with Studio insert_asset.
local specs={Droplet={131415644286650},Flame={102251088549327},Leaf={102739312973688},MasterSword={123850029359018,74015133819972},ShadowOrb={95185057003645,74726169660937},Sword={113097489818221,107578941879603},Wave={117701836399171,101823800043202}}
local history=game:GetService("ChangeHistoryService")
local recording=history:TryBeginRecording("InstallApprovedPowerMeshes")
local folder=game.ReplicatedStorage.Assets.PowerMoves
local archive=game.ServerStorage:FindFirstChild("PolishOld") or Instance.new("Folder",game.ServerStorage) archive.Name="PolishOld"
local results={}
for name,spec in specs do
 local model=workspace:FindFirstChild("BE_PowerMesh_"..name)
 assert(model,name)
 local mesh=model:FindFirstChildWhichIsA("MeshPart",true) assert(mesh,name)
 local old=folder:FindFirstChild(name) if old then old.Parent=archive end
 mesh.Size/=100 mesh.CFrame=CFrame.identity mesh.Name=name mesh.Anchored=true mesh.CanCollide=false mesh.CanTouch=false mesh.CanQuery=false mesh.CastShadow=false mesh.Material=Enum.Material.SmoothPlastic mesh.Color=Color3.new(1,1,1)
 for _,child in mesh:GetDescendants() do if child:IsA("PackageLink") or child:IsA("SurfaceAppearance") then child:Destroy() end end
 mesh.TextureID=spec[2] and "rbxassetid://"..spec[2] or ""
 mesh:SetAttribute("SourceAssetId",spec[1]) mesh.Parent=folder model:Destroy()
 table.insert(results,name)
end
if recording then history:FinishRecording(recording,Enum.FinishRecordingOperation.Commit) end
return results
