local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local ContractEncounterService = {}
local ctx
local selected = {}
local activeId
local spawnSerial = 0
local activeRoom = 0
local roomToken = 0
local nextHazardAt = 0
local accumulator = 0
local rng = Random.new()

local VALID = {
    SCAVENGER_RUN = true,
    IRON_VAULT = true,
    DEEP_DIVE = true,
    ELITE_PURGE = true,
    GLASS_KNIFE = true,
}

local function livingPlayers()
    return ctx.Run.GetLivingParticipants()
end

local function rootAndHumanoid(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and root and humanoid.Health > 0 then
        return root, humanoid
    end
    return nil
end

local function effectsFolder()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    if not world then
        return Workspace
    end
    local folder = world:FindFirstChild("ContractEffects")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "ContractEffects"
        folder.Parent = world
    end
    return folder
end

local function notice(text)
    for _, player in ipairs(livingPlayers()) do
        ctx.Remotes.State:FireClient(player, "Notice", text)
    end
end

local function makeDisc(position, radius, color, transparency)
    local part = Instance.new("Part")
    part.Name = "ContractTelegraph"
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(0.14, radius * 2, radius * 2)
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = transparency or 0.5
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CFrame = CFrame.new(position + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.rad(90))
    part.Parent = effectsFolder()
    return part
end

local function affectNear(position, radius, amount)
    for _, player in ipairs(livingPlayers()) do
        local root, humanoid = rootAndHumanoid(player)
        if root and humanoid and (root.Position - position).Magnitude <= radius then
            humanoid:TakeDamage(amount)
        end
    end
end

local function warningPulse(token, room, amount, radius, color)
    local marker = makeDisc(room.Origin, 2, color, 0.52)
    TweenService:Create(marker, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.14, radius * 2, radius * 2),
        Transparency = 0.18,
    }):Play()
    task.delay(1.0, function()
        if token ~= roomToken or not ctx.Run.IsActive() then
            if marker.Parent then marker:Destroy() end
            return
        end
        affectNear(room.Origin, radius, amount)
        if marker.Parent then marker:Destroy() end
    end)
end

local function targetedWarning(token, amount, radius, color)
    local players = livingPlayers()
    if #players == 0 then
        return
    end
    local target = players[rng:NextInteger(1, #players)]
    local root = rootAndHumanoid(target)
    if not root then
        return
    end
    local position = root.Position + Vector3.new(rng:NextNumber(-4, 4), 0, rng:NextNumber(-4, 4))
    local marker = makeDisc(position, 1, color, 0.58)
    TweenService:Create(marker, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.14, radius * 2, radius * 2),
        Transparency = 0.14,
    }):Play()
    task.delay(0.9, function()
        if token ~= roomToken or not ctx.Run.IsActive() then
            if marker.Parent then marker:Destroy() end
            return
        end
        affectNear(position, radius, amount)
        if marker.Parent then marker:Destroy() end
    end)
end

local function mutateEnemyType(enemyType, roomIndex)
    spawnSerial += 1
    if not activeId or roomIndex < 2 then
        return enemyType
    end
    if activeId == "SCAVENGER_RUN" then
        if enemyType == "Shade" and spawnSerial % 5 == 0 then return "Archer" end
    elseif activeId == "IRON_VAULT" then
        if enemyType == "Shade" and roomIndex >= 4 and spawnSerial % 3 == 0 then return "Brute" end
        if enemyType == "Archer" and roomIndex >= 8 and spawnSerial % 5 == 0 then return "Elite" end
    elseif activeId == "DEEP_DIVE" then
        if enemyType == "Shade" and roomIndex >= 6 and spawnSerial % 4 == 0 then return "Brute" end
        if enemyType == "Archer" and roomIndex >= 9 and spawnSerial % 5 == 0 then return "Elite" end
    elseif activeId == "ELITE_PURGE" then
        if enemyType == "Shade" and roomIndex >= 3 and spawnSerial % 4 == 0 then return "Elite" end
        if enemyType == "Archer" and roomIndex >= 7 and spawnSerial % 6 == 0 then return "Huntsman" end
    elseif activeId == "GLASS_KNIFE" then
        if enemyType == "Shade" and roomIndex >= 4 and spawnSerial % 5 == 0 then return "Reaper" end
        if enemyType == "Archer" and roomIndex >= 7 and spawnSerial % 4 == 0 then return "Huntsman" end
    end
    return enemyType
