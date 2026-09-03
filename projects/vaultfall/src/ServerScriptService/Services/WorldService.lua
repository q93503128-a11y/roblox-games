local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local WorldService = {}
local ctx
local worldFolder
local rooms = {}

local SAFEHOUSE_ORIGIN = Vector3.new(-220, 0, -120)
local DUNGEON_OFFSET = Vector3.new(100, 0, 0)
local WALL_HEIGHT = 20
local DOOR_WIDTH = 18
local WALL_THICKNESS = 3
local hubSpawnCFrame = CFrame.new(SAFEHOUSE_ORIGIN + Vector3.new(0, 5, 52))

local SIDES = {
    N = Vector3.new(0, 0, -1),
    S = Vector3.new(0, 0, 1),
    E = Vector3.new(1, 0, 0),
    W = Vector3.new(-1, 0, 0),
}

local function createPart(name, size, cframe, material, color, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.Material = material or Enum.Material.Metal
    part.Color = color or Color3.fromRGB(56, 60, 67)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function addBillboard(part, text, textSize, color)
    local gui = Instance.new("BillboardGui")
    gui.Name = "WorldLabel"
    gui.Size = UDim2.fromOffset(260, 54)
    gui.StudsOffset = Vector3.new(0, part.Size.Y * 0.5 + 2.6, 0)
    gui.AlwaysOnTop = false
    gui.MaxDistance = 58
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextSize = textSize or 18
    label.TextColor3 = color or Color3.fromRGB(225, 231, 239)
    label.TextStrokeTransparency = 0.55
    label.Parent = gui
    return label
end

local function addPanelText(part, text, face)
    local gui = Instance.new("SurfaceGui")
    gui.Face = face or Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.PixelsPerStud = 32
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(205, 224, 235)
    label.Parent = gui
end

local function addPrompt(part, actionText, objectText, callback, holdDuration)
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.HoldDuration = holdDuration or 0.25
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = part
    prompt.Triggered:Connect(callback)
    return prompt
end

local function sanitizeClone(clone)
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            descendant:Destroy()
        elseif descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanTouch = false
        end
    end
end

local function cloneDecorCandidate(packName, keywords, targetCFrame, maxDimension, parent, collide)
    local assetRoot = ServerStorage:FindFirstChild("VaultfallAssets")
    local pack = assetRoot and assetRoot:FindFirstChild(packName)
    if not pack then
        return nil
    end

    local candidates = {}
    for _, child in ipairs(pack:GetDescendants()) do
        if child:IsA("Model") or child:IsA("MeshPart") or child:IsA("UnionOperation") then
            local lower = string.lower(child.Name)
            for _, keyword in ipairs(keywords) do
                if string.find(lower, keyword, 1, true) then
                    table.insert(candidates, child)
                    break
                end
            end
        end
    end
    if #candidates == 0 then
        return nil
    end

    local source = candidates[math.random(1, #candidates)]
    local clone = source:Clone()
    sanitizeClone(clone)

    if clone:IsA("BasePart") then
        clone.CFrame = targetCFrame
        clone.CanCollide = collide == true
    elseif clone:IsA("Model") then
        local ok, _, size = pcall(function()
            return clone:GetBoundingBox()
        end)
        if ok and size then
            local largest = math.max(size.X, size.Y, size.Z)
            if largest > maxDimension and largest > 0.1 then
                pcall(function()
                    clone:ScaleTo(maxDimension / largest)
                end)
            end
        end
        pcall(function()
            clone:PivotTo(targetCFrame)
        end)
        for _, descendant in ipairs(clone:GetDescendants()) do
            if descendant:IsA("BasePart") then
                descendant.CanCollide = collide == true
            end
        end
    end

    clone.Parent = parent
    return clone
end

local function directionKey(delta)
    if delta.X > 0.5 then
        return "E"
    elseif delta.X < -0.5 then
        return "W"
    elseif delta.Z > 0.5 then
        return "S"
    end
    return "N"
end

local function buildDesk(folder, position, width, screenText)
    local desk = createPart("Desk", Vector3.new(width or 14, 3, 4), CFrame.new(position + Vector3.new(0, 1.5, 0)), Enum.Material.Metal, Color3.fromRGB(49, 53, 58), folder)
    local screen = createPart("Terminal", Vector3.new(math.min(width or 14, 9), 5, 0.7), CFrame.new(position + Vector3.new(0, 5, -1.4)) * CFrame.Angles(math.rad(-8), 0, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(21, 31, 35), folder)
    local glow = createPart("TerminalGlow", Vector3.new(math.min(width or 14, 8.2), 4.2, 0.12), screen.CFrame * CFrame.new(0, 0, -0.41), Enum.Material.Neon, Color3.fromRGB(62, 139, 157), folder)
    glow.CanCollide = false
    if screenText then
        addPanelText(glow, screenText, Enum.NormalId.Front)
    end
    return desk, screen
end

local function buildWallSection(folder, center, size)
    return createPart("SafehouseWall", size, CFrame.new(center), Enum.Material.Concrete, Color3.fromRGB(49, 53, 58), folder)
end

local function buildSafehouseShell(folder)
    local origin = SAFEHOUSE_ORIGIN
    createPart("SafehouseFloor", Vector3.new(264, 1, 224), CFrame.new(origin), Enum.Material.Concrete, Color3.fromRGB(48, 50, 54), folder)
    createPart("InsetFloor", Vector3.new(246, 0.35, 206), CFrame.new(origin + Vector3.new(0, 0.68, 0)), Enum.Material.Metal, Color3.fromRGB(37, 41, 45), folder)

    buildWallSection(folder, origin + Vector3.new(0, 10, -112), Vector3.new(264, 20, 3))
    buildWallSection(folder, origin + Vector3.new(-132, 10, 0), Vector3.new(3, 20, 224))
    buildWallSection(folder, origin + Vector3.new(132, 10, 0), Vector3.new(3, 20, 224))
    buildWallSection(folder, origin + Vector3.new(0, 10, 112), Vector3.new(264, 20, 3))

    -- Structural beams keep the space readable without turning it into a boxy maze.
    for x = -108, 108, 54 do
        createPart("CeilingBeam", Vector3.new(3, 3, 216), CFrame.new(origin + Vector3.new(x, 17.5, 0)), Enum.Material.Metal, Color3.fromRGB(70, 74, 80), folder)
    end
    for z = -88, 88, 44 do
        createPart("CrossBeam", Vector3.new(258, 2, 2), CFrame.new(origin + Vector3.new(0, 18, z)), Enum.Material.Metal, Color3.fromRGB(67, 71, 77), folder)
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "HubSpawn"
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.CFrame = hubSpawnCFrame * CFrame.new(0, -4.5, 0)
    spawn.Transparency = 1
    spawn.CanCollide = false
    spawn.Neutral = true
    spawn.Parent = folder
end

local function buildArmory(folder)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(-82, 0, -54)
    buildWallSection(folder, origin + Vector3.new(0, 7, -38), Vector3.new(76, 14, 2))
    buildWallSection(folder, origin + Vector3.new(-38, 7, 0), Vector3.new(2, 14, 76))
    createPart("ArmoryHeader", Vector3.new(32, 3, 2), CFrame.new(origin + Vector3.new(0, 12, -36.8)), Enum.Material.Neon, Color3.fromRGB(49, 99, 115), folder)
    addBillboard(createPart("ArmoryMarker", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 9, -31)), Enum.Material.SmoothPlastic, Color3.new(0, 0, 0), folder), "ARMORY", 20)

    for row = 0, 2 do
        local z = -23 + row * 18
        local rack = createPart("WeaponRack", Vector3.new(3, 9, 15), CFrame.new(origin + Vector3.new(-31, 4.5, z)), Enum.Material.Metal, Color3.fromRGB(69, 74, 80), folder)
        for slot = -1, 1 do
            local dummy = createPart("WeaponDisplay", Vector3.new(0.8, 1.2, 8), rack.CFrame * CFrame.new(-2, slot * 2.7, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.Material.Metal, Color3.fromRGB(93, 103, 111), folder)
            dummy.CanCollide = false
        end
    end

    local _, terminal = buildDesk(folder, origin + Vector3.new(14, 0, 19), 18, "LOADOUT")
    addPrompt(terminal, "Inspect loadout", "Armory console", function(player)
        ctx.Remotes.State:FireClient(player, "Notice", "Armory loadout system online — weapon slots are being expanded during this build")
    end)

    cloneDecorCandidate("WeaponPack", { "rifle", "gun", "weapon", "blade" }, CFrame.new(origin + Vector3.new(8, 5, -10)), 12, folder, false)
end

local function buildOperations(folder)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(72, 0, -55)
    buildWallSection(folder, origin + Vector3.new(0, 7, -38), Vector3.new(88, 14, 2))
    buildWallSection(folder, origin + Vector3.new(44, 7, 0), Vector3.new(2, 14, 76))

    addBillboard(createPart("OpsMarker", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 9, -31)), Enum.Material.SmoothPlastic, Color3.new(0, 0, 0), folder), "OPERATIONS", 20)

    local board = createPart("ContractBoard", Vector3.new(30, 15, 1.2), CFrame.new(origin + Vector3.new(0, 8, -34)), Enum.Material.Metal, Color3.fromRGB(23, 31, 36), folder)
    addPanelText(board, "BREACH CONTRACTS\n\nSECTOR 07  •  ACTIVE\nTHREAT: ESCALATING\nTEAM: 1–4 OPERATORS", Enum.NormalId.Front)
    addPrompt(board, "Review contract", "Operations board", function(player)
        ctx.Remotes.State:FireClient(player, "Notice", "Contract selected: Sector 07 breach / escalating threat")
    end)

    local tableTop = createPart("TacticalTable", Vector3.new(24, 2, 16), CFrame.new(origin + Vector3.new(0, 3, 7)), Enum.Material.Metal, Color3.fromRGB(57, 62, 68), folder)
    local holo = createPart("Hologram", Vector3.new(18, 0.25, 11), tableTop.CFrame * CFrame.new(0, 1.35, 0), Enum.Material.Neon, Color3.fromRGB(50, 128, 148), folder)
    holo.Transparency = 0.25
    holo.CanCollide = false

    for i = -2, 2 do
        local line = createPart("HoloLine", Vector3.new(0.18, 3 + math.abs(i), 0.18), CFrame.new(origin + Vector3.new(i * 3, 5, 7 + ((i % 2) * 2))), Enum.Material.Neon, Color3.fromRGB(84, 163, 178), folder)
        line.CanCollide = false
    end
end

local function buildUpgradeLab(folder)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(-78, 0, 53)
    buildWallSection(folder, origin + Vector3.new(-42, 7, 0), Vector3.new(2, 14, 82))
    addBillboard(createPart("LabMarker", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 9, -33)), Enum.Material.SmoothPlastic, Color3.new(0, 0, 0), folder), "SYSTEMS LAB", 20)

    local _, attackTerminal = buildDesk(folder, origin + Vector3.new(-8, 0, -12), 18, "WEAPON CALIBRATION")
    addPrompt(attackTerminal, "Calibrate weapons", "Systems terminal", function(player)
        local _, message = ctx.Profile.BuyUpgrade(player, "Attack")
        ctx.Remotes.State:FireClient(player, "Notice", message)
    end)

    local _, healthTerminal = buildDesk(folder, origin + Vector3.new(20, 0, -12), 18, "SUIT REINFORCEMENT")
    addPrompt(healthTerminal, "Reinforce suit", "Systems terminal", function(player)
        local _, message = ctx.Profile.BuyUpgrade(player, "Health")
        ctx.Remotes.State:FireClient(player, "Notice", message)
    end)

    for i = 0, 3 do
        local tank = createPart("PowerCell", Vector3.new(5, 10, 5), CFrame.new(origin + Vector3.new(-25 + i * 16, 5, 20)), Enum.Material.Glass, Color3.fromRGB(47, 77, 82), folder)
        tank.Transparency = 0.28
        local core = createPart("CellCore", Vector3.new(2.3, 7, 2.3), tank.CFrame, Enum.Material.Neon, Color3.fromRGB(65, 154, 163), folder)
        core.CanCollide = false
    end
