local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local C = require(ReplicatedStorage.Shared.PilotConfig)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Data = require(script.Parent.DataService)
local World = require(script.Parent.PilotWorld)
local Combat = require(script.Parent.PilotCombat)
local Service = {}
local actors, bandits = Combat.Actors, Combat.Bandits
local phase, deadline, matchId = "Lobby", 0, 0
local rng = Random.new()
local results = {}

local function randomPower()
	return C.BaseIds[rng:NextInteger(1, #C.BaseIds)]
end

local function notify(player, message)
	Remotes.Notify:FireClient(player, message)
end

local function newActor(player)
	return { Player = player, HP = C.MaxHealth, Active = false, Queued = false, Slots = {}, Slot = 1,
		Cooldowns = {}, Score = 0, Damage = 0, Inhales = 0, Opponents = {}, EarnedKOs = 0 }
end

local function spawnPosition(index)
	return World.PlayerSpawnPosition(index)
end

local function resetActor(actor)
	actor.HP, actor.Slots, actor.Slot, actor.Cooldowns = C.MaxHealth, { randomPower() }, 1, {}
	actor.Held, actor.Inhaling, actor.Shield, actor.Protection = nil, nil, 0, 0
	actor.InhaleTarget, actor.InhaleMessage, actor.InhaleMessageUntil = nil, nil, 0
	actor.Stunned, actor.StunImmune, actor.Invulnerable = 0, 0, os.clock() + 1
end

local function placeCharacter(actor)
	local character = actor.Player.Character
	if not character then
		return
	end
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or character ~= actor.Player.Character then
		return
	end
	actor.Model = character
	actor.Dead = false
	resetActor(actor)
	humanoid.MaxHealth, humanoid.Health, humanoid.WalkSpeed = C.MaxHealth, C.MaxHealth, C.WalkSpeed
	actor.Player.RespawnLocation = World.Spawn
	character:PivotTo(CFrame.new(actor.Active and spawnPosition(rng:NextInteger(1, 8)) or World.LobbyPosition))
	humanoid.Died:Connect(function()
		if actor.Model == character and actor.HP > 0 then
			Combat.OnKO(nil, actor)
		end
	end)
end

local function createBot(index)
	local actor = newActor(nil)
	actor.Name, actor.Active, actor.Bot = "Bot " .. index, true, true
	resetActor(actor)
	actor.Model = World.Dummy(World.Root, actor.Name, spawnPosition(index) - Vector3.new(0, 3, 0), C.Powers[actor.Slots[1]].Color)
	-- Only the yellow power bandits are inhale targets; make fighters distinct.
	for _, part in actor.Model:GetChildren() do
		if part:IsA("BasePart") and part.Name ~= "PowerTell" then
			part.Color = Color3.fromRGB(80, 140, 220)
		end
	end
	local label = actor.Model.PrimaryPart:FindFirstChildWhichIsA("BillboardGui")
	if label then
		label.TextLabel.Text = actor.Name .. " - FIGHTER"
	end
	actors[actor.Name] = actor
end

local function clearBots()
	for key, actor in actors do
		if actor.Bot then
			actor.Active = false
			actor.Model:Destroy()
			actors[key] = nil
		end
	end
end

local function fillBots()
	local humans = 0
	for _, actor in actors do
		if actor.Player and actor.Active then
			humans += 1
		end
	end
	local needed = math.max(0, C.BotFill - humans)
	for i = 1, C.BotFill do
		local key = "Bot " .. i
		local bot = actors[key]
		if i <= needed and not bot then
			createBot(i)
		elseif i > needed and bot then
			bot.Active = false
			bot.Model:Destroy()
			actors[key] = nil
		end
	end
end

local function joinMatch(actor)
	if phase ~= "Match" or actor.Active or not Data.GetData(actor.Player) then
		return
	end
	local character = actor.Player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 or not character:FindFirstChild("HumanoidRootPart") then
		return
	end
	actor.Active, actor.Queued, actor.Dead, actor.Payout = true, false, false, 0
	actor.Score, actor.Damage, actor.Inhales, actor.EarnedKOs, actor.Opponents = 0, 0, 0, 0, {}
	placeCharacter(actor)
	notify(actor.Player, "Inhale a bandit to get a second power. Hold F, then G to swallow or T to spit.")
end

local function checkArenaEntry()
	local pad = World.ArenaTeleportPad
	for _, actor in actors do
		if not actor.Player or actor.Active then
			continue
		end
		local character = actor.Player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			local position = pad.CFrame:PointToObjectSpace(root.Position)
			-- Server-side volume check also handles standing on the pad while data loads.
			if math.abs(position.X) <= pad.Size.X / 2 and math.abs(position.Z) <= pad.Size.Z / 2
				and position.Y >= 0 and position.Y <= 7 then
				actor.Queued = true
			end
		end
		if actor.Queued then
			joinMatch(actor)
		end
	end
	if phase == "Match" then
		fillBots()
	end
end

local function spawnBandit(index, variant)
	local power = randomPower()
	if variant == "Normal" then
		power = C.BaseIds[(index - 1) % #C.BaseIds + 1]
	end
	local position = World.BanditPosition(index)
	local model = World.Dummy(World.Root, variant == "Mystery" and "Mystery" or power, position,
	variant == "Mystery" and Color3.new(1, 1, 1) or C.Powers[power].Color, variant)
	bandits[index] = { Model = model, Power = power, Variant = variant, NextAttack = os.clock() + 2 }
end

local function clearBandits()
	for index, bandit in bandits do
		if bandit.Model then
			bandit.Model:Destroy()
		end
		bandits[index] = nil
	end
end

local function takeBandit(actor, index, bandit)
	if bandits[index] ~= bandit or not bandit.Model.Parent then
		return
	end
	local held = { Power = bandit.Power, Variant = bandit.Variant }
	actor.Held, actor.Inhales = held, actor.Inhales + 1
	bandit.Model:Destroy()
	bandits[index] = nil
	local id = matchId
	task.delay(C.BanditRespawn, function()
		if phase == "Match" and matchId == id and index <= 6 and not bandits[index] then
			spawnBandit(index, "Normal")
		end
	end)
end

local function inhale(actor)
	if actor.Inhaling then
		return
	end
	if actor.Held then
		actor.InhaleMessage = "Already holding a bandit: G to swallow or T to spit."
		actor.InhaleMessageUntil = os.clock() + 2
		return
	end
	if not Combat.Ready(actor, "Inhale", C.InhaleCooldown) then
		local remaining = math.max(0, (actor.Cooldowns.Inhale or 0) - os.clock())
		actor.InhaleMessage = remaining > 0 and string.format("Inhale recharging: %.1fs", remaining)
			or "Cannot inhale while stunned. Try again when you can move."
		actor.InhaleMessageUntil = os.clock() + 1
		return
	end
	actor.Inhaling = true
	actor.InhaleTarget, actor.InhaleMessage = nil, nil
	local model, started = actor.Model, os.clock()
	task.spawn(function()
		while actor.Inhaling and Combat.Enabled and Combat.Alive(actor) and actor.Model == model and os.clock() - started < 2 do
			local root = Combat.Root(actor)
			local closest, candidate, distance = nil, nil, C.InhaleRange
			for index, bandit in bandits do
				local offset = bandit.Model.PrimaryPart.Position - root.Position
				local d = offset.Magnitude
				if d < distance and (d < 2 or offset.Unit:Dot(root.CFrame.LookVector) > 0.6)
				and Combat.LineClear(root.Position, bandit.Model.PrimaryPart.Position, { model, bandit.Model }) then
					closest, candidate, distance = index, bandit, d
				end
			end
			actor.InhaleTarget = candidate and (candidate.Variant == "Mystery" and "Mystery" or candidate.Power) or nil
			if candidate then
				local direction = root.Position - candidate.Model.PrimaryPart.Position
				candidate.Model:PivotTo(candidate.Model:GetPivot() + direction * 0.24)
				if distance < 4 and os.clock() - started >= C.InhaleDuration then
					takeBandit(actor, closest, candidate)
					break
				end
			end
			task.wait(0.06)
		end
		if actor.Model == model then
			actor.Inhaling = false
			actor.InhaleTarget = nil
			if not actor.Held then
				actor.InhaleMessage = "Hold F facing a yellow power bandit within 19 studs. Blue fighters cannot be inhaled."
				actor.InhaleMessageUntil = os.clock() + 2
			end
		end
	end)
end

local function swallow(actor, replacement)
	if not actor.Held or os.clock() < (actor.Stunned or 0) then
		return
	end
	local slot = not actor.Slots[1] and 1 or not actor.Slots[2] and 2 or replacement
	if slot ~= 1 and slot ~= 2 then
		if actor.Player then
			notify(actor.Player, "Both slots full: choose Replace 1 or Replace 2.")
		end
		return
	end
	local held = actor.Held
	actor.Held = nil
	local power = held.Variant == "Mystery" and randomPower() or held.Power
	actor.Slots[slot] = power
	actor.Protection = os.clock() + C.SwallowProtection
	Combat.Effect(Combat.Root(actor).Position, C.Powers[power].Color, 4, C.SwallowProtection)
	if held.Variant == "Mystery" and actor.Player then
		Remotes.PilotReveal:FireClient(actor.Player, power)
	end
end

local function input(player, action, argument)
	local actor = actors[player]
	if not actor or type(action) ~= "string" then
		return
	end
	-- One budget across all actions; no client-supplied target, damage, position or currency.
	local now = os.clock()
	actor.Tokens = math.min(20, (actor.Tokens or 20) + (now - (actor.LastInput or now)) * 12)
	actor.LastInput = now
	if actor.Tokens < 1 then
		return
	end
	actor.Tokens -= 1
	if action == "Queue" then
		if not Data.GetData(player) then
			notify(player, "Your save is loading. Try joining again shortly.")
			return
		end
		if actor.Active then
			return
		end
		actor.Queued = not actor.Queued
		if actor.Queued then
			joinMatch(actor)
		end
		return
	elseif action == "Shop" then
		local data, skin = Data.GetData(player), type(argument) == "string" and C.Skins[argument]
		if actor.Active or not data or not skin then
			return
		end
		if not data.cosmetics[argument] then
			if data.coins < skin.Price then
				notify(player, "Not enough coins.")
				return
			end
			data.coins -= skin.Price
			data.cosmetics[argument] = true
		end
		data.equippedStar = argument
		return
	end
	if phase ~= "Match" or not Combat.Alive(actor) then
		return
	end
	if action == "InhaleEnd" then
		actor.Inhaling = false
	elseif action == "Inhale" then
		inhale(actor)
	elseif action == "Swallow" then
		swallow(actor, argument)
	elseif action == "Spit" and actor.Held and Combat.Ready(actor, "Spit", 1.5) then
		actor.Held = nil
		local data = Data.GetData(player)
		local skin = C.Skins[data and data.equippedStar or "Default"] or C.Skins.Default
		Combat.Projectile(actor, skin.Color, 20, 65, true)
	elseif action == "Swap" and actor.Slots[2] and Combat.Ready(actor, "Swap", C.SwapCooldown) then
		actor.Slot = 3 - actor.Slot
	elseif action == "Fuse" and Combat.Ready(actor, "Fuse", 1) then
		local fusion = C.Fusion(actor.Slots[1], actor.Slots[2])
		if fusion then
			-- Preserve the longest existing move cooldown to prevent fusion resetting a signature.
			local longest = now
			for _, time in actor.Cooldowns do
				longest = math.max(longest, time)
			end
			actor.Slots, actor.Slot = { fusion }, 1
			for i = 1, 3 do
				actor.Cooldowns[fusion .. i] = longest
			end
			Combat.Effect(Combat.Root(actor).Position, C.Powers[fusion].Color, 5, 0.6)
		end
	else
		Combat.Action(actor, action, argument)
	end
end

function Combat.OnKO(source, target)
	if target.Dead then
		return
	end
	target.Dead, target.HP, target.Inhaling, target.Held = true, 0, nil, nil
	if source then
		source.Score += 1
		local key = target.Player and tostring(target.Player.UserId) or target.Name
		source.Opponents[key] = (source.Opponents[key] or 0) + 1
		source.EarnedKOs += (target.Bot and 0.25 or 1) / source.Opponents[key]
	end
	local data = target.Player and Data.GetData(target.Player)
	if data then
		data.stats.deaths += 1
	end
	local humanoid = target.Model and target.Model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.Health = 0
	end
	local id = matchId
	task.delay(3, function()
		if phase ~= "Match" or id ~= matchId or not target.Active then
			return
		end
		if target.Bot then
			resetActor(target)
			target.Dead = false
			target.Model:PivotTo(CFrame.new(spawnPosition(rng:NextInteger(1, 8))))
		end
	end)
end

local function standings()
	local rows = {}
	for _, actor in actors do
		if actor.Active then
			table.insert(rows, { Name = actor.Player and actor.Player.DisplayName or actor.Name, Score = actor.Score, Bot = actor.Bot == true })
		end
	end
	table.sort(rows, function(a, b)
		if a.Score == b.Score then
			return a.Name < b.Name
		end
		return a.Score > b.Score
	end)
	return rows
end

local function payout()
	results = standings()
	local best = results[1] and results[1].Score or 0
	for _, actor in actors do
		if not actor.Player or not actor.Active then
			continue
		end
		local data = Data.GetData(actor.Player)
		local eligible = actor.Damage >= 20 or actor.Inhales >= 2
		actor.Payout = 0
		if data and eligible then
			local day = math.floor(os.time() / 86400)
			if data.rewardDay ~= day then
				data.rewardDay, data.boostedMatches = day, 0
			end
			local won = actor.Score == best and actor.Score > 0
			local base = 10 + math.floor(math.min(actor.EarnedKOs, 10) * 2) + (won and 10 or 0)
			local humans = 0
			for _, other in actors do
				if other.Active and other.Player then
					humans += 1
				end
			end
			if humans <= 1 then
				base = math.max(5, math.floor(base * 0.5))
			end
			actor.Payout = base * (data.boostedMatches < 10 and 2 or 1)
			data.boostedMatches += 1
			data.coins += actor.Payout
			data.stats.matches += 1
			data.stats.kos += actor.Score
			if won then
				data.stats.wins += 1
				data.titles.ArenaWinner = true
			end
		end
	end
end

local function sendState()
	local rows = phase == "Results" and results or standings()
	local board = {}
	for _, player in Players:GetPlayers() do
		local data = Data.GetData(player)
		if data then
			table.insert(board, { Name = player.DisplayName, Wins = data.stats.wins, KOs = data.stats.kos })
		end
	end
	table.sort(board, function(a, b)
		return a.Wins > b.Wins
	end)
	if World.Leaderboard then
		for i = 1, 5 do
			local row = World.Leaderboard:FindFirstChild("Row" .. i)
			if row then
				local entry = board[i]
				row.Sign.Text.Text = entry and string.format("%d. %s   %d wins", i, entry.Name, entry.Wins) or i .. ".  --"
			end
		end
	end
	for player, actor in actors do
		if actor.Bot then
			continue
		end
		local data = Data.GetData(player)
		local cooldowns = {}
		for key, time in actor.Cooldowns do
			cooldowns[key] = math.max(0, time - os.clock())
		end
		Remotes.PilotState:FireClient(player, { Phase = phase, Seconds = math.max(0, math.ceil(deadline - os.clock())),
			Queued = actor.Queued, Active = actor.Active, HP = math.ceil(actor.HP), Slots = actor.Slots, Slot = actor.Slot,
			Inhaling = actor.Inhaling == true, InhaleTarget = actor.InhaleTarget,
			InhaleMessage = os.clock() < (actor.InhaleMessageUntil or 0) and actor.InhaleMessage or nil,
			Held = actor.Held and actor.Held.Variant == "Mystery" and "Mystery" or actor.Held and actor.Held.Power,
			Cooldowns = cooldowns, Coins = data and data.coins or 0, Cosmetics = data and data.cosmetics or {},
			Skin = data and data.equippedStar or "Default", Rows = rows, Board = board, Payout = actor.Payout or 0,
			Ready = data ~= nil, Title = data and data.titles.ArenaWinner == true })
	end
end

local function stepAI(dt)
	for _, actor in actors do
		if not Combat.Alive(actor) then
			continue
		end
		local humanoid = actor.Model:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = os.clock() < (actor.Stunned or 0) and 0 or actor.Inhaling and 8 or C.WalkSpeed
		end
		if not actor.Bot then
			continue
		end
		local root, target, distance = Combat.Root(actor), nil, math.huge
		for _, other in actors do
			if other ~= actor and Combat.Alive(other) then
				local d = (Combat.Root(other).Position - root.Position).Magnitude
				if d < distance then
					target, distance = other, d
				end
			end
		end
		if target and os.clock() >= (actor.Stunned or 0) then
			local position = root.Position
			local goal = Combat.Root(target).Position
			local flat = Vector3.new(goal.X, position.Y, goal.Z)
			if (flat - position).Magnitude > 0.1 then
				local direction = (flat - position).Unit
				local nextPosition = position + direction * math.min(math.max(distance - 5, 0), dt * 12)
				if not Combat.LineClear(position, nextPosition + direction * 2, { actor.Model, target.Model }) then
					nextPosition = position + Vector3.new(-direction.Z, 0, direction.X) * dt * 12
				end
				actor.Model:PivotTo(CFrame.lookAt(nextPosition, flat))
			end
			if distance < 9 then
				Combat.Action(actor, "M1")
			end
			if distance < 45 then
				Combat.Action(actor, "Move", 1)
			end
			if distance < 16 then
				Combat.Action(actor, "Move", 3)
			end
		end
	end
	for _, bandit in bandits do
		if os.clock() < bandit.NextAttack then
			continue
		end
		local position, target, distance = bandit.Model.PrimaryPart.Position, nil, 23
		for _, actor in actors do
			-- Bandits prioritize the nearest human player, never match score.
			if actor.Player and Combat.Alive(actor) then
				local d = (Combat.Root(actor).Position - position).Magnitude
				if d < distance then
					target, distance = actor, d
				end
			end
		end
		if target then
			bandit.NextAttack = os.clock() + (bandit.Variant == "Rare" and 2 or 3)
			Combat.Effect(position, C.Powers[bandit.Power].Color, 3, 0.5)
			local model = bandit.Model
			task.delay(0.5, function()
				if phase == "Match" and model.Parent and Combat.Alive(target)
				and (Combat.Root(target).Position - position).Magnitude < 25
				and Combat.LineClear(position, Combat.Root(target).Position, { model, target.Model }) then
					Combat.Effect(Combat.Root(target).Position, C.Powers[bandit.Power].Color, 2)
					Combat.Damage(nil, target, 4, 0, false)
				end
			end)
		end
	end
end

local function runMatches()
	while true do
		matchId += 1
		phase, deadline = "Match", os.clock() + C.MatchSeconds
		Combat.Enabled = true
		for _, actor in actors do
			if actor.Queued and actor.Player then
				joinMatch(actor)
			end
		end
		fillBots()
		for i = 1, 6 do
			spawnBandit(i, "Normal")
		end
		local nextRare, nextMystery = os.clock() + 20, os.clock() + 30
		while os.clock() < deadline do
			if os.clock() >= nextRare then
				if not bandits[7] then
					spawnBandit(7, "Rare")
				end
				nextRare = os.clock() + 25
			end
			if os.clock() >= nextMystery then
				if not bandits[8] then
					spawnBandit(8, "Mystery")
				end
				nextMystery = os.clock() + 30
			end
			stepAI(0.1)
			task.wait(0.1)
		end
		phase, deadline = "Results", os.clock() + C.ResultsSeconds
		Combat.Enabled = false
		payout()
		clearBandits()
		repeat
			task.wait(0.25)
		until os.clock() >= deadline
		clearBots()
		for _, actor in actors do
			actor.Active, actor.Dead, actor.Held, actor.Inhaling = false, false, nil, nil
			actor.Slots = {}
			if actor.Player then
				placeCharacter(actor)
				actor.Slots = {}
			end
		end
		phase, deadline = "Intermission", os.clock() + C.IntermissionSeconds
		repeat
			task.wait(0.25)
		until os.clock() >= deadline
	end
end

function Service.Init()
	World.Build()
end

function Service.Start()

	local function added(player)
		local actor = newActor(player)
		actors[player] = actor
		player.RespawnLocation = World.Spawn
		player.CharacterAdded:Connect(function()
			actor.Dead = false
			placeCharacter(actor)
			if not actor.Active then
				actor.Slots = {}
			end
		end)
		if player.Character then
			task.spawn(placeCharacter, actor)
		end
	end
	Players.PlayerAdded:Connect(added)
	Players.PlayerRemoving:Connect(function(player)
		local actor = actors[player]
		if actor then
			actor.Active = false
			actor.Inhaling = false
		end
		actors[player] = nil
	end)
	for _, player in Players:GetPlayers() do
		added(player)
	end
	Remotes.PilotInput.OnServerEvent:Connect(input)
	task.spawn(runMatches)
	task.spawn(function()
		while true do
			checkArenaEntry()
			sendState()
			task.wait(0.2)
		end
	end)
end
return Service
