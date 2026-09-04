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
    disc.Size = Vector3.new(0.18, radius * 2, radius * 2)
    disc.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    disc.Anchored = true
    disc.CanCollide = false
    disc.CanTouch = false
    disc.CanQuery = false
    disc.Material = Enum.Material.Neon
    disc.Color = color
    disc.Transparency = transparency
    disc.Parent = parent
    return disc
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
    light.Range = 30
    light.Brightness = 8
    light.Parent = root

    local shell = Instance.new("Part")
    shell.Name = "PhaseCoreShell"
    shell.Shape = Enum.PartType.Ball
    shell.Size = Vector3.new(3, 3, 3)
    shell.CFrame = root.CFrame * CFrame.new(0, 3.2, 0)
    shell.Anchored = true
    shell.CanCollide = false
    shell.CanTouch = false
    shell.CanQuery = false
    shell.Material = Enum.Material.Neon
    shell.Color = color
    shell.Transparency = 0.22
    shell.Parent = Workspace

    TweenService:Create(shell, TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(scale, scale, scale),
        Transparency = 1,
    }):Play()
    TweenService:Create(light, TweenInfo.new(0.85), { Brightness = 0, Range = 44 }):Play()

    task.delay(0.9, function()
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
        pillar.Size = Vector3.new(1.1, 1, 1.1)
        pillar.CFrame = CFrame.new(position + offset + Vector3.new(0, 5, 0))
        pillar.Anchored = true
        pillar.CanCollide = false
        pillar.CanTouch = false
        pillar.CanQuery = false
        pillar.Material = Enum.Material.Neon
        pillar.Color = color
        pillar.Transparency = 0.2
        pillar.Parent = folder

        TweenService:Create(pillar, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(1.1, 18, 1.1),
            CFrame = CFrame.new(position + offset + Vector3.new(0, 9, 0)),
        }):Play()
        task.delay(0.75, function()
            if pillar.Parent then
                TweenService:Create(pillar, TweenInfo.new(0.35), { Transparency = 1 }):Play()
            end
        end)
    end

    task.delay(1.2, function()
        if folder.Parent then folder:Destroy() end
    end)
end

local function phaseTwoTransition(model)
    local root = model:FindFirstChild("Root")
    if not root then return end

    local position = root.Position - Vector3.new(0, 1.4, 0)
    pulseCore(root, PHASE_TWO, 11)
    makePillars(position, PHASE_TWO, 6)

    local warning = makeDisc(Workspace, "WardenContainmentWarning", position, 4, PHASE_TWO, 0.18)
    TweenService:Create(warning, TweenInfo.new(1.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.18, 36, 36),
        Transparency = 0.42,
    }):Play()

    task.delay(1.05, function()
        if not model.Parent or not root.Parent then
            if warning.Parent then warning:Destroy() end
            return
        end
        damagePlayersNear(root.Position, 18, 22)
        if warning.Parent then
            warning.Color = Color3.fromRGB(255, 78, 62)
            TweenService:Create(warning, TweenInfo.new(0.22), { Transparency = 1 }):Play()
            task.delay(0.25, function()
                if warning.Parent then warning:Destroy() end
            end)
        end
    end)
end

local function phaseThreeTransition(model)
    local root = model:FindFirstChild("Root")
    if not root then return end

    local position = root.Position - Vector3.new(0, 1.4, 0)
    pulseCore(root, PHASE_THREE, 15)
    makePillars(position, PHASE_THREE, 10)

    for wave = 1, 3 do
        task.delay((wave - 1) * 0.62, function()
            if not model.Parent or not root.Parent then return end
            local radius = 10 + wave * 7
            local warning = makeDisc(Workspace, "WardenMeltdownRing", position, 2, PHASE_THREE, 0.16)
            TweenService:Create(warning, TweenInfo.new(0.58, Enum.EasingStyle.Linear), {
                Size = Vector3.new(0.18, radius * 2, radius * 2),
                Transparency = 0.36,
            }):Play()
            task.delay(0.58, function()
                if not model.Parent or not root.Parent then
                    if warning.Parent then warning:Destroy() end
                    return
                end
                damagePlayersNear(root.Position, radius, 10 + wave * 4)
                if warning.Parent then
                    warning.Color = Color3.fromRGB(255, 55, 85)
                    TweenService:Create(warning, TweenInfo.new(0.18), { Transparency = 1 }):Play()
                    task.delay(0.2, function()
                        if warning.Parent then warning:Destroy() end
                    end)
                end
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
