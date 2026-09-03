local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Shared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local WorkerVisualFactory = require(shared:WaitForChild("WorkerVisualFactory"))

local MonsterStateUpdated = remotes:WaitForChild("MonsterStateUpdated")
local RequestMonsterState = remotes:WaitForChild("RequestMonsterState")

local known = {}
local pendingNew = {}
local lastHatchCount = 0
local initialized = false
local revealQueue = {}
local revealing = false

local rarityRank = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7,
    Exclusive = 8,
}

local gui = Instance.new("ScreenGui")
gui.Name = "MonsterFactoryHatchReveal"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 80
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local backdrop = Instance.new("TextButton")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(4, 7, 12)
backdrop.BackgroundTransparency = 1
backdrop.Text = ""
backdrop.AutoButtonColor = false
backdrop.Visible = false
backdrop.ZIndex = 1
backdrop.Parent = gui

local card = Instance.new("Frame")
card.Name = "RevealCard"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.48)
card.Size = UDim2.fromOffset(430, 520)
card.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
card.BackgroundTransparency = 0.02
card.BorderSizePixel = 0
card.Visible = false
card.ZIndex = 4
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 28)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Thickness = 3
cardStroke.Transparency = 0.05
cardStroke.Parent = card

local cardGradient = Instance.new("UIGradient")
cardGradient.Rotation = 90
cardGradient.Color = ColorSequence.new(
    Color3.fromRGB(38, 49, 66),
    Color3.fromRGB(14, 19, 28)
)
cardGradient.Parent = card

local scale = Instance.new("UIScale")
scale.Scale = 0.65
scale.Parent = card

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -30, 0, 38)
header.Position = UDim2.fromOffset(15, 18)
header.BackgroundTransparency = 1
header.Text = "NEW WORKER"
header.TextColor3 = Color3.fromRGB(245, 248, 255)
header.Font = Enum.Font.GothamBlack
header.TextSize = 24
header.ZIndex = 5
header.Parent = card

local rarity = Instance.new("TextLabel")
rarity.Size = UDim2.new(1, -30, 0, 28)
rarity.Position = UDim2.fromOffset(15, 57)
rarity.BackgroundTransparency = 1
rarity.Font = Enum.Font.GothamBold
rarity.TextSize = 15
rarity.ZIndex = 5
rarity.Parent = card

local viewport = Instance.new("ViewportFrame")
viewport.Name = "WorkerPreview"
viewport.Size = UDim2.new(1, -44, 0, 300)
viewport.Position = UDim2.fromOffset(22, 96)
viewport.BackgroundColor3 = Color3.fromRGB(11, 16, 24)
viewport.BackgroundTransparency = 0.05
viewport.BorderSizePixel = 0
viewport.Ambient = Color3.fromRGB(190, 200, 220)
viewport.LightColor = Color3.fromRGB(255, 255, 255)
viewport.LightDirection = Vector3.new(-1, -1, -1)
viewport.ZIndex = 5
viewport.Parent = card

local viewportCorner = Instance.new("UICorner")
viewportCorner.CornerRadius = UDim.new(0, 20)
viewportCorner.Parent = viewport

local viewportStroke = Instance.new("UIStroke")
viewportStroke.Thickness = 1.5
viewportStroke.Transparency = 0.2
viewportStroke.Parent = viewport

local camera = Instance.new("Camera")
camera.CFrame = CFrame.lookAt(Vector3.new(0, 3.1, -13.5), Vector3.new(0, 2.6, 0))
camera.FieldOfView = 35
camera.Parent = viewport
viewport.CurrentCamera = camera

local name = Instance.new("TextLabel")
name.Size = UDim2.new(1, -28, 0, 42)
name.Position = UDim2.fromOffset(14, 406)
name.BackgroundTransparency = 1
name.TextColor3 = Color3.fromRGB(248, 250, 255)
name.Font = Enum.Font.GothamBlack
name.TextSize = 24
name.ZIndex = 5
name.Parent = card

local bonus = Instance.new("TextLabel")
bonus.Size = UDim2.new(1, -28, 0, 28)
bonus.Position = UDim2.fromOffset(14, 449)
bonus.BackgroundTransparency = 1
bonus.TextColor3 = Color3.fromRGB(178, 192, 212)
bonus.Font = Enum.Font.GothamBold
bonus.TextSize = 13
bonus.ZIndex = 5
bonus.Parent = card

local dismiss = Instance.new("TextLabel")
dismiss.Size = UDim2.new(1, -28, 0, 22)
dismiss.Position = UDim2.fromOffset(14, 487)
dismiss.BackgroundTransparency = 1
dismiss.Text = "CLICK / TAP TO CONTINUE"
dismiss.TextColor3 = Color3.fromRGB(137, 151, 171)
dismiss.Font = Enum.Font.GothamMedium
dismiss.TextSize = 10
dismiss.ZIndex = 5
dismiss.Parent = card

local function clearViewport()
    for _, child in ipairs(viewport:GetChildren()) do
        if child ~= camera and not child:IsA("UICorner") and not child:IsA("UIStroke") then
            child:Destroy()
        end
    end
end

local dismissToken = 0
local function dismissCurrent()
    if not revealing then
        return
    end
    dismissToken += 1
    revealing = false

    TweenService:Create(scale, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Scale = 0.82,
    }):Play()
    TweenService:Create(card, TweenInfo.new(0.13), {
        BackgroundTransparency = 0.18,
    }):Play()
    TweenService:Create(backdrop, TweenInfo.new(0.15), {
        BackgroundTransparency = 1,
    }):Play()

    task.delay(0.16, function()
        card.Visible = false
        backdrop.Visible = false
        clearViewport()
        card.BackgroundTransparency = 0.02
        task.defer(function()
            if #revealQueue > 0 then
                local nextItem = table.remove(revealQueue, 1)
                local show
                show = nil
                -- deferred below through the queue runner
            end
        end)
    end)
