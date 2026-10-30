-- Server-timed presentation only. No collision, damage or movement authority.
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config.Vfx)
local Kit = require(script.Parent.Parent.Kit)
local Cartoon = require(script.Parent.Parent.Cartoon)
local Definitions = require(ReplicatedStorage.Shared.Config.PowerMoves)
local FireHero = require(script.Parent.FireHero)
local SlickQ = require(script.Parent.SlickQ)
local ProjectileQ = require(script.Parent.ProjectileQ)
local GroundMove = require(script.Parent.GroundMove)
local Moves = {}
Moves.MaxConcurrent = 6
Moves.CullDistance = 190
Moves.MaxParts = 40
local COLORS = {
 Wind = Color3.fromRGB(127,232,207), Earth = Color3.fromRGB(185,132,67),
 Water = Color3.fromRGB(63,182,255), Fire = Color3.fromRGB(255,138,31),
 Sword = Color3.fromRGB(201,211,222), Shadow = Color3.fromRGB(155,92,255),
}
-- Mesh library contract: centered, upright, normalized MeshParts under Assets.PowerMoves.
-- Geometry is optional during rollout; silhouette-specific primitive fallbacks stay bounded.
Moves.MeshNames = { "Rock", "Droplet", "Flame", "Slash", "Leaf", "Wave", "Sword", "MasterSword", "ShadowOrb", "WindFront" }
local function finite(x)
 return type(x) == "number" and x == x and math.abs(x) < math.huge
end
local function vector(v)
 return typeof(v) == "Vector3" and finite(v.X) and finite(v.Y) and finite(v.Z) and v.Magnitude < 1000000
end
local function element(power)
 if COLORS[power] then
  return power, false
 end
 local base = type(power) == "string" and string.match(power, "^Sword_(%a+)$")
 if base and COLORS[base] then
  return base, true
 end
 return nil
end
function Moves.Valid(data)
 if type(data) ~= "table" or data.Effect ~= "PowerMove" or type(data.Token) ~= "string"
  or #data.Token < 1 or #data.Token > 80 then
   return false
  end
 if data.Phase == "Release" then
  return vector(data.Origin) and vector(data.Direction) and data.Direction.Magnitude > 0.01 and finite(data.ReleaseTime)
 end
 if data.Phase == "Stop" or data.Phase == "Impact" then
  return data.Position == nil or vector(data.Position)
 end
 return data.Phase == "Start" and element(data.Power) ~= nil
  and (data.Key == "Q" or data.Key == "E" or data.Key == "R")
  and typeof(data.Caster) == "Instance" and data.Caster:IsA("Model")
  and vector(data.Origin) and vector(data.Direction) and data.Direction.Magnitude > 0.01
  and finite(data.StartedAt) and finite(data.Duration) and data.Duration > 0 and data.Duration <= 8
  and finite(data.Radius) and data.Radius > 0 and data.Radius <= 60
  and finite(data.Speed) and data.Speed >= 0 and data.Speed <= 200
  and (data.Delay == nil or (finite(data.Delay) and data.Delay >= 0 and data.Delay <= data.Duration))
end
local function safeTemplate(name)
 local assets = ReplicatedStorage:FindFirstChild("Assets")
 local library = assets and assets:FindFirstChild("PowerMoves")
 local item = library and library:FindFirstChild(name)
 return item and (item:IsA("MeshPart") and item or item:FindFirstChildWhichIsA("MeshPart", true))
