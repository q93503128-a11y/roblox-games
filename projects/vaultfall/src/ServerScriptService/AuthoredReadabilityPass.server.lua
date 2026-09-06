local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("VaultfallWorld", 20)
if not world then
    warn("[Vaultfall Readability] world unavailable; authored readability pass skipped")
    return
end

local previous = world:FindFirstChild("AuthoredReadability")
if previous then
    previous:Destroy()
end

local root = Instance.new("Folder")
root.Name = "AuthoredReadability"
root.Parent = world

local function newPart(parent, name, size, cframe, material, color, transparency)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Material = material or Enum.Material.Metal
    part.Color = color or Color3.fromRGB(90, 96, 103)
    part.Transparency = transparency or 0
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local function pointLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Name = "ReadableFill"
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Shadows = false
    light.Parent = host
    return light
end

local function surfaceLight(host, face, color, brightness, range, angle)
    local light = Instance.new("SurfaceLight")
    light.Name = "TaskLight"
    light.Face = face
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Angle = angle or 120
    light.Shadows = false
    light.Parent = host
    return light
end

local neutral = Color3.fromRGB(218, 230, 234)
local warm = Color3.fromRGB(244, 226, 198)
local cyan = Color3.fromRGB(93, 176, 190)
local amber = Color3.fromRGB(223, 163, 87)
local red = Color3.fromRGB(196, 89, 92)
local violet = Color3.fromRGB(145, 111, 173)
local green = Color3.fromRGB(105, 176, 145)
local paleFloor = Color3.fromRGB(91, 97, 103)
local housing = Color3.fromRGB(73, 79, 85)
local darkHousing = Color3.fromRGB(48, 54, 60)

local safehouse = world:FindFirstChild("Safehouse")
if safehouse then
    local authored = Instance.new("Folder")
    authored.Name = "SafehouseReadability"
    authored.Parent = root

    local origin = Vector3.new(-220, 0, -120)

    -- A continuous navigation spine makes the route from spawn to deployment
    -- readable without relying on giant text pads or neon-only decoration.
    newPart(authored, "NavigationSpine", Vector3.new(16, 0.16, 154), CFrame.new(origin + Vector3.new(0, 0.86, 25)), Enum.Material.DiamondPlate, Color3.fromRGB(77, 84, 90))
    newPart(authored, "NavigationSpineEdgeL", Vector3.new(0.34, 0.12, 154), CFrame.new(origin + Vector3.new(-8.1, 0.98, 25)), Enum.Material.Neon, cyan, 0.18)
    newPart(authored, "NavigationSpineEdgeR", Vector3.new(0.34, 0.12, 154), CFrame.new(origin + Vector3.new(8.1, 0.98, 25)), Enum.Material.Neon, cyan, 0.18)

    -- Cross aisles connect the major work areas and break the previous huge,
    -- low-value floor into readable spatial bands.
    for _, z in ipairs({ -55, 48 }) do
        newPart(authored, "CrossAisle", Vector3.new(176, 0.14, 11), CFrame.new(origin + Vector3.new(0, 0.87, z)), Enum.Material.DiamondPlate, paleFloor)
    end

    local zones = {
        { "ARMORY", Vector3.new(-82, 0, -54), cyan, 34, 30 },
        { "OPERATIONS", Vector3.new(72, 0, -55), amber, 38, 32 },
        { "SYSTEMS", Vector3.new(-78, 0, 53), green, 36, 32 },
        { "RANGE", Vector3.new(78, 0, 48), warm, 38, 34 },
        { "DEPLOY", Vector3.new(0, 0, 76), red, 28, 26 },
    }

    for _, zone in ipairs(zones) do
        local name = zone[1]
        local offset = zone[2]
        local accent = zone[3]
        local width = zone[4]
        local depth = zone[5]
        local center = origin + offset

        newPart(authored, name .. "FloorBand", Vector3.new(width, 0.11, depth), CFrame.new(center + Vector3.new(0, 0.94, 0)), Enum.Material.SmoothPlastic, Color3.fromRGB(66, 72, 78), 0.08)
        newPart(authored, name .. "Threshold", Vector3.new(width - 4, 0.16, 1.2), CFrame.new(center + Vector3.new(0, 1.04, -(depth * 0.5 - 1.6))), Enum.Material.Neon, accent, 0.12)

        local ceiling = newPart(authored, name .. "CeilingFixture", Vector3.new(math.max(16, width - 10), 0.55, 3.2), CFrame.new(center + Vector3.new(0, 15.7, 0)), Enum.Material.Metal, housing)
        local diffuser = newPart(authored, name .. "Diffuser", Vector3.new(math.max(14, width - 12), 0.12, 2.35), ceiling.CFrame * CFrame.new(0, -0.34, 0), Enum.Material.Neon, neutral, 0.22)
        surfaceLight(diffuser, Enum.NormalId.Bottom, neutral, 1.85, 35, 120)
        pointLight(diffuser, accent, 0.7, 24)

        -- Short architectural fins give each station a recognisable silhouette
        -- while keeping sightlines and player movement open.
        for _, x in ipairs({ -(width * 0.5 - 2.5), width * 0.5 - 2.5 }) do
            newPart(authored, name .. "Fin", Vector3.new(1.2, 9, 4), CFrame.new(center + Vector3.new(x, 4.5, -(depth * 0.5 - 3))), Enum.Material.Metal, darkHousing)
            newPart(authored, name .. "FinAccent", Vector3.new(0.2, 6.5, 3.4), CFrame.new(center + Vector3.new(x + (x < 0 and 0.66 or -0.66), 4.5, -(depth * 0.5 - 3))), Enum.Material.Neon, accent, 0.15)
        end
    end

    -- The spawn area gets a bright visual anchor so the player's first frame
    -- has a clear horizon and destination instead of a dark open box.
    local spawnAnchor = newPart(authored, "SpawnCanopy", Vector3.new(44, 0.7, 7), CFrame.new(origin + Vector3.new(0, 15.4, 56)), Enum.Material.Metal, housing)
    local spawnDiffuser = newPart(authored, "SpawnCanopyDiffuser", Vector3.new(40, 0.12, 5.2), spawnAnchor.CFrame * CFrame.new(0, -0.42, 0), Enum.Material.Neon, neutral, 0.2)
    surfaceLight(spawnDiffuser, Enum.NormalId.Bottom, neutral, 2.15, 38, 125)
