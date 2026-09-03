local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local tracked = {}
local projectileConnection
local worldConnection

local TYPE_PROFILE = {
    Shade = { bob = 0.16, stride = 10.5, lean = 8, attack = "lunge" },
    Archer = { bob = 0.10, stride = 7.5, lean = 5, attack = "recoil" },
    Brute = { bob = 0.12, stride = 6.2, lean = 10, attack = "slam" },
    Elite = { bob = 0.14, stride = 8.0, lean = 7, attack = "slam" },
    VaultWarden = { bob = 0.09, stride = 4.5, lean = 4, attack = "slam" },
}

local function cleanClone(part)
    local clone = part:Clone()
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript")
            or descendant:IsA("Constraint") or descendant:IsA("JointInstance") then
            descendant:Destroy()
        end
    end
    clone.Anchored = true
    clone.CanCollide = false
    clone.CanQuery = false
    clone.CanTouch = false
    clone.CastShadow = part.CastShadow
    return clone
end

local function enemyTypeFromName(name)
    local prefix = string.match(name, "^([^_]+)")
    return prefix or "Shade"
end

local function getProfile(enemyType)
    return TYPE_PROFILE[enemyType] or { bob = 0.12, stride = 7.5, lean = 6, attack = "lunge" }
end

local function findHealthFill(model)
    local healthBar = model:FindFirstChild("HealthBar", true)
    local background = healthBar and healthBar:FindFirstChild("Background")
    local fill = background and background:FindFirstChild("Fill")
    return fill
end

local function makePresentation(serverModel)
    if tracked[serverModel] then
        return
    end

    local root = serverModel:FindFirstChild("Root")
    if not root or not root:IsA("BasePart") then
        return
    end

    local visual = Instance.new("Model")
    visual.Name = serverModel.Name .. "_LocalPresentation"

    local parts = {}
    for _, descendant in ipairs(serverModel:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant ~= root and not descendant:IsDescendantOf(root) then
            local isProjectile = descendant.Name == "EnemyBolt" or descendant.Name == "WardenPulse"
            if not isProjectile then
                local relative = root.CFrame:ToObjectSpace(descendant.CFrame)
                local clone = cleanClone(descendant)
                clone.CFrame = descendant.CFrame
                clone.Parent = visual
                table.insert(parts, { clone = clone, source = descendant, relative = relative })
                descendant.LocalTransparencyModifier = 1
            end
        end
    end

    if #parts == 0 then
        visual:Destroy()
        return
    end

    visual.Parent = Workspace

    local healthFill = findHealthFill(serverModel)
    local initialHealthScale = healthFill and healthFill.Size.X.Scale or 1
    local enemyType = enemyTypeFromName(serverModel.Name)
    local profile = getProfile(enemyType)

    tracked[serverModel] = {
        model = serverModel,
        root = root,
        visual = visual,
        parts = parts,
        enemyType = enemyType,
        profile = profile,
        lastRootCFrame = root.CFrame,
        moveSpeed = 0,
        moveBlend = 0,
        phase = math.random() * math.pi * 2,
        attackTime = -10,
        attackKind = profile.attack,
        hitTime = -10,
        healthFill = healthFill,
        healthScale = initialHealthScale,
        deathStarted = false,
        lastNearAttack = -10,
    }
end

local function restoreAndDestroy(entry)
    for _, info in ipairs(entry.parts) do
        if info.source and info.source.Parent then
            info.source.LocalTransparencyModifier = 0
        end
    end
    if entry.visual then
        entry.visual:Destroy()
    end
end

local function getNearestPlayerDistance(position)
    local best = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and humanoid.Health > 0 and root then
            best = math.min(best, (root.Position - position).Magnitude)
        end
    end
    return best
end

local function flashHit(entry)
    entry.hitTime = os.clock()
    for _, info in ipairs(entry.parts) do
        if info.clone:IsA("BasePart") then
            info.clone:SetAttribute("PreHitMaterial", info.clone.Material.Name)
            info.clone.Material = Enum.Material.Neon
        end
    end
    task.delay(0.055, function()
        if not tracked[entry.model] then
            return
        end
        for _, info in ipairs(entry.parts) do
            if info.clone and info.clone.Parent then
                local materialName = info.clone:GetAttribute("PreHitMaterial")
                if materialName and Enum.Material[materialName] then
                    info.clone.Material = Enum.Material[materialName]
                end
            end
        end
    end)
end

local function beginDeath(entry)
    if entry.deathStarted then
        return
    end
    entry.deathStarted = true
    local deathOrigin = entry.root and entry.root.CFrame or entry.lastRootCFrame
    local direction = CFrame.Angles(math.rad(-72), 0, math.rad(18))
    for _, info in ipairs(entry.parts) do
        if info.source and info.source.Parent then
            info.source.LocalTransparencyModifier = 1
        end
        local clone = info.clone
        if clone and clone.Parent then
            local goal = deathOrigin * direction * CFrame.new(0, -1.2, 0) * info.relative
            TweenService:Create(clone, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                CFrame = goal,
                Transparency = math.max(clone.Transparency, 0.45),
            }):Play()
        end
    end
    task.delay(0.34, function()
        if tracked[entry.model] == entry then
            tracked[entry.model] = nil
        end
        if entry.visual then
            entry.visual:Destroy()
        end
    end)
end

