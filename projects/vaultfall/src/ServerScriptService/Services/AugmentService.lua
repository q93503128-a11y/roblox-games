local AugmentService = {}
local ctx

local playerState = {}
local pendingChoices = {}
local pendingSources = {}
local queuedBonusSources = {}
local rng = Random.new()

local AUGMENTS = {
    overclock = {
        Name = "OVERCLOCK",
        Description = "+18% fire rate, +8% recoil",
        MaxStacks = 4,
        Apply = function(mods)
            mods.FireInterval *= 0.82
            mods.Recoil *= 1.08
        end,
    },
    glass_cannon = {
        Name = "GLASS CANNON",
        Description = "+28% damage, -12% max health",
        MaxStacks = 3,
        Apply = function(mods)
            mods.Damage *= 1.28
            mods.MaxHealth *= 0.88
        end,
    },
    deep_mag = {
        Name = "DEEP MAG",
        Description = "+35% magazine capacity",
        MaxStacks = 3,
        Apply = function(mods)
            mods.Magazine *= 1.35
        end,
    },
    field_loader = {
        Name = "FIELD LOADER",
        Description = "+24% reload speed",
        MaxStacks = 3,
        Apply = function(mods)
            mods.Reload *= 0.76
        end,
    },
    deadeye = {
        Name = "DEADEYE",
        Description = "+10% critical chance, +15% critical damage",
        MaxStacks = 4,
        Apply = function(mods)
            mods.CritChance += 0.10
            mods.CritDamage *= 1.15
        end,
    },
    kinetic_shell = {
        Name = "KINETIC SHELL",
        Description = "+22% max health",
        MaxStacks = 4,
        Apply = function(mods)
            mods.MaxHealth *= 1.22
        end,
    },
    blood_circuit = {
        Name = "BLOOD CIRCUIT",
        Description = "Recover 3% max health on kill",
        MaxStacks = 3,
        Apply = function(mods)
            mods.HealOnKill += 0.03
        end,
    },
    pursuit = {
        Name = "PURSUIT VECTOR",
        Description = "+12% movement speed, +8% damage",
        MaxStacks = 3,
        Apply = function(mods)
            mods.Move *= 1.12
            mods.Damage *= 1.08
        end,
    },
    stabilizer = {
        Name = "GYRO STABILIZER",
        Description = "-28% recoil, -16% spread",
        MaxStacks = 3,
        Apply = function(mods)
            mods.Recoil *= 0.72
            mods.Spread *= 0.84
        end,
    },
    capacitor = {
        Name = "BREACH CAPACITOR",
        Description = "+16% damage and +12% crit damage",
        MaxStacks = 4,
        Apply = function(mods)
            mods.Damage *= 1.16
            mods.CritDamage *= 1.12
        end,
    },
    emergency_mesh = {
        Name = "EMERGENCY MESH",
        Description = "+15% max health and heal 18% immediately",
        MaxStacks = 3,
        Apply = function(mods)
            mods.MaxHealth *= 1.15
        end,
        ImmediateHeal = 0.18,
    },
    hunter_protocol = {
        Name = "HUNTER PROTOCOL",
        Description = "+20% damage to elites and bosses",
        MaxStacks = 3,
        Apply = function(mods)
            mods.EliteDamage *= 1.20
        end,
    },
}

local ORDER = {
    "overclock", "glass_cannon", "deep_mag", "field_loader", "deadeye", "kinetic_shell",
    "blood_circuit", "pursuit", "stabilizer", "capacitor", "emergency_mesh", "hunter_protocol",
}

local BONUS_SOURCES = {
    ["HVT BOUNTY"] = true,
    ["OVERLOAD CACHE"] = true,
    ["RELAY SWEEP"] = true,
    ["CONTAINMENT HOLD"] = true,
}

local function defaultModifiers()
    return {
        Damage = 1,
        FireInterval = 1,
        Magazine = 1,
        Reload = 1,
        Recoil = 1,
        Spread = 1,
        Move = 1,
        MaxHealth = 1,
        CritChance = 0,
        CritDamage = 1,
        HealOnKill = 0,
        EliteDamage = 1,
    }
end

local function newPlayerState()
    return {
        Stacks = {},
        Modifiers = defaultModifiers(),
        Picks = 0,
        LastStandardOfferRoom = 0,
        LastBonusOfferRoom = 0,
    }
end

local function stateFor(player)
    local state = playerState[player]
    if not state then
        state = newPlayerState()
        playerState[player] = state
    end
    return state
end

local function rebuild(player)
    local state = stateFor(player)
    local mods = defaultModifiers()
    for id, stacks in pairs(state.Stacks) do
        local def = AUGMENTS[id]
        if def then
            for _ = 1, stacks do
                def.Apply(mods)
            end
        end
    end
    state.Modifiers = mods

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local healthRatio = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth or 1
        local baseHealth = ctx.Config.BasePlayerHealth * ctx.Profile.GetHealthMultiplier(player)
        humanoid.MaxHealth = math.max(1, math.floor(baseHealth * mods.MaxHealth + 0.5))
        humanoid.Health = math.clamp(humanoid.MaxHealth * healthRatio, 1, humanoid.MaxHealth)
        humanoid.WalkSpeed = ctx.Config.BaseWalkSpeed * mods.Move
    end
