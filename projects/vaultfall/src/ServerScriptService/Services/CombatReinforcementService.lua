local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CombatReinforcementService = {}
local ctx
local accumulator = 0
local activeRoom = 0
local roomEnteredAt = 0
local responseUsed = false
local responseToken = 0
local drones = {}
local rng = Random.new()

local ROOM_TUNING = {
    Combat = {
        Color = Color3.fromRGB(86, 174, 210),
        DamageBonus = 0,
        Lifetime = 10.5,
        FireDelay = 2.8,
    },
    DeepCombat = {
        Color = Color3.fromRGB(225, 132, 74),
        DamageBonus = 2,
        Lifetime = 12.0,
        FireDelay = 2.55,
    },
    Elite = {
        Color = Color3.fromRGB(211, 78, 118),
        DamageBonus = 4,
        Lifetime = 13.0,
        FireDelay = 2.3,
    },
}

local function effectsFolder()
    local folder = Workspace:FindFirstChild("VaultfallReinforcementPressure")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "VaultfallReinforcementPressure"
        folder.Parent = Workspace
    end
    return folder
end

local function livingPlayers()
    if not ctx.Run or not ctx.Run.GetLivingParticipants then
        return {}
    end
    return ctx.Run.GetLivingParticipants()
end

local function rootAndHumanoid(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if humanoid and root and humanoid.Health > 0 then
        return root, humanoid
    end
    return nil
end

local function aliveEnemyCount(roomIndex)
    local count = 0
    for _, enemy in pairs(ctx.Enemies.GetAll()) do
        if enemy.Alive and enemy.RoomIndex == roomIndex then
            count += 1
        end
    end
    return count
end

local function broadcast(text)
    for _, player in ipairs(livingPlayers()) do
        ctx.Remotes.State:FireClient(player, "Notice", text)
    end
end

local function makePart(name, size, cframe, material, color, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Material = material
    part.Color = color
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.Parent = parent
    return part
end

local function pulseRing(position, color, startRadius, endRadius, duration)
    local ring = makePart(
        "ResponseRing",
        Vector3.new(0.16, startRadius * 2, startRadius * 2),
        CFrame.new(position + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.rad(90)),
        Enum.Material.Neon,
        color,
        effectsFolder()
    )
    ring.Shape = Enum.PartType.Cylinder
    ring.Transparency = 0.3
    TweenService:Create(ring, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.16, endRadius * 2, endRadius * 2),
        Transparency = 1,
    }):Play()
    Debris:AddItem(ring, duration + 0.05)
end

local function nearestPlayer(position)
    local bestPlayer
    local bestDistance = math.huge
    for _, player in ipairs(livingPlayers()) do
        local root = rootAndHumanoid(player)
        if root then
            local distance = (root.Position - position).Magnitude
            if distance < bestDistance then
                bestPlayer = player
                bestDistance = distance
            end
        end
    end
    return bestPlayer
end

local function predictedPosition(root)
    local velocity = root.AssemblyLinearVelocity
    local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
    if horizontal.Magnitude > 24 then
        horizontal = horizontal.Unit * 24
    end
    return root.Position + horizontal * 0.32
end

local function dissolveDrone(drone, disrupted)
    if not drone.Active then
        return
    end
    drone.Active = false

    if drone.Prompt then
        drone.Prompt.Enabled = false
    end
    if drone.Model and drone.Model.Parent then
        pulseRing(drone.Core.Position, drone.Color, 2.5, disrupted and 12 or 8, 0.32)
        for _, descendant in ipairs(drone.Model:GetDescendants()) do
            if descendant:IsA("BasePart") then
                TweenService:Create(descendant, TweenInfo.new(0.28), {
                    Transparency = 1,
                }):Play()
            end
        end
        task.delay(0.32, function()
            if drone.Model then
                drone.Model:Destroy()
            end
        end)
    end
end

