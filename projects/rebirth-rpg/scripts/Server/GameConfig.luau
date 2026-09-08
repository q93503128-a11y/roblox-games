--!strict

-- First playable-slice tuning. Values are deliberately small and easy to edit after Studio TTK measurements.
-- Visual identities remain abstract until Studio asset approval.

local GameConfig = {}

GameConfig.SchemaVersion = 1

GameConfig.Progression = table.freeze({
	SliceLevelCap = 10,
	XPToNextLevel = table.freeze({
		[1] = 30,
		[2] = 45,
		[3] = 65,
		[4] = 90,
		[5] = 120,
		[6] = 155,
		[7] = 195,
		[8] = 240,
		[9] = 290,
	}),
	DamagePerLevel = 0.05,
})

GameConfig.Rebirth = table.freeze({
	SliceRequiredLevel = 10,
	RequiredClearFlag = "boss_region_01_cleared",
	XPMultiplierPerRebirth = 0.40,
	GoldMultiplierPerRebirth = 0.25,
	LuckPerRebirth = 0.02,
	LuckCap = 0.20,
	StartPowerPerRebirth = 0.10,
	Milestones = table.freeze({
		[1] = "unlock_dungeon",
		[2] = "unlock_forge",
		[3] = "unlock_world_02",
		[5] = "unlock_raid",
		[7] = "unlock_high_rarity",
		[10] = "unlock_permanent_layer_02",
	}),
})

GameConfig.Items = table.freeze({
	weapon_start_a = table.freeze({
		id = "weapon_start_a",
		category = "weapon",
		equipSlot = "mainhand",
		visualKey = "weapon_start_a",
		prototypeLabel = "Weapon A",
		unique = true,
	}),
	weapon_start_b = table.freeze({
		id = "weapon_start_b",
		category = "weapon",
		equipSlot = "mainhand",
		visualKey = "weapon_start_b",
		prototypeLabel = "Weapon B",
		unique = true,
	}),
})

GameConfig.Weapons = table.freeze({
	weapon_start_a = table.freeze({
		baseDamage = 10,
		cooldown = 0.48,
		windup = 0.08,
		comboReset = 1.05,
		comboMultipliers = table.freeze({ 1.00, 1.00, 1.28 }),
		hitboxSize = Vector3.new(7, 6, 8),
		forwardOffset = 4,
		maxTargets = 4,
		skill = table.freeze({
			cooldown = 4.5,
			windup = 0.22,
			damageMultiplier = 1.85,
			hitboxSize = Vector3.new(11, 7, 12),
			forwardOffset = 4,
			maxTargets = 6,
		}),
	}),
	weapon_start_b = table.freeze({
		baseDamage = 21,
		cooldown = 0.78,
		windup = 0.13,
		comboReset = 1.35,
		comboMultipliers = table.freeze({ 1.00, 1.08, 1.38 }),
		hitboxSize = Vector3.new(8, 7, 11),
		forwardOffset = 5,
		maxTargets = 3,
		skill = table.freeze({
			cooldown = 5.5,
			windup = 0.34,
			damageMultiplier = 2.10,
			hitboxSize = Vector3.new(12, 8, 14),
			forwardOffset = 5,
			maxTargets = 5,
		}),
	}),
})

GameConfig.Enemies = table.freeze({
	enemy_field_a_01 = table.freeze({
		maxHealth = 38,
		moveSpeed = 10,
		aggroRange = 48,
		attackRange = 4.5,
		attackWindup = 0.35,
		attackCooldown = 1.25,
		damage = 6,
		xpReward = 16,
		goldReward = 6,
		lootTable = "field_a",
		respawnTime = 3.5,
	}),
	enemy_field_b_01 = table.freeze({
		maxHealth = 72,
		moveSpeed = 9,
		aggroRange = 52,
		attackRange = 5,
		attackWindup = 0.45,
		attackCooldown = 1.45,
		damage = 9,
		xpReward = 30,
		goldReward = 11,
		lootTable = "field_b",
		respawnTime = 5,
	}),
	boss_region_01 = table.freeze({
		maxHealth = 340,
		moveSpeed = 8,
		aggroRange = 70,
		attackRange = 6,
		attackWindup = 0.65,
		attackCooldown = 1.55,
		damage = 14,
		xpReward = 145,
		goldReward = 75,
		lootTable = "boss_region_01",
		clearFlag = "boss_region_01_cleared",
		respawnTime = 18,
	}),
})

GameConfig.LootTables = table.freeze({
	field_a = table.freeze({}),
	field_b = table.freeze({
		table.freeze({ itemId = "weapon_start_b", chance = 1.00 }),
	}),
	boss_region_01 = table.freeze({
		table.freeze({ itemId = "weapon_start_b", chance = 1.00 }),
	}),
})

function GameConfig.GetXPRequirement(level: number): number?
	return GameConfig.Progression.XPToNextLevel[level]
end

function GameConfig.GetRebirthModifiers(rebirths: number)
	local rebirth = GameConfig.Rebirth
	return {
		xp = 1 + rebirth.XPMultiplierPerRebirth * rebirths,
		gold = 1 + rebirth.GoldMultiplierPerRebirth * rebirths,
		luck = math.min(rebirth.LuckPerRebirth * rebirths, rebirth.LuckCap),
		startPower = 1 + rebirth.StartPowerPerRebirth * rebirths,
	}
end

function GameConfig.GetDamageMultiplier(level: number, rebirths: number): number
	local levelMultiplier = 1 + GameConfig.Progression.DamagePerLevel * math.max(level - 1, 0)
	return levelMultiplier * GameConfig.GetRebirthModifiers(rebirths).startPower
end

return GameConfig
