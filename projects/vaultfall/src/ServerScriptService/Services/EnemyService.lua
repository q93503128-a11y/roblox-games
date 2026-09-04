local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local EnemyService = {}
local ctx
local enemies = {}
local nextEnemyId = 0
local heartbeatAccumulator = 0

local function stripScripts(instance)
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            descendant:Destroy()
        end
    end
end

local function weldPartToRoot(part, root)
    part.Anchored = false
    part.CanCollide = false
    part.CanTouch = false
    part.Massless = true
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = part
    weld.Parent = part
end

local function attachImportedVisual(enemyModel, root, desiredSize, seed)
    local assetRoot = ServerStorage:FindFirstChild("VaultfallAssets")
    local pack = assetRoot and assetRoot:FindFirstChild("MonsterPack")
    if not pack then
        return false
    end

    local candidates = {}
    for _, child in ipairs(pack:GetChildren()) do
        if child:IsA("Model") or child:IsA("MeshPart") or child:IsA("UnionOperation") then
            table.insert(candidates, child)
        end
    end
    if #candidates == 0 then
        for _, descendant in ipairs(pack:GetDescendants()) do
            if descendant:IsA("Model") and descendant:FindFirstChildWhichIsA("BasePart", true) then
                table.insert(candidates, descendant)
            end
        end
    end
    if #candidates == 0 then
        return false
    end

    local source = candidates[((seed - 1) % #candidates) + 1]
    local clone = source:Clone()
    clone.Name = "ImportedVisual"
    stripScripts(clone)
    clone.Parent = enemyModel

    if clone:IsA("Model") then
        local ok, _, size = pcall(function()
            return clone:GetBoundingBox()
        end)
        if ok and size then
            local maxDim = math.max(size.X, size.Y, size.Z)
            if maxDim > 0.1 then
                pcall(function()
                    clone:ScaleTo(desiredSize / maxDim)
                end)
            end
        end
        pcall(function()
            clone:PivotTo(root.CFrame)
        end)
        for _, part in ipairs(clone:GetDescendants()) do
            if part:IsA("BasePart") then
                weldPartToRoot(part, root)
            end
        end
    elseif clone:IsA("BasePart") then
        clone.Size = Vector3.new(desiredSize, desiredSize, desiredSize)
        clone.CFrame = root.CFrame
        weldPartToRoot(clone, root)
    end

    return true
end

local function fallbackVisual(enemyModel, root, enemyType, radius)
    local colors = {
        Shade = Color3.fromRGB(63, 58, 82),
        Archer = Color3.fromRGB(63, 80, 75),
        Brute = Color3.fromRGB(92, 66, 61),
        Elite = Color3.fromRGB(100, 72, 111),
        VaultWarden = Color3.fromRGB(90, 55, 61),
    }
    local color = colors[enemyType] or Color3.fromRGB(70, 70, 75)

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(radius * 1.5, radius * 2.1, radius * 1.25)
    body.CFrame = root.CFrame * CFrame.new(0, radius * 0.35, 0)
    body.Material = Enum.Material.Slate
    body.Color = color
    body.Parent = enemyModel
    weldPartToRoot(body, root)

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Shape = Enum.PartType.Ball
    head.Size = Vector3.new(radius, radius, radius)
    head.CFrame = root.CFrame * CFrame.new(0, radius * 1.6, 0)
    head.Material = Enum.Material.SmoothPlastic
    head.Color = color:Lerp(Color3.new(1, 1, 1), 0.08)
    head.Parent = enemyModel
    weldPartToRoot(head, root)

    local eye = Instance.new("Part")
    eye.Name = "Eye"
    eye.Size = Vector3.new(radius * 0.55, radius * 0.16, 0.12)
    eye.CFrame = head.CFrame * CFrame.new(0, 0.05, -(radius * 0.51))
    eye.Material = Enum.Material.Neon
    eye.Color = enemyType == "VaultWarden" and Color3.fromRGB(255, 86, 86) or Color3.fromRGB(190, 168, 255)
    eye.Parent = enemyModel
    weldPartToRoot(eye, root)
end

local function createHealthBar(root, enemy)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBar"
    billboard.Size = UDim2.fromOffset(110, 18)
    billboard.StudsOffset = Vector3.new(0, enemy.Data.Radius * 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 90
    billboard.Parent = root

    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.fromScale(1, 1)
    background.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    background.BorderSizePixel = 0
    background.Parent = billboard

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = enemy.Data.Boss and Color3.fromRGB(206, 76, 80) or Color3.fromRGB(118, 174, 117)
    fill.BorderSizePixel = 0
    fill.Parent = background

    local label = Instance.new("TextLabel")
    label.Name = "Name"
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.35
    label.Text = enemy.Type
    label.Parent = background

    enemy.HealthFill = fill
end

local function updateHealth(enemy)
    if enemy.HealthFill then
        enemy.HealthFill.Size = UDim2.fromScale(math.clamp(enemy.Health / enemy.MaxHealth, 0, 1), 1)
    end
end

local function getTarget(enemy)
    if not ctx.Run or not ctx.Run.GetLivingParticipants then
        return nil
    end

    local nearest
    local nearestDistance = math.huge
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if root and humanoid and humanoid.Health > 0 then
            local distance = (root.Position - enemy.Root.Position).Magnitude
            if distance < nearestDistance then
                nearest = player
                nearestDistance = distance
            end
        end
    end
    return nearest, nearestDistance
end

local function damagePlayer(player, amount)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:TakeDamage(amount)
    end
end

local function rangedStrike(enemy, player)
    local character = player.Character
    local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local startPosition = enemy.Root.Position + Vector3.new(0, 2, 0)
    local targetPosition = targetRoot.Position
    local projectile = Instance.new("Part")
    projectile.Name = "EnemyBolt"
    projectile.Shape = Enum.PartType.Ball
    projectile.Size = Vector3.new(0.8, 0.8, 0.8)
    projectile.Material = Enum.Material.Neon
    projectile.Color = Color3.fromRGB(169, 126, 214)
    projectile.Anchored = true
    projectile.CanCollide = false
    projectile.CFrame = CFrame.new(startPosition)
    projectile.Parent = Workspace

    local travelTime = math.clamp((targetPosition - startPosition).Magnitude / 36, 0.25, 0.75)
    local tween = TweenService:Create(projectile, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), { Position = targetPosition })
    tween:Play()
    task.delay(travelTime, function()
        if projectile.Parent then
            projectile:Destroy()
        end
        local currentCharacter = player.Character
        local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
        if currentRoot and (currentRoot.Position - targetPosition).Magnitude <= 5.5 then
            damagePlayer(player, enemy.Damage)
        end
    end)
end

local function bossPulse(enemy)
    local ring = Instance.new("Part")
    ring.Name = "WardenPulse"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.18, 2, 2)
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(194, 69, 84)
    ring.Transparency = 0.35
    ring.Anchored = true
    ring.CanCollide = false
    ring.CFrame = CFrame.new(enemy.Root.Position - Vector3.new(0, 1.3, 0)) * CFrame.Angles(0, 0, math.rad(90))
    ring.Parent = Workspace

    TweenService:Create(ring, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.18, 38, 38),
        Transparency = 0.78,
    }):Play()

    task.delay(0.78, function()
        if not enemy.Alive then
            if ring.Parent then ring:Destroy() end
            return
        end
        for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - enemy.Root.Position).Magnitude <= 19 then
                damagePlayer(player, math.floor(enemy.Damage * 1.25))
            end
        end
        if ring.Parent then
            ring:Destroy()
        end
    end)
