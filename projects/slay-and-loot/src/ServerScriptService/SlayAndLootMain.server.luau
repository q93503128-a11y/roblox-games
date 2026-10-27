local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.SlayAndLoot.Config)
local Shared = require(RS.SlayAndLoot.Shared)
local PlayerState = require(RS.SlayAndLoot.PlayerState)
local EnemyService = require(RS.SlayAndLoot.EnemyService)
local CombatService = require(RS.SlayAndLoot.CombatService)
local RunService_ = require(RS.SlayAndLoot.RunService)

local remotes = RS.SlayAndLoot.Remotes
local Request = remotes.Request
local StateSync = remotes.StateSync
local Feedback = remotes.Feedback

Players.RespawnTime = 3
Players.CharacterAutoLoads = true

local function faceAim(player, payload)
	if type(payload) == "table" and typeof(payload.aim) == "Vector3" then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local f = Vector3.new(payload.aim.X, 0, payload.aim.Z)
			if f.Magnitude > 0.05 then
				hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + f.Unit)
			end
		end
	end
end

local function sync(player)
	if player and player.Parent then
		StateSync:FireClient(player, PlayerState.snapshot(player))
	end
end

local function broadcast(kind, payload)
	Feedback:FireAllClients(kind, payload)
end

EnemyService.hooks.playerHit = function(raw, pos)
	for _, p in ipairs(Players:GetPlayers()) do
		CombatService.applyPlayerDamage(p, raw)
	end
	broadcast("playerHit", { pos = pos })
end

EnemyService.hooks.fx = function(kind, payload)
	if kind == "hit" then
		broadcast("damage", payload)
	elseif kind == "slam" then
		broadcast("slam", payload)
	elseif kind == "enemyHit" then
		broadcast("enemyAttack", payload)
	end
end

EnemyService.hooks.onDeath = function(e)
	broadcast("enemyDeath", { pos = e.pos, kind = e.kind })
end

CombatService.onEvent = function(kind, player, payload)
	if kind == "playerHurt" then
		broadcast("playerHurt", payload)
		sync(player)
	elseif kind == "swing" or kind == "skill" or kind == "dash" then
		Feedback:FireClient(player, kind, payload)
	elseif kind == "connect" then
		broadcast("connect", payload)
	end
end

RunService_.onState = function(player)
	sync(player)
end

RunService_.onEvent = function(player, kind, payload)
	Feedback:FireClient(player, kind, payload)
	if kind == "roomClear" or kind == "bossDown" or kind == "loot" or kind == "encounter" then
		sync(player)
	end
end

local function onCharacter(player, char)
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	hum.MaxHealth = Config.Player.maxHP
	hum.Health = Config.Player.maxHP
	hum.WalkSpeed = Config.Player.walkSpeed
	hum.UseJumpPower = false
	hum.JumpHeight = 7.2
	local st = PlayerState.get(player)
	if st.runState ~= "active" then
		RunService_.returnToHub(player)
	end
	sync(player)
end

local function onPlayer(player)
	PlayerState.get(player)
	player.CharacterAdded:Connect(function(char) onCharacter(player, char) end)
	if player.Character then onCharacter(player, player.Character) end
	sync(player)
end

Players.PlayerAdded:Connect(onPlayer)
for _, p in ipairs(Players:GetPlayers()) do onPlayer(p) end
Players.PlayerRemoving:Connect(function(p) PlayerState.remove(p) end)

Request.OnServerEvent:Connect(function(player, action, payload)
	if type(action) ~= "string" then return end
	if action == "attack" then
		faceAim(player, payload)
		CombatService.attack(player)
	elseif action == "dash" then
		faceAim(player, payload)
		CombatService.dash(player)
	elseif action == "skill" then
		faceAim(player, payload)
		CombatService.skill(player)
	elseif action == "startRun" then
		local st = PlayerState.get(player)
		local want = type(payload) == "table" and payload.difficulty or "Normal"
		if want == "Hard" and not st.hasClearedNormal then return end
		RunService_.start(player, want)
	elseif action == "abandon" then
		RunService_.abort(player)
		RunService_.returnToHub(player)
	elseif action == "claimLoot" then
		local st = PlayerState.get(player)
		if st.pendingLoot then
			PlayerState.addItem(st, st.pendingLoot)
			st.pendingLoot = nil
			st.lootTaken = true
			Feedback:FireClient(player, "lootClaimed", {})
			sync(player)
		end
	elseif action == "equip" then
		local st = PlayerState.get(player)
		if type(payload) == "table" and type(payload.id) == "string" then
			if PlayerState.equip(st, payload.id) then
				Feedback:FireClient(player, "equipped", { id = payload.id })
				sync(player)
			end
		end
	elseif action == "hub" then
		RunService_.abort(player)
		RunService_.returnToHub(player)
	end
end)

RunService_.setup()

task.spawn(function()
	local RunS = game:GetService("RunService")
	local acc = 0
	RunS.Heartbeat:Connect(function(dt)
		acc += dt
		local players = Players:GetPlayers()
		if #players > 0 then
			EnemyService.update(dt, players[1])
			RunService_.update(dt, players)
		end
		if acc >= 0.5 then
			acc = 0
			for _, p in ipairs(players) do sync(p) end
		end
	end)
end)

game:GetService("StarterPlayer").StarterPlayerScripts:SetAttribute("SlayAndLootReady", true)
print("[SlayAndLoot] server ready")