end

local function buildFiringRange(folder)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(78, 0, 48)
    addBillboard(createPart("RangeMarker", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 9, -37)), Enum.Material.SmoothPlastic, Color3.new(0, 0, 0), folder), "FIRING RANGE", 20)

    buildWallSection(folder, origin + Vector3.new(-43, 6, 6), Vector3.new(2, 12, 84))
    buildWallSection(folder, origin + Vector3.new(43, 6, 6), Vector3.new(2, 12, 84))
    buildWallSection(folder, origin + Vector3.new(0, 6, 48), Vector3.new(88, 12, 2))

    for lane = -1, 1 do
        local x = lane * 24
        createPart("LaneDivider", Vector3.new(1, 5, 56), CFrame.new(origin + Vector3.new(x - 11, 2.5, 7)), Enum.Material.Metal, Color3.fromRGB(66, 70, 75), folder)
        local targetPole = createPart("TargetPole", Vector3.new(1, 8, 1), CFrame.new(origin + Vector3.new(x, 4, 36)), Enum.Material.Metal, Color3.fromRGB(72, 75, 80), folder)
        local target = createPart("Target", Vector3.new(7, 9, 1), targetPole.CFrame * CFrame.new(0, 4, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(115, 75, 73), folder)
        addPanelText(target, "●", Enum.NormalId.Front)
    end

    for i = -1, 1 do
        createPart("RangeCounter", Vector3.new(18, 3, 5), CFrame.new(origin + Vector3.new(i * 24, 1.5, -25)), Enum.Material.Metal, Color3.fromRGB(54, 58, 63), folder)
    end
end

local function buildDeploymentBay(folder)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(0, 0, 76)
    addBillboard(createPart("DeployMarker", Vector3.new(1, 1, 1), CFrame.new(origin + Vector3.new(0, 10, -23)), Enum.Material.SmoothPlastic, Color3.new(0, 0, 0), folder), "DEPLOYMENT", 21)

    local platform = createPart("DeploymentLift", Vector3.new(34, 2, 28), CFrame.new(origin + Vector3.new(0, 1, 7)), Enum.Material.DiamondPlate, Color3.fromRGB(63, 67, 72), folder)
    for _, x in ipairs({ -18, 18 }) do
        createPart("LiftRail", Vector3.new(2, 8, 32), CFrame.new(origin + Vector3.new(x, 4, 7)), Enum.Material.Metal, Color3.fromRGB(80, 84, 90), folder)
    end
    local archTop = createPart("GateHeader", Vector3.new(40, 4, 4), CFrame.new(origin + Vector3.new(0, 16, 18)), Enum.Material.Metal, Color3.fromRGB(56, 61, 67), folder)
    createPart("GatePost", Vector3.new(4, 18, 4), CFrame.new(origin + Vector3.new(-18, 8, 18)), Enum.Material.Metal, Color3.fromRGB(56, 61, 67), folder)
    createPart("GatePost", Vector3.new(4, 18, 4), CFrame.new(origin + Vector3.new(18, 8, 18)), Enum.Material.Metal, Color3.fromRGB(56, 61, 67), folder)
    local signal = createPart("DeploymentSignal", Vector3.new(28, 1, 1), archTop.CFrame * CFrame.new(0, -3, -2.2), Enum.Material.Neon, Color3.fromRGB(79, 149, 165), folder)
    signal.CanCollide = false

    addPrompt(platform, "Deploy to Sector 07", "Breach lift", function(player)
        if ctx.Run then
            ctx.Run.StartRun(player)
        end
    end, 0.55)
end

local function buildTrophyWall(folder)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(0, 0, -84)
    local wall = buildWallSection(folder, origin + Vector3.new(0, 7, 0), Vector3.new(78, 14, 2))
    addBillboard(wall, "OPERATOR RECORD", 18)
    for i = -3, 3 do
        local frame = createPart("TrophyFrame", Vector3.new(8, 8, 0.6), CFrame.new(origin + Vector3.new(i * 10, 7, -1.4)), Enum.Material.WoodPlanks, Color3.fromRGB(78, 64, 55), folder)
        local plate = createPart("TrophyPlate", Vector3.new(6.5, 6.5, 0.2), frame.CFrame * CFrame.new(0, 0, -0.42), Enum.Material.Metal, Color3.fromRGB(82, 88, 94), folder)
        plate.CanCollide = false
    end
end

local function decorateSafehouse(folder)
    local placements = {
        { "NaturePack", { "plant", "bush", "tree" }, SAFEHOUSE_ORIGIN + Vector3.new(-113, 1, 88), 14 },
        { "NaturePack", { "plant", "bush", "tree" }, SAFEHOUSE_ORIGIN + Vector3.new(113, 1, 88), 14 },
        { "DungeonKit", { "crate", "barrel" }, SAFEHOUSE_ORIGIN + Vector3.new(-112, 1, -88), 12 },
        { "DungeonKit", { "crate", "barrel" }, SAFEHOUSE_ORIGIN + Vector3.new(112, 1, -88), 12 },
    }
    for _, item in ipairs(placements) do
        cloneDecorCandidate(item[1], item[2], CFrame.new(item[3]), item[4], folder, true)
    end
end

local function buildHub()
    local folder = Instance.new("Folder")
    folder.Name = "Safehouse"
    folder.Parent = worldFolder

    buildSafehouseShell(folder)
    buildArmory(folder)
    buildOperations(folder)
    buildUpgradeLab(folder)
    buildFiringRange(folder)
    buildDeploymentBay(folder)
    buildTrophyWall(folder)
    decorateSafehouse(folder)
end

local function createWallWithGap(folder, origin, side, openCenter)
    local half = ctx.Config.RoomSize.X / 2
    local segmentLength = (ctx.Config.RoomSize.X - DOOR_WIDTH) / 2
    local y = WALL_HEIGHT / 2

    if side == "N" or side == "S" then
        local z = origin.Z + ((side == "N") and -half or half)
        createPart("Wall", Vector3.new(segmentLength, WALL_HEIGHT, WALL_THICKNESS), CFrame.new(origin.X - (DOOR_WIDTH / 2 + segmentLength / 2), y, z), Enum.Material.Concrete, Color3.fromRGB(48, 52, 58), folder)
        createPart("Wall", Vector3.new(segmentLength, WALL_HEIGHT, WALL_THICKNESS), CFrame.new(origin.X + (DOOR_WIDTH / 2 + segmentLength / 2), y, z), Enum.Material.Concrete, Color3.fromRGB(48, 52, 58), folder)
        if not openCenter then
            createPart("WallFill", Vector3.new(DOOR_WIDTH, WALL_HEIGHT, WALL_THICKNESS), CFrame.new(origin.X, y, z), Enum.Material.Concrete, Color3.fromRGB(48, 52, 58), folder)
        end
    else
        local x = origin.X + ((side == "W") and -half or half)
        createPart("Wall", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, segmentLength), CFrame.new(x, y, origin.Z - (DOOR_WIDTH / 2 + segmentLength / 2)), Enum.Material.Concrete, Color3.fromRGB(48, 52, 58), folder)
        createPart("Wall", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, segmentLength), CFrame.new(x, y, origin.Z + (DOOR_WIDTH / 2 + segmentLength / 2)), Enum.Material.Concrete, Color3.fromRGB(48, 52, 58), folder)
        if not openCenter then
            createPart("WallFill", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, DOOR_WIDTH), CFrame.new(x, y, origin.Z), Enum.Material.Concrete, Color3.fromRGB(48, 52, 58), folder)
        end
    end