end

local function getNavigationAreas(room)
    local areas = {
        {
            Center = room.Origin,
            Size = Vector2.new(ctx.Config.RoomSize.X - 10, ctx.Config.RoomSize.Z - 10),
        },
    }

    local expansions = Workspace:FindFirstChild("VaultfallCombatExpansions")
    if expansions then
        for _, wing in ipairs(expansions:GetChildren()) do
            if wing:GetAttribute("RoomIndex") == room.Index then
                local floor = wing:FindFirstChild("WingFloor")
                if floor and floor:IsA("BasePart") then
                    table.insert(areas, {
                        Center = floor.Position,
                        Size = Vector2.new(math.max(4, floor.Size.X - 8), math.max(4, floor.Size.Z - 8)),
                    })
                end
            end
        end
    end

    return areas
end

local function clampToNavigation(room, candidate, y)
    local areas = getNavigationAreas(room)
    for _, area in ipairs(areas) do
        local halfX = area.Size.X * 0.5
        local halfZ = area.Size.Y * 0.5
        if math.abs(candidate.X - area.Center.X) <= halfX and math.abs(candidate.Z - area.Center.Z) <= halfZ then
            return Vector3.new(candidate.X, y, candidate.Z)
        end
    end

    local best
    local bestDistance = math.huge
    for _, area in ipairs(areas) do
        local halfX = area.Size.X * 0.5
        local halfZ = area.Size.Y * 0.5
        local projected = Vector3.new(
            math.clamp(candidate.X, area.Center.X - halfX, area.Center.X + halfX),
            y,
            math.clamp(candidate.Z, area.Center.Z - halfZ, area.Center.Z + halfZ)
        )
        local distance = (Vector2.new(projected.X, projected.Z) - Vector2.new(candidate.X, candidate.Z)).Magnitude
        if distance < bestDistance then
            bestDistance = distance
            best = projected
        end
    end
    return best or Vector3.new(candidate.X, y, candidate.Z)
end

