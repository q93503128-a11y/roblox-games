local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local gui = player:WaitForChild("PlayerGui"):WaitForChild("MonsterFactoryHUD")
local shared = ReplicatedStorage:WaitForChild("Shared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local UIVisualContract = require(shared:WaitForChild("UIVisualContract"))

task.wait(0.2)

gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local existingShell = gui:FindFirstChild("VisualShell")
if existingShell then
    existingShell:Destroy()
end

local existingFx = gui:FindFirstChild("MFFeedbackLayer")
if existingFx then
    existingFx:Destroy()
end

local C = {
    bg = Color3.fromRGB(14, 19, 27),
    panel = Color3.fromRGB(25, 33, 45),
    panel2 = Color3.fromRGB(37, 48, 64),
    panel3 = Color3.fromRGB(47, 60, 78),
    line = Color3.fromRGB(80, 97, 122),
    text = Color3.fromRGB(246, 249, 255),
    muted = Color3.fromRGB(165, 179, 200),
    green = Color3.fromRGB(67, 229, 139),
    cyan = Color3.fromRGB(71, 215, 239),
    gold = Color3.fromRGB(255, 198, 70),
    purple = Color3.fromRGB(177, 111, 255),
    red = Color3.fromRGB(255, 104, 112),
    darkText = Color3.fromRGB(17, 23, 31),
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

local function padding(obj, left, right, top, bottom)
    local p = obj:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = obj
    return p
end

local function gradient(obj, topColor, bottomColor, rotation)
    local old = obj:FindFirstChild("MFGradient")
    if old then
        old:Destroy()
    end
    local g = Instance.new("UIGradient")
    g.Name = "MFGradient"
    g.Color = ColorSequence.new(topColor, bottomColor)
    g.Rotation = rotation or 90
    g.Parent = obj
    return g
end

local function starts(text, prefix)
    return string.sub(text or "", 1, #prefix) == prefix
end

local function contains(text, value)
    return string.find(text or "", value, 1, true) ~= nil
end

local function findButton(test)
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextButton") and test(obj.Text or "") then
            return obj
        end
    end
end

local collect = findButton(function(t) return starts(t, "COLLECT") or starts(t, "AUTO COLLECT") end)
local hatch = findButton(function(t) return contains(t, "HATCH") end)
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
    warn("[MonsterFactory] Visual Refresh 005 could not resolve HUD controls.")
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

local fxLayer = Instance.new("Frame")
fxLayer.Name = "MFFeedbackLayer"
fxLayer.Size = UDim2.fromScale(1, 1)
fxLayer.BackgroundTransparency = 1
fxLayer.ZIndex = 80
fxLayer.Parent = gui

local function makeIcon(parent, slotKey, size, position, zIndex)
    local spec = UIVisualContract.GetSlot(slotKey)
    local holder = Instance.new("Frame")
    holder.Name = "MFIconSlot_" .. slotKey
    holder.Size = UDim2.fromOffset(size or 36, size or 36)
    holder.Position = position or UDim2.fromOffset(0, 0)
    holder.BackgroundColor3 = spec.Color
    holder.BackgroundTransparency = 0.04
    holder.BorderSizePixel = 0
    holder.ZIndex = zIndex or 5
    holder:SetAttribute("MFIconSlot", slotKey)
    holder.Parent = parent
    corner(holder, math.max(8, math.floor((size or 36) * 0.28)))
    stroke(holder, spec.Color:Lerp(Color3.new(1, 1, 1), 0.25), 0.48)

    local image = Instance.new("ImageLabel")
    image.Name = "IconImage"
    image.Size = UDim2.new(1, -8, 1, -8)
    image.Position = UDim2.fromOffset(4, 4)
    image.BackgroundTransparency = 1
    image.Image = spec.Image or ""
    image.Visible = image.Image ~= ""
    image.ScaleType = Enum.ScaleType.Fit
    image.ZIndex = holder.ZIndex + 1
    image.Parent = holder

    local glyph = Instance.new("TextLabel")
    glyph.Name = "FallbackGlyph"
    glyph.Size = UDim2.fromScale(1, 1)
    glyph.BackgroundTransparency = 1
    glyph.Text = spec.Glyph or "•"
    glyph.TextColor3 = C.darkText
    glyph.Font = Enum.Font.GothamBlack
    glyph.TextSize = math.max(13, math.floor((size or 36) * 0.42))
    glyph.Visible = not image.Visible
    glyph.ZIndex = holder.ZIndex + 1
    glyph.Parent = holder

    return holder
end

local function styleButton(button, accent, darkText, options)
    options = options or {}
    button.AutoButtonColor = false
    button.BackgroundColor3 = accent or C.panel2
    button.BackgroundTransparency = accent and 0.01 or 0.03
    button.TextColor3 = darkText and C.darkText or C.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = options.TextSize or 12
    button.TextScaled = false
    button.TextWrapped = true
    button.BorderSizePixel = 0
    button.ZIndex = options.ZIndex or 5
    corner(button, options.Radius or 13)
    stroke(button, accent and accent:Lerp(Color3.new(1, 1, 1), 0.14) or C.line, 0.4)

    local scale = button:FindFirstChild("MFButtonScale") or Instance.new("UIScale")
    scale.Name = "MFButtonScale"
    scale.Scale = 1
    scale.Parent = button

    if not button:GetAttribute("MFVisual005") then
        button:SetAttribute("MFVisual005", true)
        button.MouseEnter:Connect(function()
            if button.Active then
                TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Scale = 1.035 }):Play()
            end
        end)
        button.MouseLeave:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.09, Enum.EasingStyle.Quad), { Scale = 1 }):Play()
        end)
        button.MouseButton1Down:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.045, Enum.EasingStyle.Quad), { Scale = 0.965 }):Play()
        end)
        button.MouseButton1Up:Connect(function()
            TweenService:Create(scale, TweenInfo.new(0.07, Enum.EasingStyle.Back), { Scale = 1 }):Play()
        end)
    end
