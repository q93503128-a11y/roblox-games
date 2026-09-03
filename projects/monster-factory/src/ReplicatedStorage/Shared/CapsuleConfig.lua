local CapsuleConfig = {}

CapsuleConfig.Definitions = {
    Meadow = {
        Id = "Meadow",
        DisplayName = "Meadow Capsule",
        Zone = 1,
        Currency = "Cash",
        Cost = 100,
        FirstHatchFree = true,
        Entries = {
            { MonsterId = "Slime", Weight = 4500 },
            { MonsterId = "Mushroom", Weight = 3000 },
            { MonsterId = "Bee", Weight = 1500 },
            { MonsterId = "Wolf", Weight = 800 },
            { MonsterId = "Golem", Weight = 200 },
        },
    },

    Desert = {
        Id = "Desert",
        DisplayName = "Desert Capsule",
        Zone = 2,
        Currency = "Cash",
        Cost = 12000,
        FirstHatchFree = false,
        Entries = {
            { MonsterId = "Sandling", Weight = 4500 },
            { MonsterId = "Scarab", Weight = 3000 },
            { MonsterId = "Jackal", Weight = 1500 },
            { MonsterId = "Mummy", Weight = 800 },
            { MonsterId = "Sphinx", Weight = 200 },
        },
    },

    Frozen = {
        Id = "Frozen",
        DisplayName = "Frozen Capsule",
        Zone = 3,
        Currency = "Cash",
        Cost = 300000,
        FirstHatchFree = false,
        Entries = {
            { MonsterId = "Snowball", Weight = 4500 },
            { MonsterId = "Penguin", Weight = 3000 },
            { MonsterId = "IceWolf", Weight = 1500 },
            { MonsterId = "Yeti", Weight = 800 },
            { MonsterId = "FrostDragon", Weight = 200 },
        },
    },
}

function CapsuleConfig.Get(capsuleId)
    return CapsuleConfig.Definitions[capsuleId]
end

return CapsuleConfig
