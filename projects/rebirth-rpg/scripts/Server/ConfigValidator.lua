--!strict

local GameConfig = require(script.Parent.GameConfig)

local ConfigValidator = {}

local function assertFinitePositive(label: string, value: any)
	assert(type(value) == "number", string.format("%s must be a number", label))
	assert(value == value and value ~= math.huge and value ~= -math.huge, string.format("%s must be finite", label))
	assert(value > 0, string.format("%s must be > 0", label))
end

local function validateProtocol(protocol: any)
	assert(type(protocol) == "table", "Protocol must be a table")
	assert(type(protocol.Remotes) == "table", "Protocol.Remotes must be a table")

	local seen: { [string]: string } = {}
	for key, name in pairs(protocol.Remotes) do
		assert(type(key) == "string", "Protocol remote key must be a string")
		assert(type(name) == "string" and #name > 0, string.format("Protocol remote %s has invalid name", tostring(key)))
		local previous = seen[name]
		assert(previous == nil, string.format("Protocol remote name %s is duplicated by %s and %s", name, tostring(previous), key))
		seen[name] = key
	end
end

local function validateProgression()
	local cap = GameConfig.Progression.SliceLevelCap
	assert(type(cap) == "number" and cap >= 2 and cap == math.floor(cap), "SliceLevelCap must be an integer >= 2")

	for level = 1, cap - 1 do
		local requirement = GameConfig.GetXPRequirement(level)
		assertFinitePositive(string.format("XP requirement L%d", level), requirement)
	end

	assertFinitePositive("DamagePerLevel", GameConfig.Progression.DamagePerLevel)
end

local function validateItemsAndWeapons()
	for itemId, item in pairs(GameConfig.Items) do
		assert(type(itemId) == "string" and #itemId > 0, "Item ID must be a non-empty string")
		assert(item.id == itemId, string.format("Item %s id field must match catalog key", itemId))
		assert(type(item.category) == "string", string.format("Item %s category missing", itemId))
		assert(type(item.equipSlot) == "string", string.format("Item %s equipSlot missing", itemId))
		assert(type(item.visualKey) == "string" and #item.visualKey > 0, string.format("Item %s visualKey missing", itemId))

		if item.category == "weapon" then
			assert(GameConfig.Weapons[itemId] ~= nil, string.format("Weapon item %s has no weapon config", itemId))
		end
	end

	for weaponId, weapon in pairs(GameConfig.Weapons) do
		assert(GameConfig.Items[weaponId] ~= nil, string.format("Weapon config %s has no item definition", weaponId))
		assertFinitePositive(string.format("%s baseDamage", weaponId), weapon.baseDamage)
		assertFinitePositive(string.format("%s cooldown", weaponId), weapon.cooldown)
		assertFinitePositive(string.format("%s windup", weaponId), weapon.windup)
		assertFinitePositive(string.format("%s comboReset", weaponId), weapon.comboReset)
		assert(typeof(weapon.hitboxSize) == "Vector3", string.format("%s hitboxSize must be Vector3", weaponId))
		assertFinitePositive(string.format("%s forwardOffset", weaponId), weapon.forwardOffset)
		assertFinitePositive(string.format("%s maxTargets", weaponId), weapon.maxTargets)
		assert(type(weapon.comboMultipliers) == "table" and #weapon.comboMultipliers >= 1, string.format("%s comboMultipliers must not be empty", weaponId))

		for index, multiplier in ipairs(weapon.comboMultipliers) do
			assertFinitePositive(string.format("%s combo multiplier %d", weaponId, index), multiplier)
		end

		local skill = weapon.skill
		assert(type(skill) == "table", string.format("%s skill config missing", weaponId))
		assertFinitePositive(string.format("%s skill cooldown", weaponId), skill.cooldown)
		assertFinitePositive(string.format("%s skill windup", weaponId), skill.windup)
		assertFinitePositive(string.format("%s skill damageMultiplier", weaponId), skill.damageMultiplier)
		assert(typeof(skill.hitboxSize) == "Vector3", string.format("%s skill hitboxSize must be Vector3", weaponId))
		assertFinitePositive(string.format("%s skill forwardOffset", weaponId), skill.forwardOffset)
		assertFinitePositive(string.format("%s skill maxTargets", weaponId), skill.maxTargets)
	end
end

local function validateEnemiesAndLoot()
	local requiredClearFlagFound = false

	for enemyId, enemy in pairs(GameConfig.Enemies) do
		assert(type(enemyId) == "string" and #enemyId > 0, "Enemy ID must be a non-empty string")
		assertFinitePositive(string.format("%s maxHealth", enemyId), enemy.maxHealth)
		assertFinitePositive(string.format("%s moveSpeed", enemyId), enemy.moveSpeed)
		assertFinitePositive(string.format("%s aggroRange", enemyId), enemy.aggroRange)
		assertFinitePositive(string.format("%s attackRange", enemyId), enemy.attackRange)
		assertFinitePositive(string.format("%s attackWindup", enemyId), enemy.attackWindup)
		assertFinitePositive(string.format("%s attackCooldown", enemyId), enemy.attackCooldown)
		assertFinitePositive(string.format("%s damage", enemyId), enemy.damage)
		assertFinitePositive(string.format("%s xpReward", enemyId), enemy.xpReward)
		assertFinitePositive(string.format("%s goldReward", enemyId), enemy.goldReward)
		assertFinitePositive(string.format("%s respawnTime", enemyId), enemy.respawnTime)
		assert(type(enemy.lootTable) == "string", string.format("%s lootTable missing", enemyId))
		assert(GameConfig.LootTables[enemy.lootTable] ~= nil, string.format("%s references missing loot table %s", enemyId, tostring(enemy.lootTable)))

		if enemy.clearFlag == GameConfig.Rebirth.RequiredClearFlag then
			requiredClearFlagFound = true
		end
	end

	assert(requiredClearFlagFound, string.format("No enemy produces required Rebirth clear flag %s", GameConfig.Rebirth.RequiredClearFlag))

	for lootTableId, lootTable in pairs(GameConfig.LootTables) do
		assert(type(lootTable) == "table", string.format("Loot table %s must be a table", tostring(lootTableId)))
		for index, entry in ipairs(lootTable) do
			assert(type(entry.itemId) == "string", string.format("Loot table %s entry %d itemId missing", tostring(lootTableId), index))
			assert(GameConfig.Items[entry.itemId] ~= nil, string.format("Loot table %s references unknown item %s", tostring(lootTableId), tostring(entry.itemId)))
			assert(type(entry.chance) == "number" and entry.chance >= 0 and entry.chance <= 1, string.format("Loot table %s entry %d chance must be 0..1", tostring(lootTableId), index))
		end
	end
end

local function validateRebirth()
	assert(type(GameConfig.Rebirth.RequiredClearFlag) == "string" and #GameConfig.Rebirth.RequiredClearFlag > 0, "Rebirth RequiredClearFlag missing")
	assertFinitePositive("Rebirth SliceRequiredLevel", GameConfig.Rebirth.SliceRequiredLevel)
	assertFinitePositive("Rebirth XP multiplier step", GameConfig.Rebirth.XPMultiplierPerRebirth)
	assertFinitePositive("Rebirth Gold multiplier step", GameConfig.Rebirth.GoldMultiplierPerRebirth)
	assertFinitePositive("Rebirth Luck step", GameConfig.Rebirth.LuckPerRebirth)
	assertFinitePositive("Rebirth Luck cap", GameConfig.Rebirth.LuckCap)
	assertFinitePositive("Rebirth StartPower step", GameConfig.Rebirth.StartPowerPerRebirth)

	for threshold, flag in pairs(GameConfig.Rebirth.Milestones) do
		assert(type(threshold) == "number" and threshold >= 1 and threshold == math.floor(threshold), "Rebirth milestone threshold must be positive integer")
		assert(type(flag) == "string" and #flag > 0, "Rebirth milestone flag must be a non-empty string")
	end
end

function ConfigValidator.Validate(protocol: any)
	validateProtocol(protocol)
	validateProgression()
	validateItemsAndWeapons()
	validateEnemiesAndLoot()
	validateRebirth()
end

return ConfigValidator
