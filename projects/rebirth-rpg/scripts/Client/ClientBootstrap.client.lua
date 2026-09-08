--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local projectRoot = ReplicatedStorage:WaitForChild("RebirthRPG")
local Protocol = require(projectRoot:WaitForChild("Shared"):WaitForChild("Protocol"))
local remotes = projectRoot:WaitForChild("Remotes")

local AttackIntent = remotes:WaitForChild(Protocol.Remotes.AttackIntent) :: RemoteEvent
local EquipItem = remotes:WaitForChild(Protocol.Remotes.EquipItem) :: RemoteEvent
local RequestRebirth = remotes:WaitForChild(Protocol.Remotes.RequestRebirth) :: RemoteEvent
local StateUpdated = remotes:WaitForChild(Protocol.Remotes.StateUpdated) :: RemoteEvent
local CombatFeedback = remotes:WaitForChild(Protocol.Remotes.CombatFeedback) :: RemoteEvent
local GetState = remotes:WaitForChild(Protocol.Remotes.GetState) :: RemoteFunction

local currentState: any = nil

-- INTERNAL SLICE UI ONLY. Final visual language waits for the approved asset/reference pass.
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RebirthRPG_InternalHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "StatePanel"
panel.Size = UDim2.fromOffset(280, 122)
panel.Position = UDim2.fromOffset(16, 16)
panel.BackgroundTransparency = 0.18
panel.BorderSizePixel = 0
panel.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 3)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = panel

local function makeLabel(name: string): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextSize = 16
	label.Font = Enum.Font.GothamMedium
	label.Text = ""
	label.Parent = panel
	return label
end

local levelLabel = makeLabel("Level")
local goldLabel = makeLabel("Gold")
local rebirthLabel = makeLabel("Rebirth")
local objectiveLabel = makeLabel("Objective")
objectiveLabel.TextSize = 14

local equipButton = Instance.new("TextButton")
equipButton.Name = "EquipWeaponB"
equipButton.Size = UDim2.fromOffset(170, 38)
equipButton.Position = UDim2.new(0, 16, 1, -56)
equipButton.Text = "Equip Weapon B"
equipButton.TextSize = 15
equipButton.Font = Enum.Font.GothamMedium
equipButton.Visible = false
equipButton.Parent = screenGui

equipButton.Activated:Connect(function()
	EquipItem:FireServer("weapon_start_b")
end)

local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Name = "Feedback"
feedbackLabel.AnchorPoint = Vector2.new(0.5, 0)
feedbackLabel.Position = UDim2.new(0.5, 0, 0, 18)
feedbackLabel.Size = UDim2.fromOffset(360, 34)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.TextSize = 18
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.Text = ""
feedbackLabel.Parent = screenGui

local feedbackToken = 0
local function showFeedback(text: string)
	feedbackToken += 1
	local token = feedbackToken
	feedbackLabel.Text = text
	task.delay(1.2, function()
		if token == feedbackToken then
			feedbackLabel.Text = ""
		end
	end)
end

local function refresh(state: any)
	if type(state) ~= "table" then
		return
	end
	currentState = state

	local progression = state.progression or {}
	local inventory = state.inventory or {}
	local equipped = inventory.equipped or {}
	local items = inventory.items or {}
	local regionProgress = progression.regionProgress or {}

	levelLabel.Text = string.format("Level %d   |   XP %d", progression.level or 1, progression.xp or 0)
	goldLabel.Text = string.format("Gold %d", progression.gold or 0)
	rebirthLabel.Text = string.format("Rebirth %d   |   Mainhand: %s", progression.rebirths or 0, tostring(equipped.mainhand or "none"))

	local bossCleared = regionProgress.boss_region_01_cleared == true
	if bossCleared and (progression.level or 1) >= 10 then
		objectiveLabel.Text = "Objective: Rebirth available (R / touch button)"
	elseif bossCleared then
		objectiveLabel.Text = "Objective: Reach Level 10"
	else
		objectiveLabel.Text = "Objective: Farm → upgrade → defeat region boss"
	end

	equipButton.Visible = (items.weapon_start_b or 0) > 0 and equipped.mainhand ~= "weapon_start_b"
end

StateUpdated.OnClientEvent:Connect(refresh)

CombatFeedback.OnClientEvent:Connect(function(payload: any)
	if type(payload) ~= "table" then
		return
	end

	if payload.type == "hit" then
		if payload.killed == true and type(payload.rewards) == "table" then
			local rewards = payload.rewards
			showFeedback(string.format("KO  +%d XP  +%d Gold", rewards.xp or 0, rewards.gold or 0))
		else
			showFeedback(string.format("%d", payload.damage or 0))
		end
	elseif payload.type == "rebirth" then
		if payload.success == true then
			showFeedback("REBIRTH! Early progression is now faster.")
		else
			showFeedback("Rebirth locked: " .. tostring(payload.reason or "requirements"))
		end
	end
end)

local ACTION_ATTACK = "RebirthRPG_Attack"
local ACTION_REBIRTH = "RebirthRPG_Rebirth"

local function attackAction(_actionName: string, inputState: Enum.UserInputState)
	if inputState == Enum.UserInputState.Begin then
		-- Immediate local response hook. Approved animation/VFX will be attached after Studio asset intake.
		AttackIntent:FireServer()
	end
	return Enum.ContextActionResult.Sink
end

local function rebirthAction(_actionName: string, inputState: Enum.UserInputState)
	if inputState == Enum.UserInputState.Begin then
		RequestRebirth:FireServer()
	end
	return Enum.ContextActionResult.Sink
end

ContextActionService:BindAction(
	ACTION_ATTACK,
	attackAction,
	true,
	Enum.UserInputType.MouseButton1,
	Enum.KeyCode.ButtonR2
)
ContextActionService:SetTitle(ACTION_ATTACK, "Attack")
ContextActionService:SetPosition(ACTION_ATTACK, UDim2.new(1, -135, 1, -155))

ContextActionService:BindAction(
	ACTION_REBIRTH,
	rebirthAction,
	true,
	Enum.KeyCode.R,
	Enum.KeyCode.ButtonY
)
ContextActionService:SetTitle(ACTION_REBIRTH, "Rebirth")
ContextActionService:SetPosition(ACTION_REBIRTH, UDim2.new(1, -235, 1, -155))

local ok, initialState = pcall(function()
	return GetState:InvokeServer()
end)
if ok then
	refresh(initialState)
else
	warn("[RebirthRPG] Failed to request initial state")
end
