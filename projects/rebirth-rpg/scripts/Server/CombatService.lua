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
local skillRemote: RemoteEvent? = nil
local feedbackRemote: RemoteEvent? = nil

local lastAttackAt: { [Player]: number } = {}
local lastSkillAt: { [Player]: number } = {}
local busyUntil: { [Player]: number } = {}
local comboState: { [Player]: { index: number, lastAt: number } } = {}

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

local function getEquippedWeapon(player: Player): (string?, any?)
	if ProfileService == nil then
		return nil, nil
	end
	local profile = ProfileService.Get(player)
	if profile == nil then
		return nil, nil
	end

	local weaponId = profile.inventory.equipped.mainhand
	if type(weaponId) ~= "string" then
		return nil, nil
	end
	return weaponId, GameConfig.Weapons[weaponId]
end

local function executeVolumeAttack(
	player: Player,
	weaponId: string,
	hitboxSize: Vector3,
	forwardOffset: number,
	maxTargets: number,
	damageScale: number,
	actionKind: string,
	comboIndex: number?
)
	local character = player.Character
	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if humanoid == nil or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then
		return
	end

	local currentWeaponId, weapon = getEquippedWeapon(player)
	if currentWeaponId ~= weaponId or weapon == nil then
		return
	end

	local attackCFrame = root.CFrame * CFrame.new(0, 0, -forwardOffset)
	local overlap = OverlapParams.new()
	overlap.FilterType = Enum.RaycastFilterType.Exclude
	overlap.FilterDescendantsInstances = { character }
	local parts = workspace:GetPartBoundsInBox(attackCFrame, hitboxSize, overlap)

	local alreadyHit: { [Model]: boolean } = {}
	local targetsHit = 0
	for _, part in ipairs(parts) do
		if targetsHit >= maxTargets then
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

		local damage = math.max(
			1,
			math.floor(weapon.baseDamage * damageScale * ProfileService.GetDamageMultiplier(player) + 0.5)
		)
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
				action = actionKind,
				comboIndex = comboIndex,
				enemyId = enemyId,
				damage = damage,
				killed = killed,
				rewards = rewards,
			})
		end
	end
end

local function onAttackIntent(player: Player)
	local weaponId, weapon = getEquippedWeapon(player)
	if weaponId == nil or weapon == nil then
		return
	end

	local now = os.clock()
	if now < (busyUntil[player] or -math.huge) then
		return
	end
	local previous = lastAttackAt[player] or -math.huge
	if now - previous < weapon.cooldown then
		return
	end
	lastAttackAt[player] = now
	busyUntil[player] = now + weapon.windup + 0.08

	local state = comboState[player]
	if state == nil or now - state.lastAt > weapon.comboReset then
		state = { index = 1, lastAt = now }
		comboState[player] = state
	else
		state.index = (state.index % #weapon.comboMultipliers) + 1
		state.lastAt = now
	end

	local comboIndex = state.index
	local damageScale = weapon.comboMultipliers[comboIndex]
	task.delay(weapon.windup, function()
		if player.Parent == Players then
			executeVolumeAttack(
				player,
				weaponId,
				weapon.hitboxSize,
				weapon.forwardOffset,
				weapon.maxTargets,
				damageScale,
				"basic",
				comboIndex
			)
		end
	end)
end

local function onSkillIntent(player: Player)
	local weaponId, weapon = getEquippedWeapon(player)
	if weaponId == nil or weapon == nil or weapon.skill == nil then
		return
	end

	local now = os.clock()
	if now < (busyUntil[player] or -math.huge) then
		return
	end
	local previous = lastSkillAt[player] or -math.huge
	if now - previous < weapon.skill.cooldown then
		return
	end
	lastSkillAt[player] = now
	busyUntil[player] = now + weapon.skill.windup + 0.12

	task.delay(weapon.skill.windup, function()
		if player.Parent == Players then
			executeVolumeAttack(
				player,
				weaponId,
				weapon.skill.hitboxSize,
				weapon.skill.forwardOffset,
				weapon.skill.maxTargets,
				weapon.skill.damageMultiplier,
				"skill",
				nil
			)
		end
	end)
end

function CombatService.Init(
	profileService: any,
	rewardService: any,
	attackIntent: RemoteEvent,
	skillIntent: RemoteEvent,
	combatFeedback: RemoteEvent
)
	ProfileService = profileService
	RewardService = rewardService
	attackRemote = attackIntent
	skillRemote = skillIntent
	feedbackRemote = combatFeedback
	attackRemote.OnServerEvent:Connect(onAttackIntent)
	skillRemote.OnServerEvent:Connect(onSkillIntent)

	Players.PlayerRemoving:Connect(function(player)
		lastAttackAt[player] = nil
		lastSkillAt[player] = nil
		busyUntil[player] = nil
		comboState[player] = nil
	end)
end

return CombatService