end

local function decorateNavButton(button, slotKey, accent, darkText)
    styleButton(button, accent, darkText, { TextSize = 12 })
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Size = UDim2.fromOffset(108, accent and 60 or 52)
    padding(button, 46, 8, 0, 0)
    if not button:FindFirstChild("MFNavIcon") then
        local icon = makeIcon(button, slotKey, 32, UDim2.new(0, 8, 0.5, -16), button.ZIndex + 1)
        icon.Name = "MFNavIcon"
    end
end

local brand = Instance.new("Frame")
brand.Name = "Brand"
brand.Position = UDim2.fromOffset(18, 16)
brand.Size = UDim2.fromOffset(174, 45)
brand.BackgroundColor3 = C.bg
brand.BackgroundTransparency = 0.02
brand.ZIndex = 3
brand.Parent = shell
corner(brand, 15)
stroke(brand, C.green, 0.32)

makeIcon(brand, "Monsters", 31, UDim2.fromOffset(7, 7), 4)

local brandText = Instance.new("TextLabel")
brandText.Size = UDim2.new(1, -47, 1, 0)
brandText.Position = UDim2.fromOffset(43, 0)
brandText.BackgroundTransparency = 1
brandText.Text = "MONSTER\nFACTORY"
brandText.TextColor3 = C.text
brandText.Font = Enum.Font.GothamBlack
brandText.TextSize = 12
brandText.TextXAlignment = Enum.TextXAlignment.Left
brandText.ZIndex = 4
brandText.Parent = brand

local statBar = Instance.new("Frame")
statBar.Name = "StatBar"
statBar.AnchorPoint = Vector2.new(0.5, 0)
statBar.Position = UDim2.new(0.5, 0, 0, 15)
statBar.Size = UDim2.fromOffset(786, 52)
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

local statRecords = {}

local function classifyStat(label)
    local t = label.Text or ""
    if starts(t, "Collector") then return "Collector", C.green end
    if starts(t, "Gems") then return "Gems", C.purple end
    if starts(t, "Friends") then return "Friends", C.cyan end
    if contains(t, "/s") then return "Production", C.gold end
    if starts(t, "R") then return "Rebirth", C.red end
    if starts(t, "$") then return "Cash", C.green end
    return "Cash", C.line
end

local function pulseObject(obj, amount)
    local scale = obj:FindFirstChild("MFPulseScale") or Instance.new("UIScale")
    scale.Name = "MFPulseScale"
    scale.Parent = obj
    scale.Scale = 1
    TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Back), { Scale = amount or 1.08 }):Play()
    task.delay(0.09, function()
        if scale.Parent then
            TweenService:Create(scale, TweenInfo.new(0.14, Enum.EasingStyle.Quad), { Scale = 1 }):Play()
        end
    end)
