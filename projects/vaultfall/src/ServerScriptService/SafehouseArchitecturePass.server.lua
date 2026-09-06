local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("VaultfallWorld", 20)
if not world then
    warn("[Vaultfall Safehouse Architecture] world unavailable; pass skipped")
    return
end

local safehouse = world:FindFirstChild("Safehouse")
if not safehouse then
    warn("[Vaultfall Safehouse Architecture] safehouse unavailable; pass skipped")
    return
end

local previous = world:FindFirstChild("SafehouseArchitecture")
if previous then
    previous:Destroy()
end

local root = Instance.new("Folder")
root.Name = "SafehouseArchitecture"
root.Parent = world

local ORIGIN = Vector3.new(-220, 0, -120)

local palette = {
    shell = Color3.fromRGB(58, 64, 70),
    dark = Color3.fromRGB(40, 46, 51),
    mid = Color3.fromRGB(76, 83, 89),
    light = Color3.fromRGB(111, 119, 126),
    neutral = Color3.fromRGB(221, 231, 234),
    cyan = Color3.fromRGB(88, 171, 190),
    amber = Color3.fromRGB(221, 166, 91),
    green = Color3.fromRGB(103, 176, 143),
    warm = Color3.fromRGB(231, 210, 177),
    red = Color3.fromRGB(193, 83, 86),
}

local function part(parent, name, size, cframe, material, color, transparency)
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.CFrame = cframe
    item.Anchored = true
    item.CanCollide = false
    item.CanTouch = false
    item.CanQuery = false
    item.CastShadow = false
    item.TopSurface = Enum.SurfaceType.Smooth
    item.BottomSurface = Enum.SurfaceType.Smooth
    item.Material = material or Enum.Material.Metal
    item.Color = color or palette.mid
    item.Transparency = transparency or 0
    item.Parent = parent
    return item
end

local function light(host, color, brightness, range)
    local lamp = Instance.new("PointLight")
    lamp.Name = "FacilityLight"
    lamp.Color = color
    lamp.Brightness = brightness
    lamp.Range = range
    lamp.Shadows = false
    lamp.Parent = host
    return lamp
end

local function strip(parent, name, center, size, color)
    local housing = part(parent, name .. "Housing", size + Vector3.new(0.5, 0.45, 0.5), CFrame.new(center), Enum.Material.Metal, palette.dark)
    local diffuser = part(parent, name .. "Diffuser", size, housing.CFrame * CFrame.new(0, -0.27, 0), Enum.Material.Neon, color, 0.18)
    light(diffuser, color, 0.7, 22)
end

local function verticalFrame(parent, name, center, width, height, accent)
    local half = width * 0.5
    part(parent, name .. "Left", Vector3.new(1.5, height, 2), CFrame.new(center + Vector3.new(-half, height * 0.5, 0)), Enum.Material.Metal, palette.dark)
    part(parent, name .. "Right", Vector3.new(1.5, height, 2), CFrame.new(center + Vector3.new(half, height * 0.5, 0)), Enum.Material.Metal, palette.dark)
    part(parent, name .. "Top", Vector3.new(width + 1.5, 1.4, 2), CFrame.new(center + Vector3.new(0, height - 0.7, 0)), Enum.Material.Metal, palette.mid)
    part(parent, name .. "Accent", Vector3.new(width - 2, 0.18, 2.08), CFrame.new(center + Vector3.new(0, height - 1.55, -0.05)), Enum.Material.Neon, accent, 0.12)
end

local function ribbedWall(parent, name, center, width, height, depth, accent, facingX)
    local panelSize = facingX and Vector3.new(depth, height, width) or Vector3.new(width, height, depth)
    part(parent, name .. "Panel", panelSize, CFrame.new(center + Vector3.new(0, height * 0.5, 0)), Enum.Material.Metal, palette.shell)

    local count = math.max(3, math.floor(width / 9))
    for index = 0, count do
        local along = -width * 0.5 + (width / count) * index
        local pos = facingX and Vector3.new(0, height * 0.5, along) or Vector3.new(along, height * 0.5, 0)
        local ribSize = facingX and Vector3.new(depth + 0.4, height + 0.2, 0.5) or Vector3.new(0.5, height + 0.2, depth + 0.4)
        part(parent, name .. "Rib", ribSize, CFrame.new(center + pos), Enum.Material.Metal, palette.dark)
    end

    local accentSize = facingX and Vector3.new(depth + 0.12, 0.22, width - 2) or Vector3.new(width - 2, 0.22, depth + 0.12)
    part(parent, name .. "Accent", accentSize, CFrame.new(center + Vector3.new(0, 2.3, 0)), Enum.Material.Neon, accent, 0.2)