end

local function createGate(folder, origin, side)
    local half = ctx.Config.RoomSize.X / 2
    local gate
    if side == "N" or side == "S" then
        local z = origin.Z + ((side == "N") and -half or half)
        gate = createPart("ExitGate", Vector3.new(DOOR_WIDTH, 13, 2), CFrame.new(origin.X, 6.5, z), Enum.Material.ForceField, Color3.fromRGB(72, 111, 126), folder)
    else
        local x = origin.X + ((side == "W") and -half or half)
        gate = createPart("ExitGate", Vector3.new(2, 13, DOOR_WIDTH), CFrame.new(x, 6.5, origin.Z), Enum.Material.ForceField, Color3.fromRGB(72, 111, 126), folder)
    end
    gate.Transparency = 0.3
    gate.CanCollide = true
    return gate
end

local function createCorridor(folder, fromOrigin, toOrigin)
    local delta = toOrigin - fromOrigin
    local midpoint = (fromOrigin + toOrigin) / 2
    if math.abs(delta.X) > math.abs(delta.Z) then
        local length = math.abs(delta.X) - ctx.Config.RoomSize.X
        createPart("CorridorFloor", Vector3.new(length, 1, 24), CFrame.new(midpoint.X, 0, midpoint.Z), Enum.Material.DiamondPlate, Color3.fromRGB(55, 58, 62), folder)
        createPart("CorridorRail", Vector3.new(length, 7, 2), CFrame.new(midpoint.X, 3.5, midpoint.Z - 13), Enum.Material.Metal, Color3.fromRGB(52, 56, 61), folder)
        createPart("CorridorRail", Vector3.new(length, 7, 2), CFrame.new(midpoint.X, 3.5, midpoint.Z + 13), Enum.Material.Metal, Color3.fromRGB(52, 56, 61), folder)
    else
        local length = math.abs(delta.Z) - ctx.Config.RoomSize.Z
        createPart("CorridorFloor", Vector3.new(24, 1, length), CFrame.new(midpoint.X, 0, midpoint.Z), Enum.Material.DiamondPlate, Color3.fromRGB(55, 58, 62), folder)
        createPart("CorridorRail", Vector3.new(2, 7, length), CFrame.new(midpoint.X - 13, 3.5, midpoint.Z), Enum.Material.Metal, Color3.fromRGB(52, 56, 61), folder)
        createPart("CorridorRail", Vector3.new(2, 7, length), CFrame.new(midpoint.X + 13, 3.5, midpoint.Z), Enum.Material.Metal, Color3.fromRGB(52, 56, 61), folder)
    end