end

local function runHazard(token, room, roomType)
    if roomType == "Treasure" or roomType == "Shrine" or roomType == "Boss" then
        return 4
    end
    if activeId == "SCAVENGER_RUN" then
        targetedWarning(token, 10, 5.0, Color3.fromRGB(219, 160, 74))
        return rng:NextNumber(11, 14)
    elseif activeId == "IRON_VAULT" then
        notice("IRON VAULT — pressure wave incoming")
        warningPulse(token, room, 16, 25, Color3.fromRGB(104, 161, 224))
        return rng:NextNumber(9.5, 12)
    elseif activeId == "DEEP_DIVE" then
        targetedWarning(token, 15, 5.6, Color3.fromRGB(109, 154, 228))
        task.delay(0.5, function()
            if token == roomToken and ctx.Run.IsActive() then
                targetedWarning(token, 13, 4.8, Color3.fromRGB(109, 154, 228))
            end
        end)
        return rng:NextNumber(8.5, 10.5)
    elseif activeId == "ELITE_PURGE" then
        notice("ELITE PURGE — containment pulse")
        warningPulse(token, room, 18, 28, Color3.fromRGB(229, 94, 84))
        return rng:NextNumber(9, 11)
    elseif activeId == "GLASS_KNIFE" then
        notice("GLASS KNIFE — rapid hazard cycle")
        targetedWarning(token, 20, 5.2, Color3.fromRGB(245, 91, 103))
        task.delay(0.6, function()
            if token == roomToken and ctx.Run.IsActive() then
                targetedWarning(token, 18, 4.7, Color3.fromRGB(245, 91, 103))
            end
        end)
        return rng:NextNumber(7.2, 9.0)
    end
    return 5
end

local function step()
    if not ctx.Run.IsActive() then
        activeRoom = 0
        nextHazardAt = 0
        return
    end
    local roomIndex = ctx.Run.GetCurrentRoom()
    if roomIndex <= 0 then return end
    if roomIndex ~= activeRoom then
        activeRoom = roomIndex
        roomToken += 1
        nextHazardAt = os.clock() + 5.5
    end
    if not activeId or os.clock() < nextHazardAt then return end
    local room = ctx.World.GetRoom(roomIndex)
    if not room then
        nextHazardAt = os.clock() + 3
        return
    end
    nextHazardAt = os.clock() + runHazard(roomToken, room, ctx.Config.RoomSequence[roomIndex] or room.Type)
end

function ContractEncounterService.Init(context)
    ctx = context
    ctx.Remotes.SelectContract.OnServerEvent:Connect(function(player, contractId)
        if not ctx.Run.IsActive() and type(contractId) == "string" and VALID[contractId] then
            selected[player] = contractId
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        selected[player] = nil
    end)

    local originalStart = ctx.Run.StartRun
    ctx.Run.StartRun = function(requester)
        activeId = selected[requester]
        spawnSerial = 0
        activeRoom = 0
        roomToken += 1
        local started = originalStart(requester)
        if not started then
            activeId = nil
        elseif activeId then
            notice("CONTRACT RULESET ONLINE — sector composition and hazards modified")
        end
        return started
    end

    local originalSpawn = ctx.Enemies.Spawn
    ctx.Enemies.Spawn = function(enemyType, roomIndex, position, difficultyScale)
        return originalSpawn(mutateEnemyType(enemyType, roomIndex), roomIndex, position, difficultyScale)
    end

    local originalComplete = ctx.Run.CompleteRun
    ctx.Run.CompleteRun = function()
        originalComplete()
        activeId = nil
        roomToken += 1
    end

    local originalFail = ctx.Run.FailRun
    ctx.Run.FailRun = function(reason)
        originalFail(reason)
        activeId = nil
        roomToken += 1
    end

    RunService.Heartbeat:Connect(function(dt)
        accumulator += dt
        if accumulator < 0.2 then return end
        accumulator = 0
        step()
    end)
end

return ContractEncounterService
