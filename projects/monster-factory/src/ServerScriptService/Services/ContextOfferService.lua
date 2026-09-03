local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local ContextOfferService = {}

local PlayerDataService
local PassService
local RemoteService
local AnalyticsService

local function canShow(data)
    local last = data.Session.LastContextOfferUnix or 0
    return os.time() - last >= GameConfig.CONTEXT_OFFER_COOLDOWN_SECONDS
end

local function show(player, key, reason)
    local data = PlayerDataService.Get(player)
    if not data or not canShow(data) then
        return
    end

    data.Session.LastContextOfferUnix = os.time()

    RemoteService.Get("ContextOffer"):FireClient(player, {
        Key = key,
        Reason = reason,
    })

    if AnalyticsService then
        AnalyticsService.Track(player, "context_offer_shown", {
            Key = key,
            Reason = reason,
        })
    end
end

function ContextOfferService.Evaluate(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return
    end

    if not PassService.Get(player, "StarterPack")
        and data.Stats.TotalHatches >= 1
        and data.Stats.TotalHatches <= 3
    then
        show(player, "StarterPack", "first_hatch_window")
        return
    end

    if not PassService.Get(player, "AutoCollect")
        and (data.Stats.TotalCashCollected or 0) >= 5000
    then
        show(player, "AutoCollect", "manual_collection_pressure")
        return
    end

    if not PassService.Get(player, "ExtraEquip")
        and #data.Monsters.Inventory >= math.max(5, #data.Monsters.Equipped + 2)
    then
        show(player, "ExtraEquip", "worker_slot_pressure")
        return
    end

    if not PassService.Get(player, "BiggerStorage")
        and #data.Monsters.Inventory >= math.floor(0.8 * 50)
    then
        show(player, "BiggerStorage", "storage_pressure")
        return
    end
end

function ContextOfferService.Init(playerDataService, passService, remoteService, analyticsService)
    PlayerDataService = playerDataService
    PassService = passService
    RemoteService = remoteService
    AnalyticsService = analyticsService
end

return ContextOfferService
