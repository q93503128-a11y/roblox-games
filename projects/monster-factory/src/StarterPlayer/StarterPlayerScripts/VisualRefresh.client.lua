local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local gui = player:WaitForChild("PlayerGui"):WaitForChild("MonsterFactoryHUD")

task.wait(0.35)

local C = {
    bg = Color3.fromRGB(18, 23, 31),
    panel = Color3.fromRGB(31, 39, 51),
    panel2 = Color3.fromRGB(42, 53, 69),
    line = Color3.fromRGB(84, 101, 126),
    text = Color3.fromRGB(244, 248, 255),
    muted = Color3.fromRGB(166, 180, 201),
    green = Color3.fromRGB(74, 224, 139),
    cyan = Color3.fromRGB(77, 221, 236),
    gold = Color3.fromRGB(255, 198, 73),
    purple = Color3.fromRGB(174, 113, 255),
    red = Color3.fromRGB(255, 105, 112),
    dark = Color3.fromRGB(16, 23, 31),
}

local function corner(obj, radius)
    if obj:FindFirstChildOfClass("UICorner") then
        return
    end
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius or 12)
    x.Parent = obj
end

local function stroke(obj, color, transparency)
    local s = obj:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
    s.Color = color or C.line
    s.Thickness = 1
    s.Transparency = transparency or 0.25
    s.Parent = obj
end

local function styleButton(b, accent, darkText)
    b.AutoButtonColor = false
    b.BackgroundColor3 = accent or C.panel2
    b.TextColor3 = darkText and C.dark or C.text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextScaled = false
    b.TextWrapped = true
    corner(b, 12)
    stroke(b, (accent or C.line):Lerp(Color3.new(1, 1, 1), 0.15), 0.28)

    if not b:GetAttribute("MFVisualHover") then
        b:SetAttribute("MFVisualHover", true)
        local base = b.BackgroundColor3
        b.MouseEnter:Connect(function()
            if b.Active then
                TweenService:Create(b, TweenInfo.new(0.1), {
                    BackgroundColor3 = base:Lerp(Color3.new(1, 1, 1), 0.08),
                }):Play()
            end
        end)
        b.MouseLeave:Connect(function()
            TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = base }):Play()
        end)
    end
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

local function findDirectLabel(test)
    for _, obj in ipairs(gui:GetChildren()) do
        if obj:IsA("TextLabel") and test(obj) then
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

if not (collect and hatch and upgrade and monsters and zones and quests and shop and rewards and index and rebirth) then
    warn("[MonsterFactory] VisualRefresh could not resolve the legacy HUD controls.")
    return
end

local oldLeft = collect.Parent
local oldRight = shop.Parent

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
shell.Parent = gui

local statBar = Instance.new("Frame")
statBar.AnchorPoint = Vector2.new(0.5, 0)
statBar.Position = UDim2.new(0.5, 0, 0, 18)
statBar.Size = UDim2.fromOffset(760, 54)
statBar.BackgroundTransparency = 1
statBar.Parent = shell

local statLayout = Instance.new("UIListLayout")
statLayout.FillDirection = Enum.FillDirection.Horizontal
statLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
statLayout.VerticalAlignment = Enum.VerticalAlignment.Center
statLayout.Padding = UDim.new(0, 8)
statLayout.Parent = statBar

local statScale = Instance.new("UIScale")
statScale.Parent = statBar

if top then
    local statLabels = {}
    for _, child in ipairs(top:GetChildren()) do
        if child:IsA("TextLabel") then
            table.insert(statLabels, child)
        end
    end
    for i, label in ipairs(statLabels) do
        label.Parent = statBar
        label.Size = UDim2.fromOffset(118, 48)
        label.Position = UDim2.new()
        label.BackgroundTransparency = 0.05
        label.BackgroundColor3 = C.panel
        label.TextColor3 = C.text
        label.Font = Enum.Font.GothamBold
        label.TextSize = i == 2 and 13 or 15
        label.TextScaled = false
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Center
        corner(label, 14)
        stroke(label, C.line, 0.3)
    end
    top.Visible = false
end