local function stepEnemy(enemy, dt)
    if not enemy.Alive or not enemy.Model.Parent then
        return
    end

    local player, distance = getTarget(enemy)
    if not player then
        return
    end

    local character = player.Character
    local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        return
    end

    local now = os.clock()
    if enemy.Data.Boss and now - enemy.LastPulse >= 5.4 then
        enemy.LastPulse = now
        bossPulse(enemy)
    end

    if distance <= enemy.AttackRange then
        if now - enemy.LastAttack >= enemy.AttackCooldown then
            enemy.LastAttack = now
            if enemy.Data.Ranged then
                rangedStrike(enemy, player)
            else
                damagePlayer(player, enemy.Damage)
            end
        end
        return
    end

    local delta = targetRoot.Position - enemy.Root.Position
    local flat = Vector3.new(delta.X, 0, delta.Z)
    if flat.Magnitude < 0.01 then
        return
    end

    local direction = flat.Unit
    local moveDistance = math.min(enemy.Speed * dt, flat.Magnitude - enemy.AttackRange * 0.75)
    if moveDistance <= 0 then
        return
    end

    local room = ctx.World.GetRoom(enemy.RoomIndex)
    local candidate = enemy.Root.Position + direction * moveDistance
    if room then
        candidate = clampToNavigation(room, candidate, enemy.Root.Position.Y)
    end

    enemy.Model:PivotTo(CFrame.lookAt(candidate, candidate + direction))
end

function EnemyService.Init(context)
    ctx = context
    RunService.Heartbeat:Connect(function(dt)
        heartbeatAccumulator += dt
        if heartbeatAccumulator < 0.1 then
            return
        end
        local step = heartbeatAccumulator
        heartbeatAccumulator = 0
        for _, enemy in pairs(enemies) do
            stepEnemy(enemy, step)
        end
    end)
end

function EnemyService.Spawn(enemyType, roomIndex, position, difficultyScale)
    local base = ctx.Config.Enemies[enemyType]
    assert(base, "Unknown enemy type: " .. tostring(enemyType))

    nextEnemyId += 1
    local model = Instance.new("Model")
    model.Name = string.format("%s_%d", enemyType, nextEnemyId)

    local root = Instance.new("Part")
    root.Name = "Root"
    root.Size = Vector3.new(base.Radius * 1.5, base.Radius * 2, base.Radius * 1.5)
    root.Transparency = 1
    root.Anchored = true
    root.CanCollide = true
    root.CanTouch = false
    root.CFrame = CFrame.new(position)
    root.Parent = model
    model.PrimaryPart = root

    local enemy = {
        Id = nextEnemyId,
        Type = enemyType,
        Data = base,
        Model = model,
        Root = root,
        RoomIndex = roomIndex,
        MaxHealth = math.floor(base.Health * difficultyScale + 0.5),
        Health = math.floor(base.Health * difficultyScale + 0.5),
        Damage = math.floor(base.Damage * (0.88 + difficultyScale * 0.12) + 0.5),
        Speed = base.Speed,
        AttackRange = base.AttackRange,
        AttackCooldown = base.AttackCooldown,
        LastAttack = 0,
        LastPulse = os.clock(),
        Alive = true,
    }

    local desiredSize = base.Radius * (base.Boss and 3.2 or base.Elite and 2.7 or 2.3)
    if not attachImportedVisual(model, root, desiredSize, nextEnemyId) then
        fallbackVisual(model, root, enemyType, base.Radius)
    end
    createHealthBar(root, enemy)

    local world = Workspace:FindFirstChild("VaultfallWorld")
    local container = world and world:FindFirstChild("Enemies")
    if not container and world then
        container = Instance.new("Folder")
        container.Name = "Enemies"
        container.Parent = world
    end
    model.Parent = container or Workspace
    enemies[enemy.Id] = enemy
    return enemy
end

function EnemyService.GetAll()
    return enemies
end

function EnemyService.GetInRange(position, range, facing, coneDot, roomIndex)
    local result = {}
    local flatFacing = Vector3.new(facing.X, 0, facing.Z)
    if flatFacing.Magnitude > 0.01 then
        flatFacing = flatFacing.Unit
    else
        flatFacing = Vector3.new(0, 0, -1)
    end

    for _, enemy in pairs(enemies) do
        if enemy.Alive and enemy.RoomIndex == roomIndex then
            local offset = enemy.Root.Position - position
            local flat = Vector3.new(offset.X, 0, offset.Z)
            local distance = flat.Magnitude
            if distance <= range + enemy.Data.Radius then
                local dot = 1
                if distance > 0.01 then
                    dot = flatFacing:Dot(flat.Unit)
                end
                if dot >= coneDot then
                    table.insert(result, enemy)
                end
            end
        end
    end
    table.sort(result, function(a, b)
        return (a.Root.Position - position).Magnitude < (b.Root.Position - position).Magnitude
    end)
    return result
end

function EnemyService.Damage(enemy, amount, attacker)
    if not enemy or not enemy.Alive then
        return false
    end

    enemy.Health = math.max(0, enemy.Health - math.max(0, amount))
    updateHealth(enemy)

    if enemy.Health > 0 then
        return false
    end

    enemy.Alive = false
    enemies[enemy.Id] = nil
    enemy.Root.CanCollide = false

    if ctx.Run and ctx.Run.OnEnemyDied then
        ctx.Run.OnEnemyDied(enemy, attacker)
    end

    task.delay(0.35, function()
        if enemy.Model then
            enemy.Model:Destroy()
        end
    end)
    return true
end

function EnemyService.ClearAll()
    for id, enemy in pairs(enemies) do
        enemy.Alive = false
        if enemy.Model then
            enemy.Model:Destroy()
        end
        enemies[id] = nil
    end
end

return EnemyService