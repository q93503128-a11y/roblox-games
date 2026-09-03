local Config = {}

Config.GameName = "BREACH PROTOCOL"
Config.SaveKey = "BreachProtocol_Profile_v1"
Config.MaxPartySize = 4

Config.RoomSize = Vector3.new(104, 22, 104)
Config.RoomSpacing = 142
Config.RoomCount = 12
Config.RoomSequence = {
    "Combat",
    "Treasure",
    "Combat",
    "Elite",
    "Shrine",
    "DeepCombat",
    "Treasure",
    "Combat",
    "Elite",
    "Shrine",
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
    Vector3.new(-1, 0, 3),
    Vector3.new(-1, 0, 4),
    Vector3.new(0, 0, 4),
    Vector3.new(1, 0, 4),
}

Config.Missions = {
    [3] = {
        Type = "Uplink",
        Title = "GHOST UPLINK",
        Brief = "Reconnect all three isolated uplinks while the sector is contested.",
        Target = 3,
    },
    [6] = {
        Type = "Holdout",
        Title = "SIGNAL HOLD",
        Brief = "Hold the defense uplink until the encrypted burst finishes transmitting.",
        Duration = 24,
        Target = 24,
    },
    [8] = {
        Type = "Recovery",
        Title = "BLACKBOX RECOVERY",
        Brief = "Secure the three data cores before pushing deeper into the facility.",
        Target = 3,
    },
    [11] = {
        Type = "Sabotage",
        Title = "THERMAL SABOTAGE",
        Brief = "Plant breach charges on both coolant nodes and eliminate resistance.",
        Target = 2,
    },
}

Config.BasePlayerHealth = 120
Config.BaseWalkSpeed = 17
Config.StartingWeapon = {
    Name = "PX-9 Service Carbine",
    Rarity = "Common",
    Archetype = "Carbine",
    Trait = nil,
    TraitName = nil,
    Power = 14,
    CritChance = 0.06,
    CritMultiplier = 1.6,
    DamageMultiplier = 1,
    FireIntervalMultiplier = 1,
    MagazineMultiplier = 1,
    ReloadMultiplier = 1,
    RecoilMultiplier = 1,
    SpreadMultiplier = 1,
    MoveMultiplier = 1,
}

Config.Attacks = {
    Dash = {
        Cooldown = 1.9,
        Distance = 24,
    },
}

Config.Enemies = {
    Shade = {
        Health = 72,
        Damage = 10,
        Speed = 9.5,
        AttackRange = 5.5,
        AttackCooldown = 1.1,
        Essence = 4,
        Radius = 2.2,
    },
    Archer = {
        Health = 58,
        Damage = 9,
        Speed = 7.2,
        AttackRange = 26,
        AttackCooldown = 1.55,
        Essence = 5,
        Radius = 2.0,
        Ranged = true,
    },
    Brute = {
        Health = 165,
        Damage = 18,
        Speed = 5.9,
        AttackRange = 6.5,
        AttackCooldown = 1.55,
        Essence = 8,
        Radius = 3.2,
    },
    Elite = {
        Health = 390,
        Damage = 24,
        Speed = 7.8,
        AttackRange = 7,
        AttackCooldown = 1.25,
        Essence = 24,
        Radius = 3.4,
        Elite = true,
    },
    VaultWarden = {
        Health = 1650,
        Damage = 31,
        Speed = 6.6,
        AttackRange = 8,
        AttackCooldown = 1.35,
        Essence = 100,
        Radius = 4.7,
        Boss = true,
    },
}

Config.Rarity = {
    Common = { Weight = 48, Multiplier = 1.00 },
    Uncommon = { Weight = 29, Multiplier = 1.28 },
    Rare = { Weight = 15, Multiplier = 1.72 },
    Epic = { Weight = 6.5, Multiplier = 2.35 },
    Mythic = { Weight = 1.5, Multiplier = 3.25 },
}

Config.WeaponNames = {
    Common = { "PX-9 Service Carbine", "Kestrel Sidearm", "Cinder SMG", "Ward Shotgun" },
    Uncommon = { "Helix Burst Rifle", "Needle Carbine", "Breaker Shotgun", "Arc Repeater" },
    Rare = { "Vanta Rail Rifle", "Grav-12", "Cerberus SMG", "Ion Lance" },
    Epic = { "Kingfall", "Abyss Talon", "Starforged Edge", "Warden's Ruin" },
    Mythic = { "ZERO HOUR", "Crown of Blades", "Eclipse Fang", "THE LAST DOOR" },
}

Config.Meta = {
    AttackPerLevel = 0.08,
    HealthPerLevel = 0.10,
    UpgradeBaseCost = 55,
    UpgradeCostGrowth = 1.58,
    CompletionEssence = 120,
    CompletionRankEvery = 2,
}

Config.AssetManifest = {
    DungeonKit = 9492405836,
    WeaponPack = 17351010368,
    MonsterPack = 14483015744,
    NaturePack = 79195618410265,
}

return Config
