local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local stateRemote = ReplicatedStorage:WaitForChild("VaultfallRemotes"):WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "OperatorRecordUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local shade = Instance.new("Frame")
shade.Size = UDim2.fromScale(1, 1)
shade.BackgroundColor3 = Color3.fromRGB(4, 7, 9)
shade.BackgroundTransparency = 0.3
shade.BorderSizePixel = 0
shade.Visible = false
shade.Parent = gui

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(720, 470)
panel.BackgroundColor3 = Color3.fromRGB(17, 22, 27)
panel.BorderSizePixel = 0
panel.Parent = shade

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(86, 124, 137)
stroke.Transparency = 0.28
stroke.Thickness = 1
stroke.Parent = panel

local function makeLabel(parent, text, size, position, textSize, align)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Font = Enum.Font.GothamMedium
    label.Text = text
    label.TextSize = textSize
    label.TextColor3 = Color3.fromRGB(229, 235, 239)
    label.TextXAlignment = align or Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local header = makeLabel(panel, "OPERATOR ARCHIVE", UDim2.new(1, -120, 0, 42), UDim2.fromOffset(24, 16), 22)
header.Font = Enum.Font.GothamBold
local sub = makeLabel(panel, "Persistent breach record  •  trophies unlock from actual runs", UDim2.new(1, -48, 0, 24), UDim2.fromOffset(24, 51), 12)
sub.TextColor3 = Color3.fromRGB(146, 162, 171)

local close = Instance.new("TextButton")
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -18, 0, 16)
close.Size = UDim2.fromOffset(42, 34)
close.BackgroundColor3 = Color3.fromRGB(42, 48, 54)
close.BorderSizePixel = 0
close.Font = Enum.Font.GothamBold
close.Text = "×"
close.TextSize = 22
close.TextColor3 = Color3.fromRGB(230, 235, 238)
close.Parent = panel
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = close
close.Activated:Connect(function()
    shade.Visible = false
end)

local statPanel = Instance.new("Frame")
statPanel.Position = UDim2.fromOffset(24, 88)
statPanel.Size = UDim2.new(1, -48, 0, 88)
statPanel.BackgroundColor3 = Color3.fromRGB(24, 30, 35)
statPanel.BorderSizePixel = 0
statPanel.Parent = panel
local statCorner = Instance.new("UICorner")
statCorner.CornerRadius = UDim.new(0, 8)
statCorner.Parent = statPanel

local statLabels = {}
local statNames = { "COMPLETIONS", "BEST DEPTH", "EXTRACTIONS", "WARDENS", "POWER RANK" }
for index, name in ipairs(statNames) do
    local width = 1 / #statNames
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.new((index - 1) * width, 0, 0, 0)
    holder.Size = UDim2.new(width, 0, 1, 0)
    holder.Parent = statPanel
    local value = makeLabel(holder, "0", UDim2.new(1, 0, 0, 38), UDim2.fromOffset(0, 12), 23, Enum.TextXAlignment.Center)
    value.Font = Enum.Font.GothamBold
    value.TextColor3 = Color3.fromRGB(121, 196, 205)
    local caption = makeLabel(holder, name, UDim2.new(1, 0, 0, 24), UDim2.fromOffset(0, 50), 10, Enum.TextXAlignment.Center)
    caption.TextColor3 = Color3.fromRGB(143, 156, 165)
    statLabels[index] = value
end

local trophyHeader = makeLabel(panel, "TROPHY WALL", UDim2.new(1, -48, 0, 28), UDim2.fromOffset(24, 194), 14)
trophyHeader.Font = Enum.Font.GothamBold
local trophyGrid = Instance.new("Frame")
trophyGrid.BackgroundTransparency = 1
trophyGrid.Position = UDim2.fromOffset(24, 228)
trophyGrid.Size = UDim2.new(1, -48, 0, 214)
trophyGrid.Parent = panel

