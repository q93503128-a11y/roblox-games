--!strict

local Remotes = table.freeze({
	AttackIntent = "AttackIntent",
	EquipItem = "EquipItem",
	RequestRebirth = "RequestRebirth",
	StateUpdated = "StateUpdated",
	CombatFeedback = "CombatFeedback",
	GetState = "GetState",
})

local Tags = table.freeze({
	Enemy = "RebirthRPG_Enemy",
})

local Attributes = table.freeze({
	EnemyId = "EnemyId",
	RewardClaimed = "RewardClaimed",
	AttackState = "AttackState",
})

return table.freeze({
	Remotes = Remotes,
	Tags = Tags,
	Attributes = Attributes,
})
