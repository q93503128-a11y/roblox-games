local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Vaultfall"):WaitForChild("Config"))

local Loot = {}

local orderedRarities = { "Common", "Uncommon", "Rare", "Epic", "Mythic" }

local function chooseRarity(rng, luck)
    luck = math.max(0, luck or 0)
    local weights = {}
    local total = 0

    for index, rarity in ipairs(orderedRarities) do
        local base = Config.Rarity[rarity].Weight
        local boost = 1 + (luck * ((index - 1) / 4))
        local adjusted = base * boost
        weights[index] = adjusted
        total += adjusted
    end

    local roll = rng:NextNumber(0, total)
    local cursor = 0
    for index, rarity in ipairs(orderedRarities) do
        cursor += weights[index]
        if roll <= cursor then
            return rarity
        end
    end

    return "Common"
end

function Loot.GenerateWeapon(rng, roomIndex, powerRank, luck)
    local rarity = chooseRarity(rng, luck)
    local rarityIndex = table.find(orderedRarities, rarity) or 1
    local rarityData = Config.Rarity[rarity]
    local names = Config.WeaponNames[rarity]
    local name = names[rng:NextInteger(1, #names)]

    local depthScale = 1 + ((math.max(roomIndex, 1) - 1) * 0.22)
    local rankScale = 1 + (math.max(powerRank or 0, 0) * 0.11)
    local variance = rng:NextNumber(0.92, 1.10)
    local power = math.floor(12 * depthScale * rankScale * rarityData.Multiplier * variance + 0.5)

    local critChance = math.clamp(0.04 + (0.015 * (rarityIndex - 1)), 0.04, 0.14)
    local critMultiplier = 1.55 + (0.08 * (rarityIndex - 1))

    return {
        Name = name,
        Rarity = rarity,
        Power = power,
        CritChance = critChance,
        CritMultiplier = critMultiplier,
    }
end

function Loot.ScoreWeapon(weapon)
    if not weapon then
        return 0
    end
    return (weapon.Power or 0) * (1 + ((weapon.CritChance or 0) * ((weapon.CritMultiplier or 1) - 1)))
end

return Loot
