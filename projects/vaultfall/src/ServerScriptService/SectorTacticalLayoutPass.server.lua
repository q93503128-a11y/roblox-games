local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("VaultfallWorld", 20)
if not world then
    warn("[Vaultfall TacticalLayout] world unavailable; tactical layout pass skipped")
    return
end

local dungeon = world:FindFirstChild("Sector07")
if not dungeon then
    warn("[Vaultfall TacticalLayout] Sector07 unavailable; tactical layout pass skipped")
    return
end

local previous = world:FindFirstChild("SectorTacticalLayouts")
if previous then
    previous:Destroy()
end

local root = Instance.new("Folder")
root.Name = "SectorTacticalLayouts"
root.Parent = world

local palette = {
    Steel = Color3.fromRGB(78, 84, 89),
    SteelDark = Color3.fromRGB(49, 55, 60),
    Concrete = Color3.fromRGB(92, 96, 100),
    ConcreteLight = Color3.fromRGB(116, 120, 124),
    Neutral = Color3.fromRGB(224, 232, 235),
    Cyan = Color3.fromRGB(83, 172, 193),
    Amber = Color3.fromRGB(226, 167, 83),
    Violet = Color3.fromRGB(155, 119, 191),
    Green = Color3.fromRGB(101, 181, 143),
    Blue = Color3.fromRGB(105, 151, 202),
    Red = Color3.fromRGB(203, 82, 91),
}

local accents = {
    Combat = palette.Cyan,
    Treasure = palette.Amber,
    Elite = palette.Violet,
    Shrine = palette.Green,
    DeepCombat = palette.Blue,
    Boss = palette.Red,
}

local combatTypes = {
    Combat = true,
    DeepCombat = true,
    Elite = true,
}

