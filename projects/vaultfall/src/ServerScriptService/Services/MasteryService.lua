local DataStoreService = game:GetService("DataStoreService")

local MasteryService = {}
local ctx
local store
local records = {}
local wrapped = false

local ORDER = { "Carbine", "SMG", "Shotgun", "RailRifle" }
local MAX_LEVEL = 10
local LEVEL_XP = { 0, 45, 120, 230, 380, 580, 830, 1130, 1480, 1880, 2330 }

local PERK_COPY = {
    Carbine = {
        "Lv.1–10  Ballistic Calibration: +1.5% damage / level",
        "Lv.1–10  Counterweight: -1.5% recoil / level",
        "Lv.5  Deadeye Link: +4% critical chance",
        "Lv.10  Command Breaker: +12% elite / boss damage",
    },
    SMG = {
        "Lv.1–10  Hot Cycle: +1.3% fire rate / level",
        "Lv.1–10  Snap Feed: -1.5% reload time / level",
        "Lv.5  Extended Feed: +15% magazine capacity",
        "Lv.10  Close-Quarters Optics: +4% critical chance",
    },
    Shotgun = {
        "Lv.1–10  Breach Load: +2% damage / level",
        "Lv.1–10  Pattern Control: -1.8% spread / level",
        "Lv.5  Combat Loader: -12% reload time",
        "Lv.10  Juggernaut Breaker: +18% elite / boss damage",
    },
    RailRifle = {
        "Lv.1–10  Precision Stack: +0.6% critical chance / level",
        "Lv.1–10  Execution Coil: +2.5% critical damage / level",
        "Lv.1–10  Cell Discipline: -1% reload time / level",
        "Lv.5  Charged Bore: +10% damage",
        "Lv.10  Apex Penetrator: +20% elite / boss damage",
    },
}

local function blankRecord()
    local result = { XP = {} }
    for _, archetype in ipairs(ORDER) do
        result.XP[archetype] = 0
    end
    return result
end

local function sanitize(data)
    local result = blankRecord()
    if type(data) ~= "table" or type(data.XP) ~= "table" then
        return result
    end
    for _, archetype in ipairs(ORDER) do
        local value = data.XP[archetype]
        if type(value) == "number" then
            result.XP[archetype] = math.max(0, math.floor(value + 0.5))
        end
    end
    return result
end

local function levelForXP(xp)
    local level = 0
    for candidate = 1, MAX_LEVEL do
        if xp >= LEVEL_XP[candidate + 1] then
            level = candidate
        else
            break
        end
    end
    return level
end

local function entryFor(record, archetype)
    local xp = record.XP[archetype] or 0
    local level = levelForXP(xp)
    local floorXP = LEVEL_XP[level + 1] or 0
    local nextXP = level < MAX_LEVEL and LEVEL_XP[level + 2] or floorXP
    local progress = level >= MAX_LEVEL and 1 or math.clamp((xp - floorXP) / math.max(1, nextXP - floorXP), 0, 1)
    return {
        Archetype = archetype,
        XP = xp,
        Level = level,
        MaxLevel = MAX_LEVEL,
        FloorXP = floorXP,
        NextXP = nextXP,
        Progress = progress,
        Perks = PERK_COPY[archetype],
    }
end

local function payloadFor(player, levelUp)
    local record = records[player] or blankRecord()
    local entries = {}
    for _, archetype in ipairs(ORDER) do
        table.insert(entries, entryFor(record, archetype))
    end
    return {
        Entries = entries,
        LevelUp = levelUp,
    }
end

local function push(player, levelUp)
    if player and player.Parent then
        ctx.Remotes.State:FireClient(player, "Mastery", payloadFor(player, levelUp))
    end
end

local function currentArchetype(player)
    local weapon = ctx.Run and ctx.Run.GetEquippedWeapon and ctx.Run.GetEquippedWeapon(player)
    weapon = weapon or ctx.Config.StartingWeapon
    return weapon and weapon.Archetype or "Carbine"
end

local function masteryLevel(player, archetype)
    local record = records[player]
    if not record then
        return 0
    end
    return levelForXP(record.XP[archetype] or 0)
end

