local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunS = game:GetService("RunService")

local player = Players.LocalPlayer
local Config = require(RS.SlayAndLoot.Config)
local remotes = RS.SlayAndLoot.Remotes
local Request, StateSync, Feedback = remotes.Request, remotes.StateSync, remotes.Feedback

local ACCENT = Color3.fromRGB(224,177,90)
local PANEL = Color3.fromRGB(20,22,27)
local TEXT = Color3.fromRGB(238,240,245)
local MUTED = Color3.fromRGB(150,156,168)
local RED = Color3.fromRGB(214,74,64)
local GREEN = Color3.fromRGB(104,196,116)

local state = { gold = 0, xp = 0, level = 1, hp = 100, maxHp = 100, inventory = {}, equipped = nil,
	damage = 10, runState = "idle", difficulty = "Normal", roomIndex = 0, pendingLoot = nil,
	hasClearedNormal = false, skillCd = 0, dashCd = 0 }

local function font() return Enum.Font.GothamBold end
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local gui = Instance.new("ScreenGui")
gui.Name = "SlayAndLootHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- ============ HUD ============
local root = new("Frame", { Name = "Root", Size = UDim2.fromScale(1,1), BackgroundTransparency = 1 }, gui)

local topLeft = new("Frame", { Name = "TopLeft", Position = UDim2.fromOffset(24, 22),
	Size = UDim2.fromOffset(268, 78), BackgroundTransparency = 1 }, root)

new("TextLabel", { Name = "Level", Position = UDim2.fromOffset(0,0), Size = UDim2.fromOffset(120, 20),
	BackgroundTransparency = 1, Font = font(), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = ACCENT, Text = "LEVEL 1" }, topLeft)

local hpBg = new("Frame", { Name = "HpBg", Position = UDim2.fromOffset(0, 24), Size = UDim2.fromOffset(268, 16),
	BackgroundColor3 = Color3.fromRGB(12,13,16), BorderSizePixel = 0 }, topLeft)
new("UICorner", { CornerRadius = UDim.new(0, 3) }, hpBg)
local hpFill = new("Frame", { Name = "Fill", Size = UDim2.fromScale(1,1), BackgroundColor3 = RED, BorderSizePixel = 0 }, hpBg)
new("UICorner", { CornerRadius = UDim.new(0, 3) }, hpFill)
local hpText = new("TextLabel", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Font = font(),
	TextSize = 12, TextColor3 = Color3.fromRGB(255,255,255), Text = "100 / 100" }, hpBg)

local xpBg = new("Frame", { Name = "XpBg", Position = UDim2.fromOffset(0, 44), Size = UDim2.fromOffset(268, 6),
	BackgroundColor3 = Color3.fromRGB(12,13,16), BorderSizePixel = 0 }, topLeft)
local xpFill = new("Frame", { Size = UDim2.fromScale(0,1), BackgroundColor3 = Color3.fromRGB(88,150,224), BorderSizePixel = 0 }, xpBg)

local goldLabel = new("TextLabel", { Name = "Gold", Position = UDim2.fromOffset(0, 54), Size = UDim2.fromOffset(268, 20),
	BackgroundTransparency = 1, Font = font(), TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = ACCENT, Text = "0 GOLD" }, topLeft)

-- objective banner
local banner = new("Frame", { Name = "Banner", Position = UDim2.new(0.5, 0, 0, 26), AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromOffset(340, 34), BackgroundColor3 = PANEL, BackgroundTransparency = 0.25, Visible = false }, root)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, banner)
new("UIStroke", { Color = ACCENT, Transparency = 0.6, Thickness = 1 }, banner)
local bannerText = new("TextLabel", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Font = font(),
	TextSize = 15, TextColor3 = TEXT, Text = "" }, banner)

-- top right
local topRight = new("Frame", { Name = "TopRight", Position = UDim2.new(1, -24, 0, 22), AnchorPoint = Vector2.new(1, 0),
	Size = UDim2.fromOffset(210, 92), BackgroundTransparency = 1 }, root)
