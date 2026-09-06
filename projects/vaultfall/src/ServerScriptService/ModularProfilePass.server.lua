local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("VaultfallWorld", 20)
if not world then
    warn("[Vaultfall Modular Profile] world unavailable; pass skipped")
    return
end

local previous = world:FindFirstChild("ModularProfilePass")
if previous then
    previous:Destroy()
end

local root = Instance.new("Folder")
root.Name = "ModularProfilePass"
root.Parent = world

local palette = {
    dark = Color3.fromRGB(43, 49, 54),
    mid = Color3.fromRGB(73, 80, 86),
    light = Color3.fromRGB(113, 121, 128),
    white = Color3.fromRGB(226, 234, 236),
    cyan = Color3.fromRGB(87, 174, 194),
    amber = Color3.fromRGB(221, 163, 83),
    violet = Color3.fromRGB(151, 112, 188),
    green = Color3.fromRGB(101, 177, 143),
    blue = Color3.fromRGB(101, 145, 194),
    red = Color3.fromRGB(195, 79, 86),
}

local accentByKind = {
    Combat = palette.cyan,
    Treasure = palette.amber,
    Elite = palette.violet,
    Shrine = palette.green,
    DeepCombat = palette.blue,
    Boss = palette.red,
}

local function basePart(className, parent, name, size, cframe, material, color, transparency)
    local item = Instance.new(className)
    item.Name = name
    item.Size = size
    item.CFrame = cframe
    item.Anchored = true
    item.CanCollide = false
    item.CanTouch = false
    item.CanQuery = false
    item.CastShadow = false
    item.Material = material or Enum.Material.Metal
    item.Color = color or palette.mid
    item.Transparency = transparency or 0
    item.TopSurface = Enum.SurfaceType.Smooth
    item.BottomSurface = Enum.SurfaceType.Smooth
    item.Parent = parent
    return item
end

local function part(parent, name, size, cframe, material, color, transparency)
    return basePart("Part", parent, name, size, cframe, material, color, transparency)
end

local function wedge(parent, name, size, cframe, color)
    return basePart("WedgePart", parent, name, size, cframe, Enum.Material.Metal, color or palette.dark, 0)
end

local function neon(parent, name, size, cframe, color, transparency)
    return part(parent, name, size, cframe, Enum.Material.Neon, color, transparency or 0.18)
end

local function pointLight(host, color, brightness, range)
    local lamp = Instance.new("PointLight")
    lamp.Name = "ProfileLight"
    lamp.Color = color
    lamp.Brightness = brightness or 0.45
    lamp.Range = range or 18
    lamp.Shadows = false
    lamp.Parent = host
end

local function surfaceLabel(host, text, accent, face, textSize)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Wayfinding"
    gui.Face = face or Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.LightInfluence = 0
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 28
    gui.Parent = host

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = accent
    label.TextScaled = false
    label.TextSize = textSize or 24
    label.TextStrokeColor3 = Color3.fromRGB(18, 22, 25)
    label.TextStrokeTransparency = 0.45
    label.Parent = gui
end

local function angledPortal(group, center, width, height, depth, accent, yaw)
    local rotation = CFrame.Angles(0, math.rad(yaw or 0), 0)
    local frame = CFrame.new(center) * rotation
    local half = width * 0.5

    local left = part(group, "PortalLeft", Vector3.new(2.3, height - 2.5, depth), frame * CFrame.new(-half, (height - 2.5) * 0.5, 0), Enum.Material.Metal, palette.dark)
    local right = part(group, "PortalRight", Vector3.new(2.3, height - 2.5, depth), frame * CFrame.new(half, (height - 2.5) * 0.5, 0), Enum.Material.Metal, palette.dark)
    part(group, "PortalHeader", Vector3.new(width + 2.3, 1.8, depth), frame * CFrame.new(0, height - 0.9, 0), Enum.Material.Metal, palette.mid)

    local leftBrace = wedge(group, "PortalBraceL", Vector3.new(5.2, 4.5, depth + 0.5), frame * CFrame.new(-half - 1.55, 2.25, 0) * CFrame.Angles(0, math.rad(180), 0), palette.mid)
    local rightBrace = wedge(group, "PortalBraceR", Vector3.new(5.2, 4.5, depth + 0.5), frame * CFrame.new(half + 1.55, 2.25, 0), palette.mid)
    leftBrace.Transparency = 0.03
    rightBrace.Transparency = 0.03

    local strip = neon(group, "PortalAccent", Vector3.new(width - 3, 0.22, depth + 0.12), frame * CFrame.new(0, height - 2.05, -0.05), accent, 0.12)
    pointLight(strip, accent, 0.42, 17)

    return left, right
