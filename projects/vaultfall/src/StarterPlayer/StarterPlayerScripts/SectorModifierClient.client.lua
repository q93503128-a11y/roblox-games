local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "SectorModifierHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 13
gui.Parent = playerGui

local card = Instance.new("Frame")
card.Name = "ModifierCard"
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position = UDim2.fromScale(0.5, 0.075)
card.Size = UDim2.fromOffset(430, 78)
card.BackgroundColor3 = Color3.fromRGB(17, 20, 25)
card.BackgroundTransparency = 0.08
card.BorderSizePixel = 0
card.Visible = false
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Name = "AccentStroke"
stroke.Color = Color3.fromRGB(120, 140, 255)
stroke.Transparency = 0.2
stroke.Thickness = 1.5
stroke.Parent = card

local accent = Instance.new("Frame")
accent.Name = "Accent"
accent.Size = UDim2.new(0, 5, 1, 0)
accent.BackgroundColor3 = stroke.Color
accent.BorderSizePixel = 0
accent.Parent = card

local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(0, 8)
accentCorner.Parent = accent

local eyebrow = Instance.new("TextLabel")
eyebrow.Name = "Eyebrow"
eyebrow.BackgroundTransparency = 1
eyebrow.Position = UDim2.fromOffset(20, 8)
eyebrow.Size = UDim2.new(1, -34, 0, 16)
eyebrow.Font = Enum.Font.GothamBold
eyebrow.Text = "SECTOR CONDITION"
eyebrow.TextSize = 11
eyebrow.TextColor3 = Color3.fromRGB(164, 172, 185)
eyebrow.TextXAlignment = Enum.TextXAlignment.Left
eyebrow.Parent = card

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 24)
title.Size = UDim2.new(1, -34, 0, 24)
title.Font = Enum.Font.GothamBlack
title.Text = "OVERCLOCK GRID"
title.TextSize = 19
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

local description = Instance.new("TextLabel")
description.Name = "Description"
description.BackgroundTransparency = 1
description.Position = UDim2.fromOffset(20, 49)
description.Size = UDim2.new(1, -34, 0, 20)
description.Font = Enum.Font.Gotham
description.Text = ""
description.TextSize = 12
description.TextColor3 = Color3.fromRGB(204, 209, 218)
description.TextXAlignment = Enum.TextXAlignment.Left
description.TextTruncate = Enum.TextTruncate.AtEnd
description.Parent = card

local activeId
local hideToken = 0

local function hideCard()
    if not card.Visible then
        return
    end
    hideToken += 1
    local token = hideToken
    TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.055),
    }):Play()
    task.delay(0.19, function()
        if token == hideToken then
            card.Visible = false
            card.BackgroundTransparency = 0.08
            card.Position = UDim2.fromScale(0.5, 0.075)
        end
    end)
end

local function showModifier(data)
    if type(data) ~= "table" or data.Active ~= true then
        activeId = nil
        hideCard()
        return
    end

    local newId = tostring(data.Id or "")
    local isNew = newId ~= activeId
    activeId = newId
    hideToken += 1

    title.Text = tostring(data.Title or "SECTOR CONDITION")
    description.Text = tostring(data.Description or "Combat conditions changed.")

    local color = data.Accent
    if typeof(color) ~= "Color3" then
        color = Color3.fromRGB(120, 140, 255)
    end
    stroke.Color = color
    accent.BackgroundColor3 = color

    card.Visible = true
    if isNew then
        card.BackgroundTransparency = 1
        card.Position = UDim2.fromScale(0.5, 0.055)
        TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.08,
            Position = UDim2.fromScale(0.5, 0.075),
        }):Play()
    else
        card.BackgroundTransparency = 0.08
        card.Position = UDim2.fromScale(0.5, 0.075)
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "SectorModifier" then
        showModifier(payload)
    elseif kind == "Run" and type(payload) == "table" and payload.Active == false then
        activeId = nil
        hideCard()
    end
end)