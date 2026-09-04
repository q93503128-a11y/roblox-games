local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local EnvironmentalHazardService = {}
local ctx

local ROOT_NAME = "VaultfallEnvironmentalHazards"
local hazards = {}
local running = false
local touchCooldowns = setmetatable({}, { __mode = "k" })

local TELEGRAPH_COLOR = Color3.fromRGB(229, 169, 69)
local ACTIVE_COLOR = Color3.fromRGB(235, 76, 64)
local IDLE_COLOR = Color3.fromRGB(58, 86, 91)

local function part(parent, name, size, cframe, material, color, transparency, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Material = material or Enum.Material.Metal
    p.Color = color or Color3.fromRGB(62, 67, 72)
    p.Transparency = transparency or 0
    p.CanCollide = collide == true
    p.CanTouch = true
    p.CanQuery = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function getHumanoidFromHit(hit)
    if not hit then
        return nil, nil
    end
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then
        return nil, nil
    end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil, nil
    end
    local player = Players:GetPlayerFromCharacter(model)
    if not player then
        return nil, nil
    end
    return humanoid, player
end

local function damageParticipant(hazard, hit)
    if not hazard.Active then
        return
    end

    local humanoid, player = getHumanoidFromHit(hit)
    if not humanoid or not player or not ctx.Run.IsParticipant(player) then
        return
    end

    local now = os.clock()
    local perHumanoid = touchCooldowns[humanoid]
    if not perHumanoid then
        perHumanoid = {}
        touchCooldowns[humanoid] = perHumanoid
    end
    if now - (perHumanoid[hazard.Id] or -100) < 0.8 then
        return
    end
    perHumanoid[hazard.Id] = now

    humanoid:TakeDamage(hazard.Damage)
    ctx.Remotes.State:FireClient(player, "Notice", hazard.DisplayName .. " — MOVE OUT")
end

local function setHazardState(hazard, state)
    hazard.State = state
    hazard.Active = state == "Active"

    if state == "Idle" then
        hazard.Warning.Color = IDLE_COLOR
        hazard.Warning.Transparency = 0.62
        hazard.Danger.Transparency = 1
        hazard.Zone.Transparency = 1
        hazard.Zone.CanTouch = false
    elseif state == "Telegraph" then
        hazard.Warning.Color = TELEGRAPH_COLOR
        hazard.Warning.Transparency = 0.08
        hazard.Danger.Color = TELEGRAPH_COLOR
        hazard.Danger.Transparency = 0.58
        hazard.Zone.Transparency = 1
        hazard.Zone.CanTouch = false
    else
        hazard.Warning.Color = ACTIVE_COLOR
        hazard.Warning.Transparency = 0
        hazard.Danger.Color = ACTIVE_COLOR
        hazard.Danger.Transparency = 0.12
        hazard.Zone.Transparency = 0.88
        hazard.Zone.Color = ACTIVE_COLOR
        hazard.Zone.CanTouch = true
    end
end

local function addFloorArc(root, room, index)
    local origin = room.Origin
    local horizontal = index % 2 == 0
    local size = horizontal and Vector3.new(68, 0.5, 11) or Vector3.new(11, 0.5, 68)
    local zoneSize = horizontal and Vector3.new(68, 4.8, 11) or Vector3.new(11, 4.8, 68)
    local angle = horizontal and 0 or math.rad(90)

    local base = part(
        root,
        "ArcConduitBase",
        size,
        CFrame.new(origin + Vector3.new(0, 0.85, 0)) * CFrame.Angles(0, angle, 0),
        Enum.Material.DiamondPlate,
        Color3.fromRGB(43, 49, 53),
        0,
        true
    )
    base.CanTouch = false

    local warning = part(
        root,
        "ArcWarningStrip",
        horizontal and Vector3.new(66, 0.18, 1.2) or Vector3.new(1.2, 0.18, 66),
        CFrame.new(origin + Vector3.new(0, 1.18, 0)),
        Enum.Material.Neon,
        IDLE_COLOR,
        0.62,
        false
    )
    warning.CanTouch = false

    local danger = part(
        root,
        "ArcField",
        horizontal and Vector3.new(64, 0.22, 8.5) or Vector3.new(8.5, 0.22, 64),
        CFrame.new(origin + Vector3.new(0, 1.32, 0)),
        Enum.Material.Neon,
        ACTIVE_COLOR,
        1,
        false
    )
    danger.CanTouch = false

    local zone = part(
        root,
        "ArcDamageZone",
        zoneSize,
        CFrame.new(origin + Vector3.new(0, 3.2, 0)),
        Enum.Material.ForceField,
        ACTIVE_COLOR,
        1,
        false
    )

    local hazard = {
        Id = "Arc-" .. index,
        DisplayName = "ARC GRID",
        Warning = warning,
        Danger = danger,
        Zone = zone,
        Damage = 14,
        Period = 7.0 + (index % 3) * 0.45,
        Telegraph = 1.15,
        ActiveDuration = 1.55,
        Phase = index * 0.73,
        Active = false,
        State = "Idle",
    }
    zone.Touched:Connect(function(hit)
        damageParticipant(hazard, hit)
    end)
    table.insert(hazards, hazard)
end

local function addSteamLane(root, room, index)
    local origin = room.Origin
    local side = index % 2 == 0 and -1 or 1
    local laneCenter = origin + Vector3.new(25 * side, 0, 0)

    local warning = part(
        root,
        "SteamWarningStrip",
        Vector3.new(14, 0.18, 62),
        CFrame.new(laneCenter + Vector3.new(0, 1.1, 0)),
        Enum.Material.Neon,
        IDLE_COLOR,
        0.62,
        false
    )
    warning.CanTouch = false

    local danger = part(
        root,
        "SteamCloud",
        Vector3.new(12, 7, 58),
        CFrame.new(laneCenter + Vector3.new(0, 4, 0)),
        Enum.Material.ForceField,
        Color3.fromRGB(214, 224, 226),
        1,
        false
    )
    danger.CanTouch = false

    for z = -25, 25, 10 do
        local vent = part(
            root,
            "SteamVent",
            Vector3.new(3.4, 1.2, 3.4),
            CFrame.new(laneCenter + Vector3.new(0, 1.3, z)),
            Enum.Material.Metal,
            Color3.fromRGB(71, 77, 80),
            0,
            true
        )
        vent.CanTouch = false
        local cap = part(
            root,
            "SteamVentGlow",
            Vector3.new(2.4, 0.16, 2.4),
            vent.CFrame * CFrame.new(0, 0.68, 0),
            Enum.Material.Neon,
            IDLE_COLOR,
            0.48,
            false
        )
        cap.CanTouch = false
    end

    local zone = part(
        root,
        "SteamDamageZone",
        Vector3.new(12, 8, 58),
        CFrame.new(laneCenter + Vector3.new(0, 4.5, 0)),
        Enum.Material.ForceField,
        ACTIVE_COLOR,
        1,
        false
    )

    local hazard = {
        Id = "Steam-" .. index,
        DisplayName = "PRESSURE VENT",
        Warning = warning,
        Danger = danger,
        Zone = zone,
        Damage = 11,
        Period = 6.4 + (index % 4) * 0.35,
        Telegraph = 1.35,
        ActiveDuration = 1.8,
        Phase = index * 0.91,
        Active = false,
        State = "Idle",
    }
    zone.Touched:Connect(function(hit)
        damageParticipant(hazard, hit)
    end)
    table.insert(hazards, hazard)
end

local function shouldHazard(room, index)
    if not room or not room.Origin then
        return false
    end
    if room.Type == "Treasure" or room.Type == "Shrine" then
        return false
    end
    if room.Type == "Boss" then
        return true
    end
    return index >= 2 and index % 2 == 0
end

local function updateHazards()
    if running then
        return
    end
    running = true
    task.spawn(function()
        while running do
            local now = os.clock()
            for _, hazard in ipairs(hazards) do
                if hazard.Zone.Parent then
                    local cycle = (now + hazard.Phase) % hazard.Period
                    local activeStart = hazard.Period - hazard.ActiveDuration
                    local telegraphStart = activeStart - hazard.Telegraph
                    local nextState = "Idle"
                    if cycle >= activeStart then
                        nextState = "Active"
                    elseif cycle >= telegraphStart then
                        nextState = "Telegraph"
                    end
                    if nextState ~= hazard.State then
                        setHazardState(hazard, nextState)
                    end
                end
            end
            task.wait(0.08)
        end
    end)
end

function EnvironmentalHazardService.Init(context)
    ctx = context
end

function EnvironmentalHazardService.Build()
    local old = Workspace:FindFirstChild(ROOT_NAME)
    if old then
        old:Destroy()
    end
    table.clear(hazards)

    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = Workspace

    for index, room in ipairs(ctx.World.GetRooms()) do
        if shouldHazard(room, index) then
            if index % 4 == 0 or room.Type == "Boss" then
                addFloorArc(root, room, index)
            else
                addSteamLane(root, room, index)
            end
        end
    end

    root:SetAttribute("GameplayHazards", #hazards)
    root:SetAttribute("Telegraphed", true)
    updateHazards()
end

return EnvironmentalHazardService