end

local function conduit(group, center, length, axisX, accent)
    local pipe = part(
        group,
        "Conduit",
        axisX and Vector3.new(length, 1.25, 1.25) or Vector3.new(1.25, 1.25, length),
        CFrame.new(center),
        Enum.Material.Metal,
        palette.dark
    )
    pipe.Shape = Enum.PartType.Cylinder
    pipe.CFrame = pipe.CFrame * CFrame.Angles(0, 0, math.rad(90))
    if not axisX then
        pipe.CFrame = CFrame.new(center) * CFrame.Angles(math.rad(90), 0, 0)
    end
    local collarOffsets = { -length * 0.35, 0, length * 0.35 }
    for _, offset in ipairs(collarOffsets) do
        local position = axisX and center + Vector3.new(offset, 0, 0) or center + Vector3.new(0, 0, offset)
        local collar = part(group, "ConduitCollar", Vector3.new(1.65, 1.65, 0.45), CFrame.new(position), Enum.Material.Metal, palette.mid)
        collar.Shape = Enum.PartType.Cylinder
        collar.CFrame = collar.CFrame * (axisX and CFrame.Angles(0, 0, math.rad(90)) or CFrame.Angles(math.rad(90), 0, 0))
    end
    neon(group, "ConduitStatus", Vector3.new(1.35, 0.18, 0.18), CFrame.new(center + Vector3.new(0, 0.82, 0)), accent, 0.2)
end

local function hangingSign(group, center, width, text, accent, yaw)
    local cf = CFrame.new(center) * CFrame.Angles(0, math.rad(yaw or 0), 0)
    part(group, "SignSupportL", Vector3.new(0.35, 3.4, 0.35), cf * CFrame.new(-width * 0.36, 1.7, 0), Enum.Material.Metal, palette.dark)
    part(group, "SignSupportR", Vector3.new(0.35, 3.4, 0.35), cf * CFrame.new(width * 0.36, 1.7, 0), Enum.Material.Metal, palette.dark)
    local plate = part(group, "WayfindingPlate", Vector3.new(width, 3.2, 0.45), cf * CFrame.new(0, -0.2, 0), Enum.Material.Metal, palette.dark)
    neon(group, "WayfindingUnderline", Vector3.new(width - 1.2, 0.18, 0.5), plate.CFrame * CFrame.new(0, -1.25, -0.02), accent, 0.14)
    surfaceLabel(plate, text, palette.white, Enum.NormalId.Front, 23)
end

