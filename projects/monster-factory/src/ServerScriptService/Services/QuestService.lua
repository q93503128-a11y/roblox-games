local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestConfig = require(ReplicatedStorage.Shared.QuestConfig)

local QuestService = {}

local PlayerDataService
local RemoteService
local EconomyService
local SecurityService

local function metricValue(data, metric)
    if metric == "TotalCashCollected" then
        return math.floor(data.Stats.TotalCashCollected or 0)
    elseif metric == "TotalHatches" then
        return math.floor(data.Stats.TotalHatches or 0)
    elseif metric == "GeneratorLevel" then
        return math.floor(data.Factory.GeneratorLevel or 1)
    elseif metric == "HighestZone" then
        return math.floor(data.Progress.HighestZone or 1)
    elseif metric == "Rebirths" then
        return math.floor(data.Progress.Rebirths or 0)
    end
    return 0
end

local function grantReward(data, reward)
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

    local quests = {}

    for _, questId in ipairs(QuestConfig.Order) do
        local def = QuestConfig.Definitions[questId]
        local progress = metricValue(data, def.Metric)
        local claimed = data.Quests.Claimed[questId] == true

        table.insert(quests, {
            Id = def.Id,
            DisplayName = def.DisplayName,
            Progress = math.min(progress, def.Target),
            Target = def.Target,
            Complete = progress >= def.Target,
            Claimed = claimed,
            Reward = def.Reward,
        })
    end

    return { Quests = quests }
end

local function pushState(player)
    local state = stateFor(player)
    if state then
        RemoteService.Get("QuestStateUpdated"):FireClient(player, state)
    end
end

local function claim(player, questId)
    if not SecurityService.IsSafeId(questId, 50) then
        return
    end

    if not SecurityService.Allow(player, "QuestClaim") then
        return
    end

    local data = PlayerDataService.Get(player)
    local def = QuestConfig.Definitions[questId]
    if not data or not def then
        return
    end

    if data.Quests.Claimed[questId] then
        return
    end

    if metricValue(data, def.Metric) < def.Target then
        return
    end

    grantReward(data, def.Reward)
    data.Quests.Claimed[questId] = true

    RemoteService.Get("Toast"):FireClient(player, "Quest reward claimed!")
    pushState(player)

    if EconomyService then
        EconomyService.PushState(player)
    end
end

function QuestService.Init(playerDataService, remoteService, securityService)
    PlayerDataService = playerDataService
    RemoteService = remoteService
    SecurityService = securityService

    RemoteService.Get("RequestQuestClaim").OnServerEvent:Connect(claim)

    RemoteService.Get("RequestQuestState").OnServerInvoke = function(player)
        return stateFor(player)
    end
end

function QuestService.SetEconomyService(economyService)
    EconomyService = economyService
end

function QuestService.PushState(player)
    pushState(player)
end

function QuestService.OnPlayerReady(player)
    pushState(player)
end

return QuestService
