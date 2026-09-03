local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local shared = ReplicatedStorage:WaitForChild("Shared")

local MonetizationConfig = require(shared:WaitForChild("MonetizationConfig"))
local CapsuleConfig = require(shared:WaitForChild("CapsuleConfig"))
local MonsterConfig = require(shared:WaitForChild("MonsterConfig"))

local R = {}
for _, name in ipairs({
    "StateUpdated", "MonsterStateUpdated", "ZoneStateUpdated",
    "QuestStateUpdated", "RewardStateUpdated", "AchievementStateUpdated",
    "OnboardingStateUpdated", "WorkerVisualStateUpdated", "ContextOffer", "Toast",
    "RequestUpgrade", "RequestCollect", "RequestHatch",
    "RequestToggleEquip", "RequestEquipBest", "RequestFuse",
    "RequestZoneUnlock", "RequestZoneTravel", "RequestRebirth",
    "RequestQuestClaim", "RequestDailyClaim", "RequestPlaytimeClaim",
    "RequestAchievementClaim",
    "RequestFullState", "RequestMonsterState", "RequestZoneState",
    "RequestQuestState", "RequestRewardState", "RequestAchievementState",
    "RequestOnboardingState", "RequestWorkerVisualState",
}) do
    R[name] = remotes:WaitForChild(name)
end

local gui = Instance.new("ScreenGui")
gui.Name = "MonsterFactoryHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function rounded(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 14)
    corner.Parent = instance
end

local function stroke(instance, thickness)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness or 2
    s.Transparency = 0.5
    s.Parent = instance
end

local function makeButton(parent, text, size)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(1, -16, 0, 44)
    b.Text = text
    b.TextScaled = true
    b.TextWrapped = true
    b.Font = Enum.Font.GothamBold
    b.Parent = parent
    rounded(b, 12)
    return b
end

local function makeWindow(name, maxSize)
    local f = Instance.new("Frame")
    f.Name = name
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Size = UDim2.new(0.86, 0, 0.76, 0)
    f.Position = UDim2.fromScale(0.5, 0.5)
    f.Visible = false
    f.Parent = gui

    local constraint = Instance.new("UISizeConstraint")
    constraint.MinSize = Vector2.new(
        math.min(300, maxSize.X),
        math.min(300, maxSize.Y)
    )
    constraint.MaxSize = maxSize
    constraint.Parent = f

    rounded(f, 18)
    stroke(f, 3)
    return f
end