end

local dungeon = world:FindFirstChild("Sector07")
if dungeon then
    local authored = Instance.new("Folder")
    authored.Name = "SectorReadability"
    authored.Parent = root

    local accents = {
        Combat = cyan,
        Treasure = amber,
        Elite = violet,
        Shrine = green,
        DeepCombat = Color3.fromRGB(111, 150, 198),
        Boss = red,
    }

    for _, zone in ipairs(dungeon:GetChildren()) do
        if zone:IsA("Folder") and string.match(zone.Name, "^Zone_%d+_") then
            local floor = zone:FindFirstChild("Floor")
            if floor and floor:IsA("BasePart") then
                local roomType = string.match(zone.Name, "^Zone_%d+_(.+)$") or "Combat"
                local accent = accents[roomType] or cyan
                local center = floor.Position
                local size = floor.Size
                local group = Instance.new("Folder")
                group.Name = zone.Name
                group.Parent = authored

                -- Raise the visual value of the playable plane without changing
                -- collision or the room's encounter geometry.
                newPart(group, "ReadableFloorInset", Vector3.new(math.max(24, size.X - 18), 0.08, math.max(24, size.Z - 18)), CFrame.new(center + Vector3.new(0, 0.82, 0)), Enum.Material.Concrete, Color3.fromRGB(69, 75, 81), 0.06)

                -- Four non-blocking corner pylons create depth cues and give
                -- enemies a contrasting backdrop instead of flat black walls.
                local px = math.max(18, size.X * 0.5 - 11)
                local pz = math.max(18, size.Z * 0.5 - 11)
                for _, offset in ipairs({ Vector3.new(-px, 0, -pz), Vector3.new(px, 0, -pz), Vector3.new(-px, 0, pz), Vector3.new(px, 0, pz) }) do
                    local pylon = newPart(group, "CornerPylon", Vector3.new(2.4, 10, 2.4), CFrame.new(center + offset + Vector3.new(0, 5, 0)), Enum.Material.Metal, housing)
                    local lamp = newPart(group, "PylonLamp", Vector3.new(1.35, 5.2, 0.25), pylon.CFrame * CFrame.new(0, 0.5, -1.33), Enum.Material.Neon, accent, 0.14)
                    pointLight(lamp, accent, 0.7, 22)
                end

                -- Large diffused ceiling fixtures provide readable surfaces.
                -- The old gameplay fill remains broad ambient support; these
                -- fixtures make that light feel authored rather than invisible.
                for _, x in ipairs({ -size.X * 0.22, size.X * 0.22 }) do
                    local fixture = newPart(group, "CeilingHousing", Vector3.new(26, 0.65, 4.2), CFrame.new(center + Vector3.new(x, 16.8, 0)), Enum.Material.Metal, darkHousing)
                    local diffuser = newPart(group, "CeilingDiffuser", Vector3.new(23.5, 0.12, 3.1), fixture.CFrame * CFrame.new(0, -0.4, 0), Enum.Material.Neon, neutral, 0.24)
                    surfaceLight(diffuser, Enum.NormalId.Bottom, neutral, roomType == "Boss" and 2.2 or 1.75, 38, 125)
                end

                -- Directional floor inlays make room orientation and exits
                -- legible during combat without introducing blocking objects.
                newPart(group, "CenterGuideX", Vector3.new(math.max(22, size.X - 28), 0.07, 0.34), CFrame.new(center + Vector3.new(0, 0.93, 0)), Enum.Material.Neon, accent, 0.34)
                newPart(group, "CenterGuideZ", Vector3.new(0.34, 0.07, math.max(22, size.Z - 28)), CFrame.new(center + Vector3.new(0, 0.93, 0)), Enum.Material.Neon, accent, 0.34)

                local exitGate = zone:FindFirstChild("ExitGate")
                if exitGate and exitGate:IsA("BasePart") then
                    local gateSize = exitGate.Size
                    local horizontal = gateSize.X > gateSize.Z
                    local topSize = horizontal and Vector3.new(gateSize.X + 5, 1, 2.4) or Vector3.new(2.4, 1, gateSize.Z + 5)
                    local top = newPart(group, "ExitFrameTop", topSize, exitGate.CFrame * CFrame.new(0, gateSize.Y * 0.5 + 1.1, 0), Enum.Material.Metal, housing)
                    local beacon = newPart(group, "ExitBeacon", horizontal and Vector3.new(gateSize.X, 0.25, 0.45) or Vector3.new(0.45, 0.25, gateSize.Z), top.CFrame * CFrame.new(0, -0.65, 0), Enum.Material.Neon, accent, 0.08)
                    pointLight(beacon, accent, 0.9, 24)
                end
            end
        end
    end
end

print("[Vaultfall Readability] authored safehouse and sector readability ready")
