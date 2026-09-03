-- BREACH PROTOCOL enemy threat presentation
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "EnemyThreatFeedback"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 72
gui.Parent = player:WaitForChild("PlayerGui")

local damageFlash = Instance.new("Frame")
damageFlash.Size = UDim2.fromScale(1, 1)
damageFlash.BackgroundColor3 = Color3.fromRGB(170, 16, 24)
damageFlash.BackgroundTransparency = 1
damageFlash.BorderSizePixel = 0
damageFlash.Parent = gui

local warning = Instance.new("TextLabel")
warning.AnchorPoint = Vector2.new(0.5, 0)
warning.Position = UDim2.fromScale(0.5, 0.105)
warning.Size = UDim2.fromOffset(420, 36)
warning.BackgroundTransparency = 1
warning.Font = Enum.Font.GothamBold
warning.TextSize = 15
warning.TextColor3 = Color3.new(1, 1, 1)
warning.TextStrokeTransparency = 0.42
warning.TextTransparency = 1
warning.Parent = gui

local bloom = Lighting:FindFirstChild("VaultfallImpactBloom") or Instance.new("BloomEffect")
bloom.Name = "VaultfallImpactBloom"
bloom.Intensity = 0
bloom.Size = 18
bloom.Threshold = 1
bloom.Parent = Lighting

local profiles = {
    Elite = { Color3.fromRGB(199, 115, 255), 2.4 },
    Huntsman = { Color3.fromRGB(255, 126, 82), 3.2 },
    Bulwark = { Color3.fromRGB(255, 198, 83), 1.7 },
    Reaper = { Color3.fromRGB(218, 92, 255), 4.0 },
    VaultWarden = { Color3.fromRGB(255, 79, 94), 1.35 },
}
local threats = {}

local function prefix(name)
    return string.match(name, "^([^_]+)") or name
end

local function warn(text, color)
    warning.Text = text
    warning.TextColor3 = color
    warning.TextTransparency = 0
    warning.Position = UDim2.fromScale(0.5, 0.095)
    TweenService:Create(warning, TweenInfo.new(0.12), { Position = UDim2.fromScale(0.5, 0.112) }):Play()
    task.delay(0.58, function()
        TweenService:Create(warning, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
    end)
end

local function cameraPulse(amount)
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local base = camera.FieldOfView
    TweenService:Create(camera, TweenInfo.new(0.07), { FieldOfView = base + amount }):Play()
    task.delay(0.08, function()
        if Workspace.CurrentCamera == camera then
            TweenService:Create(camera, TweenInfo.new(0.16), { FieldOfView = base }):Play()
        end
    end)
end

local function bindThreat(model)
    if threats[model] then return end
    local root = model:FindFirstChild("Root")
    local profile = profiles[prefix(model.Name)]
    if not root or not root:IsA("BasePart") or not profile then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ThreatOutline"
    highlight.Adornee = model
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillColor = profile[1]
    highlight.OutlineColor = profile[1]:Lerp(Color3.new(1, 1, 1), 0.32)
    highlight.FillTransparency = 0.9
    highlight.OutlineTransparency = 0.15
    highlight.Parent = model

    local light = Instance.new("PointLight")
    light.Name = "ThreatGlow"
    light.Color = profile[1]
    light.Brightness = prefix(model.Name) == "VaultWarden" and 2.1 or 1.2
    light.Range = prefix(model.Name) == "VaultWarden" and 18 or 13
    light.Shadows = false
    light.Parent = root

    threats[model] = { highlight = highlight, light = light, speed = profile[2], phase = math.random() * 6.28 }
end

local function addProjectileTrail(part)
    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, 0.24, 0)
    a0.Parent = part
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -0.24, 0)
    a1.Parent = part
    local trail = Instance.new("Trail")
    trail.Attachment0 = a0
    trail.Attachment1 = a1
    trail.Lifetime = 0.16
    trail.FaceCamera = true
    trail.Color = ColorSequence.new(Color3.fromRGB(239, 193, 255), Color3.fromRGB(122, 71, 183))
    trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.08), NumberSequenceKeypoint.new(1, 1) })
    trail.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
    trail.Parent = part
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(194, 133, 255)
    light.Brightness = 1.6
    light.Range = 8
    light.Parent = part
