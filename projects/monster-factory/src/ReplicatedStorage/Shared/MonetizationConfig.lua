local MonetizationConfig = {}

-- IMPORTANT:
-- Replace zeroes after the experience is published and products/passes are created.
-- Never duplicate these IDs in UI code.

MonetizationConfig.Passes = {
    StarterPack = {
        Id = 0,
        Key = "StarterPack",
        DisplayName = "Starter Pack",
    },
    AutoCollect = {
        Id = 0,
        Key = "AutoCollect",
        DisplayName = "Auto Collect",
    },
    ExtraEquip = {
        Id = 0,
        Key = "ExtraEquip",
        DisplayName = "+3 Equip Slots",
    },
    VIP = {
        Id = 0,
        Key = "VIP",
        DisplayName = "VIP",
    },
    FastHatch = {
        Id = 0,
        Key = "FastHatch",
        DisplayName = "Fast Hatch",
    },
    BiggerStorage = {
        Id = 0,
        Key = "BiggerStorage",
        DisplayName = "Bigger Storage",
    },
    ExtraWorker = {
        Id = 0,
        Key = "ExtraWorker",
        DisplayName = "Extra Factory Worker",
    },
}

MonetizationConfig.Products = {
    GemsSmall = {
        Id = 0,
        Key = "GemsSmall",
        DisplayName = "Gem Pack S",
        Grant = { Gems = 100 },
    },
    GemsMedium = {
        Id = 0,
        Key = "GemsMedium",
        DisplayName = "Gem Pack M",
        Grant = { Gems = 550 },
    },
    GemsLarge = {
        Id = 0,
        Key = "GemsLarge",
        DisplayName = "Gem Pack L",
        Grant = { Gems = 1500 },
    },
    RebirthSmall = {
        Id = 0,
        Key = "RebirthSmall",
        DisplayName = "Rebirth Tokens S",
        Grant = { RebirthTokens = 5 },
    },
    RebirthMedium = {
        Id = 0,
        Key = "RebirthMedium",
        DisplayName = "Rebirth Tokens M",
        Grant = { RebirthTokens = 30 },
    },
    Overdrive15 = {
        Id = 0,
        Key = "Overdrive15",
        DisplayName = "Factory Overdrive 15m",
        Grant = { OverdriveSeconds = 15 * 60 },
    },
    Overdrive60 = {
        Id = 0,
        Key = "Overdrive60",
        DisplayName = "Factory Overdrive 60m",
        Grant = { OverdriveSeconds = 60 * 60 },
    },
    UpgradeTokens = {
        Id = 0,
        Key = "UpgradeTokens",
        DisplayName = "Upgrade Token Bundle",
        Grant = { UpgradeTokens = 10 },
    },
}

function MonetizationConfig.FindProductById(productId)
    for _, item in pairs(MonetizationConfig.Products) do
        if item.Id == productId and productId ~= 0 then
            return item
        end
    end
    return nil
end

function MonetizationConfig.FindPassById(passId)
    for _, item in pairs(MonetizationConfig.Passes) do
        if item.Id == passId and passId ~= 0 then
            return item
        end
    end
    return nil
end

return MonetizationConfig
