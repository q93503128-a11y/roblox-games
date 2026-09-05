local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local tracked = {}
local folderConnections = {}

local ACCENT = {
    Shade = Color3.fromRGB(164, 116, 235),
    Archer = Color3.fromRGB(91, 205, 163),
    Brute = Color3.fromRGB(231, 122, 70),
    Elite = Color3.fromRGB(229, 88, 176),
    VaultWarden = Color3.fromRGB(242, 72, 88),
}

local function enemyType(model)
    return string.match(model.Name, "^([^_]+)") or "Shade"
end

local function safePart(parent, name, size, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = material or Enum.Material.Metal
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Massless = true
    part.Parent = parent
    return part
end

local function cylinder(parent, name, size, color, material)
    local part = safePart(parent, name, size, color, material)
    part.Shape = Enum.PartType.Cylinder
    return part
end

local function ball(parent, name, size, color, material)
    local part = safePart(parent, name, Vector3.new(size, size, size), color, material)
    part.Shape = Enum.PartType.Ball
    return part
end

local function addLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Shadows = false
    light.Parent = host
end

local function addPiece(entry, part, localCFrame, motionKind, index)
    table.insert(entry.pieces, {
        part = part,
        localCFrame = localCFrame,
        motionKind = motionKind,
        index = index or 1,
    })
end

local function buildShade(entry, accent, scale)
    local dark = Color3.fromRGB(25, 24, 31)
    for sideIndex, side in ipairs({ -1, 1 }) do
        local blade = safePart(entry.visual, "ShadeForearmBlade", Vector3.new(0.18, 0.72, 2.65) * scale, accent, Enum.Material.Neon)
        addPiece(entry, blade, CFrame.new(side * 1.15 * scale, 0.1 * scale, -1.15 * scale) * CFrame.Angles(math.rad(-18), math.rad(side * 8), math.rad(side * 18)), "blade", sideIndex)

        local guard = safePart(entry.visual, "ShadeBladeGuard", Vector3.new(0.46, 0.42, 0.62) * scale, dark, Enum.Material.Metal)
        addPiece(entry, guard, CFrame.new(side * 1.1 * scale, 0.1 * scale, -0.15 * scale), "blade", sideIndex)
    end
    for index = 1, 3 do
        local shard = safePart(entry.visual, "ShadeBackShard", Vector3.new(0.14, 1.0, 1.8) * scale, dark, Enum.Material.Metal)
        addPiece(entry, shard, CFrame.new((index - 2) * 0.48 * scale, 0.75 * scale, 0.7 * scale) * CFrame.Angles(math.rad(18), 0, math.rad((index - 2) * 18)), "shard", index)
    end
end

local function buildArcher(entry, accent, scale)
    local dark = Color3.fromRGB(24, 33, 31)
    local bowTop = cylinder(entry.visual, "ArcherBowTop", Vector3.new(0.14, 2.5, 0.14) * scale, dark, Enum.Material.Metal)
    addPiece(entry, bowTop, CFrame.new(-1.15 * scale, 0.5 * scale, -0.5 * scale) * CFrame.Angles(0, 0, math.rad(22)), "bow", 1)
    local bowBottom = cylinder(entry.visual, "ArcherBowBottom", Vector3.new(0.14, 2.5, 0.14) * scale, dark, Enum.Material.Metal)
    addPiece(entry, bowBottom, CFrame.new(-1.15 * scale, -0.75 * scale, -0.5 * scale) * CFrame.Angles(0, 0, math.rad(-22)), "bow", 2)

    local charge = ball(entry.visual, "ArcherCharge", 0.52 * scale, accent, Enum.Material.Neon)
    addLight(charge, accent, 0.8, 7)
    addPiece(entry, charge, CFrame.new(-0.7 * scale, 0, -1.35 * scale), "charge", 1)

    local quiver = cylinder(entry.visual, "ArcherQuiver", Vector3.new(0.48, 2.2, 0.48) * scale, Color3.fromRGB(53, 66, 61), Enum.Material.Metal)
    addPiece(entry, quiver, CFrame.new(0.9 * scale, 0.4 * scale, 0.65 * scale) * CFrame.Angles(math.rad(18), 0, math.rad(-28)), "idle", 1)
end

local function buildBrute(entry, accent, scale)
    local armor = Color3.fromRGB(63, 55, 50)
    for sideIndex, side in ipairs({ -1, 1 }) do
        local shoulder = safePart(entry.visual, "BruteShoulderPlate", Vector3.new(1.55, 0.62, 1.7) * scale, armor, Enum.Material.DiamondPlate)
        addPiece(entry, shoulder, CFrame.new(side * 1.25 * scale, 0.95 * scale, 0.1 * scale) * CFrame.Angles(0, 0, math.rad(side * 9)), "shoulder", sideIndex)
        local fist = safePart(entry.visual, "BruteGauntlet", Vector3.new(1.15, 1.05, 1.3) * scale, armor, Enum.Material.Metal)
        addPiece(entry, fist, CFrame.new(side * 1.35 * scale, -0.55 * scale, -0.65 * scale), "gauntlet", sideIndex)
        local knuckle = safePart(entry.visual, "BruteKnuckleGlow", Vector3.new(0.8, 0.16, 0.22) * scale, accent, Enum.Material.Neon)
        addPiece(entry, knuckle, CFrame.new(side * 1.35 * scale, -0.55 * scale, -1.33 * scale), "gauntlet", sideIndex)
    end
    local spine = safePart(entry.visual, "BruteBackPlate", Vector3.new(2.2, 2.8, 0.38) * scale, armor, Enum.Material.DiamondPlate)
    addPiece(entry, spine, CFrame.new(0, 0.25 * scale, 0.95 * scale), "idle", 1)
end

local function buildElite(entry, accent, scale)
    local dark = Color3.fromRGB(41, 29, 43)
    for index = 1, 4 do
        local fin = safePart(entry.visual, "EliteOrbitBlade", Vector3.new(0.18, 0.56, 1.9) * scale, index % 2 == 0 and accent or dark, index % 2 == 0 and Enum.Material.Neon or Enum.Material.Metal)
        addPiece(entry, fin, CFrame.identity, "orbit", index)
    end
    local core = ball(entry.visual, "EliteCrownCore", 0.66 * scale, accent, Enum.Material.Neon)
    addLight(core, accent, 0.7, 8)
    addPiece(entry, core, CFrame.new(0, 2.1 * scale, 0), "pulse", 1)
end

local function buildWarden(entry, accent, scale)
    local dark = Color3.fromRGB(35, 31, 38)
    for index = 1, 6 do
        local crown = safePart(entry.visual, "WardenCrownBlade", Vector3.new(0.2, 1.0, 2.4) * scale, index % 2 == 0 and accent or dark, index % 2 == 0 and Enum.Material.Neon or Enum.Material.Metal)
        addPiece(entry, crown, CFrame.identity, "crown", index)
    end
    for index = 1, 3 do
        local reactor = ball(entry.visual, "WardenReactor", 0.72 * scale, accent, Enum.Material.Neon)
        addLight(reactor, accent, 0.6, 10)
        addPiece(entry, reactor, CFrame.identity, "reactor", index)
    end
    local chest = safePart(entry.visual, "WardenChestPlate", Vector3.new(3.2, 2.4, 0.42) * scale, dark, Enum.Material.DiamondPlate)
    addPiece(entry, chest, CFrame.new(0, 0.45 * scale, -1.15 * scale), "pulse", 1)
end

local function build(model)
    if tracked[model] then
        return
    end
    local root = model:FindFirstChild("Root")
    if not root or not root:IsA("BasePart") then
        return
    end

    local kind = enemyType(model)
    local accent = ACCENT[kind] or ACCENT.Shade
    local radius = math.max(1.2, math.max(root.Size.X, root.Size.Z) * 0.5)
    local scale = math.clamp(radius / 2.4, 0.75, kind == "VaultWarden" and 1.8 or 1.35)

    local visual = Instance.new("Model")
    visual.Name = model.Name .. "_SilhouettePolish"
    visual.Parent = Workspace

    local entry = {
        model = model,
        root = root,
        visual = visual,
        kind = kind,
        scale = scale,
        pieces = {},
        phase = math.random() * math.pi * 2,
        lastPosition = root.Position,
        moveBlend = 0,
    }
    tracked[model] = entry

    if kind == "Archer" then
        buildArcher(entry, accent, scale)
    elseif kind == "Brute" then
        buildBrute(entry, accent, scale)
    elseif kind == "Elite" then
        buildElite(entry, accent, scale)
    elseif kind == "VaultWarden" then
        buildWarden(entry, accent, scale)
    else
        buildShade(entry, accent, scale)
    end
end

local function destroyEntry(model)
    local entry = tracked[model]
    if not entry then
        return
    end
    if entry.visual then
        entry.visual:Destroy()
    end
    tracked[model] = nil
end

local function nearestPlayerDistance(position)
    local best = math.huge
    for _, candidate in ipairs(Players:GetPlayers()) do
        local character = candidate.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and humanoid.Health > 0 and root then
            best = math.min(best, (root.Position - position).Magnitude)
        end
    end
    return best
end

local function update(entry, dt, now)
    local root = entry.root
    if not root or not root.Parent or not entry.model.Parent then
        destroyEntry(entry.model)
        return
    end

    local delta = root.Position - entry.lastPosition
    entry.lastPosition = root.Position
    local targetMove = delta.Magnitude > 0.025 and 1 or 0
    entry.moveBlend += (targetMove - entry.moveBlend) * math.min(1, dt * 8)

    local threatDistance = nearestPlayerDistance(root.Position)
    local attackRange = entry.kind == "Archer" and 32 or entry.kind == "VaultWarden" and 15 or 8
    local threat = math.clamp(1 - threatDistance / attackRange, 0, 1)
    local gait = math.sin(now * 6.4 + entry.phase)
    local breathe = math.sin(now * 2.2 + entry.phase)
    local base = root.CFrame * CFrame.new(0, math.abs(gait) * 0.06 * entry.moveBlend, 0)

    for _, info in ipairs(entry.pieces) do
        local motion = CFrame.identity
        if info.motionKind == "blade" then
            local side = info.index == 1 and -1 or 1
            motion = CFrame.Angles(math.rad(gait * 10 * entry.moveBlend), 0, math.rad(side * (4 + threat * 12)))
        elseif info.motionKind == "shard" then
            motion = CFrame.Angles(0, math.rad(breathe * 4 + (info.index - 2) * 2), math.rad(breathe * 3))
        elseif info.motionKind == "bow" then
            local sign = info.index == 1 and 1 or -1
            motion = CFrame.Angles(0, math.rad(-threat * 12), math.rad(sign * threat * 7))
        elseif info.motionKind == "charge" then
            local pulse = 1 + math.max(0, math.sin(now * (5 + threat * 7))) * (0.15 + threat * 0.22)
            info.part.Size = Vector3.new(0.52, 0.52, 0.52) * entry.scale * pulse
            info.part.Transparency = 0.08 + (1 - threat) * 0.18
        elseif info.motionKind == "gauntlet" then
            local side = info.index == 1 and -1 or 1
            motion = CFrame.new(0, 0, -threat * 0.28) * CFrame.Angles(math.rad(-threat * 18), 0, math.rad(side * 4 * threat))
        elseif info.motionKind == "shoulder" then
            local side = info.index == 1 and -1 or 1
            motion = CFrame.Angles(0, 0, math.rad(side * breathe * 2.5))
        elseif info.motionKind == "orbit" then
            local angle = now * (0.8 + threat * 0.9) + info.index * (math.pi * 0.5)
            local radius = 2.05 * entry.scale
            local y = 1.15 * entry.scale + math.sin(angle * 1.7) * 0.24
            motion = CFrame.new(math.cos(angle) * radius, y, math.sin(angle) * radius) * CFrame.Angles(0, -angle + math.pi * 0.5, math.rad(18))
        elseif info.motionKind == "crown" then
            local angle = now * (0.32 + threat * 0.38) + info.index * (math.pi / 3)
            local radius = 3.2 * entry.scale
            motion = CFrame.new(math.cos(angle) * radius, (2.8 + math.sin(angle * 2) * 0.25) * entry.scale, math.sin(angle) * radius) * CFrame.Angles(math.rad(-20), -angle + math.pi * 0.5, math.rad(28))
        elseif info.motionKind == "reactor" then
            local angle = now * (0.9 + threat * 0.6) + info.index * (math.pi * 2 / 3)
            local radius = 1.55 * entry.scale
            motion = CFrame.new(math.cos(angle) * radius, 0.45 * entry.scale + math.sin(angle * 1.4) * 0.35, math.sin(angle) * radius)
        elseif info.motionKind == "pulse" then
            motion = CFrame.new(0, breathe * 0.08 * entry.scale, 0)
        else
            motion = CFrame.Angles(math.rad(breathe * 1.5), 0, 0)
        end

        if info.part and info.part.Parent then
            if info.motionKind == "orbit" or info.motionKind == "crown" or info.motionKind == "reactor" then
                info.part.CFrame = base * motion
            else
                info.part.CFrame = base * info.localCFrame * motion
            end
        end
    end
end

local function bindEnemiesFolder(folder)
    if folderConnections[folder] then
        return
    end
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") then
            task.defer(build, child)
        end
    end
    folderConnections[folder] = folder.ChildAdded:Connect(function(child)
        if not child:IsA("Model") then
            return
        end
        task.defer(function()
            child:WaitForChild("Root", 2)
            build(child)
        end)
    end)
end

local function scanWorld(world)
    local enemies = world:FindFirstChild("Enemies")
    if enemies and enemies:IsA("Folder") then
        bindEnemiesFolder(enemies)
    end
    world.ChildAdded:Connect(function(child)
        if child.Name == "Enemies" and child:IsA("Folder") then
            bindEnemiesFolder(child)
        end
    end)
end

local world = Workspace:FindFirstChild("VaultfallWorld")
if world then
    scanWorld(world)
end
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "VaultfallWorld" then
        scanWorld(child)
    end
end)

RunService:BindToRenderStep("VaultfallEnemySilhouettePolish", Enum.RenderPriority.Character.Value + 5, function(dt)
    local now = os.clock()
    for _, entry in pairs(tracked) do
        update(entry, dt, now)
    end
end)

player.AncestryChanged:Connect(function(_, parent)
    if parent then
        return
    end
    RunService:UnbindFromRenderStep("VaultfallEnemySilhouettePolish")
    for model in pairs(tracked) do
        destroyEntry(model)
    end
    for _, connection in pairs(folderConnections) do
        connection:Disconnect()
    end
    table.clear(folderConnections)
end)