local trophyCards = {}
for index = 1, 7 do
    local card = Instance.new("Frame")
    local column = (index - 1) % 4
    local row = math.floor((index - 1) / 4)
    card.Position = UDim2.new(column * 0.25, 4, 0, row * 105)
    card.Size = UDim2.new(0.25, -8, 0, 96)
    card.BackgroundColor3 = Color3.fromRGB(29, 34, 39)
    card.BorderSizePixel = 0
    card.Parent = trophyGrid
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 7)
    cardCorner.Parent = card
    local name = makeLabel(card, "LOCKED", UDim2.new(1, -14, 0, 24), UDim2.fromOffset(7, 8), 11, Enum.TextXAlignment.Center)
    name.Font = Enum.Font.GothamBold
    local desc = makeLabel(card, "Unknown archive condition", UDim2.new(1, -14, 0, 38), UDim2.fromOffset(7, 34), 10, Enum.TextXAlignment.Center)
    desc.TextWrapped = true
    desc.TextColor3 = Color3.fromRGB(145, 154, 160)
    local progress = makeLabel(card, "0 / 1", UDim2.new(1, -14, 0, 18), UDim2.fromOffset(7, 74), 9, Enum.TextXAlignment.Center)
    progress.TextColor3 = Color3.fromRGB(111, 128, 138)
    trophyCards[index] = { Card = card, Name = name, Description = desc, Progress = progress }
end

local function findTrophyPlates()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    local safehouse = world and world:FindFirstChild("Safehouse")
    if not safehouse then
        return {}
    end
    local plates = {}
    for _, child in ipairs(safehouse:GetChildren()) do
        if child.Name == "TrophyPlate" and child:IsA("BasePart") then
            table.insert(plates, child)
        end
    end
    table.sort(plates, function(a, b)
        return a.Position.X < b.Position.X
    end)
    return plates
end

local function updateWorldTrophies(trophies)
    local plates = findTrophyPlates()
    for index, trophy in ipairs(trophies) do
        local plate = plates[index]
        if plate then
            if trophy.Unlocked then
                plate.Material = Enum.Material.Neon
                plate.Color = Color3.fromRGB(111, 181, 188)
                plate.LocalTransparencyModifier = 0
            else
                plate.Material = Enum.Material.Metal
                plate.Color = Color3.fromRGB(59, 64, 69)
                plate.LocalTransparencyModifier = 0.22
            end
        end
    end
end

local function render(payload)
    local profile = payload.Profile or {}
    statLabels[1].Text = tostring(profile.Runs or 0)
    statLabels[2].Text = tostring(profile.BestDepth or 0)
    statLabels[3].Text = tostring(profile.Extractions or 0)
    statLabels[4].Text = tostring(profile.BossKills or 0)
    statLabels[5].Text = tostring(profile.PowerRank or 0)
    trophyHeader.Text = string.format("TROPHY WALL   %d / %d UNLOCKED", payload.Unlocked or 0, payload.Total or 7)

    for index, trophy in ipairs(payload.Trophies or {}) do
        local card = trophyCards[index]
        if card then
            card.Name.Text = trophy.Unlocked and trophy.Name or "LOCKED // " .. trophy.Name
            card.Description.Text = trophy.Description
            card.Progress.Text = string.format("%d / %d", trophy.Progress or 0, trophy.Target or 1)
            if trophy.Unlocked then
                card.Card.BackgroundColor3 = Color3.fromRGB(31, 53, 57)
                card.Name.TextColor3 = Color3.fromRGB(143, 220, 217)
                card.Progress.TextColor3 = Color3.fromRGB(117, 188, 193)
            else
                card.Card.BackgroundColor3 = Color3.fromRGB(29, 34, 39)
                card.Name.TextColor3 = Color3.fromRGB(174, 181, 186)
                card.Progress.TextColor3 = Color3.fromRGB(111, 128, 138)
            end
        end
    end

    updateWorldTrophies(payload.Trophies or {})
    shade.Visible = true
    panel.Size = UDim2.fromOffset(680, 438)
    panel.BackgroundTransparency = 0.18
    TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(720, 470),
        BackgroundTransparency = 0,
    }):Play()
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "OperatorRecord" and type(payload) == "table" then
        render(payload)
    end
end)
