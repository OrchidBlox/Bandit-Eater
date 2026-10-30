-- Server owns release times, projectile capture, obstruction and damage.
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Remotes = require(game:GetService("ReplicatedStorage").Shared.Remotes)
local Service = {}
local projectiles = {}

local function send(state, phase, position)
	local packet = table.clone(state.packet)
	packet.Phase = phase
	packet.Position = position
	Remotes.PilotVfx:FireAllClients(packet)
end

local function finish(state, phase, position)
	if state.done then
		return
	end
	state.done = true
	if state.actor.PowerCast == state then
		state.actor.PowerCast = nil
	end
	projectiles[state.packet.Token] = nil
	if state.connection then
		state.connection:Disconnect()
	end
	send(state, phase or "Stop", position)
end

function Service.Cancel(actor)
	local state = actor.PowerCast
	if state then
		finish(state)
	end
end

local function valid(combat, actor, model)
	return combat.Enabled and combat.Alive(actor) and actor.Model == model
		and os.clock() >= (actor.Stunned or 0)
end

function Service.TryInhale(combat, actor)
	if actor.Held or not actor.Inhaling or os.clock() > (actor.InhaleCatchUntil or 0)
		or not combat.Alive(actor) or os.clock() < (actor.Stunned or 0) then
		return false
	end
	local root = combat.Root(actor)
	local nearest, distance = nil, 12
	for _, state in projectiles do
		local offset = state.position - root.Position
		local d = offset.Magnitude
		if state.move.Inhaleable and state.actor ~= actor and d < distance and (d < 0.01 or offset.Unit:Dot(root.CFrame.LookVector) > 0.55)
			and state.packet.Direction:Dot(root.CFrame.LookVector) < -0.15
			and combat.LineClear(root.Position, state.position, { actor.Model, state.model }) then
			nearest, distance = state, d
		end
	end
	if not nearest then
		return false
	end
	actor.Held = { Power = nearest.packet.Power, Variant = "Normal", Projectile = true }
	actor.Inhales += 1
	finish(nearest, "Stop", nearest.position)
	return true
end

local function knock(target, center, move)
	local root = target.Model:FindFirstChild("HumanoidRootPart")
	if not root or root.Anchored then
		return
	end
	local flat = Vector3.new(root.Position.X - center.X, 0, root.Position.Z - center.Z)
	local direction = flat.Magnitude > 0.01 and flat.Unit or Vector3.zAxis
	root.AssemblyLinearVelocity += direction * ((move.Push or 0) - (move.Pull or 0))
		+ Vector3.yAxis * (move.Lift or 0)
end

local function damage(combat, state, target, amount, center)
	local move = state.move
	local actual = combat.Damage(state.actor, target, amount * move.PvpDamage,
		move.Stun * move.PvpStun, state.packet.Key == "R", true)
	if actual and actual > 0 then
		knock(target, center, move)
	end
end

local function hitArea(combat, state, center, amount, cone, hitSet)
	for _, other in combat.Actors do
		local root = combat.Root(other)
		if other ~= state.actor and combat.Alive(other) and (not hitSet or not hitSet[other]) then
			local delta = root.Position - center
			local allowed = delta.Magnitude <= state.move.Radius
			if cone then
				local offset = root.Position - state.packet.Origin
				allowed = offset.Magnitude <= state.move.Range and (offset.Magnitude < 0.01
					or offset.Unit:Dot(state.packet.Direction) > 0.45)
			end
			if allowed and combat.LineClear(center, root.Position, { state.model, other.Model }) then
				damage(combat, state, other, amount, center)
				if hitSet then
					hitSet[other] = true
				end
			end
		end
	end
end

local function worldParameters(combat)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local excluded = {}
	for _, actor in combat.Actors do
		if actor.Model then
			table.insert(excluded, actor.Model)
		end
	end
	params.FilterDescendantsInstances = excluded
	params.RespectCanCollide = true
	return params
end

