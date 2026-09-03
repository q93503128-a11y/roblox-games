local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local shared = ReplicatedStorage:WaitForChild("Shared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local WorkerVisualFactory = require(shared:WaitForChild("WorkerVisualFactory"))

local MonsterStateUpdated = remotes:WaitForChild("MonsterStateUpdated")
local ZoneStateUpdated = remotes:WaitForChild("ZoneStateUpdated")
local RequestMonsterState = remotes:WaitForChild("RequestMonsterState")
local RequestZoneState = remotes:WaitForChild("RequestZoneState")

local zoneKeys = {
    [1] = "Meadow",
    [2] = "Desert",
    [3] = "Frozen",
}

local latestMonsterState
local currentZone = 1
local renderFolder
local active = {}

local function clearWorkers()
    if renderFolder then
        renderFolder:Destroy()
        renderFolder = nil
    end
    table.clear(active)
end

local function getStations(zoneId)
    local world = workspace:FindFirstChild("MonsterFactoryWorld")
    if not world then
        return nil
    end

    local zone = world:FindFirstChild(zoneKeys[zoneId] or "Meadow")
    local stations = zone and zone:FindFirstChild("WorkerStations")
    if not stations then
        return nil
    end

    local result = {}
    for _, child in ipairs(stations:GetChildren()) do
        if child:IsA("BasePart") and child:GetAttribute("WorkerSlot") then
            table.insert(result, child)
        end
    end

    table.sort(result, function(a, b)
        return (a:GetAttribute("WorkerSlot") or 999) < (b:GetAttribute("WorkerSlot") or 999)
    end)
    return result
end

local function rebuild()
    clearWorkers()

    if type(latestMonsterState) ~= "table" then
        return
    end

    local stations = getStations(currentZone)
    if not stations then
        return
    end

    local equipped = {}
    for _, item in ipairs(latestMonsterState.Inventory or {}) do
        if item.Equipped then
            table.insert(equipped, item)
        end
    end

    table.sort(equipped, function(a, b)
        return (a.SortPower or 0) > (b.SortPower or 0)
    end)

    local folder = Instance.new("Folder")
    folder.Name = "ClientWorkerVisuals"
    folder.Parent = workspace
    renderFolder = folder

    for index, item in ipairs(equipped) do
        local station = stations[index]
        if not station then
            break
        end

        local model = WorkerVisualFactory.Create(item.MonsterId, item.Shiny == true, {
            Name = "WorkerCharacter_" .. tostring(index) .. "_" .. tostring(item.MonsterId),
            CFrame = station.CFrame * CFrame.new(0, 1.55, 0),
            Nameplate = true,
        })

        if model then
            model.Parent = folder
            active[model] = {
                base = model.PrimaryPart.CFrame,
                phase = index * 0.83,
            }
        end
    end
end

local function applyMonsterState(state)
    if type(state) ~= "table" then
        return
    end
    latestMonsterState = state
    rebuild()
end

local function applyZoneState(state)
    if type(state) ~= "table" then
        return
    end
    local nextZone = tonumber(state.CurrentZone) or currentZone
    if nextZone ~= currentZone then
        currentZone = nextZone
        rebuild()
    else
        currentZone = nextZone
    end
end

MonsterStateUpdated.OnClientEvent:Connect(applyMonsterState)
ZoneStateUpdated.OnClientEvent:Connect(applyZoneState)

RunService.RenderStepped:Connect(function()
    local now = os.clock()
    for model, info in pairs(active) do
        if not model.Parent or not model.PrimaryPart then
            active[model] = nil
        else
            local bob = math.sin(now * 2.1 + info.phase) * 0.11
            local turn = math.sin(now * 0.55 + info.phase) * math.rad(4)
            model:PivotTo(info.base * CFrame.new(0, bob, 0) * CFrame.Angles(0, turn, 0))
        end
    end
end)

task.spawn(function()
    local okZone, zoneState = pcall(function()
        return RequestZoneState:InvokeServer()
    end)
    if okZone and type(zoneState) == "table" then
        currentZone = tonumber(zoneState.CurrentZone) or currentZone
    end

    local okMonsters, monsterState = pcall(function()
        return RequestMonsterState:InvokeServer()
    end)
    if okMonsters then
        applyMonsterState(monsterState)
    end
end)

print("[MonsterFactory] WorkerCharacters direct renderer active.")
