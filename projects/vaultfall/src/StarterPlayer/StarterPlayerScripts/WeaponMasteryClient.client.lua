local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "WeaponMasteryUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 58
gui.Parent = player:WaitForChild("PlayerGui")

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.fromRGB(4, 8, 11)
shade.BackgroundTransparency = 0.34
shade.BorderSizePixel = 0
shade.Visible = false
shade.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(790, 520)
panel.BackgroundColor3 = Color3.fromRGB(15, 21, 25)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(72, 111, 125)
stroke.Transparency = 0.24
stroke.Parent = panel

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Position = UDim2.fromOffset(24, 17)
header.Size = UDim2.new(1, -48, 0, 34)
header.Font = Enum.Font.GothamBold
header.Text = "ARMORY  //  WEAPON MASTERY"
header.TextColor3 = Color3.fromRGB(224, 239, 243)
header.TextSize = 22
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.fromOffset(24, 49)
sub.Size = UDim2.new(1, -48, 0, 28)
sub.Font = Enum.Font.GothamMedium
sub.Text = "Kills permanently calibrate the weapon family used for the takedown. Mastery perks stack with run augments and gear traits."
sub.TextColor3 = Color3.fromRGB(145, 165, 174)
sub.TextSize = 12
sub.TextWrapped = true
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = panel

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -18, 0, 16)
close.Size = UDim2.fromOffset(34, 34)
close.BackgroundColor3 = Color3.fromRGB(39, 47, 52)
close.BorderSizePixel = 0
close.Font = Enum.Font.GothamBold
close.Text = "×"
close.TextSize = 22
close.TextColor3 = Color3.fromRGB(219, 228, 232)
close.Parent = panel
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = close

local list = Instance.new("Frame")
list.BackgroundTransparency = 1
list.Position = UDim2.fromOffset(24, 92)
list.Size = UDim2.new(1, -48, 1, -116)
list.Parent = panel
local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0.5, -8, 0, 190)
layout.CellPadding = UDim2.fromOffset(16, 14)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local cards = {}
local latestEntries = {}
local order = { Carbine = 1, SMG = 2, Shotgun = 3, RailRifle = 4 }
local display = {
    Carbine = "PX-9 CARBINE",
    SMG = "CINDER SMG",
    Shotgun = "WARD SHOTGUN",
    RailRifle = "VANTA RAIL RIFLE",
}
local accents = {
    Carbine = Color3.fromRGB(73, 139, 155),
    SMG = Color3.fromRGB(168, 101, 74),
    Shotgun = Color3.fromRGB(176, 132, 69),
    RailRifle = Color3.fromRGB(115, 91, 172),
}

local function makeLabel(parent, position, size, textSize, color, bold)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    label.TextSize = textSize
    label.TextColor3 = color
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Parent = parent
    return label
end

local function makeCard(archetype)
    local card = Instance.new("Frame")
    card.Name = archetype
    card.LayoutOrder = order[archetype]
    card.BackgroundColor3 = Color3.fromRGB(24, 31, 36)
    card.BorderSizePixel = 0
    card.Parent = list
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 9)
    cardCorner.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = accents[archetype]
    cardStroke.Transparency = 0.42
    cardStroke.Parent = card

    local title = makeLabel(card, UDim2.fromOffset(15, 12), UDim2.new(1, -30, 0, 25), 15, Color3.fromRGB(230, 238, 241), true)
    title.Text = display[archetype]
    local level = makeLabel(card, UDim2.new(1, -118, 0, 13), UDim2.fromOffset(104, 23), 13, accents[archetype], true)
    level.TextXAlignment = Enum.TextXAlignment.Right

    local barBack = Instance.new("Frame")
    barBack.Position = UDim2.fromOffset(15, 45)
    barBack.Size = UDim2.new(1, -30, 0, 9)
    barBack.BackgroundColor3 = Color3.fromRGB(49, 57, 62)
    barBack.BorderSizePixel = 0
    barBack.Parent = card
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 4)
    barCorner.Parent = barBack
    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = accents[archetype]
    fill.BorderSizePixel = 0
    fill.Parent = barBack
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill

    local xp = makeLabel(card, UDim2.fromOffset(15, 61), UDim2.new(1, -30, 0, 20), 11, Color3.fromRGB(148, 164, 172), false)
    local perks = makeLabel(card, UDim2.fromOffset(15, 88), UDim2.new(1, -30, 1, -99), 11, Color3.fromRGB(190, 204, 211), false)
    perks.TextWrapped = true
    perks.RichText = true

    cards[archetype] = { Level = level, Fill = fill, XP = xp, Perks = perks, Stroke = cardStroke }