local safehouse = world:FindFirstChild("Safehouse")
if safehouse then
    local safeRoot = Instance.new("Folder")
    safeRoot.Name = "SafehouseProfiles"
    safeRoot.Parent = root

    local origin = Vector3.new(-220, 0, -120)
    local facilities = {
        { name = "ARMORY", center = origin + Vector3.new(-63, 11.8, -34), accent = palette.cyan, yaw = 0 },
        { name = "OPERATIONS", center = origin + Vector3.new(52, 11.8, -34), accent = palette.amber, yaw = 0 },
        { name = "SYSTEMS", center = origin + Vector3.new(-56, 11.8, 32), accent = palette.green, yaw = 180 },
        { name = "FIRING RANGE", center = origin + Vector3.new(54, 11.8, 20), accent = palette.amber, yaw = 180 },
        { name = "DEPLOYMENT", center = origin + Vector3.new(0, 12.5, -78), accent = palette.cyan, yaw = 0 },
    }

    for _, facility in ipairs(facilities) do
        local group = Instance.new("Folder")
        group.Name = facility.name:gsub(" ", "") .. "Profile"
        group.Parent = safeRoot
        hangingSign(group, facility.center, math.max(17, #facility.name * 1.25), facility.name, facility.accent, facility.yaw)
    end

    -- Break the broad safehouse ceiling silhouette with sloped service canopies and ducts.
    for _, entry in ipairs({
        { origin + Vector3.new(-78, 13.5, -8), 28, palette.cyan },
        { origin + Vector3.new(76, 13.5, -8), 30, palette.amber },
        { origin + Vector3.new(-76, 13.5, 54), 26, palette.green },
        { origin + Vector3.new(77, 13.5, 55), 27, palette.amber },
    }) do
        local center = entry[1]
        local width = entry[2]
        local accent = entry[3]
        part(safeRoot, "CanopyBeam", Vector3.new(width, 1.1, 5.5), CFrame.new(center), Enum.Material.Metal, palette.mid)
        wedge(safeRoot, "CanopyEndL", Vector3.new(5.5, 4, 5.5), CFrame.new(center + Vector3.new(-width * 0.5 - 2.65, -1.45, 0)) * CFrame.Angles(0, math.rad(180), 0), palette.dark)
        wedge(safeRoot, "CanopyEndR", Vector3.new(5.5, 4, 5.5), CFrame.new(center + Vector3.new(width * 0.5 + 2.65, -1.45, 0)), palette.dark)
        local lamp = neon(safeRoot, "CanopyLamp", Vector3.new(width - 4, 0.18, 2.2), CFrame.new(center + Vector3.new(0, -0.65, 0)), palette.white, 0.24)
        pointLight(lamp, palette.white, 0.38, 18)
        conduit(safeRoot, center + Vector3.new(0, 2.0, 3.4), width - 3, true, accent)
    end
end

local dungeon = world:FindFirstChild("Sector07")
local sectorCount = 0
if dungeon then
    for _, zone in ipairs(dungeon:GetChildren()) do
        if zone:IsA("Folder") and string.match(zone.Name, "^Zone_%d+_") then
            local floor = zone:FindFirstChild("Floor")
            if floor and floor:IsA("BasePart") then
                local index = tonumber(string.match(zone.Name, "^Zone_(%d+)_")) or 0
                local kind = string.match(zone.Name, "^Zone_%d+_(.+)$") or "Combat"
                local accent = accentByKind[kind] or palette.cyan
                local center = floor.Position
                local sx = floor.Size.X
                local sz = floor.Size.Z
                local halfX = math.max(28, sx * 0.5 - 9)
                local halfZ = math.max(28, sz * 0.5 - 9)

                local group = Instance.new("Folder")
                group.Name = zone.Name .. "_Profile"
                group.Parent = root

                -- A readable framed threshold gives each generated room a deliberate entrance silhouette.
                local entranceZ = -halfZ + 5.5
                angledPortal(group, center + Vector3.new(0, 0, entranceZ), math.clamp(sx * 0.46, 34, 58), 14, 3.2, accent, 0)
                local sign = part(group, "SectorSign", Vector3.new(22, 3.3, 0.5), CFrame.new(center + Vector3.new(0, 11.2, entranceZ - 1.9)), Enum.Material.Metal, palette.dark)
                surfaceLabel(sign, string.format("%02d  %s", index, string.upper(kind)), palette.white, Enum.NormalId.Front, 21)
                neon(group, "SectorSignBand", Vector3.new(20.5, 0.2, 0.55), sign.CFrame * CFrame.new(0, -1.22, 0), accent, 0.12)

                -- Sidewall modules add sloped/chamfered profiles instead of another run of flat boxes.
                for _, side in ipairs({ -1, 1 }) do
                    local x = halfX * side
                    for _, zAlpha in ipairs({ -0.52, 0.52 }) do
                        local z = halfZ * zAlpha
                        local moduleCenter = center + Vector3.new(x, 0, z)
                        part(group, "WallModule", Vector3.new(5.2, 9, 13), CFrame.new(moduleCenter + Vector3.new(0, 4.5, 0)), Enum.Material.Metal, palette.mid)
                        local braceRotation = side < 0 and 0 or 180
                        wedge(group, "WallModuleFoot", Vector3.new(5.5, 4, 13.5), CFrame.new(moduleCenter + Vector3.new(-side * 3.9, 2, 0)) * CFrame.Angles(0, math.rad(braceRotation), 0), palette.dark)
                        local status = neon(group, "WallModuleStatus", Vector3.new(0.2, 5.5, 7.5), CFrame.new(moduleCenter + Vector3.new(-side * 2.72, 5, 0)), accent, 0.2)
                        if zAlpha > 0 then
                            pointLight(status, accent, 0.32, 14)
                        end
                    end
                end

                local pipeZ = halfZ * (index % 2 == 0 and 0.66 or -0.66)
                conduit(group, center + Vector3.new(0, 10.8, pipeZ), math.clamp(sx * 0.58, 34, 64), true, accent)

                -- Boss and shrine rooms get an additional circular/raised visual profile without collision.
                if kind == "Boss" or kind == "Shrine" then
                    local radius = kind == "Boss" and 18 or 13
                    for i = 1, 8 do
                        local angle = (i - 1) * math.pi / 4
                        local pos = center + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
                        local fin = wedge(group, "RadialFin", Vector3.new(3.8, kind == "Boss" and 8 or 6, 7.5), CFrame.new(pos + Vector3.new(0, kind == "Boss" and 4 or 3, 0)) * CFrame.Angles(0, -angle + math.pi * 0.5, 0), palette.dark)
                        fin.Transparency = 0.05
                    end
                end

                sectorCount += 1
            end
        end
    end
end

print(string.format("[Vaultfall Modular Profile] authored profile breakup ready for %d sectors", sectorCount))