end

local function lockerBank(parent, center, count, accent)
    for index = 1, count do
        local offset = (index - (count + 1) * 0.5) * 4.4
        local body = part(parent, "Locker", Vector3.new(3.8, 8.5, 2.2), CFrame.new(center + Vector3.new(offset, 4.25, 0)), Enum.Material.Metal, palette.mid)
        part(parent, "LockerInset", Vector3.new(3.1, 6.8, 0.18), body.CFrame * CFrame.new(0, 0.2, -1.19), Enum.Material.SmoothPlastic, palette.dark)
        part(parent, "LockerTag", Vector3.new(2.4, 0.28, 0.2), body.CFrame * CFrame.new(0, 2.55, -1.3), Enum.Material.Neon, accent, 0.18)
    end
end

local function crateStack(parent, center, accent)
    local placements = {
        { Vector3.new(-3.2, 1.4, 0), Vector3.new(5.8, 2.8, 4.8) },
        { Vector3.new(3.2, 1.4, 0), Vector3.new(5.8, 2.8, 4.8) },
        { Vector3.new(0, 4.2, 0), Vector3.new(5.8, 2.8, 4.8) },
    }
    for _, entry in ipairs(placements) do
        local box = part(parent, "SupplyCase", entry[2], CFrame.new(center + entry[1]), Enum.Material.DiamondPlate, palette.mid)
        part(parent, "CaseBand", Vector3.new(entry[2].X + 0.05, 0.25, entry[2].Z + 0.08), box.CFrame, Enum.Material.Neon, accent, 0.25)
    end
end

local architecture = Instance.new("Folder")
architecture.Name = "Facilities"
architecture.Parent = root

-- SPAWN / TRANSIT: create a real arrival vestibule so the first frame has walls,
-- ceiling mass and a framed sightline toward the rest of the safehouse.
do
    local group = Instance.new("Folder")
    group.Name = "ArrivalConcourse"
    group.Parent = architecture
    local center = ORIGIN + Vector3.new(0, 0, 52)
    verticalFrame(group, "ArrivalPortal", center + Vector3.new(0, 0, -17), 34, 13, palette.cyan)
    verticalFrame(group, "InnerPortal", center + Vector3.new(0, 0, -2), 28, 11, palette.cyan)
    ribbedWall(group, "ArrivalLeft", center + Vector3.new(-23, 0, -3), 38, 10, 1.4, palette.cyan, true)
    ribbedWall(group, "ArrivalRight", center + Vector3.new(23, 0, -3), 38, 10, 1.4, palette.cyan, true)
    strip(group, "ArrivalLightA", center + Vector3.new(-9, 14.8, -7), Vector3.new(12, 0.18, 2.4), palette.neutral)
    strip(group, "ArrivalLightB", center + Vector3.new(9, 14.8, -7), Vector3.new(12, 0.18, 2.4), palette.neutral)
end

-- ARMORY: stronger authored silhouette with gear lockers, service gantry and stacked
-- supply cases. Everything is decorative/non-colliding so loadout interactions remain safe.
do
    local group = Instance.new("Folder")
    group.Name = "ArmoryFacility"
    group.Parent = architecture
    local center = ORIGIN + Vector3.new(-82, 0, -54)
    verticalFrame(group, "ArmoryPortal", center + Vector3.new(18, 0, 30), 28, 12, palette.cyan)
    ribbedWall(group, "ArmoryBulkhead", center + Vector3.new(20, 0, -28), 35, 11, 1.2, palette.cyan, false)
    lockerBank(group, center + Vector3.new(21, 0, -19), 6, palette.cyan)
    crateStack(group, center + Vector3.new(20, 0, 5), palette.cyan)
    for _, x in ipairs({ -25, -7, 11 }) do
        strip(group, "ArmoryTask", center + Vector3.new(x, 14.4, 2), Vector3.new(11, 0.18, 2), palette.neutral)
    end
    for _, z in ipairs({ -20, 0, 20 }) do
        local rail = part(group, "WeaponServiceRail", Vector3.new(1.2, 10, 12), CFrame.new(center + Vector3.new(-25, 6, z)), Enum.Material.Metal, palette.dark)
        part(group, "WeaponServiceGlow", Vector3.new(0.18, 7.5, 9.5), rail.CFrame * CFrame.new(0.7, 0, 0), Enum.Material.Neon, palette.cyan, 0.24)
    end
