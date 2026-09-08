--!strict

local GameConfig = require(script.Parent.GameConfig)

local RewardService = {}

local ProfileService: any = nil
local rng = Random.new()

function RewardService.Init(profileService: any)
	ProfileService = profileService
end

function RewardService.AwardEnemyDefeat(player: Player, enemyId: string)
	if ProfileService == nil then
		return nil
	end

	local enemy = GameConfig.Enemies[enemyId]
	if enemy == nil then
		warn(string.format("[RebirthRPG] Unknown enemy reward id: %s", enemyId))
		return nil
	end

	local xpAwarded = ProfileService.AddXP(player, enemy.xpReward)
	local goldAwarded = ProfileService.AddGold(player, enemy.goldReward)

	if enemy.clearFlag ~= nil then
		ProfileService.SetRegionFlag(player, enemy.clearFlag, true)
	end

	local lootAwarded = {}
	local lootTable = GameConfig.LootTables[enemy.lootTable]
	if lootTable ~= nil then
		local luckBonus = ProfileService.GetLuckBonus(player)
		for _, entry in ipairs(lootTable) do
			local itemDefinition = GameConfig.Items[entry.itemId]
			if itemDefinition ~= nil and itemDefinition.unique == true and ProfileService.OwnsItem(player, entry.itemId) then
				continue
			end

			local effectiveChance = math.clamp(entry.chance + luckBonus, 0, 1)
			if rng:NextNumber() <= effectiveChance then
				if ProfileService.AddItem(player, entry.itemId, 1) then
					table.insert(lootAwarded, entry.itemId)
				end
			end
		end
	end

	return {
		xp = xpAwarded,
		gold = goldAwarded,
		items = lootAwarded,
		clearFlag = enemy.clearFlag,
	}
end

return RewardService
