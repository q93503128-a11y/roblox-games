local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local MonsterConfig = require(ReplicatedStorage.Shared.MonsterConfig)
local CapsuleConfig = require(ReplicatedStorage.Shared.CapsuleConfig)

local MonsterService = {}

local PlayerDataService
local PassService
local RemoteService
local EconomyService
local QuestService
local AchievementService
local OnboardingService
local WorkerVisualService
local ContextOfferService
local SecurityService

local random = Random.new()
local lastHatch = {}

local function findInventoryItem(data, uid)
    for index, item in ipairs(data.Monsters.Inventory) do
        if item.Uid == uid then
            return item, index
        end
    end
    return nil, nil
end

local function isEquipped(data, uid)
    for _, equippedUid in ipairs(data.Monsters.Equipped) do
        if equippedUid == uid then
            return true
        end
    end
    return false
end

local function removeEquipped(data, uid)
    for index = #data.Monsters.Equipped, 1, -1 do
        if data.Monsters.Equipped[index] == uid then
            table.remove(data.Monsters.Equipped, index)
        end
    end
end

local function inventoryCount(data)
    return #data.Monsters.Inventory
end

local function publicState(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return nil
    end

    local inventory = {}
    for _, item in ipairs(data.Monsters.Inventory) do
        local def = MonsterConfig.Get(item.MonsterId)
        if def then
            table.insert(inventory, {
                Uid = item.Uid,
                MonsterId = item.MonsterId,
                DisplayName = def.DisplayName,
                Rarity = def.Rarity,
                ProductionBonus = MonsterConfig.GetEffectiveBonus(item.MonsterId, item.Shiny == true),
                Shiny = item.Shiny == true,
                Equipped = isEquipped(data, item.Uid),
                SortPower = (def.SortPower or 0) * (item.Shiny and GameConfig.SHINY_POWER_MULTIPLIER or 1),
            })
        end
    end

    table.sort(inventory, function(a, b)
        if a.SortPower == b.SortPower then
            return a.DisplayName < b.DisplayName
        end
        return a.SortPower > b.SortPower
    end)

    return {
        Inventory = inventory,
        Equipped = table.clone(data.Monsters.Equipped),
        EquipSlots = PassService.GetEquipSlots(player),
        Storage = PassService.GetStorage(player),
        HatchCount = data.Monsters.HatchCount or 0,
    }
end

local function pushState(player)
    local state = publicState(player)
    if state then
        RemoteService.Get("MonsterStateUpdated"):FireClient(player, state)
    end
end

function MonsterService.GetProductionMultiplier(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return 1
    end

    local totalBonus = 0
    for _, uid in ipairs(data.Monsters.Equipped) do
        local item = findInventoryItem(data, uid)
        if item then
            totalBonus += MonsterConfig.GetEffectiveBonus(item.MonsterId, item.Shiny == true)
        end
    end

    return 1 + totalBonus
end

function MonsterService.GrantMonster(player, monsterId, options)
    options = options or {}

    local data = PlayerDataService.Get(player)
    local def = MonsterConfig.Get(monsterId)
    if not data or not def then
        return nil
    end

    if not options.IgnoreStorage and inventoryCount(data) >= PassService.GetStorage(player) then
        return nil
    end

    local item = {
        Uid = HttpService:GenerateGUID(false),
        MonsterId = monsterId,
        Shiny = options.Shiny == true,
        CreatedAt = os.time(),
    }

    table.insert(data.Monsters.Inventory, item)

    if options.AutoEquip then
        local maxSlots = PassService.GetEquipSlots(player)
        if #data.Monsters.Equipped < maxSlots then
            table.insert(data.Monsters.Equipped, item.Uid)
        end
    end

    pushState(player)
    if EconomyService then
        EconomyService.PushState(player)
    end
    if WorkerVisualService then
        WorkerVisualService.PushState(player)
    end
    if OnboardingService then
        OnboardingService.PushState(player)
    end

    return item
end

local function chooseWeighted(entries)
    local total = 0
    for _, entry in ipairs(entries) do
        total += entry.Weight
    end

    local roll = random:NextInteger(1, total)
    local running = 0

    for _, entry in ipairs(entries) do
        running += entry.Weight
        if roll <= running then
            return entry.MonsterId
        end
    end

    return entries[#entries].MonsterId
end

local function tryHatch(player, capsuleId)
    if not SecurityService.IsSafeId(capsuleId, 40) then
        return
    end

    if not SecurityService.Allow(player, "Hatch") then
        return
    end

    local now = os.clock()
    local previous = lastHatch[player] or 0
    local cooldown = GameConfig.CAPSULE_HATCH_COOLDOWN
    if PassService.Get(player, "FastHatch") then
        cooldown = 0.12
    end
    if now - previous < cooldown then
        return
    end
    lastHatch[player] = now

    local data = PlayerDataService.Get(player)
    local capsule = CapsuleConfig.Get(capsuleId)
    if not data or not capsule then
        return
    end

    if capsule.Zone > (data.Progress.HighestZone or 1) then
        return
    end

    if capsule.Zone ~= (data.Progress.CurrentZone or 1) then
        RemoteService.Get("Toast"):FireClient(player, "Travel to that zone before hatching.")
        return
    end

    if inventoryCount(data) >= PassService.GetStorage(player) then
        RemoteService.Get("Toast"):FireClient(player, "Monster storage is full.")
        return
    end

    local isFree = capsule.FirstHatchFree and (data.Monsters.HatchCount or 0) == 0
    if not isFree then
        if not PlayerDataService.SpendCurrency(player, capsule.Currency, capsule.Cost) then
            RemoteService.Get("Toast"):FireClient(player, "Not enough " .. capsule.Currency .. ".")
            return
        end
    end

    local monsterId = chooseWeighted(capsule.Entries)
    local item = MonsterService.GrantMonster(player, monsterId, { AutoEquip = true })
    if not item then
        return
    end

    data.Monsters.HatchCount += 1
    data.Stats.TotalHatches += 1

    local def = MonsterConfig.Get(monsterId)
    RemoteService.Get("Toast"):FireClient(
        player,
        string.format("Hatched %s [%s]!", def.DisplayName, def.Rarity)
    )

    pushState(player)
    if EconomyService then
        EconomyService.PushState(player)
    end
    if QuestService then
        QuestService.PushState(player)
    end
    if AchievementService then
        AchievementService.PushState(player)
    end
    if OnboardingService then
        OnboardingService.PushState(player)
    end
    if ContextOfferService then
        ContextOfferService.Evaluate(player)
    end
end

local function toggleEquip(player, uid)
    if type(uid) ~= "string" or #uid > 64 then
        return
    end

    if not SecurityService.Allow(player, "ToggleEquip") then
        return
    end

    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    local item = findInventoryItem(data, uid)
    if not item then
        return
    end

    if isEquipped(data, uid) then
        removeEquipped(data, uid)
    else
        if #data.Monsters.Equipped >= PassService.GetEquipSlots(player) then
            RemoteService.Get("Toast"):FireClient(player, "All worker slots are occupied.")
            return
        end
        table.insert(data.Monsters.Equipped, uid)
    end

    pushState(player)
    if EconomyService then
        EconomyService.PushState(player)
    end
    if WorkerVisualService then
        WorkerVisualService.PushState(player)
    end
    if OnboardingService then
        OnboardingService.PushState(player)
    end
    if ContextOfferService then
        ContextOfferService.Evaluate(player)
    end
end

local function equipBest(player)
    if not SecurityService.Allow(player, "EquipBest") then
        return
    end

    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    local candidates = {}
    for _, item in ipairs(data.Monsters.Inventory) do
        local def = MonsterConfig.Get(item.MonsterId)
        if def then
            table.insert(candidates, {
                Uid = item.Uid,
                Power = (def.SortPower or 0) * (item.Shiny and GameConfig.SHINY_POWER_MULTIPLIER or 1),
            })
        end
    end

    table.sort(candidates, function(a, b)
        return a.Power > b.Power
    end)

    data.Monsters.Equipped = {}
    local slots = PassService.GetEquipSlots(player)
    for index = 1, math.min(slots, #candidates) do
        table.insert(data.Monsters.Equipped, candidates[index].Uid)
    end

    pushState(player)
    if EconomyService then
        EconomyService.PushState(player)
    end
    if WorkerVisualService then
        WorkerVisualService.PushState(player)
    end
    if OnboardingService then
        OnboardingService.PushState(player)
    end
end

local function fuse(player, monsterId)
    if not SecurityService.IsSafeId(monsterId, 40) or not MonsterConfig.Get(monsterId) then
        return
    end

    if not SecurityService.Allow(player, "Fuse") then
        return
    end

    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    local eligible = {}
    for index, item in ipairs(data.Monsters.Inventory) do
        if item.MonsterId == monsterId and item.Shiny ~= true and not isEquipped(data, item.Uid) then
            table.insert(eligible, { Index = index, Uid = item.Uid })
        end
    end

    if #eligible < GameConfig.SHINY_REQUIRED_DUPLICATES then
        RemoteService.Get("Toast"):FireClient(
            player,
            "Need 5 unequipped duplicates to make a Shiny."
        )
        return
    end

    table.sort(eligible, function(a, b)
        return a.Index > b.Index
    end)

    for i = 1, GameConfig.SHINY_REQUIRED_DUPLICATES do
        table.remove(data.Monsters.Inventory, eligible[i].Index)
    end

    MonsterService.GrantMonster(player, monsterId, {
        Shiny = true,
        AutoEquip = false,
        IgnoreStorage = true,
    })

    data.Stats.ShinyCreated = (data.Stats.ShinyCreated or 0) + 1

    RemoteService.Get("Toast"):FireClient(player, "Shiny fusion complete!")
    pushState(player)

    if AchievementService then
        AchievementService.PushState(player)
    end
end

function MonsterService.Init(playerDataService, passService, remoteService, securityService)
    PlayerDataService = playerDataService
    PassService = passService
    RemoteService = remoteService
    SecurityService = securityService

    RemoteService.Get("RequestHatch").OnServerEvent:Connect(tryHatch)
    RemoteService.Get("RequestToggleEquip").OnServerEvent:Connect(toggleEquip)
    RemoteService.Get("RequestEquipBest").OnServerEvent:Connect(equipBest)
    RemoteService.Get("RequestFuse").OnServerEvent:Connect(fuse)

    RemoteService.Get("RequestMonsterState").OnServerInvoke = function(player)
        return publicState(player)
    end
end

function MonsterService.SetDependencies(
    economyService,
    questService,
    achievementService,
    onboardingService,
    workerVisualService,
    contextOfferService
)
    EconomyService = economyService
    QuestService = questService
    AchievementService = achievementService
    OnboardingService = onboardingService
    WorkerVisualService = workerVisualService
    ContextOfferService = contextOfferService
end

function MonsterService.OnPlayerReady(player)
    pushState(player)
    if WorkerVisualService then
        WorkerVisualService.PushState(player)
    end
end

function MonsterService.Remove(player)
    lastHatch[player] = nil
end

return MonsterService
