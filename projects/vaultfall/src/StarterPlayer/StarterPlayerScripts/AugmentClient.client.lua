local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")
local claimRemote = remotes:WaitForChild("ClaimAugment")

local gui = Instance.new("ScreenGui")
gui.Name = "BreachAugments"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 8
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "ChoicePanel"
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, -18, 0.5, 0)
panel.Size = UDim2.fromOffset(360, 392)
panel.BackgroundColor3 = Color3.fromRGB(17, 20, 26)
panel.BackgroundTransparency = 0.05
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(88, 132, 154)
panelStroke.Transparency = 0.2
panelStroke.Thickness = 1
panelStroke.Parent = panel

local accent = Instance.new("Frame")
accent.Size = UDim2.new(0, 4, 1, -20)
accent.Position = UDim2.fromOffset(10, 10)
accent.BackgroundColor3 = Color3.fromRGB(81, 167, 201)
accent.BorderSizePixel = 0
accent.Parent = panel
local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(1, 0)
accentCorner.Parent = accent

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Position = UDim2.fromOffset(28, 18)
header.Size = UDim2.new(1, -48, 0, 24)
header.Font = Enum.Font.GothamBold
header.Text = "BREACH AUGMENT"
header.TextSize = 17
header.TextColor3 = Color3.fromRGB(221, 241, 248)
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local sourceLabel = Instance.new("TextLabel")
sourceLabel.BackgroundTransparency = 1
sourceLabel.Position = UDim2.fromOffset(28, 43)
sourceLabel.Size = UDim2.new(1, -48, 0, 22)
sourceLabel.Font = Enum.Font.GothamMedium
sourceLabel.Text = "CHOOSE ONE"
sourceLabel.TextSize = 11
sourceLabel.TextColor3 = Color3.fromRGB(128, 157, 170)
sourceLabel.TextXAlignment = Enum.TextXAlignment.Left
sourceLabel.Parent = panel

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.AnchorPoint = Vector2.new(0, 1)
hint.Position = UDim2.new(0, 28, 1, -14)
hint.Size = UDim2.new(1, -48, 0, 18)
hint.Font = Enum.Font.Gotham
hint.Text = "1 / 2 / 3 to install  •  stacks persist for this breach"
hint.TextSize = 10
hint.TextColor3 = Color3.fromRGB(102, 117, 126)
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.Parent = panel

local cards = {}
local currentChoices = nil

local function makeCard(index)
    local button = Instance.new("TextButton")
    button.Name = "Choice" .. index
    button.Position = UDim2.fromOffset(28, 78 + ((index - 1) * 91))
    button.Size = UDim2.new(1, -48, 0, 78)
    button.BackgroundColor3 = Color3.fromRGB(28, 34, 42)
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = panel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(67, 81, 92)
    stroke.Transparency = 0.3
    stroke.Parent = button

    local key = Instance.new("TextLabel")
    key.BackgroundColor3 = Color3.fromRGB(45, 61, 72)
    key.Position = UDim2.fromOffset(10, 10)
    key.Size = UDim2.fromOffset(30, 30)
    key.Font = Enum.Font.GothamBold
    key.Text = tostring(index)
    key.TextSize = 13
    key.TextColor3 = Color3.fromRGB(205, 232, 242)
    key.BorderSizePixel = 0
    key.Parent = button
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = key

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Position = UDim2.fromOffset(50, 8)
    name.Size = UDim2.new(1, -60, 0, 26)
    name.Font = Enum.Font.GothamBold
    name.Text = "AUGMENT"
    name.TextSize = 14
    name.TextColor3 = Color3.fromRGB(237, 241, 244)
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = button

    local desc = Instance.new("TextLabel")
    desc.BackgroundTransparency = 1
    desc.Position = UDim2.fromOffset(50, 34)
    desc.Size = UDim2.new(1, -60, 0, 34)
    desc.Font = Enum.Font.Gotham
    desc.Text = ""
    desc.TextSize = 11
    desc.TextWrapped = true
    desc.TextColor3 = Color3.fromRGB(153, 166, 174)
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(34, 43, 53) }):Play()
        stroke.Color = Color3.fromRGB(81, 167, 201)
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(28, 34, 42) }):Play()
        stroke.Color = Color3.fromRGB(67, 81, 92)
    end)

    cards[index] = { Button = button, Name = name, Description = desc }
end

for index = 1, 3 do
    makeCard(index)
end

local buildStrip = Instance.new("Frame")
buildStrip.Name = "BuildStrip"
buildStrip.AnchorPoint = Vector2.new(1, 1)
buildStrip.Position = UDim2.new(1, -18, 1, -18)
buildStrip.Size = UDim2.fromOffset(360, 42)
buildStrip.BackgroundColor3 = Color3.fromRGB(19, 22, 28)
buildStrip.BackgroundTransparency = 0.12
buildStrip.BorderSizePixel = 0
buildStrip.Parent = gui
local buildCorner = Instance.new("UICorner")
buildCorner.CornerRadius = UDim.new(0, 9)
buildCorner.Parent = buildStrip

local buildLabel = Instance.new("TextLabel")
buildLabel.BackgroundTransparency = 1
buildLabel.Position = UDim2.fromOffset(12, 0)
buildLabel.Size = UDim2.new(1, -24, 1, 0)
buildLabel.Font = Enum.Font.GothamMedium
buildLabel.Text = "AUGMENTS  0  •  no protocols installed"
buildLabel.TextSize = 11
buildLabel.TextColor3 = Color3.fromRGB(150, 168, 177)
buildLabel.TextXAlignment = Enum.TextXAlignment.Left
buildLabel.TextTruncate = Enum.TextTruncate.AtEnd
buildLabel.Parent = buildStrip

local function choose(index)
    if not currentChoices then
        return
    end
    local choice = currentChoices[index]
    if not choice then
        return
    end
    currentChoices = nil
    panel.Visible = false
    claimRemote:FireServer(choice.Id)
end

for index, card in ipairs(cards) do
    card.Button.Activated:Connect(function()
        choose(index)
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not panel.Visible then
        return
    end
    if input.KeyCode == Enum.KeyCode.One then
        choose(1)
    elseif input.KeyCode == Enum.KeyCode.Two then
        choose(2)
    elseif input.KeyCode == Enum.KeyCode.Three then
        choose(3)
    end
end)

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "AugmentOffer" then
        currentChoices = payload.Choices or {}
        sourceLabel.Text = tostring(payload.Source or "BREACH REWARD")
        for index, card in ipairs(cards) do
            local choice = currentChoices[index]
            card.Button.Visible = choice ~= nil
            if choice then
                card.Name.Text = tostring(choice.Name or choice.Id or "AUGMENT")
                card.Description.Text = tostring(choice.Description or "")
            end
        end
        panel.Visible = true
        panel.Position = UDim2.new(1, 380, 0.5, 0)
        TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -18, 0.5, 0),
        }):Play()
    elseif kind == "AugmentState" then
        local augments = payload.Augments or {}
        local names = {}
        for _, item in ipairs(augments) do
            local suffix = (item.Stacks or 1) > 1 and (" x" .. tostring(item.Stacks)) or ""
            table.insert(names, tostring(item.Name or item.Id) .. suffix)
        end
        local summary = #names > 0 and table.concat(names, "  •  ") or "no protocols installed"
        buildLabel.Text = string.format("AUGMENTS  %d  •  %s", payload.Picks or 0, summary)
    elseif kind == "Run" and payload.Active == false then
        currentChoices = nil
        panel.Visible = false
    end
end)
