local Config = require(script.Parent.Config)
local Shared = require(script.Parent.Shared)
local PlayerState = require(script.Parent.PlayerState)
local EnemyService = require(script.Parent.EnemyService)
local LootService = require(script.Parent.LootService)

local RunService = {}
RunService.onState = function() end
RunService.onEvent = function() end

local gates = {}
local rooms = {}
local chest
local lastCheck = 0

local function gateColor(closed)
	return closed and Color3.fromRGB(255,96,72) or Color3.fromRGB(120,200,255)
end

local function setGate(g, closed)
	if not g then return end
	g.CanCollide = closed
	g.Transparency = closed and 0.42 or 1
	g.Material = closed and Enum.Material.ForceField or Enum.Material.SmoothPlastic
	g.Color = gateColor(closed)
end

local function buildGates()
	local root = workspace.SlayAndLoot
	local folder = root:FindFirstChild("Gates")
	if not folder then folder = Instance.new("Folder"); folder.Name = "Gates"; folder.Parent = root end
	folder:ClearAllChildren()
	gates = {}
	for _, r in ipairs(Config.Rooms) do
		for _, spec in ipairs({
			{ key = "in", anchor = r.gateIn, axis = r.gateInAxis, w = r.gateInW, h = r.gateInH },
			{ key = "out", anchor = r.gateOut, axis = r.gateOutAxis, w = r.gateOutW, h = r.gateOutH },
		}) do
			local p = Shared.anchorXZ(spec.anchor)
			if p then
				local size = spec.axis == "Z" and Vector3.new(spec.w, spec.h, 1.2) or Vector3.new(1.2, spec.h, spec.w)
				local g = Instance.new("Part")
				g.Name = "Gate_" .. r.id .. "_" .. spec.key
				g.Size = size
				g.CFrame = CFrame.new(p.X, spec.h / 2, p.Z)
				g.Anchored = true
				g.CanCollide = false
				g.Transparency = 1
				g.Material = Enum.Material.SmoothPlastic
				g.Parent = folder
				gates[r.id .. spec.key] = g
				setGate(g, false)
			end
		end
	end
end

local function buildChest()
	local root = workspace.SlayAndLoot
	local folder = root:FindFirstChild("Reward")
	if not folder then folder = Instance.new("Folder"); folder.Name = "Reward"; folder.Parent = root end
	folder:ClearAllChildren()
	local p = Shared.anchorXZ("Reward_Chest")
	if not p then return end
	local base = Instance.new("Part")
	base.Name = "ChestBase"; base.Size = Vector3.new(5, 3, 3.6)
	base.CFrame = CFrame.new(p.X, 1.5, p.Z)
	base.Anchored = true; base.Material = Enum.Material.WoodPlanks
	base.Color = Color3.fromRGB(96,66,40); base.Parent = folder
	local lid = Instance.new("Part")
	lid.Name = "ChestLid"; lid.Size = Vector3.new(5.4, 1, 3.9)
	lid.CFrame = CFrame.new(p.X, 3.4, p.Z)
	lid.Anchored = true; lid.Material = Enum.Material.WoodPlanks
	lid.Color = Color3.fromRGB(120,84,50); lid.Parent = folder
	local glow = Instance.new("PointLight")
	glow.Brightness = 0; glow.Range = 16; glow.Color = Color3.fromRGB(255,200,110)
	glow.Parent = lid
	local bill = Instance.new("BillboardGui")
	bill.Name = "ChestPrompt"; bill.Size = UDim2.fromOffset(200, 40)
	bill.StudsOffset = Vector3.new(0, 4.2, 0); bill.MaxDistance = 90
	bill.Enabled = false; bill.Parent = lid
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold; label.TextSize = 18
	label.TextColor3 = Color3.fromRGB(255,214,140); label.Text = "CLAIM REWARD"
	label.Parent = bill
	chest = { base = base, lid = lid, glow = glow, prompt = bill }
end

local function resetRoomStates()
	rooms = {}
	for i, r in ipairs(Config.Rooms) do
		rooms[i] = { cfg = r, spawned = false, cleared = false }
	end
end

local function setChestActive(on)
	if not chest then return end
	chest.glow.Brightness = on and 2.2 or 0
	chest.prompt.Enabled = on
end

function RunService.setup()
	buildGates()
	buildChest()
	resetRoomStates()
end

local function closeAllGates()
	for _, g in pairs(gates) do setGate(g, true) end
end

local function openRoomGates(id)
	setGate(gates[id .. "in"], false)
	setGate(gates[id .. "out"], false)
end

