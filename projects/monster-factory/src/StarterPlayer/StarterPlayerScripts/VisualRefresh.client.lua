local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local gui = player:WaitForChild("PlayerGui"):WaitForChild("MonsterFactoryHUD")

task.wait(0.2)

local existingShell = gui:FindFirstChild("VisualShell")
if existingShell then
    existingShell:Destroy()
end

local C = {
    bg = Color3.fromRGB(16, 21, 29),
    panel = Color3.fromRGB(26, 34, 45),
    panel2 = Color3.fromRGB(38, 49, 64),
    line = Color3.fromRGB(80, 96, 120),
    text = Color3.fromRGB(244, 248, 255),
    muted = Color3.fromRGB(163, 177, 198),
    green = Color3.fromRGB(71, 230, 137),
    cyan = Color3.fromRGB(69, 216, 239),
    gold = Color3.fromRGB(255, 197, 70),
    purple = Color3.fromRGB(174, 109, 255),
    red = Color3.fromRGB(255, 99, 108),
    darkText = Color3.fromRGB(18, 24, 32),
}

local function corner(obj, radius)
    local old = obj:FindFirstChildOfClass("UICorner")
    if old then
        old.CornerRadius = UDim.new(0, radius or 12)
        return old
    end
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius or 12)
    x.Parent = obj
    return x
end

local function stroke(obj, color, transparency, thickness)
    local s = obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    s.Color = color or C.line
    s.Transparency = transparency or 0.3
    s.Thickness = thickness or 1
    s.Parent = obj
    return s
end