end

if top then
    local labels = {}
    for _, child in ipairs(top:GetChildren()) do
        if child:IsA("TextLabel") then
            table.insert(labels, child)
        end
    end

    local order = { Cash = 1, Collector = 2, Gems = 3, Production = 4, Friends = 5, Rebirth = 6 }
    table.sort(labels, function(a, b)
        local ka = classifyStat(a)
        local kb = classifyStat(b)
        return (order[ka] or 99) < (order[kb] or 99)
    end)

    for _, label in ipairs(labels) do
        local slotKey, accent = classifyStat(label)
        local chip = Instance.new("Frame")
        chip.Name = "Stat_" .. slotKey
        chip.Size = UDim2.fromOffset(124, 48)
        chip.BackgroundColor3 = C.panel
        chip.BackgroundTransparency = 0.01
        chip.BorderSizePixel = 0
        chip.ZIndex = 3
        chip.Parent = statBar
        corner(chip, 14)
        stroke(chip, accent, 0.45)
        gradient(chip, C.panel2, C.panel, 90)

        makeIcon(chip, slotKey, 32, UDim2.fromOffset(7, 8), 4)

        label.Parent = chip
        label.Size = UDim2.new(1, -46, 1, -6)
        label.Position = UDim2.fromOffset(43, 3)
        label.BackgroundTransparency = 1
        label.TextColor3 = C.text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextScaled = false
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 4

        local previousText = label.Text
        label:GetPropertyChangedSignal("Text"):Connect(function()
            if label.Text ~= previousText then
                previousText = label.Text
                pulseObject(chip, 1.055)
            end
        end)

        statRecords[slotKey] = { Label = label, Chip = chip }
    end
    top.Visible = false
end

local function makeDock(name, side)
    local dock = Instance.new("Frame")
    dock.Name = name
    dock.AnchorPoint = Vector2.new(side == "right" and 1 or 0, 0.5)
    dock.Position = side == "right" and UDim2.new(1, -17, 0.51, 0) or UDim2.new(0, 17, 0.51, 0)
    dock.Size = UDim2.fromOffset(124, 330)
    dock.BackgroundColor3 = C.bg
    dock.BackgroundTransparency = 0.025
    dock.BorderSizePixel = 0
    dock.ZIndex = 3
    dock.Parent = shell
    corner(dock, 20)
    stroke(dock, C.line, 0.38)
    gradient(dock, C.panel, C.bg, 90)

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

decorateNavButton(equipBest, "EquipBest")
decorateNavButton(monsters, "Monsters")
decorateNavButton(zones, "Worlds")
decorateNavButton(quests, "Quests")
decorateNavButton(achievements, "Achievements")
for _, button in ipairs({ equipBest, monsters, zones, quests, achievements }) do
    button.Parent = leftDock
end

decorateNavButton(shop, "Shop", C.green, true)
decorateNavButton(rewards, "Rewards", C.gold, true)
decorateNavButton(index, "Index", C.cyan, true)
decorateNavButton(rebirth, "Rebirth", C.red, true)
for _, button in ipairs({ shop, rewards, index, rebirth }) do
    button.Parent = rightDock
end

legacyLeft.Visible = false
legacyRight.Visible = false

local actions = Instance.new("Frame")
actions.Name = "PrimaryActions"
actions.AnchorPoint = Vector2.new(0.5, 1)
actions.Position = UDim2.new(0.5, 0, 1, -18)
actions.Size = UDim2.fromOffset(646, 88)
actions.BackgroundColor3 = C.bg
actions.BackgroundTransparency = 0.015
actions.BorderSizePixel = 0
actions.ZIndex = 3
actions.Parent = shell
corner(actions, 24)
stroke(actions, C.line, 0.28)
gradient(actions, C.panel, C.bg, 90)

local actionLayout = Instance.new("UIListLayout")
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
actionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
actionLayout.Padding = UDim.new(0, 10)
actionLayout.Parent = actions

local actionScale = Instance.new("UIScale")
actionScale.Parent = actions