function RunService.start(player, difficulty)
	local st = PlayerState.get(player)
	difficulty = Config.Difficulty[difficulty] and difficulty or "Normal"
	EnemyService.clear()
	resetRoomStates()
	setChestActive(false)
	st.difficulty = difficulty
	st.runState = "active"
	st.roomIndex = 0
	st.pendingLoot = nil
	st.lootTaken = false
	st.comboIndex = 0
	st.lastAttack = 0
	st.lastSkill = 0
	st.lastDash = 0
	closeAllGates()
	-- gates ahead of the player stay open until the encounter starts
	for _, r in ipairs(Config.Rooms) do openRoomGates(r.id) end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local startPos = Shared.anchorXZ("RunStart") or Shared.anchorXZ("RoomA_Entry")
	if hrp and startPos then
		char:PivotTo(CFrame.new(startPos.X, 4, startPos.Z))
	end
	local h = char and char:FindFirstChildOfClass("Humanoid")
	if h then h.Health = h.MaxHealth end
	RunService.onState(player)
	RunService.onEvent(player, "runStart", { difficulty = difficulty })
end

function RunService.abort(player)
	local st = PlayerState.get(player)
	EnemyService.clear()
	resetRoomStates()
	setChestActive(false)
	st.runState = "idle"
	st.pendingLoot = nil
	st.roomIndex = 0
	for _, r in ipairs(Config.Rooms) do openRoomGates(r.id) end
	RunService.onState(player)
end

function RunService.returnToHub(player)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local p = Shared.anchorXZ("HubCenter")
	if hrp and p then char:PivotTo(CFrame.new(p.X, 4, p.Z)) end
end

local function grantRoomClear(player, roomState)
	local st = PlayerState.get(player)
	local diff = Config.Difficulty[st.difficulty] or Config.Difficulty.Normal
	local gold, xp = 0, 0
	for _, s in ipairs(roomState.cfg.spawns) do
		local ec = Config.Enemy[s.kind]
		if ec then gold += ec.gold * diff.gold; xp += ec.xp * diff.xp end
	end
	local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if h and h.Health > 0 then
		h.Health = math.min(h.MaxHealth, h.Health + h.MaxHealth * 0.45)
	end
	st.gold += math.floor(gold)
	st.xp += math.floor(xp)
	st.level = 1 + math.floor(st.xp / 100)
	RunService.onEvent(player, "roomClear", { room = roomState.cfg.id, label = roomState.cfg.label })
	RunService.onState(player)
end

function RunService.update(dt, players)
	if os.clock() - lastCheck < 0.15 then return end
	lastCheck = os.clock()
	for _, player in ipairs(players) do
		local st = PlayerState.get(player)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos = Shared.flat(hrp.Position)
			if st.runState == "active" then
				for i, rs in ipairs(rooms) do
					local center = Shared.anchorXZ(rs.cfg.center)
					if center then
						local d = (pos - center).Magnitude
						if not rs.spawned and d <= rs.cfg.radius then
							rs.spawned = true
							setGate(gates[rs.cfg.id .. "in"], true)
							setGate(gates[rs.cfg.id .. "out"], true)
							for _, s in ipairs(rs.cfg.spawns) do
								EnemyService.spawn(s.kind, center + s.off, rs.cfg.id,
									Config.Difficulty[st.difficulty] or Config.Difficulty.Normal, rs.cfg.center)
							end
							RunService.onEvent(player, "encounter", { room = rs.cfg.id, label = rs.cfg.label })
							RunService.onState(player)
						elseif rs.spawned and not rs.cleared and EnemyService.aliveInRoom(rs.cfg.id) == 0 then
							rs.cleared = true
							openRoomGates(rs.cfg.id)
							grantRoomClear(player, rs)
							if rs.cfg.id == "Boss" then
								st.runState = "cleared"
								if st.difficulty == "Normal" then st.hasClearedNormal = true end
								setChestActive(true)
								RunService.onEvent(player, "bossDown", {})
								RunService.onState(player)
							else
								st.roomIndex = i
							end
						end
					end
				end
			end
			-- reward chest: boss sets runState = "cleared", so this must sit outside the active branch
			if st.runState == "cleared" and not st.pendingLoot and not st.lootTaken and chest then
				local d = (pos - Shared.flat(chest.base.Position)).Magnitude
				if d < 7 then
					local diff = Config.Difficulty[st.difficulty] or Config.Difficulty.Normal
					st.pendingLoot = LootService.roll(diff.tier)
					setChestActive(false)
					RunService.onEvent(player, "loot", { item = st.pendingLoot })
					RunService.onState(player)
				end
			end
		end
	end
end

return RunService