local function makeDock(name, xScale, xOffset)
    local f = Instance.new("Frame")
    f.Name = name
    f.AnchorPoint = Vector2.new(xScale == 1 and 1 or 0, 0.5)
    f.Position = UDim2.new(xScale, xOffset, 0.53, 0)
    f.Size = UDim2.fromOffset(104, 286)
    f.BackgroundColor3 = C.bg
    f.BackgroundTransparency = 0.05
    f.Parent = shell
    corner(f, 18)
    stroke(f, C.line, 0.25)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 9)
    pad.PaddingBottom = UDim.new(0, 9)
    pad.PaddingLeft = UDim.new(0, 7)
    pad.PaddingRight = UDim.new(0, 7)
    pad.Parent = f

    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 7)
    layout.Parent = f

    local scale = Instance.new("UIScale")
    scale.Parent = f
    return f, scale
end

local leftDock, leftScale = makeDock("LeftDock", 0, 18)
local rightDock, rightScale = makeDock("RightDock", 1, -18)

for _, b in ipairs({ equipBest, monsters, zones, quests, achievements }) do
    if b then
        b.Parent = leftDock
        b.Size = UDim2.fromOffset(90, 46)
        styleButton(b, C.panel2, false)
    end
end

for _, pair in ipairs({
    { shop, C.green },
    { rewards, C.gold },
    { index, C.cyan },
    { rebirth, C.red },
}) do
    local b, accent = pair[1], pair[2]
    if b then
        b.Parent = rightDock
        b.Size = UDim2.fromOffset(90, 52)
        styleButton(b, accent, true)
    end
end

local actions = Instance.new("Frame")
actions.Name = "PrimaryActions"
actions.AnchorPoint = Vector2.new(0.5, 1)
actions.Position = UDim2.new(0.5, 0, 1, -22)
actions.Size = UDim2.fromOffset(620, 82)
actions.BackgroundColor3 = C.bg
actions.BackgroundTransparency = 0.05
actions.Parent = shell
corner(actions, 22)
stroke(actions, C.line, 0.2)

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
    local b, accent = pair[1], pair[2]
    b.Parent = actions
    b.Size = UDim2.fromOffset(190, 60)
    b.TextSize = 16
    styleButton(b, accent, true)
end

oldLeft.Visible = false
oldRight.Visible = false

local onboarding = findDirectLabel(function(obj)
    return obj.Visible and obj.Size.Y.Offset >= 40 and obj ~= nil
end)

if onboarding then
    onboarding.AnchorPoint = Vector2.new(0.5, 0)
    onboarding.Position = UDim2.new(0.5, 0, 0, 82)
    onboarding.Size = UDim2.fromOffset(430, 40)
    onboarding.BackgroundColor3 = C.panel
    onboarding.BackgroundTransparency = 0.06
    onboarding.TextColor3 = C.text
    onboarding.Font = Enum.Font.GothamBold
    onboarding.TextSize = 14
    onboarding.TextScaled = false
    corner(onboarding, 13)
    stroke(onboarding, C.green, 0.35)
end

local windowNames = {
    Shop = C.green,
    Monsters = C.purple,
    Zones = C.cyan,
    Quests = C.gold,
    Rewards = C.gold,
    Achievements = C.purple,
    Index = C.cyan,
}

local function styleModalDescendant(obj, accent)
    if obj:IsA("TextButton") then
        if obj.Text == "X" then
            obj.Size = UDim2.fromOffset(38, 34)
            styleButton(obj, C.red, true)
        else
            styleButton(obj, C.panel2, false)
        end
    elseif obj:IsA("TextLabel") then
        obj.TextColor3 = C.text
        if obj.Font ~= Enum.Font.GothamBold then
            obj.Font = Enum.Font.Gotham
        end
    elseif obj:IsA("ScrollingFrame") then
        obj.BackgroundTransparency = 1
        obj.BorderSizePixel = 0
        obj.ScrollBarImageColor3 = accent
        obj.ScrollBarThickness = 5
    elseif obj:IsA("Frame") and obj.Parent and obj.Parent:IsA("ScrollingFrame") then
        obj.BackgroundColor3 = C.panel
        obj.BackgroundTransparency = 0.04
        corner(obj, 13)
        stroke(obj, C.line, 0.35)
    end
