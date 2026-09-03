local Players = game:GetService("Players")

local RunService = {}
local ctx

local state = {
    Active = false,
    Ending = false,
    RunId = 0,
    Participants = {},
    ParticipantSet = {},
    Dead = {},
    CurrentRoom = 0,
    RoomCleared = false,
    EnemyCount = 0,
    DifficultyScale = 1,
    RNG = Random.new(),
}

local equippedWeapons = {}
local pendingLoot = {}

local function copyWeapon(weapon)
    local result = {}
    for key, value in pairs(weapon) do
        result[key] = value
    end
    return result
end

local function runPayload()
    return {
        Active = state.Active,
        Room = state.CurrentRoom,
        TotalRooms = ctx.Config.RoomCount,
        RoomType = state.CurrentRoom > 0 and ctx.Config.RoomSequence[state.CurrentRoom] or "Hub",
        Cleared = state.RoomCleared,
        EnemyCount = state.EnemyCount,
    }
end

local function sendRunState()
    local payload = runPayload()
    for _, player in ipairs(state.Participants) do
        if player.Parent then
            ctx.Remotes.State:FireClient(player, "Run", payload)
        end
    end
end

local function sendWeapon(player)
    local weapon = equippedWeapons[player]
    if weapon and player.Parent then
        ctx.Remotes.State:FireClient(player, "Weapon", weapon)
    end
end

local function teleportCharacter(player, cframe)
    local character = player.Character
    if not character then
        return false
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return false
    end
    character:PivotTo(cframe)
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function teleportToHub(player)
    if not teleportCharacter(player, ctx.World.GetHubSpawnCFrame()) then
        task.defer(function()
            if player.Parent then
                player:LoadCharacter()
            end
        end)
    end
end

local function averagePowerRank()
    local total = 0
    local count = 0
    for _, player in ipairs(state.Participants) do
        local profile = ctx.Profile.Get(player)
        if profile then
            total += profile.PowerRank
            count += 1
        end
    end
    return count > 0 and (total / count) or 0
end

