--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local GameConfig = require(script.Parent.GameConfig)
local Protocol = require(ReplicatedStorage:WaitForChild("RebirthRPG"):WaitForChild("Shared"):WaitForChild("Protocol"))

local EnemyService = {}

local bound: { [Model]: boolean } = {}

local function setServerNetworkOwnership(model: Model)
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") and not descendant.Anchored then
			pcall(function()
				descendant:SetNetworkOwner(nil)
			end)
		end
	end
end

local function getNearestTarget(origin: Vector3, maxDistance: number): (Player?, BasePart?, Humanoid?)
	local bestPlayer: Player? = nil
	local bestRoot: BasePart? = nil
	local bestHumanoid: Humanoid? = nil
	local bestDistance = maxDistance

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character == nil then
			continue
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if humanoid == nil or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
			continue
		end

		local distance = (root.Position - origin).Magnitude
		if distance < bestDistance then
			bestDistance = distance
			bestPlayer = player
			bestRoot = root
			bestHumanoid = humanoid
		end
	end

	return bestPlayer, bestRoot, bestHumanoid
end

local function canStillHit(model: Model, humanoid: Humanoid, targetRoot: BasePart, targetHumanoid: Humanoid, attackRange: number): boolean
	if model.Parent == nil or humanoid.Health <= 0 then
		return false
	end
	if targetRoot.Parent == nil or targetHumanoid.Health <= 0 then
		return false
	end
	return (targetRoot.Position - model:GetPivot().Position).Magnitude <= attackRange + 1.5
end

local function runBrain(model: Model, humanoid: Humanoid, config: any)
	local lastAttackAt = -math.huge

	while model.Parent ~= nil and humanoid.Health > 0 do
		local origin = model:GetPivot().Position
		local _player, targetRoot, targetHumanoid = getNearestTarget(origin, config.aggroRange)

		if targetRoot ~= nil and targetHumanoid ~= nil then
			local distance = (targetRoot.Position - origin).Magnitude
			if distance <= config.attackRange then
				humanoid:MoveTo(origin)
				local now = os.clock()
				if now - lastAttackAt >= config.attackCooldown then
					lastAttackAt = now
					model:SetAttribute(Protocol.Attributes.AttackState, "Windup")
					task.wait(config.attackWindup)

					if canStillHit(model, humanoid, targetRoot, targetHumanoid, config.attackRange) then
						targetHumanoid:TakeDamage(config.damage)
					end

					if model.Parent ~= nil and humanoid.Health > 0 then
						model:SetAttribute(Protocol.Attributes.AttackState, "Idle")
					end
				end
			else
				humanoid:MoveTo(targetRoot.Position)
			end
		else
			humanoid:MoveTo(origin)
		end

		task.wait(0.20)
	end
end

local function bindEnemy(instance: Instance)
	if not instance:IsA("Model") or bound[instance] then
		return
	end

	local enemyId = instance:GetAttribute(Protocol.Attributes.EnemyId)
	if type(enemyId) ~= "string" then
		warn(string.format("[RebirthRPG] Tagged enemy %s is missing EnemyId", instance:GetFullName()))
		return
	end

	local config = GameConfig.Enemies[enemyId]
	if config == nil then
		warn(string.format("[RebirthRPG] Tagged enemy %s uses unknown EnemyId %s", instance:GetFullName(), enemyId))
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	if humanoid == nil then
		warn(string.format("[RebirthRPG] Enemy %s has no Humanoid", instance:GetFullName()))
		return
	end

	bound[instance] = true
	instance:SetAttribute(Protocol.Attributes.RewardClaimed, false)
	instance:SetAttribute(Protocol.Attributes.AttackState, "Idle")
	humanoid.MaxHealth = config.maxHealth
	humanoid.Health = config.maxHealth
	humanoid.WalkSpeed = config.moveSpeed
	setServerNetworkOwnership(instance)

	local spawnCFrame = instance:GetPivot()
	local spawnParent = instance.Parent
	local respawnTemplate = instance:Clone()

	humanoid.Died:Connect(function()
		bound[instance] = nil
		instance:SetAttribute(Protocol.Attributes.AttackState, "Dead")

		task.delay(math.min(config.respawnTime, 2), function()
			if instance.Parent ~= nil then
				instance:Destroy()
			end
		end)

		task.delay(config.respawnTime, function()
			if spawnParent == nil or spawnParent.Parent == nil then
				return
			end

			local replacement = respawnTemplate:Clone()
			replacement:SetAttribute(Protocol.Attributes.EnemyId, enemyId)
			replacement:SetAttribute(Protocol.Attributes.RewardClaimed, false)
			replacement:SetAttribute(Protocol.Attributes.AttackState, "Idle")
			replacement:PivotTo(spawnCFrame)
			replacement.Parent = spawnParent
			CollectionService:AddTag(replacement, Protocol.Tags.Enemy)
		end)
	end)

	task.spawn(runBrain, instance, humanoid, config)
end

function EnemyService.Start()
	for _, instance in ipairs(CollectionService:GetTagged(Protocol.Tags.Enemy)) do
		bindEnemy(instance)
	end

	CollectionService:GetInstanceAddedSignal(Protocol.Tags.Enemy):Connect(bindEnemy)
end

return EnemyService
