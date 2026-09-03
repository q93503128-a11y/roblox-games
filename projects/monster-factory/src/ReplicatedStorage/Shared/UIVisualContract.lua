local UIVisualContract = {}

-- Semantic UI contract for the canonical Monster Factory HUD.
-- External GUI packs are NEVER loaded from Creator Store asset IDs at runtime.
-- After a Studio-side sanitized intake, approved project-owned image IDs may be
-- assigned to the Image field of a slot. Until then every slot has a glyph fallback.

UIVisualContract.RuntimeCreatorStoreLoadingAllowed = false
UIVisualContract.Version = 2

local function slot(glyph, color, image)
    return {
        Glyph = glyph,
        Color = color,
        Image = image or "",
    }
end

UIVisualContract.Slots = {
    Cash = slot("$", Color3.fromRGB(67, 229, 139)),
    Collector = slot("◎", Color3.fromRGB(82, 238, 151)),
    Gems = slot("◆", Color3.fromRGB(178, 110, 255)),
    Production = slot("↑", Color3.fromRGB(255, 198, 70)),
    Friends = slot("+", Color3.fromRGB(72, 216, 239)),
    Rebirth = slot("R", Color3.fromRGB(255, 104, 112)),

    EquipBest = slot("★", Color3.fromRGB(255, 198, 70)),
    Monsters = slot("M", Color3.fromRGB(177, 111, 255)),
    Worlds = slot("W", Color3.fromRGB(71, 215, 239)),
    Quests = slot("Q", Color3.fromRGB(255, 198, 70)),
    Achievements = slot("A", Color3.fromRGB(177, 111, 255)),
    Shop = slot("$", Color3.fromRGB(67, 229, 139)),
    Rewards = slot("★", Color3.fromRGB(255, 198, 70)),
    Index = slot("#", Color3.fromRGB(71, 215, 239)),

    Collect = slot("$", Color3.fromRGB(67, 229, 139)),
    Hatch = slot("◇", Color3.fromRGB(71, 215, 239)),
    Upgrade = slot("↑", Color3.fromRGB(255, 198, 70)),

    Monster = slot("M", Color3.fromRGB(177, 111, 255)),
    World = slot("W", Color3.fromRGB(71, 215, 239)),
    Quest = slot("Q", Color3.fromRGB(255, 198, 70)),
    Achievement = slot("A", Color3.fromRGB(177, 111, 255)),
    Product = slot("$", Color3.fromRGB(67, 229, 139)),
    Reward = slot("★", Color3.fromRGB(255, 198, 70)),
    IndexEntry = slot("#", Color3.fromRGB(71, 215, 239)),
    Close = slot("×", Color3.fromRGB(255, 104, 112)),
}

UIVisualContract.Windows = {
    Shop = { Icon = "Shop", Subtitle = "Boosts, storage and factory accelerators" },
    Monsters = { Icon = "Monsters", Subtitle = "Equip the strongest workers or fuse duplicates" },
    Zones = { Icon = "Worlds", Subtitle = "Unlock factories and jump between worlds" },
    Quests = { Icon = "Quests", Subtitle = "Short goals that keep the factory moving" },
    Rewards = { Icon = "Rewards", Subtitle = "Daily and playtime rewards" },
    Achievements = { Icon = "Achievements", Subtitle = "Long-term milestones and one-time payouts" },
    Index = { Icon = "Index", Subtitle = "Discover every non-exclusive worker" },
}

UIVisualContract.Navigation = {
    EquipBest = "EquipBest",
    Monsters = "Monsters",
    Zones = "Worlds",
    Quests = "Quests",
    Achievements = "Achievements",
    Shop = "Shop",
    Rewards = "Rewards",
    Index = "Index",
    Rebirth = "Rebirth",
}

UIVisualContract.PrimaryActions = {
    Collect = "Collect",
    Hatch = "Hatch",
    Upgrade = "Upgrade",
}

local aliases = {
    cash = "Cash",
    collector = "Collector",
    gems = "Gems",
    production = "Production",
    friends = "Friends",
    rebirth = "Rebirth",
}

function UIVisualContract.GetSlot(key)
    local canonical = aliases[key] or key
    return UIVisualContract.Slots[canonical] or slot("•", Color3.fromRGB(111, 129, 154))
end

function UIVisualContract.GetWindow(name)
    return UIVisualContract.Windows[name]
end

return UIVisualContract
