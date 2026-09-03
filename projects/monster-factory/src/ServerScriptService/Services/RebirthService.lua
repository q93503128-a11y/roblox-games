local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local RebirthService = {}

local PlayerDataService
local RemoteService
local EconomyService
local ZoneService
local QuestService
local AchievementService
local OnboardingService
local AnalyticsService
local SecurityService

local function requirementFor(rebirths)
    return math.floor(
        GameConfig.REBIRTH_BASE_REQUIREMENT
        * (GameConfig.REBIRTH_REQUIREMENT_GROWTH ^ rebirths)
    )
end

local function tryRebirth(player)
    if not SecurityService.Allow(player, "Rebirth") then
        return
    end

    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    local requirement = requirementFor(data.Progress.Rebirths or 0)

    if data.Currency.Cash < requirement then
        RemoteService.Get("Toast"):FireClient(
            player,
            "Need $" .. tostring(requirement) .. " Cash to Rebirth."
        )
        return
    end

    data.Progress.Rebirths += 1
    data.Currency.RebirthTokens += 1

    data.Currency.Cash = GameConfig.STARTING_CASH
    data.Factory.PendingCash = 0
    data.Factory.GeneratorLevel = 1

    ZoneService.ResetToZoneOne(player)

    RemoteService.Get("Toast"):FireClient(
        player,
        "REBIRTH COMPLETE! Permanent production increased."
    )

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
    if AnalyticsService then
        AnalyticsService.Track(player, "rebirth", {
            Rebirths = data.Progress.Rebirths,
        })
    end
end

function RebirthService.Init(playerDataService, remoteService, zoneService, securityService)
    PlayerDataService = playerDataService
    RemoteService = remoteService
    ZoneService = zoneService
    SecurityService = securityService

    RemoteService.Get("RequestRebirth").OnServerEvent:Connect(tryRebirth)
end

function RebirthService.SetDependencies(
    economyService,
    questService,
    achievementService,
    onboardingService,
    analyticsService
)
    EconomyService = economyService
    QuestService = questService
    AchievementService = achievementService
    OnboardingService = onboardingService
    AnalyticsService = analyticsService
end

function RebirthService.GetRequirement(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return GameConfig.REBIRTH_BASE_REQUIREMENT
    end
    return requirementFor(data.Progress.Rebirths or 0)
end

return RebirthService
