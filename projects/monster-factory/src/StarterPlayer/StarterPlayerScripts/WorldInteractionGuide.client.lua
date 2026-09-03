local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local shared = ReplicatedStorage:WaitForChild("Shared")
local CapsuleConfig = require(shared:WaitForChild("CapsuleConfig"))

local R = {
    StateUpdated = remotes:WaitForChild("StateUpdated"),
    MonsterStateUpdated = remotes:WaitForChild("MonsterStateUpdated"),
    ZoneStateUpdated = remotes:WaitForChild("ZoneStateUpdated"),
    RequestCollect = remotes:WaitForChild("RequestCollect"),
    RequestUpgrade = remotes:WaitForChild("RequestUpgrade"),
    RequestHatch = remotes:WaitForChild("RequestHatch"),
    RequestFullState = remotes:WaitForChild("RequestFullState"),
    RequestMonsterState = remotes:WaitForChild("RequestMonsterState"),
    RequestZoneState = remotes:WaitForChild("RequestZoneState"),
}

local world = workspace:WaitForChild("MonsterFactoryWorld", 10)
if not world then
    warn("[MonsterFactory] WorldInteractionGuide skipped: world missing.")
    return
end

local zoneDefs = {
    [1] = { Key = "Meadow", CapsuleId = "Meadow", Accent = Color3.fromRGB(75, 232, 132) },
    [2] = { Key = "Desert", CapsuleId = "Desert", Accent = Color3.fromRGB(255, 153, 63) },
    [3] = { Key = "Frozen", CapsuleId = "Frozen", Accent = Color3.fromRGB(83, 215, 255) },
}

local latestEconomy
local latestMonsters
local currentZone = 1
local markers = {}