end

local function publicState(player)
    local state = stateFor(player)
    local list = {}
    for _, id in ipairs(ORDER) do
        local stacks = state.Stacks[id]
        if stacks and stacks > 0 then
            table.insert(list, {
                Id = id,
                Name = AUGMENTS[id].Name,
                Stacks = stacks,
            })
        end
    end
    return { Picks = state.Picks, Augments = list }
end

local function pushState(player)
    if player.Parent then
        ctx.Remotes.State:FireClient(player, "AugmentState", publicState(player))
    end
end

local function eligibleIds(player)
    local state = stateFor(player)
    local result = {}
    for _, id in ipairs(ORDER) do
        local def = AUGMENTS[id]
        if (state.Stacks[id] or 0) < def.MaxStacks then
            table.insert(result, id)
        end
    end
    return result
end

local function buildChoice(id)
    local def = AUGMENTS[id]
    return {
        Id = id,
        Name = def.Name,
        Description = def.Description,
        MaxStacks = def.MaxStacks,
    }
end

local function isBonusSource(source)
    return BONUS_SOURCES[source or ""] == true
end

local function queueBonus(player, source)
    if not isBonusSource(source) then
        return false
    end
    if queuedBonusSources[player] then
        return false
    end
    queuedBonusSources[player] = source
    ctx.Remotes.State:FireClient(player, "Notice", string.format("%s reward queued — install your current augment first", source))
    return true
end

function AugmentService.Init(context)
    ctx = context

    ctx.Remotes.ClaimAugment.OnServerEvent:Connect(function(player, choiceId)
        if type(choiceId) ~= "string" or not ctx.Run.IsParticipant(player) then
            return
        end
        local pending = pendingChoices[player]
        if not pending then
            return
        end

        local allowed = false
        for _, id in ipairs(pending) do
            if id == choiceId then
                allowed = true
                break
            end
        end
        if not allowed then
            return
        end

        pendingChoices[player] = nil
        pendingSources[player] = nil
        local state = stateFor(player)
        local def = AUGMENTS[choiceId]
        state.Stacks[choiceId] = math.min(def.MaxStacks, (state.Stacks[choiceId] or 0) + 1)
        state.Picks += 1
        rebuild(player)

        if def.ImmediateHeal then
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * def.ImmediateHeal)
            end
        end

        pushState(player)
        ctx.Remotes.State:FireClient(player, "Notice", string.format("Augment installed: %s", def.Name))

        local queued = queuedBonusSources[player]
        if queued then
            queuedBonusSources[player] = nil
            task.defer(function()
                if player.Parent and ctx.Run.IsParticipant(player) then
                    AugmentService.Offer(player, queued)
                end
            end)
        end
    end)
end

function AugmentService.ResetRun(players)
    table.clear(pendingChoices)
    table.clear(pendingSources)
    table.clear(queuedBonusSources)
    for _, player in ipairs(players or {}) do
        playerState[player] = newPlayerState()
        rebuild(player)
        pushState(player)
    end
end

function AugmentService.ClearPlayer(player)
    playerState[player] = nil
    pendingChoices[player] = nil
    pendingSources[player] = nil
    queuedBonusSources[player] = nil
end

function AugmentService.GetModifiers(player)
    return stateFor(player).Modifiers
end

function AugmentService.PushState(player)
    pushState(player)
end

function AugmentService.Offer(player, source)
    if not player.Parent or not ctx.Run.IsParticipant(player) then
        return false
    end

    if pendingChoices[player] then
        return queueBonus(player, source)
    end

    local state = stateFor(player)
    local room = ctx.Run.GetCurrentRoom()
    local bonus = isBonusSource(source)
    if room > 0 then
        if bonus then
            if state.LastBonusOfferRoom == room then
                return false
            end
        elseif state.LastStandardOfferRoom == room then
            return false
        end
    end

    local pool = eligibleIds(player)
    if #pool == 0 then
        return false
    end

    local ids = {}
    while #ids < math.min(3, #pool) do
        local index = rng:NextInteger(1, #pool)
        table.insert(ids, table.remove(pool, index))
    end
    pendingChoices[player] = ids
    pendingSources[player] = source
    if room > 0 then
        if bonus then
            state.LastBonusOfferRoom = room
        else
            state.LastStandardOfferRoom = room
        end
    end

    local choices = {}
    for _, id in ipairs(ids) do
        table.insert(choices, buildChoice(id))
    end
    ctx.Remotes.State:FireClient(player, "AugmentOffer", {
        Source = source or "BREACH REWARD",
        Choices = choices,
    })
    return true
end

function AugmentService.OfferParty(source)
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        AugmentService.Offer(player, source)
    end
end

function AugmentService.OnEnemyKilled(player)
    if not player or not player.Parent then
        return
    end
    local mods = AugmentService.GetModifiers(player)
    if mods.HealOnKill <= 0 then
        return
    end
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * mods.HealOnKill)
    end
end

return AugmentService
