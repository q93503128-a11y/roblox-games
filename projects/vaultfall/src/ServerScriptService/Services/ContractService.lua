local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local ContractService = {}
local ctx
local offers = {}
local selected = {}
local activeContract
local wrapped = false
local spawnSerial = 0

local CONTRACTS = {
    {
        Id = "SCAVENGER_RUN",
        Name = "SCAVENGER RUN",
        Threat = "MODERATE",
        Description = "Hostile response is reinforced. Salvage values are increased.",
        RewardText = "+25% unsecured Essence • +140 completion payout",
        ThreatScale = 1.12,
        EssenceScale = 1.25,
        CompletionPayout = 140,
        ExtractionPayout = 55,
    },
    {
        Id = "IRON_VAULT",
        Name = "IRON VAULT",
        Threat = "HIGH",
        Description = "Enemies hit harder and endure longer. Contract payout is substantially increased.",
        RewardText = "+40% unsecured Essence • +240 completion payout",
        ThreatScale = 1.28,
        EssenceScale = 1.40,
        CompletionPayout = 240,
        ExtractionPayout = 90,
    },
    {
        Id = "DEEP_DIVE",
        Name = "DEEP DIVE",
        Threat = "SEVERE",
        Description = "A high-risk deep breach with aggressive scaling and premium recovery rights.",
        RewardText = "+55% unsecured Essence • +320 completion payout",
        ThreatScale = 1.36,
        EssenceScale = 1.55,
        CompletionPayout = 320,
        ExtractionPayout = 110,
    },
    {
        Id = "ELITE_PURGE",
        Name = "ELITE PURGE",
        Threat = "HIGH",
        Description = "Response teams field more elite bodies throughout the breach.",
        RewardText = "+35% unsecured Essence • elite-heavy encounters",
        ThreatScale = 1.20,
        EssenceScale = 1.35,
        CompletionPayout = 220,
        ExtractionPayout = 75,
        EliteEvery = 5,
    },
    {
        Id = "GLASS_KNIFE",
        Name = "GLASS KNIFE",
        Threat = "EXTREME",
        Description = "Fast lethal opposition. Success pays like a black-site contract.",
        RewardText = "+70% unsecured Essence • +380 completion payout",
        ThreatScale = 1.48,
        EssenceScale = 1.70,
        CompletionPayout = 380,
        ExtractionPayout = 125,
        EliteEvery = 4,
    },
}

local function shallowCopy(source)
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

local function findContract(id)
    for _, contract in ipairs(CONTRACTS) do
        if contract.Id == id then
            return contract
        end
    end
    return nil
end

local function publicContract(contract)
    return {
        Id = contract.Id,
        Name = contract.Name,
        Threat = contract.Threat,
        Description = contract.Description,
        RewardText = contract.RewardText,
    }
end

