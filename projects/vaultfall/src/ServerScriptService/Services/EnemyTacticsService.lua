local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local EnemyTacticsService = {}
local ctx
local states = {}
local accumulator = 0

local COLORS = {
    Shade = Color3.fromRGB(147, 112, 255),
    Archer = Color3.fromRGB(91, 224, 177),
    Brute = Color3.fromRGB(255, 128, 91),
    Elite = Color3.fromRGB(225, 112, 255),
}

local COOLDOWNS = {
    Shade = 5.4,
    Archer = 6.4,
    Brute = 7.2,
    Elite = 5.8,
}

local function getParticipants()
    if ctx.Run and ctx.Run.GetLivingParticipants then
        return ctx.Run.GetLivingParticipants()
    end
    return {}
end

local function getRoot(player)
    local character = player and player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 and root then
        return root, humanoid
    end
    return nil, nil
end

local function damagePlayer(player, amount)
    local _, humanoid = getRoot(player)
    if humanoid then
        humanoid:TakeDamage(math.max(1, math.floor(amount + 0.5)))
    end
end

local function makePart(name, size, cframe, color, transparency, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = transparency or 0
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Parent = parent or Workspace
    return part
end

local function warningDisc(position, radius, color, duration)
    local disc = makePart(
        "EnemyTelegraph",
        Vector3.new(0.12, radius * 2, radius * 2),
        CFrame.new(position + Vector3.new(0, 0.08, 0)) * CFrame.Angles(0, 0, math.rad(90)),
        color,
        0.58,
        Workspace
    )
    disc.Shape = Enum.PartType.Cylinder
    Debris:AddItem(disc, duration + 0.2)
    return disc
end

local function warningLine(startPosition, endPosition, width, color, duration)
    local delta = endPosition - startPosition
    local length = math.max(0.2, delta.Magnitude)
    local line = makePart(
        "EnemyTelegraphLine",
        Vector3.new(width, 0.14, length),
        CFrame.lookAt((startPosition + endPosition) * 0.5 + Vector3.new(0, 0.08, 0), endPosition + Vector3.new(0, 0.08, 0)),
        color,
        0.42,
        Workspace
    )
    Debris:AddItem(line, duration + 0.2)
    return line
end

local function burst(position, radius, color)
    local ring = warningDisc(position, 1.3, color, 0.4)
    ring.Transparency = 0.2
    local start = os.clock()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not ring.Parent then
            if connection then connection:Disconnect() end
            return
        end
        local alpha = math.clamp((os.clock() - start) / 0.35, 0, 1)
        local diameter = 2.6 + (radius * 2 - 2.6) * alpha
        ring.Size = Vector3.new(0.12, diameter, diameter)
        ring.Transparency = 0.2 + alpha * 0.72
        if alpha >= 1 and connection then
            connection:Disconnect()
        end
    end)
end

local function clampToRoom(enemy, position)
    local room = ctx.World and ctx.World.GetRoom and ctx.World.GetRoom(enemy.RoomIndex)
    if not room then
        return position
    end
    local limitX = ctx.Config.RoomSize.X / 2 - 7
    local limitZ = ctx.Config.RoomSize.Z / 2 - 7
    return Vector3.new(
        math.clamp(position.X, room.Origin.X - limitX, room.Origin.X + limitX),
        enemy.Root.Position.Y,
        math.clamp(position.Z, room.Origin.Z - limitZ, room.Origin.Z + limitZ)
    )
end

local function attachAccent(model, root, name, size, offset, color, rotation)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = 0.12
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    part.CastShadow = false
    part.CFrame = root.CFrame * CFrame.new(offset) * (rotation or CFrame.new())
    part.Parent = model

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = part
    weld.Parent = part
    return part
end

