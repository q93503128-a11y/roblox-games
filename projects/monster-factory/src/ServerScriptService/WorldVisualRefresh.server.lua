local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("MonsterFactoryWorld", 10)
if not world then
    warn("[MonsterFactory] Visual Rebuild 001 skipped: static world missing.")
    return
end

for _, name in ipairs({ "Baseplate", "SpawnLocation" }) do
    local legacy = Workspace:FindFirstChild(name)
    if legacy then
        legacy:Destroy()
    end
end

local COLORS = {
    dark = Color3.fromRGB(38, 46, 58),
    dark2 = Color3.fromRGB(50, 61, 76),
    steel = Color3.fromRGB(103, 118, 137),
    path = Color3.fromRGB(91, 101, 113),
    meadow = Color3.fromRGB(53, 151, 65),
    meadowAccent = Color3.fromRGB(76, 235, 143),
    desert = Color3.fromRGB(194, 132, 55),
    desertAccent = Color3.fromRGB(255, 147, 53),
    frozen = Color3.fromRGB(126, 196, 225),
    frozenAccent = Color3.fromRGB(75, 221, 255),
    purple = Color3.fromRGB(137, 87, 205),
    collector = Color3.fromRGB(59, 214, 119),
}

local zoneDefs = {
    Meadow = {
        center = Vector3.new(0, 0, 0),
        display = "GREEN MEADOWS",
        floor = COLORS.meadow,
        accent = COLORS.meadowAccent,
        material = Enum.Material.Grass,
        decor = "meadow",
    },
    Desert = {
        center = Vector3.new(280, 0, 0),
        display = "DESERT OUTPOST",
        floor = COLORS.desert,
        accent = COLORS.desertAccent,
        material = Enum.Material.Sand,
        decor = "desert",
    },
    Frozen = {
        center = Vector3.new(560, 0, 0),
        display = "FROZEN LAB",
        floor = COLORS.frozen,
        accent = COLORS.frozenAccent,
        material = Enum.Material.Ice,
        decor = "frozen",
    },
}

local function makePart(parent, name, size, position, color, material, collide, transparency)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.CanCollide = collide ~= false
    part.Size = size
    part.Position = position
    part.Color = color
    part.Material = material or Enum.Material.SmoothPlastic
    part.Transparency = transparency or 0
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function glowPart(parent, name, size, position, color, transparency)
    local part = makePart(
        parent,
        name,
        size,
        position,
        color,
        Enum.Material.Neon,
        false,
        transparency or 0.12
    )
    part.CastShadow = false
    return part
end

local function addLight(part, color, range, brightness)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Range = range or 14
    light.Brightness = brightness or 1
    light.Parent = part
end