end

local function addRoomCover(folder, origin, roomIndex, roomType)
    local variant = ((roomIndex - 1) % 4) + 1
    local coverColor = Color3.fromRGB(66, 71, 76)

    if variant == 1 then
        for _, offset in ipairs({ Vector3.new(-24, 3, -12), Vector3.new(24, 3, 12), Vector3.new(-5, 3, 25) }) do
            createPart("Cover", Vector3.new(18, 6, 4), CFrame.new(origin + offset), Enum.Material.Metal, coverColor, folder)
        end
    elseif variant == 2 then
        for _, offset in ipairs({ Vector3.new(-27, 4, -27), Vector3.new(27, 4, -27), Vector3.new(-27, 4, 27), Vector3.new(27, 4, 27) }) do
            createPart("Pillar", Vector3.new(7, 8, 7), CFrame.new(origin + offset), Enum.Material.Concrete, coverColor, folder)
        end
        createPart("CenterCover", Vector3.new(24, 5, 9), CFrame.new(origin + Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, math.rad(35), 0), Enum.Material.Metal, coverColor, folder)
    elseif variant == 3 then
        createPart("RaisedDeck", Vector3.new(34, 3, 22), CFrame.new(origin + Vector3.new(-25, 1.5, 20)), Enum.Material.DiamondPlate, coverColor, folder)
        createPart("RaisedDeck", Vector3.new(34, 3, 22), CFrame.new(origin + Vector3.new(25, 1.5, -20)), Enum.Material.DiamondPlate, coverColor, folder)
        for _, z in ipairs({ -4, 4 }) do
            createPart("LowCover", Vector3.new(16, 4, 4), CFrame.new(origin + Vector3.new(0, 2, z * 5)), Enum.Material.Metal, coverColor, folder)
        end
    else
        for _, offset in ipairs({ Vector3.new(-30, 2.5, 0), Vector3.new(30, 2.5, 0), Vector3.new(0, 2.5, -30), Vector3.new(0, 2.5, 30) }) do
            createPart("Barricade", Vector3.new(17, 5, 5), CFrame.lookAt(origin + offset, origin), Enum.Material.Metal, coverColor, folder)
        end
    end

    if roomType == "Elite" or roomType == "Boss" then
        local ring = createPart("ThreatRing", Vector3.new(roomType == "Boss" and 48 or 32, 0.18, roomType == "Boss" and 48 or 32), CFrame.new(origin + Vector3.new(0, 0.65, 0)), Enum.Material.Neon, roomType == "Boss" and Color3.fromRGB(151, 63, 67) or Color3.fromRGB(127, 91, 147), folder)
        ring.Transparency = 0.68
        ring.CanCollide = false
    end
