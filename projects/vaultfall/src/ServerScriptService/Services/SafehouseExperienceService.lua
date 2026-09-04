local Workspace = game:GetService("Workspace")

local SafehouseExperienceService = {}
local ctx

local SAFEHOUSE_ORIGIN = Vector3.new(-220, 0, -120)
local ROOT_NAME = "VaultfallSafehouseExperience"

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

local function neon(parent, name, size, cframe, color, transparency)
    return part(parent, name, size, cframe, Enum.Material.Neon, color, transparency or 0.08, false)
end

local function surfaceText(host, text, face, color)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "SafehouseSign"
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
    label.TextColor3 = color or Color3.fromRGB(220, 231, 236)
    label.TextStrokeTransparency = 0.78
    label.Parent = gui
end

local function light(host, color, brightness, range)
    local point = Instance.new("PointLight")
    point.Color = color
    point.Brightness = brightness or 1
    point.Range = range or 20
    point.Shadows = true
    point.Parent = host
    return point
end

local function prompt(host, actionText, objectText, callback)
    local proximity = Instance.new("ProximityPrompt")
    proximity.ActionText = actionText
    proximity.ObjectText = objectText
    proximity.HoldDuration = 0.35
    proximity.MaxActivationDistance = 11
    proximity.RequiresLineOfSight = false
    proximity.Parent = host
    proximity.Triggered:Connect(callback)
    return proximity
end

local function buildLocker(parent, position, facing)
    local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(facing or 0), 0)
    local body = part(parent, "OperatorLocker", Vector3.new(5.5, 11, 3.8), cf * CFrame.new(0, 5.5, 0), Enum.Material.Metal, Color3.fromRGB(49, 55, 60))
    part(parent, "LockerDoorInset", Vector3.new(4.5, 9.2, 0.28), body.CFrame * CFrame.new(0, 0, -2.04), Enum.Material.DiamondPlate, Color3.fromRGB(65, 72, 77), 0, false)
    neon(parent, "LockerStatus", Vector3.new(2.8, 0.25, 0.18), body.CFrame * CFrame.new(0, 3.8, -2.23), Color3.fromRGB(67, 157, 175), 0.12)
    return body
end