local function part(parent, name, size, cframe, material, color, transparency, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.CanCollide = collide == true
    p.CanTouch = false
    p.CanQuery = collide == true
    p.CastShadow = false
    p.Material = material or Enum.Material.Metal
    p.Color = color or palette.Steel
    p.Transparency = transparency or 0
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function neon(parent, name, size, cframe, color, transparency)
    return part(parent, name, size, cframe, Enum.Material.Neon, color, transparency or 0.12, false)
end

local function addLight(host, color, brightness, range)
    local lamp = Instance.new("PointLight")
    lamp.Name = "TacticalLayoutLight"
    lamp.Color = color
    lamp.Brightness = brightness or 0.55
    lamp.Range = range or 18
    lamp.Shadows = false
    lamp.Parent = host
end

local function zoneType(zone)
    return string.match(zone.Name, "^Zone_%d+_(.+)$") or "Combat"
end

local function zoneIndex(zone)
    return tonumber(string.match(zone.Name, "^Zone_(%d+)_")) or 0
end

local function floorTop(floor)
    return floor.Position.Y + floor.Size.Y * 0.5
end

local function safeHalfExtents(floor)
    return math.max(28, floor.Size.X * 0.5 - 20), math.max(28, floor.Size.Z * 0.5 - 20)
end

local function addRouteInlays(group, floor, accent, index)
    local y = floorTop(floor) + 0.08
    local halfX, halfZ = safeHalfExtents(floor)
    local laneWidth = 3.6

    neon(group, "PrimaryRouteX", Vector3.new(halfX * 1.72, 0.12, laneWidth), CFrame.new(floor.Position.X, y, floor.Position.Z), accent, 0.58)
    neon(group, "PrimaryRouteZ", Vector3.new(laneWidth, 0.12, halfZ * 1.72), CFrame.new(floor.Position.X, y + 0.01, floor.Position.Z), accent, 0.58)

    local offset = index % 2 == 0 and 16 or -16
    neon(group, "SecondaryRoute", Vector3.new(math.max(26, halfX * 0.72), 0.13, 1.6), CFrame.new(floor.Position.X + offset, y + 0.02, floor.Position.Z + halfZ * 0.28), palette.Neutral, 0.72)
end

local function addCoverPod(group, center, yaw, accent, variant)
    local rotation = CFrame.Angles(0, math.rad(yaw), 0)
    local base = CFrame.new(center) * rotation
    local width = variant == 2 and 15 or 12
    local height = variant == 2 and 4.6 or 3.8
    local depth = variant == 3 and 5.8 or 4.4

    local barrier = part(group, "TacticalCover", Vector3.new(width, height, depth), base * CFrame.new(0, height * 0.5, 0), Enum.Material.Metal, palette.Steel, 0, true)
    part(group, "CoverArmorInset", Vector3.new(width - 1.2, math.max(1.4, height - 1.1), depth + 0.08), barrier.CFrame * CFrame.new(0, 0.1, 0), Enum.Material.DiamondPlate, palette.SteelDark, 0.04, false)
    local strip = neon(group, "CoverIdentityStrip", Vector3.new(math.max(5, width - 3), 0.28, depth + 0.16), barrier.CFrame * CFrame.new(0, height * 0.32, 0), accent, 0.18)
    addLight(strip, accent, 0.35, 10)

    if variant == 3 then
        local shoulder = part(group, "CoverShoulder", Vector3.new(4.2, 6.2, depth), base * CFrame.new(width * 0.32, 3.1, 0), Enum.Material.Metal, palette.SteelDark, 0, true)
        neon(group, "CoverShoulderMark", Vector3.new(2.2, 0.24, depth + 0.12), shoulder.CFrame * CFrame.new(0, 1.9, 0), accent, 0.18)
    end
end

local function addCombatLayout(group, floor, kind, index, accent)
    local top = floorTop(floor)
    local halfX, halfZ = safeHalfExtents(floor)

    -- Keep a broad cross through the room completely clear so every cardinal door,
    -- objective and emergency recovery path remains reachable.
    local x = math.min(halfX * 0.55, 34)
    local z = math.min(halfZ * 0.52, 32)
    local alternating = index % 2 == 0 and 1 or -1

    addCoverPod(group, Vector3.new(floor.Position.X - x, top, floor.Position.Z - z), 28 * alternating, accent, 1)
    addCoverPod(group, Vector3.new(floor.Position.X + x, top, floor.Position.Z + z), -28 * alternating, accent, 2)
    addCoverPod(group, Vector3.new(floor.Position.X - x, top, floor.Position.Z + z), -18 * alternating, accent, 3)
    addCoverPod(group, Vector3.new(floor.Position.X + x, top, floor.Position.Z - z), 18 * alternating, accent, 1)

    -- A readable side perch adds vertical silhouette and flanking interest without
    -- blocking the room center. It is intentionally low enough to jump on/off.
    local perchSide = index % 2 == 0 and -1 or 1
    local perchCenter = Vector3.new(
        floor.Position.X + perchSide * math.min(halfX * 0.66, 40),
        top + 1.1,
        floor.Position.Z
    )
    local perch = part(group, "SidePerch", Vector3.new(18, 2.2, 26), CFrame.new(perchCenter), Enum.Material.DiamondPlate, palette.ConcreteLight, 0, true)
    neon(group, "PerchEdge", Vector3.new(18.4, 0.2, 2), perch.CFrame * CFrame.new(0, 1.18, -12.2), accent, 0.14)

    for _, stepZ in ipairs({ -9, 0, 9 }) do
        local step = part(
            group,
            "PerchStep",
            Vector3.new(6, 0.7, 7),
            CFrame.new(perchCenter.X - perchSide * 11.4, top + 0.35 + math.abs(stepZ) * 0.01, perchCenter.Z + stepZ),
            Enum.Material.DiamondPlate,
            palette.Steel,
            0,
            true
        )
        step:SetAttribute("TraversalAssist", true)
    end

    if kind == "Elite" then
        local warning = neon(group, "EliteArenaBoundary", Vector3.new(math.max(28, halfX * 0.92), 0.16, 2.4), CFrame.new(floor.Position.X, top + 0.11, floor.Position.Z - halfZ * 0.66), accent, 0.38)
        addLight(warning, accent, 0.45, 16)
    elseif kind == "DeepCombat" then
        for _, side in ipairs({ -1, 1 }) do
            local trench = part(group, "UtilityTrenchLip", Vector3.new(3.5, 1.8, math.max(24, halfZ * 0.72)), CFrame.new(floor.Position.X + side * halfX * 0.72, top + 0.9, floor.Position.Z), Enum.Material.Metal, palette.SteelDark, 0, true)
            neon(group, "UtilityTrenchGuide", Vector3.new(0.3, 0.24, trench.Size.Z - 4), trench.CFrame * CFrame.new(-side * 1.82, 0.45, 0), accent, 0.18)
        end
    end
end

local function addTreasureLayout(group, floor, accent)
    local top = floorTop(floor)
    local halfX, halfZ = safeHalfExtents(floor)
    local radiusX = math.min(halfX * 0.44, 26)
    local radiusZ = math.min(halfZ * 0.38, 24)

    for _, spec in ipairs({
        { -radiusX, -radiusZ, 18 },
        { radiusX, -radiusZ, -18 },
        { -radiusX, radiusZ, -18 },
        { radiusX, radiusZ, 18 },
    }) do
        local plinth = part(group, "VaultDisplayPlinth", Vector3.new(12, 1.4, 8), CFrame.new(floor.Position.X + spec[1], top + 0.7, floor.Position.Z + spec[2]) * CFrame.Angles(0, math.rad(spec[3]), 0), Enum.Material.Marble, palette.ConcreteLight, 0, false)
        neon(group, "VaultDisplayEdge", Vector3.new(8.5, 0.18, 8.15), plinth.CFrame * CFrame.new(0, 0.8, 0), accent, 0.32)
    end
end

local function addShrineLayout(group, floor, accent)
    local top = floorTop(floor)
    local halfX, halfZ = safeHalfExtents(floor)
    local radius = math.min(halfX, halfZ, 34) * 0.72

    for i = 1, 6 do
        local angle = (i / 6) * math.pi * 2
        local center = Vector3.new(floor.Position.X + math.cos(angle) * radius, top + 0.12, floor.Position.Z + math.sin(angle) * radius)
        local marker = neon(group, "ShrineApproachMarker", Vector3.new(7, 0.16, 2.1), CFrame.new(center) * CFrame.Angles(0, -angle, 0), accent, 0.38)
        if i % 2 == 0 then
            addLight(marker, accent, 0.38, 12)
        end
    end
end

local function addBossLayout(group, floor, accent)
    local top = floorTop(floor)
    local halfX, halfZ = safeHalfExtents(floor)
    local radius = math.min(halfX, halfZ, 48) * 0.58

    -- Boss telegraphs own the playable floor. These markers are visual-only and
    -- deliberately avoid adding collision that could invalidate attack patterns.
    for i = 1, 8 do
        local angle = (i / 8) * math.pi * 2
        local center = Vector3.new(floor.Position.X + math.cos(angle) * radius, top + 0.1, floor.Position.Z + math.sin(angle) * radius)
        neon(group, "BossOrientationTick", Vector3.new(6.5, 0.14, 1.5), CFrame.new(center) * CFrame.Angles(0, -angle, 0), accent, 0.34)
    end

    neon(group, "BossClearCenter", Vector3.new(9, 0.12, 9), CFrame.new(floor.Position.X, top + 0.11, floor.Position.Z), palette.Neutral, 0.76)
end

local built = 0
local combatLayouts = 0
for _, zone in ipairs(dungeon:GetChildren()) do
    if zone:IsA("Folder") and string.match(zone.Name, "^Zone_%d+_") then
        local floor = zone:FindFirstChild("Floor")
        if floor and floor:IsA("BasePart") then
            local kind = zoneType(zone)
            local index = zoneIndex(zone)
            local accent = accents[kind] or palette.Cyan
            local group = Instance.new("Folder")
            group.Name = zone.Name .. "_TacticalLayout"
            group.Parent = root

            addRouteInlays(group, floor, accent, index)
            if combatTypes[kind] then
                addCombatLayout(group, floor, kind, index, accent)
                combatLayouts += 1
            elseif kind == "Treasure" then
                addTreasureLayout(group, floor, accent)
            elseif kind == "Shrine" then
                addShrineLayout(group, floor, accent)
            elseif kind == "Boss" then
                addBossLayout(group, floor, accent)
            end

            group:SetAttribute("RoomIndex", index)
            group:SetAttribute("RoomType", kind)
            group:SetAttribute("CentralCrossKeptClear", true)
            built += 1
        end
    end
end

root:SetAttribute("SelfContained", true)
root:SetAttribute("ReadableRouteInlays", true)
root:SetAttribute("CombatLayoutsWithCover", combatLayouts)
root:SetAttribute("BuildVersion", 1)

print(string.format("[Vaultfall TacticalLayout] readable tactical layouts ready for %d sectors (%d combat layouts)", built, combatLayouts))
