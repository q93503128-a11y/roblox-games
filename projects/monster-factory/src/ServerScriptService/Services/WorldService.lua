local Workspace = game:GetService("Workspace")

local WorldService = {}

function WorldService.Init()
    local world = Workspace:FindFirstChild("MonsterFactoryWorld")

    if world then
        print("[MonsterFactory] Static world found.")
        return
    end

    -- Emergency fallback only. The normal world is synced by Rojo / embedded in the place.
    warn("[MonsterFactory] Static world missing; creating emergency platform.")

    local fallback = Instance.new("Model")
    fallback.Name = "MonsterFactoryWorld"
    fallback.Parent = Workspace

    local floor = Instance.new("Part")
    floor.Name = "EmergencyFloor"
    floor.Anchored = true
    floor.Size = Vector3.new(220, 2, 180)
    floor.Position = Vector3.new(0, -1, 0)
    floor.Parent = fallback

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "FactorySpawn"
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Position = Vector3.new(0, 2, 30)
    spawn.Parent = fallback
end

return WorldService
