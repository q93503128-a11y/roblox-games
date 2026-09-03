local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local EncounterDirector = {}
local ctx
local accumulator = 0
local roomToken = 0
local activeRoom = 0
local nextPatternAt = 0
local lastBossPhase = 0
local rng = Random.new()

local function effectsFolder()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    if not world then
        return Workspace
    end
    local folder = world:FindFirstChild("EncounterEffects")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "EncounterEffects"
        folder.Parent = world
    end
    return folder
end

local function livingPlayers()
    if not ctx.Run or not ctx.Run.GetLivingParticipants then
        return {}
    end
    return ctx.Run.GetLivingParticipants()
end

local function rootOf(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and root and humanoid.Health > 0 then
        return root, humanoid
    end
    return nil
end

local function damageNear(position, radius, amount)
    for _, player in ipairs(livingPlayers()) do
        local root, humanoid = rootOf(player)
        if root and humanoid and (root.Position - position).Magnitude <= radius then
            humanoid:TakeDamage(amount)
        end
    end
end

local function notice(text)
    for _, player in ipairs(livingPlayers()) do
        ctx.Remotes.State:FireClient(player, "Notice", text)
    end
end

local function makeDisc(position, radius, color, transparency)
    local disc = Instance.new("Part")
    disc.Name = "TelegraphDisc"
    disc.Shape = Enum.PartType.Cylinder
    disc.Size = Vector3.new(0.16, radius * 2, radius * 2)
    disc.Material = Enum.Material.Neon
    disc.Color = color
    disc.Transparency = transparency or 0.45
    disc.Anchored = true
    disc.CanCollide = false
    disc.CanTouch = false
    disc.CFrame = CFrame.new(position + Vector3.new(0, 0.12, 0)) * CFrame.Angles(0, 0, math.rad(90))
    disc.Parent = effectsFolder()
    return disc
end

local function mortarStrike(token, position, damage, radius)
    local warning = makeDisc(position, radius, Color3.fromRGB(226, 108, 72), 0.5)
    warning.Size = Vector3.new(0.14, 1.4, 1.4)
    TweenService:Create(warning, TweenInfo.new(0.95, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.14, radius * 2, radius * 2),
        Transparency = 0.18,
    }):Play()

    task.delay(1.0, function()
        if token ~= roomToken or not ctx.Run.IsActive() then
            if warning.Parent then warning:Destroy() end
            return
        end
        if warning.Parent then warning:Destroy() end

        local blast = makeDisc(position, radius, Color3.fromRGB(255, 164, 86), 0.1)
        blast.Size = Vector3.new(0.22, radius * 2, radius * 2)
        TweenService:Create(blast, TweenInfo.new(0.22), { Transparency = 1 }):Play()
        Debris:AddItem(blast, 0.26)
        damageNear(position, radius, damage)
    end)
end

local function targetedMortars(token, count, damage, radius, spacing)
    local players = livingPlayers()
    if #players == 0 then
        return
    end
    for index = 1, count do
        task.delay((index - 1) * spacing, function()
            if token ~= roomToken or not ctx.Run.IsActive() then
                return
            end
            local target = players[((index - 1) % #players) + 1]
            local root = rootOf(target)
            if root then
                local jitter = Vector3.new(rng:NextNumber(-5, 5), 0, rng:NextNumber(-5, 5))
                mortarStrike(token, root.Position + jitter, damage, radius)
            end
        end)
    end
end

local function sweepLaser(token, room, damage, duration, width)
    local center = room.Origin + Vector3.new(0, 0.45, 0)
    local length = math.max(ctx.Config.RoomSize.X, ctx.Config.RoomSize.Z) * 0.94
    local beam = Instance.new("Part")
    beam.Name = "SweepLaser"
    beam.Size = Vector3.new(width, 0.2, length)
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(220, 78, 86)
    beam.Transparency = 0.72
    beam.Anchored = true
    beam.CanCollide = false
    beam.CanTouch = false
    beam.CFrame = CFrame.new(center)
    beam.Parent = effectsFolder()

    local warningDuration = 0.8
    TweenService:Create(beam, TweenInfo.new(warningDuration), { Transparency = 0.25 }):Play()
    task.delay(warningDuration, function()
        if token ~= roomToken or not ctx.Run.IsActive() or not beam.Parent then
            if beam.Parent then beam:Destroy() end
            return
        end

        local start = os.clock()
        local alreadyHit = {}
        local connection
        connection = RunService.Heartbeat:Connect(function()
            if token ~= roomToken or not ctx.Run.IsActive() or not beam.Parent then
                if connection then connection:Disconnect() end
                if beam.Parent then beam:Destroy() end
                return
            end
            local elapsed = os.clock() - start
            if elapsed >= duration then
                if connection then connection:Disconnect() end
                if beam.Parent then beam:Destroy() end
                return
            end

            local angle = (elapsed / duration) * math.pi * 1.45 - math.pi * 0.72
            beam.CFrame = CFrame.new(center) * CFrame.Angles(0, angle, 0)
            for _, player in ipairs(livingPlayers()) do
                if not alreadyHit[player] then
                    local root, humanoid = rootOf(player)
                    if root and humanoid then
                        local localPos = beam.CFrame:PointToObjectSpace(root.Position)
                        if math.abs(localPos.X) <= width * 0.75 and math.abs(localPos.Z) <= length * 0.5 and math.abs(localPos.Y) <= 5 then
                            alreadyHit[player] = true
                            humanoid:TakeDamage(damage)
                        end
                    end
                end
            end
        end)
    end)
end

local function shockwave(token, position, damage, maxRadius)
    local ring = makeDisc(position, 1.5, Color3.fromRGB(111, 171, 225), 0.32)
    local duration = 0.78
    TweenService:Create(ring, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.18, maxRadius * 2, maxRadius * 2),
        Transparency = 0.72,
    }):Play()

    task.delay(duration, function()
        if token ~= roomToken or not ctx.Run.IsActive() then
            if ring.Parent then ring:Destroy() end
            return
        end
        damageNear(position, maxRadius, damage)
        if ring.Parent then ring:Destroy() end
    end)