local function hitWave(combat, state, before, after, hitSet, params)
	local segment = after - before
	local lengthSquared = segment:Dot(segment)
	for _, other in combat.Actors do
		if other ~= state.actor and not hitSet[other] and combat.Alive(other) then
			local position = combat.Root(other).Position
			local alpha = lengthSquared > 0 and math.clamp((position - before):Dot(segment) / lengthSquared, 0, 1) or 0
			local closest = before + segment * alpha
			local offset = position - closest
			-- Sweep the entire traveled segment; world geometry blocks radial reach too.
			if offset.Magnitude <= state.move.Radius
				and (offset.Magnitude < 0.001 or not workspace:Raycast(closest, offset, params)) then
				hitSet[other] = true
				damage(combat, state, other, state.move.Damage, closest)
			end
		end
	end
end

-- Fast launch that eases out: the share of a dash's distance covered after t of total seconds.
local function dashEase(t, total)
	return 1 - (1 - math.clamp(t / total, 0, 1)) ^ 2
end

local function launch(combat, state)
	local packet, move = state.packet, state.move
	local root = combat.Root(state.actor)
	-- Sample the live character at release, not the beginning of the windup.
	local direction = root.CFrame.LookVector
	local chest = root.Position + Vector3.new(0, 0.35, 0)
	local muzzleParams = worldParameters(combat)
	local muzzleHit = workspace:Raycast(chest, direction * 2, muzzleParams)
	packet.Origin = muzzleHit and muzzleHit.Position - direction * 0.1 or chest + direction * 2
	packet.Direction = direction
	packet.ReleaseTime = workspace:GetServerTimeNow()
	send(state, "Release")
	if muzzleHit then
		finish(state, "Impact", muzzleHit.Position)
		return
	end
	-- Released shots persist independently of their caster's next action.
	if state.actor.PowerCast == state then
		state.actor.PowerCast = nil
	end
	state.position = packet.Origin
	state.traveled = 0
	projectiles[packet.Token] = state
	state.connection = RunService.Heartbeat:Connect(function(dt)
		if state.done then
			return
		end
		if not combat.Enabled or not combat.Alive(state.actor) or state.actor.Model ~= state.model then
			finish(state)
			return
		end
		local step = math.min(dt * move.Speed, move.Range - state.traveled)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local excluded = { state.model }
		for _, other in combat.Actors do
			if other.Model then
				table.insert(excluded, other.Model)
			end
		end
		params.FilterDescendantsInstances = excluded
		params.RespectCanCollide = true
		local hit = workspace:Raycast(state.position, packet.Direction * step, params)
		local obstruction = hit and (hit.Position - state.position).Magnitude or step
		local victim, nearest = nil, obstruction + 0.001
		for _, other in combat.Actors do
			if other ~= state.actor and combat.Alive(other) then
				local offset = combat.Root(other).Position - state.position
				local along = math.clamp(offset:Dot(packet.Direction), 0, step)
				if (offset - packet.Direction * along).Magnitude <= move.Radius and along < nearest then
					victim, nearest = other, along
				end
			end
		end
		if victim then
			-- Catch is evaluated before impact, including frames between the inhale polling ticks.
			if Service.TryInhale(combat, victim) and state.done then
				return
			end
			damage(combat, state, victim, move.Damage, state.position)
			finish(state, "Impact", state.position + packet.Direction * nearest)
			return
		end
		state.position += packet.Direction * step
		state.traveled += step
		if hit or state.traveled >= move.Range then
			finish(state, "Impact", hit and hit.Position or state.position)
		end
	end)
end