local function clearGuiObjects(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local promptPass

local toast = Instance.new("TextLabel")
toast.Size = UDim2.new(0.52, 0, 0, 54)
toast.Position = UDim2.new(0.24, 0, 0.10, 0)
toast.Visible = false
toast.TextScaled = true
toast.TextWrapped = true
toast.Font = Enum.Font.GothamBold
toast.Parent = gui
rounded(toast, 14)

local function showToast(message)
    if type(message) ~= "string" then
        return
    end

    toast.Text = message
    toast.Visible = true

    local token = os.clock()
    toast:SetAttribute("Token", token)

    task.delay(2.4, function()
        if toast:GetAttribute("Token") == token then
            toast.Visible = false
        end
    end)
end

local contextOfferCard = Instance.new("Frame")
contextOfferCard.Size = UDim2.new(0, 360, 0, 132)
contextOfferCard.Position = UDim2.new(0.5, -180, 1, -150)
contextOfferCard.Visible = false
contextOfferCard.Parent = gui
rounded(contextOfferCard, 16)
stroke(contextOfferCard, 3)

local contextOfferText = Instance.new("TextLabel")
contextOfferText.Size = UDim2.new(1, -20, 0, 70)
contextOfferText.Position = UDim2.fromOffset(10, 8)
contextOfferText.BackgroundTransparency = 1
contextOfferText.TextScaled = true
contextOfferText.TextWrapped = true
contextOfferText.Font = Enum.Font.GothamBold
contextOfferText.Parent = contextOfferCard

local contextOfferBuy = makeButton(
    contextOfferCard,
    "VIEW OFFER",
    UDim2.new(0.62, -12, 0, 40)
)
contextOfferBuy.Position = UDim2.new(0, 10, 1, -48)

local contextOfferDismiss = makeButton(
    contextOfferCard,
    "NO THANKS",
    UDim2.new(0.38, -8, 0, 40)
)
contextOfferDismiss.Position = UDim2.new(0.62, 2, 1, -48)

local currentContextPass

contextOfferBuy.Activated:Connect(function()
    if currentContextPass then
        promptPass(currentContextPass)
    end
    contextOfferCard.Visible = false
    currentContextPass = nil
end)

contextOfferDismiss.Activated:Connect(function()
    contextOfferCard.Visible = false
    currentContextPass = nil
end)

-- onboarding banner
local onboarding = Instance.new("TextLabel")
onboarding.Size = UDim2.new(0.55, 0, 0, 52)
onboarding.Position = UDim2.new(0.225, 0, 0, 78)
onboarding.TextScaled = true
onboarding.TextWrapped = true
onboarding.Font = Enum.Font.GothamBold
onboarding.Parent = gui
rounded(onboarding, 12)

-- top bar
local top = Instance.new("Frame")
top.Size = UDim2.new(0.70, 0, 0, 62)
top.Position = UDim2.new(0.15, 0, 0, 10)
top.Parent = gui
rounded(top, 18)
stroke(top)

local topList = Instance.new("UIListLayout")
topList.FillDirection = Enum.FillDirection.Horizontal
topList.HorizontalAlignment = Enum.HorizontalAlignment.Center
topList.VerticalAlignment = Enum.VerticalAlignment.Center
topList.Parent = top

local function topLabel(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.166, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    l.Parent = top
    return l
end

local cashLabel = topLabel("$0")
local pendingLabel = topLabel("Collector $0")
local gemsLabel = topLabel("Gems 0")
local prodLabel = topLabel("+0/s")
local friendLabel = topLabel("Friends +0%")
local rebirthLabel = topLabel("R0")

-- left controls
local left = Instance.new("Frame")
left.Size = UDim2.fromOffset(210, 388)
left.Position = UDim2.new(0, 12, 0.5, -194)
left.Parent = gui
rounded(left, 18)
stroke(left)

local leftList = Instance.new("UIListLayout")
leftList.Padding = UDim.new(0, 7)
leftList.HorizontalAlignment = Enum.HorizontalAlignment.Center
leftList.Parent = left

local collectButton = makeButton(left, "COLLECT")
local hatchButton = makeButton(left, "HATCH")
local upgradeButton = makeButton(left, "UPGRADE")
local equipBestButton = makeButton(left, "EQUIP BEST")
local monstersButton = makeButton(left, "MONSTERS")
local zonesButton = makeButton(left, "ZONES")
local questsButton = makeButton(left, "QUESTS")
local achievementsButton = makeButton(left, "ACHIEVEMENTS")

-- right controls
local right = Instance.new("Frame")
right.Size = UDim2.fromOffset(145, 236)
right.Position = UDim2.new(1, -157, 0, 84)
right.Parent = gui
rounded(right, 16)
stroke(right)

local rightList = Instance.new("UIListLayout")
rightList.Padding = UDim.new(0, 7)
rightList.HorizontalAlignment = Enum.HorizontalAlignment.Center
rightList.Parent = right

local shopButton = makeButton(right, "SHOP")
local rewardsButton = makeButton(right, "REWARDS")
local indexButton = makeButton(right, "INDEX")
local rebirthButton = makeButton(right, "REBIRTH")

local leftScale = Instance.new("UIScale")
leftScale.Scale = 1
leftScale.Parent = left

local rightScale = Instance.new("UIScale")
rightScale.Scale = 1
rightScale.Parent = right

local function applyResponsiveLayout()
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local width = viewport.X
    local height = viewport.Y

    if width <= 600 then
        leftScale.Scale = 0.72
        rightScale.Scale = 0.72

        left.Position = UDim2.new(0, 8, 0.5, -140)
        right.Position = UDim2.new(1, -112, 0, 82)

        top.Size = UDim2.new(0.96, 0, 0, 54)
        top.Position = UDim2.new(0.02, 0, 0, 8)

        onboarding.Size = UDim2.new(0.70, 0, 0, 44)
        onboarding.Position = UDim2.new(0.15, 0, 0, 66)

        contextOfferCard.Size = UDim2.new(0.92, 0, 0, 118)
        contextOfferCard.Position = UDim2.new(0.04, 0, 1, -128)
    elseif width <= 900 then
        leftScale.Scale = 0.86
        rightScale.Scale = 0.86

        left.Position = UDim2.new(0, 10, 0.5, -168)
        right.Position = UDim2.new(1, -132, 0, 84)

        top.Size = UDim2.new(0.84, 0, 0, 58)
        top.Position = UDim2.new(0.08, 0, 0, 9)

        onboarding.Size = UDim2.new(0.62, 0, 0, 48)
        onboarding.Position = UDim2.new(0.19, 0, 0, 72)

        contextOfferCard.Size = UDim2.new(0, 360, 0, 125)
        contextOfferCard.Position = UDim2.new(0.5, -180, 1, -140)
    else
        leftScale.Scale = 1
        rightScale.Scale = 1

        left.Position = UDim2.new(0, 12, 0.5, -194)
        right.Position = UDim2.new(1, -157, 0, 84)

        top.Size = UDim2.new(0.70, 0, 0, 62)
        top.Position = UDim2.new(0.15, 0, 0, 10)

        onboarding.Size = UDim2.new(0.55, 0, 0, 52)
        onboarding.Position = UDim2.new(0.225, 0, 0, 78)

        contextOfferCard.Size = UDim2.new(0, 360, 0, 132)
        contextOfferCard.Position = UDim2.new(0.5, -180, 1, -150)
    end

    if height <= 650 and width <= 600 then
        leftScale.Scale = 0.66
        rightScale.Scale = 0.66
    end
end

if camera then
    camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
end

task.defer(applyResponsiveLayout)

-- generic windows
local shop = makeWindow("Shop", Vector2.new(430, 470))
local monsters = makeWindow("Monsters", Vector2.new(760, 560))
local zones = makeWindow("Zones", Vector2.new(600, 430))
local quests = makeWindow("Quests", Vector2.new(640, 500))
local rewards = makeWindow("Rewards", Vector2.new(620, 500))
local achievements = makeWindow("Achievements", Vector2.new(680, 520))
local indexWindow = makeWindow("Index", Vector2.new(680, 520))

local function titleAndClose(window, title)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -80, 0, 50)
    t.Position = UDim2.fromOffset(14, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextScaled = true
    t.Font = Enum.Font.GothamBold
    t.Parent = window

    local close = makeButton(window, "X", UDim2.fromOffset(50, 40))
    close.Position = UDim2.new(1, -60, 0, 12)
    close.Activated:Connect(function()
        window.Visible = false
    end)
end

titleAndClose(shop, "BOOST SHOP")
titleAndClose(monsters, "MONSTER WORKERS")
titleAndClose(zones, "FACTORY WORLDS")
titleAndClose(quests, "MILESTONE QUESTS")
titleAndClose(rewards, "REWARDS")
titleAndClose(achievements, "ACHIEVEMENTS")
titleAndClose(indexWindow, "MONSTER INDEX")

local function makeScroll(window)
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1, -30, 1, -75)
    s.Position = UDim2.fromOffset(15, 65)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.CanvasSize = UDim2.new()
    s.ScrollBarThickness = 7
    s.Parent = window

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.Parent = s

    return s
end

local shopScroll = makeScroll(shop)
local zonesScroll = makeScroll(zones)
local questsScroll = makeScroll(quests)
local rewardsScroll = makeScroll(rewards)
local achievementsScroll = makeScroll(achievements)
local indexScroll = makeScroll(indexWindow)

local monsterScroll = Instance.new("ScrollingFrame")
monsterScroll.Size = UDim2.new(1, -30, 1, -110)
monsterScroll.Position = UDim2.fromOffset(15, 100)
monsterScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
monsterScroll.CanvasSize = UDim2.new()
monsterScroll.Parent = monsters

local monsterGrid = Instance.new("UIGridLayout")
monsterGrid.CellSize = UDim2.fromOffset(215, 125)
monsterGrid.CellPadding = UDim2.fromOffset(10, 10)
monsterGrid.Parent = monsterScroll

local monstersInfo = Instance.new("TextLabel")
monstersInfo.Size = UDim2.new(1, -30, 0, 36)
monstersInfo.Position = UDim2.fromOffset(15, 60)
monstersInfo.BackgroundTransparency = 1
monstersInfo.TextScaled = true
monstersInfo.Parent = monsters

promptPass = function(pass)
    if pass.Id == 0 then
        showToast("Purchase IDs are not configured yet.")
        return
    end
    MarketplaceService:PromptGamePassPurchase(player, pass.Id)
end

local function promptProduct(product)
    if product.Id == 0 then
        showToast("Purchase IDs are not configured yet.")
        return
    end
    MarketplaceService:PromptProductPurchase(player, product.Id)
end

local storeOrder = {
    {"pass", MonetizationConfig.Passes.StarterPack},
    {"pass", MonetizationConfig.Passes.AutoCollect},
    {"pass", MonetizationConfig.Passes.ExtraEquip},
    {"pass", MonetizationConfig.Passes.VIP},
    {"pass", MonetizationConfig.Passes.BiggerStorage},
    {"pass", MonetizationConfig.Passes.FastHatch},
    {"product", MonetizationConfig.Products.Overdrive15},
    {"product", MonetizationConfig.Products.Overdrive60},
    {"product", MonetizationConfig.Products.GemsSmall},
    {"product", MonetizationConfig.Products.GemsMedium},
    {"product", MonetizationConfig.Products.RebirthSmall},
}

for _, entry in ipairs(storeOrder) do
    local kind = entry[1]
    local item = entry[2]
    local b = makeButton(shopScroll, item.DisplayName, UDim2.new(0.92, 0, 0, 42))

    if item.Id == 0 then
        b.Text = item.DisplayName .. " | DEV"
    else
        task.spawn(function()
            local infoType = kind == "pass" and Enum.InfoType.GamePass or Enum.InfoType.Product
            local ok, info = pcall(function()
                return MarketplaceService:GetProductInfo(item.Id, infoType)
            end)
            if ok and info and info.PriceInRobux then
                b.Text = item.DisplayName .. " | " .. tostring(info.PriceInRobux) .. " R$"
            end
        end)
    end

    b.Activated:Connect(function()
        if kind == "pass" then
            promptPass(item)
        else
            promptProduct(item)
        end
    end)
end

local latestEconomy
local latestMonsters
local latestZones
local currentWorkerFolder

local function rebuildMonsters(state)
    latestMonsters = state
    if type(state) ~= "table" then
        return
    end

    clearGuiObjects(monsterScroll)

    monstersInfo.Text = string.format(
        "%d/%d stored | %d/%d active",
        #(state.Inventory or {}),
        state.Storage or 0,
        #(state.Equipped or {}),
        state.EquipSlots or 0
    )

    for _, item in ipairs(state.Inventory or {}) do
        local card = Instance.new("Frame")
        card.Parent = monsterScroll
        rounded(card, 12)

        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -8, 0, 78)
        info.Position = UDim2.fromOffset(4, 2)
        info.BackgroundTransparency = 1
        info.Text = string.format(
            "%s%s\n%s | +%d%%",
            item.Shiny and "SHINY " or "",
            item.DisplayName,
            item.Rarity,
            math.floor((item.ProductionBonus or 0) * 100)
        )
        info.TextWrapped = true
        info.TextScaled = true
        info.Font = Enum.Font.GothamBold
        info.Parent = card

        local equip = makeButton(
            card,
            item.Equipped and "UNEQUIP" or "EQUIP",
            UDim2.new(0.58, -6, 0, 32)
        )
        equip.Position = UDim2.new(0, 4, 1, -36)
        equip.Activated:Connect(function()
            R.RequestToggleEquip:FireServer(item.Uid)
        end)

        local fuse = makeButton(
            card,
            item.Shiny and "SHINY" or "FUSE",
            UDim2.new(0.42, -6, 0, 32)
        )
        fuse.Position = UDim2.new(0.58, 2, 1, -36)
        fuse.Active = not item.Shiny
        fuse.AutoButtonColor = not item.Shiny
        fuse.Activated:Connect(function()
            if not item.Shiny then
                R.RequestFuse:FireServer(item.MonsterId)
            end
        end)
    end
