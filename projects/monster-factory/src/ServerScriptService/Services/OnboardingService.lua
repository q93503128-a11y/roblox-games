local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OnboardingConfig = require(ReplicatedStorage.Shared.OnboardingConfig)

local OnboardingService = {}

local PlayerDataService
local RemoteService
local AnalyticsService

local function metricValue(data, metric)
    if metric == "TotalCashCollected" then
        return math.floor(data.Stats.TotalCashCollected or 0)
    elseif metric == "TotalHatches" then
        return math.floor(data.Stats.TotalHatches or 0)
    elseif metric == "EquippedCount" then
        return #data.Monsters.Equipped
    elseif metric == "GeneratorLevel" then
        return math.floor(data.Factory.GeneratorLevel or 1)
    elseif metric == "HighestZone" then
        return math.floor(data.Progress.HighestZone or 1)
    end
    return 0
end

local function updateProgress(player)
    local data = PlayerDataService.Get(player)
    if not data or data.Onboarding.Finished then
        return
    end

    local completedCount = 0

    for _, step in ipairs(OnboardingConfig.Steps) do
        local complete = metricValue(data, step.Metric) >= step.Target

        if complete then
            completedCount += 1

            if not data.Onboarding.CompletedSteps[step.Id] then
                data.Onboarding.CompletedSteps[step.Id] = true

                if AnalyticsService then
                    AnalyticsService.Track(player, "onboarding_step", {
                        StepId = step.Id,
                    })
                end
            end
        end
    end

    if completedCount >= #OnboardingConfig.Steps then
        data.Onboarding.Finished = true
    end
end

local function stateFor(player)
    updateProgress(player)

    local data = PlayerDataService.Get(player)
    if not data then
        return nil
    end

    if data.Onboarding.Finished then
        return {
            Finished = true,
        }
    end

    for _, step in ipairs(OnboardingConfig.Steps) do
        if not data.Onboarding.CompletedSteps[step.Id] then
            return {
                Finished = false,
                StepId = step.Id,
                DisplayName = step.DisplayName,
                Progress = metricValue(data, step.Metric),
                Target = step.Target,
            }
        end
    end

    return {
        Finished = true,
    }
end

local function pushState(player)
    local state = stateFor(player)
    if state then
        RemoteService.Get("OnboardingStateUpdated"):FireClient(player, state)
    end
end

function OnboardingService.Init(playerDataService, remoteService)
    PlayerDataService = playerDataService
    RemoteService = remoteService

    RemoteService.Get("RequestOnboardingState").OnServerInvoke = function(player)
        return stateFor(player)
    end
end

function OnboardingService.SetAnalyticsService(analyticsService)
    AnalyticsService = analyticsService
end

function OnboardingService.PushState(player)
    pushState(player)
end

function OnboardingService.OnPlayerReady(player)
    pushState(player)
end

return OnboardingService