local function starts(text, prefix)
    return string.sub(text or "", 1, #prefix) == prefix
end

local function findButton(test)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") and test(obj.Text or "") then
            return obj
        end
    end
end

local collect = findButton(function(t) return starts(t, "COLLECT") or starts(t, "AUTO COLLECT") end)
local hatch = findButton(function(t) return string.find(t, "HATCH", 1, true) ~= nil end)
local upgrade = findButton(function(t) return starts(t, "UPGRADE") end)
local equipBest = findButton(function(t) return t == "EQUIP BEST" end)
local monsters = findButton(function(t) return t == "MONSTERS" end)
local zones = findButton(function(t) return t == "ZONES" end)
local quests = findButton(function(t) return t == "QUESTS" end)
local achievements = findButton(function(t) return t == "ACHIEVEMENTS" end)
local shop = findButton(function(t) return t == "SHOP" end)
local rewards = findButton(function(t) return t == "REWARDS" end)
local index = findButton(function(t) return t == "INDEX" end)
local rebirth = findButton(function(t) return starts(t, "REBIRTH") end)

if not (collect and hatch and upgrade and equipBest and monsters and zones and quests and achievements and shop and rewards and index and rebirth) then
    warn("[MonsterFactory] Visual Refresh 002 could not resolve HUD controls.")
    return
end

local legacyLeft = collect.Parent
local legacyRight = shop.Parent

local top
for _, obj in ipairs(gui:GetChildren()) do
    if obj:IsA("Frame") then
        local labels = 0
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("TextLabel") then
                labels += 1
            end
        end
        if labels >= 6 then
            top = obj
            break
        end
    end
end

local shell = Instance.new("Frame")
shell.Name = "VisualShell"
shell.BackgroundTransparency = 1
shell.Size = UDim2.fromScale(1, 1)
shell.ZIndex = 2
shell.Parent = gui

local brand = Instance.new("TextLabel")
brand.Name = "Brand"
brand.Position = UDim2.fromOffset(18, 17)
brand.Size = UDim2.fromOffset(154, 40)
brand.BackgroundColor3 = C.bg
brand.BackgroundTransparency = 0.04
brand.Text = "MONSTER FACTORY"
brand.TextColor3 = C.text
brand.Font = Enum.Font.GothamBlack
brand.TextSize = 13
brand.ZIndex = 3
brand.Parent = shell
corner(brand, 14)
stroke(brand, C.green, 0.3)

local statBar = Instance.new("Frame")
statBar.Name = "StatBar"
statBar.AnchorPoint = Vector2.new(0.5, 0)
statBar.Position = UDim2.new(0.5, 0, 0, 16)
statBar.Size = UDim2.fromOffset(770, 50)
statBar.BackgroundTransparency = 1
statBar.ZIndex = 3
statBar.Parent = shell

local statLayout = Instance.new("UIListLayout")
statLayout.FillDirection = Enum.FillDirection.Horizontal
statLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
statLayout.VerticalAlignment = Enum.VerticalAlignment.Center
statLayout.Padding = UDim.new(0, 7)
statLayout.Parent = statBar

local statScale = Instance.new("UIScale")
statScale.Parent = statBar

local function classifyStat(label)
    local t = label.Text or ""
    if starts(t, "Collector") then return "collector", "◎", C.green end
    if starts(t, "Gems") then return "gems", "◆", C.purple end
    if starts(t, "Friends") then return "friends", "+", C.cyan end
    if string.find(t, "/s", 1, true) then return "production", "↑", C.gold end
    if starts(t, "R") then return "rebirth", "R", C.red end
    if starts(t, "$") then return "cash", "$", C.green end
    return "stat", "•", C.line
end

if top then
    local labels = {}
    for _, child in ipairs(top:GetChildren()) do
        if child:IsA("TextLabel") then
            table.insert(labels, child)
        end
    end

    table.sort(labels, function(a, b)
        local order = { cash = 1, collector = 2, gems = 3, production = 4, friends = 5, rebirth = 6, stat = 7 }
        local ka = classifyStat(a)
        local kb = classifyStat(b)
        return (order[ka] or 99) < (order[kb] or 99)
    end)

    for _, label in ipairs(labels) do
        local _, glyph, accent = classifyStat(label)
        local chip = Instance.new("Frame")
        chip.Size = UDim2.fromOffset(122, 46)
        chip.BackgroundColor3 = C.panel
        chip.BackgroundTransparency = 0.02
        chip.ZIndex = 3
        chip.Parent = statBar
        corner(chip, 14)
        stroke(chip, accent, 0.42)

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.fromOffset(31, 31)
        icon.Position = UDim2.fromOffset(7, 7)
        icon.BackgroundColor3 = accent
        icon.BackgroundTransparency = 0.05
        icon.Text = glyph
        icon.TextColor3 = C.darkText
        icon.Font = Enum.Font.GothamBlack
        icon.TextSize = 16
        icon.ZIndex = 4
        icon.Parent = chip
        corner(icon, 10)

        label.Parent = chip
        label.Size = UDim2.new(1, -44, 1, -6)
        label.Position = UDim2.fromOffset(41, 3)
        label.BackgroundTransparency = 1
        label.TextColor3 = C.text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextScaled = false
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 4
    end
    top.Visible = false
end

local function styleButton(button, accent, darkText, height)
    button.AutoButtonColor = false
    button.BackgroundColor3 = accent or C.panel2
    button.BackgroundTransparency = accent and 0.02 or 0.04
    button.TextColor3 = darkText and C.darkText or C.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.TextScaled = false
    button.TextWrapped = true
    button.ZIndex = 4
    corner(button, 13)
    stroke(button, accent and accent:Lerp(Color3.new(1,1,1), 0.15) or C.line, 0.38)

    local scale = button:FindFirstChild("MFButtonScale") or Instance.new("UIScale")
    scale.Name = "MFButtonScale"
    scale.Scale = 1
    scale.Parent = button

    if not button:GetAttribute("MFVisual002") then
        button:SetAttribute("MFVisual002", true)
        button.MouseEnter:Connect(function()
            if button.Active then
                TweenService:Create(scale, TweenInfo.new(0.09), { Scale = 1.045 }):Play()
            end
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.09), { Scale = 1 }):Play()
        end)
        button.MouseButton1Down:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.05), { Scale = 0.965 }):Play()
        end)
        button.MouseButton1Up:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.07), { Scale = 1.02 }):Play()
        end)
    end

    if height then
        button.Size = UDim2.fromOffset(92, height)
    end
