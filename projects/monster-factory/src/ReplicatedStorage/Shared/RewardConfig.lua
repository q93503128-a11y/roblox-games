local RewardConfig = {}

RewardConfig.Daily = {
    [1] = { Gems = 25 },
    [2] = { Gems = 40 },
    [3] = { UpgradeTokens = 1 },
    [4] = { Gems = 75 },
    [5] = { RebirthTokens = 1 },
    [6] = { Gems = 125 },
    [7] = { Gems = 250, UpgradeTokens = 3, RebirthTokens = 2 },
}

RewardConfig.Playtime = {
    { Id = "pt_5m", Seconds = 5 * 60, Reward = { Gems = 15 } },
    { Id = "pt_15m", Seconds = 15 * 60, Reward = { Gems = 35 } },
    { Id = "pt_30m", Seconds = 30 * 60, Reward = { UpgradeTokens = 1 } },
    { Id = "pt_60m", Seconds = 60 * 60, Reward = { Gems = 100, RebirthTokens = 1 } },
}

return RewardConfig
