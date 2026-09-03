local Arsenal = {}

-- Data-only definitions shared by loot generation, server combat and client
-- presentation. AssetKeywords deliberately target imported Creator Store packs;
-- the client can fall back to a lightweight procedural model when a pack is
-- not installed in a raw Rojo build.
Arsenal.Order = { "Carbine", "SMG", "Shotgun", "RailRifle" }

Arsenal.Weapons = {
    Carbine = {
        DisplayName = "PX-9 Service Carbine",
        Role = "Balanced rifle",
        FireMode = "Auto",
        BaseDamage = 18,
        FireInterval = 0.115,
        Magazine = 30,
        ReloadTime = 1.75,
        Range = 170,
        Spread = 0.010,
        Recoil = 0.72,
        MoveMultiplier = 0.98,
        AssetKeywords = { "rifle", "carbine", "assault" },
        Accent = Color3.fromRGB(73, 139, 155),
    },
    SMG = {
        DisplayName = "Cinder SMG",
        Role = "Close-range mobility",
        FireMode = "Auto",
        BaseDamage = 11,
        FireInterval = 0.072,
        Magazine = 38,
        ReloadTime = 1.55,
        Range = 105,
        Spread = 0.018,
        Recoil = 0.48,
        MoveMultiplier = 1.05,
        AssetKeywords = { "smg", "submachine", "compact" },
        Accent = Color3.fromRGB(168, 101, 74),
    },
    Shotgun = {
        DisplayName = "Ward Shotgun",
        Role = "Breach / stagger",
        FireMode = "Pump",
        BaseDamage = 9,
        Pellets = 8,
        FireInterval = 0.82,
        Magazine = 7,
        ReloadTime = 2.25,
        Range = 78,
        Spread = 0.065,
        Recoil = 1.75,
        MoveMultiplier = 0.94,
        AssetKeywords = { "shotgun", "scatter" },
        Accent = Color3.fromRGB(176, 132, 69),
    },
    RailRifle = {
        DisplayName = "Vanta Rail Rifle",
        Role = "Precision / armor break",
        FireMode = "Semi",
        BaseDamage = 82,
        FireInterval = 1.1,
        Magazine = 5,
        ReloadTime = 2.45,
        Range = 310,
        Spread = 0.0015,
        Recoil = 2.1,
        MoveMultiplier = 0.90,
        AssetKeywords = { "rail", "sniper", "marksman", "rifle" },
        Accent = Color3.fromRGB(115, 91, 172),
    },
}

Arsenal.Traits = {
    Overpressure = {
        Name = "Overpressure",
        Description = "+18% damage, +12% recoil",
        DamageMultiplier = 1.18,
        RecoilMultiplier = 1.12,
    },
    Lightweight = {
        Name = "Lightweight Frame",
        Description = "+8% move speed while equipped",
        MoveMultiplier = 1.08,
    },
    Capacitor = {
        Name = "Capacitor Feed",
        Description = "+20% magazine capacity",
        MagazineMultiplier = 1.20,
    },
    Surgical = {
        Name = "Surgical Optics",
        Description = "+5% crit chance, +15% crit damage",
        CritChanceBonus = 0.05,
        CritMultiplierBonus = 0.15,
    },
    Breacher = {
        Name = "Breacher Choke",
        Description = "+25% close damage, tighter spread",
        DamageMultiplier = 1.25,
        SpreadMultiplier = 0.78,
        ArchetypeOnly = "Shotgun",
    },
    QuickCycle = {
        Name = "Quick-Cycle Assembly",
        Description = "+14% fire rate",
        FireIntervalMultiplier = 0.86,
    },
    DeepCell = {
        Name = "Deep Cell",
        Description = "+32% magazine, +12% reload time",
        MagazineMultiplier = 1.32,
        ReloadMultiplier = 1.12,
    },
    Executioner = {
        Name = "Executioner Core",
        Description = "+30% crit damage",
        CritMultiplierBonus = 0.30,
    },
}

function Arsenal.Get(archetype)
    return Arsenal.Weapons[archetype]
end

function Arsenal.GetRandomArchetype(rng)
    return Arsenal.Order[rng:NextInteger(1, #Arsenal.Order)]
end

function Arsenal.GetCompatibleTraits(archetype)
    local result = {}
    for id, trait in pairs(Arsenal.Traits) do
        if not trait.ArchetypeOnly or trait.ArchetypeOnly == archetype then
            table.insert(result, id)
        end
    end
    table.sort(result)
    return result
end

return Arsenal
