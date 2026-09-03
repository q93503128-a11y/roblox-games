local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local RewardConfig = require(ReplicatedStorage.Shared.RewardConfig)

local RewardService = {}

local PlayerDataService
local RemoteService
local EconomyService
local SecurityService

local sessionStarted = {}

local function dayKey(unix)
    local t = os.date("!*t", unix)
    return string.format("%04d-%02d-%02d", t.year, t.month, t.day)
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

local function refreshPlaytimeDay(data)
    local today = dayKey(os.time())
    if data.Rewards.Playtime.DayKey ~= today then
        data.Rewards.Playtime.DayKey = today
        data.Rewards.Playtime.Claimed = {}
        data.Rewards.Playtime.SecondsToday = 0
    end
end

local function stateFor(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return nil
    end

    refreshPlaytimeDay(data)

    local now = os.time()
    local elapsed = sessionStarted[player] and math.max(0, now - sessionStarted[player]) or 0
    local secondsToday = math.floor((data.Rewards.Playtime.SecondsToday or 0) + elapsed)

    local daily = data.Rewards.Daily
    local nextAvailable = math.max(0, (daily.LastClaimUnix + GameConfig.DAILY_CLAIM_COOLDOWN_SECONDS) - now)

    local playtime = {}
    for _, def in ipairs(RewardConfig.Playtime) do
        table.insert(playtime, {
            Id = def.Id,
            Seconds = def.Seconds,
            Progress = math.min(secondsToday, def.Seconds),
            Available = secondsToday >= def.Seconds and not data.Rewards.Playtime.Claimed[def.Id],
            Claimed = data.Rewards.Playtime.Claimed[def.Id] == true,
            Reward = def.Reward,
        })
    end

    return {
        Daily = {
            Streak = daily.Streak or 0,
            NextAvailableSeconds = nextAvailable,
            CanClaim = nextAvailable <= 0,
        },
        SecondsToday = secondsToday,
        Playtime = playtime,
    }
end

local function pushState(player)
    local state = stateFor(player)
    if state then
        RemoteService.Get("RewardStateUpdated"):FireClient(player, state)
    end
end

local function claimDaily(player)
    if not SecurityService.Allow(player, "DailyClaim") then
        return
    end

    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    local now = os.time()
    local daily = data.Rewards.Daily

    if daily.LastClaimUnix > 0 and now - daily.LastClaimUnix < GameConfig.DAILY_CLAIM_COOLDOWN_SECONDS then
        return
    end

    local gap = daily.LastClaimUnix > 0 and (now - daily.LastClaimUnix) or 0
    if daily.LastClaimUnix == 0 or gap > 48 * 60 * 60 then
        daily.Streak = 1
    else
        daily.Streak = (daily.Streak % 7) + 1
    end

    daily.LastClaimUnix = now
    local reward = RewardConfig.Daily[daily.Streak]
    grant(data, reward)

    RemoteService.Get("Toast"):FireClient(player, "Daily reward claimed! Day " .. tostring(daily.Streak))
    pushState(player)

    if EconomyService then
        EconomyService.PushState(player)
    end
end

local function claimPlaytime(player, rewardId)
    if not SecurityService.IsSafeId(rewardId, 50) then
        return
    end

    if not SecurityService.Allow(player, "PlaytimeClaim") then
        return
    end

    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    refreshPlaytimeDay(data)

    local now = os.time()
    local elapsed = sessionStarted[player] and math.max(0, now - sessionStarted[player]) or 0
    local totalSeconds = (data.Rewards.Playtime.SecondsToday or 0) + elapsed

    local targetDef
    for _, def in ipairs(RewardConfig.Playtime) do
        if def.Id == rewardId then
            targetDef = def
            break
        end
    end

    if not targetDef or totalSeconds < targetDef.Seconds then
        return
    end

    if data.Rewards.Playtime.Claimed[rewardId] then
        return
    end

    data.Rewards.Playtime.Claimed[rewardId] = true
    grant(data, targetDef.Reward)

    RemoteService.Get("Toast"):FireClient(player, "Playtime reward claimed!")
    pushState(player)

    if EconomyService then
        EconomyService.PushState(player)
    end
end

function RewardService.Init(playerDataService, remoteService, securityService)
    PlayerDataService = playerDataService
    RemoteService = remoteService
    SecurityService = securityService

    RemoteService.Get("RequestDailyClaim").OnServerEvent:Connect(claimDaily)
    RemoteService.Get("RequestPlaytimeClaim").OnServerEvent:Connect(claimPlaytime)

    RemoteService.Get("RequestRewardState").OnServerInvoke = function(player)
        return stateFor(player)
    end

    task.spawn(function()
        while true do
            task.wait(5)
            for player in pairs(sessionStarted) do
                if player.Parent then
                    pushState(player)
                end
            end
        end
    end)
end

function RewardService.SetEconomyService(economyService)
    EconomyService = economyService
end

function RewardService.OnPlayerReady(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    refreshPlaytimeDay(data)
    sessionStarted[player] = os.time()
    pushState(player)
end

function RewardService.OnPlayerRemoving(player)
    local data = PlayerDataService.Get(player)
    local started = sessionStarted[player]

    if data and started then
        refreshPlaytimeDay(data)
        data.Rewards.Playtime.SecondsToday += math.max(0, os.time() - started)
    end

    sessionStarted[player] = nil
end

return RewardService