local function fireAtPlayer(drone, player, token)
    if not drone.Active or token ~= responseToken then
        return
    end
    local root, humanoid = rootAndHumanoid(player)
    if not root or not humanoid then
        return
    end

    local target = predictedPosition(root)
    local origin = drone.Core.Position
    local delta = target - origin
    local distance = delta.Magnitude
    if distance < 0.1 then
        return
    end

    local beam = makePart(
        "ResponseAimLine",
        Vector3.new(0.16, 0.16, distance),
        CFrame.lookAt(origin, target) * CFrame.new(0, 0, -distance * 0.5),
        Enum.Material.Neon,
        drone.Color,
        effectsFolder()
    )
    beam.Transparency = 0.72

    local marker = makePart(
        "ResponseTarget",
        Vector3.new(0.12, 2.2, 2.2),
        CFrame.new(target - Vector3.new(0, 2.6, 0)) * CFrame.Angles(0, 0, math.rad(90)),
        Enum.Material.Neon,
        drone.Color,
        effectsFolder()
    )
    marker.Shape = Enum.PartType.Cylinder
    marker.Transparency = 0.38

    TweenService:Create(beam, TweenInfo.new(0.68), { Transparency = 0.22 }):Play()
    TweenService:Create(marker, TweenInfo.new(0.68), {
        Size = Vector3.new(0.12, 7.5, 7.5),
        Transparency = 0.14,
    }):Play()

    task.delay(0.72, function()
        if beam.Parent then
            beam:Destroy()
        end
        if marker.Parent then
            marker:Destroy()
        end
        if not drone.Active or token ~= responseToken or not ctx.Run.IsActive() then
            return
        end

        local currentRoot, currentHumanoid = rootAndHumanoid(player)
        if currentRoot and currentHumanoid and (currentRoot.Position - target).Magnitude <= 4.2 then
            currentHumanoid:TakeDamage(drone.Damage)
        end
        pulseRing(target - Vector3.new(0, 2.4, 0), drone.Color, 1.2, 5.2, 0.18)
    end)
end

local function buildDrone(position, tuning, index, token)
    local model = Instance.new("Model")
    model.Name = string.format("SecurityResponseDrone_%d", index)
    model.Parent = effectsFolder()

    local startPosition = position + Vector3.new(0, 15 + index * 2, 0)
    local core = makePart(
        "DroneCore",
        Vector3.new(2.8, 2.8, 2.8),
        CFrame.new(startPosition),
        Enum.Material.Neon,
        tuning.Color,
        model
    )
    core.Shape = Enum.PartType.Ball
    core.Transparency = 0.12

    for arm = 0, 3 do
        local angle = math.rad(arm * 90)
        local plate = makePart(
            "Stabilizer",
            Vector3.new(4.8, 0.45, 1.15),
            CFrame.new(startPosition) * CFrame.Angles(0, angle, 0) * CFrame.new(2.35, 0, 0),
            Enum.Material.Metal,
            Color3.fromRGB(48, 55, 62),
            model
        )
        plate.Transparency = 0.02
    end

    local halo = makePart(
        "DroneHalo",
        Vector3.new(0.22, 6.4, 6.4),
        CFrame.new(startPosition) * CFrame.Angles(0, 0, math.rad(90)),
        Enum.Material.Neon,
        tuning.Color,
        model
    )
    halo.Shape = Enum.PartType.Cylinder
    halo.Transparency = 0.28

    local light = Instance.new("PointLight")
    light.Color = tuning.Color
    light.Brightness = 2.5
    light.Range = 16
    light.Parent = core

    pulseRing(position, tuning.Color, 2, 11, 1.0)
    local column = makePart(
        "InsertionColumn",
        Vector3.new(1.25, 18, 1.25),
        CFrame.new(position + Vector3.new(0, 9, 0)),
        Enum.Material.Neon,
        tuning.Color,
        effectsFolder()
    )
    column.Transparency = 0.58
    TweenService:Create(column, TweenInfo.new(1.0), { Transparency = 1 }):Play()
    Debris:AddItem(column, 1.05)

    local drone = {
        Model = model,
        Core = core,
        Color = tuning.Color,
        Active = false,
        Prompt = nil,
        Damage = 0,
        NextShotAt = math.huge,
        ExpiresAt = math.huge,
        FireDelay = tuning.FireDelay,
        HoverBase = position + Vector3.new(0, 6.5 + index * 0.45, 0),
        Phase = rng:NextNumber(0, math.pi * 2),
    }
    table.insert(drones, drone)

    task.delay(0.92, function()
        if token ~= responseToken or not ctx.Run.IsActive() or activeRoom ~= ctx.Run.GetCurrentRoom() then
            if model.Parent then
                model:Destroy()
            end
            return
        end

        model:PivotTo(CFrame.new(drone.HoverBase))
        drone.Active = true
        drone.Damage = math.floor(7 + activeRoom * 0.82 + tuning.DamageBonus + 0.5)
        drone.NextShotAt = os.clock() + 1.15 + index * 0.28
        drone.ExpiresAt = os.clock() + tuning.Lifetime

        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "DisruptPrompt"
        prompt.ActionText = "DISRUPT"
        prompt.ObjectText = "Response drone"
        prompt.HoldDuration = 0.65
        prompt.MaxActivationDistance = 8.5
        prompt.RequiresLineOfSight = true
        prompt.Parent = core
        drone.Prompt = prompt
        prompt.Triggered:Connect(function(player)
            if not drone.Active or not ctx.Run.IsParticipant(player) then
                return
            end
            local root, humanoid = rootAndHumanoid(player)
            if not root or not humanoid or (root.Position - core.Position).Magnitude > 10 then
                return
            end
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.06)
            ctx.Remotes.State:FireClient(player, "Notice", "Response drone disrupted — suit recovered 6% integrity")
            dissolveDrone(drone, true)
        end)
    end)

    return drone
