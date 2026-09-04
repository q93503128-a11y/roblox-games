local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local SectorPolishService = {}
local ctx

local ROOT_NAME = "VaultfallSectorPolish"

local function part(parent, name, size, cframe, material, color, transparency, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Material = material or Enum.Material.Metal
    p.Color = color or Color3.fromRGB(55, 61, 67)
    p.Transparency = transparency or 0
    p.CanCollide = collide ~= false
    p.CanTouch = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function neon(parent, name, size, cframe, color, transparency)
    return part(parent, name, size, cframe, Enum.Material.Neon, color, transparency or 0.08, false)
end

local function pointLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness or 1.2
    light.Range = range or 24
    light.Shadows = true
    light.Parent = host
    return light
end

local function beam(parent, origin, offset, size, rotation)
    return part(
        parent,
        "StructuralBeam",
        size,
        CFrame.new(origin + offset) * CFrame.Angles(0, math.rad(rotation or 0), 0),
        Enum.Material.Metal,
        Color3.fromRGB(57, 62, 67)
    )
end

local function crate(parent, position, scale, rotation)
    local s = scale or 1
    local cf = CFrame.new(position + Vector3.new(0, 2.8 * s, 0)) * CFrame.Angles(0, math.rad(rotation or 0), 0)
    local body = part(parent, "SectorCargo", Vector3.new(8, 5.6, 8) * s, cf, Enum.Material.Metal, Color3.fromRGB(65, 70, 74))
    for _, z in ipairs({ -3.9, 3.9 }) do
        part(parent, "SectorCargoBrace", Vector3.new(7.1, 0.45, 0.45) * s, cf * CFrame.new(0, 1.7 * s, z * s), Enum.Material.DiamondPlate, Color3.fromRGB(101, 105, 108), 0, false)
        part(parent, "SectorCargoBrace", Vector3.new(7.1, 0.45, 0.45) * s, cf * CFrame.new(0, -1.7 * s, z * s), Enum.Material.DiamondPlate, Color3.fromRGB(101, 105, 108), 0, false)
    end
    return body
end

local function addRoomCeiling(parent, origin, roomIndex)
    local accent = roomIndex % 3 == 0 and Color3.fromRGB(199, 101, 60) or Color3.fromRGB(69, 143, 163)

    for x = -42, 42, 28 do
        beam(parent, origin, Vector3.new(x, 18.4, 0), Vector3.new(2.4, 2.4, 98), 0)
    end
    for z = -42, 42, 28 do
        beam(parent, origin, Vector3.new(0, 18.7, z), Vector3.new(98, 1.6, 1.6), 0)
    end

    for _, z in ipairs({ -30, 0, 30 }) do
        local lamp = neon(parent, "SectorCeilingLamp", Vector3.new(21, 0.35, 1), CFrame.new(origin + Vector3.new(0, 17.7, z)), accent, 0.12)
        pointLight(lamp, accent, 1.05, 26)
    end
end

local function addPerimeterDetail(parent, origin, roomIndex)
    local dark = Color3.fromRGB(38, 43, 47)
    local mid = Color3.fromRGB(67, 72, 77)

    for _, x in ipairs({ -47, 47 }) do
        for _, z in ipairs({ -35, 0, 35 }) do
            part(parent, "WallButtress", Vector3.new(4, 13, 11), CFrame.new(origin + Vector3.new(x, 6.5, z)), Enum.Material.Concrete, dark)
            part(parent, "WallInset", Vector3.new(0.4, 7, 7), CFrame.new(origin + Vector3.new(x + (x < 0 and 2.2 or -2.2), 7.5, z)), Enum.Material.Metal, mid, 0, false)
        end
    end

    for _, z in ipairs({ -47, 47 }) do
        for _, x in ipairs({ -35, 0, 35 }) do
            part(parent, "WallButtress", Vector3.new(11, 13, 4), CFrame.new(origin + Vector3.new(x, 6.5, z)), Enum.Material.Concrete, dark)
            part(parent, "WallInset", Vector3.new(7, 7, 0.4), CFrame.new(origin + Vector3.new(x, 7.5, z + (z < 0 and 2.2 or -2.2))), Enum.Material.Metal, mid, 0, false)
        end
    end

    local stripeColor = roomIndex % 2 == 0 and Color3.fromRGB(181, 93, 58) or Color3.fromRGB(62, 133, 151)
    for _, x in ipairs({ -46.7, 46.7 }) do
        neon(parent, "WallRouteStripe", Vector3.new(0.3, 1.2, 24), CFrame.new(origin + Vector3.new(x, 2.3, 0)), stripeColor, 0.18)
    end
end

local function addCombatCatwalk(parent, origin, mirror)
    local side = mirror and -1 or 1
    local deckColor = Color3.fromRGB(61, 66, 70)
    local railColor = Color3.fromRGB(96, 101, 104)

    part(parent, "CombatCatwalk", Vector3.new(16, 1.1, 56), CFrame.new(origin + Vector3.new(34 * side, 8.8, 0)), Enum.Material.DiamondPlate, deckColor)
    for _, xOffset in ipairs({ -8.2, 8.2 }) do
        local worldX = 34 * side + xOffset
        for z = -25, 25, 10 do
            part(parent, "CatwalkPost", Vector3.new(0.35, 3.1, 0.35), CFrame.new(origin + Vector3.new(worldX, 10.6, z)), Enum.Material.Metal, railColor, 0, false)
        end
        part(parent, "CatwalkRail", Vector3.new(0.35, 0.35, 54), CFrame.new(origin + Vector3.new(worldX, 12.1, 0)), Enum.Material.Metal, railColor, 0, false)
    end

    local ramp = part(
        parent,
        "CatwalkRamp",
        Vector3.new(13, 1.1, 38),
        CFrame.new(origin + Vector3.new(34 * side, 4.4, 37)) * CFrame.Angles(math.rad(13), 0, 0),
        Enum.Material.DiamondPlate,
        deckColor
    )
    ramp.CanCollide = true
end

local function addUtilityBay(parent, origin, roomIndex)
    local side = roomIndex % 2 == 0 and -1 or 1
    local bay = part(parent, "UtilityBay", Vector3.new(30, 5, 18), CFrame.new(origin + Vector3.new(27 * side, 2.5, -27)), Enum.Material.Metal, Color3.fromRGB(51, 56, 60))
    for x = -10, 10, 10 do
        local cell = part(parent, "UtilityCell", Vector3.new(5, 9, 5), bay.CFrame * CFrame.new(x, 5.5, 0), Enum.Material.Glass, Color3.fromRGB(48, 79, 84), 0.24, true)
        local core = neon(parent, "UtilityCore", Vector3.new(2.1, 6.5, 2.1), cell.CFrame, Color3.fromRGB(72, 163, 173), 0.06)
        pointLight(core, core.Color, 0.7, 12)
    end
end

local function addTreasureIdentity(parent, origin)
    local platform = part(parent, "RewardDais", Vector3.new(36, 2.2, 28), CFrame.new(origin + Vector3.new(0, 1.2, 2)), Enum.Material.DiamondPlate, Color3.fromRGB(65, 59, 51))
    for _, offset in ipairs({ Vector3.new(-17, 5, -13), Vector3.new(17, 5, -13), Vector3.new(-17, 5, 13), Vector3.new(17, 5, 13) }) do
        part(parent, "RewardPylon", Vector3.new(2.5, 10, 2.5), CFrame.new(origin + offset), Enum.Material.Metal, Color3.fromRGB(91, 78, 59))
    end
    local glow = neon(parent, "RewardBeacon", Vector3.new(18, 0.35, 18), platform.CFrame * CFrame.new(0, 1.35, 0), Color3.fromRGB(203, 145, 67), 0.45)
    glow.Shape = Enum.PartType.Cylinder
    pointLight(glow, Color3.fromRGB(229, 170, 86), 1.2, 22)
    crate(parent, origin + Vector3.new(-32, 0, 27), 0.85, 15)
    crate(parent, origin + Vector3.new(33, 0, -24), 0.7, -20)
end

local function addShrineIdentity(parent, origin)
    local base = part(parent, "ShrineBase", Vector3.new(30, 2.4, 30), CFrame.new(origin + Vector3.new(0, 1.3, 0)), Enum.Material.Slate, Color3.fromRGB(55, 50, 63))
    for _, offset in ipairs({ Vector3.new(-12, 8, -12), Vector3.new(12, 8, -12), Vector3.new(-12, 8, 12), Vector3.new(12, 8, 12) }) do
        part(parent, "ShrinePillar", Vector3.new(3, 16, 3), CFrame.new(origin + offset), Enum.Material.Slate, Color3.fromRGB(71, 61, 82))
    end
    local sigil = neon(parent, "ShrineSigil", Vector3.new(16, 0.28, 16), base.CFrame * CFrame.new(0, 1.45, 0), Color3.fromRGB(138, 91, 174), 0.34)
    sigil.Shape = Enum.PartType.Cylinder
    pointLight(sigil, Color3.fromRGB(150, 105, 184), 1.1, 23)
end

local function addEliteIdentity(parent, origin)
    local accent = Color3.fromRGB(161, 73, 78)
    for _, offset in ipairs({ Vector3.new(-29, 6, -29), Vector3.new(29, 6, -29), Vector3.new(-29, 6, 29), Vector3.new(29, 6, 29) }) do
        local tower = part(parent, "ThreatPylon", Vector3.new(5, 12, 5), CFrame.new(origin + offset), Enum.Material.Metal, Color3.fromRGB(60, 51, 53))
        local beacon = neon(parent, "ThreatBeacon", Vector3.new(5.5, 0.8, 5.5), tower.CFrame * CFrame.new(0, 4.8, 0), accent, 0.09)
        pointLight(beacon, accent, 0.9, 17)
    end
end

local function addMissionIdentity(parent, origin, missionType)
    if missionType == "Uplink" then
        for _, offset in ipairs({ Vector3.new(-28, 0, -18), Vector3.new(24, 0, 22), Vector3.new(7, 0, -31) }) do
            local tower = part(parent, "UplinkMast", Vector3.new(3, 13, 3), CFrame.new(origin + offset + Vector3.new(0, 6.5, 0)), Enum.Material.Metal, Color3.fromRGB(55, 65, 69))
            neon(parent, "UplinkBand", Vector3.new(3.5, 0.6, 3.5), tower.CFrame * CFrame.new(0, 3.8, 0), Color3.fromRGB(61, 156, 181), 0.08)
        end
    elseif missionType == "Holdout" then
        part(parent, "DefensePad", Vector3.new(42, 1.4, 42), CFrame.new(origin + Vector3.new(0, 0.9, 0)), Enum.Material.DiamondPlate, Color3.fromRGB(56, 62, 66))
        for _, angle in ipairs({ 0, 90, 180, 270 }) do
            local rad = math.rad(angle)
            local pos = origin + Vector3.new(math.cos(rad) * 25, 3, math.sin(rad) * 25)
            part(parent, "DefenseBarricade", Vector3.new(18, 6, 4), CFrame.lookAt(pos, origin), Enum.Material.Metal, Color3.fromRGB(78, 83, 87))
        end
    elseif missionType == "Recovery" then
        crate(parent, origin + Vector3.new(-33, 0, -30), 0.9, 12)
        crate(parent, origin + Vector3.new(31, 0, 27), 0.85, -18)
        crate(parent, origin + Vector3.new(-29, 0, 29), 0.7, 25)
        neon(parent, "RecoveryGuide", Vector3.new(32, 0.16, 2), CFrame.new(origin + Vector3.new(0, 0.78, 0)), Color3.fromRGB(70, 139, 162), 0.42)
    elseif missionType == "Sabotage" then
        for _, x in ipairs({ -26, 26 }) do
            local coolant = part(parent, "CoolantTower", Vector3.new(10, 17, 10), CFrame.new(origin + Vector3.new(x, 8.5, 0)), Enum.Material.Metal, Color3.fromRGB(55, 62, 64))
            local glass = part(parent, "CoolantGlass", Vector3.new(7.5, 11, 7.5), coolant.CFrame, Enum.Material.Glass, Color3.fromRGB(66, 120, 131), 0.34, false)
            pointLight(glass, Color3.fromRGB(79, 165, 176), 0.65, 14)
        end
    end
end

local function addBossArena(parent, origin)
    local accent = Color3.fromRGB(171, 62, 66)
    local inner = part(parent, "BossArenaInset", Vector3.new(72, 0.7, 72), CFrame.new(origin + Vector3.new(0, 0.95, 0)), Enum.Material.Basalt, Color3.fromRGB(38, 39, 42))
    local ring = neon(parent, "BossArenaRing", Vector3.new(62, 0.3, 62), inner.CFrame * CFrame.new(0, 0.5, 0), accent, 0.66)
    ring.Shape = Enum.PartType.Cylinder

    for _, offset in ipairs({ Vector3.new(-39, 0, -39), Vector3.new(39, 0, -39), Vector3.new(-39, 0, 39), Vector3.new(39, 0, 39) }) do
        local pillar = part(parent, "BossReactorPillar", Vector3.new(7, 16, 7), CFrame.new(origin + offset + Vector3.new(0, 8, 0)), Enum.Material.Metal, Color3.fromRGB(62, 49, 51))
        local lamp = neon(parent, "BossWarning", Vector3.new(7.5, 0.8, 7.5), pillar.CFrame * CFrame.new(0, 5.9, 0), accent, 0.08)
        pointLight(lamp, accent, 1.1, 20)
    end
end

local function addRoomIdentity(parent, room, index)
    local origin = room.Origin
    local roomType = room.Type

    addRoomCeiling(parent, origin, index)
    addPerimeterDetail(parent, origin, index)

    if roomType == "Combat" or roomType == "DeepCombat" then
        addCombatCatwalk(parent, origin, index % 2 == 0)
        addUtilityBay(parent, origin, index)
    elseif roomType == "Treasure" then
        addTreasureIdentity(parent, origin)
    elseif roomType == "Shrine" then
        addShrineIdentity(parent, origin)
    elseif roomType == "Elite" then
        addEliteIdentity(parent, origin)
        addCombatCatwalk(parent, origin, index % 2 == 0)
    elseif roomType == "Boss" then
        addBossArena(parent, origin)
    end

    local mission = ctx.Config.Missions and ctx.Config.Missions[index]
    if mission then
        addMissionIdentity(parent, origin, mission.Type)
    end

    for _, offset in ipairs({ Vector3.new(-43, 0, -39), Vector3.new(43, 0, 39) }) do
        crate(parent, origin + offset, 0.7 + ((index % 3) * 0.08), index * 13)
    end
end

local function addCorridorLighting(parent, rooms)
    for index = 2, #rooms do
        local previous = rooms[index - 1]
        local room = rooms[index]
        if previous and room then
            local delta = room.Origin - previous.Origin
            local midpoint = (room.Origin + previous.Origin) / 2
            local length = math.max(math.abs(delta.X), math.abs(delta.Z)) - ctx.Config.RoomSize.X
            if length > 0 then
                if math.abs(delta.X) > math.abs(delta.Z) then
                    local lamp = neon(parent, "TransitLight", Vector3.new(length - 8, 0.3, 1), CFrame.new(midpoint + Vector3.new(0, 6.4, 0)), Color3.fromRGB(64, 135, 153), 0.22)
                    pointLight(lamp, lamp.Color, 0.7, 20)
                else
                    local lamp = neon(parent, "TransitLight", Vector3.new(1, 0.3, length - 8), CFrame.new(midpoint + Vector3.new(0, 6.4, 0)), Color3.fromRGB(64, 135, 153), 0.22)
                    pointLight(lamp, lamp.Color, 0.7, 20)
                end
            end
        end
    end
end

function SectorPolishService.Init(context)
    ctx = context
end

function SectorPolishService.Build()
    local old = Workspace:FindFirstChild(ROOT_NAME)
    if old then
        old:Destroy()
    end

    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = Workspace

    local rooms = ctx.World.GetRooms()
    for index, room in ipairs(rooms) do
        addRoomIdentity(root, room, index)
    end
    addCorridorLighting(root, rooms)

    root:SetAttribute("SectorArchitecture", true)
    root:SetAttribute("SelfContained", true)
    root:SetAttribute("RoomCount", #rooms)
    root:SetAttribute("BuildVersion", 1)

    local correction = Lighting:FindFirstChild("VaultfallColor")
    if correction and correction:IsA("ColorCorrectionEffect") then
        correction.Contrast = math.max(correction.Contrast, 0.1)
    end
end

return SectorPolishService