local function decoratePrimary(button, slotKey, accent)
    button.Parent = actions
    button.Size = UDim2.fromOffset(199, 66)
    styleButton(button, accent, true, { TextSize = 15, Radius = 16 })
    button.TextXAlignment = Enum.TextXAlignment.Left
    padding(button, 62, 10, 0, 0)
    gradient(button, accent:Lerp(Color3.new(1, 1, 1), 0.08), accent:Lerp(Color3.new(0, 0, 0), 0.08), 90)
    if not button:FindFirstChild("MFPrimaryIcon") then
        local icon = makeIcon(button, slotKey, 42, UDim2.new(0, 10, 0.5, -21), button.ZIndex + 1)
        icon.Name = "MFPrimaryIcon"
        icon.BackgroundColor3 = C.bg
        local glyph = icon:FindFirstChild("FallbackGlyph")
        if glyph then
            glyph.TextColor3 = accent
        end
    end
end

decoratePrimary(collect, "Collect", C.green)
decoratePrimary(hatch, "Hatch", C.cyan)
decoratePrimary(upgrade, "Upgrade", C.gold)

local onboarding
for _, obj in ipairs(gui:GetChildren()) do
    if obj:IsA("TextLabel") and obj.Visible and obj.Size.Y.Offset >= 35 then
        onboarding = obj
        break
    end
end

if onboarding then
    onboarding.AnchorPoint = Vector2.new(0.5, 0)
    onboarding.Position = UDim2.new(0.5, 0, 0, 76)
    onboarding.Size = UDim2.fromOffset(470, 39)
    onboarding.BackgroundColor3 = C.panel
    onboarding.BackgroundTransparency = 0.02
    onboarding.TextColor3 = C.text
    onboarding.Font = Enum.Font.GothamBold
    onboarding.TextSize = 13
    onboarding.TextScaled = false
    onboarding.TextWrapped = true
    onboarding.ZIndex = 4
    corner(onboarding, 12)
    stroke(onboarding, C.green, 0.42)
    gradient(onboarding, C.panel2, C.panel, 90)
end

local dimmer = Instance.new("Frame")
dimmer.Name = "ModalDimmer"
dimmer.Size = UDim2.fromScale(1, 1)
dimmer.BackgroundColor3 = Color3.new(0, 0, 0)
dimmer.BackgroundTransparency = 1
dimmer.Visible = false
dimmer.Active = true
dimmer.BorderSizePixel = 0
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

local entrySlot = {
    Shop = "Product",
    Monsters = "Monster",
    Zones = "World",
    Quests = "Quest",
    Rewards = "Reward",
    Achievements = "Achievement",
    Index = "IndexEntry",
}

local windows = {}
local decoratedEntries = setmetatable({}, { __mode = "k" })

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

local function getEntryStatus(windowName, text)
    text = text or ""
    if windowName == "Shop" then
        if contains(text, "DEV") then return "DEV", C.muted end
        return "BUY", C.green
    elseif windowName == "Zones" then
        if starts(text, "CURRENT") then return "HERE", C.green end
        if starts(text, "TRAVEL") then return "GO", C.cyan end
        if starts(text, "UNLOCK") then return "LOCK", C.gold end
    elseif windowName == "Rewards" or windowName == "Quests" or windowName == "Achievements" then
        if contains(text, "CLAIMED") then return "DONE", C.muted end
        if contains(text, "CLAIM") then return "CLAIM", C.gold end
    elseif windowName == "Index" then
        if contains(text, "???") then return "?", C.muted end
        return "FOUND", C.cyan
    end
    return nil, nil
end

local function attachStatusBadge(obj, windowName)
    if not (obj:IsA("TextButton") or obj:IsA("TextLabel")) then return end
    local badge = obj:FindFirstChild("MFEntryBadge")
    if not badge then
        badge = Instance.new("TextLabel")
        badge.Name = "MFEntryBadge"
        badge.AnchorPoint = Vector2.new(1, 0.5)
        badge.Position = UDim2.new(1, -9, 0.5, 0)
        badge.Size = UDim2.fromOffset(56, 22)
        badge.BackgroundTransparency = 0.05
        badge.TextColor3 = C.darkText
        badge.Font = Enum.Font.GothamBlack
        badge.TextSize = 9
        badge.ZIndex = obj.ZIndex + 2
        badge.Parent = obj
        corner(badge, 8)
    end

    local function update()
        local text, color = getEntryStatus(windowName, obj.Text)
        badge.Visible = text ~= nil
        if text then
            badge.Text = text
            badge.BackgroundColor3 = color
        end
    end
    update()
    if not obj:GetAttribute("MFStatusWatch") then
        obj:SetAttribute("MFStatusWatch", true)
        obj:GetPropertyChangedSignal("Text"):Connect(update)
    end
