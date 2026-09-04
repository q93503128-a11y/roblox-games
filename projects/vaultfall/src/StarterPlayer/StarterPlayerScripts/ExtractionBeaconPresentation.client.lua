local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local tracked = {}

local function makeRing(parent, diameter, y, transparency)
    local ring = Instance.new("Part")
    ring.Name = "ClientExtractionRing"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.14, diameter, diameter)
    ring.CFrame = parent.CFrame * CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(90))
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(95, 231, 205)
    ring.Transparency = transparency
    ring.Anchored = true
    ring.CanCollide = false
    ring.CanQuery = false
    ring.CanTouch = false
    ring.CastShadow = false
    ring.Parent = parent.Parent
    return ring
end

local function addLamp(model, offset)
    local pad = model:FindFirstChild("ExtractionPad")
    if not pad or not pad:IsA("BasePart") then
        return nil
    end

    local lamp = Instance.new("Part")
    lamp.Name = "ClientExtractionLamp"
    lamp.Size = Vector3.new(0.8, 0.35, 0.8)
    lamp.CFrame = pad.CFrame * CFrame.new(offset.X, 0.7, offset.Z)
    lamp.Material = Enum.Material.Neon
    lamp.Color = Color3.fromRGB(99, 231, 204)
    lamp.Anchored = true
    lamp.CanCollide = false
    lamp.CanQuery = false
    lamp.CanTouch = false
    lamp.CastShadow = false
    lamp.Parent = model

    local light = Instance.new("PointLight")
    light.Color = lamp.Color
    light.Range = 10
    light.Brightness = 1.1
    light.Shadows = false
    light.Parent = lamp
    return lamp
end

local function attach(model)
    if tracked[model] or not model:IsA("Model") or model.Name ~= "EmergencyExtraction" then
        return
    end

    local core = model:FindFirstChild("BeaconCore")
    local pad = model:FindFirstChild("ExtractionPad")
    if not core or not core:IsA("BasePart") or not pad or not pad:IsA("BasePart") then
        return
    end

    local data = {
        Time = 0,
        Core = core,
        Pad = pad,
        Rings = {},
        Lamps = {},
        Connections = {},
    }
    tracked[model] = data

    table.insert(data.Rings, makeRing(core, 7.5, -3.5, 0.26))
    table.insert(data.Rings, makeRing(core, 10.5, -3.35, 0.48))
    table.insert(data.Rings, makeRing(core, 13.5, -3.2, 0.7))

    for _, offset in ipairs({
        Vector3.new(-5.2, 0, -5.2),
        Vector3.new(5.2, 0, -5.2),
        Vector3.new(-5.2, 0, 5.2),
        Vector3.new(5.2, 0, 5.2),
    }) do
        local lamp = addLamp(model, offset)
        if lamp then
            table.insert(data.Lamps, lamp)
        end
    end

    local beam = Instance.new("Part")
    beam.Name = "ClientExtractionBeam"
    beam.Size = Vector3.new(1.35, 22, 1.35)
    beam.CFrame = core.CFrame * CFrame.new(0, 10.5, 0)
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(91, 224, 202)
    beam.Transparency = 0.82
    beam.Anchored = true
    beam.CanCollide = false
    beam.CanQuery = false
    beam.CanTouch = false
    beam.CastShadow = false
    beam.Parent = model
    data.Beam = beam

    local crown = Instance.new("Part")
    crown.Name = "ClientExtractionCrown"
    crown.Shape = Enum.PartType.Cylinder
    crown.Size = Vector3.new(0.3, 5.2, 5.2)
    crown.CFrame = core.CFrame * CFrame.new(0, 8.2, 0) * CFrame.Angles(0, 0, math.rad(90))
    crown.Material = Enum.Material.Neon
    crown.Color = Color3.fromRGB(105, 241, 212)
    crown.Transparency = 0.35
    crown.Anchored = true
    crown.CanCollide = false
    crown.CanQuery = false
    crown.CanTouch = false
    crown.CastShadow = false
    crown.Parent = model
    data.Crown = crown

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ClientExtractionCallout"
    billboard.Adornee = core
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.fromOffset(240, 70)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, 7.2, 0)
    billboard.MaxDistance = 90
    billboard.Parent = model

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Font = Enum.Font.GothamBlack
    title.Text = "EXTRACTION READY"
    title.TextSize = 17
    title.TextColor3 = Color3.fromRGB(116, 247, 219)
    title.TextStrokeTransparency = 0.45
    title.Parent = billboard

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(0, 28)
    sub.Size = UDim2.new(1, 0, 0, 34)
    sub.Font = Enum.Font.GothamMedium
    sub.Text = "HOLD TO SECURE FIELD BANK\nOR PUSH DEEPER"
    sub.TextSize = 10
    sub.TextColor3 = Color3.fromRGB(220, 235, 232)
    sub.TextStrokeTransparency = 0.55
    sub.Parent = billboard
    data.Billboard = billboard

    local highlight = Instance.new("Highlight")
    highlight.Name = "ClientExtractionHighlight"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(68, 190, 168)
    highlight.FillTransparency = 0.88
    highlight.OutlineColor = Color3.fromRGB(125, 246, 220)
    highlight.OutlineTransparency = 0.18
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
    data.Highlight = highlight

    local ancestry
    ancestry = model.AncestryChanged:Connect(function(_, parent)
        if parent ~= nil then
            return
        end
        if ancestry then
            ancestry:Disconnect()
        end
        tracked[model] = nil
    end)
    table.insert(data.Connections, ancestry)

    TweenService:Create(core, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = core.Size * 1.12,
    }):Play()
    task.delay(0.23, function()
        if core.Parent then
            TweenService:Create(core, TweenInfo.new(0.2), { Size = core.Size / 1.12 }):Play()
        end
    end)
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
    if descendant:IsA("Model") and descendant.Name == "EmergencyExtraction" then
        attach(descendant)
    end