local function generateOffers(player)
    local rng = Random.new(player.UserId + math.floor(os.time() / 3600))
    local pool = table.clone(CONTRACTS)
    local result = {}
    while #result < 3 and #pool > 0 do
        local index = rng:NextInteger(1, #pool)
        table.insert(result, table.remove(pool, index))
    end
    offers[player] = result
    if not selected[player] or not findContract(selected[player]) then
        selected[player] = result[1] and result[1].Id or nil
    end
    return result
end

local function payloadFor(player, open)
    local currentOffers = offers[player] or generateOffers(player)
    local publicOffers = {}
    for _, contract in ipairs(currentOffers) do
        table.insert(publicOffers, publicContract(contract))
    end
    return {
        Open = open == true,
        Offers = publicOffers,
        Selected = selected[player],
        Active = activeContract and publicContract(activeContract) or nil,
    }
end

local function push(player, open)
    if player and player.Parent then
        ctx.Remotes.State:FireClient(player, "Contracts", payloadFor(player, open))
    end
end

local function payPlayer(player, amount, label)
    if amount <= 0 or not player.Parent then
        return
    end
    ctx.Profile.AddEssence(player, amount)
    ctx.Profile.Save(player)
    ctx.Remotes.State:FireClient(player, "Notice", string.format("CONTRACT PAYOUT — %s +%d secured Essence", label, amount))
end

local function installHooks()
    if wrapped then
        return
    end
    wrapped = true

    local originalStart = ctx.Run.StartRun
    ctx.Run.StartRun = function(requester)
        activeContract = findContract(selected[requester]) or (offers[requester] and offers[requester][1]) or CONTRACTS[1]
        spawnSerial = 0
        local started = originalStart(requester)
        if not started then
            activeContract = nil
            return false
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if ctx.Run.IsParticipant(player) then
                ctx.Remotes.State:FireClient(player, "ContractActive", publicContract(activeContract))
                ctx.Remotes.State:FireClient(player, "Notice", string.format("CONTRACT ACTIVE — %s / %s", activeContract.Name, activeContract.Threat))
            end
        end
        return true
    end

    local originalSpawn = ctx.Enemies.Spawn
    ctx.Enemies.Spawn = function(enemyType, roomIndex, position, difficultyScale)
        spawnSerial += 1
        local typeToSpawn = enemyType
        if activeContract and activeContract.EliteEvery and roomIndex >= 3 and enemyType == "Shade" and spawnSerial % activeContract.EliteEvery == 0 then
            typeToSpawn = "Elite"
        end
        local scale = difficultyScale * (activeContract and activeContract.ThreatScale or 1)
        return originalSpawn(typeToSpawn, roomIndex, position, scale)
    end

    local originalDeath = ctx.Run.OnEnemyDied
    ctx.Run.OnEnemyDied = function(enemy, attacker)
        if activeContract and enemy and enemy.Data then
            local originalData = enemy.Data
            local modified = shallowCopy(originalData)
            modified.Essence = math.max(1, math.floor((originalData.Essence or 1) * activeContract.EssenceScale + 0.5))
            enemy.Data = modified
            local result = originalDeath(enemy, attacker)
            enemy.Data = originalData
            return result
        end
        return originalDeath(enemy, attacker)
    end

    local originalExtract = ctx.Run.ExtractPlayer
    ctx.Run.ExtractPlayer = function(player)
        local contract = activeContract
        local depth = ctx.Run.GetCurrentRoom()
        local success = originalExtract(player)
        if success and contract then
            local fraction = math.clamp(depth / ctx.Config.RoomCount, 0.2, 1)
            payPlayer(player, math.floor(contract.ExtractionPayout * fraction + 0.5), contract.Name)
        end
        return success
    end

    local originalComplete = ctx.Run.CompleteRun
    ctx.Run.CompleteRun = function()
        local contract = activeContract
        local recipients = ctx.Run.GetLivingParticipants()
        originalComplete()
        if contract then
            for _, player in ipairs(recipients) do
                payPlayer(player, contract.CompletionPayout, contract.Name)
            end
        end
        activeContract = nil
    end

    local originalFail = ctx.Run.FailRun
    ctx.Run.FailRun = function(reason)
        originalFail(reason)
        activeContract = nil
    end
end

function ContractService.Init(context)
    ctx = context
    installHooks()

    ctx.Remotes.SelectContract.OnServerEvent:Connect(function(player, contractId)
        if ctx.Run.IsActive() or type(contractId) ~= "string" then
            return
        end
        local currentOffers = offers[player] or generateOffers(player)
        for _, contract in ipairs(currentOffers) do
            if contract.Id == contractId then
                selected[player] = contractId
                push(player, true)
                ctx.Remotes.State:FireClient(player, "Notice", string.format("Contract selected — %s", contract.Name))
                return
            end
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        offers[player] = nil
        selected[player] = nil
    end)
end

function ContractService.BindWorld()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    if not world then
        return
    end
    local board = world:FindFirstChild("ContractBoard", true)
    local prompt = board and board:FindFirstChildOfClass("ProximityPrompt")
    if prompt then
        prompt.ActionText = "Choose contract"
        prompt.ObjectText = "Operations board"
        prompt.Triggered:Connect(function(player)
            ContractService.OpenBoard(player)
        end)
    end
end

function ContractService.OpenBoard(player)
    if ctx.Run.IsActive() then
        ctx.Remotes.State:FireClient(player, "Notice", "Contracts are locked while a breach is active")
        return
    end
    generateOffers(player)
    push(player, true)
end

function ContractService.PushState(player)
    push(player, false)
end

return ContractService