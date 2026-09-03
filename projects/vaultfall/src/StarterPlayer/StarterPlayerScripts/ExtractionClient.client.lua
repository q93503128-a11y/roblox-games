local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "ExtractionHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 7
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "RiskPanel"
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -18, 1, -104)
panel.Size = UDim2.fromOffset(260, 92)
panel.BackgroundColor3 = Color3.fromRGB(21, 25, 29)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(77, 95, 100)
stroke.Transparency = 0.28
stroke.Thickness = 1
stroke.Parent = panel

local accent = Instance.new("Frame")
accent.Name = "Accent"
accent.Size = UDim2.new(0, 4, 1, -12)
accent.Position = UDim2.fromOffset(6, 6)
accent.BackgroundColor3 = Color3.fromRGB(90, 214, 190)
accent.BorderSizePixel = 0
accent.Parent = panel
local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(1, 0)
accentCorner.Parent = accent

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(18, 8)
title.Size = UDim2.new(1, -30, 0, 20)
title.Font = Enum.Font.GothamBold
title.Text = "UNSECURED ESSENCE"
title.TextSize = 12
title.TextColor3 = Color3.fromRGB(154, 170, 174)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local bankLabel = Instance.new("TextLabel")
bankLabel.Name = "Bank"
bankLabel.BackgroundTransparency = 1
bankLabel.Position = UDim2.fromOffset(18, 27)
bankLabel.Size = UDim2.new(1, -30, 0, 29)
bankLabel.Font = Enum.Font.GothamBold
bankLabel.Text = "0 AT RISK"
bankLabel.TextSize = 22
bankLabel.TextColor3 = Color3.fromRGB(238, 241, 242)
bankLabel.TextXAlignment = Enum.TextXAlignment.Left
bankLabel.Parent = panel

local status = Instance.new("TextLabel")
status.Name = "Status"
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(18, 57)
status.Size = UDim2.new(1, -30, 0, 25)
status.Font = Enum.Font.GothamMedium
status.Text = "Push deeper to increase the payout."
status.TextSize = 11
status.TextColor3 = Color3.fromRGB(154, 170, 174)
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextYAlignment = Enum.TextYAlignment.Top
status.Parent = panel

local choice = Instance.new("Frame")
choice.Name = "ExtractionChoice"
choice.AnchorPoint = Vector2.new(0.5, 0)
choice.Position = UDim2.new(0.5, 0, 0, 84)
choice.Size = UDim2.fromOffset(440, 88)
choice.BackgroundColor3 = Color3.fromRGB(20, 30, 31)
choice.BackgroundTransparency = 0.04
choice.BorderSizePixel = 0
choice.Visible = false
choice.Parent = gui

local choiceCorner = Instance.new("UICorner")
choiceCorner.CornerRadius = UDim.new(0, 12)
choiceCorner.Parent = choice
local choiceStroke = Instance.new("UIStroke")
choiceStroke.Color = Color3.fromRGB(90, 214, 190)
choiceStroke.Transparency = 0.18
choiceStroke.Thickness = 1.25
choiceStroke.Parent = choice

local choiceTitle = Instance.new("TextLabel")
choiceTitle.BackgroundTransparency = 1
choiceTitle.Position = UDim2.fromOffset(16, 9)
choiceTitle.Size = UDim2.new(1, -32, 0, 22)
choiceTitle.Font = Enum.Font.GothamBold
choiceTitle.Text = "EXTRACTION WINDOW OPEN"
choiceTitle.TextSize = 15
choiceTitle.TextColor3 = Color3.fromRGB(111, 232, 207)
choiceTitle.TextXAlignment = Enum.TextXAlignment.Center
choiceTitle.Parent = choice

local choiceBody = Instance.new("TextLabel")
choiceBody.BackgroundTransparency = 1
choiceBody.Position = UDim2.fromOffset(16, 33)
choiceBody.Size = UDim2.new(1, -32, 0, 42)
choiceBody.Font = Enum.Font.GothamMedium
choiceBody.Text = ""
choiceBody.TextSize = 12
choiceBody.TextColor3 = Color3.fromRGB(221, 229, 230)
choiceBody.TextWrapped = true
choiceBody.TextXAlignment = Enum.TextXAlignment.Center
choiceBody.TextYAlignment = Enum.TextYAlignment.Top
choiceBody.Parent = choice

local lastBank = 0
local pulseToken = 0

local function pulseBank()
    pulseToken += 1
    local token = pulseToken
    bankLabel.TextColor3 = Color3.fromRGB(111, 232, 207)
    TweenService:Create(bankLabel, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color3.fromRGB(238, 241, 242),
    }):Play()
    task.delay(0.3, function()
        if token == pulseToken then
            bankLabel.TextColor3 = Color3.fromRGB(238, 241, 242)
        end
    end)
end

local function update(payload)
    local active = payload.Active == true
    local available = payload.Available == true
    local bank = math.max(0, math.floor(tonumber(payload.Bank) or 0))
    local bonus = math.max(0, math.floor(tonumber(payload.Bonus) or 0))
    local total = math.max(0, math.floor(tonumber(payload.Total) or (bank + bonus)))
    local room = math.max(0, math.floor(tonumber(payload.Room) or 0))

    panel.Visible = active
    choice.Visible = active and available
    bankLabel.Text = string.format("%d AT RISK", bank)

    if bank > lastBank and active then
        pulseBank()
    end
    lastBank = bank

    if available then
        status.Text = string.format("Checkpoint %d reached. Bank now or gamble on deeper sectors.", room)
        choiceBody.Text = string.format("EXTRACT: secure %d Essence (%d bank + %d depth/risk bonus)  •  CONTINUE: walk through the open sector gate", total, bank, bonus)
        accent.BackgroundColor3 = Color3.fromRGB(90, 214, 190)
    else
        status.Text = "Death before extraction loses this bank. Deeper checkpoints pay a larger bonus."
        accent.BackgroundColor3 = bank > 0 and Color3.fromRGB(215, 153, 76) or Color3.fromRGB(77, 95, 100)
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Extraction" and type(payload) == "table" then
        update(payload)
    end
end)