end

local function makeDock(name, side)
    local dock = Instance.new("Frame")
    dock.Name = name
    dock.AnchorPoint = Vector2.new(side == "right" and 1 or 0, 0.5)
    dock.Position = side == "right" and UDim2.new(1, -18, 0.51, 0) or UDim2.new(0, 18, 0.51, 0)
    dock.Size = UDim2.fromOffset(108, 306)
    dock.BackgroundColor3 = C.bg
    dock.BackgroundTransparency = 0.04
    dock.ZIndex = 3
    dock.Parent = shell
    corner(dock, 19)
    stroke(dock, C.line, 0.35)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = dock

    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 7)
    layout.Parent = dock

    local scale = Instance.new("UIScale")
    scale.Parent = dock
    return dock, scale
end

local leftDock, leftScale = makeDock("CollectionDock", "left")
local rightDock, rightScale = makeDock("ProgressDock", "right")

for _, button in ipairs({ equipBest, monsters, zones, quests, achievements }) do
    button.Parent = leftDock
    styleButton(button, nil, false, 49)
end

for _, pair in ipairs({
    { shop, C.green },
    { rewards, C.gold },
    { index, C.cyan },
    { rebirth, C.red },
}) do
    local button, accent = pair[1], pair[2]
    button.Parent = rightDock
    styleButton(button, accent, true, 58)
end

legacyLeft.Visible = false
legacyRight.Visible = false

local actions = Instance.new("Frame")
actions.Name = "PrimaryActions"
actions.AnchorPoint = Vector2.new(0.5, 1)
actions.Position = UDim2.new(0.5, 0, 1, -20)
actions.Size = UDim2.fromOffset(628, 82)
actions.BackgroundColor3 = C.bg
actions.BackgroundTransparency = 0.02
actions.ZIndex = 3
actions.Parent = shell
corner(actions, 22)
stroke(actions, C.line, 0.26, 1)

local actionLayout = Instance.new("UIListLayout")
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
actionLayout.Padding = UDim.new(0, 10)
actionLayout.Parent = actions

local actionScale = Instance.new("UIScale")
actionScale.Parent = actions

for _, pair in ipairs({
    { collect, C.green },
    { hatch, C.cyan },
    { upgrade, C.gold },
}) do
    local button, accent = pair[1], pair[2]
    button.Parent = actions
    button.Size = UDim2.fromOffset(194, 61)
    styleButton(button, accent, true)
    button.TextSize = 15
end

local onboarding
for _, obj in ipairs(gui:GetChildren()) do
    if obj:IsA("TextLabel") and obj ~= brand then
        onboarding = obj
        break
    end
end

if onboarding then
    onboarding.AnchorPoint = Vector2.new(0.5, 0)
    onboarding.Position = UDim2.new(0.5, 0, 0, 76)
    onboarding.Size = UDim2.fromOffset(460, 38)
    onboarding.BackgroundColor3 = C.panel
    onboarding.BackgroundTransparency = 0.03
    onboarding.TextColor3 = C.text
    onboarding.Font = Enum.Font.GothamBold
    onboarding.TextSize = 13
    onboarding.TextScaled = false
    onboarding.TextWrapped = true
    onboarding.ZIndex = 4
    corner(onboarding, 12)
    stroke(onboarding, C.green, 0.38)
end

local dimmer = Instance.new("Frame")
dimmer.Name = "ModalDimmer"
dimmer.Size = UDim2.fromScale(1, 1)
dimmer.BackgroundColor3 = Color3.new(0, 0, 0)
dimmer.BackgroundTransparency = 1
dimmer.Visible = false
dimmer.Active = true
dimmer.ZIndex = 20
dimmer.Parent = gui

