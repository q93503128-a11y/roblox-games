local Workspace = game:GetService("Workspace")

local CombatSectorExpansionService = {}
local ctx

local ROOT_NAME = "VaultfallCombatExpansions"
local WING_DEPTH = 58
local WING_WIDTH = 78
local ROOM_MARGIN = 57

local COMBAT_TYPES = {
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
    p.Material = material or Enum.Material.Metal
    p.Color = color or Color3.fromRGB(58, 63, 69)
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

local function addLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness or 0.85
    light.Range = range or 22
    light.Shadows = true
    light.Parent = host
end

local function directionFromFill(fill, origin)
    local delta = fill.Position - origin
    if math.abs(delta.X) > math.abs(delta.Z) then
        return Vector3.new(delta.X > 0 and 1 or -1, 0, 0)
    end
    return Vector3.new(0, 0, delta.Z > 0 and 1 or -1)
end

local function perpendicular(direction)
    return Vector3.new(-direction.Z, 0, direction.X)
end

local function wingCenter(origin, direction)
    local halfRoom = ctx.Config.RoomSize.X * 0.5
    return origin + direction * (halfRoom + WING_DEPTH * 0.5)
end

local function wingHalfExtents(direction)
    if math.abs(direction.X) > 0.5 then
        return Vector2.new(WING_DEPTH * 0.5, WING_WIDTH * 0.5)
    end
    return Vector2.new(WING_WIDTH * 0.5, WING_DEPTH * 0.5)
end

local function candidateIsClear(room, direction, rooms)
    local center = wingCenter(room.Origin, direction)
    local extents = wingHalfExtents(direction)

    for _, other in ipairs(rooms) do
        if other ~= room then
            local delta = other.Origin - center
            if math.abs(delta.X) < extents.X + ROOM_MARGIN and math.abs(delta.Z) < extents.Y + ROOM_MARGIN then
                return false
            end
        end
    end
    return true
end

local function clearanceScore(room, direction, rooms)
    local center = wingCenter(room.Origin, direction)
    local best = math.huge
    for _, other in ipairs(rooms) do
        if other ~= room then
            local delta = other.Origin - center
            local distance = Vector2.new(delta.X, delta.Z).Magnitude
            best = math.min(best, distance)
        end
    end
    return best
end

local function chooseWallFill(room, rooms)
    local candidates = {}
    for _, child in ipairs(room.Folder:GetChildren()) do
        if child:IsA("BasePart") and child.Name == "WallFill" then
            local direction = directionFromFill(child, room.Origin)
            if candidateIsClear(room, direction, rooms) then
                table.insert(candidates, {
                    Fill = child,
                    Direction = direction,
                    Score = clearanceScore(room, direction, rooms),
                })
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.Score > b.Score
    end)
    return candidates[1]
end

local function orientedSize(direction, along, height, across)
    if math.abs(direction.X) > 0.5 then
        return Vector3.new(along, height, across)
    end
    return Vector3.new(across, height, along)
end

local function createDoorFrame(parent, room, direction)
    local halfRoom = ctx.Config.RoomSize.X * 0.5
    local across = perpendicular(direction)
    local center = room.Origin + direction * halfRoom
    local accent = room.Type == "Elite" and Color3.fromRGB(180, 72, 82) or Color3.fromRGB(64, 146, 166)

    for _, side in ipairs({ -1, 1 }) do
        local postPos = center + across * (12.5 * side) + Vector3.new(0, 7.5, 0)
        part(parent, "WingDoorPost", orientedSize(direction, 3.2, 15, 3.2), CFrame.new(postPos), Enum.Material.Metal, Color3.fromRGB(72, 78, 84))
    end
    local headerPos = center + Vector3.new(0, 15, 0)
    part(parent, "WingDoorHeader", orientedSize(direction, 3.2, 3, 28), CFrame.new(headerPos), Enum.Material.Metal, Color3.fromRGB(72, 78, 84))
    neon(parent, "WingDoorSignal", orientedSize(direction, 3.5, 0.55, 20), CFrame.new(headerPos - Vector3.new(0, 2.2, 0)), accent, 0.08)
end