end

local function rebuildZones(state)
    latestZones = state
    if type(state) ~= "table" then
        return
    end

    clearGuiObjects(zonesScroll)

    for _, zone in ipairs(state.Zones or {}) do
        local text
        if zone.Unlocked then
            text = zone.Current
                and ("CURRENT | " .. zone.DisplayName)
                or ("TRAVEL | " .. zone.DisplayName)
        else
            text = "UNLOCK " .. zone.DisplayName .. " | $" .. tostring(zone.UnlockCost)
        end

        local b = makeButton(zonesScroll, text, UDim2.new(0.96, 0, 0, 72))
        b.Activated:Connect(function()
            if zone.Unlocked then
                R.RequestZoneTravel:FireServer(zone.Id)
            else
                R.RequestZoneUnlock:FireServer(zone.Id)
            end
        end)
    end
end

local function rebuildQuests(state)
    if type(state) ~= "table" then
        return
    end

    clearGuiObjects(questsScroll)

    for _, quest in ipairs(state.Quests or {}) do
        local status = quest.Claimed
            and "CLAIMED"
            or (quest.Complete and "CLAIM" or (tostring(quest.Progress) .. "/" .. tostring(quest.Target)))

        local b = makeButton(
            questsScroll,
            quest.DisplayName .. "\n" .. status,
            UDim2.new(0.96, 0, 0, 70)
        )

        b.Active = quest.Complete and not quest.Claimed
        b.AutoButtonColor = b.Active
        b.Activated:Connect(function()
            if b.Active then
                R.RequestQuestClaim:FireServer(quest.Id)
            end
        end)
    end