local function decorate(enemy)
    local color = COLORS[enemy.Type]
    if not color or enemy.Model:FindFirstChild("TacticsVisuals") then
        return
    end

    local folder = Instance.new("Folder")
    folder.Name = "TacticsVisuals"
    folder.Parent = enemy.Model

    local highlight = Instance.new("Highlight")
    highlight.Name = "ArchetypeOutline"
    highlight.Adornee = enemy.Model
    highlight.FillColor = color
    highlight.FillTransparency = 0.91
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0.28
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = folder

    local radius = enemy.Data.Radius
    if enemy.Type == "Shade" then
        attachAccent(folder, enemy.Root, "PhaseBladeL", Vector3.new(0.16, radius * 1.65, 0.22), Vector3.new(-radius * 0.7, radius * 0.55, 0.25), color, CFrame.Angles(0, 0, math.rad(-24)))
        attachAccent(folder, enemy.Root, "PhaseBladeR", Vector3.new(0.16, radius * 1.65, 0.22), Vector3.new(radius * 0.7, radius * 0.55, 0.25), color, CFrame.Angles(0, 0, math.rad(24)))
    elseif enemy.Type == "Archer" then
        attachAccent(folder, enemy.Root, "ArcRail", Vector3.new(radius * 2.1, 0.18, 0.18), Vector3.new(0, radius * 1.05, -radius * 0.55), color, CFrame.Angles(0, 0, math.rad(8)))
        attachAccent(folder, enemy.Root, "RangeCore", Vector3.new(0.42, 0.42, 0.42), Vector3.new(0, radius * 0.55, -radius * 0.72), color)
    elseif enemy.Type == "Brute" then
        attachAccent(folder, enemy.Root, "ShoulderL", Vector3.new(radius * 0.65, radius * 0.42, radius * 0.8), Vector3.new(-radius * 0.82, radius * 0.95, 0), color, CFrame.Angles(0, 0, math.rad(-12)))
        attachAccent(folder, enemy.Root, "ShoulderR", Vector3.new(radius * 0.65, radius * 0.42, radius * 0.8), Vector3.new(radius * 0.82, radius * 0.95, 0), color, CFrame.Angles(0, 0, math.rad(12)))
        attachAccent(folder, enemy.Root, "ImpactCore", Vector3.new(radius * 0.6, radius * 0.6, 0.2), Vector3.new(0, radius * 0.55, -radius * 0.66), color)
    elseif enemy.Type == "Elite" then
        attachAccent(folder, enemy.Root, "CrownL", Vector3.new(0.18, radius * 1.15, 0.18), Vector3.new(-radius * 0.48, radius * 1.48, 0), color, CFrame.Angles(0, 0, math.rad(-20)))
        attachAccent(folder, enemy.Root, "CrownR", Vector3.new(0.18, radius * 1.15, 0.18), Vector3.new(radius * 0.48, radius * 1.48, 0), color, CFrame.Angles(0, 0, math.rad(20)))
        attachAccent(folder, enemy.Root, "RiftCore", Vector3.new(radius * 0.72, radius * 0.72, 0.22), Vector3.new(0, radius * 0.65, -radius * 0.72), color)
    end

    local light = Instance.new("PointLight")
    light.Name = "ThreatGlow"
    light.Color = color
    light.Brightness = enemy.Type == "Elite" and 1.8 or 1.15
    light.Range = radius * 4.5
    light.Shadows = false
    light.Parent = enemy.Root
end

local function shadeLunge(enemy, targetRoot)
    local color = COLORS.Shade
    local targetPosition = targetRoot.Position
    local flatLook = Vector3.new(targetRoot.CFrame.LookVector.X, 0, targetRoot.CFrame.LookVector.Z)
    if flatLook.Magnitude < 0.01 then
        flatLook = Vector3.new(0, 0, -1)
    else
        flatLook = flatLook.Unit
    end
    local side = targetRoot.CFrame.RightVector * ((enemy.Id % 2 == 0) and 4.5 or -4.5)
    local destination = clampToRoom(enemy, targetPosition - flatLook * 5 + side)
    warningDisc(destination, 4.2, color, 0.45)
    warningLine(enemy.Root.Position, destination, 0.38, color, 0.45)

    task.delay(0.42, function()
        if not enemy.Alive or not enemy.Model.Parent then return end
        enemy.Model:PivotTo(CFrame.lookAt(destination, targetPosition))
        burst(destination, 6, color)
        local currentPosition = targetRoot.Parent and targetRoot.Position
        if currentPosition and (currentPosition - destination).Magnitude <= 6.2 then
            local player = game:GetService("Players"):GetPlayerFromCharacter(targetRoot.Parent)
            if player then damagePlayer(player, enemy.Damage * 0.8) end
        end
    end)
end

