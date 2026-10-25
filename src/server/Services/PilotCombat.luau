local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local C = require(ReplicatedStorage.Shared.PilotConfig)
local World = require(script.Parent.PilotWorld)
local Actions = require(script.Parent.CombatActions)
local Combat = { Actors = {}, Bandits = {}, Enabled = false }
Combat.CancelAction = Actions.Cancel

function Combat.Root(actor)
	return actor.Model and actor.Model:FindFirstChild("HumanoidRootPart")
end

function Combat.Alive(actor)
	return actor and actor.Active and actor.HP > 0 and Combat.Root(actor) ~= nil
end

function Combat.Effect(position, color, radius, duration)
	local p = World.Part(World.Root, "Effect", Vector3.one * radius * 2, CFrame.new(position), color, false)
	p.Shape, p.Transparency, p.Material = Enum.PartType.Ball, 0.75, Enum.Material.Neon
	p.CanQuery = false
	Debris:AddItem(p, duration or 0.3)
	return p
end

function Combat.Damage(source, target, amount, stun, heavy, cartoonHit)
	if not Combat.Enabled or source == target or not Combat.Alive(target) then
		return
	end
	local now = os.clock()
	if now < (target.Invulnerable or 0) then
		return
	end
	if now < (target.Shield or 0) then
		amount *= 1 - C.ShieldReduction
		if heavy then
			target.Shield = 0
		end
	end
	if now < (target.Protection or 0) then
		amount *= 0.5
	end
	if stun > 0 and now > (target.StunImmune or 0) then
		Actions.Cancel(target)
		target.Stunned = now + math.min(stun, 0.6)
		target.StunImmune = target.Stunned + 1.5
	end
	local actual = math.min(target.HP, amount)
	target.HP -= actual
	if source then
		source.Damage += actual
	end
	if not cartoonHit then
		Combat.Effect(Combat.Root(target).Position, Color3.new(1, 1, 1), 2)
	end
	-- Mark and credit the KO before Health=0 triggers Humanoid.Died.
	if target.HP <= 0 then
		Combat.OnKO(source, target)
	else
		local humanoid = target.Model:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = target.HP
		end
	end
	return actual
end

function Combat.LineClear(from, to, excluded)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = excluded
	return workspace:Raycast(from, to - from, params) == nil
end

function Combat.Area(actor, center, radius, damage, stun, heavy)
	for _, other in Combat.Actors do
		local root = Combat.Root(other)
		if other ~= actor and Combat.Alive(other) and (root.Position - center).Magnitude <= radius
		and Combat.LineClear(center, root.Position, { actor.Model, other.Model }) then
			Combat.Damage(actor, other, damage, stun, heavy)
		end
	end
end

function Combat.Projectile(actor, color, damage, range, star)
	local root = Combat.Root(actor)
	if not root then
		return
	end
	local direction = root.CFrame.LookVector
	local p = World.Part(World.Root, star and "SpitStar" or "PowerShot", Vector3.one * 1.5, CFrame.new(root.Position + direction * 3), color, false)
	p.CanQuery, p.Material = false, Enum.Material.Neon
	if star then
		p.Transparency = 1
		for i = 1, 5 do
			local angle = i * math.pi * 2 / 5
			local spike = World.Part(p, "StarPoint", Vector3.new(0.65, 1.7, 0.4), p.CFrame * CFrame.Angles(0, 0, angle) * CFrame.new(0, 0.55, 0), color, false)
			spike.CanQuery = false
		end
	else
		p.Shape = Enum.PartType.Ball
	end
	local traveled = 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not p.Parent or not Combat.Enabled or not Combat.Alive(actor) then
			connection:Disconnect()
			p:Destroy()
			return
		end
		local step = math.min(dt * 65, range - traveled)
		local old, nextPosition = p.Position, p.Position + direction * step
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { actor.Model, p }
		local hit = workspace:Raycast(old, nextPosition - old, params)
		local hitDistance = hit and (hit.Position - old).Magnitude or step
		local victim, distance = nil, hitDistance + 0.001
		for _, other in Combat.Actors do
			if other ~= actor and Combat.Alive(other) then
				local offset = Combat.Root(other).Position - old
				local along = math.clamp(offset:Dot(direction), 0, step)
				if (offset - direction * along).Magnitude < 2.5 and along <= distance then
					victim, distance = other, along
				end
			end
		end
		if victim then
			Combat.Damage(actor, victim, damage, 0, false)
		end
		local delta = direction * step
		p.CFrame += delta
		for _, child in p:GetChildren() do
			if child:IsA("BasePart") then
				child.CFrame += delta
			end
		end
		traveled += step
		if victim or hit or traveled >= range then
			connection:Disconnect()
			p:Destroy()
		end
	end)
	Debris:AddItem(p, 3)
end

function Combat.Ready(actor, key, cooldown)
	local now = os.clock()
	if not Combat.Enabled or not Combat.Alive(actor) or now < (actor.Stunned or 0) or actor.Inhaling then
		return false
	end
	if now < (actor.Cooldowns[key] or 0) then
		return false
	end
	if actor.CombatAction and actor.CombatAction.name == "Dash" and key ~= "Dash" then
		return false
	end
	if key ~= "M1" and key ~= "Dash" then
		Actions.Cancel(actor)
	end
	actor.Cooldowns[key] = now + cooldown
	return true
end

function Combat.Action(actor, action, argument)
	local root = Combat.Root(actor)
	if not Combat.Alive(actor) then
		return
	end
	if action == "M1" then
		Actions.M1(Combat, actor)
	elseif action == "Dash" then
		Actions.Dash(Combat, actor)
	elseif action == "Block" and Combat.Ready(actor, "Block", C.ShieldCooldown) then
		actor.Shield = os.clock() + C.ShieldDuration
		local bubble = Combat.Effect(root.Position, Color3.fromRGB(100, 210, 255), 3.5, C.ShieldDuration)
		task.spawn(function()
			while bubble.Parent and Combat.Alive(actor) and os.clock() < actor.Shield do
				bubble.Position = root.Position
				task.wait()
			end
			bubble:Destroy()
		end)
	elseif action == "Move" and type(argument) == "number" and argument % 1 == 0 and argument >= 1 and argument <= 3 then
		local id = actor.Slots[actor.Slot]
		local power = C.Powers[id]
		if not power then
			return
		end
		local move = power.Moves[argument]
		if not Combat.Ready(actor, id .. argument, move.Cooldown * move.PvpCooldown) then
			return
		end
		local damage, stun = move.Damage * move.PvpDamage, move.Stun * move.PvpStun
		if move.Kind == "Projectile" then
			Combat.Projectile(actor, power.Color, damage, move.Range, false)
		elseif move.Kind == "Guard" then
			actor.Protection = os.clock() + 1.2
			Combat.Effect(root.Position, power.Color, 4, 1.2)
		elseif move.Kind == "Field" then
			local center = root.Position + root.CFrame.LookVector * 10
			Combat.Effect(center, power.Color, 8, 1.2)
			Combat.Area(actor, center, 8, damage, stun, false)
		elseif move.Kind == "Melee" then
			local center = root.Position + root.CFrame.LookVector * 4
			Combat.Effect(center, power.Color, 5)
			Combat.Area(actor, center, 6, damage, stun, false)
		else
			local center = root.Position
			Combat.Effect(center, power.Color, move.Range, 0.6)
			task.delay(0.5, function()
				if Combat.Alive(actor) then
					Combat.Area(actor, center, move.Range, damage, stun, true)
				end
			end)
		end
	end
end
return Combat
