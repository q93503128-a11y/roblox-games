local Workspace = game:GetService("Workspace")

local SelfContainedDressingService = {}
local ctx

local ROOT_NAME = "VaultfallSelfContainedDressing"
local SAFEHOUSE_ORIGIN = Vector3.new(-220, 0, -120)

local ROOM_ACCENTS = {
    Combat = Color3.fromRGB(73, 156, 173),
    Treasure = Color3.fromRGB(205, 153, 67),
    Elite = Color3.fromRGB(148, 89, 176),
    Shrine = Color3.fromRGB(82, 176, 128),
    DeepCombat = Color3.fromRGB(195, 94, 68),
    Boss = Color3.fromRGB(196, 62, 71),
}

local function part(parent, name, size, cframe, material, color, transparency, collide)
    local instance = Instance.new("Part")
    instance.Name = name
    instance.Size = size
    instance.CFrame = cframe
    instance.Anchored = true
    instance.Material = material or Enum.Material.Metal
    instance.Color = color or Color3.fromRGB(58, 63, 68)
    instance.Transparency = transparency or 0
    instance.CanCollide = collide ~= false
    instance.CanTouch = false
    instance.TopSurface = Enum.SurfaceType.Smooth
    instance.BottomSurface = Enum.SurfaceType.Smooth
    instance.Parent = parent
    return instance
end

local function neon(parent, name, size, cframe, color, transparency)
    return part(parent, name, size, cframe, Enum.Material.Neon, color, transparency or 0.08, false)
end

local function addLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness or 0.8
    light.Range = range or 14
    light.Shadows = true
    light.Parent = host
end

local function crate(parent, cframe, scale, accent)
    local s = scale or 1
    local body = part(parent, "CargoCrate", Vector3.new(6, 4.2, 5) * s, cframe, Enum.Material.Metal, Color3.fromRGB(53, 58, 61))
    part(parent, "CrateBand", Vector3.new(6.16, 0.34, 5.16) * s, cframe * CFrame.new(0, 1.25 * s, 0), Enum.Material.DiamondPlate, Color3.fromRGB(82, 88, 91), 0, false)
    part(parent, "CrateBand", Vector3.new(6.16, 0.34, 5.16) * s, cframe * CFrame.new(0, -1.25 * s, 0), Enum.Material.DiamondPlate, Color3.fromRGB(82, 88, 91), 0, false)
    neon(parent, "CrateStatus", Vector3.new(2.4, 0.18, 0.12) * s, cframe * CFrame.new(0, 0, -2.56 * s), accent, 0.1)
    return body
end

local function pipeRun(parent, origin, length, horizontal, accent)
    local pipeColor = Color3.fromRGB(76, 80, 82)
    if horizontal then
        local pipe = part(parent, "UtilityPipe", Vector3.new(length, 0.7, 0.7), CFrame.new(origin), Enum.Material.Metal, pipeColor, 0, false)
        for x = -length / 2 + 4, length / 2 - 4, 8 do
            part(parent, "PipeClamp", Vector3.new(0.35, 1.2, 1.2), pipe.CFrame * CFrame.new(x, 0, 0), Enum.Material.Metal, Color3.fromRGB(38, 42, 45), 0, false)
        end
    else
        local pipe = part(parent, "UtilityPipe", Vector3.new(0.7, 0.7, length), CFrame.new(origin), Enum.Material.Metal, pipeColor, 0, false)
        for z = -length / 2 + 4, length / 2 - 4, 8 do
            part(parent, "PipeClamp", Vector3.new(1.2, 1.2, 0.35), pipe.CFrame * CFrame.new(0, 0, z), Enum.Material.Metal, Color3.fromRGB(38, 42, 45), 0, false)
        end
    end
    local marker = neon(parent, "PipeMarker", Vector3.new(1.8, 0.14, 0.14), CFrame.new(origin + Vector3.new(0, 0.55, 0)), accent, 0.16)
    marker.CanCollide = false
end

local function workLamp(parent, cframe, accent)
    local mast = part(parent, "WorkLampMast", Vector3.new(0.35, 6.6, 0.35), cframe * CFrame.new(0, 3.3, 0), Enum.Material.Metal, Color3.fromRGB(55, 60, 64), 0, false)
    local head = part(parent, "WorkLampHead", Vector3.new(2.8, 0.8, 1.1), mast.CFrame * CFrame.new(0, 3.15, 0), Enum.Material.Metal, Color3.fromRGB(42, 47, 50), 0, false)
    local lens = neon(parent, "WorkLampLens", Vector3.new(2.3, 0.42, 0.12), head.CFrame * CFrame.new(0, 0, -0.61), accent, 0.05)
    addLight(lens, accent, 1.05, 18)
end

local function buildSafehouseDressing(root)
    local folder = Instance.new("Folder")
    folder.Name = "SafehouseDressing"
    folder.Parent = root

    local cyan = Color3.fromRGB(74, 164, 184)
    local amber = Color3.fromRGB(215, 146, 68)

    for _, spec in ipairs({
        { Vector3.new(-108, 2.1, -86), 0 },
        { Vector3.new(-98, 2.1, -79), 18 },
        { Vector3.new(101, 2.1, -83), -12 },
        { Vector3.new(110, 2.1, 61), 9 },
        { Vector3.new(-110, 2.1, 66), -8 },
        { Vector3.new(91, 2.1, 88), 14 },
    }) do
        crate(folder, CFrame.new(SAFEHOUSE_ORIGIN + spec[1]) * CFrame.Angles(0, math.rad(spec[2]), 0), 1, amber)
    end

    pipeRun(folder, SAFEHOUSE_ORIGIN + Vector3.new(0, 14.5, -105), 210, true, cyan)
    pipeRun(folder, SAFEHOUSE_ORIGIN + Vector3.new(-124, 13.2, 0), 180, false, cyan)
    pipeRun(folder, SAFEHOUSE_ORIGIN + Vector3.new(124, 13.2, 0), 180, false, amber)

    for _, offset in ipairs({
        Vector3.new(-66, 1.7, -4), Vector3.new(66, 1.7, -4),
        Vector3.new(-66, 1.7, 55), Vector3.new(66, 1.7, 55),
        Vector3.new(0, 1.7, -70), Vector3.new(0, 1.7, 78),
    }) do
        workLamp(folder, CFrame.new(SAFEHOUSE_ORIGIN + offset), cyan)
    end
