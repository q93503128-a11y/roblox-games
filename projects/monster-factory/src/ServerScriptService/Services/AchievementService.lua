local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AchievementConfig = require(ReplicatedStorage.Shared.AchievementConfig)

local AchievementService = {}

local PlayerDataService
local RemoteService
local EconomyService
local AnalyticsService
local SecurityService

local function metricValue(data, metric)
    if metric == "TotalCashCollected" then
        return math.floor(data.Stats.TotalCashCollected or 0)
    elseif metric == "TotalHatches" then
        return math.floor(data.Stats.TotalHatches or 0)
    elseif metric == "HighestZone" then
        return math.floor(data.Progress.HighestZone or 1)
    elseif metric == "Rebirths" then
        return math.floor(data.Progress.Rebirths or 0)
    elseif metric == "ShinyCreated" then
        return math.floor(data.Stats.ShinyCreated or 0)
    end
    return 0
end

local function grant(data, reward)
    if reward.Gems then
        data.Currency.Gems += reward.Gems
    end
    if reward.RebirthTokens then
        data.Currency.RebirthTokens += reward.RebirthTokens
    end
    if reward.UpgradeTokens then
        data.Factory.UpgradeTokens += reward.UpgradeTokens
    end
end

local function stateFor(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return nil
    end

    local items = {}

    for _, achievementId in ipairs(AchievementConfig.Order) do
        local def = AchievementConfig.Definitions[achievementId]
        local progress = metricValue(data, def.Metric)
        local claimed = data.Achievements.Claimed[achievementId] == true

        table.insert(items, {
            Id = def.Id,
            DisplayName = def.DisplayName,
            Description = def.Description,
            Progress = math.min(progress, def.Target),
            Target = def.Target,
            Complete = progress >= def.Target,
            Claimed = claimed,
            Reward = def.Reward,
        })
    end

    return {
        Achievements = items,
    }
end

local function pushState(player)
    local state = stateFor(player)
    if state then
        RemoteService.Get("AchievementStateUpdated"):FireClient(player, state)
    end
end

local function claim(player, achievementId)
    if not SecurityService.IsSafeId(achievementId, 60) then
        return
    end

    if not SecurityService.Allow(player, "AchievementClaim") then
        return
    end

    local data = PlayerDataService.Get(player)
    local def = AchievementConfig.Definitions[achievementId]
    if not data or not def then
        return
    end

    if data.Achievements.Claimed[achievementId] then
        return
    end

    if metricValue(data, def.Metric) < def.Target then
        return
    end

    grant(data, def.Reward)
    data.Achievements.Claimed[achievementId] = true

    RemoteService.Get("Toast"):FireClient(player, "Achievement claimed: " .. def.DisplayName)

    if AnalyticsService then
        AnalyticsService.Track(player, "achievement_claim", {
            AchievementId = achievementId,
        })
    end

    pushState(player)

    if EconomyService then
        EconomyService.PushState(player)
    end
end

function AchievementService.Init(playerDataService, remoteService, securityService)
    PlayerDataService = playerDataService
    RemoteService = remoteService
    SecurityService = securityService

    RemoteService.Get("RequestAchievementClaim").OnServerEvent:Connect(claim)

    RemoteService.Get("RequestAchievementState").OnServerInvoke = function(player)
        return stateFor(player)
    end
end

function AchievementService.SetDependencies(economyService, analyticsService)
    EconomyService = economyService
    AnalyticsService = analyticsService
end

function AchievementService.PushState(player)
    pushState(player)
end

function AchievementService.OnPlayerReady(player)
    pushState(player)
end

return AchievementService