local function createPerimeter(parent, room, direction)
    local center = wingCenter(room.Origin, direction)
    local across = perpendicular(direction)
    local halfDepth = WING_DEPTH * 0.5
    local halfWidth = WING_WIDTH * 0.5
    local wallColor = Color3.fromRGB(45, 50, 55)

    part(parent, "WingFloor", orientedSize(direction, WING_DEPTH, 1, WING_WIDTH), CFrame.new(center), Enum.Material.DiamondPlate, Color3.fromRGB(50, 55, 60))
    part(parent, "WingFloorInset", orientedSize(direction, WING_DEPTH - 6, 0.22, WING_WIDTH - 6), CFrame.new(center + Vector3.new(0, 0.62, 0)), Enum.Material.Metal, Color3.fromRGB(61, 66, 71), 0.05)

    local farWall = center + direction * halfDepth + Vector3.new(0, 8, 0)
    part(parent, "WingFarWall", orientedSize(direction, 3, 16, WING_WIDTH), CFrame.new(farWall), Enum.Material.Concrete, wallColor)

    for _, side in ipairs({ -1, 1 }) do
        local sideCenter = center + across * (halfWidth * side) + Vector3.new(0, 8, 0)
        part(parent, "WingSideWall", orientedSize(direction, WING_DEPTH, 16, 3), CFrame.new(sideCenter), Enum.Material.Concrete, wallColor)
    end

    for along = -20, 20, 20 do
        local beamPos = center + direction * along + Vector3.new(0, 14.5, 0)
        part(parent, "WingRoofBeam", orientedSize(direction, 2, 2, WING_WIDTH - 4), CFrame.new(beamPos), Enum.Material.Metal, Color3.fromRGB(75, 80, 84), 0, false)
    end

    return center, across
end

local function createElevatedRoute(parent, room, direction, center, across)
    local accent = room.Type == "Elite" and Color3.fromRGB(181, 70, 82) or Color3.fromRGB(67, 146, 164)
    local deckCenter = center + direction * 12 + across * 18 + Vector3.new(0, 8.2, 0)
    local deck = part(parent, "WingUpperDeck", orientedSize(direction, 30, 1, 30), CFrame.new(deckCenter), Enum.Material.DiamondPlate, Color3.fromRGB(66, 71, 75))

    local railOffset = 15.3
    for _, side in ipairs({ -1, 1 }) do
        local railCenter = deckCenter + across * (railOffset * side) + Vector3.new(0, 2.1, 0)
        part(parent, "WingDeckRail", orientedSize(direction, 30, 0.35, 0.35), CFrame.new(railCenter), Enum.Material.Metal, Color3.fromRGB(103, 108, 111), 0, false)
    end

    local rampCenter = center - direction * 10 + across * 18 + Vector3.new(0, 4.1, 0)
    local ramp = part(parent, "WingAccessRamp", Vector3.new(14, 1.1, 34), CFrame.lookAt(rampCenter, rampCenter + direction) * CFrame.Angles(math.rad(-14), 0, 0), Enum.Material.DiamondPlate, Color3.fromRGB(70, 75, 79))
    ramp.CanCollide = true

    local lamp = neon(parent, "WingDeckBeacon", Vector3.new(9, 0.35, 2), deck.CFrame * CFrame.new(0, 1.2, 0), accent, 0.1)
    addLight(lamp, accent, 0.85, 20)

    return deckCenter
end

local function createCover(parent, room, direction, center, across)
    local coverColor = Color3.fromRGB(73, 78, 82)
    local heavyColor = Color3.fromRGB(57, 62, 66)

    for _, spec in ipairs({
        { -18, -24, 14, 5, 5 },
        { 3, -25, 10, 7, 6 },
        { -5, 4, 17, 5, 4 },
        { 19, -2, 12, 6, 5 },
    }) do
        local along = spec[1]
        local lateral = spec[2]
        local width = spec[3]
        local height = spec[4]
        local depth = spec[5]
        local pos = center + direction * along + across * lateral + Vector3.new(0, height * 0.5, 0)
        part(parent, "WingCover", orientedSize(direction, depth, height, width), CFrame.new(pos), Enum.Material.Metal, coverColor)
    end

    local landmarkBase = center + direction * 20 - across * 21
    for level = 0, 1 do
        local pos = landmarkBase + direction * (level * 3) + Vector3.new(0, 3 + level * 5.6, 0)
        part(parent, "WingCargoStack", orientedSize(direction, 9, 5.5, 12), CFrame.new(pos), Enum.Material.Metal, heavyColor)
    end
end

