local ZoneConfig = {}

ZoneConfig.Definitions = {
    [1] = {
        Id = 1,
        Key = "Meadow",
        DisplayName = "Green Meadows",
        UnlockCost = 0,
        CapsuleId = "Meadow",
        ProductionMultiplier = 1,
        WorldPosition = Vector3.new(0, 4, 28),
    },
    [2] = {
        Id = 2,
        Key = "Desert",
        DisplayName = "Desert Outpost",
        UnlockCost = 10000,
        CapsuleId = "Desert",
        ProductionMultiplier = 4,
        WorldPosition = Vector3.new(280, 4, 28),
    },
    [3] = {
        Id = 3,
        Key = "Frozen",
        DisplayName = "Frozen Lab",
        UnlockCost = 250000,
        CapsuleId = "Frozen",
        ProductionMultiplier = 16,
        WorldPosition = Vector3.new(560, 4, 28),
    },
}

function ZoneConfig.Get(zoneId)
    return ZoneConfig.Definitions[zoneId]
end

function ZoneConfig.GetProductionMultiplier(highestZone)
    local def = ZoneConfig.Get(highestZone)
    return def and def.ProductionMultiplier or 1
end

return ZoneConfig