end

backdrop.Activated:Connect(dismissCurrent)

local function addBurst(accent, intensity)
    for i = 1, intensity do
        local ray = Instance.new("Frame")
        ray.Name = "RevealRay"
        ray.AnchorPoint = Vector2.new(0.5, 1)
        ray.Position = UDim2.fromScale(0.5, 0.5)
        ray.Size = UDim2.fromOffset(4, 110 + i * 6)
        ray.BackgroundColor3 = accent
        ray.BackgroundTransparency = 0.12
        ray.BorderSizePixel = 0
        ray.Rotation = (360 / intensity) * (i - 1)
        ray.ZIndex = 2
        ray.Parent = backdrop

        local grad = Instance.new("UIGradient")
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.35, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        })
        grad.Parent = ray

        TweenService:Create(ray, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(2, 260 + i * 8),
            BackgroundTransparency = 1,
        }):Play()
        task.delay(0.58, function()
            if ray.Parent then ray:Destroy() end
        end)
    end
end

local function showReveal(item)
    if revealing or type(item) ~= "table" then
        return
    end
    revealing = true
    dismissToken += 1
    local token = dismissToken

    local rarityName = item.Rarity or "Common"
    local accent = WorkerVisualFactory.GetRarityColor(rarityName)
    local rank = rarityRank[rarityName] or 1

    cardStroke.Color = item.Shiny and Color3.fromRGB(255, 224, 91) or accent
    viewportStroke.Color = accent
    rarity.Text = (item.Shiny and "SHINY • " or "") .. string.upper(rarityName)
    rarity.TextColor3 = accent
    name.Text = item.DisplayName or item.MonsterId or "Worker"
    bonus.Text = string.format("FACTORY OUTPUT  +%d%%", math.floor((item.ProductionBonus or 0) * 100))
    header.Text = rank >= 5 and "LEGENDARY WORKER!" or (rank >= 4 and "EPIC WORKER!" or "NEW WORKER")

    clearViewport()
    local preview = WorkerVisualFactory.Create(item.MonsterId, item.Shiny == true, {
        Name = "RevealPreview",
        CFrame = CFrame.new(),
        Nameplate = false,
    })
    if preview then
        preview.Parent = viewport
        preview:PivotTo(CFrame.Angles(0, math.rad(18), 0))
    end

    backdrop.Visible = true
    card.Visible = true
    backdrop.BackgroundTransparency = 1
    scale.Scale = 0.62
    card.Rotation = -3

    addBurst(accent, math.clamp(5 + rank, 6, 12))
    TweenService:Create(backdrop, TweenInfo.new(0.18), {
        BackgroundTransparency = rank >= 5 and 0.20 or 0.34,
    }):Play()
    TweenService:Create(scale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Scale = rank >= 5 and 1.04 or 1,
    }):Play()
    TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Rotation = 0,
    }):Play()

    if rank >= 5 then
        task.delay(0.34, function()
            if revealing and token == dismissToken then
                TweenService:Create(scale, TweenInfo.new(0.16), { Scale = 1 }):Play()
            end
        end)
    end

    task.delay(2.8, function()
        if revealing and token == dismissToken then
            dismiss.Text = "CLICK / TAP TO CONTINUE"
        end
    end)
end

local function runQueue()
    if revealing or #revealQueue == 0 then
        return
    end
    local item = table.remove(revealQueue, 1)
    showReveal(item)
end

local oldDismissCurrent = dismissCurrent
dismissCurrent = function()
    if not revealing then return end
    oldDismissCurrent()
    task.delay(0.2, runQueue)
end

local function seed(state)
    known = {}
    pendingNew = {}
    lastHatchCount = tonumber(state and state.HatchCount) or 0
    for _, item in ipairs((state and state.Inventory) or {}) do
        if item.Uid then
            known[item.Uid] = true
        end
    end
    initialized = true
end

local function onMonsterState(state)
    if type(state) ~= "table" then
        return
    end
    if not initialized then
        seed(state)
        return
    end

    for _, item in ipairs(state.Inventory or {}) do
        if item.Uid and not known[item.Uid] then
            known[item.Uid] = true
            table.insert(pendingNew, item)
        end
    end

    local hatchCount = tonumber(state.HatchCount) or lastHatchCount
    local hatchDelta = math.max(0, hatchCount - lastHatchCount)
    if hatchDelta > 0 then
        for _ = 1, hatchDelta do
            if #pendingNew > 0 then
                table.insert(revealQueue, table.remove(pendingNew, 1))
            end
        end
        lastHatchCount = hatchCount
        runQueue()
    else
        -- A fusion can add a Shiny without increasing HatchCount. Keep the
        -- candidate briefly so the second hatch-state push can claim it, but
        -- discard obvious Shiny fusion additions from the hatch queue.
        for i = #pendingNew, 1, -1 do
            if pendingNew[i].Shiny then
                table.remove(pendingNew, i)
            end
        end
    end
end

task.spawn(function()
    local ok, state = pcall(function()
        return RequestMonsterState:InvokeServer()
    end)
    if ok and type(state) == "table" then
        seed(state)
    else
        initialized = true
    end
    MonsterStateUpdated.OnClientEvent:Connect(onMonsterState)
end)

print("[MonsterFactory] HatchReveal 006 ready.")
