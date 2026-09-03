local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local UIVisualContract = require(ReplicatedStorage.Shared:WaitForChild("UIVisualContract"))

local HUDView = {}

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
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius or 12)
    x.Parent = obj
    return x
end

local function stroke(obj, color, transparency, thickness)
    local x = Instance.new("UIStroke")
    x.Color = color or C.line
    x.Transparency = transparency or 0.3
    x.Thickness = thickness or 1
    x.Parent = obj
    return x
end

local function gradient(obj, topColor, bottomColor, rotation)
    local x = Instance.new("UIGradient")
    x.Color = ColorSequence.new(topColor, bottomColor)
    x.Rotation = rotation or 90
    x.Parent = obj
    return x
end

local function padding(obj, left, right, top, bottom)
    local x = Instance.new("UIPadding")
    x.PaddingLeft = UDim.new(0, left or 0)
    x.PaddingRight = UDim.new(0, right or 0)
    x.PaddingTop = UDim.new(0, top or 0)
    x.PaddingBottom = UDim.new(0, bottom or 0)
    x.Parent = obj
    return x
end

local function icon(parent, slotKey, size, position, zIndex)
    local spec = UIVisualContract.GetSlot(slotKey)
    local holder = Instance.new("Frame")
    holder.Name = "MFIconSlot_" .. slotKey
    holder.Size = UDim2.fromOffset(size, size)
    holder.Position = position
    holder.BackgroundColor3 = spec.Color
    holder.BackgroundTransparency = 0.04
    holder.BorderSizePixel = 0
    holder.ZIndex = zIndex
    holder:SetAttribute("MFIconSlot", slotKey)
    holder.Parent = parent
    corner(holder, math.max(8, math.floor(size * 0.28)))
    stroke(holder, spec.Color:Lerp(Color3.new(1, 1, 1), 0.25), 0.48)

    local image = Instance.new("ImageLabel")
    image.Name = "IconImage"
    image.Size = UDim2.new(1, -8, 1, -8)
    image.Position = UDim2.fromOffset(4, 4)
    image.BackgroundTransparency = 1
    image.Image = spec.Image or ""
    image.Visible = image.Image ~= ""
    image.ScaleType = Enum.ScaleType.Fit
    image.ZIndex = zIndex + 1
    image.Parent = holder

    local glyph = Instance.new("TextLabel")
    glyph.Name = "FallbackGlyph"
    glyph.Size = UDim2.fromScale(1, 1)
    glyph.BackgroundTransparency = 1
    glyph.Text = spec.Glyph or "•"
    glyph.TextColor3 = C.darkText
    glyph.Font = Enum.Font.GothamBlack
    glyph.TextSize = math.max(13, math.floor(size * 0.42))
    glyph.Visible = not image.Visible
    glyph.ZIndex = zIndex + 1
    glyph.Parent = holder
    return holder
end

local function styleButton(button, accent, darkText, textSize, radius)
    button.AutoButtonColor = false
    button.BackgroundColor3 = accent or C.panel2
    button.BackgroundTransparency = accent and 0.01 or 0.03
    button.TextColor3 = darkText and C.darkText or C.text
    button.Font = Enum.Font.GothamBold
    button.TextSize = textSize or 12
    button.TextScaled = false
    button.TextWrapped = true
    button.BorderSizePixel = 0
    corner(button, radius or 13)
    stroke(button, accent and accent:Lerp(Color3.new(1, 1, 1), 0.14) or C.line, 0.4)

    local scale = Instance.new("UIScale")
    scale.Name = "MFButtonScale"
    scale.Parent = button
    button.MouseEnter:Connect(function()
        if button.Active then TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 1.035 }):Play() end
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 1 }):Play()
    end)
    button.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.05), { Scale = 0.965 }):Play()
    end)
    button.MouseButton1Up:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.07), { Scale = 1.015 }):Play()
    end)
end