end

local function rebuildAchievements(state)
    if type(state) ~= "table" then
        return
    end

    clearGuiObjects(achievementsScroll)

    for _, item in ipairs(state.Achievements or {}) do
        local status = item.Claimed
            and "CLAIMED"
            or (item.Complete and "CLAIM" or (tostring(item.Progress) .. "/" .. tostring(item.Target)))

        local b = makeButton(
            achievementsScroll,
            item.DisplayName .. "\n" .. item.Description .. "\n" .. status,
            UDim2.new(0.96, 0, 0, 88)
        )

        b.Active = item.Complete and not item.Claimed
        b.AutoButtonColor = b.Active
        b.Activated:Connect(function()
            if b.Active then
                R.RequestAchievementClaim:FireServer(item.Id)
            end
        end)
    end
end

local function rebuildIndex()
    clearGuiObjects(indexScroll)

    local discovered = {}
    if latestMonsters then
        for _, item in ipairs(latestMonsters.Inventory or {}) do
            discovered[item.MonsterId] = true
        end
    end

    local entries = {}
    for monsterId, def in pairs(MonsterConfig.Definitions) do
        if not def.Exclusive then
            table.insert(entries, {
                MonsterId = monsterId,
                Zone = def.Zone,
                DisplayName = discovered[monsterId] and def.DisplayName or "???",
                Rarity = discovered[monsterId] and def.Rarity or "Unknown",
            })
        end
    end

    table.sort(entries, function(a, b)
        if a.Zone == b.Zone then
            return a.MonsterId < b.MonsterId
        end
        return a.Zone < b.Zone
    end)

    for _, entry in ipairs(entries) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.96, 0, 0, 54)
        label.BackgroundTransparency = 0.1
        label.Text = "Zone " .. tostring(entry.Zone)
            .. " | " .. entry.DisplayName
            .. " | " .. entry.Rarity
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = indexScroll
        rounded(label, 10)
    end