local diffBadge = new("TextLabel", { Position = UDim2.fromOffset(0,0), Size = UDim2.fromOffset(210, 22),
	BackgroundTransparency = 1, Font = font(), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right,
	TextColor3 = MUTED, Text = "NORMAL" }, topRight)

local function mkButton(parent, text, size, pos, color)
	local b = new("TextButton", { Size = size, Position = pos, BackgroundColor3 = color or PANEL,
		BackgroundTransparency = 0.1, Font = font(), TextSize = 15, TextColor3 = TEXT, Text = text,
		AutoButtonColor = true, BorderSizePixel = 0 }, parent)
	new("UICorner", { CornerRadius = UDim.new(0, 6) }, b)
	new("UIStroke", { Color = ACCENT, Transparency = 0.55, Thickness = 1 }, b)
	return b
end

local leaveBtn = mkButton(topRight, "LEAVE DUNGEON", UDim2.fromOffset(210, 28), UDim2.fromOffset(0, 58))
leaveBtn.Visible = false
local invBtn = mkButton(topRight, "INVENTORY  [TAB]", UDim2.fromOffset(210, 30), UDim2.fromOffset(0, 24))

-- ============ ability bar ============
local bar = new("Frame", { Name = "AbilityBar", Position = UDim2.new(0.5, 0, 1, -96), AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromOffset(384, 74), BackgroundTransparency = 1 }, root)

local function ability(key, label, pos)
	local f = new("Frame", { Size = UDim2.fromOffset(112, 74), Position = pos, BackgroundColor3 = PANEL,
		BackgroundTransparency = 0.1, BorderSizePixel = 0 }, bar)
	new("UICorner", { CornerRadius = UDim.new(0, 8) }, f)
	new("UIStroke", { Color = ACCENT, Transparency = 0.6, Thickness = 1 }, f)
	local b = new("TextButton", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "" }, f)
	new("TextLabel", { Position = UDim2.fromOffset(0, 12), Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
		Font = font(), TextSize = 17, TextColor3 = TEXT, Text = label }, f)
	new("TextLabel", { Position = UDim2.fromOffset(0, 42), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
		Font = font(), TextSize = 12, TextColor3 = MUTED, Text = key }, f)
	local cd = new("Frame", { Size = UDim2.fromScale(1, 0), Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 1), BackgroundColor3 = Color3.fromRGB(10,11,14),
		BackgroundTransparency = 0.35, BorderSizePixel = 0 }, f)
	new("UICorner", { CornerRadius = UDim.new(0, 8) }, cd)
	local cdText = new("TextLabel", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Font = font(),
		TextSize = 20, TextColor3 = TEXT, Text = "" }, f)
	return b, cd, cdText
end

local atkBtn = ability("LMB / F", "ATTACK", UDim2.fromOffset(0, 0))
local dashBtn, dashCd, dashCdText = ability("Q", "DASH", UDim2.fromOffset(136, 0))
local skillBtn, skillCd, skillCdText = ability("E", "CLEAVE", UDim2.fromOffset(272, 0))

-- ============ start panel ============
local startPanel = new("Frame", { Name = "StartPanel", Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5,0.5),
	Size = UDim2.fromOffset(400, 226), BackgroundColor3 = PANEL, BackgroundTransparency = 0.08 }, root)
new("UICorner", { CornerRadius = UDim.new(0, 10) }, startPanel)
new("UIStroke", { Color = ACCENT, Transparency = 0.5, Thickness = 1 }, startPanel)
new("TextLabel", { Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1,
	Font = font(), TextSize = 26, TextColor3 = ACCENT, Text = "SLAY & LOOT" }, startPanel)
local startSub = new("TextLabel", { Position = UDim2.fromOffset(0, 62), Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1,
	Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = MUTED, TextWrapped = true,
	Text = "Clear three halls. Break the Goblin King. Take his blade." }, startPanel)
