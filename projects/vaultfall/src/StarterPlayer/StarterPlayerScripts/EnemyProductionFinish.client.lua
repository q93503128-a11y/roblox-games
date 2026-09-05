local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local TYPES = {
    Shade = { Accent = Color3.fromRGB(151, 113, 221), Label = "SHADE" },
    Archer = { Accent = Color3.fromRGB(87, 188, 151), Label = "ARCHER" },
    Brute = { Accent = Color3.fromRGB(224, 117, 72), Label = "BRUTE" },
    Elite = { Accent = Color3.fromRGB(222, 91, 176), Label = "ELITE" },
    Huntsman = { Accent = Color3.fromRGB(240, 171, 72), Label = "HUNTSMAN", HVT = true },
    Bulwark = { Accent = Color3.fromRGB(93, 166, 222), Label = "BULWARK", HVT = true },
    Reaper = { Accent = Color3.fromRGB(225, 79, 101), Label = "REAPER", HVT = true },
    VaultWarden = { Accent = Color3.fromRGB(242, 77, 91), Label = "VAULT WARDEN", Boss = true },
}

local tracked = {}

local function enemyTypeFromModel(model)
    for enemyType in pairs(TYPES) do
        if string.sub(model.Name, 1, #enemyType + 1) == enemyType .. "_" then
            return enemyType
        end
    end
    return nil
end

local function weldVisual(root, name, size, offset, color, material, shape, transparency)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Material = material or Enum.Material.Metal
    part.Color = color
    part.Transparency = transparency or 0
    part.Anchored = false
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Massless = true
    if shape then
        part.Shape = shape
    end
    part.CFrame = root.CFrame * offset
    part.Parent = root.Parent

    local weld = Instance.new("WeldConstraint")
    weld.Name = name .. "Weld"
    weld.Part0 = root
    weld.Part1 = part
    weld.Parent = part
    return part
end

local function addHighlight(model, accent, boss)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ProductionThreatHighlight"
    highlight.FillColor = accent
    highlight.FillTransparency = boss and 0.83 or 0.91
    highlight.OutlineColor = accent:Lerp(Color3.new(1, 1, 1), 0.28)
    highlight.OutlineTransparency = boss and 0.08 or 0.24
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Adornee = model
    highlight.Parent = model
    return highlight
end

local function addThreatPlate(root, data)
    local gui = Instance.new("BillboardGui")
    gui.Name = "ProductionThreatPlate"
    gui.Size = data.Boss and UDim2.fromOffset(170, 28) or UDim2.fromOffset(112, 21)
    gui.StudsOffset = Vector3.new(0, data.Boss and 7.4 or data.HVT and 5.6 or 4.3, 0)
    gui.MaxDistance = data.Boss and 180 or 105
    gui.AlwaysOnTop = true
    gui.Parent = root

    local label = Instance.new("TextLabel")
    label.BackgroundColor3 = Color3.fromRGB(15, 18, 22)
    label.BackgroundTransparency = 0.18
    label.BorderSizePixel = 0
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = (data.Boss and "// " or data.HVT and "HVT // " or "") .. data.Label
    label.TextColor3 = data.Accent:Lerp(Color3.new(1, 1, 1), 0.34)
    label.TextSize = data.Boss and 15 or 11
    label.TextStrokeTransparency = 0.75
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = label

    local stroke = Instance.new("UIStroke")
    stroke.Color = data.Accent
    stroke.Transparency = 0.26
    stroke.Thickness = 1
    stroke.Parent = label
end

local function decorateShade(root, accent, radius)
    for _, side in ipairs({ -1, 1 }) do
        weldVisual(root, "ShadeBlade", Vector3.new(0.18, radius * 1.55, radius * 0.48),
            CFrame.new(side * radius * 0.94, radius * 0.42, radius * 0.22) * CFrame.Angles(0, 0, math.rad(side * 28)),
            accent:Lerp(Color3.new(0, 0, 0), 0.48), Enum.Material.Metal)
    end
end

local function decorateArcher(root, accent, radius)
    weldVisual(root, "ArcherSensor", Vector3.new(radius * 0.14, radius * 1.45, radius * 0.14),
        CFrame.new(0, radius * 1.86, radius * 0.08) * CFrame.Angles(math.rad(-12), 0, 0), accent, Enum.Material.Neon, nil, 0.08)
    for _, side in ipairs({ -1, 1 }) do
        weldVisual(root, "ArcherFin", Vector3.new(radius * 0.12, radius * 0.72, radius * 0.85),
            CFrame.new(side * radius * 0.72, radius * 0.72, radius * 0.28) * CFrame.Angles(0, math.rad(side * 18), math.rad(side * 18)),
            accent:Lerp(Color3.new(0, 0, 0), 0.38), Enum.Material.Metal)
    end
end

local function decorateBrute(root, accent, radius)
    for _, side in ipairs({ -1, 1 }) do
        weldVisual(root, "BruteShoulder", Vector3.new(radius * 0.92, radius * 0.42, radius * 1.02),
            CFrame.new(side * radius * 0.94, radius * 0.72, 0) * CFrame.Angles(0, 0, math.rad(side * 9)),
            accent:Lerp(Color3.new(0, 0, 0), 0.44), Enum.Material.DiamondPlate)
    end
    weldVisual(root, "BruteChestBar", Vector3.new(radius * 1.46, radius * 0.18, radius * 0.18),
        CFrame.new(0, radius * 0.42, -radius * 0.72), accent, Enum.Material.Neon, nil, 0.08)
end

local function decorateElite(root, accent, radius)
    for i = 0, 3 do
        local angle = (math.pi * 2 / 4) * i
        local x = math.cos(angle) * radius * 0.82
        local z = math.sin(angle) * radius * 0.82
        weldVisual(root, "EliteCrownSpike", Vector3.new(radius * 0.18, radius * 1.02, radius * 0.18),
            CFrame.new(x, radius * 1.44, z) * CFrame.Angles(math.rad(-18), -angle, 0), accent, Enum.Material.Neon, nil, 0.06)
    end
end

local function decorateHVT(root, enemyType, accent, radius)
    if enemyType == "Huntsman" then
        weldVisual(root, "HuntsmanScope", Vector3.new(radius * 0.25, radius * 0.25, radius * 1.35),
            CFrame.new(radius * 0.52, radius * 1.02, -radius * 0.40) * CFrame.Angles(0, 0, math.rad(90)), accent, Enum.Material.Neon, Enum.PartType.Cylinder, 0.05)
        weldVisual(root, "HuntsmanBackRail", Vector3.new(radius * 0.22, radius * 0.22, radius * 1.75),
            CFrame.new(0, radius * 0.92, radius * 0.52), accent:Lerp(Color3.new(0, 0, 0), 0.38), Enum.Material.Metal)
    elseif enemyType == "Bulwark" then
        for _, side in ipairs({ -1, 1 }) do
            weldVisual(root, "BulwarkShield", Vector3.new(radius * 0.58, radius * 1.58, radius * 1.32),
                CFrame.new(side * radius * 1.02, radius * 0.22, -radius * 0.12) * CFrame.Angles(0, math.rad(side * 11), 0),
                accent:Lerp(Color3.new(0, 0, 0), 0.42), Enum.Material.DiamondPlate)
        end
        weldVisual(root, "BulwarkCore", Vector3.new(radius * 0.56, radius * 0.56, radius * 0.22),
            CFrame.new(0, radius * 0.34, -radius * 0.86), accent, Enum.Material.Neon, nil, 0.04)
    elseif enemyType == "Reaper" then
        for _, side in ipairs({ -1, 1 }) do
            weldVisual(root, "ReaperBlade", Vector3.new(radius * 0.16, radius * 2.05, radius * 0.56),
                CFrame.new(side * radius * 0.96, radius * 0.25, radius * 0.18) * CFrame.Angles(0, 0, math.rad(side * 32)), accent, Enum.Material.Neon, nil, 0.08)
        end
    end
end

local function decorateBoss(root, accent, radius)
    for i = 0, 5 do
        local angle = (math.pi * 2 / 6) * i
        local x = math.cos(angle) * radius * 1.13
        local z = math.sin(angle) * radius * 1.13
        weldVisual(root, "WardenSpine", Vector3.new(radius * 0.22, radius * 1.38, radius * 0.22),
            CFrame.new(x, radius * 1.24, z) * CFrame.Angles(math.rad(-22), -angle, 0), accent, Enum.Material.Neon, nil, 0.05)
    end
    weldVisual(root, "WardenCore", Vector3.new(radius * 0.78, radius * 0.78, radius * 0.28),
        CFrame.new(0, radius * 0.42, -radius * 0.91), accent, Enum.Material.Neon, nil, 0.02)
end

local function decorate(model, enemyType)
    if tracked[model] or model:FindFirstChild("ProductionThreatHighlight") then
        return
    end
    local root = model:FindFirstChild("Root")
    if not root or not root:IsA("BasePart") then
        return
    end

    local data = TYPES[enemyType]
    local radius = math.max(1.6, root.Size.X / 1.5)
    addHighlight(model, data.Accent, data.Boss)
    addThreatPlate(root, data)

    if enemyType == "Shade" then
        decorateShade(root, data.Accent, radius)
    elseif enemyType == "Archer" then
        decorateArcher(root, data.Accent, radius)
    elseif enemyType == "Brute" then
        decorateBrute(root, data.Accent, radius)
    elseif enemyType == "Elite" then
        decorateElite(root, data.Accent, radius)
    elseif data.HVT then
        decorateHVT(root, enemyType, data.Accent, radius)
    elseif data.Boss then
        decorateBoss(root, data.Accent, radius)
    end

    tracked[model] = {
        Root = root,
        Data = data,
        Phase = math.random() * math.pi * 2,
    }
end

local function scan(instance)
    if not instance:IsA("Model") then
        return
    end
    local enemyType = enemyTypeFromModel(instance)
    if enemyType then
        task.defer(decorate, instance, enemyType)
    end
end

for _, instance in ipairs(Workspace:GetDescendants()) do
    scan(instance)
end
Workspace.DescendantAdded:Connect(scan)

RunService.RenderStepped:Connect(function()
    local now = os.clock()
    for model, state in pairs(tracked) do
        if not model.Parent or not state.Root.Parent then
            tracked[model] = nil
        else
            local highlight = model:FindFirstChild("ProductionThreatHighlight")
            if highlight then
                local pulse = (math.sin(now * (state.Data.Boss and 3.2 or state.Data.HVT and 2.4 or 1.7) + state.Phase) + 1) * 0.5
                highlight.OutlineTransparency = state.Data.Boss and (0.03 + pulse * 0.10)
                    or state.Data.HVT and (0.12 + pulse * 0.13)
                    or (0.22 + pulse * 0.10)
            end
        end
    end
end)