local blur = Lighting:FindFirstChild("MonsterFactoryModalBlur") or Instance.new("BlurEffect")
blur.Name = "MonsterFactoryModalBlur"
blur.Size = 0
blur.Parent = Lighting

local windowAccent = {
    Shop = C.green,
    Monsters = C.purple,
    Zones = C.cyan,
    Quests = C.gold,
    Rewards = C.gold,
    Achievements = C.purple,
    Index = C.cyan,
}

local windows = {}

local function bringAboveDimmer(obj)
    if obj:IsA("GuiObject") then
        obj.ZIndex = math.max(obj.ZIndex, 22)
    end
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("GuiObject") then
            d.ZIndex = math.max(d.ZIndex, 23)
        end
    end
end

local function styleModal(window, accent)
    window.BackgroundColor3 = C.bg
    window.BackgroundTransparency = 0.01
    window.Size = UDim2.new(0.82, 0, 0.76, 0)
    corner(window, 21)
    stroke(window, accent, 0.28, 2)
    bringAboveDimmer(window)

    local strip = window:FindFirstChild("MFAccentStrip") or Instance.new("Frame")
    strip.Name = "MFAccentStrip"
    strip.Size = UDim2.new(1, -28, 0, 4)
    strip.Position = UDim2.fromOffset(14, 54)
    strip.BackgroundColor3 = accent
    strip.BorderSizePixel = 0
    strip.ZIndex = 24
    strip.Parent = window
    corner(strip, 2)

    local function styleDesc(obj)
        if obj:IsA("TextButton") then
            if obj.Text == "X" then
                obj.Size = UDim2.fromOffset(38, 34)
                styleButton(obj, C.red, true)
            else
                styleButton(obj, C.panel2, false)
            end
            obj.ZIndex = 24
        elseif obj:IsA("TextLabel") then
            obj.TextColor3 = C.text
            obj.ZIndex = 24
            if obj.TextScaled then
                obj.TextScaled = false
                obj.TextSize = 14
            end
        elseif obj:IsA("ScrollingFrame") then
            obj.BackgroundTransparency = 1
            obj.BorderSizePixel = 0
            obj.ScrollBarThickness = 5
            obj.ScrollBarImageColor3 = accent
            obj.ZIndex = 23
        elseif obj:IsA("Frame") and obj.Parent and obj.Parent:IsA("ScrollingFrame") then
            obj.BackgroundColor3 = C.panel
            obj.BackgroundTransparency = 0.03
            obj.ZIndex = 24
            corner(obj, 13)
            stroke(obj, C.line, 0.45)
        end
    end

    for _, d in ipairs(window:GetDescendants()) do
        styleDesc(d)
    end
    window.DescendantAdded:Connect(function(d)
        task.defer(styleDesc, d)
    end)
end

local modalBusy = false
local function refreshModalState(source)
    if modalBusy then return end
    modalBusy = true

    local anyOpen = false
    for _, window in ipairs(windows) do
        if source and source.Visible and window ~= source and window.Visible then
            window.Visible = false
        end
        if window.Visible then
            anyOpen = true
        end
    end

    dimmer.Visible = anyOpen
    TweenService:Create(dimmer, TweenInfo.new(0.14), {
        BackgroundTransparency = anyOpen and 0.38 or 1,
    }):Play()
    TweenService:Create(blur, TweenInfo.new(0.14), {
        Size = anyOpen and 8 or 0,
    }):Play()

    if not anyOpen then
        task.delay(0.15, function()
            if blur.Size <= 0.1 then
                dimmer.Visible = false
            end
        end)
    end
    modalBusy = false
end

for name, accent in pairs(windowAccent) do
    local window = gui:FindFirstChild(name)
    if window and window:IsA("Frame") then
        table.insert(windows, window)
        styleModal(window, accent)
        window:GetPropertyChangedSignal("Visible"):Connect(function()
            refreshModalState(window)
        end)
    end