local function calculateDifficulty()
    local partyCount = math.max(1, #state.Participants)
    local rank = averagePowerRank()
    return (1 + ((partyCount - 1) * 0.42)) * (1 + (rank * 0.08))
end

local function getSpawnPosition(room, slot)
    local offset = room.SpawnPoints[((slot - 1) % #room.SpawnPoints) + 1]
    return room.Origin + offset
end

local function spawnRoomEnemies(roomIndex)
    local room = ctx.World.GetRoom(roomIndex)
    local roomType = room.Type
    local partyCount = math.max(1, #RunService.GetLivingParticipants())
    local depthScale = 1 + ((roomIndex - 1) * 0.19)
    local difficulty = state.DifficultyScale * depthScale
    local spawnList = {}

    if roomType == "Combat" then
        local count = 3 + partyCount + math.floor(roomIndex / 3)
        for index = 1, count do
            if index % 4 == 0 then
                table.insert(spawnList, "Archer")
            elseif roomIndex >= 6 and index % 3 == 0 then
                table.insert(spawnList, "Brute")
            else
                table.insert(spawnList, "Shade")
            end
        end
    elseif roomType == "DeepCombat" then
        local count = 5 + (partyCount * 2)
        for index = 1, count do
            table.insert(spawnList, (index % 3 == 0) and "Brute" or ((index % 2 == 0) and "Archer" or "Shade"))
        end
    elseif roomType == "Elite" then
        table.insert(spawnList, "Elite")
        for _ = 1, 2 + partyCount do
            table.insert(spawnList, "Shade")
        end
        if partyCount >= 3 then
            table.insert(spawnList, "Archer")
        end
    elseif roomType == "Boss" then
        table.insert(spawnList, "VaultWarden")
        for _ = 2, partyCount do
            table.insert(spawnList, "Brute")
        end
    end

    state.EnemyCount = #spawnList
    for index, enemyType in ipairs(spawnList) do
        ctx.Enemies.Spawn(enemyType, roomIndex, getSpawnPosition(room, index), difficulty)
    end
end

local function offerLoot(roomIndex, luckBonus)
    for _, player in ipairs(RunService.GetLivingParticipants()) do
        local profile = ctx.Profile.Get(player)
        local rank = profile and profile.PowerRank or 0
        local weapon = ctx.Loot.GenerateWeapon(state.RNG, roomIndex, rank, luckBonus or 0)
        pendingLoot[player] = weapon
        ctx.Remotes.State:FireClient(player, "LootOffer", {
            Offered = weapon,
            Equipped = equippedWeapons[player],
        })
    end
end

local function healParticipants(fraction)
    for _, player in ipairs(RunService.GetLivingParticipants()) do
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * fraction)
        end
    end
end

local function objectiveComplete()
    return not ctx.Objectives or ctx.Objectives.IsComplete(state.CurrentRoom)
end

local function resetState()
    ctx.Enemies.ClearAll()
    ctx.World.ResetGates()
    if ctx.Objectives then
        ctx.Objectives.Reset()
    end
    table.clear(equippedWeapons)
    table.clear(pendingLoot)
    state.Active = false
    state.Ending = false
    state.Participants = {}
    state.ParticipantSet = {}
    state.Dead = {}
    state.CurrentRoom = 0
    state.RoomCleared = false
    state.EnemyCount = 0
    state.DifficultyScale = 1
end

local function finishCleanup(delaySeconds)
    local runId = state.RunId
    task.delay(delaySeconds, function()
        if state.RunId ~= runId then
            return
        end
        for _, player in ipairs(state.Participants) do
            if player.Parent then
                teleportToHub(player)
                ctx.Remotes.State:FireClient(player, "Run", {
                    Active = false,
                    Room = 0,
                    TotalRooms = ctx.Config.RoomCount,
                    RoomType = "Hub",
                    Cleared = false,
                    EnemyCount = 0,
                })
            end
        end
        resetState()
    end)
end

function RunService.Init(context)
    ctx = context

    ctx.Remotes.ClaimLoot.OnServerEvent:Connect(function(player, accept)
        if not state.Active or not state.ParticipantSet[player] then
            return
        end
        local offer = pendingLoot[player]
        if not offer then
            return
        end
        pendingLoot[player] = nil
        if accept == true then
            equippedWeapons[player] = offer
            sendWeapon(player)
            if ctx.Combat then
                ctx.Combat.ResetPlayer(player)
                ctx.Combat.PushState(player)
            end
            ctx.Remotes.State:FireClient(player, "Notice", string.format("Equipped %s [%s]", offer.Name, offer.Rarity))
        else
            ctx.Remotes.State:FireClient(player, "Notice", "Loot skipped")
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        pendingLoot[player] = nil
        equippedWeapons[player] = nil
        if state.Active and state.ParticipantSet[player] then
            state.Dead[player] = true
            task.defer(function()
                if state.Active and #RunService.GetLivingParticipants() == 0 then
                    RunService.FailRun("Party wiped")
                end
            end)
        end
    end)
end

function RunService.PushState(player)
    if not player or not player.Parent then
        return
    end

    if state.ParticipantSet[player] then
        ctx.Remotes.State:FireClient(player, "Run", runPayload())
        sendWeapon(player)
        local offer = pendingLoot[player]
        if offer then
            ctx.Remotes.State:FireClient(player, "LootOffer", {
                Offered = offer,
                Equipped = equippedWeapons[player],
            })
        end
    else
        ctx.Remotes.State:FireClient(player, "Run", {
            Active = false,
            Room = 0,
            TotalRooms = ctx.Config.RoomCount,
            RoomType = "Hub",
            Cleared = false,
            EnemyCount = 0,
        })
    end
end

function RunService.IsActive()
    return state.Active
end

function RunService.IsParticipant(player)
    return state.Active and state.ParticipantSet[player] == true
end

function RunService.GetCurrentRoom()
    return state.CurrentRoom
end

function RunService.GetEquippedWeapon(player)
    return equippedWeapons[player]
end

function RunService.GetLivingParticipants()
    local result = {}
    if not state.Active then
        return result
    end
    for _, player in ipairs(state.Participants) do
        if player.Parent and not state.Dead[player] then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and root and humanoid.Health > 0 then
                table.insert(result, player)
            end
        end
    end
    return result
end

function RunService.StartRun(requester)
    if state.Active or state.Ending then
        ctx.Remotes.State:FireClient(requester, "Notice", state.Ending and "The previous run is closing" or "A vault run is already active")
        return false
    end

    local participants = { requester }
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= requester and #participants < ctx.Config.MaxPartySize then
            table.insert(participants, player)
        end
    end

    if #participants == 0 then
        return false
    end

    resetState()
    state.Active = true
    state.RunId += 1
    state.Participants = participants
    state.ParticipantSet = {}
    state.Dead = {}
    state.CurrentRoom = 0
    state.RoomCleared = false
    state.DifficultyScale = calculateDifficulty()
    state.RNG = Random.new(math.floor(os.clock() * 100000) % 2147483646)

    for _, player in ipairs(participants) do
        state.ParticipantSet[player] = true
        state.Dead[player] = false
        equippedWeapons[player] = copyWeapon(ctx.Config.StartingWeapon)
        pendingLoot[player] = nil
        if ctx.Combat then
            ctx.Combat.ResetPlayer(player)
        end
        sendWeapon(player)
        teleportCharacter(player, ctx.World.GetRoomSpawnCFrame(1) * CFrame.new((math.random() - 0.5) * 8, 0, (math.random() - 0.5) * 8))
        ctx.Remotes.State:FireClient(player, "Notice", "Breach initiated — adapt, descend, extract")
    end

    if ctx.Augments then
        ctx.Augments.ResetRun(participants)
    end

    RunService.ActivateRoom(1)
    return true
end

function RunService.TryEnterRoom(player, roomIndex)
    if not state.Active or not state.ParticipantSet[player] or state.Dead[player] then
        return
    end

    if roomIndex == state.CurrentRoom then
        return
    end

    if state.RoomCleared and roomIndex == state.CurrentRoom + 1 then
        RunService.ActivateRoom(roomIndex)
    end
end

function RunService.ActivateRoom(roomIndex)
    if not state.Active or roomIndex < 1 or roomIndex > ctx.Config.RoomCount then
        return
    end

    state.CurrentRoom = roomIndex
    state.RoomCleared = false
    state.EnemyCount = 0
    ctx.World.SetExitOpen(roomIndex, false)
    if ctx.Objectives then
        ctx.Objectives.Reset()
    end

    for _, player in ipairs(state.Participants) do
        if player.Parent then
            ctx.Profile.SetBestDepth(player, roomIndex)
        end
    end

    local room = ctx.World.GetRoom(roomIndex)
    if room.Type == "Treasure" then
        sendRunState()
        task.delay(0.6, function()
            if state.Active and state.CurrentRoom == roomIndex then
                offerLoot(roomIndex + 1, 0.75)
                RunService.ClearRoom()
            end
        end)
        return
    elseif room.Type == "Shrine" then
        sendRunState()
        healParticipants(0.55)
        for _, player in ipairs(RunService.GetLivingParticipants()) do
            ctx.Remotes.State:FireClient(player, "Notice", "Field station restored 55% health")
        end
        task.delay(0.6, function()
            if state.Active and state.CurrentRoom == roomIndex then
                RunService.ClearRoom()
            end
        end)
        return
    end

    spawnRoomEnemies(roomIndex)
    if ctx.Objectives then
        ctx.Objectives.StartRoom(roomIndex)
    end
    sendRunState()
end

function RunService.OnEnemyDied(enemy, attacker)
    if not state.Active or enemy.RoomIndex ~= state.CurrentRoom then
        return
    end

    local essence = math.ceil(enemy.Data.Essence * (0.7 + state.CurrentRoom * 0.08))
    for _, player in ipairs(RunService.GetLivingParticipants()) do
        ctx.Profile.AddEssence(player, essence)
    end

    if attacker and attacker.Parent then
        ctx.Remotes.State:FireClient(attacker, "Hit", {
            Damage = 0,
            Kill = true,
            Enemy = enemy.Type,
        })
    end

    state.EnemyCount = math.max(0, state.EnemyCount - 1)
    sendRunState()
    if state.EnemyCount == 0 then
        if objectiveComplete() then
            RunService.ClearRoom()
        else
            for _, player in ipairs(RunService.GetLivingParticipants()) do
                ctx.Remotes.State:FireClient(player, "Notice", "Hostiles cleared — finish the sector objective")
            end
        end
    end
end

function RunService.OnObjectiveComplete(roomIndex)
    if not state.Active or state.RoomCleared or roomIndex ~= state.CurrentRoom then
        return
    end

    if state.EnemyCount == 0 then
        RunService.ClearRoom()
        return
    end

    for _, player in ipairs(RunService.GetLivingParticipants()) do
        ctx.Remotes.State:FireClient(player, "Notice", "Objective complete — neutralize remaining hostiles")
    end
end

function RunService.ClearRoom()
    if not state.Active or state.RoomCleared then
        return
    end
    if state.EnemyCount > 0 or not objectiveComplete() then
        return
    end

    state.RoomCleared = true
    state.EnemyCount = 0
    local roomIndex = state.CurrentRoom
    local roomType = ctx.Config.RoomSequence[roomIndex]
    if ctx.Objectives then
        ctx.Objectives.EndRoom()
    end
    sendRunState()

    if roomType == "Boss" then
        RunService.CompleteRun()
        return
    end

    ctx.World.SetExitOpen(roomIndex, true)
    if roomType ~= "Treasure" and roomType ~= "Shrine" then
        local luck = roomType == "Elite" and 0.45 or roomType == "DeepCombat" and 0.30 or 0
        offerLoot(roomIndex, luck)
        if ctx.Augments then
            local rewardName = roomType == "Elite" and "ELITE PROTOCOL" or roomType == "DeepCombat" and "DEEP BREACH PROTOCOL" or "BREACH PROTOCOL"
            ctx.Augments.OfferParty(rewardName)
        end
    end

    for _, player in ipairs(RunService.GetLivingParticipants()) do
        ctx.Remotes.State:FireClient(player, "Notice", string.format("Sector %d secured — choose your next advantage", roomIndex))
    end
end

function RunService.CompleteRun()
    if not state.Active then
        return
    end

    state.Active = false
    state.Ending = true
    for _, player in ipairs(state.Participants) do
        if player.Parent then
            ctx.Profile.RecordCompletion(player)
            ctx.Profile.Save(player)
            ctx.Remotes.State:FireClient(player, "Notice", "BREACH COMPLETE — permanent rewards secured")
        end
    end
    finishCleanup(4)
end

function RunService.FailRun(reason)
    if not state.Active then
        return
    end

    state.Active = false
    state.Ending = true
    ctx.Enemies.ClearAll()
    if ctx.Objectives then
        ctx.Objectives.Reset()
    end
    for _, player in ipairs(state.Participants) do
        if player.Parent then
            ctx.Profile.Save(player)
            ctx.Remotes.State:FireClient(player, "Notice", "BREACH FAILED — " .. (reason or "party lost"))
        end
    end
    finishCleanup(2.5)
end

function RunService.OnPlayerDied(player)
    if not state.Active or not state.ParticipantSet[player] or state.Dead[player] then
        return
    end
    state.Dead[player] = true
    ctx.Remotes.State:FireClient(player, "Notice", "Operator down. Surviving squad members can finish the breach.")
    task.delay(0.5, function()
        if state.Active and #RunService.GetLivingParticipants() == 0 then
            RunService.FailRun("Squad wiped")
        end
    end)
end

return RunService