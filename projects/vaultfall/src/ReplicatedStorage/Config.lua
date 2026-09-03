local Config = {}

Config.GameName = "Vaultfall"
Config.SaveKey = "Vaultfall_Profile_v1"
Config.MaxPartySize = 4

Config.RoomSize = Vector3.new(82, 20, 82)
Config.RoomSpacing = 116
Config.RoomCount = 8
Config.RoomSequence = {
    "Combat",
    "Treasure",
    "Combat",
    "Elite",
    "Shrine",
    "Combat",
    "DeepCombat",
    "Boss",
}

Config.RoomPath = {
    Vector3.new(0, 0, 0),
    Vector3.new(0, 0, 1),
    Vector3.new(1, 0, 1),
    Vector3.new(2, 0, 1),
    Vector3.new(2, 0, 2),
    Vector3.new(2, 0, 3),
    Vector3.new(1, 0, 3),
    Vector3.new(0, 0, 3),
}

Config.BasePlayerHealth = 120
Config.BaseWalkSpeed = 16
Config.StartingWeapon = {
    Name = "Worn Blade",
    Rarity = "Common",
    Power = 12,
    CritChance = 0.05,
    CritMultiplier = 1.6,
}

Config.Attacks = {
    Basic = {
        Cooldown = 0.32,
        Range = 10,
        ConeDot = 0.20,
        Multiplier = 1.0,
    },
    Heavy = {
        Cooldown = 1.7,
        Range = 13,
        ConeDot = -0.05,
        Multiplier = 2.15,
    },
    Whirl = {
        Cooldown = 6.0,
        Range = 15,
        ConeDot = -1,
        Multiplier = 1.65,
    },
    Dash = {
        Cooldown = 2.25,
        Distance = 22,
    },
}

Config.Enemies = {
    Shade = {
        Health = 70,
        Damage = 10,
        Speed = 9,
        AttackRange = 5.5,
        AttackCooldown = 1.15,
        Essence = 4,
        Radius = 2.2,
    },
    Archer = {
        Health = 55,
        Damage = 8,
        Speed = 7,
        AttackRange = 24,
        AttackCooldown = 1.7,
        Essence = 5,
        Radius = 2.0,
        Ranged = true,
    },
    Brute = {
        Health = 150,
        Damage = 18,
        Speed = 5.8,
        AttackRange = 6.5,
        AttackCooldown = 1.65,
        Essence = 8,
        Radius = 3.2,
    },
    Elite = {
        Health = 360,
        Damage = 24,
        Speed = 7.5,
        AttackRange = 7,
        AttackCooldown = 1.35,
        Essence = 22,
        Radius = 3.4,
        Elite = true,
    },
    VaultWarden = {
        Health = 1350,
        Damage = 30,
        Speed = 6.3,
        AttackRange = 8,
        AttackCooldown = 1.45,
        Essence = 80,
        Radius = 4.5,
        Boss = true,
    },
}

Config.Rarity = {
    Common = { Weight = 55, Multiplier = 1.00 },
    Uncommon = { Weight = 27, Multiplier = 1.28 },
    Rare = { Weight = 12, Multiplier = 1.72 },
    Epic = { Weight = 5, Multiplier = 2.35 },
    Mythic = { Weight = 1, Multiplier = 3.25 },
}

Config.WeaponNames = {
    Common = { "Iron Fang", "Dustcutter", "Guard Blade", "Crypt Edge" },
    Uncommon = { "Mossbite", "Lantern Saber", "Gravehook", "Runed Cleaver" },
    Rare = { "Azure Reaver", "Vaultbreaker", "Moonsteel", "Emberbrand" },
    Epic = { "Kingfall", "Abyssal Talon", "Starforged Edge", "Warden's Ruin" },
    Mythic = { "Zero Hour", "Crown of Blades", "Eclipse Fang", "The Last Door" },
}

Config.Meta = {
    AttackPerLevel = 0.08,
    HealthPerLevel = 0.10,
    UpgradeBaseCost = 55,
    UpgradeCostGrowth = 1.58,
    CompletionEssence = 90,
    CompletionRankEvery = 2,
}

Config.AssetManifest = {
    DungeonKit = 84153348982194,
    WeaponPack = 17351010368,
    MonsterPack = 14483015744,
    NaturePack = 79195618410265,
}

return Config
