local Config = require(script.Parent.Config)
local Shared = require(script.Parent.Shared)
local PlayerState = require(script.Parent.PlayerState)
local EnemyService = require(script.Parent.EnemyService)

local CombatService = {}
CombatService.onEvent = function() end

local function root(player)
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function hum(player)
	local c = player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function flat(v) return Vector3.new(v.X, 0, v.Z) end

function CombatService.attack(player)
	local st = PlayerState.get(player)
	local hrp, h = root(player), hum(player)
	if not hrp or not h or h.Health <= 0 then return end
	if st.runState ~= "active" then return end
	local now = os.clock()
	st.comboIndex = (st.comboIndex % 3) + 1
	local combo = Config.Combo[st.comboIndex]
	if now - st.lastAttack < combo.cd then
		st.comboIndex = math.max(1, st.comboIndex - 1)
		return
	end
	st.lastAttack = now
	local origin = flat(hrp.Position)
	local look = flat(hrp.CFrame.LookVector)
	if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
	look = look.Unit
	local dmg = PlayerState.totalDamage(st) * combo.mul
	local idx = st.comboIndex
	CombatService.onEvent("swing", player, { index = idx })
	task.delay(combo.hitAt, function()
		local hits = EnemyService.hitArea(origin, look, combo.range, combo.arc, dmg)
		if hits > 0 then
			CombatService.onEvent("connect", player, { index = idx, hits = hits })
		end
	end)
end

function CombatService.dash(player)
	local st = PlayerState.get(player)
	local hrp, h = root(player), hum(player)
	if not hrp or not h or h.Health <= 0 then return end
	if st.runState ~= "active" then return end
	local now = os.clock()
	if now - st.lastDash < Config.Dash.cd then return end
	st.lastDash = now
	st.invulnUntil = now + Config.Dash.invuln
	local look = flat(hrp.CFrame.LookVector)
	if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
	look = look.Unit
	local speed = Config.Dash.distance / Config.Dash.duration
	hrp.AssemblyLinearVelocity = look * speed + Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
	CombatService.onEvent("dash", player, {})
end

function CombatService.skill(player)
	local st = PlayerState.get(player)
	local hrp, h = root(player), hum(player)
	if not hrp or not h or h.Health <= 0 then return end
	if st.runState ~= "active" then return end
	local now = os.clock()
	if now - st.lastSkill < Config.Skill.cd then return end
	st.lastSkill = now
	local origin = flat(hrp.Position)
	local look = flat(hrp.CFrame.LookVector)
	if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
	local dmg = PlayerState.totalDamage(st) * Config.Skill.mul
	CombatService.onEvent("skill", player, {})
	task.delay(Config.Skill.hitAt, function()
		local hits = EnemyService.hitArea(origin, look.Unit, Config.Skill.range, 360, dmg)
		if hits > 0 then CombatService.onEvent("connect", player, { index = 4, hits = hits }) end
	end)
end

function CombatService.applyPlayerDamage(player, raw)
	local st = PlayerState.get(player)
	local h = hum(player)
	if not h or h.Health <= 0 then return end
	local now = os.clock()
	if now < st.invulnUntil then return end
	st.invulnUntil = now + 0.45
	local diff = Config.Difficulty[st.difficulty] or Config.Difficulty.Normal
	local amount = raw * diff.dmg
	h.Health = math.max(0, h.Health - amount)
	CombatService.onEvent("playerHurt", player, { amount = math.floor(amount) })
end

function CombatService.heal(player)
	local h = hum(player)
	if h then h.Health = h.MaxHealth end
end

return CombatService