end

local function bossInfo()
    for _, enemy in pairs(ctx.Enemies.GetAll()) do
        if enemy.Alive and enemy.Data and enemy.Data.Boss and enemy.RoomIndex == ctx.Run.GetCurrentRoom() then
            return enemy
        end
    end
    return nil
end

local function runBossPattern(token, room)
    local boss = bossInfo()
    if not boss then
        return 2.5
    end

    local healthRatio = boss.MaxHealth > 0 and boss.Health / boss.MaxHealth or 1
    local phase = healthRatio > 0.66 and 1 or (healthRatio > 0.33 and 2 or 3)
    if phase ~= lastBossPhase then
        lastBossPhase = phase
        if phase == 2 then
            notice("WARDEN PHASE II — CROSS-FIRE PROTOCOL")
        elseif phase == 3 then
            notice("WARDEN PHASE III — CONTAINMENT FAILURE")
        end
    end

    if phase == 1 then
        shockwave(token, boss.Root.Position, math.floor(boss.Damage * 0.75), 17)
        targetedMortars(token, 2, math.floor(boss.Damage * 0.68), 6.5, 0.55)
        return 5.3
    elseif phase == 2 then
        sweepLaser(token, room, math.floor(boss.Damage * 0.72), 2.1, 3.5)
        task.delay(1.2, function()
            if token == roomToken and ctx.Run.IsActive() then
                sweepLaser(token, room, math.floor(boss.Damage * 0.66), 1.8, 3.0)
            end
        end)
        targetedMortars(token, 3, math.floor(boss.Damage * 0.62), 6.0, 0.45)
        return 5.8
    else
        shockwave(token, boss.Root.Position, math.floor(boss.Damage * 0.82), 21)
        targetedMortars(token, 5, math.floor(boss.Damage * 0.68), 6.2, 0.34)
        task.delay(0.85, function()
            if token == roomToken and ctx.Run.IsActive() then
                sweepLaser(token, room, math.floor(boss.Damage * 0.78), 1.55, 4.0)
            end
        end)
        return 4.6
    end
end

local function runAmbientPattern(token, room, roomType)
    if roomType == "Elite" then
        notice("HOSTILE ARTILLERY LOCK")
        targetedMortars(token, 3, 17, 6.2, 0.48)
        return rng:NextNumber(8.5, 11.0)
    elseif roomType == "DeepCombat" then
        if rng:NextNumber() < 0.55 then
            sweepLaser(token, room, 16, 1.75, 3.3)
        else
            targetedMortars(token, 4, 15, 5.8, 0.38)
        end
        return rng:NextNumber(8.0, 10.5)
    elseif roomType == "Combat" and activeRoom >= 6 then
        targetedMortars(token, 2, 13, 5.5, 0.52)
        return rng:NextNumber(10.0, 13.5)
    end
    return 4.0
end

local function step()
    if not ctx.Run.IsActive() then
        activeRoom = 0
        lastBossPhase = 0
        nextPatternAt = 0
        return
    end

    local roomIndex = ctx.Run.GetCurrentRoom()
    if roomIndex <= 0 then
        return
    end
    if roomIndex ~= activeRoom then
        activeRoom = roomIndex
        roomToken += 1
        lastBossPhase = 0
        nextPatternAt = os.clock() + 4.0
    end

    if os.clock() < nextPatternAt then
        return
    end

    local room = ctx.World.GetRoom(roomIndex)
    if not room then
        nextPatternAt = os.clock() + 3
        return
    end
    local roomType = ctx.Config.RoomSequence[roomIndex] or room.Type
    local token = roomToken
    local delaySeconds
    if roomType == "Boss" then
        delaySeconds = runBossPattern(token, room)
    else
        delaySeconds = runAmbientPattern(token, room, roomType)
    end
    nextPatternAt = os.clock() + (delaySeconds or 4)
end

function EncounterDirector.Init(context)
    ctx = context
    RunService.Heartbeat:Connect(function(dt)
        accumulator += dt
        if accumulator < 0.2 then
            return
        end
        accumulator = 0
        step()
    end)
end

return EncounterDirector
