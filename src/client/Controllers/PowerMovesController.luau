local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Moves = require(script.Parent.Parent.Vfx.Effects.PowerMoves)
local Controller = {}
local active, seen, connections = {}, {}, {}
local running = false
local animationSessions = {}
local animationConfig
local bumpStarted, bumpStrength = 0, 0
local function bump(strength)
 bumpStarted = os.clock()
 bumpStrength = math.max(bumpStrength, strength)
end
local counters = { started = 0, cleaned = 0, culled = 0, rejected = 0, failed = 0, peakParts = 0, meshFallbacks = 0 }
local function remove(token)
 local effect=active[token]
 if effect then
  effect:Destroy()
 active[token]=nil
 counters.cleaned+=1
 end
end
local function stopAnimation(caster)
 local session=animationSessions[caster]
 if not session then
  return
 end
 animationSessions[caster]=nil
 session.track:Stop(0.1)
 task.delay(0.15,function()
  session.track:Destroy()
  session.animation:Destroy()
 end)
end
local function playAnimation(data)
 -- Player-owned tracks replicate from their owner; remote viewers must not double-play them.
 local player=Players:GetPlayerFromCharacter(data.Caster)
 if player and player~=Players.LocalPlayer then
  return
 end
 if not animationConfig then
  local module=ReplicatedStorage.Shared.Config:FindFirstChild("PowerAnimations")
  if not module then
   return
  end
  local ok,result=pcall(require,module)
  if not ok then
   return
  end
  animationConfig=result
 end
 local index=data.Key=="Q" and 1 or data.Key=="E" and 2 or 3
 local power=animationConfig[data.Power]
 local config=power and power[index]
 if not config then
  return
 end
 local humanoid=data.Caster:FindFirstChildOfClass("Humanoid")
 local root=data.Caster:FindFirstChild("HumanoidRootPart")
 local animator=humanoid and humanoid:FindFirstChildOfClass("Animator")
 if not animator or not root or humanoid.Health<=0 then
  return
 end
 local v=root.AssemblyLinearVelocity
 local moving=humanoid.FloorMaterial==Enum.Material.Air or Vector3.new(v.X,0,v.Z).Magnitude>1.5
 local id=moving and config.MovingAnimationId or config.AnimationId
 if type(id)~="string" or not string.match(id,"^rbxassetid://%d+$") then
  return
 end
 local elapsed=workspace:GetServerTimeNow()-data.StartedAt
 if elapsed>=config.Duration then
  return
 end
 stopAnimation(data.Caster)
 local count=0
 for _ in animationSessions do
  count+=1
 end
 if count>=Moves.MaxConcurrent then
  return
 end
 local animation=Instance.new("Animation")
 animation.AnimationId=id
 local ok,track=pcall(function() return animator:LoadAnimation(animation)
 end)
 if not ok then
  animation:Destroy()
 return
 end
 track.Priority,track.Looped=Enum.AnimationPriority.Action,false
 track:Play(0.08,1,1)
 animationSessions[data.Caster]={track=track,animation=animation,started=data.StartedAt,
  duration=config.Duration,token=data.Token,seeked=false}
end
local function distance(position)
 local camera=workspace.CurrentCamera
 return camera and (camera.CFrame.Position-position).Magnitude or math.huge
end
function Controller.debugStats()
 local stats=table.clone(counters)
 stats.active,stats.parts,stats.connections,stats.animationTracks=0,0,#connections,0
 for _ in animationSessions do
  stats.animationTracks+=1
 end
 for _,effect in active do
  stats.active+=1
  stats.parts+=effect.partCount
 end
 return stats
