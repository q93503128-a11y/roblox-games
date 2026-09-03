local OnboardingConfig = {}

OnboardingConfig.Steps = {
    {
        Id = "collect",
        DisplayName = "Collect factory Cash",
        Metric = "TotalCashCollected",
        Target = 10,
    },
    {
        Id = "hatch",
        DisplayName = "Open your first Capsule",
        Metric = "TotalHatches",
        Target = 1,
    },
    {
        Id = "equip",
        DisplayName = "Activate a monster worker",
        Metric = "EquippedCount",
        Target = 1,
    },
    {
        Id = "upgrade",
        DisplayName = "Upgrade the Generator",
        Metric = "GeneratorLevel",
        Target = 2,
    },
    {
        Id = "zone2",
        DisplayName = "Unlock Desert Outpost",
        Metric = "HighestZone",
        Target = 2,
    },
}

return OnboardingConfig