local function applyMastery(base, player)
    local archetype = currentArchetype(player)
    local level = masteryLevel(player, archetype)
    if level <= 0 then
        return base
    end

    local result = {}
    for key, value in pairs(base) do
        result[key] = value
    end

    result.Damage = result.Damage or 1
    result.FireInterval = result.FireInterval or 1
    result.Magazine = result.Magazine or 1
    result.Reload = result.Reload or 1
    result.Recoil = result.Recoil or 1
    result.Spread = result.Spread or 1
    result.CritChance = result.CritChance or 0
    result.CritDamage = result.CritDamage or 1
    result.EliteDamage = result.EliteDamage or 1

    if archetype == "Carbine" then
        result.Damage *= 1 + (level * 0.015)
        result.Recoil *= math.max(0.82, 1 - (level * 0.015))
        if level >= 5 then result.CritChance += 0.04 end
        if level >= 10 then result.EliteDamage *= 1.12 end
    elseif archetype == "SMG" then
        result.FireInterval *= math.max(0.82, 1 - (level * 0.013))
        result.Reload *= math.max(0.80, 1 - (level * 0.015))
        if level >= 5 then result.Magazine *= 1.15 end
        if level >= 10 then result.CritChance += 0.04 end
    elseif archetype == "Shotgun" then
        result.Damage *= 1 + (level * 0.020)
        result.Spread *= math.max(0.76, 1 - (level * 0.018))
        if level >= 5 then result.Reload *= 0.88 end
        if level >= 10 then result.EliteDamage *= 1.18 end
    elseif archetype == "RailRifle" then
        result.CritChance += level * 0.006
        result.CritDamage *= 1 + (level * 0.025)
        result.Reload *= math.max(0.86, 1 - (level * 0.010))
        if level >= 5 then result.Damage *= 1.10 end
        if level >= 10 then result.EliteDamage *= 1.20 end
    end

    return result
end

local function killXP(enemy)
    if not enemy or not enemy.Data then
        return 8
    end
    local amount = 8
    if enemy.Data.Elite then amount = 18 end
    if enemy.Data.HVT then amount = 32 end
    if enemy.Data.Boss then amount = 70 end
    amount += math.floor(math.max(0, (enemy.RoomIndex or 1) - 1) * 0.75)
    return amount
end

function MasteryService.Init(context)
    ctx = context

    local ok, result = pcall(function()
        return DataStoreService:GetDataStore("BreachProtocol_WeaponMastery_v1")
    end)
    if ok then
        store = result
    else
        store = nil
        warn("[Vaultfall] Mastery DataStore unavailable; using session mastery:", result)
    end

    -- Keep mastery orthogonal to combat architecture: layer its role-specific
    -- modifiers over the existing augment payload instead of duplicating fire logic.
    if not wrapped and ctx.Augments and ctx.Augments.GetModifiers then
        wrapped = true
        local originalModifiers = ctx.Augments.GetModifiers
        ctx.Augments.GetModifiers = function(player)
            return applyMastery(originalModifiers(player), player)
        end
    end

    -- EnemyService calls Run.OnEnemyDied dynamically. Wrapping the callback lets
    -- mastery progress from real kills without touching the stable encounter loop.
    if ctx.Run and ctx.Run.OnEnemyDied and not ctx.Run._MasteryWrapped then
        ctx.Run._MasteryWrapped = true
        local originalDeath = ctx.Run.OnEnemyDied
        ctx.Run.OnEnemyDied = function(enemy, attacker)
            if attacker and attacker.Parent then
                MasteryService.AwardKill(attacker, enemy)
            end
            return originalDeath(enemy, attacker)
        end
    end
end

function MasteryService.Load(player)
    if records[player] then
        return records[player]
    end
    local data
    if store then
        local ok, err = pcall(function()
            data = store:GetAsync("u_" .. player.UserId)
        end)
        if not ok then
            warn("[Vaultfall] mastery load failed for", player.UserId, err)
        end
    end
    local record = sanitize(data)
    records[player] = record
    push(player)
    return record
end

function MasteryService.Save(player)
    local record = records[player]
    if not record or not store then
        return true
    end
    local snapshot = sanitize(record)
    local ok, err = pcall(function()
        store:SetAsync("u_" .. player.UserId, snapshot)
    end)
    if not ok then
        warn("[Vaultfall] mastery save failed for", player.UserId, err)
    end
    return ok
end

function MasteryService.Unload(player)
    MasteryService.Save(player)
    records[player] = nil
end

function MasteryService.PushState(player)
    if not records[player] then
        MasteryService.Load(player)
        return
    end
    push(player)
end

function MasteryService.GetLevel(player, archetype)
    return masteryLevel(player, archetype)
end

function MasteryService.AwardKill(player, enemy)
    local record = records[player]
    if not record then
        record = MasteryService.Load(player)
    end
    if not record then
        return
    end

    local archetype = currentArchetype(player)
    if not table.find(ORDER, archetype) then
        return
    end

    local before = levelForXP(record.XP[archetype] or 0)
    record.XP[archetype] = (record.XP[archetype] or 0) + killXP(enemy)
    local after = levelForXP(record.XP[archetype])

    if after > before then
        push(player, {
            Archetype = archetype,
            Level = after,
        })
        MasteryService.Save(player)
        ctx.Remotes.State:FireClient(player, "Notice", string.format("%s MASTERY Lv.%d — new weapon calibration active", archetype, after))
    else
        -- Keep the in-run mastery strip live. This is a tiny state payload and
        -- gives every confirmed kill visible long-term progression feedback.
        push(player)
    end
end

return MasteryService