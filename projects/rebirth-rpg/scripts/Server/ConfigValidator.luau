--!strict

local GameConfig = require(script.Parent.GameConfig)

local ConfigValidator = {}

local function assertFinite(label: string, value: any)
	assert(type(value) == "number", string.format("%s must be a number", label))
	assert(value == value and value ~= math.huge and value ~= -math.huge, string.format("%s must be finite", label))
end

local function assertFinitePositive(label: string, value: any)
	assertFinite(label, value)
	assert(value > 0, string.format("%s must be > 0", label))
end

local function assertPositiveInteger(label: string, value: any)
	assertFinitePositive(label, value)
	assert(value == math.floor(value), string.format("%s must be an integer", label))
end

local function assertPositiveVector3(label: string, value: any)
	assert(typeof(value) == "Vector3", string.format("%s must be Vector3", label))
	assertFinitePositive(label .. ".X", value.X)
	assertFinitePositive(label .. ".Y", value.Y)
	assertFinitePositive(label .. ".Z", value.Z)
end

local function validateNamedStringTable(label: string, values: any)
	assert(type(values) == "table", string.format("%s must be a table", label))
	local seen: { [string]: string } = {}
	for key, name in pairs(values) do
		assert(type(key) == "string", string.format("%s key must be a string", label))
		assert(type(name) == "string" and #name > 0, string.format("%s.%s has invalid name", label, tostring(key)))
		local previous = seen[name]
		assert(previous == nil, string.format("%s name %s is duplicated by %s and %s", label, name, tostring(previous), key))
		seen[name] = key
	end
end

local function validateProtocol(protocol: any)
	assert(type(protocol) == "table", "Protocol must be a table")
	validateNamedStringTable("Protocol.Remotes", protocol.Remotes)
	validateNamedStringTable("Protocol.Tags", protocol.Tags)
	validateNamedStringTable("Protocol.Attributes", protocol.Attributes)
end

local function validateProgression()
	assertPositiveInteger("SchemaVersion", GameConfig.SchemaVersion)

	local cap = GameConfig.Progression.SliceLevelCap
	assertPositiveInteger("SliceLevelCap", cap)
	assert(cap >= 2, "SliceLevelCap must be >= 2")

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
		assert(type(item.category) == "string" and #item.category > 0, string.format("Item %s category missing", itemId))
		assert(type(item.equipSlot) == "string" and #item.equipSlot > 0, string.format("Item %s equipSlot missing", itemId))
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
		assertPositiveVector3(string.format("%s hitboxSize", weaponId), weapon.hitboxSize)
		assertFinitePositive(string.format("%s forwardOffset", weaponId), weapon.forwardOffset)
		assertPositiveInteger(string.format("%s maxTargets", weaponId), weapon.maxTargets)
		assert(type(weapon.comboMultipliers) == "table" and #weapon.comboMultipliers >= 1, string.format("%s comboMultipliers must not be empty", weaponId))

		for index, multiplier in ipairs(weapon.comboMultipliers) do
			assertFinitePositive(string.format("%s combo multiplier %d", weaponId, index), multiplier)
		end

		local skill = weapon.skill
		assert(type(skill) == "table", string.format("%s skill config missing", weaponId))
		assertFinitePositive(string.format("%s skill cooldown", weaponId), skill.cooldown)
		assertFinitePositive(string.format("%s skill windup", weaponId), skill.windup)
		assertFinitePositive(string.format("%s skill damageMultiplier", weaponId), skill.damageMultiplier)
		assertPositiveVector3(string.format("%s skill hitboxSize", weaponId), skill.hitboxSize)
		assertFinitePositive(string.format("%s skill forwardOffset", weaponId), skill.forwardOffset)
		assertPositiveInteger(string.format("%s skill maxTargets", weaponId), skill.maxTargets)
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
		assert(enemy.aggroRange >= enemy.attackRange, string.format("%s aggroRange must be >= attackRange", enemyId))
		assertFinitePositive(string.format("%s attackWindup", enemyId), enemy.attackWindup)
		assertFinitePositive(string.format("%s attackCooldown", enemyId), enemy.attackCooldown)
		assertFinitePositive(string.format("%s damage", enemyId), enemy.damage)
		assertFinitePositive(string.format("%s xpReward", enemyId), enemy.xpReward)
		assertFinitePositive(string.format("%s goldReward", enemyId), enemy.goldReward)
		assertFinitePositive(string.format("%s respawnTime", enemyId), enemy.respawnTime)
		assert(type(enemy.lootTable) == "string" and #enemy.lootTable > 0, string.format("%s lootTable missing", enemyId))
		assert(GameConfig.LootTables[enemy.lootTable] ~= nil, string.format("%s references missing loot table %s", enemyId, tostring(enemy.lootTable)))

		if enemy.clearFlag == GameConfig.Rebirth.RequiredClearFlag then
			requiredClearFlagFound = true
		end
	end

	assert(requiredClearFlagFound, string.format("No enemy produces required Rebirth clear flag %s", GameConfig.Rebirth.RequiredClearFlag))

	for lootTableId, lootTable in pairs(GameConfig.LootTables) do
		assert(type(lootTableId) == "string" and #lootTableId > 0, "Loot table ID must be a non-empty string")
		assert(type(lootTable) == "table", string.format("Loot table %s must be a table", tostring(lootTableId)))
		for index, entry in ipairs(lootTable) do
			assert(type(entry.itemId) == "string", string.format("Loot table %s entry %d itemId missing", tostring(lootTableId), index))
			assert(GameConfig.Items[entry.itemId] ~= nil, string.format("Loot table %s references unknown item %s", tostring(lootTableId), tostring(entry.itemId)))
			assert(type(entry.chance) == "number" and entry.chance == entry.chance and entry.chance >= 0 and entry.chance <= 1, string.format("Loot table %s entry %d chance must be finite 0..1", tostring(lootTableId), index))
		end
	end
end

local function validateRebirth()
	assert(type(GameConfig.Rebirth.RequiredClearFlag) == "string" and #GameConfig.Rebirth.RequiredClearFlag > 0, "Rebirth RequiredClearFlag missing")
	assertPositiveInteger("Rebirth SliceRequiredLevel", GameConfig.Rebirth.SliceRequiredLevel)
	assert(GameConfig.Rebirth.SliceRequiredLevel <= GameConfig.Progression.SliceLevelCap, "Rebirth SliceRequiredLevel cannot exceed SliceLevelCap")
	assertFinitePositive("Rebirth XP multiplier step", GameConfig.Rebirth.XPMultiplierPerRebirth)
	assertFinitePositive("Rebirth Gold multiplier step", GameConfig.Rebirth.GoldMultiplierPerRebirth)
	assertFinitePositive("Rebirth Luck step", GameConfig.Rebirth.LuckPerRebirth)
	assertFinitePositive("Rebirth Luck cap", GameConfig.Rebirth.LuckCap)
	assert(GameConfig.Rebirth.LuckCap >= GameConfig.Rebirth.LuckPerRebirth, "Rebirth Luck cap must be >= one Rebirth Luck step")
	assertFinitePositive("Rebirth StartPower step", GameConfig.Rebirth.StartPowerPerRebirth)

	local seenFlags: { [string]: number } = {}
	for threshold, flag in pairs(GameConfig.Rebirth.Milestones) do
		assertPositiveInteger("Rebirth milestone threshold", threshold)
		assert(type(flag) == "string" and #flag > 0, "Rebirth milestone flag must be a non-empty string")
		local previousThreshold = seenFlags[flag]
		assert(previousThreshold == nil, string.format("Rebirth milestone flag %s is duplicated at %s and %s", flag, tostring(previousThreshold), tostring(threshold)))
		seenFlags[flag] = threshold
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