local normalBtn = mkButton(startPanel, "ENTER DUNGEON", UDim2.fromOffset(320, 44), UDim2.fromOffset(40, 116), Color3.fromRGB(44,38,26))
local hardBtn = mkButton(startPanel, "ENTER HARD DUNGEON", UDim2.fromOffset(320, 44), UDim2.fromOffset(40, 116), Color3.fromRGB(56,30,24))
hardBtn.Visible = false
local hardLock = new("TextLabel", { Position = UDim2.fromOffset(0, 168), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
	Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = MUTED, Text = "Hard unlocks after your first clear" }, startPanel)

-- ============ inventory ============
local inv = new("Frame", { Name = "Inventory", Position = UDim2.new(1, -24, 0, 120), AnchorPoint = Vector2.new(1,0),
	Size = UDim2.fromOffset(320, 420), BackgroundColor3 = PANEL, BackgroundTransparency = 0.05, Visible = false }, root)
new("UICorner", { CornerRadius = UDim.new(0, 10) }, inv)
new("UIStroke", { Color = ACCENT, Transparency = 0.55, Thickness = 1 }, inv)
new("TextLabel", { Position = UDim2.fromOffset(16, 12), Size = UDim2.new(1, -32, 0, 24), BackgroundTransparency = 1,
	Font = font(), TextSize = 16, TextColor3 = ACCENT, TextXAlignment = Enum.TextXAlignment.Left, Text = "INVENTORY" }, inv)
local equippedLabel = new("TextLabel", { Position = UDim2.fromOffset(16, 38), Size = UDim2.new(1, -32, 0, 20), BackgroundTransparency = 1,
	Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Left, Text = "Equipped: Starter Blade" }, inv)
local list = new("ScrollingFrame", { Position = UDim2.fromOffset(16, 66), Size = UDim2.new(1, -32, 1, -84),
	BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new() }, inv)
new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, list)

-- ============ loot card ============
local lootCard = new("Frame", { Name = "LootCard", Position = UDim2.fromScale(0.5, 0.42), AnchorPoint = Vector2.new(0.5,0.5),
	Size = UDim2.fromOffset(340, 190), BackgroundColor3 = PANEL, BackgroundTransparency = 0.05, Visible = false }, root)
new("UICorner", { CornerRadius = UDim.new(0, 10) }, lootCard)
local lootStroke = new("UIStroke", { Color = ACCENT, Transparency = 0.3, Thickness = 2 }, lootCard)
new("TextLabel", { Position = UDim2.fromOffset(0, 16), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1,
	Font = font(), TextSize = 13, TextColor3 = MUTED, Text = "REWARD" }, lootCard)
local lootName = new("TextLabel", { Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1,
	Font = font(), TextSize = 24, TextColor3 = ACCENT, Text = "" }, lootCard)
local lootRarity = new("TextLabel", { Position = UDim2.fromOffset(0, 76), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1,
	Font = font(), TextSize = 13, TextColor3 = MUTED, Text = "" }, lootCard)
local lootDmg = new("TextLabel", { Position = UDim2.fromOffset(0, 100), Size = UDim2.new(1,0,0,24), BackgroundTransparency = 1,
	Font = font(), TextSize = 18, TextColor3 = TEXT, Text = "" }, lootCard)
local takeBtn = mkButton(lootCard, "TAKE", UDim2.fromOffset(140, 38), UDim2.fromOffset(100, 136), Color3.fromRGB(44,38,26))

