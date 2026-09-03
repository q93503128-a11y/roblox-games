local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MonsterConfig = require(ReplicatedStorage.Shared.MonsterConfig)

local WorkerVisualService = {}

local PlayerDataService
local RemoteService

local function stateFor(player)
    local data = PlayerDataService.Get(player)
    if not data then
        return nil
    end

    local equippedSet = {}
    for _, uid in ipairs(data.Monsters.Equipped) do
        equippedSet[uid] = true
    end

    local workers = {}
    for _, item in ipairs(data.Monsters.Inventory) do
        if equippedSet[item.Uid] then
            local def = MonsterConfig.Get(item.MonsterId)
            if def then
                table.insert(workers, {
                    Uid = item.Uid,
                    MonsterId = item.MonsterId,
                    DisplayName = def.DisplayName,
                    Shiny = item.Shiny == true,
                    Color = def.Color,
                })
            end
        end
    end

    return {
        CurrentZone = data.Progress.CurrentZone or 1,
        Workers = workers,
    }
end

function WorkerVisualService.PushState(player)
    local state = stateFor(player)
    if state then
        RemoteService.Get("WorkerVisualStateUpdated"):FireClient(player, state)
    end
end

function WorkerVisualService.Init(playerDataService, remoteService)
    PlayerDataService = playerDataService
    RemoteService = remoteService

    RemoteService.Get("RequestWorkerVisualState").OnServerInvoke = function(player)
        return stateFor(player)
    end
end

return WorkerVisualService