end

-- OPERATIONS: surround the tactical table with a command pit identity instead of
-- leaving a floating table and board in a dark rectangle.
do
    local group = Instance.new("Folder")
    group.Name = "OperationsFacility"
    group.Parent = architecture
    local center = ORIGIN + Vector3.new(72, 0, -55)
    verticalFrame(group, "OpsPortal", center + Vector3.new(-20, 0, 30), 30, 12, palette.amber)
    for _, x in ipairs({ -31, 31 }) do
        part(group, "CommandPillar", Vector3.new(4, 11, 4), CFrame.new(center + Vector3.new(x, 5.5, 5)), Enum.Material.Metal, palette.dark)
        part(group, "CommandPillarGlow", Vector3.new(2.7, 0.25, 4.1), CFrame.new(center + Vector3.new(x, 8.2, 5)), Enum.Material.Neon, palette.amber, 0.14)
    end
    for _, z in ipairs({ -5, 9, 23 }) do
        local console = part(group, "SideConsole", Vector3.new(14, 3.2, 3.6), CFrame.new(center + Vector3.new(28, 1.6, z)), Enum.Material.Metal, palette.mid)
        part(group, "SideConsoleScreen", Vector3.new(10.5, 1.6, 0.15), console.CFrame * CFrame.new(0, 1.7, -1.9) * CFrame.Angles(math.rad(-14), 0, 0), Enum.Material.Neon, palette.cyan, 0.28)
    end
    ribbedWall(group, "OpsStatusWall", center + Vector3.new(-26, 0, -26), 32, 10, 1.2, palette.amber, false)
    strip(group, "OpsLightA", center + Vector3.new(-15, 14.7, 5), Vector3.new(18, 0.2, 2.5), palette.neutral)
    strip(group, "OpsLightB", center + Vector3.new(15, 14.7, 5), Vector3.new(18, 0.2, 2.5), palette.neutral)
end

-- SYSTEMS LAB: add cable trunks, maintenance bridge language and equipment racks.
do
    local group = Instance.new("Folder")
    group.Name = "SystemsFacility"
    group.Parent = architecture
    local center = ORIGIN + Vector3.new(-78, 0, 53)
    verticalFrame(group, "SystemsPortal", center + Vector3.new(22, 0, -27), 28, 12, palette.green)
    ribbedWall(group, "SystemsBackplane", center + Vector3.new(-27, 0, 4), 60, 11, 1.2, palette.green, true)
    for index = -2, 2 do
        local z = index * 12
        part(group, "CableTrunk", Vector3.new(2.2, 2.2, 10), CFrame.new(center + Vector3.new(-23, 11.8, z)), Enum.Material.Metal, palette.dark)
        part(group, "CableGlow", Vector3.new(0.25, 0.25, 8.7), CFrame.new(center + Vector3.new(-21.8, 11.8, z)), Enum.Material.Neon, palette.green, 0.2)
    end
    for _, x in ipairs({ -8, 12, 32 }) do
        local rack = part(group, "DiagnosticRack", Vector3.new(8, 8, 3), CFrame.new(center + Vector3.new(x, 4, 26)), Enum.Material.Metal, palette.mid)
        for row = -1, 1 do
            part(group, "DiagnosticLine", Vector3.new(5.7, 0.2, 0.18), rack.CFrame * CFrame.new(0, row * 1.7, -1.59), Enum.Material.Neon, row == 0 and palette.green or palette.cyan, 0.2)
        end
    end
    strip(group, "SystemsLightA", center + Vector3.new(-5, 14.7, -6), Vector3.new(18, 0.2, 2.4), palette.neutral)
    strip(group, "SystemsLightB", center + Vector3.new(22, 14.7, -6), Vector3.new(18, 0.2, 2.4), palette.neutral)
end