end

for name, accent in pairs(windowNames) do
    local window = gui:FindFirstChild(name)
    if window and window:IsA("Frame") then
        window.BackgroundColor3 = C.bg
        window.BackgroundTransparency = 0.02
        corner(window, 20)
        stroke(window, accent, 0.35)

        for _, obj in ipairs(window:GetDescendants()) do
            styleModalDescendant(obj, accent)
        end
        window.DescendantAdded:Connect(function(obj)
            task.defer(styleModalDescendant, obj, accent)
        end)
    end
end

local function findContextCard()
    for _, obj in ipairs(gui:GetChildren()) do
        if obj:IsA("Frame") and obj ~= oldLeft and obj ~= oldRight and obj ~= top then
            local hasView, hasNo = false, false
            for _, d in ipairs(obj:GetDescendants()) do
                if d:IsA("TextButton") and d.Text == "VIEW OFFER" then hasView = true end
                if d:IsA("TextButton") and d.Text == "NO THANKS" then hasNo = true end
            end
            if hasView and hasNo then
                return obj
            end
        end
    end
end

local offer = findContextCard()
if offer then
    offer.BackgroundColor3 = C.bg
    offer.Size = UDim2.fromOffset(330, 126)
    offer.AnchorPoint = Vector2.new(1, 1)
    offer.Position = UDim2.new(1, -118, 1, -116)
    corner(offer, 17)
    stroke(offer, C.gold, 0.25)
    for _, obj in ipairs(offer:GetDescendants()) do
        if obj:IsA("TextButton") then
            styleButton(obj, obj.Text == "VIEW OFFER" and C.gold or C.panel2, obj.Text == "VIEW OFFER")
        elseif obj:IsA("TextLabel") then
            obj.TextColor3 = C.text
            obj.TextSize = 13
            obj.TextScaled = false
        end
    end
end

local function applyResponsive()
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local w, h = viewport.X, viewport.Y

    statScale.Scale = 1
    leftScale.Scale = 1
    rightScale.Scale = 1
    actionScale.Scale = 1

    statBar.Position = UDim2.new(0.5, 0, 0, 18)
    leftDock.Position = UDim2.new(0, 18, 0.53, 0)
    rightDock.Position = UDim2.new(1, -18, 0.53, 0)
    actions.Position = UDim2.new(0.5, 0, 1, -22)

    if onboarding then
        onboarding.Position = UDim2.new(0.5, 0, 0, 82)
        onboarding.Size = UDim2.fromOffset(430, 40)
    end

    if w <= 520 then
        statScale.Scale = math.clamp((w - 16) / 760, 0.43, 0.68)
        leftScale.Scale = 0.66
        rightScale.Scale = 0.66
        actionScale.Scale = math.clamp((w - 18) / 620, 0.52, 0.76)
        statBar.Position = UDim2.new(0.5, 0, 0, 10)
        leftDock.Position = UDim2.new(0, 6, 0.54, 0)
        rightDock.Position = UDim2.new(1, -6, 0.54, 0)
        actions.Position = UDim2.new(0.5, 0, 1, -10)
        if onboarding then
            onboarding.Size = UDim2.new(0.70, 0, 0, 36)
            onboarding.Position = UDim2.new(0.5, 0, 0, 46)
            onboarding.TextSize = 11
        end
    elseif w <= 820 then
        statScale.Scale = 0.78
        leftScale.Scale = 0.82
        rightScale.Scale = 0.82
        actionScale.Scale = 0.78
        statBar.Position = UDim2.new(0.5, 0, 0, 12)
        leftDock.Position = UDim2.new(0, 10, 0.53, 0)
        rightDock.Position = UDim2.new(1, -10, 0.53, 0)
        actions.Position = UDim2.new(0.5, 0, 1, -14)
    end

    if h <= 620 then
        leftScale.Scale = math.min(leftScale.Scale, 0.70)
        rightScale.Scale = math.min(rightScale.Scale, 0.70)
        actionScale.Scale = math.min(actionScale.Scale, 0.72)
    end
end

if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsive)
end

applyResponsive()
print("[MonsterFactory] Visual Rebuild 001 UI shell applied.")