end

dimmer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        for _, window in ipairs(windows) do
            window.Visible = false
        end
        refreshModalState()
    end
end)

local function findOffer()
    for _, obj in ipairs(gui:GetChildren()) do
        if obj:IsA("Frame") and obj ~= legacyLeft and obj ~= legacyRight and obj ~= top and obj ~= dimmer then
            local hasView, hasNo = false, false
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == "VIEW OFFER" then hasView = true end
                if d:IsA("TextButton") and d.Text == "NO THANKS" then hasNo = true end
            end
            if hasView and hasNo then return obj end
        end
    end
end

local offer = findOffer()
if offer then
    offer.AnchorPoint = Vector2.new(1, 1)
    offer.Position = UDim2.new(1, -18, 1, -114)
    offer.Size = UDim2.fromOffset(336, 128)
    offer.BackgroundColor3 = C.bg
    offer.BackgroundTransparency = 0.02
    offer.ZIndex = 15
    corner(offer, 18)
    stroke(offer, C.gold, 0.28)
    for _, d in ipairs(offer:GetDescendants()) do
        if d:IsA("TextButton") then
            styleButton(d, d.Text == "VIEW OFFER" and C.gold or C.panel2, d.Text == "VIEW OFFER")
            d.ZIndex = 16
        elseif d:IsA("TextLabel") then
            d.TextColor3 = C.text
            d.TextScaled = false
            d.TextSize = 13
            d.ZIndex = 16
        end
    end
end

local function applyResponsive()
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local w, h = viewport.X, viewport.Y

    local stat = 1
    local side = 1
    local action = 1

    brand.Visible = w >= 980

    if w <= 560 then
        stat = math.clamp((w - 12) / 770, 0.43, 0.67)
        side = 0.66
        action = math.clamp((w - 14) / 628, 0.54, 0.76)
        leftDock.Position = UDim2.new(0, 6, 0.52, 0)
        rightDock.Position = UDim2.new(1, -6, 0.52, 0)
        actions.Position = UDim2.new(0.5, 0, 1, -9)
        statBar.Position = UDim2.new(0.5, 0, 0, 9)
        if onboarding then
            onboarding.Size = UDim2.new(0.70, 0, 0, 34)
            onboarding.Position = UDim2.new(0.5, 0, 0, 43)
            onboarding.TextSize = 10
        end
    elseif w <= 900 then
        stat = 0.78
        side = 0.82
        action = 0.80
        leftDock.Position = UDim2.new(0, 10, 0.52, 0)
        rightDock.Position = UDim2.new(1, -10, 0.52, 0)
        actions.Position = UDim2.new(0.5, 0, 1, -13)
        statBar.Position = UDim2.new(0.5, 0, 0, 12)
        if onboarding then
            onboarding.Size = UDim2.fromOffset(390, 36)
            onboarding.Position = UDim2.new(0.5, 0, 0, 60)
            onboarding.TextSize = 12
        end
    else
        leftDock.Position = UDim2.new(0, 18, 0.51, 0)
        rightDock.Position = UDim2.new(1, -18, 0.51, 0)
        actions.Position = UDim2.new(0.5, 0, 1, -20)
        statBar.Position = UDim2.new(0.5, 0, 0, 16)
        if onboarding then
            onboarding.Size = UDim2.fromOffset(460, 38)
            onboarding.Position = UDim2.new(0.5, 0, 0, 76)
            onboarding.TextSize = 13
        end
    end

    if h < 620 then
        side *= 0.88
        action *= 0.90
    end

    statScale.Scale = stat
    leftScale.Scale = side
    rightScale.Scale = side
    actionScale.Scale = action
end

if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsive)
end
applyResponsive()

print("[MonsterFactory] Visual Refresh 002 active.")
