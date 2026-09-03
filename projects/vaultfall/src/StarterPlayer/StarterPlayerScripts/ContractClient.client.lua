local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")
local selectRemote = remotes:WaitForChild("SelectContract")

local gui = Instance.new("ScreenGui")
gui.Name = "ContractUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 62
gui.Parent = player:WaitForChild("PlayerGui")

local shade = Instance.new("Frame")
shade.Name = "Shade"
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.fromRGB(4, 7, 9)
shade.BackgroundTransparency = 1
shade.Visible = false
shade.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "OperationsPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(850, 510)
panel.BackgroundColor3 = Color3.fromRGB(14, 20, 24)
panel.BorderSizePixel = 0
panel.Parent = shade

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(66, 126, 141)
stroke.Transparency = 0.25
stroke.Thickness = 2
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(30, 20)
title.Size = UDim2.new(1, -60, 0, 40)
title.Font = Enum.Font.GothamBlack
title.Text = "OPERATIONS // SELECT BREACH CONTRACT"
title.TextColor3 = Color3.fromRGB(223, 235, 239)
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(31, 62)
subtitle.Size = UDim2.new(1, -62, 0, 30)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "One contract governs the entire squad. Higher threat increases recovery value."
subtitle.TextColor3 = Color3.fromRGB(132, 157, 166)
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = panel

local cards = {}
for index = 1, 3 do
    local card = Instance.new("TextButton")
    card.Name = "Contract" .. index
    card.AutoButtonColor = false
    card.Position = UDim2.fromOffset(30 + ((index - 1) * 266), 112)
    card.Size = UDim2.fromOffset(246, 320)
    card.BackgroundColor3 = Color3.fromRGB(24, 31, 36)
    card.BorderSizePixel = 0
    card.Text = ""
    card.Parent = panel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Name = "SelectionStroke"
    cardStroke.Color = Color3.fromRGB(69, 87, 94)
    cardStroke.Thickness = 1.5
    cardStroke.Parent = card

    local threat = Instance.new("TextLabel")
    threat.Name = "Threat"
    threat.BackgroundTransparency = 1
    threat.Position = UDim2.fromOffset(18, 16)
    threat.Size = UDim2.new(1, -36, 0, 24)
    threat.Font = Enum.Font.GothamBold
    threat.TextColor3 = Color3.fromRGB(225, 147, 105)
    threat.TextSize = 13
    threat.TextXAlignment = Enum.TextXAlignment.Left
    threat.Parent = card

    local name = Instance.new("TextLabel")
    name.Name = "NameLabel"
    name.BackgroundTransparency = 1
    name.Position = UDim2.fromOffset(18, 48)
    name.Size = UDim2.new(1, -36, 0, 58)
    name.Font = Enum.Font.GothamBlack
    name.TextColor3 = Color3.fromRGB(230, 237, 240)
    name.TextSize = 21
    name.TextWrapped = true
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextYAlignment = Enum.TextYAlignment.Top
    name.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Name = "Description"
    desc.BackgroundTransparency = 1
    desc.Position = UDim2.fromOffset(18, 116)
    desc.Size = UDim2.new(1, -36, 0, 92)
    desc.Font = Enum.Font.Gotham
    desc.TextColor3 = Color3.fromRGB(165, 181, 187)
    desc.TextSize = 14
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.Parent = card

    local reward = Instance.new("TextLabel")
    reward.Name = "Reward"
    reward.BackgroundTransparency = 1
    reward.Position = UDim2.fromOffset(18, 223)
    reward.Size = UDim2.new(1, -36, 0, 60)
    reward.Font = Enum.Font.GothamBold
    reward.TextColor3 = Color3.fromRGB(98, 208, 179)
    reward.TextSize = 14
    reward.TextWrapped = true
    reward.TextXAlignment = Enum.TextXAlignment.Left
    reward.TextYAlignment = Enum.TextYAlignment.Top
    reward.Parent = card

    local choose = Instance.new("TextLabel")
    choose.Name = "Choose"
    choose.AnchorPoint = Vector2.new(0.5, 1)
    choose.Position = UDim2.new(0.5, 0, 1, -14)
    choose.Size = UDim2.new(1, -36, 0, 25)
    choose.BackgroundTransparency = 1
    choose.Font = Enum.Font.GothamBold
    choose.Text = "SELECT"
    choose.TextColor3 = Color3.fromRGB(143, 176, 185)
    choose.TextSize = 14
    choose.Parent = card

    cards[index] = card