-- ============ floating damage numbers ============
local function floatText(worldPos, text, color, size)
	local part = Instance.new("Part")
	part.Anchored = true; part.CanCollide = false; part.CanQuery = false
	part.Transparency = 1; part.Size = Vector3.new(1,1,1); part.CFrame = CFrame.new(worldPos)
	part.Parent = workspace
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(120, 40); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0,0,0)
	bb.Parent = part
	local t = new("TextLabel", { Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Font = font(),
		TextSize = size or 24, TextColor3 = color, Text = text, TextStrokeTransparency = 0.3,
		TextStrokeColor3 = Color3.fromRGB(0,0,0) }, bb)
	TweenService:Create(part, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = CFrame.new(worldPos + Vector3.new(math.random(-6,6)/10, 3.4, 0)) }):Play()
	TweenService:Create(t, TweenInfo.new(0.7), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	task.delay(0.75, function() part:Destroy() end)
end

-- ============ slash vfx ============
local function slashFX(origin, look, range, arcDeg, color)
	local folder = Instance.new("Folder"); folder.Name = "Slash"; folder.Parent = workspace
	local n = 7
	for i = 1, n do
		local frac = (i - 1) / (n - 1)
		local ang = math.rad(-arcDeg/2 + arcDeg * frac)
		local dir = CFrame.new(Vector3.zero, look) * CFrame.Angles(0, ang, 0)
		local p = Instance.new("Part")
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false
		p.Material = Enum.Material.Neon; p.Color = color
		p.Size = Vector3.new(0.22, 0.55, range * 0.42)
		p.CFrame = CFrame.new(origin + dir.LookVector * (range * 0.72) + Vector3.new(0, 2.2, 0), origin + dir.LookVector * range + Vector3.new(0, 2.2, 0))
		p.Transparency = 0.15
		p.Parent = folder
		TweenService:Create(p, TweenInfo.new(0.22), { Transparency = 1 }):Play()
	end
	task.delay(0.3, function() folder:Destroy() end)
end

local function ringFX(pos, radius, color)
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.CanQuery = false
	p.Material = Enum.Material.Neon; p.Color = color
	p.Shape = Enum.PartType.Cylinder
	p.Size = Vector3.new(0.4, radius * 2, radius * 2)
	p.CFrame = CFrame.new(pos.X, 0.4, pos.Z) * CFrame.Angles(0, 0, math.rad(90))
	p.Transparency = 0.2
	p.Parent = workspace
	TweenService:Create(p, TweenInfo.new(0.45), { Transparency = 1, Size = Vector3.new(0.4, radius * 2.6, radius * 2.6) }):Play()
	task.delay(0.5, function() p:Destroy() end)
end

-- ============ sword ============
local swordModel, swordWeld
local swingT, swingKind = 0, 1

local function buildSword(char)
	if swordModel and swordModel.Parent then swordModel:Destroy() end
	local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	if not hand then return end
	local m = Instance.new("Model"); m.Name = "Blade"
	local function piece(name, size, cf, color, mat)
		local p = Instance.new("Part")
		p.Name = name; p.Size = size; p.CFrame = cf
		p.Anchored = false; p.CanCollide = false; p.CanQuery = false; p.Massless = true
		p.Material = mat or Enum.Material.SmoothPlastic; p.Color = color
		p.Parent = m
		return p
	end
	local base = CFrame.new(0, -1.4, 0)
	piece("Grip", Vector3.new(0.34, 1.0, 0.34), base, Color3.fromRGB(48,36,26))
	piece("Pommel", Vector3.new(0.46, 0.24, 0.46), base * CFrame.new(0, 0.56, 0), ACCENT, Enum.Material.Metal)
	piece("Guard", Vector3.new(1.7, 0.24, 0.42), base * CFrame.new(0, -0.58, 0), ACCENT, Enum.Material.Metal)
	local blade = piece("Blade", Vector3.new(0.26, 4.4, 0.78), base * CFrame.new(0, -2.9, 0), Color3.fromRGB(206,212,224), Enum.Material.Metal)
	blade.Material = Enum.Material.Metal
	piece("Edge", Vector3.new(0.1, 4.3, 0.2), base * CFrame.new(0, -2.9, -0.36), Color3.fromRGB(255,246,225), Enum.Material.Neon)
	m.PrimaryPart = m:FindFirstChild("Grip")
	for _, p in ipairs(m:GetChildren()) do
		if p:IsA("BasePart") and p ~= m.PrimaryPart then
			local wc = Instance.new("WeldConstraint")
			wc.Part0 = m.PrimaryPart
			wc.Part1 = p
			wc.Parent = p
		end
	end
	m.Parent = char
	local w = Instance.new("Weld")
	w.Part0 = hand; w.Part1 = m.PrimaryPart
	w.C0 = CFrame.new(0, -0.35, 0) * CFrame.Angles(math.rad(135), 0, 0)
	w.Parent = m.PrimaryPart
	swordModel = m
	swordWeld = w
end

local function swingPose(kind, t)
	local a
	if kind == 1 then
		a = CFrame.Angles(0, math.rad(-95 + 190 * t), math.rad(-25 + 45 * t))
	elseif kind == 2 then
		a = CFrame.Angles(0, math.rad(95 - 190 * t), math.rad(20 - 45 * t))
	else
		a = CFrame.Angles(math.rad(-60 + 110 * t), 0, math.rad(-15 + 30 * t))
	end
	return CFrame.new(0, -0.35, 0) * CFrame.Angles(math.rad(135), 0, 0) * a
end

RunS.RenderStepped:Connect(function(dt)
	if swordWeld and swordWeld.Parent then
		if swingT > 0 then
			swingT -= dt
			local dur = swingKind == 3 and 0.36 or 0.26
			local t = math.clamp(1 - (swingT / dur), 0, 1)
			local eased = t < 0.55 and (t / 0.55) or (1 - (t - 0.55) / 0.45)
			swordWeld.C0 = swingPose(swingKind, eased)
		else
			swordWeld.C0 = swingPose(swingKind, 0.5)
		end
	end
end)

-- ============ camera shake ============
local shake = 0
local cam = workspace.CurrentCamera
RunS.RenderStepped:Connect(function(dt)
	if shake > 0 then
		shake = math.max(0, shake - dt * 3.4)
		local cam2 = workspace.CurrentCamera
		cam2.CFrame = cam2.CFrame * CFrame.new(math.random(-100,100)/1400 * shake, math.random(-100,100)/1400 * shake, 0)
	end
end)

-- ============ UI logic ============
local function applyState(s)
	if not s then return end
	state.pendingLoot = nil
	state.equipped = nil
	for k, v in pairs(s) do state[k] = v end
	local hpPct = state.maxHp > 0 and math.clamp(state.hp / state.maxHp, 0, 1) or 0
	TweenService:Create(hpFill, TweenInfo.new(0.15), { Size = UDim2.fromScale(hpPct, 1) }):Play()
	hpFill.BackgroundColor3 = hpPct > 0.35 and RED or Color3.fromRGB(240,120,60)
	hpText.Text = math.floor(state.hp) .. " / " .. math.floor(state.maxHp)
	xpFill.Size = UDim2.fromScale((state.xp % 100) / 100, 1)
	goldLabel.Text = state.gold .. " GOLD"
	topLeft.Level.Text = "LEVEL " .. state.level
	diffBadge.Text = string.upper(state.difficulty)
	diffBadge.TextColor3 = Config.Difficulty[state.difficulty] and Config.Difficulty[state.difficulty].color or MUTED
	equippedLabel.Text = "Equipped: " .. (state.equipped and (function()
		for _, it in ipairs(state.inventory) do if it.id == state.equipped then return it.name .. "  (+" .. it.dmg .. ")" end end
		return "?" end)() or "Starter Blade")
	leaveBtn.Visible = state.runState == "active" or state.runState == "cleared"
	local idle = state.runState == "idle"
	startPanel.Visible = idle
	if idle then
		if state.hasClearedNormal then
			hardBtn.Visible = true; normalBtn.Visible = false
			startSub.Text = "Normal cleared. Hard hits harder and pays better."
			hardLock.Text = "Recommended: equip your best blade first"
		else
			hardBtn.Visible = false; normalBtn.Visible = true
			startSub.Text = "Clear three halls. Break the Goblin King. Take his blade."
			hardLock.Text = "Hard unlocks after your first clear"
		end
	end
	-- inventory list
	for _, c in ipairs(list:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	local y = 0
	for i, it in ipairs(state.inventory) do
		local row = new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = Color3.fromRGB(30,33,40),
			BackgroundTransparency = 0.15, LayoutOrder = i, BorderSizePixel = 0 }, list)
		new("UICorner", { CornerRadius = UDim.new(0, 6) }, row)
		local rc = Config.Rarity[it.rarity] or MUTED
		new("Frame", { Size = UDim2.fromOffset(4, 56), BackgroundColor3 = rc, BorderSizePixel = 0 }, row)
		new("TextLabel", { Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -104, 0, 20), BackgroundTransparency = 1,
			Font = font(), TextSize = 15, TextColor3 = rc, TextXAlignment = Enum.TextXAlignment.Left, Text = it.name }, row)
		new("TextLabel", { Position = UDim2.fromOffset(14, 30), Size = UDim2.new(1, -104, 0, 18), BackgroundTransparency = 1,
			Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = MUTED, TextXAlignment = Enum.TextXAlignment.Left,
			Text = it.rarity .. "  |  DMG " .. it.dmg }, row)
		local equipped = state.equipped == it.id
		local b = mkButton(row, equipped and "EQUIPPED" or "EQUIP", UDim2.fromOffset(88, 30), UDim2.fromOffset(196, 13),
			equipped and Color3.fromRGB(38,52,38) or Color3.fromRGB(44,38,26))
		b.TextSize = 11
		if not equipped then
			b.MouseButton1Click:Connect(function() Request:FireServer("equip", { id = it.id }) end)
		end
		y += 1
	end
	list.CanvasSize = UDim2.new(0, 0, 0, math.max(1, y) * 64)
	invBtn.Text = "INVENTORY  [TAB]  (" .. #state.inventory .. ")"
	-- cooldown rings
	local dashPct = math.clamp(state.dashCd / Config.Dash.cd, 0, 1)
	dashCd.Size = UDim2.fromScale(1, dashPct)
	dashCdText.Text = dashPct > 0.02 and string.format("%.1f", state.dashCd) or ""
	local skillPct = math.clamp(state.skillCd / Config.Skill.cd, 0, 1)
	skillCd.Size = UDim2.fromScale(1, skillPct)
	skillCdText.Text = skillPct > 0.02 and string.format("%.1f", state.skillCd) or ""
	-- loot card
	if state.pendingLoot and state.runState ~= "idle" then
		local it = state.pendingLoot
		local rc = Config.Rarity[it.rarity] or ACCENT
		lootCard.Visible = true
		lootName.Text = it.name; lootName.TextColor3 = rc
		lootStroke.Color = rc
		lootRarity.Text = it.rarity
		lootRarity.TextColor3 = rc
		lootDmg.Text = "DAMAGE  +" .. it.dmg
	else
		lootCard.Visible = false
	end
