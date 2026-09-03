local AchievementConfig = {}

AchievementConfig.Definitions = {
    first_hatch = {
        Id = "first_hatch",
        DisplayName = "First Worker",
        Description = "Hatch your first monster.",
        Metric = "TotalHatches",
        Target = 1,
        Reward = { Gems = 15 },
    },
    hatch_25 = {
        Id = "hatch_25",
        DisplayName = "Capsule Regular",
        Description = "Hatch 25 monsters.",
        Metric = "TotalHatches",
        Target = 25,
        Reward = { Gems = 75 },
    },
    cash_100k = {
        Id = "cash_100k",
        DisplayName = "Factory Cashflow",
        Description = "Collect 100,000 Cash.",
        Metric = "TotalCashCollected",
        Target = 100000,
        Reward = { Gems = 100 },
    },
    zone_3 = {
        Id = "zone_3",
        DisplayName = "Frozen Frontier",
        Description = "Unlock Frozen Lab.",
        Metric = "HighestZone",
        Target = 3,
        Reward = { Gems = 150, UpgradeTokens = 1 },
    },
    rebirth_1 = {
        Id = "rebirth_1",
        DisplayName = "Built Again",
        Description = "Rebirth once.",
        Metric = "Rebirths",
        Target = 1,
        Reward = { Gems = 200, RebirthTokens = 1 },
    },
    rebirth_5 = {
        Id = "rebirth_5",
        DisplayName = "Industrial Loop",
        Description = "Rebirth five times.",
        Metric = "Rebirths",
        Target = 5,
        Reward = { Gems = 500, RebirthTokens = 5 },
    },
    shiny_1 = {
        Id = "shiny_1",
        DisplayName = "Polished Production",
        Description = "Create your first Shiny worker.",
        Metric = "ShinyCreated",
        Target = 1,
        Reward = { Gems = 125 },
    },
}

AchievementConfig.Order = {
    "first_hatch",
    "hatch_25",
    "cash_100k",
    "zone_3",
    "rebirth_1",
    "rebirth_5",
    "shiny_1",
}

return AchievementConfig
