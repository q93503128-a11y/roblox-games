local QuestConfig = {}

QuestConfig.Definitions = {
    cash_1 = {
        Id = "cash_1",
        DisplayName = "Collect 1,000 Cash",
        Metric = "TotalCashCollected",
        Target = 1000,
        Reward = { Gems = 25 },
    },
    hatch_1 = {
        Id = "hatch_1",
        DisplayName = "Hatch 5 Monsters",
        Metric = "TotalHatches",
        Target = 5,
        Reward = { Gems = 40 },
    },
    generator_1 = {
        Id = "generator_1",
        DisplayName = "Reach Generator Lv.10",
        Metric = "GeneratorLevel",
        Target = 10,
        Reward = { Gems = 60, UpgradeTokens = 1 },
    },
    zone_2 = {
        Id = "zone_2",
        DisplayName = "Unlock Desert Outpost",
        Metric = "HighestZone",
        Target = 2,
        Reward = { Gems = 100, UpgradeTokens = 2 },
    },
    rebirth_1 = {
        Id = "rebirth_1",
        DisplayName = "Rebirth Once",
        Metric = "Rebirths",
        Target = 1,
        Reward = { Gems = 150, RebirthTokens = 2 },
    },
}

QuestConfig.Order = {
    "cash_1",
    "hatch_1",
    "generator_1",
    "zone_2",
    "rebirth_1",
}

return QuestConfig
