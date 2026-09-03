local MonsterConfig = {}

MonsterConfig.Definitions = {
    -- Zone 1
    Slime = {
        Id = "Slime", DisplayName = "Slime", Rarity = "Common",
        ProductionBonus = 0.10, SortPower = 10, Zone = 1,
        Color = Color3.fromRGB(102, 255, 132),
    },
    Mushroom = {
        Id = "Mushroom", DisplayName = "Mushroom", Rarity = "Uncommon",
        ProductionBonus = 0.18, SortPower = 18, Zone = 1,
        Color = Color3.fromRGB(255, 113, 113),
    },
    Bee = {
        Id = "Bee", DisplayName = "Worker Bee", Rarity = "Rare",
        ProductionBonus = 0.32, SortPower = 32, Zone = 1,
        Color = Color3.fromRGB(255, 220, 73),
    },
    Wolf = {
        Id = "Wolf", DisplayName = "Meadow Wolf", Rarity = "Epic",
        ProductionBonus = 0.55, SortPower = 55, Zone = 1,
        Color = Color3.fromRGB(160, 178, 205),
    },
    Golem = {
        Id = "Golem", DisplayName = "Nature Golem", Rarity = "Legendary",
        ProductionBonus = 1.00, SortPower = 100, Zone = 1,
        Color = Color3.fromRGB(96, 171, 99),
    },

    -- Zone 2
    Sandling = {
        Id = "Sandling", DisplayName = "Sandling", Rarity = "Common",
        ProductionBonus = 0.45, SortPower = 145, Zone = 2,
        Color = Color3.fromRGB(222, 183, 108),
    },
    Scarab = {
        Id = "Scarab", DisplayName = "Clockwork Scarab", Rarity = "Uncommon",
        ProductionBonus = 0.70, SortPower = 170, Zone = 2,
        Color = Color3.fromRGB(194, 132, 68),
    },
    Jackal = {
        Id = "Jackal", DisplayName = "Dune Jackal", Rarity = "Rare",
        ProductionBonus = 1.10, SortPower = 210, Zone = 2,
        Color = Color3.fromRGB(203, 154, 84),
    },
    Mummy = {
        Id = "Mummy", DisplayName = "Factory Mummy", Rarity = "Epic",
        ProductionBonus = 1.80, SortPower = 280, Zone = 2,
        Color = Color3.fromRGB(215, 207, 166),
    },
    Sphinx = {
        Id = "Sphinx", DisplayName = "Mini Sphinx", Rarity = "Legendary",
        ProductionBonus = 3.00, SortPower = 400, Zone = 2,
        Color = Color3.fromRGB(236, 190, 75),
    },

    -- Zone 3
    Snowball = {
        Id = "Snowball", DisplayName = "Snowball", Rarity = "Common",
        ProductionBonus = 0.90, SortPower = 490, Zone = 3,
        Color = Color3.fromRGB(225, 242, 255),
    },
    Penguin = {
        Id = "Penguin", DisplayName = "Lab Penguin", Rarity = "Uncommon",
        ProductionBonus = 1.40, SortPower = 540, Zone = 3,
        Color = Color3.fromRGB(82, 104, 125),
    },
    IceWolf = {
        Id = "IceWolf", DisplayName = "Ice Wolf", Rarity = "Rare",
        ProductionBonus = 2.20, SortPower = 620, Zone = 3,
        Color = Color3.fromRGB(119, 195, 255),
    },
    Yeti = {
        Id = "Yeti", DisplayName = "Mini Yeti", Rarity = "Epic",
        ProductionBonus = 3.50, SortPower = 750, Zone = 3,
        Color = Color3.fromRGB(199, 231, 255),
    },
    FrostDragon = {
        Id = "FrostDragon", DisplayName = "Frost Dragon", Rarity = "Legendary",
        ProductionBonus = 6.00, SortPower = 1000, Zone = 3,
        Color = Color3.fromRGB(101, 225, 255),
    },

    -- Guaranteed paid item; never part of a randomized paid reward.
    FactoryBot = {
        Id = "FactoryBot", DisplayName = "Starter Factory Bot", Rarity = "Exclusive",
        ProductionBonus = 0.75, SortPower = 175, Zone = 0,
        Color = Color3.fromRGB(91, 194, 255),
        Exclusive = true,
    },
}

MonsterConfig.RarityOrder = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7,
    Exclusive = 8,
}

function MonsterConfig.Get(monsterId)
    return MonsterConfig.Definitions[monsterId]
end

function MonsterConfig.GetEffectiveBonus(monsterId, shiny)
    local def = MonsterConfig.Get(monsterId)
    if not def then
        return 0
    end

    local bonus = def.ProductionBonus
    if shiny then
        bonus *= 2.5
    end
    return bonus
end

return MonsterConfig