end

local function responsePositions(room, count)
    local result = {}
    local expansions = Workspace:FindFirstChild("VaultfallCombatExpansions")
    if expansions then
        for _, wing in ipairs(expansions:GetChildren()) do
            if wing:GetAttribute("RoomIndex") == room.Index then
                local floor = wing:FindFirstChild("WingFloor")
                if floor and floor:IsA("BasePart") then
                    local spacing = 12
                    local alongX = floor.Size.X >= floor.Size.Z
                    for index = 1, count do
                        local side = index - ((count + 1) * 0.5)
                        local lateral = alongX and Vector3.new(side * spacing, 0, 0) or Vector3.new(0, 0, side * spacing)
                        table.insert(result, floor.Position + lateral + Vector3.new(0, floor.Size.Y * 0.5 + 0.6, 0))
                    end
                    return result
                end
            end
        end
    end

    local fallback = {
        Vector3.new(34, 0.6, -32),
        Vector3.new(-34, 0.6, 30),
        Vector3.new(28, 0.6, 34),
    }
    for index = 1, count do
        table.insert(result, room.Origin + fallback[index])
    end
    return result
end

local function startResponse(room, roomType)
    local tuning = ROOM_TUNING[roomType]
    if not tuning then
        return
    end

    responseUsed = true
    responseToken += 1
    local token = responseToken
    local partyCount = math.max(1, #livingPlayers())
    local count = 1
    if partyCount >= 3 then
        count += 1
    end
    if roomType == "DeepCombat" or roomType == "Elite" then
        count += 1
    end
    count = math.clamp(count, 1, 3)

    broadcast("SECURITY RESPONSE — flank drones inbound. Break line of sight or close to disrupt.")
    local positions = responsePositions(room, count)
    for index, position in ipairs(positions) do
        buildDrone(position, tuning, index, token)
    end
end

local function cleanupDrones()
    for _, drone in ipairs(drones) do
        if drone.Active then
            dissolveDrone(drone, false)
        elseif drone.Model and drone.Model.Parent then
            drone.Model:Destroy()
        end
    end
    table.clear(drones)
end

local function updateDrones(now)
    for _, drone in ipairs(drones) do
        if drone.Active then
            if now >= drone.ExpiresAt then
                dissolveDrone(drone, false)
            else
                local hover = math.sin(now * 2.4 + drone.Phase) * 0.55
                local yaw = now * 0.65 + drone.Phase
                drone.Model:PivotTo(CFrame.new(drone.HoverBase + Vector3.new(0, hover, 0)) * CFrame.Angles(0, yaw, 0))
                if now >= drone.NextShotAt then
                    drone.NextShotAt = now + drone.FireDelay
                    local target = nearestPlayer(drone.Core.Position)
                    if target then
                        fireAtPlayer(drone, target, responseToken)
                    end
                end
            end
        end
    end
end

local function step()
    local now = os.clock()
    updateDrones(now)

    if not ctx.Run.IsActive() then
        if activeRoom ~= 0 then
            activeRoom = 0
            responseUsed = false
            responseToken += 1
            cleanupDrones()
        end
        return
    end

    local roomIndex = ctx.Run.GetCurrentRoom()
    if roomIndex ~= activeRoom then
        activeRoom = roomIndex
        roomEnteredAt = now
        responseUsed = false
        responseToken += 1
        cleanupDrones()
    end

    if responseUsed then
        if aliveEnemyCount(roomIndex) <= 0 then
            responseToken += 1
            cleanupDrones()
        end
        return
    end
    if roomIndex < 3 then
        return
    end

    local room = ctx.World.GetRoom(roomIndex)
    if not room then
        return
    end
    local roomType = ctx.Config.RoomSequence[roomIndex] or room.Type
    if not ROOM_TUNING[roomType] then
        return
    end
    if now - roomEnteredAt < 7.5 then
        return
    end

    local enemyCount = aliveEnemyCount(roomIndex)
    if enemyCount <= 0 then
        return
    end
    local threshold = math.min(4, 2 + math.floor(#livingPlayers() * 0.5))
    if enemyCount <= threshold then
        startResponse(room, roomType)
    end
end

function CombatReinforcementService.Init(context)
    ctx = context
    RunService.Heartbeat:Connect(function(dt)
        accumulator += dt
        if accumulator < 0.12 then
            return
        end
        accumulator = 0
        step()
    end)
end

return CombatReinforcementService
