local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local OfflineEarningsService = {}

local PlayerDataService
local EconomyService
local PassService
local RemoteService

function OfflineEarningsService.Apply(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    local lastSeen = data.Session.LastSeenUnix or 0
    if lastSeen <= 0 then
        data.Session.LastSeenUnix = os.time()
        return
    end

    local elapsed = math.clamp(
        os.time() - lastSeen,
        0,
        GameConfig.OFFLINE_MAX_SECONDS
    )

    if elapsed < 60 then
        return
    end

    local production = EconomyService.GetProductionPerSecond(player)
    local efficiency = GameConfig.OFFLINE_BASE_EFFICIENCY

    if PassService.Get(player, "VIP") then
        efficiency += GameConfig.OFFLINE_VIP_EFFICIENCY_BONUS
    end

    local earned = math.floor(production * elapsed * efficiency)
    if earned <= 0 then
        return
    end

    data.Currency.Cash += earned
    data.Stats.TotalCashCollected += earned
    data.Stats.TotalCashEarned += earned

    RemoteService.Get("Toast"):FireClient(
        player,
        "Offline factory earnings: $" .. tostring(earned)
    )
end

function OfflineEarningsService.Init(playerDataService, economyService, passService, remoteService)
    PlayerDataService = playerDataService
    EconomyService = economyService
    PassService = passService
    RemoteService = remoteService
end

return OfflineEarningsService