end

local function decorateScrollEntry(windowName, obj, accent)
    if decoratedEntries[obj] then return end
    if not obj.Parent or not obj.Parent:IsA("ScrollingFrame") then return end
    decoratedEntries[obj] = true

    local slotKey = entrySlot[windowName] or "IndexEntry"

    if obj:IsA("TextButton") then
        styleButton(obj, C.panel2, false, { TextSize = 13, Radius = 14, ZIndex = 24 })
        obj.TextXAlignment = Enum.TextXAlignment.Left
        obj.TextYAlignment = Enum.TextYAlignment.Center
        padding(obj, 58, 74, 5, 5)
        gradient(obj, C.panel3, C.panel2, 90)
        makeIcon(obj, slotKey, 38, UDim2.new(0, 10, 0.5, -19), 25)
        attachStatusBadge(obj, windowName)
    elseif obj:IsA("TextLabel") then
        obj.BackgroundColor3 = C.panel2
        obj.BackgroundTransparency = 0.02
        obj.BorderSizePixel = 0
        obj.TextColor3 = C.text
        obj.TextSize = 13
        obj.TextScaled = false
        obj.TextWrapped = true
        obj.TextXAlignment = Enum.TextXAlignment.Left
        obj.ZIndex = 24
        corner(obj, 14)
        stroke(obj, accent, 0.6)
        padding(obj, 56, 70, 4, 4)
        gradient(obj, C.panel3, C.panel2, 90)
        makeIcon(obj, slotKey, 36, UDim2.new(0, 10, 0.5, -18), 25)
        attachStatusBadge(obj, windowName)
    elseif obj:IsA("Frame") then
        obj.BackgroundColor3 = C.panel
        obj.BackgroundTransparency = 0.01
        obj.BorderSizePixel = 0
        obj.ZIndex = 24
        corner(obj, 15)
        stroke(obj, accent, 0.55)
        gradient(obj, C.panel2, C.panel, 90)
        makeIcon(obj, slotKey, 40, UDim2.fromOffset(8, 8), 25)

        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("TextLabel") then
                child.TextScaled = false
                child.TextSize = 13
                child.TextColor3 = C.text
                child.TextXAlignment = Enum.TextXAlignment.Left
                child.TextYAlignment = Enum.TextYAlignment.Top
                child.Position = UDim2.fromOffset(55, 7)
                child.Size = UDim2.new(1, -62, 0, 72)
                child.ZIndex = 25
            elseif child:IsA("TextButton") then
                local buttonAccent = accent
                if child.Text == "UNEQUIP" then buttonAccent = C.red end
                if child.Text == "FUSE" then buttonAccent = C.gold end
                styleButton(child, buttonAccent, true, { TextSize = 10, Radius = 9, ZIndex = 25 })
            end
        end
    end
end

