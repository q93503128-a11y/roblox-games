--!strict

local GameConfig = require(script.Parent.GameConfig)

local ProfileService = {}

local profiles: { [Player]: any } = {}
local stateEvent: RemoteEvent? = nil

local function deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, child in pairs(value) do
		copy[deepCopy(key)] = deepCopy(child)
	end
	return copy
end

local function createDefaultProfile()
	return {
		schemaVersion = GameConfig.SchemaVersion,
		progression = {
			level = 1,
			xp = 0,
			gold = 0,
			rebirths = 0,
			milestoneFlags = {},
			regionProgress = {},
		},
		inventory = {
			items = {
				weapon_start_a = 1,
			},
			equipped = {
				mainhand = "weapon_start_a",
			},
		},
	}
end

local function emit(player: Player)
	if stateEvent == nil then
		return
	end

	local profile = profiles[player]
	if profile ~= nil then
		stateEvent:FireClient(player, deepCopy(profile))
	end
end

function ProfileService.Init(remote: RemoteEvent)
	stateEvent = remote
end

function ProfileService.Create(player: Player)
	if profiles[player] ~= nil then
		return profiles[player]
	end

	local profile = createDefaultProfile()
	profiles[player] = profile
	emit(player)
	return profile
end

function ProfileService.Remove(player: Player)
	profiles[player] = nil
end

function ProfileService.Get(player: Player)
	return profiles[player]
end

function ProfileService.GetSnapshot(player: Player)
	local profile = profiles[player]
	if profile == nil then
		return nil
	end
	return deepCopy(profile)
end

function ProfileService.Push(player: Player)
	emit(player)
end

function ProfileService.AddXP(player: Player, baseAmount: number): number
	local profile = profiles[player]
	if profile == nil or baseAmount <= 0 then
		return 0
	end

	local modifiers = GameConfig.GetRebirthModifiers(profile.progression.rebirths)
	local amount = math.max(1, math.floor(baseAmount * modifiers.xp + 0.5))
	profile.progression.xp += amount

	while profile.progression.level < GameConfig.Progression.SliceLevelCap do
		local required = GameConfig.GetXPRequirement(profile.progression.level)
		if required == nil or profile.progression.xp < required then
			break
		end

		profile.progression.xp -= required
		profile.progression.level += 1
	end

	if profile.progression.level >= GameConfig.Progression.SliceLevelCap then
		profile.progression.xp = 0
	end

	emit(player)
	return amount
end

function ProfileService.AddGold(player: Player, baseAmount: number): number
	local profile = profiles[player]
	if profile == nil or baseAmount <= 0 then
		return 0
	end

	local modifiers = GameConfig.GetRebirthModifiers(profile.progression.rebirths)
	local amount = math.max(1, math.floor(baseAmount * modifiers.gold + 0.5))
	profile.progression.gold += amount
	emit(player)
	return amount
end

function ProfileService.OwnsItem(player: Player, itemId: string): boolean
	local profile = profiles[player]
	if profile == nil then
		return false
	end

	return (profile.inventory.items[itemId] or 0) > 0
end

function ProfileService.AddItem(player: Player, itemId: string, quantity: number?): boolean
	local profile = profiles[player]
	local itemDefinition = GameConfig.Items[itemId]
	if profile == nil or itemDefinition == nil then
		return false
	end

	local addQuantity = math.max(1, math.floor(quantity or 1))
	profile.inventory.items[itemId] = (profile.inventory.items[itemId] or 0) + addQuantity
	emit(player)
	return true
end

function ProfileService.EquipItem(player: Player, itemId: string): (boolean, string?)
	local profile = profiles[player]
	local itemDefinition = GameConfig.Items[itemId]
	if profile == nil then
		return false, "profile_missing"
	end
	if itemDefinition == nil then
		return false, "unknown_item"
	end
	if not ProfileService.OwnsItem(player, itemId) then
		return false, "not_owned"
	end
	if itemDefinition.equipSlot ~= "mainhand" then
		return false, "unsupported_slot"
	end

	profile.inventory.equipped.mainhand = itemId
	emit(player)
	return true, nil
end

function ProfileService.SetRegionFlag(player: Player, flag: string, enabled: boolean)
	local profile = profiles[player]
	if profile == nil then
		return
	end

	profile.progression.regionProgress[flag] = enabled
	emit(player)
end

function ProfileService.HasRegionFlag(player: Player, flag: string): boolean
	local profile = profiles[player]
	if profile == nil then
		return false
	end

	return profile.progression.regionProgress[flag] == true
end

function ProfileService.CanRebirth(player: Player): (boolean, string?)
	local profile = profiles[player]
	if profile == nil then
		return false, "profile_missing"
	end
	if profile.progression.level < GameConfig.Rebirth.SliceRequiredLevel then
		return false, "level_requirement"
	end
	if not ProfileService.HasRegionFlag(player, GameConfig.Rebirth.RequiredClearFlag) then
		return false, "boss_requirement"
	end

	return true, nil
end

function ProfileService.PerformRebirth(player: Player): (boolean, string?)
	local canRebirth, reason = ProfileService.CanRebirth(player)
	if not canRebirth then
		return false, reason
	end

	local profile = profiles[player]
	if profile == nil then
		return false, "profile_missing"
	end

	profile.progression.rebirths += 1
	profile.progression.level = 1
	profile.progression.xp = 0
	profile.progression.gold = 0
	profile.progression.regionProgress = {}

	-- Equipment retention is intentionally provisional for Slice 001.
	-- We preserve owned equipment until Studio tests establish a clear reset/conversion rule.
	for threshold, flag in pairs(GameConfig.Rebirth.Milestones) do
		if profile.progression.rebirths >= threshold then
			profile.progression.milestoneFlags[flag] = true
		end
	end

	emit(player)
	return true, nil
end

function ProfileService.GetDamageMultiplier(player: Player): number
	local profile = profiles[player]
	if profile == nil then
		return 1
	end
	return GameConfig.GetDamageMultiplier(profile.progression.level, profile.progression.rebirths)
end

function ProfileService.GetLuckBonus(player: Player): number
	local profile = profiles[player]
	if profile == nil then
		return 0
	end
	return GameConfig.GetRebirthModifiers(profile.progression.rebirths).luck
end

return ProfileService
