local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Config = require(shared:WaitForChild("Config"))
local Arsenal = require(shared:WaitForChild("Arsenal"))

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

local function chooseTrait(rng, archetype, rarityIndex)
    if rarityIndex <= 1 then
        return nil
    end

    local compatible = Arsenal.GetCompatibleTraits(archetype)
    if #compatible == 0 then
        return nil
    end

    -- Uncommon weapons sometimes stay clean; higher rarities are expected to
    -- feel mechanically distinct rather than only having a bigger number.
    if rarityIndex == 2 and rng:NextNumber() < 0.35 then
        return nil
    end

    return compatible[rng:NextInteger(1, #compatible)]
end

local function deriveName(rng, rarity, archetype)
    local names = Config.WeaponNames[rarity]
    local baseName = names[rng:NextInteger(1, #names)]
    local definition = Arsenal.Get(archetype)
    if rarity == "Common" and definition then
        return definition.DisplayName
    end
    return baseName
end

function Loot.GenerateWeapon(rng, roomIndex, powerRank, luck)
    local rarity = chooseRarity(rng, luck)
    local rarityIndex = table.find(orderedRarities, rarity) or 1
    local rarityData = Config.Rarity[rarity]
    local archetype = Arsenal.GetRandomArchetype(rng)
    local definition = Arsenal.Get(archetype)
    local traitId = chooseTrait(rng, archetype, rarityIndex)
    local trait = traitId and Arsenal.Traits[traitId] or nil

    local depthScale = 1 + ((math.max(roomIndex, 1) - 1) * 0.18)
    local rankScale = 1 + (math.max(powerRank or 0, 0) * 0.11)
    local variance = rng:NextNumber(0.93, 1.09)
    local archetypeScale = definition and (definition.BaseDamage / 18) or 1
    local power = math.floor(14 * depthScale * rankScale * rarityData.Multiplier * math.sqrt(archetypeScale) * variance + 0.5)

    local critChance = math.clamp(0.04 + (0.015 * (rarityIndex - 1)), 0.04, 0.14)
    local critMultiplier = 1.55 + (0.08 * (rarityIndex - 1))
    if trait then
        critChance += trait.CritChanceBonus or 0
        critMultiplier += trait.CritMultiplierBonus or 0
    end

    return {
        Name = deriveName(rng, rarity, archetype),
        Rarity = rarity,
        Archetype = archetype,
        Trait = traitId,
        TraitName = trait and trait.Name or nil,
        Power = power,
        CritChance = math.clamp(critChance, 0, 0.35),
        CritMultiplier = critMultiplier,
        DamageMultiplier = trait and (trait.DamageMultiplier or 1) or 1,
        FireIntervalMultiplier = trait and (trait.FireIntervalMultiplier or 1) or 1,
        MagazineMultiplier = trait and (trait.MagazineMultiplier or 1) or 1,
        ReloadMultiplier = trait and (trait.ReloadMultiplier or 1) or 1,
        RecoilMultiplier = trait and (trait.RecoilMultiplier or 1) or 1,
        SpreadMultiplier = trait and (trait.SpreadMultiplier or 1) or 1,
        MoveMultiplier = trait and (trait.MoveMultiplier or 1) or 1,
    }
end

function Loot.ScoreWeapon(weapon)
    if not weapon then
        return 0
    end
    local expectedCrit = 1 + ((weapon.CritChance or 0) * ((weapon.CritMultiplier or 1) - 1))
    local traitDamage = weapon.DamageMultiplier or 1
    return (weapon.Power or 0) * expectedCrit * traitDamage
end

return Loot