end

Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("Model") and descendant.Name == "EmergencyExtraction" then
        task.defer(attach, descendant)
    end
end)

RunService.RenderStepped:Connect(function(dt)
    for model, data in pairs(tracked) do
        if not model.Parent or not data.Core.Parent then
            tracked[model] = nil
            continue
        end

        data.Time += dt
        local pulse = (math.sin(data.Time * 4.6) + 1) * 0.5
        local slowPulse = (math.sin(data.Time * 2.2) + 1) * 0.5

        data.Core.Transparency = 0.03 + (pulse * 0.12)
        if data.Beam and data.Beam.Parent then
            data.Beam.Transparency = 0.76 + (slowPulse * 0.14)
            data.Beam.CFrame = data.Core.CFrame * CFrame.new(0, 10.5, 0) * CFrame.Angles(0, data.Time * 0.18, 0)
        end
        if data.Crown and data.Crown.Parent then
            data.Crown.CFrame = data.Core.CFrame * CFrame.new(0, 8.2, 0) * CFrame.Angles(0, data.Time * 0.75, math.rad(90))
            data.Crown.Transparency = 0.25 + (pulse * 0.24)
        end
        if data.Highlight and data.Highlight.Parent then
            data.Highlight.OutlineTransparency = 0.12 + (pulse * 0.25)
        end

        for index, ring in ipairs(data.Rings) do
            if ring.Parent then
                local phase = data.Time * (0.32 + index * 0.08)
                ring.CFrame = data.Pad.CFrame * CFrame.new(0, 0.66 + index * 0.045, 0) * CFrame.Angles(0, phase, math.rad(90))
                ring.Transparency = math.clamp(0.18 + index * 0.17 + pulse * 0.16, 0, 0.9)
            end
        end

        for index, lamp in ipairs(data.Lamps) do
            if lamp.Parent then
                local lampPulse = (math.sin(data.Time * 7 + index * 1.4) + 1) * 0.5
                lamp.Transparency = 0.08 + lampPulse * 0.32
                local light = lamp:FindFirstChildOfClass("PointLight")
                if light then
                    light.Brightness = 0.7 + lampPulse * 1.35
                end
            end
        end
    end
end)
