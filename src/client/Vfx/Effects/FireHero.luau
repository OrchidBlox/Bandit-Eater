-- Approved Flame mesh: solid candy shell, hot core, plume, and puff/star aftermath.
-- Q follows the authoritative release. R stays inside its nine-stud field.
-- No damage, hitstop, movement changes, new textures or per-effect connections.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Kit = require(script.Parent.Parent.Kit)
local Cartoon = require(script.Parent.Parent.Cartoon)
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local Fireball = require(script.Parent.FireballQ)
local Fire = {}
local orange = Color3.fromRGB(255,138,31)
local gold = Color3.fromRGB(255,211,77)
local shade = Color3.fromRGB(224,72,27)
local function ease(t)
 return math.sin(math.clamp(t,0,1)*math.pi/2)
end
function Fire.Play(data, look)
 if look.distanceFactor == 0 then return nil
 end
 if data.Key=="Q" or data.Key=="R" then return Fireball.Play(data,look) end
 local library=ReplicatedStorage:FindFirstChild("Assets")
 local template=library and library:FindFirstChild("PowerMoves")
 template=template and template:FindFirstChild("Flame")
 if not template or not template:IsA("MeshPart") then return nil
 end
 local q=data.Key=="Q"
 local group=Instance.new("Folder") 
 group.Name="FireHero_"..data.Token
 group.Parent=Kit.folder() 
 Debris:AddItem(group,data.Duration+2)
 local e={group=group,position=data.Origin,caster=data.Caster,partCount=0,meshFallbacks=0}
 local bodies,puffs,rim={},{},{}
 local function flame(color)
  local part=Kit.safePart(template:Clone())
  part:ClearAllChildren() 
 part.TextureID="" 
 part.Color=color
  part.Material=Enum.Material.SmoothPlastic 
 part.Transparency=1 
 part.Parent=group
  e.partCount+=1 
 return part

 end
 -- Shell and core share the dominant silhouette; supporting lobes have separate arcs.
 for i=1,q and 3 or 7 do 
 
 
 
 bodies[i]=flame(i==2 and gold or i==1 and shade or orange)
 end
 for i=1,q and 5 or 6 do
  local sprite=Cartoon.sprite(group,i%3==0 and Config.Textures.Star or Config.Textures.Puff,
   i%3==0 and gold or Color3.new(1,1,1))
  if sprite then 
 table.insert(puffs,sprite) 
 
 
 
 e.partCount+=1
 end

 end
 if not q then
  for i=1,12 do
   local part=Kit.safePart(Instance.new("Part"))
   part.Shape=Enum.PartType.Ball 
 part.Color=orange 
 part.Material=Enum.Material.SmoothPlastic
   part.Size=Vector3.new(1.6,0.12,1.6) 
 part.Parent=group
   rim[i]=part 
 e.partCount+=1
 
 end

 end
 local frame=CFrame.lookAt(data.Origin,data.Origin+data.Direction.Unit)
 local floorY=data.Origin.Y-2.7
 if not q then
  local params=RaycastParams.new() 
 params.FilterType=Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances={data.Caster,group} 
 params.RespectCanCollide=true
  local hit=workspace:Raycast(data.Origin,Vector3.new(0,-15,0),params)
  if hit then 
 
 
 
 floorY=hit.Position.Y+0.08
 end

 end
 local function place(part,cf,size,opacity)
  part.CFrame=cf 
 part.Size=Vector3.new(math.max(.02,size.X),math.max(.02,size.Y),math.max(.02,size.Z))
  part.Transparency=1-math.clamp(opacity,0,1)

 end
 function e:Destroy()
  if self.destroyed then return
 end
  self.destroyed=true 
 group:Destroy()

 end
 function e:Release(origin,direction,time)
  frame=CFrame.lookAt(origin,origin+direction.Unit) 
 self.releaseAt=time

 end
 function e:Stop(impact,position)
  if not impact then 
 self:Destroy() 
 
 
 
 return
 end
  if self.impactAt then return
 end
  self.impactAt=workspace:GetServerTimeNow() 
 self.impactPosition=position or self.position
  if look.isOwn and look.bump then 
 
 
 
 look.bump(.035)
 end

 end
 function e:Update(now)
  if self.destroyed or not group.Parent then return false
 end
  local elapsed=math.max(0,now-data.StartedAt)
  local delay=data.Delay or .18
  local charge=math.clamp(elapsed/math.max(.01,delay),0,1)
  local release=q and self.releaseAt or data.StartedAt+delay
  local active=release~=nil and now>=release
  local t=active and now-release or 0
  if active and not self.punched then
   self.punched=true
   if look.isOwn and look.bump then 
 
 
 
 look.bump(q and .02 or .045)
 end
 
 end
  local fade=math.clamp((data.StartedAt+data.Duration-now)/.22,0,1)
  if self.impactAt then
   local impact=math.max(0,now-self.impactAt)
   if impact>.42 then return false
 end
   local u=impact/.42 
 local expansion=ease(u)
   for i,part in bodies do
    local a=i*math.pi*2/#bodies
    local p=self.impactPosition+Vector3.new(math.cos(a)*2.1*expansion,.2+expansion,math.sin(a)*2.1*expansion)
    place(part,CFrame.new(p)*CFrame.Angles(0,a,-.45),Vector3.new(2.2,3.6,2)*(1-u)*(1+.2*math.sin(u*math.pi)),1-u)
  
 end
   for i,s in puffs do
    local a=i*math.pi*2/#puffs
    Cartoon.placeSprite(s,CFrame.new(self.impactPosition+Vector3.new(math.cos(a)*3.5*expansion,.5+u*2,math.sin(a)*3.5*expansion)),1.2+u*2.2,1-u,i*35+u*40)
  
 end
   return true
 
 end
  if now>data.StartedAt+data.Duration+.3 then return false
 end
  if q then
   if not active then
    local root=data.Caster:FindFirstChild("HumanoidRootPart")
    if not root then return false
 end
    local muzzle=root.Position+Vector3.new(0,.35,0)+root.CFrame.LookVector*2
    frame=CFrame.lookAt(muzzle,muzzle+root.CFrame.LookVector)
  
 end
   local flight=frame*CFrame.new(0,0,-t*data.Speed)
   self.position=flight.Position
   local pop=1+.2*math.sin(math.clamp(t/.18,0,1)*math.pi)
   local size=active and pop or .25+charge*.6
   -- Flame tip points back along +Z: a comet-like plume instead of a standing candle.
   local roll=CFrame.Angles(math.pi/2,0,math.sin(t*11)*.14)
   place(bodies[1],flight*roll,Vector3.new(3.5,4.6,3.1)*size,fade)
   place(bodies[2],flight*CFrame.new(0,0,-.65)*roll,Vector3.new(2.6,3.3,2.5)*size,fade)
   place(bodies[3],flight*CFrame.new(0,.15,1.35)*roll,Vector3.new(2.2,3.8,1.9)*size,fade)
   for i,s in puffs do
    local u=(t*4+i/#puffs)%1
    local behind=math.min(t*data.Speed,u*6)
    local p=active and flight:PointToWorldSpace(Vector3.new(math.sin(i*2+t*6)*u*.5,u*.5,behind))
     or flight:PointToWorldSpace(Vector3.new(math.cos(i*2)*2*(1-charge),math.sin(i*2)*2*(1-charge),0))
    Cartoon.placeSprite(s,CFrame.new(p),active and 1.6*(1-u)+.3 or .65,active and (1-u)*.65*fade or charge*.65,i*31)
  
 end
  else
   local base=Vector3.new(data.Origin.X,floorY,data.Origin.Z)
   self.position=base
   local blast=ease(t/.16)
   local settle=1+.22*math.sin(math.clamp(t/.28,0,1)*math.pi)
   local pulse=1+.09*math.sin(t*19)
   for i,part in bodies do
    local center=i<=2 
 local a=(i-3)*math.pi*2/5
    local r=center and 0 or data.Radius*.52*ease(math.max(0,t-.035)/.2)
    local h=center and (i==1 and 10 or 7.6) or 4.4
    local width=center and (i==1 and 5.6 or 3.7) or 2.5
    local growth=active and blast*settle*pulse or .035+.08*charge
    local p=base+Vector3.new(math.cos(a)*r,h*growth/2,math.sin(a)*r)
    if i==2 then 
 
 
 
 p+=Vector3.new(0,0,-.65)
 end
    place(part,CFrame.new(p)*CFrame.Angles(0,a,center and 0 or math.sin(t*12+i)*.18),Vector3.new(width,h,width*.75)*growth,active and fade or .8)
  
 end
   for i,part in rim do
    local a=i*math.pi*2/#rim
    -- Warning stays on the true field boundary; the release wave expands to it.
    local r=active and data.Radius*(.22+.76*ease(t/.3)) or data.Radius*.98
    local p=base+Vector3.new(math.cos(a)*r,.04,math.sin(a)*r)
    place(part,CFrame.new(p),Vector3.new(active and 2.2 or 1.6,.12,active and 2.2 or 1.6),active and fade*.6 or .35+charge*.5)
  
 end
   for i,s in puffs do
    local a=i*math.pi*2/#puffs+t*.4
    local u=active and math.clamp((t-(i%2)*.05)/.65,0,1) or 1-charge
    local r=active and data.Radius*(.28+.6*ease(u)) or data.Radius*u
    Cartoon.placeSprite(s,CFrame.new(base+Vector3.new(math.cos(a)*r,.4+u*2.5,math.sin(a)*r)),active and 1.7+u*1.6 or .8,active and (1-u)*fade or charge*.7,i*40+u*40)
  
 end
 
 end
  return true

 end
 return e
end
return Fire