end

local function localPart(name, size, cframe, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = Enum.Material.Neon
    part.Transparency = 0.2
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.CastShadow = false
    part.Parent = Workspace
    return part
end

local function enhanceTelegraph(part)
    if part.Name == "HVTTelegraph" then
        local spire = localPart("ThreatSpire", Vector3.new(0.25, 13, 0.25), CFrame.new(part.Position + Vector3.new(0, 5.5, 0)), part.Color)
        TweenService:Create(spire, TweenInfo.new(0.7), { Transparency = 0.78 }):Play()
        Debris:AddItem(spire, 1.05)
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root and (root.Position - part.Position).Magnitude <= 12 then warn("MOVE — IMPACT LOCK", part.Color) end
    elseif part.Name == "ReaperTelegraph" then
        local edge = localPart("ReaperEdge", Vector3.new(math.max(0.6, part.Size.X * 0.35), 0.28, part.Size.Z), part.CFrame * CFrame.new(0, 0.24, 0), Color3.fromRGB(245, 177, 255))
        TweenService:Create(edge, TweenInfo.new(0.72), { Transparency = 0.85, Size = Vector3.new(part.Size.X, 0.28, part.Size.Z) }):Play()
        Debris:AddItem(edge, 0.78)
        warn("CROSS EXECUTION — BREAK LINE", Color3.fromRGB(241, 166, 255))
    elseif part.Name == "WardenPulse" then
        cameraPulse(2.4)
        warn("WARDEN SHOCKWAVE — CLEAR THE RING", Color3.fromRGB(255, 111, 120))
        bloom.Intensity = 1.4
        TweenService:Create(bloom, TweenInfo.new(0.45), { Intensity = 0 }):Play()
    end
end

local function inspect(instance)
    if instance:IsA("Model") then
        task.defer(function()
            instance:WaitForChild("Root", 1)
            bindThreat(instance)
        end)
    elseif instance:IsA("BasePart") then
        if instance.Name == "EnemyBolt" then addProjectileTrail(instance) end
        if instance.Name == "HVTTelegraph" or instance.Name == "ReaperTelegraph" or instance.Name == "WardenPulse" then enhanceTelegraph(instance) end
    end
end

Workspace.DescendantAdded:Connect(inspect)
for _, instance in ipairs(Workspace:GetDescendants()) do inspect(instance) end

local healthConnection
local function bindCharacter(character)
    if healthConnection then healthConnection:Disconnect() end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    local previous = humanoid.Health
    healthConnection = humanoid.HealthChanged:Connect(function(health)
        if health < previous then
            local severity = math.clamp((previous - health) / 34, 0.2, 1)
            damageFlash.BackgroundTransparency = 0.92 - severity * 0.11
            bloom.Intensity = 0.8 + severity * 1.5
            cameraPulse(1 + severity * 2.2)
            TweenService:Create(damageFlash, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(bloom, TweenInfo.new(0.28), { Intensity = 0 }):Play()
        end
        previous = health
    end)
end
player.CharacterAdded:Connect(bindCharacter)
if player.Character then task.defer(bindCharacter, player.Character) end

RunService.RenderStepped:Connect(function()
    local now = os.clock()
    for model, entry in pairs(threats) do
        if not model.Parent then
            threats[model] = nil
        else
            local pulse = 0.5 + 0.5 * math.sin(now * entry.speed + entry.phase)
            if entry.highlight.Parent then entry.highlight.OutlineTransparency = 0.08 + 0.34 * (1 - pulse) end
            if entry.light.Parent then entry.light.Brightness = 0.8 + pulse * 1.5 end
        end
    end
end)
