local Players = game:GetService("Players")

local Services = script.Parent.Services

-- World generation is deliberately first.
-- A data/economy module failure must never leave the place without a floor/spawn.
local WorldService = require(Services.WorldService)
WorldService.Init()

local RemoteService = require(Services.RemoteService)
local PlayerDataService = require(Services.PlayerDataService)
local PassService = require(Services.PassService)
local SecurityService = require(Services.SecurityService)

local AnalyticsService = require(Services.AnalyticsService)
local FriendBonusService = require(Services.FriendBonusService)
local WorkerVisualService = require(Services.WorkerVisualService)
local AchievementService = require(Services.AchievementService)
local OnboardingService = require(Services.OnboardingService)

local MonsterService = require(Services.MonsterService)
local EconomyService = require(Services.EconomyService)
local ZoneService = require(Services.ZoneService)
local QuestService = require(Services.QuestService)
local RewardService = require(Services.RewardService)
local RebirthService = require(Services.RebirthService)
local PurchaseService = require(Services.PurchaseService)
local OfflineEarningsService = require(Services.OfflineEarningsService)
local ContextOfferService = require(Services.ContextOfferService)

RemoteService.Init()
FriendBonusService.Init()

QuestService.Init(PlayerDataService, RemoteService, SecurityService)
AchievementService.Init(PlayerDataService, RemoteService, SecurityService)
OnboardingService.Init(PlayerDataService, RemoteService)
WorkerVisualService.Init(PlayerDataService, RemoteService)

ZoneService.Init(PlayerDataService, RemoteService, SecurityService)
MonsterService.Init(PlayerDataService, PassService, RemoteService, SecurityService)
EconomyService.Init(PlayerDataService, PassService, RemoteService, MonsterService, SecurityService)
RebirthService.Init(PlayerDataService, RemoteService, ZoneService, SecurityService)
RewardService.Init(PlayerDataService, RemoteService, SecurityService)

ContextOfferService.Init(
    PlayerDataService,
    PassService,
    RemoteService,
    AnalyticsService
)

PurchaseService.Init(PlayerDataService, PassService, MonsterService)

OfflineEarningsService.Init(
    PlayerDataService,
    EconomyService,
    PassService,
    RemoteService
)

QuestService.SetEconomyService(EconomyService)
AchievementService.SetDependencies(EconomyService, AnalyticsService)
OnboardingService.SetAnalyticsService(AnalyticsService)
RewardService.SetEconomyService(EconomyService)

ZoneService.SetDependencies(
    EconomyService,
    QuestService,
    AchievementService,
    OnboardingService,
    ContextOfferService,
    WorkerVisualService
)

MonsterService.SetDependencies(
    EconomyService,
    QuestService,
    AchievementService,
    OnboardingService,
    WorkerVisualService,
    ContextOfferService
)

EconomyService.SetDependencies(
    RebirthService,
    QuestService,
    AchievementService,
    OnboardingService,
    FriendBonusService,
    ContextOfferService
)

RebirthService.SetDependencies(
    EconomyService,
    QuestService,
    AchievementService,
    OnboardingService,
    AnalyticsService
)

PlayerDataService.InitAutoSave()

local function onPlayerAdded(player)
    local data = PlayerDataService.Load(player)
    if not data then
        return
    end

    PassService.Refresh(player)

    OfflineEarningsService.Apply(player)
    PurchaseService.OnPlayerReady(player)

    AnalyticsService.Track(player, "session_start", {
        Rebirths = data.Progress.Rebirths,
        HighestZone = data.Progress.HighestZone,
    })

    ZoneService.OnPlayerReady(player)
    MonsterService.OnPlayerReady(player)
    QuestService.OnPlayerReady(player)
    AchievementService.OnPlayerReady(player)
    OnboardingService.OnPlayerReady(player)
    RewardService.OnPlayerReady(player)
    EconomyService.PushState(player)

    ContextOfferService.Evaluate(player)
end

local function onPlayerRemoving(player)
    RewardService.OnPlayerRemoving(player)
    PlayerDataService.Release(player)

    PassService.Remove(player)
    MonsterService.Remove(player)
    EconomyService.Remove(player)
    SecurityService.Remove(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        RewardService.OnPlayerRemoving(player)
        PlayerDataService.Save(player)
    end
    task.wait(2)
end)
