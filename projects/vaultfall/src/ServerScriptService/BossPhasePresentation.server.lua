local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local tracked = {}
local scanAccumulator = 0

local PHASE_TWO = Color3.fromRGB(255, 126, 78)
local PHASE_THREE = Color3.fromRGB(255, 64, 112)

local function bossHealthFraction(model)
    local root = model:FindFirstChild("Root")
    local healthBar = root and root:FindFirstChild("HealthBar")
    local background = healthBar and healthBar:FindFirstChild("Background")
    local fill = background and background:FindFirstChild("Fill")
    if fill and fill:IsA("Frame") then
        return math.clamp(fill.Size.X.Scale, 0, 1)
    end
    return 1
end

local function makeDisc(parent, name, position, radius, color, transparency)
    local disc = Instance.new("Part")
    disc.Name = name
    disc.Shape = Enum.PartType.Cylinder
    disc.Size = Vector3.new(0.12, radius * 2, radius * 2)
    disc.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    disc.Anchored = true
    disc.CanCollide = false
    disc.CanTouch = false
    disc.CanQuery = false
    disc.CastShadow = false
    disc.Material = Enum.Material.Neon
    disc.Color = color
    disc.Transparency = transparency
    disc.Parent = parent
    return disc
end

local function makeRing(parent, name, position, radius, color, segmentCount)
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent

    local circumference = math.pi * 2 * radius
    local segmentLength = math.max(2.1, circumference / segmentCount * 0.68)
    for i = 1, segmentCount do
        local angle = ((i - 1) / segmentCount) * math.pi * 2
        local tangent = Vector3.new(-math.sin(angle), 0, math.cos(angle))
        local radial = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local center = position + radial * radius + Vector3.new(0, 0.08, 0)

        local segment = Instance.new("Part")
        segment.Name = "BoundarySegment"
        segment.Size = Vector3.new(segmentLength, 0.12, 0.3)
        segment.CFrame = CFrame.lookAt(center, center + tangent)
        segment.Anchored = true
        segment.CanCollide = false
        segment.CanTouch = false
        segment.CanQuery = false
        segment.CastShadow = false
        segment.Material = Enum.Material.Neon
        segment.Color = color
        segment.Transparency = 0.12
        segment.Parent = folder
    end

    return folder
end

local function fadeRing(folder, duration)
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") then
            TweenService:Create(child, TweenInfo.new(duration), { Transparency = 1 }):Play()
        end
    end
end

local function damagePlayersNear(position, radius, amount)
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and root and humanoid.Health > 0 then
            local delta = root.Position - position
            local flat = Vector2.new(delta.X, delta.Z)
            if flat.Magnitude <= radius then
                humanoid:TakeDamage(amount)
            end
        end
    end
end

local function pulseCore(root, color, scale)
    local light = Instance.new("PointLight")
    light.Name = "PhaseCoreLight"
    light.Color = color
    light.Range = 24
    light.Brightness = 4.2
    light.Parent = root

    local shell = Instance.new("Part")
    shell.Name = "PhaseCoreShell"
    shell.Shape = Enum.PartType.Ball
    shell.Size = Vector3.new(2.5, 2.5, 2.5)
    shell.CFrame = root.CFrame * CFrame.new(0, 3.2, 0)
    shell.Anchored = true
    shell.CanCollide = false
    shell.CanTouch = false
    shell.CanQuery = false
    shell.CastShadow = false
    shell.Material = Enum.Material.Neon
    shell.Color = color
    shell.Transparency = 0.52
    shell.Parent = Workspace

    TweenService:Create(shell, TweenInfo.new(0.72, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(scale, scale, scale),
        Transparency = 1,
    }):Play()
    TweenService:Create(light, TweenInfo.new(0.72), { Brightness = 0, Range = 32 }):Play()

    task.delay(0.8, function()
        if shell.Parent then shell:Destroy() end
        if light.Parent then light:Destroy() end
    end)
end

local function makePillars(position, color, count)
    local folder = Instance.new("Folder")
    folder.Name = "WardenPhasePillars"
    folder.Parent = Workspace

    for i = 1, count do
        local angle = ((i - 1) / count) * math.pi * 2
        local offset = Vector3.new(math.cos(angle), 0, math.sin(angle)) * 18
        local pillar = Instance.new("Part")
        pillar.Name = "PhasePillar"
        pillar.Size = Vector3.new(0.38, 0.8, 0.38)
        pillar.CFrame = CFrame.new(position + offset + Vector3.new(0, 3.5, 0))
        pillar.Anchored = true
        pillar.CanCollide = false
        pillar.CanTouch = false
        pillar.CanQuery = false
        pillar.CastShadow = false
        pillar.Material = Enum.Material.Neon
        pillar.Color = color
        pillar.Transparency = 0.42
        pillar.Parent = folder

        TweenService:Create(pillar, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.38, 9, 0.38),
            CFrame = CFrame.new(position + offset + Vector3.new(0, 6.8, 0)),
            Transparency = 0.58,
        }):Play()
        task.delay(0.62, function()
            if pillar.Parent then
                TweenService:Create(pillar, TweenInfo.new(0.26), { Transparency = 1 }):Play()
            end
        end)
    end

    task.delay(0.95, function()
        if folder.Parent then folder:Destroy() end
    end)