end

local function decorateRoom(folder, origin, roomIndex, roomType)
    local corners = {
        Vector3.new(-42, 1, -42),
        Vector3.new(42, 1, -42),
        Vector3.new(-42, 1, 42),
        Vector3.new(42, 1, 42),
    }
    local keywords = roomType == "Boss" and { "statue", "pillar", "altar" } or { "pillar", "crate", "barrel", "statue" }
    for index, offset in ipairs(corners) do
        local rotation = CFrame.Angles(0, math.rad((index - 1) * 90), 0)
        cloneDecorCandidate("DungeonKit", keywords, CFrame.new(origin + offset) * rotation, 16, folder, true)
    end
    addRoomCover(folder, origin, roomIndex, roomType)
end

local function buildDungeon()
    local dungeon = Instance.new("Folder")
    dungeon.Name = "Sector07"
    dungeon.Parent = worldFolder

    for index, gridPosition in ipairs(ctx.Config.RoomPath) do
        local origin = DUNGEON_OFFSET + (gridPosition * ctx.Config.RoomSpacing)
        local roomType = ctx.Config.RoomSequence[index]
        local folder = Instance.new("Folder")
        folder.Name = string.format("Zone_%02d_%s", index, roomType)
        folder.Parent = dungeon

        createPart("Floor", Vector3.new(ctx.Config.RoomSize.X, 1, ctx.Config.RoomSize.Z), CFrame.new(origin), Enum.Material.Concrete, Color3.fromRGB(44, 48, 53), folder)
        createPart("FloorInset", Vector3.new(ctx.Config.RoomSize.X - 8, 0.25, ctx.Config.RoomSize.Z - 8), CFrame.new(origin + Vector3.new(0, 0.65, 0)), Enum.Material.DiamondPlate, Color3.fromRGB(54, 58, 63), folder)

        local connections = {}
        local nextKey
        if index > 1 then
            connections[directionKey(ctx.Config.RoomPath[index - 1] - gridPosition)] = true
        end
        if index < ctx.Config.RoomCount then
            nextKey = directionKey(ctx.Config.RoomPath[index + 1] - gridPosition)
            connections[nextKey] = true
        end

        for side in pairs(SIDES) do
            createWallWithGap(folder, origin, side, connections[side] == true)
        end

        local exitGate
        if nextKey then
            exitGate = createGate(folder, origin, nextKey)
        end

        local header = createPart("ZoneHeader", Vector3.new(24, 3, 1), CFrame.new(origin + Vector3.new(0, 13, -(ctx.Config.RoomSize.Z / 2 - 2))), Enum.Material.Neon, Color3.fromRGB(60, 126, 145), folder)
        header.CanCollide = false
        addBillboard(header, string.format("SECTOR 07  /  %02d  /  %s", index, string.upper(roomType)), 15)

        local trigger = createPart("RoomTrigger", Vector3.new(68, 8, 68), CFrame.new(origin + Vector3.new(0, 4, 0)), Enum.Material.SmoothPlastic, Color3.new(1, 1, 1), folder)
        trigger.Transparency = 1
        trigger.CanCollide = false
        trigger.CanTouch = true
        trigger.Touched:Connect(function(hit)
            local character = hit:FindFirstAncestorOfClass("Model")
            local player = character and Players:GetPlayerFromCharacter(character)
            if player and ctx.Run then
                ctx.Run.TryEnterRoom(player, index)
            end
        end)

        local spawnOffsets = {
            Vector3.new(-34, 2.5, -34),
            Vector3.new(34, 2.5, -34),
            Vector3.new(-34, 2.5, 34),
            Vector3.new(34, 2.5, 34),
            Vector3.new(0, 2.5, -38),
            Vector3.new(0, 2.5, 38),
            Vector3.new(-38, 2.5, 0),
            Vector3.new(38, 2.5, 0),
            Vector3.new(-18, 2.5, 18),
            Vector3.new(18, 2.5, -18),
        }

        rooms[index] = {
            Index = index,
            Type = roomType,
            Folder = folder,
            Origin = origin,
            ExitGate = exitGate,
            SpawnPoints = spawnOffsets,
        }

        decorateRoom(folder, origin, index, roomType)

        if index > 1 then
            createCorridor(dungeon, rooms[index - 1].Origin, origin)
        end
    end