end

for _, archetype in ipairs({ "Carbine", "SMG", "Shotgun", "RailRifle" }) do
    makeCard(archetype)
end

local toast = Instance.new("Frame")
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, -72)
toast.Size = UDim2.fromOffset(390, 56)
toast.BackgroundColor3 = Color3.fromRGB(19, 28, 33)
toast.BorderSizePixel = 0
toast.Parent = gui
local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 8)
toastCorner.Parent = toast
local toastText = makeLabel(toast, UDim2.fromOffset(14, 8), UDim2.new(1, -28, 1, -16), 14, Color3.fromRGB(224, 239, 243), true)
toastText.TextXAlignment = Enum.TextXAlignment.Center
toastText.TextYAlignment = Enum.TextYAlignment.Center

local function refresh()
    for archetype, entry in pairs(latestEntries) do
        local card = cards[archetype]
        if card then
            card.Level.Text = string.format("LV.%d / %d", entry.Level or 0, entry.MaxLevel or 10)
            card.Fill.Size = UDim2.fromScale(math.clamp(entry.Progress or 0, 0, 1), 1)
            if (entry.Level or 0) >= (entry.MaxLevel or 10) then
                card.XP.Text = string.format("MASTERED  •  %d XP", entry.XP or 0)
            else
                card.XP.Text = string.format("%d / %d XP  •  next calibration", entry.XP or 0, entry.NextXP or 0)
            end
            local perkLines = {}
            for _, line in ipairs(entry.Perks or {}) do
                table.insert(perkLines, "• " .. line)
            end
            card.Perks.Text = table.concat(perkLines, "\n")
        end
    end
end

local function setOpen(value)
    panel.Visible = value
    shade.Visible = value
    if value then
        panel.Position = UDim2.new(0.5, 0, 0.5, 12)
        panel.BackgroundTransparency = 0.22
        TweenService:Create(panel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(0.5, 0.5),
            BackgroundTransparency = 0,
        }):Play()
    end
end

close.Activated:Connect(function()
    setOpen(false)
end)
shade.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        setOpen(false)
    end
end)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Escape and panel.Visible then
        setOpen(false)
    end
end)

ProximityPromptService.PromptTriggered:Connect(function(prompt)
    if prompt and prompt.ObjectText == "Armory console" then
        refresh()
        setOpen(true)
    end
end)

local function masteryState(payload)
    table.clear(latestEntries)
    for _, entry in ipairs(payload.Entries or {}) do
        latestEntries[entry.Archetype] = entry
    end
    refresh()

    local levelUp = payload.LevelUp
    if levelUp then
        local accent = accents[levelUp.Archetype] or Color3.fromRGB(90, 170, 190)
        toast.BackgroundColor3 = Color3.fromRGB(19, 28, 33)
        toastText.TextColor3 = accent:Lerp(Color3.new(1, 1, 1), 0.35)
        toastText.Text = string.format("%s MASTERY  //  LEVEL %d", display[levelUp.Archetype] or levelUp.Archetype, levelUp.Level or 0)
        toast.Position = UDim2.new(0.5, 0, 0, -72)
        TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 18) }):Play()
        task.delay(2.4, function()
            TweenService:Create(toast, TweenInfo.new(0.22), { Position = UDim2.new(0.5, 0, 0, -72) }):Play()
        end)
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Mastery" and type(payload) == "table" then
        masteryState(payload)
    end
end)