--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local GameConfig = require(script.Parent.GameConfig)
local Protocol = require(ReplicatedStorage:WaitForChild("RebirthRPG"):WaitForChild("Shared"):WaitForChild("Protocol"))

local CombatService = {}

local ProfileService: any = nil
local RewardService: any = nil
local attackRemote: RemoteEvent? = nil
local feedbackRemote: RemoteEvent? = nil
local lastAttackAt: { [Player]: number } = {}

local function findEnemyModel(part: BasePart): Model?
	local current: Instance? = part
	while current ~= nil and current ~= workspace do
		if current:IsA("Model") and CollectionService:HasTag(current, Protocol.Tags.Enemy) then
			return current
		end
		current = current.Parent
	end
	return nil
end

local function hasLineOfSight(character: Model, targetModel: Model, origin: Vector3, target: Vector3): boolean
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	params.IgnoreWater = true

	local result = workspace:Raycast(origin, target - origin, params)
	if result == nil then
		return true
	end
	return result.Instance:IsDescendantOf(targetModel)
end

local function executeAttack(player: Player, weaponId: string)
	local character = player.Character
	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if humanoid == nil or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return
	end

	local profile = ProfileService.Get(player)
	if profile == nil or profile.inventory.equipped.mainhand ~= weaponId then
		return
	end

	local weapon = GameConfig.Weapons[weaponId]
	if weapon == nil then
		return
	end

	local attackCFrame = root.CFrame * CFrame.new(0, 0, -weapon.forwardOffset)
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = { character }
	local parts = workspace:GetPartBoundsInBox(attackCFrame, weapon.hitboxSize, overlap)

	local alreadyHit: { [Model]: boolean } = {}
	local targetsHit = 0
	for _, part in ipairs(parts) do
		if targetsHit >= weapon.maxTargets then
			break
		end
		if not part:IsA("BasePart") then
			continue
		end

		local enemyModel = findEnemyModel(part)
		if enemyModel == nil or alreadyHit[enemyModel] then
			continue
		end
		alreadyHit[enemyModel] = true

		local enemyId = enemyModel:GetAttribute(Protocol.Attributes.EnemyId)
		local enemyHumanoid = enemyModel:FindFirstChildOfClass("Humanoid")
		if type(enemyId) ~= "string" or enemyHumanoid == nil or enemyHumanoid.Health <= 0 then
			continue
		end

		local targetPosition = enemyModel:GetPivot().Position
		if not hasLineOfSight(character, enemyModel, root.Position, targetPosition) then
			continue
		end

		local damage = math.max(1, math.floor(weapon.baseDamage * ProfileService.GetDamageMultiplier(player) + 0.5))
		local beforeHealth = enemyHumanoid.Health
		enemyHumanoid:TakeDamage(damage)
		targetsHit += 1

		local killed = beforeHealth > 0 and enemyHumanoid.Health <= 0
		local rewards = nil
		if killed and enemyModel:GetAttribute(Protocol.Attributes.RewardClaimed) ~= true then
			enemyModel:SetAttribute(Protocol.Attributes.RewardClaimed, true)
			rewards = RewardService.AwardEnemyDefeat(player, enemyId)
		end

		if feedbackRemote ~= nil then
			feedbackRemote:FireClient(player, {
				type = "hit",
				enemyId = enemyId,
				damage = damage,
				killed = killed,
				rewards = rewards,
			})
		end
	end
end

local function onAttackIntent(player: Player)
	if ProfileService == nil then
		return
	end

	local profile = ProfileService.Get(player)
	if profile == nil then
		return
	end

	local weaponId = profile.inventory.equipped.mainhand
	if type(weaponId) ~= "string" then
		return
	end

	local weapon = GameConfig.Weapons[weaponId]
	if weapon == nil then
		return
	end

	local now = os.clock()
	local previous = lastAttackAt[player] or -math.huge
	if now - previous < weapon.cooldown then
		return
	end
	lastAttackAt[player] = now

	task.delay(weapon.windup, function()
		if player.Parent == Players then
			executeAttack(player, weaponId)
		end
	end)
end

function CombatService.Init(profileService: any, rewardService: any, attackIntent: RemoteEvent, combatFeedback: RemoteEvent)
	ProfileService = profileService
	RewardService = rewardService
	attackRemote = attackIntent
	feedbackRemote = combatFeedback
	attackRemote.OnServerEvent:Connect(onAttackIntent)

	Players.PlayerRemoving:Connect(function(player)
		lastAttackAt[player] = nil
	end)
end

return CombatService