local function styleModal(window, name, accent)
    window.BackgroundColor3 = C.bg
    window.BackgroundTransparency = 0.005
    window.BorderSizePixel = 0
    window.Size = UDim2.new(0.82, 0, 0.76, 0)
    corner(window, 22)
    stroke(window, accent, 0.26, 2)
    gradient(window, C.panel, C.bg, 90)
    bringAboveDimmer(window)

    local contract = UIVisualContract.GetWindow(name)
    if contract and not window:FindFirstChild("MFHeaderIcon") then
        local icon = makeIcon(window, contract.Icon, 38, UDim2.fromOffset(13, 10), 25)
        icon.Name = "MFHeaderIcon"

        local subtitle = Instance.new("TextLabel")
        subtitle.Name = "MFHeaderSubtitle"
        subtitle.Position = UDim2.fromOffset(60, 37)
        subtitle.Size = UDim2.new(1, -132, 0, 18)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = contract.Subtitle
        subtitle.TextColor3 = C.muted
        subtitle.Font = Enum.Font.GothamMedium
        subtitle.TextSize = 10
        subtitle.TextXAlignment = Enum.TextXAlignment.Left
        subtitle.ZIndex = 25
        subtitle.Parent = window
    end

    local strip = window:FindFirstChild("MFAccentStrip") or Instance.new("Frame")
    strip.Name = "MFAccentStrip"
    strip.Size = UDim2.new(1, -28, 0, 3)
    strip.Position = UDim2.fromOffset(14, 58)
    strip.BackgroundColor3 = accent
    strip.BorderSizePixel = 0
    strip.ZIndex = 24
    strip.Parent = window
    corner(strip, 2)

    local function styleDesc(obj)
        if obj:IsA("TextButton") then
            if obj.Text == "X" then
                obj.Size = UDim2.fromOffset(38, 34)
                obj.Text = "×"
                styleButton(obj, C.red, true, { TextSize = 17, Radius = 10, ZIndex = 25 })
            elseif not (obj.Parent and obj.Parent:IsA("ScrollingFrame")) then
                local buttonAccent = C.panel2
                local dark = false
                if obj.Text == "EQUIP" then buttonAccent, dark = C.purple, true end
                if obj.Text == "UNEQUIP" then buttonAccent, dark = C.red, true end
                if obj.Text == "FUSE" then buttonAccent, dark = C.gold, true end
                styleButton(obj, buttonAccent, dark, { TextSize = 11, Radius = 10, ZIndex = 25 })
            end
            obj.ZIndex = math.max(obj.ZIndex, 24)
        elseif obj:IsA("TextLabel") then
            obj.TextColor3 = C.text
            obj.ZIndex = math.max(obj.ZIndex, 24)
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
        end

        if obj.Parent and obj.Parent:IsA("ScrollingFrame") then
            decorateScrollEntry(name, obj, accent)
        end
    end

    for _, d in ipairs(window:GetDescendants()) do
        styleDesc(d)
    end

    window.DescendantAdded:Connect(function(d)
        task.defer(styleDesc, d)
    end)

    for _, child in ipairs(window:GetChildren()) do
        if child:IsA("TextLabel") and child.Name ~= "MFHeaderSubtitle" and child.Position.Y.Offset <= 16 and child.Size.Y.Offset >= 35 then
            child.Position = UDim2.fromOffset(58, 7)
            child.Size = UDim2.new(1, -126, 0, 32)
            child.TextXAlignment = Enum.TextXAlignment.Left
            child.Font = Enum.Font.GothamBlack
            child.TextSize = 20
            child.ZIndex = 25
            break
        end
    end
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

    if anyOpen then
        dimmer.Visible = true
    end
    TweenService:Create(dimmer, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {
        BackgroundTransparency = anyOpen and 0.34 or 1,
    }):Play()
    TweenService:Create(blur, TweenInfo.new(0.14, Enum.EasingStyle.Quad), {
        Size = anyOpen and 9 or 0,
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
        styleModal(window, name, accent)
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
        if obj:IsA("Frame") and obj ~= legacyLeft and obj ~= legacyRight and obj ~= top and obj ~= dimmer and obj ~= fxLayer then
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
    offer.Position = UDim2.new(1, -17, 1, -119)
    offer.Size = UDim2.fromOffset(352, 132)
    offer.BackgroundColor3 = C.bg
    offer.BackgroundTransparency = 0.01
    offer.BorderSizePixel = 0
    offer.ZIndex = 15
    corner(offer, 19)
    stroke(offer, C.gold, 0.25, 2)
    gradient(offer, C.panel2, C.bg, 90)

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.fromOffset(88, 21)
    badge.Position = UDim2.fromOffset(12, 8)
    badge.BackgroundColor3 = C.gold
    badge.Text = "RECOMMENDED"
    badge.TextColor3 = C.darkText
    badge.Font = Enum.Font.GothamBlack
    badge.TextSize = 8
    badge.ZIndex = 17
    badge.Parent = offer
    corner(badge, 7)

    for _, d in ipairs(offer:GetDescendants()) do
        if d:IsA("TextButton") then
            local highlighted = d.Text == "VIEW OFFER"
            styleButton(d, highlighted and C.gold or C.panel2, highlighted, { TextSize = 11, ZIndex = 16 })
        elseif d:IsA("TextLabel") and d ~= badge then
            d.TextColor3 = C.text
            d.TextScaled = false
            d.TextSize = 12
            d.ZIndex = 16
        end
    end
end

local function buttonCenter(button)
    return button.AbsolutePosition + button.AbsoluteSize / 2
end

local function floatText(button, text, color, rise)
    local center = buttonCenter(button)
    local label = Instance.new("TextLabel")
    label.AnchorPoint = Vector2.new(0.5, 0.5)
    label.Position = UDim2.fromOffset(center.X, center.Y - button.AbsoluteSize.Y * 0.55)
    label.Size = UDim2.fromOffset(230, 38)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeColor3 = Color3.fromRGB(12, 17, 24)
    label.TextStrokeTransparency = 0.25
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 19
    label.ZIndex = 85
    label.Parent = fxLayer

    local scale = Instance.new("UIScale")
    scale.Scale = 0.72
    scale.Parent = label
    TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Back), { Scale = 1 }):Play()
    TweenService:Create(label, TweenInfo.new(0.72, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromOffset(center.X, center.Y - (rise or 80)),
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    }):Play()
    task.delay(0.76, function()
        if label.Parent then label:Destroy() end
    end)