end
function Moves.Play(data, look)
 if not Moves.Valid(data) or data.Phase ~= "Start" or look.distanceFactor == 0 then
  return nil
 end
 local age = workspace:GetServerTimeNow() - data.StartedAt
 if age >= data.Duration + 0.3 then
  return nil
 end
 if data.Power == "Fire" and (data.Key == "Q" or data.Key == "R") then
  local fire = FireHero.Play(data, look)
  if fire then return fire end
 end
 if (data.Key == "E" or data.Key == "R") and GroundMove.Supports(data.Power, data.Key) then
  local ground = GroundMove.Play(data, look)
  if ground then return ground end
 end
 if (data.Key == "Q" or data.Key == "R") and SlickQ.Supports(data.Power, data.Key) then
  local slick = SlickQ.Play(data, look)
  if slick then return slick end
 end
 if data.Key == "Q" and ProjectileQ.Supports(data.Power) then
  local projectile = ProjectileQ.Play(data, look)
  if projectile then return projectile end
 end
 local base, fusion = element(data.Power)
 local definition = Definitions[data.Power][data.Key == "Q" and 1 or data.Key == "E" and 2 or 3]
 local color = COLORS[base]
 local gold = Color3.fromRGB(255,211,77)
 local master = fusion and base == "Sword"
 local frame = CFrame.lookAt(data.Origin, data.Origin + data.Direction.Unit)
 local group = Instance.new("Folder")
 group.Name = "PowerMove_" .. data.Token
 Debris:AddItem(group,data.Duration+1)
 local effect = { group = group, data = data, frame = frame, nodes = {}, sprites = {}, token = data.Token,
  caster = data.Caster, position = data.Origin, partCount = 0, meshFallbacks = 0 }
 local function node(name, size, shade, offset, motion)
  if effect.partCount >= Moves.MaxParts then
   return nil
  end
  local template = name and safeTemplate(name)
  local part = template and template:Clone() or Instance.new("Part")
  for _, child in part:GetChildren() do
   if not child:IsA("SurfaceAppearance") then
    child:Destroy()
   end
  end
  Kit.safePart(part)
  part.Name = name or "Support"
  part.Color, part.Material = name == "Leaf" and Color3.fromRGB(104,181,74) or shade or color, Enum.Material.SmoothPlastic
  if part:IsA("Part") then
   part.Shape = name == "Rock" and Enum.PartType.Block or Enum.PartType.Ball
   if name then
    effect.meshFallbacks += 1
   end
  end
  if template and (part.TextureID ~= "" or part:FindFirstChildWhichIsA("SurfaceAppearance")) then
   part.Color = Color3.new(1,1,1)
  end
  part.Size, part.Transparency, part.Parent = size, 1, group
  local n = { part = part, size = size, offset = offset or CFrame.identity, motion = motion or "hero" }
  table.insert(effect.nodes, n)
  effect.partCount += 1
  return n
 end
 local function arc(radius, angle, segments, plane, shade, motion, height)
  local warning = motion == "warning"
  local width = warning and 0.22 or math.min(1.25, radius*0.28)
  local ringRadius = warning and math.max(0.1,radius-width/2) or radius
  for i = 1, segments do
   local t = -angle/2 + angle * (i-1)/math.max(1,angle >= math.pi*2 and segments or segments-1)
   local offset = plane == "vertical" and Vector3.new(math.cos(t)*ringRadius, math.sin(t)*ringRadius+(motion=="descend" and 7 or 0), 0)
    or Vector3.new(math.cos(t)*ringRadius, height or 0, math.sin(t)*ringRadius)
   local size = warning and Vector3.new(width,0.12,math.min(radius*0.3,2.8))
    or Vector3.new(width, width*0.65, width*1.8)
   local n = node(nil,size,shade,CFrame.new(offset)*CFrame.Angles(0,-t,0),motion)
   if warning and n then
    n.part.Shape = Enum.PartType.Block
   end
  end
 end
 local function blade(offset, scale)
  local n = node(master and "MasterSword" or "Sword", (master and Vector3.new(2.8,5.5,0.7) or Vector3.new(2.1,4.5,0.6))*scale,
   COLORS.Sword, offset, "blade")
  if n and n.part:IsA("Part") then
   n.part.Shape = Enum.PartType.Block
   node(nil,Vector3.new(2,0.45,0.6)*scale,master and gold or color,offset*CFrame.new(0,-1.1*scale,0),"blade")
  end
 end
 local low = look.distanceFactor < 0.75
 local count = low and 4 or 6
 local radius = math.clamp(data.Radius,1,24)
 if data.Key == "Q" then
  if fusion or base == "Sword" then
   local slash = safeTemplate("Slash")
   if slash then
    node("Slash",Vector3.new(4,3,0.8),color)
   else
    arc(1.6,math.pi*1.3,7,"vertical",color,"hero")
   end
   if master then
    for i = -1,1 do
     node(nil,Vector3.new(0.6,0.75,0.6),gold,CFrame.new(i*0.8,1.7,0),"hero")
    end
   elseif base == "Earth" then
    node("Rock",Vector3.new(1.2,1,1),color,CFrame.new(0,-0.7,0),"spin")
   elseif base == "Water" then
    node("Droplet",Vector3.new(0.7,0.7,1.3),color:Lerp(Color3.new(1,1,1),0.3),CFrame.new(0,0,1),"hero")
   elseif base == "Fire" then
    for i = -1,1 do
     node("Flame",Vector3.new(0.7,1.2,0.8),gold,CFrame.new(i*0.8,0.2,0.4),"flicker")
    end
   elseif base == "Shadow" then
    node("ShadowOrb",Vector3.new(1,1,1),color,CFrame.new(0,0,1.6),"pulse")
   elseif base == "Wind" then
    node("Leaf",Vector3.new(0.6,0.2,1.1),color,CFrame.new(0,1,0.8),"spin")
   end
  elseif base == "Earth" then
   node("Rock",Vector3.new(3.4,3.1,3.2),color,CFrame.Angles(0.2,0.4,0.3),"spin")
   node("Rock",Vector3.new(0.7,0.6,0.8),color:Lerp(Color3.new(1,1,1),0.25),CFrame.new(0.8,0.3,0.2),"spin")
  elseif base == "Water" then
   node("Droplet",Vector3.new(3.2,3,3.8),color)
   for i = 1,2 do
    node(nil,Vector3.one*(0.7/i),Color3.fromRGB(189,235,255),CFrame.new(i*0.3,0,i*1.1),"hero")
   end
  elseif base == "Fire" then
   node("Flame",Vector3.new(3.4,4.1,2.8),color)
   for i = -1,1 do
    node(nil,Vector3.new(0.9,1.6,1.1),gold,CFrame.new(i*0.6,0.6,0.3),"flicker")
   end
  elseif base == "Wind" then
   if safeTemplate("WindFront") then
    node("WindFront",Vector3.new(4.2,1.2,0.6),color)
   else
    arc(1.5,math.pi*1.4,7,"vertical",color,"hero")
   end
   node("Leaf",Vector3.new(0.6,0.18,1),color,CFrame.new(0,0,0.8),"spin")
  else
   node("ShadowOrb",Vector3.new(3.4,3.4,3.4),color,nil,"pulse")
   arc(1.15,math.pi,4,"vertical",color:Lerp(Color3.new(1,1,1),0.4),"hero")
  end
 else
  -- Ground warnings are low, thin, non-solid and never obscure combatants.
  if definition.Kind == "Cone" then
   -- Cone warnings point forward instead of implying damage behind the caster.
   for i=1,5 do
    local z = definition.Range*i/6
    node(nil,Vector3.new(0.25,0.12,0.8),color,CFrame.new(0,-2.6,-z),"warning")
   end
  else
   arc(radius-0.15,math.pi*2,12,"ground",color,"warning",-2.6)
  end
  if master then
   blade(CFrame.new(0,2,0),data.Key=="R" and 1.6 or 1.25)
   arc(radius*0.6,math.pi*1.15,7,"vertical",gold,"cleave")
  elseif fusion and data.Key == "E" then
   blade(CFrame.new(0,0,-1),1.25)
   arc(radius*0.5,math.pi*1.25,7,"vertical",color,"cleave")
   if base == "Earth" then
    node("Rock",Vector3.new(2,1.2,2),color,CFrame.new(0,-2,-2),"rise")
   elseif base == "Fire" then
    node("Flame",Vector3.new(3,3.8,1.5),gold,CFrame.new(0,0,-2),"flicker")
   elseif base == "Shadow" then
    arc(radius*0.4,math.pi,5,"vertical",color:Lerp(Color3.new(1,1,1),0.3),"echo")
   elseif base == "Water" then
    node("Wave",Vector3.new(4.5,2.5,2),color,CFrame.new(0,-1,-2),"swirl")
   else
    node("Leaf",Vector3.new(1.3,0.25,1.8),color,CFrame.new(1,0,-2),"spin")
   end
  elseif base == "Sword" then
   if data.Key == "E" then
    blade(CFrame.new(0,0,-1),1.25)
    arc(radius*0.55,math.pi,6,"vertical",color,"cleave")
   else
    blade(CFrame.new(0,1,0),1.65)
    arc(radius*0.65,math.pi*1.7,9,"ground",color,"swirl",-0.6)
   end
  elseif base == "Earth" then
   if data.Key == "R" then
    arc(radius*0.82,math.pi*2,8,"ground",color:Lerp(Color3.new(1,1,1),0.3),"shock",-2.4)
    node("Rock",Vector3.new(3.5,6.5,3.2),color,CFrame.new(0,-1,0),"pillar")
   end
   for i = 1,count do
    local a = i*math.pi*2/count
    local offset = fusion and data.Key=="R" and Vector3.new(0,-2,-i*radius*0.55/count)
     or Vector3.new(math.cos(a)*radius*0.55,-2,math.sin(a)*radius*0.55)
    node("Rock",Vector3.new(2.8,2.5,2.6)*(data.Key=="R" and 1.25 or 1),color,
     CFrame.new(offset)*CFrame.Angles(0,i,0.2),"rise")
   end
  elseif base == "Water" then
   if data.Key == "R" and not fusion then
    node("Wave",Vector3.new(radius*1.6,7,3),color,CFrame.new(0,0.5,0),"wave")
    arc(radius*0.65,math.pi,7,"vertical",Color3.fromRGB(218,248,255),"wave",0)
   else
    arc(radius*0.65,math.pi*1.8,8,"ground",Color3.fromRGB(189,235,255),"swirl",-2.3)
    if fusion then
     blade(CFrame.new(0,1,0),1.5)
    end
   end
  elseif base == "Fire" then
   if data.Key == "R" then
    node("Flame",Vector3.new(fusion and 5 or 6,8,4.5),color,CFrame.new(0,1.4,0),"geyser")
    node("Flame",Vector3.new(2.8,4.8,2.4),gold,CFrame.new(0,0.5,-0.7),"geyser")
    arc(radius*0.65,math.pi*1.8,7,"ground",gold,"shock",-2.3)
   else
    for i = 1,count do
     local a=i*math.pi*2/count
     node("Flame",Vector3.new(2.4,3.2,2),i%2==0 and gold or color,
      CFrame.new(math.cos(a)*radius*0.5,-1,math.sin(a)*radius*0.5),"flicker")
    end
   end
  elseif base == "Wind" and data.Key == "E" then
   for layer=1,2 do
    node("WindFront",Vector3.new(radius*(0.75+layer*0.15),1.5,0.7),color,
     CFrame.new(0,layer*0.8,-layer),"airfront")
   end
   node("Leaf",Vector3.new(0.8,0.2,1.2),color,CFrame.new(0,1,-2),"airfront")
  elseif base == "Wind" then
   for layer=1,3 do
    local bandRadius=radius*(0.25+layer*0.12)
    for side=1,3 do
     local a=side*math.pi*2/3
     node("WindFront",Vector3.new(bandRadius*1.3,1.2,0.6),color,
      CFrame.Angles(0,a,0)*CFrame.new(0,not fusion and layer*2.6-2 or layer*0.7-1,-bandRadius),"swirl")
    end
   end
   for i=1,2 do
    node("Leaf",Vector3.new(0.8,0.2,1.2),color,CFrame.new(i,1,-i),"spin")
   end
  elseif fusion and base=="Shadow" then
   arc(radius*0.55,math.pi*1.4,8,"vertical",color,"cleave")
   arc(radius*0.45,math.pi*1.4,6,"vertical",color:Lerp(Color3.new(1,1,1),0.3),"echo")
  elseif data.Key=="R" then
   node("ShadowOrb",Vector3.new(radius*0.7,6,radius*0.7),color,CFrame.new(0,7,0),"descend")
   arc(radius*0.5,math.pi*1.4,7,"vertical",Color3.fromRGB(217,194,255),"descend")
  else
   for layer=1,2 do
    arc(radius*0.45,math.pi*1.7,6,"ground",color,"swirl",layer*0.7-1.6)
   end
  end
 end
 for i=1,low and 2 or 4 do
  if effect.partCount >= Moves.MaxParts then
   break
  end
  local sprite=Cartoon.sprite(group,i%2==0 and Config.Textures.Star or Config.Textures.Puff,Color3.new(1,1,1))
  if sprite then
   sprite.index=i
  table.insert(effect.sprites,sprite)
  effect.partCount+=1
  end
 end
 group.Parent=Kit.folder()
 function effect:Destroy()
  if self.destroyed then
   return
  end
  self.destroyed=true
  self.group:Destroy()
 end
 function effect:Release(origin, direction, time)
  if self.destroyed or not vector(origin) or not vector(direction) or direction.Magnitude < 0.01 or not finite(time) then
   return
  end
  frame=CFrame.lookAt(origin,origin+direction.Unit)
  self.releaseAt=time
 end
 function effect:Stop(impact, position)
  if self.destroyed then
   return
  end
  if not impact then
   self:Destroy()
  return
  end
  self.impactAt=workspace:GetServerTimeNow()
  self.impactPosition=position or self.position
  for _,n in self.nodes do
   n.part.Transparency=1
  end
 end
 function effect:Update(now)
  if self.destroyed or not self.group.Parent then
   return false
  end
  local elapsed=math.max(0,now-data.StartedAt)
  local deadline = self.releaseAt and self.releaseAt + definition.Range/math.max(1,data.Speed)+0.3 or data.StartedAt+data.Duration+(data.Key=="Q" and 0.5 or 0.15)
  if now>deadline then
   return false
  end
  local windup=data.Delay or 0
  local released=data.Key=="Q" and self.releaseAt~=nil or data.Key~="Q" and elapsed>=windup
  local actionTime = data.Key=="Q" and (self.releaseAt and math.max(0,now-self.releaseAt) or 0) or math.max(0,elapsed-windup)
  local charge=math.clamp(elapsed/math.max(0.01,windup),0,1)
  local progress=math.clamp(actionTime/math.max(0.1,data.Duration-windup),0,1)
  local punch=math.sin(math.clamp(actionTime/0.18,0,1)*math.pi)
  if data.Key=="Q" and not released then
   local root=data.Caster:FindFirstChild("HumanoidRootPart")
   if root then
    local facing=root.CFrame.LookVector
    local muzzle=root.Position+Vector3.new(0,0.35,0)+facing*2
    frame=CFrame.lookAt(muzzle,muzzle+facing)
   end
  end
  local alpha=math.clamp((deadline-now)/0.2,0,1)
  local travel=(data.Key=="Q" or definition.Kind=="Wave") and actionTime*data.Speed or 0
  local origin=frame*CFrame.new(0,0,-travel)
  self.position=self.impactPosition or origin.Position
  if self.impactAt then
   local t=now-self.impactAt
   if t>0.25 then
    return false
   end
   for i,s in self.sprites do
    local a=i*math.pi*2/#self.sprites
    Cartoon.placeSprite(s,CFrame.new(self.position+Vector3.new(math.cos(a),0.4,math.sin(a))*(0.4+math.sin(t/0.25*math.pi/2)*math.min(radius*0.65,2))),1.3+t*6,1-t/0.25,i*27)
   end
   return true
  end
  for i,n in self.nodes do
   local offset=n.offset
   local scale=released and 1 or 0.25+charge*0.5
   local opacity=released and alpha or 0.3+charge*0.35
   local stretch=Vector3.one
   if data.Key=="Q" then
    stretch=released and Vector3.new(1-punch*0.12,1-punch*0.12,1+punch*0.25)
     or Vector3.new(1,1-charge*0.2,1+charge*0.15)
   end
   if n.motion=="warning" then
    opacity=released and alpha*0.3 or 0.45+charge*0.4
    scale=1
   elseif n.motion=="spin" then
    offset*=CFrame.Angles(actionTime*2,actionTime*2,actionTime)
    if data.Key=="Q" then
     -- A rotating rock's diagonal must remain inside the server sphere.
     scale*=0.88
    end
   elseif n.motion=="pulse" then
    scale*=1+0.08*math.sin(elapsed*9)
   elseif n.motion=="flicker" then
    scale*=1+0.12*math.sin(elapsed*12+i)
   elseif n.motion=="rise" then
    local rise=math.clamp((actionTime-(i%3)*0.045)/0.2,0,1)
    offset+=Vector3.new(0,-1.8+math.sin(rise*math.pi/2)*3.2,0)
    stretch=Vector3.new(1,0.25+rise*0.75,1)
   elseif n.motion=="pillar" or n.motion=="geyser" then
    local erupt=math.sin(math.clamp(actionTime/0.22,0,1)*math.pi/2)
    stretch=Vector3.new(1-punch*0.1, released and (0.15+erupt*0.85) or 0.1,1-punch*0.1)
    offset+=Vector3.new(0,-n.size.Y*(1-stretch.Y)/2,0)
   elseif n.motion=="shock" then
    local expand=math.clamp(actionTime/0.4,0,1)
    offset=CFrame.new(n.offset.Position*Vector3.new(0.2+0.8*expand,1,0.2+0.8*expand))*n.offset.Rotation
    opacity=released and alpha*(1-expand*0.65) or 0
   elseif n.motion=="swirl" then
    offset=CFrame.Angles(0,actionTime*(fusion and 5 or 3)+charge*0.2,0)*offset
    if base=="Wind" then
     offset+=Vector3.new(0,math.sin(actionTime*7+i)*0.3,0)
    end
   elseif n.motion=="wave" then
    stretch=Vector3.new(1,0.7+0.3*math.sin(math.min(1,actionTime/0.22)*math.pi/2),1+punch*0.2)
    offset*=CFrame.Angles(-math.sin(progress*math.pi)*0.16,0,0)
   elseif n.motion=="airfront" then
    offset+=Vector3.new(0,0,-progress*math.max(0,definition.Range-3))
    stretch=Vector3.new(0.6+progress*0.4,1,1)
   elseif n.motion=="echo" then
    opacity=progress>0.3 and alpha or 0
    offset=CFrame.Angles(-math.max(0,progress-0.3)*math.pi,0,0)*offset
   elseif n.motion=="descend" then
    local drop=math.clamp(actionTime/0.24,0,1)
    offset+=Vector3.new(0,-7*drop*drop,0)
    stretch=Vector3.new(1-drop*0.12,1+math.sin(drop*math.pi)*0.25,1-drop*0.12)
   elseif n.motion=="cleave" then
    offset=CFrame.Angles(-progress*math.pi*0.7,0,0)*offset
   elseif n.motion=="blade" then
    offset=CFrame.Angles(master and -progress*math.pi*0.8 or 0,master and 0 or elapsed*3,0)*offset
   end
   n.part.Size=n.size*stretch*math.max(0.05,scale)
   n.part.CFrame=origin*offset
   n.part.Transparency=1-opacity*(n.motion=="warning" and 0.5 or 0.85)
  end
  for i,s in self.sprites do
   local a=i*math.pi*2/#self.sprites+elapsed
   local flow=(actionTime*3+i/#self.sprites)%1
   local localPoint=data.Key=="Q" and Vector3.new(math.cos(a)*0.7,math.sin(a)*0.7,0.5+flow*2)
    or Vector3.new(math.cos(a)*radius*0.55,-1.8+flow*2,math.sin(a)*radius*0.55)
   local p=origin:PointToWorldSpace(localPoint)
   Cartoon.placeSprite(s,CFrame.new(p),released and 0.7+(1-flow)*0.8 or 0.5,
    released and alpha*(1-flow)*0.75 or charge*0.35,i*24)
  end
  return true
 end
 return effect
end
return Moves