local function buildRecoveredLootVault(parent)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(-42, 0, 82)
    local wallColor = Color3.fromRGB(47, 52, 56)
    local accent = Color3.fromRGB(202, 145, 65)

    part(parent, "LootVaultDeck", Vector3.new(62, 1.2, 42), CFrame.new(origin + Vector3.new(0, 1.25, 0)), Enum.Material.DiamondPlate, Color3.fromRGB(43, 48, 52))
    part(parent, "LootVaultBack", Vector3.new(62, 14, 2), CFrame.new(origin + Vector3.new(0, 7, 20)), Enum.Material.Metal, wallColor)
    part(parent, "LootVaultSide", Vector3.new(2, 14, 40), CFrame.new(origin + Vector3.new(-31, 7, 0)), Enum.Material.Metal, wallColor)

    local header = part(parent, "LootVaultHeader", Vector3.new(37, 4, 1), CFrame.new(origin + Vector3.new(0, 13, 18.8)), Enum.Material.Metal, Color3.fromRGB(34, 39, 43), 0, false)
    surfaceText(header, "RECOVERED ASSETS  //  FIELD STORAGE", Enum.NormalId.Front, Color3.fromRGB(235, 202, 145))

    local specimenColors = {
        Color3.fromRGB(73, 161, 178),
        Color3.fromRGB(151, 92, 184),
        Color3.fromRGB(210, 121, 68),
        Color3.fromRGB(95, 175, 118),
        Color3.fromRGB(202, 174, 72),
        Color3.fromRGB(177, 73, 85),
    }

    for index = 1, 6 do
        local column = (index - 1) % 3
        local row = math.floor((index - 1) / 3)
        local x = -17 + column * 17
        local z = 8 - row * 15
        local pedestal = part(parent, "SpecimenPedestal", Vector3.new(11, 2.2, 9), CFrame.new(origin + Vector3.new(x, 2.6, z)), Enum.Material.Metal, Color3.fromRGB(64, 59, 51))
        local glass = part(parent, "SpecimenCase", Vector3.new(8, 8, 6), pedestal.CFrame * CFrame.new(0, 5.1, 0), Enum.Material.Glass, specimenColors[index], 0.68, false)
        local core = neon(parent, "RecoveredCore", Vector3.new(3.2, 3.2, 3.2), glass.CFrame, specimenColors[index], 0.08)
        core.Shape = Enum.PartType.Ball
        light(core, specimenColors[index], 0.6, 11)
        neon(parent, "SpecimenRail", Vector3.new(8.5, 0.2, 0.3), pedestal.CFrame * CFrame.new(0, 1.25, -4.55), accent, 0.14)
    end

    local terminal = part(parent, "StorageTerminal", Vector3.new(11, 6, 3), CFrame.new(origin + Vector3.new(22, 4, -14)) * CFrame.Angles(math.rad(-8), 0, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(25, 31, 34))
    local screen = neon(parent, "StorageTerminalScreen", Vector3.new(9.6, 4.4, 0.16), terminal.CFrame * CFrame.new(0, 0, -1.58), Color3.fromRGB(71, 156, 174), 0.14)
    surfaceText(screen, "FIELD BANK\nSECURED STORAGE", Enum.NormalId.Front, Color3.fromRGB(192, 232, 238))
    prompt(terminal, "Inspect storage", "Recovered assets", function(player)
        ctx.Remotes.State:FireClient(player, "Notice", "Recovered assets are secured here after successful extraction. Push deeper for higher-value field banks.")
    end)

    for i = 0, 3 do
        buildLocker(parent, origin + Vector3.new(-27 + i * 8.5, 1.8, -18), 0)
    end
end

local function buildOperatorGallery(parent)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(48, 11.5, 88)
    local backing = part(parent, "OperatorGalleryWall", Vector3.new(72, 10, 1.2), CFrame.new(origin + Vector3.new(0, 5.3, 0)), Enum.Material.Metal, Color3.fromRGB(42, 47, 51))
    surfaceText(backing, "OPERATOR ARCHIVE  //  BREACH RECORDS", Enum.NormalId.Front, Color3.fromRGB(177, 218, 227))

    for index = 1, 5 do
        local x = -28 + (index - 1) * 14
        local frame = part(parent, "OperatorRecordFrame", Vector3.new(10, 7, 0.8), CFrame.new(origin + Vector3.new(x, 1, -0.9)), Enum.Material.Metal, Color3.fromRGB(72, 78, 82), 0, false)
        local plate = part(parent, "OperatorRecordPlate", Vector3.new(8.5, 5.5, 0.18), frame.CFrame * CFrame.new(0, 0, -0.5), Enum.Material.SmoothPlastic, Color3.fromRGB(28, 35, 39), 0, false)
        local marker = neon(parent, "RecordStatus", Vector3.new(6.2, 0.18, 0.15), plate.CFrame * CFrame.new(0, -2, -0.12), Color3.fromRGB(73, 157, 174), 0.13)
        marker.CanCollide = false
    end
end

local function buildNavigation(parent)
    local origin = SAFEHOUSE_ORIGIN
    local cyan = Color3.fromRGB(75, 165, 184)
    local amber = Color3.fromRGB(212, 145, 70)

    local routes = {
        { Vector3.new(-44, 2.05, -42), Vector3.new(30, 0.16, 2), cyan },
        { Vector3.new(44, 2.05, -42), Vector3.new(30, 0.16, 2), cyan },
        { Vector3.new(-52, 2.05, 48), Vector3.new(38, 0.16, 2), cyan },
        { Vector3.new(52, 2.05, 48), Vector3.new(38, 0.16, 2), cyan },
        { Vector3.new(0, 2.05, 66), Vector3.new(2, 0.16, 32), amber },
    }
    for _, route in ipairs(routes) do
        neon(parent, "NavigationRoute", route[2], CFrame.new(origin + route[1]), route[3], 0.28)
    end

    local signs = {
        { Vector3.new(-52, 10, -8), "ARMORY  ←\nSYSTEMS LAB  ←", Enum.NormalId.Front },
        { Vector3.new(52, 10, -8), "OPERATIONS  →\nFIRING RANGE  →", Enum.NormalId.Front },
        { Vector3.new(0, 10, 42), "FIELD STORAGE  ←\nDEPLOYMENT  ↓", Enum.NormalId.Front },
    }
    for _, data in ipairs(signs) do
        local sign = part(parent, "WayfindingSign", Vector3.new(31, 7, 0.8), CFrame.new(origin + data[1]), Enum.Material.Metal, Color3.fromRGB(31, 37, 41), 0, false)
        surfaceText(sign, data[2], data[3], Color3.fromRGB(196, 224, 231))
        neon(parent, "WayfindingEdge", Vector3.new(31.5, 0.24, 0.15), sign.CFrame * CFrame.new(0, -3.55, -0.48), cyan, 0.12)
    end
end

local function buildDeploymentStaging(parent)
    local origin = SAFEHOUSE_ORIGIN + Vector3.new(0, 0, 76)
    local amber = Color3.fromRGB(216, 136, 64)

    for _, x in ipairs({ -30, 30 }) do
        local rack = part(parent, "DeploymentGearRack", Vector3.new(10, 9, 5), CFrame.new(origin + Vector3.new(x, 4.5, -3)), Enum.Material.Metal, Color3.fromRGB(55, 60, 64))
        for slot = -1, 1 do
            part(parent, "DeploymentPack", Vector3.new(6, 1.4, 3.2), rack.CFrame * CFrame.new(0, slot * 2.6, -2.9), Enum.Material.DiamondPlate, Color3.fromRGB(78, 84, 88), 0, false)
        end
        neon(parent, "RackReady", Vector3.new(6, 0.25, 0.16), rack.CFrame * CFrame.new(0, 3.4, -2.65), Color3.fromRGB(91, 177, 127), 0.1)
    end

    for _, x in ipairs({ -11, 11 }) do
        local beacon = neon(parent, "DeploymentFloorBeacon", Vector3.new(5.5, 0.18, 5.5), CFrame.new(origin + Vector3.new(x, 1.95, -10)), amber, 0.36)
        beacon.Shape = Enum.PartType.Cylinder
        light(beacon, amber, 0.55, 12)
    end
end

function SafehouseExperienceService.Init(context)
    ctx = context
    assert(ctx and ctx.Remotes and ctx.Remotes.State, "SafehouseExperienceService requires runtime context")
end

function SafehouseExperienceService.Build()
    local old = Workspace:FindFirstChild(ROOT_NAME)
    if old then
        old:Destroy()
    end

    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = Workspace

    buildRecoveredLootVault(root)
    buildOperatorGallery(root)
    buildNavigation(root)
    buildDeploymentStaging(root)

    root:SetAttribute("AuthoredSafehouseLayer", true)
    root:SetAttribute("SelfContainedFallback", true)
    root:SetAttribute("BuildVersion", 1)
end

return SafehouseExperienceService