end

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60

    if h > 0 then
        return string.format("%dh %02dm", h, m)
    end

    return string.format("%dm %02ds", m, s)
end

local function rebuildRewards(state)
    if type(state) ~= "table" then
        return
    end

    clearGuiObjects(rewardsScroll)

    local dailyText = state.Daily.CanClaim
        and "DAILY REWARD | CLAIM"
        or ("DAILY REWARD | " .. formatTime(state.Daily.NextAvailableSeconds))

    local daily = makeButton(rewardsScroll, dailyText, UDim2.new(0.96, 0, 0, 70))
    daily.Active = state.Daily.CanClaim
    daily.AutoButtonColor = daily.Active
    daily.Activated:Connect(function()
        if daily.Active then
            R.RequestDailyClaim:FireServer()
        end
    end)

    for _, item in ipairs(state.Playtime or {}) do
        local text

        if item.Claimed then
            text = "PLAYTIME " .. formatTime(item.Seconds) .. " | CLAIMED"
        elseif item.Available then
            text = "PLAYTIME " .. formatTime(item.Seconds) .. " | CLAIM"
        else
            text = "PLAYTIME " .. formatTime(item.Seconds)
                .. " | " .. formatTime(item.Progress)
        end

        local b = makeButton(rewardsScroll, text, UDim2.new(0.96, 0, 0, 65))
        b.Active = item.Available
        b.AutoButtonColor = b.Active
        b.Activated:Connect(function()
            if b.Active then
                R.RequestPlaytimeClaim:FireServer(item.Id)
            end
        end)
    end
