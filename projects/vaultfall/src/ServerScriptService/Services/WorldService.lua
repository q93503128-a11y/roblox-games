local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local WorldService = {}
local ctx
local worldFolder
local rooms = {}
local hubSpawnCFrame = CFrame.new(-220, 5, -120)

local DUNGEON_OFFSET = Vector3.new(80, 0, 0)
local WALL_HEIGHT = 18
local DOOR_WIDTH = 16
local WALL_THICKNESS = 3

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
    part.Material = material or Enum.Material.Slate
    part.Color = color or Color3.fromRGB(63, 65, 72)
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function addSurfaceLabel(part, text)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Top
    gui.AlwaysOnTop = true
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(235, 238, 245)
    label.Parent = gui
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

local function cloneDecorCandidate(packName, keywords, targetCFrame, maxDimension, parent)
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
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            descendant:Destroy()
        elseif descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
        end
    end

    if clone:IsA("BasePart") then
        clone.Anchored = true
        clone.CanCollide = false
        clone.CFrame = targetCFrame
    elseif clone:IsA("Model") then
        local ok, _, size = pcall(function()
            return clone:GetBoundingBox()
        end)
        if ok and size then
            local largest = math.max(size.X, size.Y, size.Z)
            if largest > maxDimension and largest > 0 then
                pcall(function()
                    clone:ScaleTo(maxDimension / largest)
                end)
            end
        end
        pcall(function()
            clone:PivotTo(targetCFrame)
        end)
    end

    clone.Parent = parent
    return clone
end

local function decorateHub(folder, origin)
    local placements = {
        CFrame.new(origin + Vector3.new(-38, 1, -38)),
        CFrame.new(origin + Vector3.new(38, 1, -38)),
        CFrame.new(origin + Vector3.new(-38, 1, 38)),
        CFrame.new(origin + Vector3.new(38, 1, 38)),
    }
    for _, cf in ipairs(placements) do
        cloneDecorCandidate("NaturePack", { "tree", "rock", "bush" }, cf, 18, folder)
    end
end

local function decorateRoom(folder, origin, roomIndex)
    local corners = {
        Vector3.new(-30, 1, -30),
        Vector3.new(30, 1, -30),
        Vector3.new(-30, 1, 30),
        Vector3.new(30, 1, 30),
    }

    local keywords = roomIndex == ctx.Config.RoomCount
        and { "statue", "pillar", "torch", "altar" }
        or { "pillar", "torch", "crate", "barrel", "statue" }

    for index, offset in ipairs(corners) do
        local rotation = CFrame.Angles(0, math.rad((index - 1) * 90), 0)
        cloneDecorCandidate("DungeonKit", keywords, CFrame.new(origin + offset) * rotation, 15, folder)
    end
end

local function createWallWithGap(folder, origin, side, openCenter)
    local half = ctx.Config.RoomSize.X / 2
    local segmentLength = (ctx.Config.RoomSize.X - DOOR_WIDTH) / 2
    local y = WALL_HEIGHT / 2

    if side == "N" or side == "S" then
        local z = origin.Z + ((side == "N") and -half or half)
        createPart("Wall", Vector3.new(segmentLength, WALL_HEIGHT, WALL_THICKNESS), CFrame.new(origin.X - (DOOR_WIDTH / 2 + segmentLength / 2), y, z), Enum.Material.Slate, nil, folder)
        createPart("Wall", Vector3.new(segmentLength, WALL_HEIGHT, WALL_THICKNESS), CFrame.new(origin.X + (DOOR_WIDTH / 2 + segmentLength / 2), y, z), Enum.Material.Slate, nil, folder)
        if not openCenter then
            createPart("WallFill", Vector3.new(DOOR_WIDTH, WALL_HEIGHT, WALL_THICKNESS), CFrame.new(origin.X, y, z), Enum.Material.Slate, nil, folder)
        end
    else
        local x = origin.X + ((side == "W") and -half or half)
        createPart("Wall", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, segmentLength), CFrame.new(x, y, origin.Z - (DOOR_WIDTH / 2 + segmentLength / 2)), Enum.Material.Slate, nil, folder)
        createPart("Wall", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, segmentLength), CFrame.new(x, y, origin.Z + (DOOR_WIDTH / 2 + segmentLength / 2)), Enum.Material.Slate, nil, folder)
        if not openCenter then
            createPart("WallFill", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, DOOR_WIDTH), CFrame.new(x, y, origin.Z), Enum.Material.Slate, nil, folder)
        end
    end
