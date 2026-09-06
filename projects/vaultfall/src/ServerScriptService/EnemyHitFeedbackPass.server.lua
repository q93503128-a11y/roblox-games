local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local EnemyService = require(script.Parent.Services.EnemyService)

local tracked = {}
local accumulator = 0
local UPDATE_STEP = 1 / 24

local DEFAULT_HIT = Color3.fromRGB(238, 244, 255)
local BOSS_HIT = Color3.fromRGB(255, 112, 122)
local ELITE_HIT = Color3.fromRGB(245, 126, 226)

local function threatColor(enemy)
    if enemy.Data.Boss then
        return BOSS_HIT
    end
    if enemy.Data.Elite then
        return ELITE_HIT
    end
    return DEFAULT_HIT
end

local function flashHit(enemy)
    local model = enemy.Model
    if not model or not model.Parent then
        return
    end

    local existing = model:FindFirstChild("HitResponseHighlight")
    if existing then
        existing:Destroy()
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "HitResponseHighlight"
    highlight.Adornee = model
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillColor = threatColor(enemy)
    highlight.FillTransparency = 0.62
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.08
    highlight.Parent = model

    TweenService:Create(highlight, TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        FillTransparency = 1,
        OutlineTransparency = 1,
    }):Play()

    task.delay(0.13, function()
        if highlight.Parent then
            highlight:Destroy()
        end
    end)
end

local function deathBurst(state)
    local model = state.Model
    local root = model and model:FindFirstChild("Root")
    if not model or not model.Parent or not root or not root:IsA("BasePart") then
        return
    end

    local color = state.Color

    local highlight = Instance.new("Highlight")
    highlight.Name = "DeathResponseHighlight"
    highlight.Adornee = model
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillColor = color
    highlight.FillTransparency = 0.2
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0.02
    highlight.Parent = model

    TweenService:Create(highlight, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        FillTransparency = 1,
        OutlineTransparency = 1,
    }):Play()

    local ring = Instance.new("Part")
    ring.Name = "EnemyDeathPulse"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.08, 1.4, 1.4)
    ring.CFrame = CFrame.new(root.Position - Vector3.new(0, math.max(0.8, root.Size.Y * 0.45), 0)) * CFrame.Angles(0, 0, math.rad(90))
    ring.Anchored = true
    ring.CanCollide = false
    ring.CanTouch = false
    ring.CanQuery = false
    ring.Material = Enum.Material.Neon
    ring.Color = color
    ring.Transparency = 0.34
    ring.Parent = Workspace

    local diameter = math.clamp(math.max(root.Size.X, root.Size.Z) * 3.4, 5.5, 12)
    TweenService:Create(ring, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.08, diameter, diameter),
        Transparency = 1,
    }):Play()

    local light = Instance.new("PointLight")
    light.Name = "EnemyDeathLight"
    light.Color = color
    light.Brightness = state.Boss and 3.2 or state.Elite and 2.3 or 1.35
    light.Range = state.Boss and 18 or state.Elite and 12 or 8
    light.Shadows = false
    light.Parent = root

    TweenService:Create(light, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Brightness = 0,
        Range = light.Range * 1.25,
    }):Play()

    task.delay(0.32, function()
        if ring.Parent then
            ring:Destroy()
        end
        if highlight.Parent then
            highlight:Destroy()
        end
        if light.Parent then
            light:Destroy()
        end
    end)
end

local function sampleEnemies()
    local alive = {}

    for id, enemy in pairs(EnemyService.GetAll()) do
        alive[id] = true
        local state = tracked[id]
        if not state then
            tracked[id] = {
                Health = enemy.Health,
                Model = enemy.Model,
                Color = threatColor(enemy),
                Elite = enemy.Data.Elite == true,
                Boss = enemy.Data.Boss == true,
            }
        else
            if enemy.Health < state.Health then
                flashHit(enemy)
            end
            state.Health = enemy.Health
            state.Model = enemy.Model
        end
    end

    for id, state in pairs(tracked) do
        if not alive[id] then
            deathBurst(state)
            tracked[id] = nil
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    accumulator += dt
    if accumulator < UPDATE_STEP then
        return
    end
    accumulator = 0
    sampleEnemies()
end)