end

local function applyOnboarding(state)
    if type(state) ~= "table" or state.Finished then
        onboarding.Visible = false
        return
    end

    onboarding.Visible = true
    onboarding.Text = "NEXT: " .. state.DisplayName
        .. " (" .. tostring(state.Progress)
        .. "/" .. tostring(state.Target) .. ")"
end

local function applyWorkers(state)
    if currentWorkerFolder then
        currentWorkerFolder:Destroy()
        currentWorkerFolder = nil
    end

    if type(state) ~= "table" then
        return
    end

    local world = workspace:FindFirstChild("MonsterFactoryWorld")
    if not world then
        return
    end

    local zoneKeys = {
        [1] = "Meadow",
        [2] = "Desert",
        [3] = "Frozen",
    }

    local zone = world:FindFirstChild(zoneKeys[state.CurrentZone or 1])
    if not zone then
        return
    end

    local stations = zone:FindFirstChild("WorkerStations")
    if not stations then
        return
    end

    local stationList = stations:GetChildren()
    table.sort(stationList, function(a, b)
        return (a:GetAttribute("WorkerSlot") or 999) < (b:GetAttribute("WorkerSlot") or 999)
    end)

    local folder = Instance.new("Folder")
    folder.Name = "ClientWorkerVisuals"
    folder.Parent = workspace
    currentWorkerFolder = folder

    for index, worker in ipairs(state.Workers or {}) do
        local station = stationList[index]
        if not station or not station:IsA("BasePart") then
            break
        end

        local orb = Instance.new("Part")
        orb.Name = "Worker_" .. tostring(index)
        orb.Shape = Enum.PartType.Ball
        orb.Size = worker.Shiny
            and Vector3.new(3.2, 3.2, 3.2)
            or Vector3.new(2.6, 2.6, 2.6)
        orb.Material = worker.Shiny and Enum.Material.Neon or Enum.Material.SmoothPlastic
        orb.Color = worker.Color or Color3.new(1, 1, 1)
        orb.CanCollide = false
        orb.Anchored = true
        orb.CFrame = station.CFrame * CFrame.new(0, 2.6, 0)
        orb.Parent = folder

        local label = Instance.new("BillboardGui")
        label.Size = UDim2.fromOffset(140, 34)
        label.StudsOffset = Vector3.new(0, 2.0, 0)
        label.AlwaysOnTop = true
        label.Parent = orb

        local text = Instance.new("TextLabel")
        text.Size = UDim2.fromScale(1, 1)
        text.BackgroundTransparency = 1
        text.Text = (worker.Shiny and "SHINY " or "") .. worker.DisplayName
        text.TextScaled = true
        text.Font = Enum.Font.GothamBold
        text.Parent = label
    end
end