local function attackTransform(entry, now)
    local elapsed = now - entry.attackTime
    if elapsed < 0 or elapsed > 0.42 then
        return CFrame.identity
    end

    local t = elapsed / 0.42
    local pulse = math.sin(t * math.pi)
    if entry.attackKind == "recoil" then
        return CFrame.new(0, 0.08 * pulse, 0.38 * pulse) * CFrame.Angles(math.rad(-12 * pulse), 0, 0)
    elseif entry.attackKind == "slam" then
        local wind = math.sin(math.min(t * 1.45, 1) * math.pi)
        return CFrame.new(0, 0.3 * wind - 0.2 * pulse, -0.42 * pulse) * CFrame.Angles(math.rad(18 * wind - 28 * pulse), 0, 0)
    end
    return CFrame.new(0, 0.08 * pulse, -0.65 * pulse) * CFrame.Angles(math.rad(15 * pulse), 0, 0)
end

local function hitTransform(entry, now)
    local elapsed = now - entry.hitTime
    if elapsed < 0 or elapsed > 0.18 then
        return CFrame.identity
    end
    local t = elapsed / 0.18
    local kick = math.sin(t * math.pi)
    local side = (entry.model:GetDebugId():byte(-1) or 1) % 2 == 0 and 1 or -1
    return CFrame.new(0.12 * side * kick, 0, 0.28 * kick) * CFrame.Angles(0, 0, math.rad(9 * side * kick))
end

local function updateEntry(entry, dt, now)
    local root = entry.root
    if not root or not root.Parent or not entry.model.Parent then
        beginDeath(entry)
        return
    end

    local current = root.CFrame
    local distance = (current.Position - entry.lastRootCFrame.Position).Magnitude
    local speed = distance / math.max(dt, 1 / 240)
    entry.moveSpeed = entry.moveSpeed + (speed - entry.moveSpeed) * math.clamp(dt * 12, 0, 1)
    local targetBlend = math.clamp(entry.moveSpeed / 7, 0, 1)
    entry.moveBlend = entry.moveBlend + (targetBlend - entry.moveBlend) * math.clamp(dt * 10, 0, 1)

    local healthFill = entry.healthFill
    if healthFill and healthFill.Parent then
        local scale = healthFill.Size.X.Scale
        if scale < entry.healthScale - 0.002 then
            entry.healthScale = scale
            flashHit(entry)
        else
            entry.healthScale = scale
        end
    end

    if entry.moveBlend < 0.14 and now - entry.attackTime > 0.55 then
        local near = getNearestPlayerDistance(current.Position)
        local threshold = entry.enemyType == "VaultWarden" and 11 or entry.enemyType == "Archer" and 26 or 6.5
        if near <= threshold and now - entry.lastNearAttack > 1.15 then
            entry.lastNearAttack = now
            entry.attackTime = now
        end
    end

    local profile = entry.profile
    local strideTime = now * profile.stride + entry.phase
    local bob = math.abs(math.sin(strideTime)) * profile.bob * entry.moveBlend
    local sway = math.sin(strideTime * 0.5) * math.rad(profile.lean) * entry.moveBlend
    local forwardLean = math.rad(-5) * entry.moveBlend
    local locomotion = CFrame.new(0, bob, 0) * CFrame.Angles(forwardLean, 0, sway)
    local pose = locomotion * attackTransform(entry, now) * hitTransform(entry, now)
    local visualRoot = current * pose

    for _, info in ipairs(entry.parts) do
        if info.clone and info.clone.Parent then
            info.clone.CFrame = visualRoot * info.relative
        end
    end
    entry.lastRootCFrame = current
end

local function noteRangedAttack(projectile)
    if projectile.Name ~= "EnemyBolt" then
        return
    end
    local position = projectile.Position
    local bestEntry
    local bestDistance = 12
    for _, entry in pairs(tracked) do
        if entry.root and entry.root.Parent then
            local distance = (entry.root.Position - position).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                bestEntry = entry
            end
        end
    end
    if bestEntry then
        bestEntry.attackKind = "recoil"
        bestEntry.attackTime = os.clock()
    end
end

local function bindEnemiesFolder(folder)
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") then
            task.defer(makePresentation, child)
        end
    end

    folder.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            task.defer(function()
                child:WaitForChild("Root", 2)
                makePresentation(child)
            end)
        end
    end)
end

local function connectWorld(world)
    local enemiesFolder = world:FindFirstChild("Enemies")
    if enemiesFolder then
        bindEnemiesFolder(enemiesFolder)
    end
    world.ChildAdded:Connect(function(child)
        if child.Name == "Enemies" and child:IsA("Folder") then
            bindEnemiesFolder(child)
        end
    end)
end

local world = Workspace:FindFirstChild("VaultfallWorld")
if world then
    connectWorld(world)
end
worldConnection = Workspace.ChildAdded:Connect(function(child)
    if child.Name == "VaultfallWorld" then
        connectWorld(child)
    end
end)

projectileConnection = Workspace.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") then
        noteRangedAttack(child)
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local now = os.clock()
    for model, entry in pairs(tracked) do
        if model.Parent == nil and not entry.deathStarted then
            beginDeath(entry)
        elseif not entry.deathStarted then
            updateEntry(entry, dt, now)
        end
    end
end)

localPlayer.AncestryChanged:Connect(function(_, parent)
    if parent then
        return
    end
    if projectileConnection then
        projectileConnection:Disconnect()
    end
    if worldConnection then
        worldConnection:Disconnect()
    end
    for _, entry in pairs(tracked) do
        restoreAndDestroy(entry)
    end
    table.clear(tracked)
end)