local function archerVolley(enemy)
    local color = COLORS.Archer
    local participants = getParticipants()
    table.sort(participants, function(a, b)
        local ar = getRoot(a)
        local br = getRoot(b)
        if not ar then return false end
        if not br then return true end
        return (ar.Position - enemy.Root.Position).Magnitude < (br.Position - enemy.Root.Position).Magnitude
    end)

    local targetCount = math.min(#participants, math.max(1, math.ceil(#participants * 0.7)))
    for index = 1, targetCount do
        local player = participants[index]
        local targetRoot = getRoot(player)
        if targetRoot then
            local velocity = targetRoot.AssemblyLinearVelocity
            local predicted = targetRoot.Position + Vector3.new(velocity.X, 0, velocity.Z) * 0.3
            warningDisc(predicted, 4.8, color, 0.78)
            warningLine(enemy.Root.Position + Vector3.new(0, 1.6, 0), predicted, 0.24, color, 0.78)
            task.delay(0.74, function()
                if not enemy.Alive then return end
                burst(predicted, 5.3, color)
                local liveRoot = getRoot(player)
                if liveRoot and (liveRoot.Position - predicted).Magnitude <= 5.1 then
                    damagePlayer(player, enemy.Damage * 0.92)
                end
            end)
        end
    end
end

local function bruteSlam(enemy)
    local color = COLORS.Brute
    local center = enemy.Root.Position
    local radius = 11.5
    warningDisc(center, radius, color, 0.95)
    task.delay(0.9, function()
        if not enemy.Alive or not enemy.Model.Parent then return end
        burst(center, radius + 2, color)
        for _, player in ipairs(getParticipants()) do
            local root = getRoot(player)
            if root then
                local offset = root.Position - center
                local flat = Vector3.new(offset.X, 0, offset.Z)
                if flat.Magnitude <= radius then
                    damagePlayer(player, enemy.Damage * 1.18)
                    if flat.Magnitude > 0.1 then
                        root.AssemblyLinearVelocity += flat.Unit * 28 + Vector3.new(0, 10, 0)
                    end
                end
            end
        end
    end)
end

local function distanceToSegment(point, a, b)
    local ab = b - a
    local lengthSquared = ab:Dot(ab)
    if lengthSquared <= 0.001 then
        return (point - a).Magnitude
    end
    local t = math.clamp((point - a):Dot(ab) / lengthSquared, 0, 1)
    return (point - (a + ab * t)).Magnitude
end

local function eliteRiftDash(enemy, targetRoot)
    local color = COLORS.Elite
    local startPosition = enemy.Root.Position
    local delta = targetRoot.Position - startPosition
    local flat = Vector3.new(delta.X, 0, delta.Z)
    if flat.Magnitude < 1 then return end
    local distance = math.min(24, math.max(12, flat.Magnitude * 0.82))
    local destination = clampToRoom(enemy, startPosition + flat.Unit * distance)
    warningLine(startPosition, destination, 2.6, color, 0.7)
    warningDisc(destination, 5, color, 0.7)

    task.delay(0.66, function()
        if not enemy.Alive or not enemy.Model.Parent then return end
        enemy.Model:PivotTo(CFrame.lookAt(destination, destination + flat.Unit))
        burst(destination, 8, color)
        for _, player in ipairs(getParticipants()) do
            local root = getRoot(player)
            if root and distanceToSegment(root.Position, startPosition, destination) <= 4.8 then
                damagePlayer(player, enemy.Damage * 1.05)
            end
        end
    end)
end

local function trySpecial(enemy, state, now)
    if now < state.NextSpecial then
        return
    end

    local participants = getParticipants()
    if #participants == 0 then
        state.NextSpecial = now + 2
        return
    end

    local nearestPlayer
    local nearestRoot
    local nearestDistance = math.huge
    for _, player in ipairs(participants) do
        local root = getRoot(player)
        if root then
            local distance = (root.Position - enemy.Root.Position).Magnitude
            if distance < nearestDistance then
                nearestPlayer = player
                nearestRoot = root
                nearestDistance = distance
            end
        end
    end
    if not nearestPlayer or not nearestRoot then return end

    local fired = false
    if enemy.Type == "Shade" and nearestDistance >= 9 and nearestDistance <= 28 then
        shadeLunge(enemy, nearestRoot)
        fired = true
    elseif enemy.Type == "Archer" and nearestDistance <= 42 then
        archerVolley(enemy)
        fired = true
    elseif enemy.Type == "Brute" and nearestDistance <= 13.5 then
        bruteSlam(enemy)
        fired = true
    elseif enemy.Type == "Elite" and nearestDistance >= 7 and nearestDistance <= 32 then
        eliteRiftDash(enemy, nearestRoot)
        fired = true
    end

    state.NextSpecial = now + (COOLDOWNS[enemy.Type] or 7) + ((enemy.Id % 5) * 0.17) + (fired and 0 or 1.5)
end

function EnemyTacticsService.Init(context)
    ctx = context
    RunService.Heartbeat:Connect(function(dt)
        accumulator += dt
        if accumulator < 0.2 then return end
        accumulator = 0

        local liveIds = {}
        local now = os.clock()
        for id, enemy in pairs(ctx.Enemies.GetAll()) do
            liveIds[id] = true
            if COLORS[enemy.Type] and enemy.Alive and enemy.Model.Parent then
                local state = states[id]
                if not state then
                    state = {
                        NextSpecial = now + 2.2 + ((id % 7) * 0.24),
                    }
                    states[id] = state
                    decorate(enemy)
                end
                trySpecial(enemy, state, now)
            end
        end

        for id in pairs(states) do
            if not liveIds[id] then
                states[id] = nil
            end
        end
    end)
end

return EnemyTacticsService