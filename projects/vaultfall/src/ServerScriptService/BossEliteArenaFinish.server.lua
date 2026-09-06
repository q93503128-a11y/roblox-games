local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("VaultfallWorld", 20)
if not world then
    warn("[Vaultfall ArenaFinish] world unavailable; arena finish skipped")
    return
end

local dungeon = world:FindFirstChild("Sector07")
if not dungeon then
    warn("[Vaultfall ArenaFinish] Sector07 unavailable; arena finish skipped")
    return
end

local previous = world:FindFirstChild("BossEliteArenaFinish")
if previous then
    previous:Destroy()
end

local root = Instance.new("Folder")
root.Name = "BossEliteArenaFinish"
root.Parent = world

local palette = {
    Steel = Color3.fromRGB(76, 82, 88),
    SteelDark = Color3.fromRGB(46, 52, 58),
    Concrete = Color3.fromRGB(112, 117, 121),
    Neutral = Color3.fromRGB(220, 229, 232),
    Elite = Color3.fromRGB(155, 119, 191),
    Boss = Color3.fromRGB(203, 82, 91),
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
    return part(parent, name, size, cframe, Enum.Material.Neon, color, transparency or 0.2, false)
end

local function addLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Name = "ArenaRouteLight"
    light.Color = color
    light.Brightness = brightness or 0.35
    light.Range = range or 11
    light.Shadows = false
    light.Parent = host
end

local function floorTop(floor)
    return floor.Position.Y + floor.Size.Y * 0.5
end

local function zoneType(zone)
    return string.match(zone.Name, "^Zone_%d+_(.+)$") or ""
end

local function safeHalfExtents(floor)
    return math.max(30, floor.Size.X * 0.5 - 18), math.max(30, floor.Size.Z * 0.5 - 18)
end

local function addRouteMarker(group, position, yaw, length, accent)
    local marker = neon(
        group,
        "EscapeRouteMarker",
        Vector3.new(length, 0.12, 1.1),
        CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), 0),
        accent,
        0.52
    )
    addLight(marker, accent, 0.22, 8)
end

local function addCoverIsland(group, center, yaw, accent, tallSide)
    local base = CFrame.new(center) * CFrame.Angles(0, math.rad(yaw), 0)

    local barrier = part(
        group,
        "ArenaCoverLow",
        Vector3.new(11.5, 3.8, 4.2),
        base * CFrame.new(0, 1.9, 0),
        Enum.Material.Metal,
        palette.Steel,
        0,
        true
    )
    part(
        group,
        "ArenaCoverArmor",
        Vector3.new(10.1, 2.6, 4.3),
        barrier.CFrame * CFrame.new(0, 0.2, 0),
        Enum.Material.DiamondPlate,
        palette.SteelDark,
        0.03,
        false
    )

    local side = tallSide and 1 or -1
    local shoulder = part(
        group,
        "ArenaCoverShoulder",
        Vector3.new(3.2, 6.2, 4.2),
        base * CFrame.new(side * 4.15, 3.1, 0),
        Enum.Material.Metal,
        palette.SteelDark,
        0,
        true
    )

    local strip = neon(
        group,
        "ArenaCoverIdentity",
        Vector3.new(6.5, 0.24, 4.36),
        barrier.CFrame * CFrame.new(-side * 1.1, 1.15, 0),
        accent,
        0.2
    )
    addLight(strip, accent, 0.3, 9)
    neon(
        group,
        "ArenaShoulderMark",
        Vector3.new(1.6, 0.22, 4.36),
        shoulder.CFrame * CFrame.new(0, 1.85, 0),
        accent,
        0.22
    )
end

local function addBossArena(group, floor)
    local top = floorTop(floor)
    local halfX, halfZ = safeHalfExtents(floor)
    local radius = math.min(halfX, halfZ, 50) * 0.76

    -- Four diagonal cover islands create temporary LOS breaks while preserving
    -- every cardinal lane for boss telegraphs, recovery paths and co-op movement.
    for i, angleDeg in ipairs({ 45, 135, 225, 315 }) do
        local angle = math.rad(angleDeg)
        local center = Vector3.new(
            floor.Position.X + math.cos(angle) * radius,
            top,
            floor.Position.Z + math.sin(angle) * radius
        )
        addCoverIsland(group, center, -angleDeg + 90, palette.Boss, i % 2 == 0)
    end

    -- Cardinal route ticks make the safe circulation lanes obvious at a glance.
    local routeDistance = radius * 0.72
    addRouteMarker(group, Vector3.new(floor.Position.X + routeDistance, top + 0.09, floor.Position.Z), 90, 13, palette.Boss)
    addRouteMarker(group, Vector3.new(floor.Position.X - routeDistance, top + 0.09, floor.Position.Z), 90, 13, palette.Boss)
    addRouteMarker(group, Vector3.new(floor.Position.X, top + 0.09, floor.Position.Z + routeDistance), 0, 13, palette.Boss)
    addRouteMarker(group, Vector3.new(floor.Position.X, top + 0.09, floor.Position.Z - routeDistance), 0, 13, palette.Boss)

    group:SetAttribute("CardinalLanesKeptClear", true)
    group:SetAttribute("DiagonalCoverIslands", 4)
end

local function addEliteArena(group, floor)
    local top = floorTop(floor)
    local halfX, halfZ = safeHalfExtents(floor)
    local x = math.min(halfX * 0.62, 38)
    local z = math.min(halfZ * 0.28, 18)

    -- Elite rooms already receive four generic cover pods. These two staggered
    -- wings break the remaining straight sightline without sealing the center.
    addCoverIsland(
        group,
        Vector3.new(floor.Position.X - x, top, floor.Position.Z + z),
        18,
        palette.Elite,
        true
    )
    addCoverIsland(
        group,
        Vector3.new(floor.Position.X + x, top, floor.Position.Z - z),
        -18,
        palette.Elite,
        false
    )

    local laneZ = math.min(halfZ * 0.66, 36)
    addRouteMarker(group, Vector3.new(floor.Position.X - x * 0.45, top + 0.09, floor.Position.Z + laneZ), 0, 11, palette.Elite)
    addRouteMarker(group, Vector3.new(floor.Position.X + x * 0.45, top + 0.09, floor.Position.Z - laneZ), 0, 11, palette.Elite)

    group:SetAttribute("CenterKeptOpen", true)
    group:SetAttribute("StaggeredCoverWings", 2)
end

local bossRooms = 0
local eliteRooms = 0
for _, zone in ipairs(dungeon:GetChildren()) do
    if zone:IsA("Folder") and string.match(zone.Name, "^Zone_%d+_") then
        local kind = zoneType(zone)
        if kind == "Boss" or kind == "Elite" then
            local floor = zone:FindFirstChild("Floor")
            if floor and floor:IsA("BasePart") then
                local group = Instance.new("Folder")
                group.Name = zone.Name .. "_ArenaFinish"
                group.Parent = root

                if kind == "Boss" then
                    addBossArena(group, floor)
                    bossRooms += 1
                else
                    addEliteArena(group, floor)
                    eliteRooms += 1
                end
            end
        end
    end
end

root:SetAttribute("SelfContained", true)
root:SetAttribute("GameplayCover", true)
root:SetAttribute("BossRoomsFinished", bossRooms)
root:SetAttribute("EliteRoomsFinished", eliteRooms)
root:SetAttribute("BuildVersion", 1)

print(string.format(
    "[Vaultfall ArenaFinish] tactical cover/routes ready for %d boss room(s) and %d elite room(s)",
    bossRooms,
    eliteRooms
))