end

local function buildRoomDressing(root, room)
    local folder = Instance.new("Folder")
    folder.Name = string.format("Room_%02d_%s_Dressing", room.Index, room.Type)
    folder.Parent = root

    local origin = room.Origin
    local accent = ROOM_ACCENTS[room.Type] or ROOM_ACCENTS.Combat
    local angle = (room.Index % 2 == 0) and 14 or -14

    crate(folder, CFrame.new(origin + Vector3.new(-39, 2.1, -30)) * CFrame.Angles(0, math.rad(angle), 0), 0.86, accent)
    crate(folder, CFrame.new(origin + Vector3.new(38, 2.1, 31)) * CFrame.Angles(0, math.rad(-angle), 0), 0.72, accent)
    crate(folder, CFrame.new(origin + Vector3.new(34, 2.1, -37)) * CFrame.Angles(0, math.rad(7 + room.Index * 3), 0), 0.62, accent)

    for _, offset in ipairs({ Vector3.new(-47, 1.2, 0), Vector3.new(47, 1.2, 0) }) do
        workLamp(folder, CFrame.new(origin + offset), accent)
    end

    pipeRun(folder, origin + Vector3.new(0, 12.8, -48), 72, true, accent)
    pipeRun(folder, origin + Vector3.new(-48, 11.6, 0), 70, false, accent)

    for _, z in ipairs({ -27, 27 }) do
        local rail = part(folder, "CableTray", Vector3.new(34, 0.38, 1.2), CFrame.new(origin + Vector3.new(0, 0.9, z)), Enum.Material.DiamondPlate, Color3.fromRGB(42, 46, 49), 0, false)
        neon(folder, "CablePulse", Vector3.new(28, 0.1, 0.16), rail.CFrame * CFrame.new(0, 0.26, 0), accent, 0.35)
    end

    if room.Type == "Treasure" then
        for x = -18, 18, 12 do
            crate(folder, CFrame.new(origin + Vector3.new(x, 2.2, 4 + math.abs(x) * 0.18)), 0.88, accent)
        end
    elseif room.Type == "Shrine" then
        for index = 0, 5 do
            local theta = math.rad(index * 60)
            local p = origin + Vector3.new(math.cos(theta) * 24, 1.2, math.sin(theta) * 24)
            local core = neon(folder, "ShrinePylon", Vector3.new(1.1, 8, 1.1), CFrame.new(p + Vector3.new(0, 4, 0)), accent, 0.15)
            addLight(core, accent, 0.5, 11)
        end
    elseif room.Type == "Elite" then
        for _, x in ipairs({ -26, 26 }) do
            part(folder, "EliteBanner", Vector3.new(7, 12, 0.3), CFrame.new(origin + Vector3.new(x, 8, -47.2)), Enum.Material.Fabric, Color3.fromRGB(57, 37, 65), 0, false)
            neon(folder, "EliteSigil", Vector3.new(4.8, 0.22, 0.12), CFrame.new(origin + Vector3.new(x, 9.5, -47.4)), accent, 0.08)
        end
    elseif room.Type == "DeepCombat" then
        for _, offset in ipairs({ Vector3.new(-28, 1.1, -20), Vector3.new(28, 1.1, 20) }) do
            local vent = part(folder, "PressureVent", Vector3.new(10, 2, 10), CFrame.new(origin + offset), Enum.Material.DiamondPlate, Color3.fromRGB(45, 48, 50), 0, false)
            neon(folder, "PressureWarning", Vector3.new(7, 0.18, 7), vent.CFrame * CFrame.new(0, 1.05, 0), accent, 0.55)
        end
    elseif room.Type == "Boss" then
        for index = 0, 7 do
            local theta = math.rad(index * 45)
            local p = origin + Vector3.new(math.cos(theta) * 43, 0, math.sin(theta) * 43)
            local pillar = part(folder, "BossArenaPillar", Vector3.new(3.8, 15, 3.8), CFrame.new(p + Vector3.new(0, 7.5, 0)), Enum.Material.Metal, Color3.fromRGB(47, 43, 46))
            local crown = neon(folder, "BossPillarCrown", Vector3.new(5.2, 0.34, 5.2), pillar.CFrame * CFrame.new(0, 6.7, 0), accent, 0.1)
            addLight(crown, accent, 0.8, 16)
        end
    end
end

function SelfContainedDressingService.Init(context)
    ctx = context
    assert(ctx and ctx.World, "SelfContainedDressingService requires WorldService")
end

function SelfContainedDressingService.Build()
    local previous = Workspace:FindFirstChild(ROOT_NAME)
    if previous then
        previous:Destroy()
    end

    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root:SetAttribute("SelfContained", true)
    root:SetAttribute("RequiresExternalAssets", false)
    root.Parent = Workspace

    buildSafehouseDressing(root)
    for _, room in ipairs(ctx.World.GetRooms()) do
        buildRoomDressing(root, room)
    end
end

return SelfContainedDressingService
