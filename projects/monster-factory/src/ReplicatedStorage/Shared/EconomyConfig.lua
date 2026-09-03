local EconomyConfig = {}

function EconomyConfig.GetUpgradeCost(currentLevel, baseCost, growth)
    currentLevel = math.max(1, math.floor(currentLevel))
    return math.floor(baseCost * (growth ^ (currentLevel - 1)))
end

function EconomyConfig.GetProduction(baseProduction, level, growth)
    level = math.max(1, math.floor(level))
    return baseProduction * (growth ^ (level - 1))
end

return EconomyConfig