-- FIRING RANGE: acoustic baffles and target backstops make the lanes read like an
-- actual range while preserving the existing shot lanes and counters.
do
    local group = Instance.new("Folder")
    group.Name = "RangeFacility"
    group.Parent = architecture
    local center = ORIGIN + Vector3.new(78, 0, 48)
    verticalFrame(group, "RangePortal", center + Vector3.new(-3, 0, -31), 34, 12, palette.warm)
    for _, x in ipairs({ -31, -7, 17, 31 }) do
        for _, z in ipairs({ -4, 12, 28 }) do
            part(group, "AcousticBaffle", Vector3.new(1.2, 4.5, 10), CFrame.new(center + Vector3.new(x, 13.2, z)) * CFrame.Angles(0, 0, math.rad(x < 0 and -10 or 10)), Enum.Material.Fabric, Color3.fromRGB(79, 78, 75))
        end
    end
    ribbedWall(group, "RangeBackstop", center + Vector3.new(0, 0, 45.5), 78, 10, 1.2, palette.red, false)
    for _, x in ipairs({ -24, 0, 24 }) do
        strip(group, "RangeLaneLight", center + Vector3.new(x, 14.5, 11), Vector3.new(13, 0.18, 2.2), palette.warm)
    end
    for _, x in ipairs({ -24, 0, 24 }) do
        local hood = part(group, "RangeHood", Vector3.new(20, 1.4, 5), CFrame.new(center + Vector3.new(x, 8.5, -23)), Enum.Material.Metal, palette.dark)
        part(group, "RangeHoodLine", Vector3.new(16, 0.2, 5.1), hood.CFrame * CFrame.new(0, -0.8, 0), Enum.Material.Neon, palette.warm, 0.22)
    end
end

-- DEPLOYMENT: build a recognizable launch gantry with side machinery and a bright
-- framed exit. This should become the dominant destination from the spawn concourse.
do
    local group = Instance.new("Folder")
    group.Name = "DeploymentFacility"
    group.Parent = architecture
    local center = ORIGIN + Vector3.new(0, 0, 76)
    verticalFrame(group, "DeploymentPortal", center + Vector3.new(0, 0, -17), 38, 14, palette.red)
    for _, x in ipairs({ -27, 27 }) do
        local tower = part(group, "LaunchTower", Vector3.new(8, 15, 8), CFrame.new(center + Vector3.new(x, 7.5, 7)), Enum.Material.Metal, palette.dark)
        part(group, "TowerPanel", Vector3.new(5.6, 8.5, 0.2), tower.CFrame * CFrame.new(0, 1, -4.1), Enum.Material.Neon, x < 0 and palette.cyan or palette.red, 0.34)
        light(tower, palette.red, 0.5, 20)
    end
    for _, z in ipairs({ -4, 12, 28 }) do
        part(group, "OverheadGantry", Vector3.new(50, 1.4, 3), CFrame.new(center + Vector3.new(0, 16, z)), Enum.Material.Metal, palette.mid)
        part(group, "GantrySignal", Vector3.new(38, 0.18, 3.1), CFrame.new(center + Vector3.new(0, 15.1, z)), Enum.Material.Neon, z < 20 and palette.neutral or palette.red, 0.2)
    end
    crateStack(group, center + Vector3.new(-31, 0, -10), palette.red)
    crateStack(group, center + Vector3.new(31, 0, -10), palette.cyan)
end

-- Trophy wall becomes a proper memorial corridor rather than loose plaques on a wall.
do
    local group = Instance.new("Folder")
    group.Name = "MemorialFacility"
    group.Parent = architecture
    local center = ORIGIN + Vector3.new(0, 0, -84)
    for _, x in ipairs({ -42, 42 }) do
        part(group, "MemorialPillar", Vector3.new(4, 12, 4), CFrame.new(center + Vector3.new(x, 6, 4)), Enum.Material.Metal, palette.dark)
        part(group, "MemorialGlow", Vector3.new(2.6, 0.3, 4.1), CFrame.new(center + Vector3.new(x, 8.5, 4)), Enum.Material.Neon, palette.amber, 0.14)
    end
    strip(group, "MemorialLight", center + Vector3.new(0, 14.6, 3), Vector3.new(58, 0.18, 2.2), palette.warm)
    for _, x in ipairs({ -30, 30 }) do
        local bench = part(group, "MemorialBench", Vector3.new(18, 1.2, 4), CFrame.new(center + Vector3.new(x, 1.4, 16)), Enum.Material.WoodPlanks, Color3.fromRGB(96, 78, 62))
        part(group, "BenchFrame", Vector3.new(19, 0.25, 4.5), bench.CFrame * CFrame.new(0, -0.8, 0), Enum.Material.Metal, palette.dark)
    end
end

print("[Vaultfall Safehouse Architecture] authored facility pass ready")