end
function Controller.Play(data)
 if type(data)~="table" or data.Effect~="PowerMove" then
  return
 end
 if not Moves.Valid(data) then
  counters.rejected+=1
 return
 end
 local now=workspace:GetServerTimeNow()
 if data.Phase=="Release" then
  if data.ReleaseTime>now+2 or now-data.ReleaseTime>8 then
   counters.rejected+=1
   return
  end
  local effect=active[data.Token]
  if effect then
   effect:Release(data.Origin,data.Direction,data.ReleaseTime)
  end
  return
 end
 if data.Phase~="Start" then
  seen[data.Token]=now+10
  if data.Phase=="Stop" then
   for caster,session in animationSessions do
    if session.token==data.Token then
     stopAnimation(caster)
    end
   end
  end
  local effect=active[data.Token]
  if effect then
   effect:Stop(data.Phase=="Impact",data.Position)
   if effect.destroyed then
    remove(data.Token)
   end
  end
  return
 end
 if seen[data.Token] or active[data.Token] then
  return
 end
 if not data.Caster:IsDescendantOf(workspace) or data.StartedAt>now+2 or now-data.StartedAt>data.Duration+0.3 then
  counters.rejected+=1
  return
 end
 playAnimation(data)
 local count=0
 for _ in active do
  count+=1
 end
 local d=distance(data.Origin)
 if d>Moves.CullDistance or count>=Moves.MaxConcurrent then
  counters.culled+=1
 return
 end
 local ok,effect=pcall(Moves.Play,data,{distanceFactor=d>100 and 0.5 or 1,isOwn=data.Caster==Players.LocalPlayer.Character,bump=bump})
 if ok and effect then
  active[data.Token]=effect
  seen[data.Token]=now+10
  counters.started+=1
  counters.meshFallbacks+=effect.meshFallbacks
  counters.peakParts=math.max(counters.peakParts,Controller.debugStats().parts)
 elseif not ok then
  counters.failed+=1
 end
end
function Controller.Stop()
 running=false
 RunService:UnbindFromRenderStep("PowerMoveCameraBump")
 bumpStrength=0
 for _,connection in connections do
  connection:Disconnect()
 end
 table.clear(connections)
 for token in active do
  remove(token)
 end
 table.clear(seen)
 for caster in animationSessions do
  stopAnimation(caster)
 end
end
function Controller.Start()
 if running then
  return
 end
 running=true
 RunService:BindToRenderStep("PowerMoveCameraBump",Enum.RenderPriority.Camera.Value+1,function()
  local t=os.clock()-bumpStarted
  local camera=workspace.CurrentCamera
  if t>=0.18 then
   bumpStrength=0
  end
  if camera and camera.CameraType~=Enum.CameraType.Scriptable and bumpStrength>0 then
   local displacement=math.sin(t/0.18*math.pi*2)*bumpStrength*(1-t/0.18)
   camera.CFrame*=CFrame.new(0,displacement,0)
  end
 end)
 table.insert(connections,Remotes.PilotVfx.OnClientEvent:Connect(Controller.Play))
 table.insert(connections,RunService.RenderStepped:Connect(function()
  local now=workspace:GetServerTimeNow()
  for caster,session in animationSessions do
   local humanoid=caster:FindFirstChildOfClass("Humanoid")
   local elapsed=math.max(0,now-session.started)
   if not caster:IsDescendantOf(workspace) or not humanoid or humanoid.Health<=0 or elapsed>session.duration+0.15 then
    stopAnimation(caster)
   elseif not session.seeked and session.track.Length>0 then
    session.track.TimePosition=math.min(elapsed,session.track.Length)
    session.seeked=true
   end
  end
  local seenCount=0
  for token,expiry in seen do
   if expiry<now then
    seen[token]=nil
   else
    seenCount+=1
   end
  end
  if seenCount>128 then
   table.clear(seen)
  end
  for token,effect in active do
   if distance(effect.position)>Moves.CullDistance then
    counters.culled+=1
    remove(token)
   else
    local ok,alive=pcall(effect.Update,effect,now)
    if not ok then
     counters.failed+=1
    end
    if not ok or not alive then
     remove(token)
    end
   end
  end
 end))
 table.insert(connections,script.Destroying:Connect(Controller.Stop))
 table.insert(connections,script.AncestryChanged:Connect(function()
  if not script:IsDescendantOf(game) then
   Controller.Stop()
  end
 end))
end
return Controller