end

local function burst(button, color)
    local center = buttonCenter(button)
    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.fromOffset(center.X, center.Y)
    ring.Size = UDim2.fromOffset(26, 26)
    ring.BackgroundTransparency = 1
    ring.ZIndex = 82
    ring.Parent = fxLayer
    corner(ring, 999)
    local s = stroke(ring, color, 0.05, 3)

    TweenService:Create(ring, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {
        Size = UDim2.fromOffset(110, 110),
    }):Play()
    TweenService:Create(s, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {
        Transparency = 1,
        Thickness = 1,
    }):Play()
    task.delay(0.35, function()
        if ring.Parent then ring:Destroy() end
    end)
end

local function actionPress(button, color)
    pulseObject(button, 1.055)
    burst(button, color)
end

collect.Activated:Connect(function() actionPress(collect, C.green) end)
hatch.Activated:Connect(function() actionPress(hatch, C.cyan) end)
upgrade.Activated:Connect(function() actionPress(upgrade, C.gold) end)

local feedbackBannerToken = 0
local function feedbackBanner(text, color)
    feedbackBannerToken += 1
    local token = feedbackBannerToken

    local old = fxLayer:FindFirstChild("MFFeedbackBanner")
    if old then old:Destroy() end

    local banner = Instance.new("TextLabel")
    banner.Name = "MFFeedbackBanner"
    banner.AnchorPoint = Vector2.new(0.5, 0)
    banner.Position = UDim2.new(0.5, 0, 0.29, 0)
    banner.Size = UDim2.fromOffset(300, 46)
    banner.BackgroundColor3 = C.bg
    banner.BackgroundTransparency = 0.04
    banner.Text = text
    banner.TextColor3 = color
    banner.Font = Enum.Font.GothamBlack
    banner.TextSize = 17
    banner.ZIndex = 86
    banner.Parent = fxLayer
    corner(banner, 14)
    stroke(banner, color, 0.15, 2)

    local scale = Instance.new("UIScale")
    scale.Scale = 0.72
    scale.Parent = banner
    TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Back), { Scale = 1 }):Play()

    task.delay(1.0, function()
        if token ~= feedbackBannerToken or not banner.Parent then return end
        TweenService:Create(banner, TweenInfo.new(0.18), {
            BackgroundTransparency = 1,
            TextTransparency = 1,
        }):Play()
        task.delay(0.2, function()
            if banner.Parent then banner:Destroy() end
        end)
    end)
end

local lastEconomy
local lastHatchCount

