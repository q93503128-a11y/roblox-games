local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("VaultfallWorld", 20)
if not world then
    warn("[Vaultfall Architecture] world unavailable; sector architecture pass skipped")
    return
end

local previous = world:FindFirstChild("SectorArchitecture")
if previous then
    previous:Destroy()
end

local root = Instance.new("Folder")
root.Name = "SectorArchitecture"
root.Parent = world

local palette = {
    Steel = Color3.fromRGB(70, 76, 82),
    SteelDark = Color3.fromRGB(43, 49, 55),
    Concrete = Color3.fromRGB(76, 81, 86),
    ConcreteLight = Color3.fromRGB(98, 103, 108),
    Cyan = Color3.fromRGB(80, 164, 182),
    Amber = Color3.fromRGB(217, 156, 78),
    Violet = Color3.fromRGB(142, 105, 177),
    Green = Color3.fromRGB(96, 168, 135),
    Blue = Color3.fromRGB(99, 139, 187),
    Red = Color3.fromRGB(188, 73, 81),
    Neutral = Color3.fromRGB(215, 226, 230),
}

local accents = {
    Combat = palette.Cyan,
    Treasure = palette.Amber,
    Elite = palette.Violet,
    Shrine = palette.Green,
    DeepCombat = palette.Blue,
    Boss = palette.Red,
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

local function light(host, color, brightness, range)
    local point = Instance.new("PointLight")
    point.Name = "ArchitecturalLight"
    point.Color = color
    point.Brightness = brightness or 0.7
    point.Range = range or 22
    point.Shadows = false
    point.Parent = host
    return point
end

local function roomType(zone)
    return string.match(zone.Name, "^Zone_%d+_(.+)$") or "Combat"
end

local function roomIndex(zone)
    return tonumber(string.match(zone.Name, "^Zone_(%d+)_")) or 0
end

local function localPoint(center, x, y, z)
    return CFrame.new(center + Vector3.new(x, y, z))
end

local function addPortalRibs(group, center, sx, sz, accent, count)
    local halfX = math.max(24, sx * 0.5 - 8)
    local halfZ = math.max(24, sz * 0.5 - 8)
    local ribs = math.max(3, count or 4)
    for i = 1, ribs do
        local alpha = i / (ribs + 1)
        local z = -halfZ + alpha * (halfZ * 2)
        part(group, "PortalRibL", Vector3.new(2.2, 13, 3), localPoint(center, -halfX, 6.5, z), Enum.Material.Metal, palette.SteelDark)
        part(group, "PortalRibR", Vector3.new(2.2, 13, 3), localPoint(center, halfX, 6.5, z), Enum.Material.Metal, palette.SteelDark)
        local header = part(group, "PortalRibHeader", Vector3.new(halfX * 2 + 2.2, 1.4, 3), localPoint(center, 0, 12.8, z), Enum.Material.Metal, palette.Steel)
        local strip = neon(group, "PortalRibStrip", Vector3.new(math.max(12, halfX * 2 - 8), 0.18, 1.2), header.CFrame * CFrame.new(0, -0.82, 0), accent, 0.2)
        if i == math.ceil(ribs * 0.5) then
            light(strip, accent, 0.7, 24)
        end
    end
end

local function addSideBays(group, center, sx, sz, accent)
    local x = math.max(26, sx * 0.5 - 10)
    local z = math.max(22, sz * 0.5 - 18)
    for _, side in ipairs({ -1, 1 }) do
        local bayCenter = center + Vector3.new(x * side, 0, z)
        part(group, "ServiceBayWall", Vector3.new(8, 9, 24), CFrame.new(bayCenter + Vector3.new(0, 4.5, 0)), Enum.Material.Concrete, palette.Concrete)
        part(group, "ServiceBayCap", Vector3.new(11, 1, 27), CFrame.new(bayCenter + Vector3.new(0, 9.2, 0)), Enum.Material.Metal, palette.SteelDark)
        local lamp = neon(group, "ServiceBayLamp", Vector3.new(0.25, 5, 12), CFrame.new(bayCenter + Vector3.new(-side * 4.2, 5, 0)), accent, 0.18)
        light(lamp, accent, 0.55, 18)
    end
end

local function buildCombat(group, center, sx, sz, accent, index)
    addPortalRibs(group, center, sx, sz, accent, index % 2 == 0 and 4 or 3)
    addSideBays(group, center, sx, sz, accent)

    local offset = index % 2 == 0 and 18 or -18
    local frame = part(group, "CombatMachineFrame", Vector3.new(18, 10, 10), localPoint(center, offset, 5, 12), Enum.Material.Metal, palette.SteelDark)
    part(group, "CombatMachineInset", Vector3.new(14, 6, 10.4), frame.CFrame, Enum.Material.Metal, palette.Steel, 0.04)
    local core = neon(group, "CombatMachineCore", Vector3.new(7, 3.8, 10.8), frame.CFrame, accent, 0.2)
    light(core, accent, 0.65, 18)
end

local function buildTreasure(group, center, sx, sz, accent)
    local halfX = math.max(28, sx * 0.5 - 11)
    local halfZ = math.max(28, sz * 0.5 - 11)

    for _, z in ipairs({ -halfZ * 0.55, halfZ * 0.55 }) do
        for _, x in ipairs({ -halfX * 0.72, 0, halfX * 0.72 }) do
            local column = part(group, "VaultColumn", Vector3.new(5, 11, 5), localPoint(center, x, 5.5, z), Enum.Material.Metal, palette.SteelDark)
            local band = neon(group, "VaultColumnBand", Vector3.new(5.4, 0.55, 5.4), column.CFrame * CFrame.new(0, 2.2, 0), accent, 0.14)
            if x == 0 then
                light(band, accent, 0.6, 18)
            end
        end
    end

    local canopy = part(group, "VaultCanopy", Vector3.new(math.max(28, sx * 0.52), 1.2, math.max(22, sz * 0.34)), localPoint(center, 0, 13.5, 0), Enum.Material.Metal, palette.SteelDark)
    local diffuser = neon(group, "VaultCanopyDiffuser", Vector3.new(math.max(24, sx * 0.48), 0.18, math.max(18, sz * 0.30)), canopy.CFrame * CFrame.new(0, -0.72, 0), palette.Neutral, 0.25)
    light(diffuser, palette.Neutral, 0.85, 26)
end

local function buildElite(group, center, sx, sz, accent)
    local halfX = math.max(28, sx * 0.5 - 13)
    local halfZ = math.max(28, sz * 0.5 - 13)

    for _, corner in ipairs({
        Vector3.new(-halfX, 0, -halfZ),
        Vector3.new(halfX, 0, -halfZ),
        Vector3.new(-halfX, 0, halfZ),
        Vector3.new(halfX, 0, halfZ),
    }) do
        local tower = part(group, "EliteButtress", Vector3.new(7, 15, 7), CFrame.new(center + corner + Vector3.new(0, 7.5, 0)), Enum.Material.Concrete, palette.SteelDark)
        local slit = neon(group, "EliteThreatSlit", Vector3.new(0.35, 8, 2.2), tower.CFrame * CFrame.new(corner.X < 0 and 3.65 or -3.65, 0, 0), accent, 0.1)
        light(slit, accent, 0.55, 17)
    end

    local spine = part(group, "EliteOverheadSpine", Vector3.new(math.max(30, sx * 0.58), 2.2, 5), localPoint(center, 0, 15.5, 0), Enum.Material.Metal, palette.SteelDark)
    neon(group, "EliteOverheadWarning", Vector3.new(math.max(24, sx * 0.5), 0.22, 2.2), spine.CFrame * CFrame.new(0, -1.3, 0), accent, 0.14)
end

local function buildShrine(group, center, sx, sz, accent)
    local radiusX = math.max(22, math.min(sx, sz) * 0.22)
    for i = 1, 8 do
        local angle = (i / 8) * math.pi * 2
        local x = math.cos(angle) * radiusX
        local z = math.sin(angle) * radiusX
        local column = part(group, "ShrinePillar", Vector3.new(3.6, 10, 3.6), localPoint(center, x, 5, z), Enum.Material.Slate, palette.ConcreteLight)
        neon(group, "ShrineGlyph", Vector3.new(1.6, 5.2, 0.18), column.CFrame * CFrame.new(0, 0, -1.9), accent, 0.16)
    end

    local halo = neon(group, "ShrineHalo", Vector3.new(radiusX * 1.4, 0.3, radiusX * 1.4), localPoint(center, 0, 13.2, 0), accent, 0.78)
    halo.Shape = Enum.PartType.Cylinder
    halo.CFrame = halo.CFrame * CFrame.Angles(0, 0, math.rad(90))
    light(halo, accent, 0.7, 24)
end

local function buildDeepCombat(group, center, sx, sz, accent, index)
    addPortalRibs(group, center, sx, sz, accent, 5)

    local halfX = math.max(28, sx * 0.5 - 12)
    local z = index % 2 == 0 and -20 or 20
    for _, side in ipairs({ -1, 1 }) do
        local pipeX = halfX * side
        for y = 4, 12, 4 do
            local pipe = part(group, "DeepUtilityPipe", Vector3.new(3.2, 3.2, math.max(36, sz * 0.58)), localPoint(center, pipeX, y, z * 0.15), Enum.Material.Metal, palette.SteelDark)
            pipe.Shape = Enum.PartType.Cylinder
            pipe.CFrame = pipe.CFrame * CFrame.Angles(math.rad(90), 0, 0)
        end
        local lamp = neon(group, "DeepUtilityLamp", Vector3.new(0.35, 7, 4), localPoint(center, pipeX - side * 2.3, 7, 0), accent, 0.14)
        light(lamp, accent, 0.6, 20)
    end
end

local function buildBoss(group, center, sx, sz, accent)
    local halfX = math.max(30, sx * 0.5 - 10)
    local halfZ = math.max(30, sz * 0.5 - 10)

    for i = 1, 6 do
        local angle = (i / 6) * math.pi * 2
        local x = math.cos(angle) * math.min(halfX, 42)
        local z = math.sin(angle) * math.min(halfZ, 42)
        local pylon = part(group, "BossArenaPylon", Vector3.new(6.5, 16, 6.5), localPoint(center, x, 8, z), Enum.Material.Metal, palette.SteelDark)
        local eye = neon(group, "BossArenaEye", Vector3.new(2.4, 6.8, 0.3), pylon.CFrame * CFrame.new(0, 0.8, -3.4), accent, 0.12)
        light(eye, accent, 0.6, 20)
    end

    local crown = part(group, "BossArenaCrown", Vector3.new(math.max(42, sx * 0.5), 2.4, math.max(42, sz * 0.5)), localPoint(center, 0, 18, 0), Enum.Material.Metal, palette.SteelDark, 0.18)
    crown.CanCollide = false
    local core = neon(group, "BossArenaCrownCore", Vector3.new(math.max(28, sx * 0.3), 0.3, math.max(28, sz * 0.3)), crown.CFrame * CFrame.new(0, -1.35, 0), accent, 0.38)
    light(core, accent, 0.95, 34)
end

local dungeon = world:FindFirstChild("Sector07")
if not dungeon then
    warn("[Vaultfall Architecture] Sector07 folder unavailable; pass skipped")
    return
end

local built = 0
for _, zone in ipairs(dungeon:GetChildren()) do
    if zone:IsA("Folder") and string.match(zone.Name, "^Zone_%d+_") then
        local floor = zone:FindFirstChild("Floor")
        if floor and floor:IsA("BasePart") then
            local kind = roomType(zone)
            local index = roomIndex(zone)
            local accent = accents[kind] or palette.Cyan
            local center = floor.Position
            local sx = floor.Size.X
            local sz = floor.Size.Z

            local group = Instance.new("Folder")
            group.Name = zone.Name .. "_Architecture"
            group.Parent = root

            if kind == "Treasure" then
                buildTreasure(group, center, sx, sz, accent)
            elseif kind == "Elite" then
                buildElite(group, center, sx, sz, accent)
            elseif kind == "Shrine" then
                buildShrine(group, center, sx, sz, accent)
            elseif kind == "DeepCombat" then
                buildDeepCombat(group, center, sx, sz, accent, index)
            elseif kind == "Boss" then
                buildBoss(group, center, sx, sz, accent)
            else
                buildCombat(group, center, sx, sz, accent, index)
            end
            built += 1
        end
    end
end

print(string.format("[Vaultfall Architecture] authored structural identities ready for %d sectors", built))