end

local function showBanner(text, duration)
	bannerText.Text = text
	banner.Visible = true
	banner.BackgroundTransparency = 0.25
	task.delay(duration or 2.6, function()
		if bannerText.Text == text then banner.Visible = false end
	end)
end

-- ============ input ============
local function aimDir()
	local cam2 = workspace.CurrentCamera
	local l = cam2.CFrame.LookVector
	local f = Vector3.new(l.X, 0, l.Z)
	if f.Magnitude < 0.05 then return Vector3.new(0, 0, -1) end
	return f.Unit
end

local function faceAim()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local d = aimDir()
	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + d)
end

local function doAttack()
	faceAim()
	Request:FireServer("attack", { aim = aimDir() })
end

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if state.runState == "active" then doAttack() end
	elseif input.KeyCode == Enum.KeyCode.F then
		if state.runState == "active" then doAttack() end
	elseif input.KeyCode == Enum.KeyCode.Q then
		faceAim(); Request:FireServer("dash", { aim = aimDir() })
	elseif input.KeyCode == Enum.KeyCode.E then
		faceAim(); Request:FireServer("skill", { aim = aimDir() })
	elseif input.KeyCode == Enum.KeyCode.Tab then
		inv.Visible = not inv.Visible
	end
end)

atkBtn.MouseButton1Click:Connect(function() if state.runState == "active" then doAttack() end end)
dashBtn.MouseButton1Click:Connect(function() faceAim(); Request:FireServer("dash", { aim = aimDir() }) end)
skillBtn.MouseButton1Click:Connect(function() faceAim(); Request:FireServer("skill", { aim = aimDir() }) end)
invBtn.MouseButton1Click:Connect(function() inv.Visible = not inv.Visible end)
leaveBtn.MouseButton1Click:Connect(function() Request:FireServer("abandon") end)
normalBtn.MouseButton1Click:Connect(function() Request:FireServer("startRun", { difficulty = "Normal" }) end)
hardBtn.MouseButton1Click:Connect(function() Request:FireServer("startRun", { difficulty = "Hard" }) end)
takeBtn.MouseButton1Click:Connect(function() Request:FireServer("claimLoot") end)