end

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 1)
close.Position = UDim2.new(1, -28, 1, -20)
close.Size = UDim2.fromOffset(100, 36)
close.BackgroundColor3 = Color3.fromRGB(35, 43, 48)
close.BorderSizePixel = 0
close.Font = Enum.Font.GothamBold
close.Text = "CLOSE"
close.TextColor3 = Color3.fromRGB(196, 207, 211)
close.TextSize = 13
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

local activeChip = Instance.new("TextLabel")
activeChip.AnchorPoint = Vector2.new(0.5, 0)
activeChip.Position = UDim2.fromScale(0.5, 0.035)
activeChip.Size = UDim2.fromOffset(470, 38)
activeChip.BackgroundColor3 = Color3.fromRGB(15, 25, 29)
activeChip.BackgroundTransparency = 0.12
activeChip.BorderSizePixel = 0
activeChip.Font = Enum.Font.GothamBold
activeChip.TextColor3 = Color3.fromRGB(113, 211, 188)
activeChip.TextSize = 14
activeChip.Visible = false
activeChip.Parent = gui
Instance.new("UICorner", activeChip).CornerRadius = UDim.new(0, 8)

local currentOffers = {}
local selectedId

local function setVisible(value)
    shade.Visible = value
    if value then
        shade.BackgroundTransparency = 1
        TweenService:Create(shade, TweenInfo.new(0.16), { BackgroundTransparency = 0.28 }):Play()
    end
end

local function refresh()
    for index, card in ipairs(cards) do
        local contract = currentOffers[index]
        card.Visible = contract ~= nil
        if contract then
            card.Threat.Text = "THREAT // " .. tostring(contract.Threat)
            card.NameLabel.Text = tostring(contract.Name)
            card.Description.Text = tostring(contract.Description)
            card.Reward.Text = tostring(contract.RewardText)
            local chosen = selectedId == contract.Id
            card.SelectionStroke.Color = chosen and Color3.fromRGB(88, 205, 177) or Color3.fromRGB(69, 87, 94)
            card.SelectionStroke.Thickness = chosen and 3 or 1.5
            card.Choose.Text = chosen and "SELECTED" or "SELECT"
            card.Choose.TextColor3 = chosen and Color3.fromRGB(100, 220, 187) or Color3.fromRGB(143, 176, 185)
        end
    end
end

for index, card in ipairs(cards) do
    card.MouseButton1Click:Connect(function()
        local contract = currentOffers[index]
        if contract then
            selectRemote:FireServer(contract.Id)
        end
    end)
end

close.MouseButton1Click:Connect(function()
    setVisible(false)
end)

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Contracts" and type(payload) == "table" then
        currentOffers = payload.Offers or currentOffers
        selectedId = payload.Selected
        refresh()
        if payload.Open then
            setVisible(true)
        end
        if payload.Active then
            activeChip.Text = string.format("ACTIVE CONTRACT  //  %s  //  %s", payload.Active.Name, payload.Active.Threat)
            activeChip.Visible = true
        end
    elseif kind == "ContractActive" and type(payload) == "table" then
        setVisible(false)
        activeChip.Text = string.format("ACTIVE CONTRACT  //  %s  //  %s", payload.Name, payload.Threat)
        activeChip.Visible = true
        task.delay(8, function()
            if activeChip.Visible then
                activeChip.Visible = false
            end
        end)
    elseif kind == "Run" and type(payload) == "table" and payload.Active == false then
        activeChip.Visible = false
    end
end)