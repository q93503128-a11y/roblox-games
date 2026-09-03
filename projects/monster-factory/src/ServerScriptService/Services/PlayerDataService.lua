local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local PlayerDataService = {}
local store
local storeInitError
local profiles = {}

local function getStore()
    if store then
        return store
    end

    if RunService:IsStudio() and game.GameId == 0 then
        return nil
    end

    local ok, result = pcall(function()
        return DataStoreService:GetDataStore(GameConfig.DATA_STORE_NAME)
    end)

    if ok then
        store = result
        storeInitError = nil
        return store
    end

    storeInitError = result
    return nil
end

local function freshData()
    return {
        Version = GameConfig.DATA_VERSION,

        Currency = {
            Cash = GameConfig.STARTING_CASH,
            Gems = GameConfig.STARTING_GEMS,
            RebirthTokens = GameConfig.STARTING_REBIRTH_TOKENS,
        },

        Factory = {
            GeneratorLevel = 1,
            UpgradeTokens = 0,
            OverdriveUntil = 0,
            PendingCash = 0,
        },

        Progress = {
            HighestZone = 1,
            CurrentZone = 1,
            Rebirths = 0,
        },

        Monsters = {
            Inventory = {},
            Equipped = {},
            HatchCount = 0,
        },

        Quests = {
            Claimed = {},
        },

        Achievements = {
            Claimed = {},
        },

        Onboarding = {
            CompletedSteps = {},
            Finished = false,
        },

        Rewards = {
            Daily = {
                LastClaimUnix = 0,
                Streak = 0,
            },
            Playtime = {
                DayKey = "",
                Claimed = {},
                SecondsToday = 0,
            },
        },

        Entitlements = {
            StarterPackGranted = false,
            StarterPackMonsterGranted = false,
        },

        Purchases = {
            ProcessedReceipts = {},
        },

        Session = {
            LastSeenUnix = 0,
            LastContextOfferUnix = 0,
        },

        Stats = {
            TotalCashEarned = 0,
            TotalCashCollected = 0,
            TotalHatches = 0,
            ShinyCreated = 0,
            PurchasesGranted = 0,
        },
    }
end

local function deepReconcile(target, template)
    if type(target) ~= "table" then
        target = {}
    end

    for key, templateValue in pairs(template) do
        if type(templateValue) == "table" then
            target[key] = deepReconcile(target[key], templateValue)
        elseif target[key] == nil then
            target[key] = templateValue
        end
    end

    return target
end

local function reconcile(data)
    local legacyZone

    if type(data) == "table"
        and type(data.Progress) == "table"
        and type(data.Progress.Zone) == "number"
    then
        legacyZone = math.max(1, math.floor(data.Progress.Zone))
    end

    data = deepReconcile(data, freshData())

    if legacyZone then
        data.Progress.HighestZone = math.max(data.Progress.HighestZone or 1, legacyZone)
        data.Progress.CurrentZone = legacyZone
    end

    data.Progress.HighestZone = math.max(1, math.floor(data.Progress.HighestZone or 1))
    data.Progress.CurrentZone = math.clamp(
        math.floor(data.Progress.CurrentZone or data.Progress.HighestZone),
        1,
        data.Progress.HighestZone
    )
    data.Progress.Zone = nil

    data.Version = GameConfig.DATA_VERSION
    return data
end

function PlayerDataService.Load(player)
    local activeStore = getStore()

    if not activeStore then
        if RunService:IsStudio() then
            warn(
                "DataStore unavailable for this local Studio place; using ephemeral data.",
                storeInitError
            )
            profiles[player] = freshData()
            return profiles[player]
        end

        warn("DataStore initialization failed:", storeInitError)
        player:Kick("Your data could not be loaded safely. Please rejoin.")
        return nil
    end

    local key = "u_" .. player.UserId
    local loaded
    local success = false
    local lastError

    for attempt = 1, 3 do
        local ok, err = pcall(function()
            loaded = activeStore:GetAsync(key)
        end)

        if ok then
            success = true
            break
        end

        lastError = err
        task.wait(attempt)
    end

    if not success then
        if RunService:IsStudio() then
            warn("DataStore read unavailable in Studio; using ephemeral data:", lastError)
            profiles[player] = freshData()
            return profiles[player]
        end

        warn("Data load failed for", player.UserId, lastError)
        player:Kick("Your data could not be loaded safely. Please rejoin.")
        return nil
    end

    profiles[player] = reconcile(loaded)
    return profiles[player]
end

function PlayerDataService.Get(player)
    return profiles[player]
end

function PlayerDataService.Save(player)
    local data = profiles[player]
    if not data then
        return false
    end

    if RunService:IsStudio() and game.GameId == 0 then
        return true
    end

    local activeStore = getStore()
    if not activeStore then
        if RunService:IsStudio() then
            return true
        end
        warn("DataStore unavailable while saving:", storeInitError)
        return false
    end

    data.Session.LastSeenUnix = os.time()

    local key = "u_" .. player.UserId
    local snapshot = data

    local ok, err = pcall(function()
        activeStore:UpdateAsync(key, function()
            return snapshot
        end)
    end)

    if not ok then
        warn("Data save failed for", player.UserId, err)
    end

    return ok
end

function PlayerDataService.Release(player)
    PlayerDataService.Save(player)
    profiles[player] = nil
end

function PlayerDataService.AddCurrency(player, currency, amount)
    local data = profiles[player]
    if not data or type(amount) ~= "number" or amount <= 0 then
        return false
    end
    if data.Currency[currency] == nil then
        return false
    end

    data.Currency[currency] += amount
    return true
end

function PlayerDataService.SpendCurrency(player, currency, amount)
    local data = profiles[player]
    if not data or type(amount) ~= "number" or amount < 0 then
        return false
    end

    local current = data.Currency[currency]
    if type(current) ~= "number" or current < amount then
        return false
    end

    data.Currency[currency] -= amount
    return true
end

function PlayerDataService.InitAutoSave()
    task.spawn(function()
        while true do
            task.wait(GameConfig.SAVE_INTERVAL_SECONDS)
            for _, player in ipairs(Players:GetPlayers()) do
                PlayerDataService.Save(player)
            end
        end
    end)
end

return PlayerDataService
