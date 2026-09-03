local SecurityService = {}

local buckets = {}

local DEFAULT_LIMITS = {
    Collect = 0.20,
    Upgrade = 0.12,
    Hatch = 0.12,
    ToggleEquip = 0.12,
    EquipBest = 0.40,
    Fuse = 0.50,
    ZoneUnlock = 0.50,
    ZoneTravel = 0.35,
    Rebirth = 1.00,
    QuestClaim = 0.30,
    DailyClaim = 1.00,
    PlaytimeClaim = 0.50,
    AchievementClaim = 0.30,
}

local function getPlayerBucket(player)
    local bucket = buckets[player]
    if not bucket then
        bucket = {}
        buckets[player] = bucket
    end
    return bucket
end

function SecurityService.Allow(player, action, customCooldown)
    if not player or player.Parent == nil then
        return false
    end

    if type(action) ~= "string" or #action > 64 then
        return false
    end

    local cooldown = customCooldown
    if type(cooldown) ~= "number" then
        cooldown = DEFAULT_LIMITS[action] or 0.20
    end

    cooldown = math.clamp(cooldown, 0.05, 10)

    local now = os.clock()
    local bucket = getPlayerBucket(player)
    local previous = bucket[action] or 0

    if now - previous < cooldown then
        return false
    end

    bucket[action] = now
    return true
end

function SecurityService.IsSafeId(value, maxLength)
    if type(value) ~= "string" then
        return false
    end

    maxLength = math.clamp(tonumber(maxLength) or 64, 1, 128)

    if #value < 1 or #value > maxLength then
        return false
    end

    return string.match(value, "^[%w_%-]+$") ~= nil
end

function SecurityService.IsSafePositiveInteger(value, minValue, maxValue)
    if type(value) ~= "number" or value ~= value then
        return false
    end

    if value % 1 ~= 0 then
        return false
    end

    minValue = minValue or 1
    maxValue = maxValue or 1000000

    return value >= minValue and value <= maxValue
end

function SecurityService.Remove(player)
    buckets[player] = nil
end

return SecurityService
