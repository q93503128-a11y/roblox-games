local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConfig = require(ReplicatedStorage.Shared.MonetizationConfig)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local PassService = {}
local cache = {}

local function ownsPass(player, pass)
    if pass.Id == 0 then
        return false
    end

    local ok, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, pass.Id)
    end)
    if not ok then
        warn("Pass ownership check failed:", pass.Key, player.UserId)
        return false
    end
    return result
end

function PassService.Refresh(player)
    local entitlements = {}
    for key, pass in pairs(MonetizationConfig.Passes) do
        entitlements[key] = ownsPass(player, pass)
    end
    cache[player] = entitlements
    return entitlements
end

function PassService.Get(player, key)
    return cache[player] and cache[player][key] == true
end

function PassService.GetEquipSlots(player)
    local slots = GameConfig.BASE_EQUIP_SLOTS
    if PassService.Get(player, "ExtraEquip") then
        slots += 3
    end
    if PassService.Get(player, "StarterPack") then
        slots += 1
    end
    return slots
end

function PassService.GetStorage(player)
    local storage = GameConfig.BASE_STORAGE
    if PassService.Get(player, "BiggerStorage") then
        storage += 150
    end
    return storage
end

function PassService.Remove(player)
    cache[player] = nil
end

return PassService