local function addBillboard(part, text, accent)
    local gui = Instance.new("BillboardGui")
    gui.Name = "ZoneBillboard"
    gui.Size = UDim2.fromOffset(260, 52)
    gui.StudsOffset = Vector3.new(0, 4.5, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 220
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Color3.fromRGB(18, 23, 31)
    label.BackgroundTransparency = 0.08
    label.Text = text
    label.TextColor3 = Color3.fromRGB(245, 249, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 20
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = label

    local stroke = Instance.new("UIStroke")
    stroke.Color = accent
    stroke.Thickness = 2
    stroke.Transparency = 0.15
    stroke.Parent = label
end

local function removeOldDecor(zone)
    local prefixes = {
        "TreeTrunk_", "TreeTop_", "CactusBody_", "CactusArm_", "IceCrystal_",
    }
    for _, child in ipairs(zone:GetChildren()) do
        for _, prefix in ipairs(prefixes) do
            if string.sub(child.Name, 1, #prefix) == prefix then
                child:Destroy()
                break
            end
        end
    end
end

local function styleAnchor(zone, def)
    local center = def.center
    local floor = zone:FindFirstChild(def.decor == "meadow" and "MeadowFloor" or def.decor == "desert" and "DesertFloor" or "FrozenFloor")
    if floor and floor:IsA("BasePart") then
        floor.Size = Vector3.new(220, 2, 180)
        floor.Position = center + Vector3.new(0, -1, 0)
        floor.Color = def.floor
        floor.Material = def.material
    end

    local pad = zone:FindFirstChild("FactoryPad")
    if pad and pad:IsA("BasePart") then
        pad.Size = Vector3.new(112, 1, 88)
        pad.Position = center + Vector3.new(0, 0.2, -4)
        pad.Color = COLORS.dark
        pad.Material = Enum.Material.Metal
    end

    local generator = zone:FindFirstChild("Generator")
    if generator and generator:IsA("BasePart") then
        generator.Size = Vector3.new(16, 12, 16)
        generator.Position = center + Vector3.new(-32, 6, -20)
        generator.Color = def.accent
        generator.Material = Enum.Material.Metal
    end

    local conveyor = zone:FindFirstChild("ConveyorCore")
    if conveyor and conveyor:IsA("BasePart") then
        conveyor.Size = Vector3.new(34, 3, 12)
        conveyor.Position = center + Vector3.new(0, 2, -18)
        conveyor.Color = Color3.fromRGB(48, 59, 73)
        conveyor.Material = Enum.Material.Metal
    end

    local reactor = zone:FindFirstChild("Reactor")
    if reactor and reactor:IsA("BasePart") then
        reactor.Size = Vector3.new(18, 18, 18)
        reactor.Position = center + Vector3.new(32, 9, -20)
        reactor.Color = COLORS.purple
        reactor.Material = Enum.Material.Metal
    end

    local capsule = zone:FindFirstChild(zone.Name .. "CapsuleMachine")
    if capsule and capsule:IsA("BasePart") then
        capsule.Size = Vector3.new(15, 12, 15)
        capsule.Position = center + Vector3.new(-38, 6, 28)
        capsule.Color = def.accent
        capsule.Material = Enum.Material.Metal
    end

    local collector = zone:FindFirstChild("Collector")
    if collector and collector:IsA("BasePart") then
        collector.Size = Vector3.new(18, 5, 12)
        collector.Position = center + Vector3.new(38, 2.5, 28)
        collector.Color = COLORS.collector
        collector.Material = Enum.Material.Metal
    end

    local marker = zone:FindFirstChild("ZoneMarker")
    if marker and marker:IsA("BasePart") then
        marker.Size = Vector3.new(34, 1.2, 12)
        marker.Position = center + Vector3.new(0, 0.7, 77)
        marker.Color = def.accent
        marker.Material = Enum.Material.Neon
        marker.Transparency = 0.08
    end

    local stations = zone:FindFirstChild("WorkerStations")
    if stations then
        local positions = {
            Vector3.new(-24, 0.8, 8), Vector3.new(-8, 0.8, 8),
            Vector3.new(8, 0.8, 8), Vector3.new(24, 0.8, 8),
            Vector3.new(-8, 0.8, 19), Vector3.new(8, 0.8, 19),
        }
        for index, offset in ipairs(positions) do
            local station = stations:FindFirstChild("WorkerStation_" .. index)
            if station and station:IsA("BasePart") then
                station.Size = Vector3.new(8, 1, 8)
                station.Position = center + offset
                station.Color = Color3.fromRGB(43, 52, 65)
                station.Material = Enum.Material.Metal
            end
        end
    end
end

local function addMachineDetails(visuals, def)
    local c = def.center
    local a = def.accent

    makePart(visuals, "IslandUnderlay", Vector3.new(208, 4, 168), c + Vector3.new(0, -3, 0), def.floor:Lerp(Color3.new(0, 0, 0), 0.42), Enum.Material.Slate)

    makePart(visuals, "EntryPath", Vector3.new(24, 1, 54), c + Vector3.new(0, 0.1, 55), COLORS.path, Enum.Material.Concrete)
    glowPart(visuals, "EntryGlowL", Vector3.new(1.4, 0.35, 54), c + Vector3.new(-10.8, 0.76, 55), a, 0.08)
    glowPart(visuals, "EntryGlowR", Vector3.new(1.4, 0.35, 54), c + Vector3.new(10.8, 0.76, 55), a, 0.08)

    makePart(visuals, "PadTrimNorth", Vector3.new(112, 1.2, 2.5), c + Vector3.new(0, 0.85, -48), a, Enum.Material.Neon, false, 0.06)
    makePart(visuals, "PadTrimSouth", Vector3.new(112, 1.2, 2.5), c + Vector3.new(0, 0.85, 40), a, Enum.Material.Neon, false, 0.06)
    makePart(visuals, "PadTrimWest", Vector3.new(2.5, 1.2, 88), c + Vector3.new(-56, 0.85, -4), a, Enum.Material.Neon, false, 0.06)
    makePart(visuals, "PadTrimEast", Vector3.new(2.5, 1.2, 88), c + Vector3.new(56, 0.85, -4), a, Enum.Material.Neon, false, 0.06)

    makePart(visuals, "GeneratorBase", Vector3.new(22, 2, 22), c + Vector3.new(-32, 1, -20), COLORS.dark2, Enum.Material.Metal)
    makePart(visuals, "GeneratorCap", Vector3.new(10, 4, 10), c + Vector3.new(-32, 14, -20), a:Lerp(Color3.new(1, 1, 1), 0.20), Enum.Material.Metal)
    glowPart(visuals, "GeneratorCore", Vector3.new(9, 6, 9), c + Vector3.new(-32, 7, -20), a, 0.22)
    makePart(visuals, "GeneratorPipeL", Vector3.new(4, 8, 4), c + Vector3.new(-43, 6, -20), COLORS.steel, Enum.Material.Metal)
    makePart(visuals, "GeneratorPipeR", Vector3.new(4, 8, 4), c + Vector3.new(-21, 6, -20), COLORS.steel, Enum.Material.Metal)

    makePart(visuals, "ConveyorBelt", Vector3.new(46, 1.1, 10), c + Vector3.new(0, 3.8, -18), Color3.fromRGB(71, 83, 99), Enum.Material.Metal)
    glowPart(visuals, "ConveyorRailL", Vector3.new(46, 1.5, 0.9), c + Vector3.new(0, 4.4, -23.4), a, 0.05)
    glowPart(visuals, "ConveyorRailR", Vector3.new(46, 1.5, 0.9), c + Vector3.new(0, 4.4, -12.6), a, 0.05)
    makePart(visuals, "ConveyorOutput", Vector3.new(12, 2, 24), c + Vector3.new(0, 1.6, 0), Color3.fromRGB(55, 65, 80), Enum.Material.Metal)
    glowPart(visuals, "ConveyorOutputCore", Vector3.new(8, 0.45, 22), c + Vector3.new(0, 2.85, 0), a, 0.12)

    makePart(visuals, "ReactorBase", Vector3.new(24, 2, 24), c + Vector3.new(32, 1, -20), COLORS.dark2, Enum.Material.Metal)
    local reactorCore = glowPart(visuals, "ReactorCore", Vector3.new(10, 10, 10), c + Vector3.new(32, 9, -20), a, 0.16)
    addLight(reactorCore, a, 20, 1.4)
    makePart(visuals, "ReactorStackL", Vector3.new(4, 17, 4), c + Vector3.new(43, 8.5, -20), COLORS.steel, Enum.Material.Metal)
    makePart(visuals, "ReactorStackR", Vector3.new(4, 17, 4), c + Vector3.new(21, 8.5, -20), COLORS.steel, Enum.Material.Metal)
    makePart(visuals, "ReactorTop", Vector3.new(14, 3, 14), c + Vector3.new(32, 19.5, -20), COLORS.dark2, Enum.Material.Metal)

    makePart(visuals, "CapsuleBase", Vector3.new(22, 2, 22), c + Vector3.new(-38, 1, 28), COLORS.dark2, Enum.Material.Metal)
    local capsuleGlow = glowPart(visuals, "CapsuleChamber", Vector3.new(11, 8, 11), c + Vector3.new(-38, 14, 28), a:Lerp(Color3.new(1, 1, 1), 0.15), 0.33)
    addLight(capsuleGlow, a, 15, 0.8)
    makePart(visuals, "CapsuleSign", Vector3.new(18, 4, 2), c + Vector3.new(-38, 18, 36), a, Enum.Material.Neon, false, 0.04)

    makePart(visuals, "CollectorBase", Vector3.new(24, 1.5, 18), c + Vector3.new(38, 0.8, 28), COLORS.dark2, Enum.Material.Metal)
    makePart(visuals, "CollectorBin", Vector3.new(12, 7, 8), c + Vector3.new(38, 7, 28), COLORS.collector, Enum.Material.Metal)
    local collectorGlow = glowPart(visuals, "CollectorGlow", Vector3.new(10, 2, 6), c + Vector3.new(38, 10.5, 28), Color3.fromRGB(115, 255, 164), 0.10)
    addLight(collectorGlow, Color3.fromRGB(115, 255, 164), 13, 0.8)

    makePart(visuals, "PortalPillarL", Vector3.new(6, 22, 6), c + Vector3.new(-15, 11, 78), COLORS.dark2, Enum.Material.Metal)
    makePart(visuals, "PortalPillarR", Vector3.new(6, 22, 6), c + Vector3.new(15, 11, 78), COLORS.dark2, Enum.Material.Metal)
    local header = makePart(visuals, "PortalHeader", Vector3.new(36, 6, 6), c + Vector3.new(0, 23, 78), COLORS.dark2, Enum.Material.Metal)
    local portal = glowPart(visuals, "PortalGlow", Vector3.new(24, 18, 1), c + Vector3.new(0, 12, 78), a, 0.42)
    addLight(portal, a, 18, 1)
    addBillboard(header, def.display, a)

    local stations = world:FindFirstChild(def.key or "")
    if stations then
        stations = stations:FindFirstChild("WorkerStations")
    end
    local stationOffsets = {
        Vector3.new(-24, 1.45, 8), Vector3.new(-8, 1.45, 8),
        Vector3.new(8, 1.45, 8), Vector3.new(24, 1.45, 8),
        Vector3.new(-8, 1.45, 19), Vector3.new(8, 1.45, 19),
    }
    for i, offset in ipairs(stationOffsets) do
        glowPart(visuals, "WorkerPadGlow_" .. i, Vector3.new(5.7, 0.35, 5.7), c + offset, a, 0.10)
    end

    for i, z in ipairs({ -55, -24, 8, 40, 69 }) do
        for _, side in ipairs({ -1, 1 }) do
            local x = side * 88
            makePart(visuals, "LampPost_" .. i .. "_" .. side, Vector3.new(2, 10, 2), c + Vector3.new(x, 5, z), COLORS.dark2, Enum.Material.Metal)
            local lamp = glowPart(visuals, "LampGlow_" .. i .. "_" .. side, Vector3.new(4, 3, 4), c + Vector3.new(x, 11, z), a, 0.08)
            addLight(lamp, a, 16, 0.8)
        end
    end
end

local function addMeadowDecor(visuals, def)
    local c = def.center
    local spots = {
        Vector3.new(-82, 0, -58), Vector3.new(-76, 0, -24), Vector3.new(-84, 0, 18), Vector3.new(-74, 0, 58),
        Vector3.new(82, 0, -52), Vector3.new(86, 0, -14), Vector3.new(78, 0, 24), Vector3.new(84, 0, 58),
    }
    for i, p in ipairs(spots) do
        local base = c + p
        makePart(visuals, "TreeTrunk_" .. i, Vector3.new(3, 10, 3), base + Vector3.new(0, 5, 0), Color3.fromRGB(105, 63, 35), Enum.Material.Wood)
        local crown = makePart(visuals, "TreeCrown_" .. i, Vector3.new(12, 12, 12), base + Vector3.new(0, 14, 0), Color3.fromRGB(42, 135, 61), Enum.Material.Grass)
        crown.Shape = Enum.PartType.Ball
        local crown2 = makePart(visuals, "TreeCrownTop_" .. i, Vector3.new(8, 8, 8), base + Vector3.new(0, 20, 0), Color3.fromRGB(55, 171, 77), Enum.Material.Grass)
        crown2.Shape = Enum.PartType.Ball
    end
    for i, p in ipairs({ Vector3.new(-58, 0, -68), Vector3.new(-42, 0, 64), Vector3.new(56, 0, -66), Vector3.new(62, 0, 58) }) do
        makePart(visuals, "MeadowRock_" .. i, Vector3.new(10, 5, 8), c + p + Vector3.new(0, 2.5, 0), Color3.fromRGB(91, 103, 104), Enum.Material.Slate)
    end
end

local function addDesertDecor(visuals, def)
    local c = def.center
    local spots = {
        Vector3.new(-82, 0, -58), Vector3.new(-78, 0, -24), Vector3.new(-85, 0, 18), Vector3.new(-72, 0, 58),
        Vector3.new(82, 0, -52), Vector3.new(88, 0, -14), Vector3.new(78, 0, 25), Vector3.new(86, 0, 60),
    }
    for i, p in ipairs(spots) do
        local base = c + p
        makePart(visuals, "CactusBody_" .. i, Vector3.new(4, 15, 4), base + Vector3.new(0, 7.5, 0), Color3.fromRGB(35, 139, 61), Enum.Material.SmoothPlastic)
        makePart(visuals, "CactusArm_" .. i, Vector3.new(10, 3, 3), base + Vector3.new(3, 9, 0), Color3.fromRGB(35, 139, 61), Enum.Material.SmoothPlastic)
        makePart(visuals, "CactusTip_" .. i, Vector3.new(3, 7, 3), base + Vector3.new(7, 11, 0), Color3.fromRGB(35, 139, 61), Enum.Material.SmoothPlastic)
    end
    for i, p in ipairs({ Vector3.new(-56, 0, -65), Vector3.new(-48, 0, 62), Vector3.new(52, 0, -66), Vector3.new(62, 0, 55) }) do
        makePart(visuals, "DesertRock_" .. i, Vector3.new(13, 6, 9), c + p + Vector3.new(0, 3, 0), Color3.fromRGB(120, 77, 43), Enum.Material.Sandstone)
    end
end

local function addFrozenDecor(visuals, def)
    local c = def.center
    local spots = {
        Vector3.new(-84, 0, -58), Vector3.new(-78, 0, -24), Vector3.new(-86, 0, 18), Vector3.new(-74, 0, 58),
        Vector3.new(84, 0, -52), Vector3.new(88, 0, -14), Vector3.new(78, 0, 25), Vector3.new(86, 0, 60),
    }
    for i, p in ipairs(spots) do
        local base = c + p
        makePart(visuals, "IceCrystal_" .. i, Vector3.new(6, 18, 6), base + Vector3.new(0, 9, 0), Color3.fromRGB(83, 205, 235), Enum.Material.Ice, true, 0.08)
        local glow = glowPart(visuals, "IceCrystalGlow_" .. i, Vector3.new(3, 22, 3), base + Vector3.new(0, 11, 0), Color3.fromRGB(148, 240, 255), 0.25)
        addLight(glow, Color3.fromRGB(111, 225, 255), 12, 0.45)
    end
    for i, p in ipairs({ Vector3.new(-54, 0, -66), Vector3.new(-44, 0, 62), Vector3.new(54, 0, -66), Vector3.new(64, 0, 56) }) do
        makePart(visuals, "FrozenRock_" .. i, Vector3.new(12, 5, 10), c + p + Vector3.new(0, 2.5, 0), Color3.fromRGB(139, 175, 192), Enum.Material.Glacier)
    end
end

for key, def in pairs(zoneDefs) do
    def.key = key
    local zone = world:FindFirstChild(key)
    if zone then
        removeOldDecor(zone)
        styleAnchor(zone, def)

        local oldVisuals = zone:FindFirstChild("VisualRebuild001")
        if oldVisuals then
            oldVisuals:Destroy()
        end

        local visuals = Instance.new("Folder")
        visuals.Name = "VisualRebuild001"
        visuals.Parent = zone

        addMachineDetails(visuals, def)
        if def.decor == "meadow" then
            addMeadowDecor(visuals, def)
        elseif def.decor == "desert" then
            addDesertDecor(visuals, def)
        else
            addFrozenDecor(visuals, def)
        end
    end
end

local spawn = world:FindFirstChild("FactorySpawn")
if spawn and spawn:IsA("SpawnLocation") then
    spawn.Position = Vector3.new(0, 2, 48)
    spawn.Size = Vector3.new(12, 1, 12)
    spawn.Color = COLORS.meadowAccent
    spawn.Material = Enum.Material.Neon
    spawn.Transparency = 0.12
end

print("[MonsterFactory] Visual Rebuild 001 world layer applied.")
