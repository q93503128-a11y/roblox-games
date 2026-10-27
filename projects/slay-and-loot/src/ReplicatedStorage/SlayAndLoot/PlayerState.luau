local Config = require(script.Parent.Config)

local PlayerState = {}
local states = {}

function PlayerState.get(player)
	local st = states[player]
	if not st then
		st = {
			gold = 0, xp = 0, level = 1,
			inventory = {}, equipped = nil,
			runState = "idle", difficulty = "Normal",
			roomIndex = 0, roomsCleared = {},
			pendingLoot = nil, hasClearedNormal = false, lootTaken = false,
			lastAttack = 0, comboIndex = 0,
			lastDash = 0, lastSkill = 0,
			invulnUntil = 0, dashUntil = 0,
		}
		states[player] = st
	end
	return st
end

function PlayerState.remove(player)
	states[player] = nil
end

function PlayerState.totalDamage(st)
	local bonus = st.equipped and st.equipped.dmg or 0
	return Config.Player.baseDamage + bonus
end

function PlayerState.addItem(st, item)
	for _, it in ipairs(st.inventory) do
		if it.id == item.id then
			if item.dmg > it.dmg then it.dmg = item.dmg end
			return false
		end
	end
	table.insert(st.inventory, item)
	return true
end

function PlayerState.equip(st, id)
	for _, it in ipairs(st.inventory) do
		if it.id == id then
			st.equipped = it
			return true
		end
	end
	return false
end

function PlayerState.snapshot(player)
	local st = PlayerState.get(player)
	local inv = {}
	for _, it in ipairs(st.inventory) do
		table.insert(inv, { id = it.id, name = it.name, rarity = it.rarity, dmg = it.dmg })
	end
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return {
		gold = st.gold, xp = st.xp, level = st.level,
		hp = hum and hum.Health or 0,
		maxHp = hum and hum.MaxHealth or Config.Player.maxHP,
		inventory = inv,
		equipped = st.equipped and st.equipped.id or nil,
		damage = PlayerState.totalDamage(st),
		runState = st.runState,
		difficulty = st.difficulty,
		roomIndex = st.roomIndex,
		pendingLoot = st.pendingLoot,
		hasClearedNormal = st.hasClearedNormal,
		skillCd = math.max(0, Config.Skill.cd - (os.clock() - st.lastSkill)),
		dashCd = math.max(0, Config.Dash.cd - (os.clock() - st.lastDash)),
	}
end

return PlayerState
