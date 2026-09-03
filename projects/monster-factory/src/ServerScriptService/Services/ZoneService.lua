local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneConfig = require(ReplicatedStorage.Shared.ZoneConfig)

local ZoneService = {}

local PlayerDataService
local RemoteService
local EconomyService
local QuestService
local AchievementService
local OnboardingService
local ContextOfferService
local WorkerVisualService
local SecurityService

local function zoneState(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return nil
    end

    local zones = {}
    for zoneId = 1, 3 do
        local def = ZoneConfig.Get(zoneId)
        table.insert(zones, {
            Id = zoneId,
            DisplayName = def.DisplayName,
            UnlockCost = def.UnlockCost,
            Unlocked = zoneId <= data.Progress.HighestZone,
            Current = zoneId == data.Progress.CurrentZone,
            CapsuleId = def.CapsuleId,
            ProductionMultiplier = def.ProductionMultiplier,
        })
    end

    return {
        HighestZone = data.Progress.HighestZone,
        CurrentZone = data.Progress.CurrentZone,
        Zones = zones,
    }
end

local function pushState(player)
    local state = zoneState(player)
    if state then
        RemoteService.Get("ZoneStateUpdated"):FireClient(player, state)
    end
end

local function teleportToZone(player, zoneId)
    local def = ZoneConfig.Get(zoneId)
    if not def then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    character:PivotTo(CFrame.new(def.WorldPosition))
end

local function unlock(player, zoneId)
    if not SecurityService.IsSafePositiveInteger(zoneId, 1, 3) then
        return
    end

    if not SecurityService.Allow(player, "ZoneUnlock") then
        return
    end

    zoneId = math.floor(zoneId)

    local data = PlayerDataService.Get(player)
    local def = ZoneConfig.Get(zoneId)
    if not data or not def then
        return
    end

    if zoneId <= data.Progress.HighestZone then
        return
    end

    if zoneId ~= data.Progress.HighestZone + 1 then
        return
    end

    if not PlayerDataService.SpendCurrency(player, "Cash", def.UnlockCost) then
        RemoteService.Get("Toast"):FireClient(player, "Not enough Cash to unlock " .. def.DisplayName .. ".")
        return
    end

    data.Progress.HighestZone = zoneId
    data.Progress.CurrentZone = zoneId

    RemoteService.Get("Toast"):FireClient(player, "Unlocked " .. def.DisplayName .. "!")
    teleportToZone(player, zoneId)

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
    if WorkerVisualService then
        WorkerVisualService.PushState(player)
    end
end

local function travel(player, zoneId)
    if not SecurityService.IsSafePositiveInteger(zoneId, 1, 3) then
        return
    end

    if not SecurityService.Allow(player, "ZoneTravel") then
        return
    end

    zoneId = math.floor(zoneId)

    local data = PlayerDataService.Get(player)
    if not data or not ZoneConfig.Get(zoneId) then
        return
    end

    if zoneId > data.Progress.HighestZone then
        return
    end

    data.Progress.CurrentZone = zoneId
    teleportToZone(player, zoneId)
    pushState(player)

    if WorkerVisualService then
        WorkerVisualService.PushState(player)
    end
end

function ZoneService.Init(playerDataService, remoteService, securityService)
    PlayerDataService = playerDataService
    RemoteService = remoteService
    SecurityService = securityService

    RemoteService.Get("RequestZoneUnlock").OnServerEvent:Connect(unlock)
    RemoteService.Get("RequestZoneTravel").OnServerEvent:Connect(travel)

    RemoteService.Get("RequestZoneState").OnServerInvoke = function(player)
        return zoneState(player)
    end
end

function ZoneService.SetDependencies(
    economyService,
    questService,
    achievementService,
    onboardingService,
    contextOfferService,
    workerVisualService
)
    EconomyService = economyService
    QuestService = questService
    AchievementService = achievementService
    OnboardingService = onboardingService
    ContextOfferService = contextOfferService
    WorkerVisualService = workerVisualService
end

function ZoneService.OnPlayerReady(player)
    pushState(player)
end

function ZoneService.ResetToZoneOne(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    data.Progress.HighestZone = 1
    data.Progress.CurrentZone = 1
    teleportToZone(player, 1)
    pushState(player)

    if WorkerVisualService then
        WorkerVisualService.PushState(player)
    end
end

function ZoneService.PushState(player)
    pushState(player)
end

return ZoneService