end

local function createGate(folder, origin, side)
    local half = ctx.Config.RoomSize.X / 2
    local gate
    if side == "N" or side == "S" then
        local z = origin.Z + ((side == "N") and -half or half)
        gate = createPart("ExitGate", Vector3.new(DOOR_WIDTH, 12, 2), CFrame.new(origin.X, 6, z), Enum.Material.ForceField, Color3.fromRGB(72, 55, 91), folder)
    else
        local x = origin.X + ((side == "W") and -half or half)
        gate = createPart("ExitGate", Vector3.new(2, 12, DOOR_WIDTH), CFrame.new(x, 6, origin.Z), Enum.Material.ForceField, Color3.fromRGB(72, 55, 91), folder)
    end
    gate.Transparency = 0.22
    gate.CanCollide = true
    return gate
end

local function createCorridor(folder, fromOrigin, toOrigin)
    local delta = toOrigin - fromOrigin
    local midpoint = (fromOrigin + toOrigin) / 2
    if math.abs(delta.X) > math.abs(delta.Z) then
        local length = math.abs(delta.X) - ctx.Config.RoomSize.X
        createPart("CorridorFloor", Vector3.new(length, 1, 18), CFrame.new(midpoint.X, 0, midpoint.Z), Enum.Material.Cobblestone, Color3.fromRGB(75, 72, 70), folder)
        createPart("CorridorRail", Vector3.new(length, 7, 2), CFrame.new(midpoint.X, 3.5, midpoint.Z - 10), Enum.Material.Slate, nil, folder)
        createPart("CorridorRail", Vector3.new(length, 7, 2), CFrame.new(midpoint.X, 3.5, midpoint.Z + 10), Enum.Material.Slate, nil, folder)
    else
        local length = math.abs(delta.Z) - ctx.Config.RoomSize.Z
        createPart("CorridorFloor", Vector3.new(18, 1, length), CFrame.new(midpoint.X, 0, midpoint.Z), Enum.Material.Cobblestone, Color3.fromRGB(75, 72, 70), folder)
        createPart("CorridorRail", Vector3.new(2, 7, length), CFrame.new(midpoint.X - 10, 3.5, midpoint.Z), Enum.Material.Slate, nil, folder)
        createPart("CorridorRail", Vector3.new(2, 7, length), CFrame.new(midpoint.X + 10, 3.5, midpoint.Z), Enum.Material.Slate, nil, folder)
    end
end

