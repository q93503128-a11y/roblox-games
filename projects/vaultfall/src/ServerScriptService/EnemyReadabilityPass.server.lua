local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ACCENTS = {
    Shade = Color3.fromRGB(168, 142, 232),
    Archer = Color3.fromRGB(91, 211, 164),
    Brute = Color3.fromRGB(239, 132, 76),
    Elite = Color3.fromRGB(237, 101, 199),
    Huntsman = Color3.fromRGB(255, 142, 72),
    Bulwark = Color3.fromRGB(244, 196, 80),
    Reaper = Color3.fromRGB(210, 103, 244),
    VaultWarden = Color3.fromRGB(255, 78, 94),
}

local PRIORITY = {
    Elite = "ELITE",
    Huntsman = "HVT",
    Bulwark = "HVT",
    Reaper = "HVT",
    VaultWarden = "BOSS",
}

local tracked = {}

local function enemyTypeFromName(name)
    return string.match(name, "^([^_]+)")
end

local function rootFor(model)
    local root = model:FindFirstChild("Root")
    if root and root:IsA("BasePart") then
        return root
    end
    return nil
end

local function makeBadge(root, enemyType, accent)
    local role = PRIORITY[enemyType]
    if not role then
        return nil
    end

    local badge = Instance.new("BillboardGui")
    badge.Name = "ReadabilityBadge"
    badge.Size = UDim2.fromOffset(96, 20)
    badge.StudsOffset = Vector3.new(0, enemyType == "VaultWarden" and 14.5 or 10.5, 0)
    badge.AlwaysOnTop = true
    badge.MaxDistance = 145
    badge.Parent = root

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
    label.BackgroundTransparency = 0.18
    label.BorderSizePixel = 0
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = accent
    label.TextStrokeTransparency = 0.58
    label.Text = string.format("◆ %s", role)
    label.Parent = badge

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 3)
    corner.Parent = label

    local stroke = Instance.new("UIStroke")
    stroke.Color = accent
    stroke.Transparency = 0.25
    stroke.Thickness = 1
    stroke.Parent = label

    return badge
end

local function apply(model)
    if tracked[model] or not model:IsA("Model") then
        return
    end

    local enemyType = enemyTypeFromName(model.Name)
    local accent = ACCENTS[enemyType]
    local root = rootFor(model)
    if not accent or not root then
        return
    end

    local oldHighlight = model:FindFirstChild("ReadabilitySilhouette")
    if oldHighlight then
        oldHighlight:Destroy()
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ReadabilitySilhouette"
    highlight.Adornee = model
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.FillColor = accent
    highlight.OutlineColor = accent
    highlight.FillTransparency = 0.96
    if enemyType == "VaultWarden" then
        highlight.OutlineTransparency = 0.02
    elseif PRIORITY[enemyType] then
        highlight.OutlineTransparency = 0.12
    else
        highlight.OutlineTransparency = 0.34
    end
    highlight.Parent = model

    local light
    if PRIORITY[enemyType] then
        light = Instance.new("PointLight")
        light.Name = "ThreatRimLight"
        light.Color = accent
        light.Brightness = enemyType == "VaultWarden" and 0.85 or 0.48
        light.Range = enemyType == "VaultWarden" and 15 or 10
        light.Shadows = false
        light.Parent = root
    end

    local oldBadge = root:FindFirstChild("ReadabilityBadge")
    if oldBadge then
        oldBadge:Destroy()
    end
    local badge = makeBadge(root, enemyType, accent)

    tracked[model] = {
        Type = enemyType,
        Accent = accent,
        Highlight = highlight,
        Light = light,
        Badge = badge,
        Phase = tonumber(string.match(model.Name, "_(%d+)$")) or 0,
    }
end

local function watchContainer(container)
    for _, child in ipairs(container:GetChildren()) do
        apply(child)
    end
    container.ChildAdded:Connect(function(child)
        task.defer(apply, child)
    end)
end

local function findEnemyContainer()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    if not world then
        return nil
    end
    return world:FindFirstChild("Enemies")
end

local container = findEnemyContainer()
if container then
    watchContainer(container)
else
    task.spawn(function()
        local world = Workspace:WaitForChild("VaultfallWorld", 30)
        if not world then
            return
        end
        local enemies = world:WaitForChild("Enemies", 30)
        if enemies then
            watchContainer(enemies)
        end
    end)
end

local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
    accumulator += dt
    if accumulator < 1 / 20 then
        return
    end
    accumulator = 0

    local now = os.clock()
    for model, entry in pairs(tracked) do
        if not model.Parent or not entry.Highlight.Parent then
            tracked[model] = nil
        elseif PRIORITY[entry.Type] then
            local pulse = (math.sin(now * (entry.Type == "VaultWarden" and 3.1 or 4.0) + entry.Phase) + 1) * 0.5
            entry.Highlight.OutlineTransparency = entry.Type == "VaultWarden" and (0.02 + pulse * 0.07) or (0.10 + pulse * 0.10)
            if entry.Light then
                entry.Light.Brightness = (entry.Type == "VaultWarden" and 0.85 or 0.48) + pulse * 0.22
            end
            if entry.Badge then
                local label = entry.Badge:FindFirstChild("Label")
                if label and label:IsA("TextLabel") then
                    label.TextTransparency = pulse * 0.08
                end
            end
        end
    end
end)