end

function WorldService.Init(context)
    ctx = context
end

function WorldService.Build()
    local previous = Workspace:FindFirstChild("VaultfallWorld")
    if previous then
        previous:Destroy()
    end

    worldFolder = Instance.new("Folder")
    worldFolder.Name = "VaultfallWorld"
    worldFolder:SetAttribute("PresentationName", "BREACH PROTOCOL")
    worldFolder.Parent = Workspace

    table.clear(rooms)
    buildHub()
    buildDungeon()
end

function WorldService.GetRoom(index)
    return rooms[index]
end

function WorldService.GetRooms()
    return rooms
end

function WorldService.GetHubSpawnCFrame()
    return hubSpawnCFrame
end

function WorldService.GetRoomSpawnCFrame(index)
    local room = rooms[index]
    if not room then
        return hubSpawnCFrame
    end
    return CFrame.new(room.Origin + Vector3.new(0, 5, 0))
end

function WorldService.SetExitOpen(index, isOpen)
    local room = rooms[index]
    local gate = room and room.ExitGate
    if not gate then
        return
    end
    gate.CanCollide = not isOpen
    gate.Transparency = isOpen and 1 or 0.3
    gate.CanTouch = not isOpen
end

function WorldService.ResetGates()
    for index = 1, ctx.Config.RoomCount do
        WorldService.SetExitOpen(index, false)
    end
end

return WorldService