local stateUpdated = remotes:FindFirstChild("StateUpdated")
if stateUpdated then
    stateUpdated.OnClientEvent:Connect(function(state)
        if type(state) ~= "table" then return end
        if lastEconomy then
            local oldCash = tonumber(lastEconomy.Cash) or 0
            local newCash = tonumber(state.Cash) or 0
            local oldPending = tonumber(lastEconomy.PendingCash) or 0
            local newPending = tonumber(state.PendingCash) or 0
            local oldLevel = tonumber(lastEconomy.GeneratorLevel) or 1
            local newLevel = tonumber(state.GeneratorLevel) or 1
            local oldProd = tonumber(lastEconomy.ProductionPerSecond) or 0
            local newProd = tonumber(state.ProductionPerSecond) or 0

            if newLevel > oldLevel then
                floatText(upgrade, "GENERATOR LV." .. tostring(newLevel), C.gold, 92)
                feedbackBanner("PRODUCTION UPGRADED", C.gold)
            elseif newCash > oldCash and newPending < oldPending then
                floatText(collect, "+$" .. tostring(math.floor(newCash - oldCash)), C.green, 90)
            elseif newProd > oldProd then
                floatText(upgrade, "+" .. tostring(math.floor(newProd - oldProd)) .. "/s", C.gold, 82)
            end
        end
        lastEconomy = state
    end)
end

local monsterStateUpdated = remotes:FindFirstChild("MonsterStateUpdated")
if monsterStateUpdated then
    monsterStateUpdated.OnClientEvent:Connect(function(state)
        if type(state) ~= "table" then return end
        local count = tonumber(state.HatchCount) or 0
        if lastHatchCount ~= nil and count > lastHatchCount then
            floatText(hatch, "NEW WORKER!", C.cyan, 94)
            feedbackBanner("MONSTER HATCHED", C.cyan)
        end
        lastHatchCount = count
    end)
end

local toastRemote = remotes:FindFirstChild("Toast")
if toastRemote then
    toastRemote.OnClientEvent:Connect(function(message)
        if type(message) ~= "string" then return end
        if starts(message, "Unlocked ") then
            feedbackBanner("NEW WORLD UNLOCKED", C.cyan)
        elseif contains(message, "Not enough") then
            feedbackBanner("NOT ENOUGH CASH", C.red)
        elseif contains(message, "Shiny") or contains(message, "SHINY") then
            feedbackBanner("SHINY CREATED", C.gold)
        end
    end)
end

local function applyResponsive()
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local w, h = viewport.X, viewport.Y

    local stat = 1
    local side = 1
    local action = 1

    brand.Visible = w >= 1050

    if w <= 560 then
        stat = math.clamp((w - 12) / 786, 0.42, 0.65)
        side = 0.62
        action = math.clamp((w - 14) / 646, 0.52, 0.73)
        leftDock.Position = UDim2.new(0, 5, 0.52, 0)
        rightDock.Position = UDim2.new(1, -5, 0.52, 0)
        actions.Position = UDim2.new(0.5, 0, 1, -8)
        statBar.Position = UDim2.new(0.5, 0, 0, 8)
        if onboarding then
            onboarding.Size = UDim2.new(0.70, 0, 0, 34)
            onboarding.Position = UDim2.new(0.5, 0, 0, 42)
            onboarding.TextSize = 10
        end
        for _, window in ipairs(windows) do
            window.Size = UDim2.new(0.94, 0, 0.80, 0)
        end
    elseif w <= 900 then
        stat = 0.77
        side = 0.79
        action = 0.79
        leftDock.Position = UDim2.new(0, 9, 0.52, 0)
        rightDock.Position = UDim2.new(1, -9, 0.52, 0)
        actions.Position = UDim2.new(0.5, 0, 1, -12)
        statBar.Position = UDim2.new(0.5, 0, 0, 11)
        if onboarding then
            onboarding.Size = UDim2.fromOffset(396, 36)
            onboarding.Position = UDim2.new(0.5, 0, 0, 60)
            onboarding.TextSize = 12
        end
        for _, window in ipairs(windows) do
            window.Size = UDim2.new(0.88, 0, 0.78, 0)
        end
    else
        leftDock.Position = UDim2.new(0, 17, 0.51, 0)
        rightDock.Position = UDim2.new(1, -17, 0.51, 0)
        actions.Position = UDim2.new(0.5, 0, 1, -18)
        statBar.Position = UDim2.new(0.5, 0, 0, 15)
        if onboarding then
            onboarding.Size = UDim2.fromOffset(470, 39)
            onboarding.Position = UDim2.new(0.5, 0, 0, 76)
            onboarding.TextSize = 13
        end
        for _, window in ipairs(windows) do
            window.Size = UDim2.new(0.82, 0, 0.76, 0)
        end
    end

    if h < 620 then
        side *= 0.86
        action *= 0.88
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

print("[MonsterFactory] Visual Refresh 005 active.")