function Service.Cast(combat, actor, power, index, move)
	local root = combat.Root(actor)
	local model = actor.Model
	local direction = root.CFrame.LookVector
	local origin = root.Position
	-- Start at the caster so the first swept segment cannot skip a nearby wall.
	if move.Kind == "Field" then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { model }
		params.RespectCanCollide = true
		local hit = workspace:Raycast(origin, direction * move.Range, params)
		origin += direction * (hit and math.max(0, hit.Distance - 2) or move.Range)
	end
	local delay = move.Delay or 0.2
	local duration = delay + ((move.Kind == "Projectile" or move.Kind == "Wave") and move.Range / move.Speed
		or move.Kind == "Dash" and move.DashTime + 0.4 or 0.9)
	local state = { actor = actor, model = model, move = move, packet = {
		Effect = "PowerMove", Phase = "Start", Caster = model, Power = power,
		Key = ({ "Q", "E", "R" })[index], Token = HttpService:GenerateGUID(false), Origin = origin,
		Direction = direction, StartedAt = workspace:GetServerTimeNow(), Duration = duration,
		Delay = delay, Radius = move.Radius, Speed = move.Speed or 0,
	} }
	actor.PowerCast = state
	send(state, "Start")
	task.delay(delay, function()
		if state.done or actor.PowerCast ~= state or not valid(combat, actor, model) then
			finish(state)
			return
		end
		if move.Kind == "Projectile" then
			launch(combat, state)
			return
		end
		if move.Kind == "Dash" then
			-- The caster lunges along their facing (Range studs over DashTime), cutting everyone within Radius of the path.
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			if root.Anchored or (humanoid and (humanoid.Sit or humanoid.PlatformStand)) then
				finish(state)
				return
			end
			local flat = Vector3.new(direction.X, 0, direction.Z)
			local dash = flat.Magnitude > 0.01 and flat.Unit or direction
			local autoRotate = humanoid and humanoid.AutoRotate
			if humanoid then
				humanoid.AutoRotate = false
			end
			local owned = pcall(function()
				root:SetNetworkOwner(nil)
			end)
			actor.Invulnerable = os.clock() + move.DashTime
			local params = worldParameters(combat)
			local hitSet, traveled, elapsed = {}, 0, 0
			local function cleanup()
				if humanoid and humanoid.Parent then
					humanoid.AutoRotate = autoRotate
				end
				if owned and root.Parent then
					pcall(function()
						root:SetNetworkOwnershipAuto()
					end)
				end
			end
			state.connection = RunService.Heartbeat:Connect(function(dt)
				if state.done or actor.PowerCast ~= state or not valid(combat, actor, model) or root.Anchored then
					cleanup()
					finish(state)
					return
				end
				local step = math.min(dt, move.DashTime - elapsed)
				local want = move.Range * (dashEase(elapsed + step, move.DashTime) - dashEase(elapsed, move.DashTime))
				local hit = workspace:Blockcast(root.CFrame, Vector3.new(3, 4, 2), dash * (want + 0.1), params)
				local moved = hit and math.clamp(hit.Distance - 0.1, 0, want) or want
				local before = root.Position
				root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				model:PivotTo(model:GetPivot() + dash * moved)
				hitWave(combat, state, before, root.Position, hitSet, params)
				traveled += moved
				elapsed += step
				if hit or elapsed >= move.DashTime then
					cleanup()
					finish(state, "Impact", root.Position)
				end
			end)
		elseif move.Kind == "Wave" then
			local distance, hitSet = 0, {}
			state.connection = RunService.Heartbeat:Connect(function(dt)
				if state.done or actor.PowerCast ~= state or not valid(combat, actor, model) then
					finish(state)
					return
				end
				local step = math.min(dt * move.Speed, move.Range - distance)
				local before = origin + direction * distance
				local params = worldParameters(combat)
				local wall = workspace:Raycast(before, direction * step, params)
				local traveled = wall and math.max(0, wall.Distance - 0.01) or step
				local after = before + direction * traveled
				hitWave(combat, state, before, after, hitSet, params)
				distance += traveled
				if wall or distance >= move.Range then
					finish(state, "Impact", wall and wall.Position or after)
				end
			end)
		else
			local pulses = move.Pulses or 1
			for pulse = 1, pulses do
				task.delay((pulse - 1) * 0.2, function()
					if not state.done and actor.PowerCast == state and valid(combat, actor, model) then
						hitArea(combat, state, origin, move.Damage / pulses, move.Kind == "Cone")
					end
				end)
			end
		end
	end)
	task.delay(duration + 0.2, function()
		finish(state)
	end)
end

function Service.DebugStats()
	local count = 0
	for _ in projectiles do
		count += 1
	end
	return { projectiles = count }
end
return Service