local function rounded(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = obj
end

local function makeBillboard(part, titleText, subtitleText, accent)
    local old = part:FindFirstChild("MFInteractionBillboard")
    if old then old:Destroy() end

    local gui = Instance.new("BillboardGui")
    gui.Name = "MFInteractionBillboard"
    gui.Size = UDim2.fromOffset(190, 58)
    gui.StudsOffset = Vector3.new(0, math.max(4, part.Size.Y * 0.5 + 2.8), 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 95
    gui.Adornee = part
    gui.Parent = part

    local card = Instance.new("Frame")
    card.Size = UDim2.fromScale(1, 1)
    card.BackgroundColor3 = Color3.fromRGB(17, 22, 30)
    card.BackgroundTransparency = 0.06
    card.Parent = gui
    rounded(card, 11)

    local stroke = Instance.new("UIStroke")
    stroke.Color = accent
    stroke.Thickness = 1.6
    stroke.Transparency = 0.12
    stroke.Parent = card

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -10, 0, 30)
    title.Position = UDim2.fromOffset(5, 2)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = Color3.fromRGB(248, 250, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.Parent = card

    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, -10, 0, 21)
    subtitle.Position = UDim2.fromOffset(5, 31)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = subtitleText
    subtitle.TextColor3 = accent
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextSize = 11
    subtitle.Parent = card

    return {
        Gui = gui,
        Title = title,
        Subtitle = subtitle,
        Accent = accent,
    }
end

local function makePrompt(part, actionText, objectText, callback)
    local old = part:FindFirstChild("MFInteractionPrompt")
    if old then old:Destroy() end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "MFInteractionPrompt"
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    prompt.MaxActivationDistance = 11
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.ClickablePrompt = true
    prompt.Parent = part
    prompt.Triggered:Connect(callback)
    return prompt
end

local function openZonesWindow()
    local playerGui = player:FindFirstChild("PlayerGui")
    local hud = playerGui and playerGui:FindFirstChild("MonsterFactoryHUD")
    local zones = hud and hud:FindFirstChild("Zones")
    if zones then
        zones.Visible = true
    end
end

local function addZoneMarkers(zoneId, def)
    local zone = world:FindFirstChild(def.Key)
    if not zone then
        return
    end

    local generator = zone:FindFirstChild("Generator")
    local collector = zone:FindFirstChild("Collector")
    local capsule = zone:FindFirstChild(def.Key .. "CapsuleMachine")
    local zoneMarker = zone:FindFirstChild("ZoneMarker")

    local record = {
        ZoneId = zoneId,
        CapsuleId = def.CapsuleId,
    }
    markers[zoneId] = record

    if generator and generator:IsA("BasePart") then
        record.Generator = makeBillboard(generator, "GENERATOR", "Upgrade production", def.Accent)
        record.GeneratorPrompt = makePrompt(generator, "UPGRADE", "Factory Generator", function()
            if currentZone == zoneId then
                R.RequestUpgrade:FireServer()
            end
        end)
    end

    if collector and collector:IsA("BasePart") then
        record.Collector = makeBillboard(collector, "COLLECTOR", "Cash waiting", Color3.fromRGB(88, 241, 139))
        record.CollectorPrompt = makePrompt(collector, "COLLECT", "Cash Collector", function()
            if currentZone == zoneId then
                R.RequestCollect:FireServer()
            end
        end)
    end

    if capsule and capsule:IsA("BasePart") then
        record.Capsule = makeBillboard(capsule, "CAPSULE", "Hatch a worker", def.Accent)
        record.CapsulePrompt = makePrompt(capsule, "HATCH", "Monster Capsule", function()
            if currentZone == zoneId then
                R.RequestHatch:FireServer(def.CapsuleId)
            end
        end)
    end

    if zoneMarker and zoneMarker:IsA("BasePart") then
        record.Worlds = makeBillboard(zoneMarker, "WORLDS", "Travel • Unlock", def.Accent)
        record.WorldsPrompt = makePrompt(zoneMarker, "OPEN WORLDS", "Factory Worlds", function()
            if currentZone == zoneId then
                openZonesWindow()
            end
        end)
    end
end

for zoneId, def in pairs(zoneDefs) do
    addZoneMarkers(zoneId, def)
end

local function updateMarkerState()
    for zoneId, record in pairs(markers) do
        local enabled = zoneId == currentZone

        for _, prompt in ipairs({
            record.GeneratorPrompt,
            record.CollectorPrompt,
            record.CapsulePrompt,
            record.WorldsPrompt,
        }) do
            if prompt then
                prompt.Enabled = enabled
            end
        end

        for _, card in ipairs({ record.Generator, record.Collector, record.Capsule, record.Worlds }) do
            if card and card.Gui then
                card.Gui.Enabled = enabled
            end
        end
    end

    local record = markers[currentZone]
    if not record then
        return
    end

    if record.Generator and latestEconomy then
        record.Generator.Subtitle.Text = string.format(
            "Lv.%d  •  $%d",
            latestEconomy.GeneratorLevel or 1,
            math.floor(latestEconomy.NextUpgradeCost or 0)
        )
    end

    if record.Collector and latestEconomy then
        record.Collector.Subtitle.Text = "$" .. tostring(math.floor(latestEconomy.PendingCash or 0)) .. " ready"
    end

    if record.Capsule then
        local capsule = CapsuleConfig.Get(record.CapsuleId)
        if capsule then
            local firstFree = record.CapsuleId == "Meadow"
                and latestMonsters
                and (latestMonsters.HatchCount or 0) == 0
            record.Capsule.Subtitle.Text = firstFree
                and "FIRST HATCH FREE"
                or ("$" .. tostring(capsule.Cost) .. " per hatch")
        end
    end
end

local function applyEconomy(state)
    if type(state) ~= "table" then return end
    latestEconomy = state
    updateMarkerState()
end

local function applyMonsters(state)
    if type(state) ~= "table" then return end
    latestMonsters = state
    updateMarkerState()
end

local function applyZones(state)
    if type(state) ~= "table" then return end
    currentZone = state.CurrentZone or currentZone
    updateMarkerState()
end

R.StateUpdated.OnClientEvent:Connect(applyEconomy)
R.MonsterStateUpdated.OnClientEvent:Connect(applyMonsters)
R.ZoneStateUpdated.OnClientEvent:Connect(applyZones)

for _, request in ipairs({
    { R.RequestFullState, applyEconomy },
    { R.RequestMonsterState, applyMonsters },
    { R.RequestZoneState, applyZones },
}) do
    task.spawn(function()
        local ok, state = pcall(function()
            return request[1]:InvokeServer()
        end)
        if ok then
            request[2](state)
        end
    end)
end

updateMarkerState()