local function button(parent, name, text, size, accent, slotKey, darkText)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Size = size
    b.Text = text
    b.Parent = parent
    styleButton(b, accent, darkText)
    if slotKey then
        b.TextXAlignment = Enum.TextXAlignment.Left
        padding(b, 51, 8, 0, 0)
        icon(b, slotKey, 34, UDim2.new(0, 8, 0.5, -17), b.ZIndex + 1)
    end
    return b
end

local function createWindow(gui, name, titleText, subtitleText, accent, iconSlot, maxSize)
    local f = Instance.new("Frame")
    f.Name = name
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.fromScale(0.5, 0.5)
    f.Size = UDim2.new(0.82, 0, 0.76, 0)
    f.BackgroundColor3 = C.bg
    f.BackgroundTransparency = 0.005
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = 22
    f.Parent = gui
    corner(f, 22)
    stroke(f, accent, 0.26, 2)
    gradient(f, C.panel, C.bg, 90)

    local constraint = Instance.new("UISizeConstraint")
    constraint.MinSize = Vector2.new(math.min(300, maxSize.X), math.min(300, maxSize.Y))
    constraint.MaxSize = maxSize
    constraint.Parent = f

    icon(f, iconSlot, 38, UDim2.fromOffset(13, 10), 25)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -126, 0, 32)
    title.Position = UDim2.fromOffset(58, 7)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = C.text
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 25
    title.Parent = f

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -132, 0, 18)
    sub.Position = UDim2.fromOffset(60, 37)
    sub.BackgroundTransparency = 1
    sub.Text = subtitleText
    sub.TextColor3 = C.muted
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 10
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 25
    sub.Parent = f

    local close = button(f, "Close", "×", UDim2.fromOffset(38, 34), C.red, nil, true)
    close.Position = UDim2.new(1, -50, 0, 12)
    close.TextSize = 17
    close.ZIndex = 25

    local strip = Instance.new("Frame")
    strip.Size = UDim2.new(1, -28, 0, 3)
    strip.Position = UDim2.fromOffset(14, 58)
    strip.BackgroundColor3 = accent
    strip.BorderSizePixel = 0
    strip.ZIndex = 24
    strip.Parent = f
    corner(strip, 2)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Content"
    scroll.Size = UDim2.new(1, -30, 1, -78)
    scroll.Position = UDim2.fromOffset(15, 68)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new()
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = accent
    scroll.ZIndex = 23
    scroll.Parent = f

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    return f, scroll, close
end

