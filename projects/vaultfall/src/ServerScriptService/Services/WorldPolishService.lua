local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local WorldPolishService = {}
local ctx

local SAFEHOUSE_ORIGIN = Vector3.new(-220, 0, -120)
local ROOT_NAME = "VaultfallProductionPolish"

local function part(parent, name, size, cframe, material, color, transparency, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Material = material or Enum.Material.Metal
    p.Color = color or Color3.fromRGB(55, 61, 67)
    p.Transparency = transparency or 0
    p.CanCollide = collide ~= false
    p.CanTouch = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function neon(parent, name, size, cframe, color)
    local p = part(parent, name, size, cframe, Enum.Material.Neon, color, 0.08, false)
    return p
end

local function addPointLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness or 1.5
    light.Range = range or 24
    light.Shadows = true
    light.Parent = host
    return light
end

local function addSurfaceText(host, text, face, color)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "ProductionSign"
    gui.Face = face or Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.PixelsPerStud = 34
    gui.Parent = host

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextScaled = true
    label.TextColor3 = color or Color3.fromRGB(218, 232, 238)
    label.TextStrokeTransparency = 0.75
    label.Parent = gui
end

local function buildCrate(parent, position, scale)
    local s = scale or 1
    local base = part(parent, "CargoCrate", Vector3.new(8, 6, 8) * s, CFrame.new(position + Vector3.new(0, 3 * s, 0)), Enum.Material.Metal, Color3.fromRGB(64, 70, 72))
    for _, offset in ipairs({
        Vector3.new(0, 0, -4.1 * s),
        Vector3.new(0, 0, 4.1 * s),
        Vector3.new(-4.1 * s, 0, 0),
        Vector3.new(4.1 * s, 0, 0),
    }) do
        local size = math.abs(offset.X) > 0 and Vector3.new(0.45, 5.2, 6.8) * s or Vector3.new(6.8, 5.2, 0.45) * s
        part(parent, "CrateBrace", size, base.CFrame * CFrame.new(offset), Enum.Material.DiamondPlate, Color3.fromRGB(87, 93, 95), 0, false)
    end
    return base
end

local function buildPipeRun(parent, startPosition, length, horizontal)
    local color = Color3.fromRGB(72, 80, 85)
    if horizontal then
        local pipe = part(parent, "UtilityPipe", Vector3.new(length, 1.2, 1.2), CFrame.new(startPosition), Enum.Material.Metal, color, 0, false)
        pipe.Shape = Enum.PartType.Cylinder
        pipe.CFrame = CFrame.new(startPosition) * CFrame.Angles(0, 0, math.rad(90))
    else
        local pipe = part(parent, "UtilityPipe", Vector3.new(1.2, length, 1.2), CFrame.new(startPosition), Enum.Material.Metal, color, 0, false)
        pipe.Shape = Enum.PartType.Cylinder
    end
end

local function buildSafehouseRoof(parent)
    local origin = SAFEHOUSE_ORIGIN
    local roofColor = Color3.fromRGB(39, 43, 47)
    for x = -108, 108, 54 do
        for z = -88, 88, 44 do
            part(parent, "RoofPanel", Vector3.new(50, 1.2, 40), CFrame.new(origin + Vector3.new(x, 21.5, z)), Enum.Material.Metal, roofColor)
        end
    end

    for x = -104, 104, 52 do
        local lamp = neon(parent, "CeilingStrip", Vector3.new(26, 0.35, 1.1), CFrame.new(origin + Vector3.new(x, 20.7, 0)), Color3.fromRGB(92, 170, 186))
        addPointLight(lamp, Color3.fromRGB(117, 194, 210), 1.2, 30)
    end

    for z = -78, 78, 52 do
        local lamp = neon(parent, "CeilingStrip", Vector3.new(1.1, 0.35, 30), CFrame.new(origin + Vector3.new(0, 20.7, z)), Color3.fromRGB(92, 170, 186))
        addPointLight(lamp, Color3.fromRGB(117, 194, 210), 1, 26)
    end
end

local function buildCentralConcourse(parent)
    local origin = SAFEHOUSE_ORIGIN
    part(parent, "ConcourseDeck", Vector3.new(54, 1.2, 86), CFrame.new(origin + Vector3.new(0, 1.35, 5)), Enum.Material.DiamondPlate, Color3.fromRGB(48, 54, 59))

    for z = -32, 42, 18.5 do
        local marker = neon(parent, "DeckGuide", Vector3.new(2.4, 0.12, 10), CFrame.new(origin + Vector3.new(0, 2.02, z)), Color3.fromRGB(55, 142, 164))
        marker.Transparency = 0.18
    end

    local commandBase = part(parent, "CommandIsland", Vector3.new(36, 4, 22), CFrame.new(origin + Vector3.new(0, 3, -20)), Enum.Material.Metal, Color3.fromRGB(45, 50, 54))
    local commandGlass = part(parent, "CommandGlass", Vector3.new(31, 7, 0.7), CFrame.new(origin + Vector3.new(0, 8.5, -31.2)), Enum.Material.Glass, Color3.fromRGB(70, 109, 117), 0.35, false)
    addSurfaceText(commandGlass, "BREACH CONTROL  //  OPERATOR READY", Enum.NormalId.Front, Color3.fromRGB(159, 221, 231))

    for x = -12, 12, 8 do
        local console = part(parent, "CommandConsole", Vector3.new(6, 4, 3), commandBase.CFrame * CFrame.new(x, 4, 0) * CFrame.Angles(math.rad(-12), 0, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(24, 31, 34))
        local display = neon(parent, "ConsoleDisplay", Vector3.new(5.3, 2.8, 0.12), console.CFrame * CFrame.new(0, 0, -1.57), Color3.fromRGB(56, 145, 164))
        display.Transparency = 0.12
    end
end

local function buildMezzanine(parent)
    local origin = SAFEHOUSE_ORIGIN
    local deckColor = Color3.fromRGB(52, 57, 61)
    local railColor = Color3.fromRGB(85, 91, 94)

    part(parent, "MezzanineWest", Vector3.new(82, 1.4, 18), CFrame.new(origin + Vector3.new(-78, 11.5, 88)), Enum.Material.DiamondPlate, deckColor)
    part(parent, "MezzanineEast", Vector3.new(82, 1.4, 18), CFrame.new(origin + Vector3.new(78, 11.5, 88)), Enum.Material.DiamondPlate, deckColor)
    part(parent, "MezzanineBridge", Vector3.new(74, 1.4, 14), CFrame.new(origin + Vector3.new(0, 11.5, 88)), Enum.Material.DiamondPlate, deckColor)

    for x = -118, 118, 8 do
        part(parent, "UpperRail", Vector3.new(0.35, 3.2, 0.35), CFrame.new(origin + Vector3.new(x, 13.5, 79.5)), Enum.Material.Metal, railColor, 0, false)
    end
    part(parent, "UpperRailTop", Vector3.new(240, 0.35, 0.35), CFrame.new(origin + Vector3.new(0, 15, 79.5)), Enum.Material.Metal, railColor, 0, false)

    for _, x in ipairs({ -104, -88, 88, 104 }) do
        part(parent, "MezzanineSupport", Vector3.new(2, 11, 2), CFrame.new(origin + Vector3.new(x, 6, 88)), Enum.Material.Metal, Color3.fromRGB(68, 73, 77))
    end

    -- Broad ramps make the upper level usable without relying on generated stairs.
    local leftRamp = part(parent, "AccessRamp", Vector3.new(18, 1.4, 44), CFrame.new(origin + Vector3.new(-94, 6.1, 61)) * CFrame.Angles(math.rad(-14), 0, 0), Enum.Material.DiamondPlate, deckColor)
    local rightRamp = part(parent, "AccessRamp", Vector3.new(18, 1.4, 44), CFrame.new(origin + Vector3.new(94, 6.1, 61)) * CFrame.Angles(math.rad(-14), 0, 0), Enum.Material.DiamondPlate, deckColor)
    leftRamp.CanCollide = true
    rightRamp.CanCollide = true
end

local function buildDeploymentAirlock(parent)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(0, 0, -88)
    local wallColor = Color3.fromRGB(50, 55, 60)
    part(parent, "AirlockFloor", Vector3.new(48, 1, 34), CFrame.new(origin + Vector3.new(0, 0.7, 0)), Enum.Material.DiamondPlate, Color3.fromRGB(43, 47, 51))
    part(parent, "AirlockLeft", Vector3.new(5, 18, 34), CFrame.new(origin + Vector3.new(-24, 9, 0)), Enum.Material.Metal, wallColor)
    part(parent, "AirlockRight", Vector3.new(5, 18, 34), CFrame.new(origin + Vector3.new(24, 9, 0)), Enum.Material.Metal, wallColor)
    part(parent, "AirlockHeader", Vector3.new(53, 6, 5), CFrame.new(origin + Vector3.new(0, 16, -16)), Enum.Material.Metal, wallColor)
    local gate = part(parent, "DeploymentGate", Vector3.new(42, 13, 1.2), CFrame.new(origin + Vector3.new(0, 7, -16)), Enum.Material.Metal, Color3.fromRGB(66, 71, 76), 0, false)
    for x = -18, 18, 6 do
        neon(parent, "GateStripe", Vector3.new(0.45, 10, 0.2), gate.CFrame * CFrame.new(x, 0, -0.7), Color3.fromRGB(210, 117, 63))
    end
    addSurfaceText(gate, "DEPLOYMENT AIRLOCK", Enum.NormalId.Back, Color3.fromRGB(233, 198, 164))
end

local function buildEnvironmentalDressing(parent)
    local origin = SAFEHOUSE_ORIGIN
    local cratePositions = {
        Vector3.new(-112, 0, 52), Vector3.new(-103, 0, 60), Vector3.new(-114, 0, -10),
        Vector3.new(112, 0, 43), Vector3.new(103, 0, 52), Vector3.new(112, 0, -18),
        Vector3.new(-50, 0, 96), Vector3.new(52, 0, 96),
    }
    for index, offset in ipairs(cratePositions) do
        buildCrate(parent, origin + offset, index % 3 == 0 and 0.8 or 1)
    end

    for _, x in ipairs({ -124, 124 }) do
        for z = -74, 70, 36 do
            buildPipeRun(parent, origin + Vector3.new(x, 15, z), 30, false)
        end
    end

    for z = -68, 68, 34 do
        local bollard = part(parent, "PathBollard", Vector3.new(1.5, 4, 1.5), CFrame.new(origin + Vector3.new(-30, 2.5, z)), Enum.Material.Metal, Color3.fromRGB(73, 78, 82))
        neon(parent, "BollardLight", Vector3.new(1.8, 0.35, 1.8), bollard.CFrame * CFrame.new(0, 1.55, 0), Color3.fromRGB(85, 173, 189))
        local twin = bollard:Clone()
        twin.CFrame = CFrame.new(origin + Vector3.new(30, 2.5, z))
        twin.Parent = parent
    end
end

local function tuneLighting()
    Lighting.Brightness = 2
    Lighting.ClockTime = 2.5
    Lighting.EnvironmentDiffuseScale = 0.35
    Lighting.EnvironmentSpecularScale = 0.65
    Lighting.Ambient = Color3.fromRGB(36, 43, 48)
    Lighting.OutdoorAmbient = Color3.fromRGB(20, 25, 30)

    local atmosphere = Lighting:FindFirstChild("VaultfallAtmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Name = "VaultfallAtmosphere"
        atmosphere.Parent = Lighting
    end
    atmosphere.Density = 0.28
    atmosphere.Offset = 0.1
    atmosphere.Color = Color3.fromRGB(151, 171, 181)
    atmosphere.Decay = Color3.fromRGB(74, 92, 105)
    atmosphere.Glare = 0.05
    atmosphere.Haze = 1.2

    local bloom = Lighting:FindFirstChild("VaultfallBloom")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Name = "VaultfallBloom"
        bloom.Parent = Lighting
    end
    bloom.Intensity = 0.28
    bloom.Size = 28
    bloom.Threshold = 1.15

    local correction = Lighting:FindFirstChild("VaultfallColor")
    if not correction then
        correction = Instance.new("ColorCorrectionEffect")
        correction.Name = "VaultfallColor"
        correction.Parent = Lighting
    end
    correction.Brightness = -0.03
    correction.Contrast = 0.09
    correction.Saturation = -0.08
    correction.TintColor = Color3.fromRGB(218, 229, 235)
end

function WorldPolishService.Init(context)
    ctx = context
    assert(ctx, "WorldPolishService requires runtime context")
end

function WorldPolishService.Build()
    local old = Workspace:FindFirstChild(ROOT_NAME)
    if old then
        old:Destroy()
    end

    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = Workspace

    tuneLighting()
    buildSafehouseRoof(root)
    buildCentralConcourse(root)
    buildMezzanine(root)
    buildDeploymentAirlock(root)
    buildEnvironmentalDressing(root)

    root:SetAttribute("ProductionWorldDressing", true)
    root:SetAttribute("SelfContainedFallback", true)
    root:SetAttribute("BuildVersion", 1)
end

return WorldPolishService