local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local FriendBonusService = {}
local cachedBonus = {}

local function computeFor(player)
    local friendCount = 0

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local ok, isFriend = pcall(function()
                return player:IsFriendsWith(other.UserId)
            end)

            if ok and isFriend then
                friendCount += 1
            end
        end
    end

    return math.min(
        friendCount * GameConfig.FRIEND_BONUS_PER_FRIEND,
        GameConfig.FRIEND_BONUS_MAX
    )
end

local function refreshAll()
    for _, player in ipairs(Players:GetPlayers()) do
        cachedBonus[player] = computeFor(player)
    end
end

function FriendBonusService.Init()
    Players.PlayerAdded:Connect(function()
        task.defer(refreshAll)
    end)

    Players.PlayerRemoving:Connect(function(player)
        cachedBonus[player] = nil
        task.defer(refreshAll)
    end)

    task.spawn(function()
        while true do
            task.wait(60)
            refreshAll()
        end
    end)
end

function FriendBonusService.GetBonus(player)
    if cachedBonus[player] == nil then
        cachedBonus[player] = computeFor(player)
    end
    return cachedBonus[player] or 0
end

return FriendBonusService