local function applyEconomy(state)
    latestEconomy = state
    if type(state) ~= "table" then
        return
    end

    cashLabel.Text = "$" .. tostring(math.floor(state.Cash or 0))
    pendingLabel.Text = "Collector $" .. tostring(math.floor(state.PendingCash or 0))
    gemsLabel.Text = "Gems " .. tostring(math.floor(state.Gems or 0))
    prodLabel.Text = "+" .. tostring(math.floor(state.ProductionPerSecond or 0)) .. "/s"
    friendLabel.Text = "Friends +" .. tostring(math.floor((state.FriendBonus or 0) * 100)) .. "%"
    rebirthLabel.Text = "R" .. tostring(state.Rebirths or 0)

    collectButton.Text = "COLLECT $" .. tostring(math.floor(state.PendingCash or 0))
    if state.Passes and state.Passes.AutoCollect then
        collectButton.Text = "AUTO COLLECT ON"
    end

    upgradeButton.Text = string.format(
        "UPGRADE Lv.%d | $%d",
        state.GeneratorLevel or 1,
        state.NextUpgradeCost or 0
    )

    rebirthButton.Text = "REBIRTH\n$" .. tostring(state.NextRebirthRequirement or 0)

    if latestZones then
        for _, zone in ipairs(latestZones.Zones or {}) do
            if zone.Current then
                local capsule = CapsuleConfig.Get(zone.CapsuleId)

                if capsule then
                    if zone.Id == 1
                        and latestMonsters
                        and (latestMonsters.HatchCount or 0) == 0
                    then
                        hatchButton.Text = "FREE FIRST HATCH"
                    else
                        hatchButton.Text = "HATCH | $" .. tostring(capsule.Cost)
                    end
                end

                break
            end
        end
    end
end

local function handleContextOffer(payload)
    if type(payload) ~= "table" or type(payload.Key) ~= "string" then
        return
    end

    local pass = MonetizationConfig.Passes[payload.Key]
    if not pass then
        return
    end

    currentContextPass = pass
    contextOfferText.Text = "RECOMMENDED\n" .. pass.DisplayName
    contextOfferCard.Visible = true
end

collectButton.Activated:Connect(function()
    R.RequestCollect:FireServer()
end)

hatchButton.Activated:Connect(function()
    if not latestZones then
        return
    end

    for _, zone in ipairs(latestZones.Zones or {}) do
        if zone.Current then
            R.RequestHatch:FireServer(zone.CapsuleId)
            return
        end
    end
end)

upgradeButton.Activated:Connect(function()
    R.RequestUpgrade:FireServer()
end)

equipBestButton.Activated:Connect(function()
    R.RequestEquipBest:FireServer()
end)

rebirthButton.Activated:Connect(function()
    R.RequestRebirth:FireServer()
end)

monstersButton.Activated:Connect(function()
    monsters.Visible = true
end)

zonesButton.Activated:Connect(function()
    zones.Visible = true
end)

questsButton.Activated:Connect(function()
    quests.Visible = true
end)

achievementsButton.Activated:Connect(function()
    achievements.Visible = true
end)

shopButton.Activated:Connect(function()
    shop.Visible = true
end)

rewardsButton.Activated:Connect(function()
    rewards.Visible = true
end)

indexButton.Activated:Connect(function()
    rebuildIndex()
    indexWindow.Visible = true
end)

R.StateUpdated.OnClientEvent:Connect(applyEconomy)

R.MonsterStateUpdated.OnClientEvent:Connect(function(state)
    rebuildMonsters(state)
    rebuildIndex()
    applyEconomy(latestEconomy)
end)

R.ZoneStateUpdated.OnClientEvent:Connect(function(state)
    rebuildZones(state)
    applyEconomy(latestEconomy)
end)

R.QuestStateUpdated.OnClientEvent:Connect(rebuildQuests)
R.RewardStateUpdated.OnClientEvent:Connect(rebuildRewards)
R.AchievementStateUpdated.OnClientEvent:Connect(rebuildAchievements)
R.OnboardingStateUpdated.OnClientEvent:Connect(applyOnboarding)
R.WorkerVisualStateUpdated.OnClientEvent:Connect(applyWorkers)
R.ContextOffer.OnClientEvent:Connect(handleContextOffer)
R.Toast.OnClientEvent:Connect(showToast)

task.spawn(function()
    local requests = {
        { R.RequestFullState, applyEconomy },
        { R.RequestMonsterState, rebuildMonsters },
        { R.RequestZoneState, rebuildZones },
        { R.RequestQuestState, rebuildQuests },
        { R.RequestRewardState, rebuildRewards },
        { R.RequestAchievementState, rebuildAchievements },
        { R.RequestOnboardingState, applyOnboarding },
        { R.RequestWorkerVisualState, applyWorkers },
    }

    for _, pair in ipairs(requests) do
        local ok, state = pcall(function()
            return pair[1]:InvokeServer()
        end)

        if ok then
            pair[2](state)
        end
    end

    rebuildIndex()
    applyEconomy(latestEconomy)
end)
