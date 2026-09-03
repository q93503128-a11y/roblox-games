local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local EconomyConfig = require(ReplicatedStorage.Shared.EconomyConfig)
local ZoneConfig = require(ReplicatedStorage.Shared.ZoneConfig)

local EconomyService = {}

local PlayerDataService
local PassService
local RemoteService
local MonsterService
local RebirthService
local QuestService
local AchievementService
local OnboardingService
local FriendBonusService
local ContextOfferService

local SecurityService

local function calculateProduction(player, data)
    local production = EconomyConfig.GetProduction(
        GameConfig.BASE_PRODUCTION_PER_SECOND,
        data.Factory.GeneratorLevel,
        GameConfig.UPGRADE_PRODUCTION_GROWTH
    )

    production *= ZoneConfig.GetProductionMultiplier(data.Progress.HighestZone or 1)

    if MonsterService then
        production *= MonsterService.GetProductionMultiplier(player)
    end

    local rebirthMultiplier = 1 + ((data.Progress.Rebirths or 0) * GameConfig.REBIRTH_PRODUCTION_BONUS)
    production *= rebirthMultiplier

    if FriendBonusService then
        production *= (1 + FriendBonusService.GetBonus(player))
    end

    if PassService.Get(player, "VIP") then
        production *= 1.15
    end

    if (data.Factory.OverdriveUntil or 0) > os.time() then
        production *= 2
    end

    return production
end

local function stateFor(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return nil
    end

    local production = calculateProduction(player, data)

    local nextUpgradeCost = EconomyConfig.GetUpgradeCost(
        data.Factory.GeneratorLevel,
        GameConfig.UPGRADE_BASE_COST,
        GameConfig.UPGRADE_COST_GROWTH
    )

    local nextRebirthRequirement = GameConfig.REBIRTH_BASE_REQUIREMENT
        * (GameConfig.REBIRTH_REQUIREMENT_GROWTH ^ (data.Progress.Rebirths or 0))

    return {
        Cash = math.floor(data.Currency.Cash),
        PendingCash = math.floor(data.Factory.PendingCash or 0),
        Gems = math.floor(data.Currency.Gems),
        RebirthTokens = math.floor(data.Currency.RebirthTokens),

        GeneratorLevel = data.Factory.GeneratorLevel,
        ProductionPerSecond = production,
        MonsterMultiplier = MonsterService and MonsterService.GetProductionMultiplier(player) or 1,
        ZoneMultiplier = ZoneConfig.GetProductionMultiplier(data.Progress.HighestZone or 1),
        RebirthMultiplier = 1 + ((data.Progress.Rebirths or 0) * GameConfig.REBIRTH_PRODUCTION_BONUS),
        FriendBonus = FriendBonusService and FriendBonusService.GetBonus(player) or 0,

        NextUpgradeCost = nextUpgradeCost,
        UpgradeTokens = data.Factory.UpgradeTokens or 0,

        Rebirths = data.Progress.Rebirths or 0,
        NextRebirthRequirement = math.floor(nextRebirthRequirement),

        EquipSlots = PassService.GetEquipSlots(player),
        Storage = PassService.GetStorage(player),
        OverdriveUntil = data.Factory.OverdriveUntil or 0,

        Passes = {
            StarterPack = PassService.Get(player, "StarterPack"),
            AutoCollect = PassService.Get(player, "AutoCollect"),
            ExtraEquip = PassService.Get(player, "ExtraEquip"),
            VIP = PassService.Get(player, "VIP"),
            FastHatch = PassService.Get(player, "FastHatch"),
            BiggerStorage = PassService.Get(player, "BiggerStorage"),
            ExtraWorker = PassService.Get(player, "ExtraWorker"),
        },
    }
end

local function pushState(player)
    local state = stateFor(player)
    if state then
        RemoteService.Get("StateUpdated"):FireClient(player, state)
    end
end

local function tryCollect(player)
    if not SecurityService.Allow(player, "Collect") then
        return
    end

    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    local pending = math.floor(data.Factory.PendingCash or 0)
    if pending <= 0 then
        return
    end

    data.Factory.PendingCash -= pending
    data.Currency.Cash += pending
    data.Stats.TotalCashCollected += pending

    pushState(player)
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

local function tryUpgrade(player)
    if not SecurityService.Allow(player, "Upgrade") then
        return
    end

    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    local cost = EconomyConfig.GetUpgradeCost(
        data.Factory.GeneratorLevel,
        GameConfig.UPGRADE_BASE_COST,
        GameConfig.UPGRADE_COST_GROWTH
    )

    if data.Factory.UpgradeTokens > 0 then
        data.Factory.UpgradeTokens -= 1
        data.Factory.GeneratorLevel += 1
        pushState(player)
        if QuestService then
            QuestService.PushState(player)
        end
        if OnboardingService then
            OnboardingService.PushState(player)
        end
        return
    end

    if PlayerDataService.SpendCurrency(player, "Cash", cost) then
        data.Factory.GeneratorLevel += 1
        pushState(player)
        if QuestService then
            QuestService.PushState(player)
        end
        if OnboardingService then
            OnboardingService.PushState(player)
        end
    end
end

function EconomyService.Init(
    playerDataService,
    passService,
    remoteService,
    monsterService,
    securityService
)
    PlayerDataService = playerDataService
    PassService = passService
    RemoteService = remoteService
    MonsterService = monsterService
    SecurityService = securityService

    RemoteService.Get("RequestUpgrade").OnServerEvent:Connect(tryUpgrade)
    RemoteService.Get("RequestCollect").OnServerEvent:Connect(tryCollect)

    RemoteService.Get("RequestFullState").OnServerInvoke = function(player)
        return stateFor(player)
    end

    task.spawn(function()
        while true do
            task.wait(1)

            for _, player in ipairs(Players:GetPlayers()) do
                local data = PlayerDataService.Get(player)
                if data then
                    local amount = calculateProduction(player, data)

                    data.Factory.PendingCash += amount
                    data.Stats.TotalCashEarned += amount

                    if PassService.Get(player, "AutoCollect") then
                        local pending = math.floor(data.Factory.PendingCash)
                        if pending > 0 then
                            data.Factory.PendingCash -= pending
                            data.Currency.Cash += pending
                            data.Stats.TotalCashCollected += pending

                            if QuestService then
                                QuestService.PushState(player)
                            end
                        end
                    end

                    pushState(player)
                end
            end
        end
    end)
end

function EconomyService.SetDependencies(
    rebirthService,
    questService,
    achievementService,
    onboardingService,
    friendBonusService,
    contextOfferService
)
    RebirthService = rebirthService
    QuestService = questService
    AchievementService = achievementService
    OnboardingService = onboardingService
    FriendBonusService = friendBonusService
    ContextOfferService = contextOfferService
end

function EconomyService.GetProductionPerSecond(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return 0
    end
    return calculateProduction(player, data)
end

function EconomyService.PushState(player)
    pushState(player)
end

function EconomyService.Remove(player)
end

return EconomyService