-- ============ server events ============
StateSync.OnClientEvent:Connect(applyState)

Feedback.OnClientEvent:Connect(function(kind, payload)
	if kind == "swing" then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local combo = Config.Combo[payload.index] or Config.Combo[1]
		local look = Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z)
		if look.Magnitude < 0.01 then look = Vector3.new(0,0,-1) end
		swingKind = payload.index == 4 and 3 or payload.index
		swingT = swingKind == 3 and 0.36 or 0.26
		slashFX(hrp.Position, look.Unit, combo.range, combo.arc, Color3.fromRGB(255,244,214))
	elseif kind == "skill" then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			ringFX(hrp.Position, Config.Skill.range, Color3.fromRGB(255,196,120))
			slashFX(hrp.Position, Vector3.new(hrp.CFrame.LookVector.X, 0, hrp.CFrame.LookVector.Z).Unit, 14, 340, Color3.fromRGB(255,214,150))
		end
		shake = math.max(shake, 0.5)
	elseif kind == "dash" then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then ringFX(hrp.Position, 5, Color3.fromRGB(150,210,255)) end
	elseif kind == "damage" then
		floatText(payload.pos, tostring(payload.amount), Color3.fromRGB(255,232,170), 22)
	elseif kind == "slam" then
		ringFX(payload.pos, payload.radius, Color3.fromRGB(255,90,60))
		shake = math.max(shake, 0.8)
	elseif kind == "playerHit" then
		shake = math.max(shake, 0.9)
	elseif kind == "playerHurt" then
		shake = math.max(shake, 1.1)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then floatText(hrp.Position + Vector3.new(0, 3, 0), "-" .. tostring(payload.amount), Color3.fromRGB(255,110,96), 26) end
	elseif kind == "enemyDeath" then
		ringFX(payload.pos, 4, Color3.fromRGB(255,180,120))
	elseif kind == "encounter" then
		showBanner(payload.label .. " — clear the room", 2.4)
	elseif kind == "roomClear" then
		showBanner(payload.label .. " cleared", 2.0)
	elseif kind == "bossDown" then
		showBanner("THE GOBLIN KING FALLS — claim your reward", 4.0)
		shake = math.max(shake, 1.4)
	elseif kind == "loot" then
		showBanner("A blade awaits", 2.0)
	elseif kind == "lootClaimed" then
		inv.Visible = true
	elseif kind == "equipped" then
		showBanner("Equipped", 1.4)
	elseif kind == "runStart" then
		showBanner(payload.difficulty .. " — Ruined Hall", 2.6)
	end
end)

-- ============ character hooks ============
local function onChar(char)
	buildSword(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then
		hum.Died:Connect(function()
			task.delay(0.4, function() Request:FireServer("hub") end)
		end)
	end
end

if player.Character then onChar(player.Character) end
player.CharacterAdded:Connect(onChar)

task.defer(function()
	pcall(function()
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	end)
end)

applyState(state)