local function createMissionLandmark(parent, room, direction, center, across)
    local mission = ctx.Config.Missions and ctx.Config.Missions[room.Index]
    local missionType = mission and mission.Type or nil
    local far = center + direction * 20

    if missionType == "Uplink" then
        local mast = part(parent, "SignalAnnexMast", Vector3.new(4, 22, 4), CFrame.new(far + Vector3.new(0, 11, 0)), Enum.Material.Metal, Color3.fromRGB(60, 68, 72))
        for y = -7, 7, 7 do
            local band = neon(parent, "SignalAnnexBand", Vector3.new(5.2, 0.55, 5.2), mast.CFrame * CFrame.new(0, y, 0), Color3.fromRGB(65, 160, 184), 0.08)
            addLight(band, band.Color, 0.55, 13)
        end
    elseif missionType == "Holdout" then
        local bunker = part(parent, "HoldoutBunker", orientedSize(direction, 18, 8, 28), CFrame.new(far + Vector3.new(0, 4, 0)), Enum.Material.Concrete, Color3.fromRGB(57, 63, 67))
        neon(parent, "HoldoutStatus", orientedSize(direction, 0.35, 2, 18), bunker.CFrame * CFrame.new(0, 2, 0), Color3.fromRGB(74, 151, 166), 0.12)
    elseif missionType == "Recovery" then
        for _, side in ipairs({ -1, 0, 1 }) do
            local pos = far + across * (side * 13) + Vector3.new(0, 3, 0)
            local vault = part(parent, "RecoveryVault", orientedSize(direction, 8, 6, 10), CFrame.new(pos), Enum.Material.Metal, Color3.fromRGB(65, 68, 73))
            neon(parent, "RecoveryVaultLatch", orientedSize(direction, 0.4, 1.2, 5), vault.CFrame * CFrame.new(0, 0, -4.2), Color3.fromRGB(190, 139, 68), 0.08)
        end
    elseif missionType == "Sabotage" then
        for _, side in ipairs({ -1, 1 }) do
            local pos = far + across * (side * 17) + Vector3.new(0, 7, 0)
            local tank = part(parent, "CoolantAnnex", Vector3.new(9, 14, 9), CFrame.new(pos), Enum.Material.Glass, Color3.fromRGB(59, 102, 110), 0.22)
            local core = neon(parent, "CoolantAnnexCore", Vector3.new(4, 10, 4), tank.CFrame, Color3.fromRGB(78, 171, 181), 0.1)
            addLight(core, core.Color, 0.65, 15)
        end
    elseif room.Type == "Elite" then
        local threat = neon(parent, "EliteKillhouseBeacon", Vector3.new(12, 0.6, 12), CFrame.new(far + Vector3.new(0, 0.9, 0)), Color3.fromRGB(180, 70, 82), 0.34)
        threat.Shape = Enum.PartType.Cylinder
        addLight(threat, threat.Color, 1.0, 22)
    else
        local reactor = part(parent, "MaintenanceReactor", Vector3.new(12, 18, 12), CFrame.new(far + Vector3.new(0, 9, 0)), Enum.Material.Metal, Color3.fromRGB(54, 61, 65))
        local core = neon(parent, "MaintenanceCore", Vector3.new(6, 12, 6), reactor.CFrame, Color3.fromRGB(66, 148, 164), 0.14)
        addLight(core, core.Color, 0.8, 18)
    end
end

local function extendSpawnPoints(room, direction)
    local halfRoom = ctx.Config.RoomSize.X * 0.5
    local across = perpendicular(direction)
    local offsets = {
        direction * (halfRoom + 18) + across * 25 + Vector3.new(0, 2.5, 0),
        direction * (halfRoom + 18) - across * 25 + Vector3.new(0, 2.5, 0),
        direction * (halfRoom + 43) + across * 20 + Vector3.new(0, 2.5, 0),
        direction * (halfRoom + 43) - across * 20 + Vector3.new(0, 2.5, 0),
    }
    for _, offset in ipairs(offsets) do
        table.insert(room.SpawnPoints, offset)
    end
end

local function buildWing(parent, room, rooms)
    local choice = chooseWallFill(room, rooms)
    if not choice then
        return false
    end

    choice.Fill:Destroy()
    local direction = choice.Direction
    local wingFolder = Instance.new("Folder")
    wingFolder.Name = string.format("Zone_%02d_TacticalWing", room.Index)
    wingFolder.Parent = parent

    createDoorFrame(wingFolder, room, direction)
    local center, across = createPerimeter(wingFolder, room, direction)
    createElevatedRoute(wingFolder, room, direction, center, across)
    createCover(wingFolder, room, direction, center, across)
    createMissionLandmark(wingFolder, room, direction, center, across)
    extendSpawnPoints(room, direction)

    wingFolder:SetAttribute("RoomIndex", room.Index)
    wingFolder:SetAttribute("RoomType", room.Type)
    wingFolder:SetAttribute("PlayableExpansion", true)
    wingFolder:SetAttribute("HasElevation", true)
    wingFolder:SetAttribute("AddedSpawnPoints", 4)
    return true
end

function CombatSectorExpansionService.Init(context)
    ctx = context
end

function CombatSectorExpansionService.Build()
    local previous = Workspace:FindFirstChild(ROOT_NAME)
    if previous then
        previous:Destroy()
    end

    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = Workspace

    local rooms = ctx.World.GetRooms()
    local expanded = 0
    for _, room in ipairs(rooms) do
        if COMBAT_TYPES[room.Type] and buildWing(root, room, rooms) then
            expanded += 1
        end
    end

    root:SetAttribute("SelfContained", true)
    root:SetAttribute("ExpandedCombatRooms", expanded)
    root:SetAttribute("WingDepth", WING_DEPTH)
    root:SetAttribute("WingWidth", WING_WIDTH)
    root:SetAttribute("AddsEnemySpawnDistribution", true)
    root:SetAttribute("BuildVersion", 1)
end

return CombatSectorExpansionService