local function buildHub()
    local folder = Instance.new("Folder")
    folder.Name = "Hub"
    folder.Parent = worldFolder

    local origin = Vector3.new(-220, 0, -120)
    createPart("HubFloor", Vector3.new(104, 1, 104), CFrame.new(origin), Enum.Material.Cobblestone, Color3.fromRGB(82, 79, 76), folder)
    createPart("HubBackWall", Vector3.new(104, 15, 3), CFrame.new(origin + Vector3.new(0, 7.5, -52)), Enum.Material.Slate, nil, folder)

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "HubSpawn"
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.CFrame = hubSpawnCFrame * CFrame.new(0, -4.5, 0)
    spawn.Transparency = 1
    spawn.CanCollide = false
    spawn.Neutral = true
    spawn.Parent = folder

    local portal = createPart("VaultPortal", Vector3.new(20, 2, 20), CFrame.new(origin + Vector3.new(0, 1, 18)), Enum.Material.Neon, Color3.fromRGB(83, 66, 112), folder)
    addSurfaceLabel(portal, "ENTER VAULT")
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Enter Vault"
    prompt.ObjectText = "Vault Gate"
    prompt.HoldDuration = 0.4
    prompt.MaxActivationDistance = 12
    prompt.Parent = portal
    prompt.Triggered:Connect(function(player)
        if ctx.Run then
            ctx.Run.StartRun(player)
        end
    end)

    local attackPad = createPart("AttackUpgrade", Vector3.new(14, 2, 14), CFrame.new(origin + Vector3.new(-25, 1, -10)), Enum.Material.Marble, Color3.fromRGB(93, 76, 70), folder)
    addSurfaceLabel(attackPad, "ATTACK")
    local attackPrompt = Instance.new("ProximityPrompt")
    attackPrompt.ActionText = "Upgrade Attack"
    attackPrompt.ObjectText = "Forge Altar"
    attackPrompt.HoldDuration = 0.25
    attackPrompt.Parent = attackPad
    attackPrompt.Triggered:Connect(function(player)
        local ok, message = ctx.Profile.BuyUpgrade(player, "Attack")
        ctx.Remotes.State:FireClient(player, "Notice", message)
    end)

    local healthPad = createPart("HealthUpgrade", Vector3.new(14, 2, 14), CFrame.new(origin + Vector3.new(25, 1, -10)), Enum.Material.Marble, Color3.fromRGB(70, 91, 81), folder)
    addSurfaceLabel(healthPad, "HEALTH")
    local healthPrompt = Instance.new("ProximityPrompt")
    healthPrompt.ActionText = "Upgrade Health"
    healthPrompt.ObjectText = "Vital Altar"
    healthPrompt.HoldDuration = 0.25
    healthPrompt.Parent = healthPad
    healthPrompt.Triggered:Connect(function(player)
        local ok, message = ctx.Profile.BuyUpgrade(player, "Health")
        ctx.Remotes.State:FireClient(player, "Notice", message)
    end)

    decorateHub(folder, origin)
end

local function buildDungeon()
    local dungeon = Instance.new("Folder")
    dungeon.Name = "Dungeon"
    dungeon.Parent = worldFolder

    for index, gridPosition in ipairs(ctx.Config.RoomPath) do
        local origin = DUNGEON_OFFSET + (gridPosition * ctx.Config.RoomSpacing)
        local folder = Instance.new("Folder")
        folder.Name = string.format("Room_%02d_%s", index, ctx.Config.RoomSequence[index])
        folder.Parent = dungeon

        createPart("Floor", Vector3.new(ctx.Config.RoomSize.X, 1, ctx.Config.RoomSize.Z), CFrame.new(origin), Enum.Material.Cobblestone, Color3.fromRGB(68, 66, 65), folder)

        local connections = {}
        local prevKey
        local nextKey
        if index > 1 then
            prevKey = directionKey(ctx.Config.RoomPath[index - 1] - gridPosition)
            connections[prevKey] = true
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

        local trigger = createPart("RoomTrigger", Vector3.new(52, 7, 52), CFrame.new(origin + Vector3.new(0, 3.5, 0)), Enum.Material.SmoothPlastic, Color3.new(1, 1, 1), folder)
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
            Vector3.new(-24, 2.5, -24),
            Vector3.new(24, 2.5, -24),
            Vector3.new(-24, 2.5, 24),
            Vector3.new(24, 2.5, 24),
            Vector3.new(0, 2.5, -26),
            Vector3.new(0, 2.5, 26),
            Vector3.new(-26, 2.5, 0),
            Vector3.new(26, 2.5, 0),
        }

        rooms[index] = {
            Index = index,
            Type = ctx.Config.RoomSequence[index],
            Folder = folder,
            Origin = origin,
            ExitGate = exitGate,
            SpawnPoints = spawnOffsets,
        }

        decorateRoom(folder, origin, index)

        if index > 1 then
            local previous = rooms[index - 1]
            createCorridor(dungeon, previous.Origin, origin)
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
    gate.Transparency = isOpen and 1 or 0.22
    gate.CanTouch = not isOpen
end

function WorldService.ResetGates()
    for index = 1, ctx.Config.RoomCount do
        WorldService.SetExitOpen(index, false)
    end
end

return WorldService