function HUDView.Create(playerGui, camera)
    local self = {}

    local old = playerGui:FindFirstChild("MonsterFactoryHUD")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MonsterFactoryHUD"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui
    self.Gui = gui

    local shell = Instance.new("Frame")
    shell.Size = UDim2.fromScale(1, 1)
    shell.BackgroundTransparency = 1
    shell.Parent = gui

    local brand = Instance.new("TextLabel")
    brand.Size = UDim2.fromOffset(160, 40)
    brand.Position = UDim2.fromOffset(18, 17)
    brand.BackgroundColor3 = C.bg
    brand.BackgroundTransparency = 0.04
    brand.Text = "MONSTER FACTORY"
    brand.TextColor3 = C.text
    brand.Font = Enum.Font.GothamBlack
    brand.TextSize = 13
    brand.Parent = shell
    corner(brand, 14)
    stroke(brand, C.green, 0.3)
    self.Brand = brand

    local statBar = Instance.new("Frame")
    statBar.AnchorPoint = Vector2.new(0.5, 0)
    statBar.Position = UDim2.new(0.5, 0, 0, 15)
    statBar.Size = UDim2.fromOffset(786, 50)
    statBar.BackgroundTransparency = 1
    statBar.Parent = shell
    local statLayout = Instance.new("UIListLayout")
    statLayout.FillDirection = Enum.FillDirection.Horizontal
    statLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    statLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    statLayout.Padding = UDim.new(0, 7)
    statLayout.Parent = statBar
    local statScale = Instance.new("UIScale")
    statScale.Parent = statBar
    self.StatScale = statScale

    self.Stats = {}
    local statDefs = {
        { "Cash", "cash", "$0", C.green },
        { "Collector", "collector", "Collector $0", C.green },
        { "Gems", "gems", "Gems 0", C.purple },
        { "Production", "production", "+0/s", C.gold },
        { "Friends", "friends", "Friends +0%", C.cyan },
        { "Rebirths", "rebirth", "R0", C.red },
    }
    for _, def in ipairs(statDefs) do
        local chip = Instance.new("Frame")
        chip.Size = UDim2.fromOffset(124, 46)
        chip.BackgroundColor3 = C.panel
        chip.BackgroundTransparency = 0.02
        chip.BorderSizePixel = 0
        chip.Parent = statBar
        corner(chip, 14)
        stroke(chip, def[4], 0.42)
        icon(chip, def[2], 31, UDim2.fromOffset(7, 7), 4)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -44, 1, -6)
        label.Position = UDim2.fromOffset(41, 3)
        label.BackgroundTransparency = 1
        label.Text = def[3]
        label.TextColor3 = C.text
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = chip
        self.Stats[def[1]] = { Label = label, Chip = chip }
    end

    local onboarding = Instance.new("TextLabel")
    onboarding.AnchorPoint = Vector2.new(0.5, 0)
    onboarding.Position = UDim2.new(0.5, 0, 0, 76)
    onboarding.Size = UDim2.fromOffset(470, 39)
    onboarding.BackgroundColor3 = C.panel
    onboarding.BackgroundTransparency = 0.02
    onboarding.TextColor3 = C.text
    onboarding.Font = Enum.Font.GothamBold
    onboarding.TextSize = 13
    onboarding.TextWrapped = true
    onboarding.Visible = false
    onboarding.Parent = shell
    corner(onboarding, 12)
    stroke(onboarding, C.green, 0.42)
    gradient(onboarding, C.panel2, C.panel, 90)
    self.Onboarding = onboarding

    local function makeDock(side)
        local dock = Instance.new("Frame")
        dock.AnchorPoint = Vector2.new(side == "right" and 1 or 0, 0.5)
        dock.Position = side == "right" and UDim2.new(1, -17, 0.51, 0) or UDim2.new(0, 17, 0.51, 0)
        dock.Size = UDim2.fromOffset(124, 330)
        dock.BackgroundColor3 = C.bg
        dock.BackgroundTransparency = 0.025
        dock.BorderSizePixel = 0
        dock.Parent = shell
        corner(dock, 20)
        stroke(dock, C.line, 0.38)
        gradient(dock, C.panel, C.bg, 90)
        padding(dock, 8, 8, 10, 10)
        local layout = Instance.new("UIListLayout")
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 7)
        layout.Parent = dock
        local scale = Instance.new("UIScale")
        scale.Parent = dock
        return dock, scale
    end

    local leftDock, leftScale = makeDock("left")
    local rightDock, rightScale = makeDock("right")
    self.LeftDock, self.RightDock = leftDock, rightDock
    self.LeftScale, self.RightScale = leftScale, rightScale
    self.Buttons = {}

    local navDefs = {
        { leftDock, "EquipBest", "EQUIP BEST", "EquipBest", nil, false },
        { leftDock, "Monsters", "MONSTERS", "Monsters", nil, false },
        { leftDock, "Zones", "WORLDS", "Worlds", nil, false },
        { leftDock, "Quests", "QUESTS", "Quests", nil, false },
        { leftDock, "Achievements", "ACHIEVEMENTS", "Achievements", nil, false },
        { rightDock, "Shop", "SHOP", "Shop", C.green, true },
        { rightDock, "Rewards", "REWARDS", "Rewards", C.gold, true },
        { rightDock, "Index", "INDEX", "Index", C.cyan, true },
        { rightDock, "Rebirth", "REBIRTH", "Rebirth", C.red, true },
    }
    for _, def in ipairs(navDefs) do
        local b = button(def[1], def[2], def[3], UDim2.fromOffset(106, def[1] == rightDock and 61 or 51), def[5], def[4], def[6])
        self.Buttons[def[2]] = b
    end

    local actions = Instance.new("Frame")
    actions.AnchorPoint = Vector2.new(0.5, 1)
    actions.Position = UDim2.new(0.5, 0, 1, -18)
    actions.Size = UDim2.fromOffset(646, 88)
    actions.BackgroundColor3 = C.bg
    actions.BackgroundTransparency = 0.015
    actions.BorderSizePixel = 0
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
    self.Actions, self.ActionScale = actions, actionScale

    local primaryDefs = {
        { "Collect", "COLLECT", "Collect", C.green },
        { "Hatch", "HATCH", "Hatch", C.cyan },
        { "Upgrade", "UPGRADE", "Upgrade", C.gold },
    }
    for _, def in ipairs(primaryDefs) do
        local b = button(actions, def[1], def[2], UDim2.fromOffset(199, 66), def[4], def[3], true)
        b.TextSize = 15
        gradient(b, def[4]:Lerp(Color3.new(1, 1, 1), 0.08), def[4]:Lerp(Color3.new(0, 0, 0), 0.08), 90)
        self.Buttons[def[1]] = b
    end

    local dimmer = Instance.new("TextButton")
    dimmer.Size = UDim2.fromScale(1, 1)
    dimmer.BackgroundColor3 = Color3.new(0, 0, 0)
    dimmer.BackgroundTransparency = 1
    dimmer.Text = ""
    dimmer.AutoButtonColor = false
    dimmer.Visible = false
    dimmer.ZIndex = 20
    dimmer.Parent = gui
    self.Dimmer = dimmer

    local blur = Lighting:FindFirstChild("MonsterFactoryModalBlur") or Instance.new("BlurEffect")
    blur.Name = "MonsterFactoryModalBlur"
    blur.Size = 0
    blur.Parent = Lighting
    self.Blur = blur

    self.Windows = {}
    self.Scrolls = {}
    local winDefs = {
        { "Shop", "BOOST SHOP", "Passes & factory boosts", C.green, "Shop", Vector2.new(520, 560) },
        { "Monsters", "MONSTER WORKERS", "Equip, compare and fuse your workforce", C.purple, "Monsters", Vector2.new(820, 620) },
        { "Zones", "FACTORY WORLDS", "Unlock and travel between production zones", C.cyan, "Worlds", Vector2.new(650, 500) },
        { "Quests", "MILESTONE QUESTS", "Progress targets and claim rewards", C.gold, "Quests", Vector2.new(680, 560) },
        { "Rewards", "REWARDS", "Daily and playtime rewards", C.gold, "Rewards", Vector2.new(660, 560) },
        { "Achievements", "ACHIEVEMENTS", "Long-term factory goals", C.purple, "Achievements", Vector2.new(720, 580) },
        { "Index", "MONSTER INDEX", "Discover workers across every zone", C.cyan, "Index", Vector2.new(720, 580) },
    }
    for _, def in ipairs(winDefs) do
        local window, scroll, close = createWindow(gui, table.unpack(def))
        self.Windows[def[1]] = window
        self.Scrolls[def[1]] = scroll
        close.Activated:Connect(function() self:CloseWindow(def[1]) end)
    end

    local monsterGrid = Instance.new("UIGridLayout")
    monsterGrid.CellSize = UDim2.fromOffset(226, 132)
    monsterGrid.CellPadding = UDim2.fromOffset(10, 10)
    monsterGrid.Parent = self.Scrolls.Monsters
    self.MonsterGrid = monsterGrid

    local contextOffer = Instance.new("Frame")
    contextOffer.AnchorPoint = Vector2.new(1, 1)
    contextOffer.Position = UDim2.new(1, -17, 1, -119)
    contextOffer.Size = UDim2.fromOffset(352, 132)
    contextOffer.BackgroundColor3 = C.bg
    contextOffer.BackgroundTransparency = 0.01
    contextOffer.BorderSizePixel = 0
    contextOffer.Visible = false
    contextOffer.ZIndex = 15
    contextOffer.Parent = gui
    corner(contextOffer, 19)
    stroke(contextOffer, C.gold, 0.25, 2)
    gradient(contextOffer, C.panel2, C.bg, 90)
    self.ContextOffer = contextOffer

    local offerBadge = Instance.new("TextLabel")
    offerBadge.Size = UDim2.fromOffset(88, 21)
    offerBadge.Position = UDim2.fromOffset(12, 8)
    offerBadge.BackgroundColor3 = C.gold
    offerBadge.Text = "RECOMMENDED"
    offerBadge.TextColor3 = C.darkText
    offerBadge.Font = Enum.Font.GothamBlack
    offerBadge.TextSize = 8
    offerBadge.ZIndex = 17
    offerBadge.Parent = contextOffer
    corner(offerBadge, 7)

    local offerText = Instance.new("TextLabel")
    offerText.Size = UDim2.new(1, -24, 0, 60)
    offerText.Position = UDim2.fromOffset(12, 31)
    offerText.BackgroundTransparency = 1
    offerText.TextColor3 = C.text
    offerText.Font = Enum.Font.GothamBold
    offerText.TextSize = 15
    offerText.TextWrapped = true
    offerText.TextXAlignment = Enum.TextXAlignment.Left
    offerText.ZIndex = 16
    offerText.Parent = contextOffer
    self.ContextOfferText = offerText

    local viewOffer = button(contextOffer, "ViewOffer", "VIEW OFFER", UDim2.new(0.62, -12, 0, 34), C.gold, nil, true)
    viewOffer.Position = UDim2.new(0, 10, 1, -42)
    viewOffer.ZIndex = 16
    local noThanks = button(contextOffer, "NoThanks", "NO THANKS", UDim2.new(0.38, -8, 0, 34), C.panel2, nil, false)
    noThanks.Position = UDim2.new(0.62, 2, 1, -42)
    noThanks.ZIndex = 16
    self.Buttons.ViewOffer, self.Buttons.NoThanks = viewOffer, noThanks

    local toast = Instance.new("TextLabel")
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0.14, 0)
    toast.Size = UDim2.fromOffset(430, 54)
    toast.BackgroundColor3 = C.bg
    toast.BackgroundTransparency = 0.03
    toast.TextColor3 = C.text
    toast.Font = Enum.Font.GothamBold
    toast.TextSize = 15
    toast.TextWrapped = true
    toast.Visible = false
    toast.ZIndex = 70
    toast.Parent = gui
    corner(toast, 14)
    stroke(toast, C.cyan, 0.25, 2)
    self.Toast = toast

    local fx = Instance.new("Frame")
    fx.Size = UDim2.fromScale(1, 1)
    fx.BackgroundTransparency = 1
    fx.ZIndex = 80
    fx.Parent = gui
    self.Fx = fx

    function self:OpenWindow(name)
        for otherName, window in pairs(self.Windows) do
            window.Visible = otherName == name
        end
        self.Dimmer.Visible = true
        TweenService:Create(self.Dimmer, TweenInfo.new(0.14), { BackgroundTransparency = 0.34 }):Play()
        TweenService:Create(self.Blur, TweenInfo.new(0.14), { Size = 9 }):Play()
    end

    function self:CloseWindow(name)
        local window = self.Windows[name]
        if window then window.Visible = false end
        local anyOpen = false
        for _, candidate in pairs(self.Windows) do
            if candidate.Visible then anyOpen = true break end
        end
        if not anyOpen then
            TweenService:Create(self.Dimmer, TweenInfo.new(0.14), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(self.Blur, TweenInfo.new(0.14), { Size = 0 }):Play()
            task.delay(0.15, function()
                if self.Blur.Size <= 0.1 then self.Dimmer.Visible = false end
            end)
        end
    end

    dimmer.Activated:Connect(function()
        for _, window in pairs(self.Windows) do window.Visible = false end
        self:CloseWindow("")
    end)

    function self:Clear(name)
        local scroll = self.Scrolls[name]
        if not scroll then return end
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
    end

    function self:SetStat(key, text)
        local record = self.Stats[key]
        if not record then return end
        if record.Label.Text ~= text then
            record.Label.Text = text
            local s = record.Chip:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
            s.Parent = record.Chip
            s.Scale = 1
            TweenService:Create(s, TweenInfo.new(0.08), { Scale = 1.05 }):Play()
            task.delay(0.09, function()
                if s.Parent then TweenService:Create(s, TweenInfo.new(0.1), { Scale = 1 }):Play() end
            end)
        end
    end

    function self:ListButton(windowName, text, height, accent, slotKey)
        local scroll = self.Scrolls[windowName]
        local b = button(scroll, "Entry", text, UDim2.new(0.96, 0, 0, height), C.panel2, nil, false)
        b.TextSize = 13
        b.TextXAlignment = Enum.TextXAlignment.Left
        padding(b, 58, 68, 5, 5)
        gradient(b, C.panel3, C.panel2, 90)
        icon(b, slotKey or "IndexEntry", 38, UDim2.new(0, 10, 0.5, -19), 25)
        if accent then stroke(b, accent, 0.55) end
        return b
    end

    function self:MonsterCard(item)
        local card = Instance.new("Frame")
        card.Size = UDim2.fromOffset(226, 132)
        card.BackgroundColor3 = C.panel
        card.BackgroundTransparency = 0.01
        card.BorderSizePixel = 0
        card.Parent = self.Scrolls.Monsters
        corner(card, 15)
        stroke(card, item.Shiny and C.gold or C.purple, 0.5)
        gradient(card, C.panel2, C.panel, 90)
        icon(card, "Monster", 40, UDim2.fromOffset(8, 8), 25)

        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -62, 0, 72)
        info.Position = UDim2.fromOffset(55, 7)
        info.BackgroundTransparency = 1
        info.Text = string.format("%s%s\n%s  •  +%d%%", item.Shiny and "SHINY " or "", item.DisplayName, item.Rarity, math.floor((item.ProductionBonus or 0) * 100))
        info.TextColor3 = C.text
        info.Font = Enum.Font.GothamBold
        info.TextSize = 13
        info.TextWrapped = true
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.Parent = card

        local equip = button(card, "Equip", item.Equipped and "UNEQUIP" or "EQUIP", UDim2.new(0.58, -6, 0, 32), item.Equipped and C.red or C.purple, nil, true)
        equip.Position = UDim2.new(0, 4, 1, -36)
        equip.TextSize = 10
        local fuse = button(card, "Fuse", item.Shiny and "SHINY" or "FUSE", UDim2.new(0.42, -6, 0, 32), C.gold, nil, true)
        fuse.Position = UDim2.new(0.58, 2, 1, -36)
        fuse.TextSize = 10
        fuse.Active = not item.Shiny
        return card, equip, fuse
    end

    function self:ShowToast(message, accent)
        self.Toast.Text = message
        local s = self.Toast:FindFirstChildOfClass("UIStroke")
        if s and accent then s.Color = accent end
        self.Toast.Visible = true
        self.Toast.TextTransparency = 0
        self.Toast.BackgroundTransparency = 0.03
        local token = os.clock()
        self.Toast:SetAttribute("Token", token)
        task.delay(2.4, function()
            if self.Toast:GetAttribute("Token") ~= token then return end
            TweenService:Create(self.Toast, TweenInfo.new(0.18), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
            task.delay(0.2, function()
                if self.Toast:GetAttribute("Token") == token then self.Toast.Visible = false end
            end)
        end)
    end

    function self:Feedback(text, color)
        local label = Instance.new("TextLabel")
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.Position = UDim2.new(0.5, 0, 0.32, 0)
        label.Size = UDim2.fromOffset(320, 46)
        label.BackgroundColor3 = C.bg
        label.BackgroundTransparency = 0.04
        label.Text = text
        label.TextColor3 = color
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 17
        label.ZIndex = 86
        label.Parent = self.Fx
        corner(label, 14)
        stroke(label, color, 0.15, 2)
        local s = Instance.new("UIScale")
        s.Scale = 0.72
        s.Parent = label
        TweenService:Create(s, TweenInfo.new(0.16, Enum.EasingStyle.Back), { Scale = 1 }):Play()
        task.delay(0.95, function()
            if not label.Parent then return end
            TweenService:Create(label, TweenInfo.new(0.18), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
            task.delay(0.2, function() if label.Parent then label:Destroy() end end)
        end)
    end

    function self:SetOnboarding(text)
        self.Onboarding.Text = text or ""
        self.Onboarding.Visible = text ~= nil and text ~= ""
    end

    function self:SetContextOffer(text, visible)
        self.ContextOfferText.Text = text or ""
        self.ContextOffer.Visible = visible == true
    end

    local function responsive()
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local w, h = viewport.X, viewport.Y
        local stat, side, action = 1, 1, 1
        brand.Visible = w >= 1050
        if w <= 560 then
            stat = math.clamp((w - 12) / 786, 0.42, 0.65)
            side = 0.62
            action = math.clamp((w - 14) / 646, 0.52, 0.73)
            leftDock.Position = UDim2.new(0, 5, 0.52, 0)
            rightDock.Position = UDim2.new(1, -5, 0.52, 0)
            actions.Position = UDim2.new(0.5, 0, 1, -8)
            statBar.Position = UDim2.new(0.5, 0, 0, 8)
            onboarding.Size = UDim2.new(0.70, 0, 0, 34)
            onboarding.Position = UDim2.new(0.5, 0, 0, 42)
            onboarding.TextSize = 10
            contextOffer.Size = UDim2.new(0.92, 0, 0, 118)
            contextOffer.Position = UDim2.new(0.96, 0, 1, -96)
            for _, window in pairs(self.Windows) do window.Size = UDim2.new(0.94, 0, 0.80, 0) end
        elseif w <= 900 then
            stat, side, action = 0.77, 0.79, 0.79
            leftDock.Position = UDim2.new(0, 9, 0.52, 0)
            rightDock.Position = UDim2.new(1, -9, 0.52, 0)
            actions.Position = UDim2.new(0.5, 0, 1, -12)
            statBar.Position = UDim2.new(0.5, 0, 0, 11)
            onboarding.Size = UDim2.fromOffset(396, 36)
            onboarding.Position = UDim2.new(0.5, 0, 0, 60)
            onboarding.TextSize = 12
            for _, window in pairs(self.Windows) do window.Size = UDim2.new(0.88, 0, 0.78, 0) end
        else
            leftDock.Position = UDim2.new(0, 17, 0.51, 0)
            rightDock.Position = UDim2.new(1, -17, 0.51, 0)
            actions.Position = UDim2.new(0.5, 0, 1, -18)
            statBar.Position = UDim2.new(0.5, 0, 0, 15)
            onboarding.Size = UDim2.fromOffset(470, 39)
            onboarding.Position = UDim2.new(0.5, 0, 0, 76)
            onboarding.TextSize = 13
            contextOffer.Size = UDim2.fromOffset(352, 132)
            contextOffer.Position = UDim2.new(1, -17, 1, -119)
            for _, window in pairs(self.Windows) do window.Size = UDim2.new(0.82, 0, 0.76, 0) end
        end
        if h < 620 then side *= 0.86 action *= 0.88 end
        statScale.Scale = stat
        leftScale.Scale = side
        rightScale.Scale = side
        actionScale.Scale = action
    end

    if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(responsive) end
    responsive()
    return self
end

HUDView.Colors = C
return HUDView
