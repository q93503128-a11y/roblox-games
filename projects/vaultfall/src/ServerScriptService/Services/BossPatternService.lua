local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local BossPatternService = {}
local ctx
local states = {}
local accumulator = 0

local TELEGRAPH_COLOR = Color3.fromRGB(255, 103, 92)
local HVT_COLOR = Color3.fromRGB(255, 190, 91)

local function livingParticipants()
    if ctx.Run and ctx.Run.GetLivingParticipants then
        return ctx.Run.GetLivingParticipants()
    end
    return {}
end

local function damagePlayer(player, amount)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:TakeDamage(amount)
    end
end

local function getRoot(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 then
        return root
    end
    return nil
end

local function makeVisualPart(parent, name, size, cframe, color, transparency)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = transparency
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Parent = parent
    return part
end

local function addRingSegments(parent, position, radius, color)
    local segmentCount = 12
    local circumference = math.pi * 2 * radius
    local segmentLength = math.max(0.75, circumference / segmentCount * 0.66)
    for i = 1, segmentCount do
        local angle = ((i - 1) / segmentCount) * math.pi * 2
        local radial = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local center = position + radial * radius + Vector3.new(0, 0.07, 0)
        local tangent = Vector3.new(-math.sin(angle), 0, math.cos(angle))
        local cframe = CFrame.lookAt(center, center + tangent)
        local segment = makeVisualPart(
            parent,
            "TelegraphRim",
            Vector3.new(0.18, 0.08, segmentLength),
            cframe,
            color,
            0.16
        )
        segment:SetAttribute("TelegraphEdge", true)
    end
end

local function addLaneEdges(parent, center, flat, length, width, color)
    local right = Vector3.new(-flat.Z, 0, flat.X)
    for _, side in ipairs({ -1, 1 }) do
        local edgeCenter = center + right * (width * 0.5 * side) + Vector3.new(0, 0.08, 0)
        local edge = makeVisualPart(
            parent,
            "TelegraphEdge",
            Vector3.new(0.16, 0.08, length),
            CFrame.lookAt(edgeCenter, edgeCenter + flat),
            color,
            0.14
        )
        edge:SetAttribute("TelegraphEdge", true)
    end

    local tickCount = math.max(2, math.floor(length / 10))
    for i = 1, tickCount do
        local t = i / (tickCount + 1)
        local tickCenter = center - flat * (length * 0.5) + flat * (length * t) + Vector3.new(0, 0.07, 0)
        local tick = makeVisualPart(
            parent,
            "TelegraphTick",
            Vector3.new(math.max(1.4, width * 0.45), 0.06, 0.14),
            CFrame.lookAt(tickCenter, tickCenter + flat),
            color,
            0.3
        )
        tick:SetAttribute("TelegraphEdge", true)
    end
end

local function setTelegraphEdges(part, color, transparency)
    for _, child in ipairs(part:GetDescendants()) do
        if child:IsA("BasePart") and child:GetAttribute("TelegraphEdge") == true then
            child.Color = color
            TweenService:Create(child, TweenInfo.new(0.18), { Transparency = transparency }):Play()
        end
    end
end

local function makeDisc(name, position, radius, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(0.12, radius * 2, radius * 2)
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = 0.82
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    part.Parent = Workspace
    addRingSegments(part, position, radius, color)
    return part
end

local function makeLane(name, origin, direction, length, width, color)
    local flat = Vector3.new(direction.X, 0, direction.Z)
    if flat.Magnitude < 0.01 then
        flat = Vector3.new(0, 0, -1)
    end
    flat = flat.Unit

    local center = origin + flat * (length * 0.5)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = Vector3.new(width, 0.12, length)
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = 0.84
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.CFrame = CFrame.lookAt(center, center + flat) * CFrame.new(0, -1.65, 0)
    part.Parent = Workspace
    addLaneEdges(part, part.Position, flat, length, width, color)
    return part, flat
end

local function distanceToSegment(point, startPoint, endPoint)
    local segment = endPoint - startPoint
    local lengthSquared = segment:Dot(segment)
    if lengthSquared <= 0.001 then
        return (point - startPoint).Magnitude
    end
    local t = math.clamp((point - startPoint):Dot(segment) / lengthSquared, 0, 1)
    local closest = startPoint + segment * t
    return (point - closest).Magnitude
end

local function targetedBarrage(enemy, count, radius, delayTime, damageScale)
    local players = livingParticipants()
    if #players == 0 then
        return
    end

    local marks = {}
    for i = 1, math.min(count, #players) do
        local player = players[((i - 1) % #players) + 1]
        local root = getRoot(player)
        if root then
            local position = Vector3.new(root.Position.X, enemy.Root.Position.Y - 1.45, root.Position.Z)
            local disc = makeDisc("WardenTarget", position, radius, TELEGRAPH_COLOR)
            table.insert(marks, { Player = player, Position = position, Disc = disc })
            TweenService:Create(disc, TweenInfo.new(delayTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Transparency = 0.66,
            }):Play()
        end
    end

    task.delay(delayTime, function()
        if not enemy.Alive then
            for _, mark in ipairs(marks) do
                if mark.Disc.Parent then mark.Disc:Destroy() end
            end
            return
        end

        for _, mark in ipairs(marks) do
            local blast = mark.Disc
            if blast.Parent then
                blast.Color = Color3.fromRGB(255, 71, 71)
                blast.Transparency = 0.44
                setTelegraphEdges(blast, Color3.fromRGB(255, 71, 71), 0.02)
                TweenService:Create(blast, TweenInfo.new(0.22), {
                    Size = Vector3.new(0.12, radius * 2.18, radius * 2.18),
                    Transparency = 1,
                }):Play()
            end

            for _, player in ipairs(livingParticipants()) do
                local root = getRoot(player)
                if root then
                    local flat = Vector3.new(root.Position.X - mark.Position.X, 0, root.Position.Z - mark.Position.Z)
                    if flat.Magnitude <= radius then
                        damagePlayer(player, math.floor(enemy.Damage * damageScale + 0.5))
                    end
                end
            end

            task.delay(0.25, function()
                if blast.Parent then blast:Destroy() end
            end)
        end
    end)
end

local function laneStrike(enemy, targetRoot, width, length, delayTime, damageScale, color)
    if not targetRoot then
        return
    end

    local origin = enemy.Root.Position
    local direction = targetRoot.Position - origin
    local lane, flat = makeLane("ThreatLane", origin, direction, length, width, color or TELEGRAPH_COLOR)
    TweenService:Create(lane, TweenInfo.new(delayTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 0.68,
    }):Play()

    task.delay(delayTime, function()
        if not enemy.Alive then
            if lane.Parent then lane:Destroy() end
            return
        end

        local startPoint = origin
        local endPoint = origin + flat * length
        lane.Color = Color3.fromRGB(255, 68, 68)
        lane.Transparency = 0.38
        setTelegraphEdges(lane, Color3.fromRGB(255, 68, 68), 0)

        for _, player in ipairs(livingParticipants()) do
            local root = getRoot(player)
            if root then
                local point = Vector3.new(root.Position.X, origin.Y, root.Position.Z)
                if distanceToSegment(point, startPoint, endPoint) <= width * 0.55 then
                    damagePlayer(player, math.floor(enemy.Damage * damageScale + 0.5))
                end
            end
        end

        TweenService:Create(lane, TweenInfo.new(0.2), { Transparency = 1 }):Play()
        setTelegraphEdges(lane, Color3.fromRGB(255, 68, 68), 1)
        task.delay(0.22, function()
            if lane.Parent then lane:Destroy() end
        end)
    end)
end

local function shockwave(enemy, radius, delayTime, damageScale, color)
    local position = enemy.Root.Position - Vector3.new(0, 1.5, 0)
    local disc = makeDisc("ThreatShockwave", position, radius, color or HVT_COLOR)
    disc.Size = Vector3.new(0.12, 2, 2)
    TweenService:Create(disc, TweenInfo.new(delayTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.12, radius * 2, radius * 2),
        Transparency = 0.7,
    }):Play()

    task.delay(delayTime, function()
        if not enemy.Alive then
            if disc.Parent then disc:Destroy() end
            return
        end

        for _, player in ipairs(livingParticipants()) do
            local root = getRoot(player)
            if root then
                local flat = Vector3.new(root.Position.X - position.X, 0, root.Position.Z - position.Z)
                if flat.Magnitude <= radius then
                    damagePlayer(player, math.floor(enemy.Damage * damageScale + 0.5))
                end
            end
        end

        disc.Color = Color3.fromRGB(255, 83, 70)
        setTelegraphEdges(disc, Color3.fromRGB(255, 83, 70), 0.02)
        TweenService:Create(disc, TweenInfo.new(0.22), { Transparency = 1 }):Play()
        setTelegraphEdges(disc, Color3.fromRGB(255, 83, 70), 1)
        task.delay(0.24, function()
            if disc.Parent then disc:Destroy() end
        end)
    end)
end

local function crossSweep(enemy, phase)
    local count = phase >= 3 and 4 or 2
    local angleOffset = math.rad((enemy.Id * 31) % 90)
    local delayTime = phase >= 3 and 0.72 or 0.9
    for i = 1, count do
        local angle = angleOffset + ((i - 1) * math.pi / count)
        local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
        local pseudoTarget = {
            Position = enemy.Root.Position + direction * 30,
        }
        laneStrike(enemy, pseudoTarget, phase >= 3 and 5.5 or 4.5, 42, delayTime, phase >= 3 and 1.15 or 0.95, TELEGRAPH_COLOR)
    end
end

local function getNearestRoot(enemy)
    local nearestRoot
    local nearestDistance = math.huge
    for _, player in ipairs(livingParticipants()) do
        local root = getRoot(player)
        if root then
            local distance = (root.Position - enemy.Root.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestRoot = root
            end
        end
    end
    return nearestRoot
end

local function stepBoss(enemy, state, now)
    local healthFraction = enemy.MaxHealth > 0 and enemy.Health / enemy.MaxHealth or 1
    local phase = healthFraction <= 0.33 and 3 or healthFraction <= 0.66 and 2 or 1
    state.Phase = phase

    if now < state.NextPattern then
        return
    end

    state.Sequence += 1
    if phase == 1 then
        if state.Sequence % 2 == 0 then
            targetedBarrage(enemy, 2, 6.5, 1.0, 1.05)
        else
            laneStrike(enemy, getNearestRoot(enemy), 4.5, 44, 0.9, 1.0, TELEGRAPH_COLOR)
        end
        state.NextPattern = now + 5.4
    elseif phase == 2 then
        if state.Sequence % 3 == 0 then
            shockwave(enemy, 17, 0.9, 1.05, TELEGRAPH_COLOR)
        elseif state.Sequence % 2 == 0 then
            targetedBarrage(enemy, 3, 7, 0.85, 1.1)
        else
            crossSweep(enemy, phase)
        end
        state.NextPattern = now + 4.4
    else
        if state.Sequence % 3 == 0 then
            targetedBarrage(enemy, 4, 7.5, 0.7, 1.2)
        elseif state.Sequence % 2 == 0 then
            crossSweep(enemy, phase)
        else
            shockwave(enemy, 20, 0.72, 1.2, TELEGRAPH_COLOR)
        end
        state.NextPattern = now + 3.5
    end
end

local function stepHVT(enemy, state, now)
    if now < state.NextPattern then
        return
    end

    if enemy.Type == "Huntsman" then
        laneStrike(enemy, getNearestRoot(enemy), 3.8, 52, 1.05, 1.18, HVT_COLOR)
        state.NextPattern = now + 5.8
    elseif enemy.Type == "Bulwark" then
        shockwave(enemy, 13, 0.95, 1.08, HVT_COLOR)
        state.NextPattern = now + 6.3
    elseif enemy.Type == "Reaper" then
        laneStrike(enemy, getNearestRoot(enemy), 6.2, 30, 0.58, 1.25, HVT_COLOR)
        state.NextPattern = now + 4.6
    end
end

local function tickPatterns()
    local aliveIds = {}
    for id, enemy in pairs(ctx.Enemies.GetAll()) do
        aliveIds[id] = true
        if enemy.Alive and (enemy.Data.Boss or enemy.Data.HVT) then
            local state = states[id]
            if not state then
                state = {
                    NextPattern = os.clock() + (enemy.Data.Boss and 2.8 or 3.6),
                    Sequence = 0,
                    Phase = 1,
                }
                states[id] = state
            end

            local now = os.clock()
            if enemy.Data.Boss then
                stepBoss(enemy, state, now)
            else
                stepHVT(enemy, state, now)
            end
        end
    end

    for id in pairs(states) do
        if not aliveIds[id] then
            states[id] = nil
        end
    end
end

function BossPatternService.Init(context)
    ctx = context
    RunService.Heartbeat:Connect(function(dt)
        accumulator += dt
        if accumulator < 0.2 then
            return
        end
        accumulator = 0
        tickPatterns()
    end)
end

return BossPatternService