end

local function phaseTwoTransition(model)
    local root = model:FindFirstChild("Root")
    if not root then return end

    local position = root.Position - Vector3.new(0, 1.4, 0)
    pulseCore(root, PHASE_TWO, 8)
    makePillars(position, PHASE_TWO, 4)

    local fill = makeDisc(Workspace, "WardenContainmentFill", position, 4, PHASE_TWO, 0.82)
    local ring = makeRing(Workspace, "WardenContainmentBoundary", position, 18, PHASE_TWO, 16)
    TweenService:Create(fill, TweenInfo.new(1.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.12, 36, 36),
        Transparency = 0.91,
    }):Play()

    task.delay(1.05, function()
        if not model.Parent or not root.Parent then
            if fill.Parent then fill:Destroy() end
            if ring.Parent then ring:Destroy() end
            return
        end
        damagePlayersNear(root.Position, 18, 22)
        if fill.Parent then
            fill.Color = Color3.fromRGB(255, 78, 62)
            TweenService:Create(fill, TweenInfo.new(0.18), { Transparency = 1 }):Play()
        end
        if ring.Parent then
            for _, child in ipairs(ring:GetChildren()) do
                if child:IsA("BasePart") then
                    child.Color = Color3.fromRGB(255, 78, 62)
                end
            end
            fadeRing(ring, 0.22)
        end
        task.delay(0.25, function()
            if fill.Parent then fill:Destroy() end
            if ring.Parent then ring:Destroy() end
        end)
    end)
end

local function phaseThreeTransition(model)
    local root = model:FindFirstChild("Root")
    if not root then return end

    local position = root.Position - Vector3.new(0, 1.4, 0)
    pulseCore(root, PHASE_THREE, 10)
    makePillars(position, PHASE_THREE, 6)

    for wave = 1, 3 do
        task.delay((wave - 1) * 0.62, function()
            if not model.Parent or not root.Parent then return end
            local radius = 10 + wave * 7
            local fill = makeDisc(Workspace, "WardenMeltdownFill", position, radius, PHASE_THREE, 0.91)
            local ring = makeRing(Workspace, "WardenMeltdownBoundary", position, radius, PHASE_THREE, 14 + wave * 2)
            fill.Size = Vector3.new(0.12, 4, 4)
            TweenService:Create(fill, TweenInfo.new(0.58, Enum.EasingStyle.Linear), {
                Size = Vector3.new(0.12, radius * 2, radius * 2),
                Transparency = 0.95,
            }):Play()
            task.delay(0.58, function()
                if not model.Parent or not root.Parent then
                    if fill.Parent then fill:Destroy() end
                    if ring.Parent then ring:Destroy() end
                    return
                end
                damagePlayersNear(root.Position, radius, 10 + wave * 4)
                if fill.Parent then
                    fill.Color = Color3.fromRGB(255, 55, 85)
                    TweenService:Create(fill, TweenInfo.new(0.16), { Transparency = 1 }):Play()
                end
                if ring.Parent then
                    for _, child in ipairs(ring:GetChildren()) do
                        if child:IsA("BasePart") then
                            child.Color = Color3.fromRGB(255, 55, 85)
                        end
                    end
                    fadeRing(ring, 0.18)
                end
                task.delay(0.2, function()
                    if fill.Parent then fill:Destroy() end
                    if ring.Parent then ring:Destroy() end
                end)
            end)
        end)
    end
end

local function updateBoss(model)
    local state = tracked[model]
    if not state then
        state = { Phase = 1 }
        tracked[model] = state
    end

    local health = bossHealthFraction(model)
    local nextPhase = health <= 0.33 and 3 or health <= 0.66 and 2 or 1
    if nextPhase <= state.Phase then return end

    state.Phase = nextPhase
    if nextPhase == 2 then
        phaseTwoTransition(model)
    elseif nextPhase == 3 then
        phaseThreeTransition(model)
    end
end

RunService.Heartbeat:Connect(function(dt)
    scanAccumulator += dt
    if scanAccumulator < 0.15 then return end
    scanAccumulator = 0

    local world = Workspace:FindFirstChild("VaultfallWorld")
    local enemies = world and world:FindFirstChild("Enemies")
    if not enemies then return end

    local alive = {}
    for _, model in ipairs(enemies:GetChildren()) do
        if model:IsA("Model") and string.match(model.Name, "^VaultWarden_%d+$") then
            alive[model] = true
            updateBoss(model)
        end
    end

    for model in pairs(tracked) do
        if not alive[model] or not model.Parent then
            tracked[model] = nil
        end
    end
end)
