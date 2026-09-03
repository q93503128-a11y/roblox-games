local RunService = game:GetService("RunService")

local OptionalOpsService = {}
local ctx

local ELIGIBLE_ROOMS = {
    [3] = true,
    [6] = true,
    [8] = true,
    [10] = true,
}

local state = {
    Room = 0,
    Kind = nil,
    Active = false,
    Armed = false,
    Complete = false,
    Progress = 0,
    Required = 0,
    TimeLeft = 0,
    Interacted = {},
    ZoneOccupancy = 0,
    Token = 0,
}

local rootModel
local heartbeatConnection
local rng = Random.new()

local COLORS = {
    Idle = Color3.fromRGB(83, 132, 146),
    Active = Color3.fromRGB(231, 169, 70),
    Danger = Color3.fromRGB(220, 82, 73),
    Complete = Color3.fromRGB(88, 198, 137),
}

local function destroyRoot()
    if rootModel then
        rootModel:Destroy()
        rootModel = nil
    end
end

local function resetState()
    state.Room = 0
    state.Kind = nil
    state.Active = false
    state.Armed = false
    state.Complete = false
    state.Progress = 0
    state.Required = 0
    state.TimeLeft = 0
    state.ZoneOccupancy = 0
    state.Interacted = {}
    state.Token += 1
    destroyRoot()
end

local function participants()
    if not ctx.Run or not ctx.Run.GetLivingParticipants then
        return {}
    end
    return ctx.Run.GetLivingParticipants()
end

local function broadcast(kind, payload)
    for _, player in ipairs(participants()) do
        if player.Parent then
            ctx.Remotes.State:FireClient(player, kind, payload)
        end
    end
end

local function payload()
    return {
        Active = state.Active,
        Armed = state.Armed,
        Complete = state.Complete,
        Kind = state.Kind,
        Room = state.Room,
        Progress = state.Progress,
        Required = state.Required,
        TimeLeft = math.max(0, state.TimeLeft),
    }
end

local function pushState()
    broadcast("OptionalOp", payload())
end

local function notify(text)
    for _, player in ipairs(participants()) do
        ctx.Remotes.State:FireClient(player, "Notice", text)
    end
end

local function makePart(parent, name, size, cframe, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.Metal
    part.Anchored = true
    part.CanCollide = true
    part.Parent = parent
    return part
end

local function makeConsole(parent, cframe, actionText, objectText, index)
    local base = makePart(parent, "ConsoleBase" .. tostring(index), Vector3.new(3.2, 4.8, 2.4), cframe, Color3.fromRGB(37, 46, 52), Enum.Material.Metal)
    local screen = makePart(parent, "ConsoleScreen" .. tostring(index), Vector3.new(2.45, 1.5, 0.18), cframe * CFrame.new(0, 0.65, -1.27), COLORS.Idle, Enum.Material.Neon)
    screen.CanCollide = false

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.HoldDuration = 0.85
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = base

    return base, screen, prompt
end

local function healParty(fraction)
    for _, player in ipairs(participants()) do
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * fraction)
        end
    end
end

local function grantReward(label, healFraction)
    if state.Complete then
        return
    end
    state.Complete = true
    state.Active = false
    state.Armed = false
    if healFraction and healFraction > 0 then
        healParty(healFraction)
    end
    if ctx.Augments then
        ctx.Augments.OfferParty(label)
    end
    pushState()
    notify(label .. " COMPLETE — bonus augment protocol unlocked")

    if rootModel then
        for _, descendant in ipairs(rootModel:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
                descendant.Color = COLORS.Complete
            elseif descendant:IsA("ProximityPrompt") then
                descendant.Enabled = false
            end
        end
    end
end

local function damagePlayersNear(position, radius, damage)
    for _, player in ipairs(participants()) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if root and humanoid and humanoid.Health > 0 and (root.Position - position).Magnitude <= radius then
            humanoid:TakeDamage(damage)
        end
    end
end

local function pulseWarning(position, radius, delayTime, token)
    if not rootModel then
        return
    end
    local marker = makePart(rootModel, "PulseWarning", Vector3.new(0.16, radius * 2, radius * 2), CFrame.new(position - Vector3.new(0, 1.2, 0)) * CFrame.Angles(0, 0, math.rad(90)), COLORS.Danger, Enum.Material.Neon)
    marker.Shape = Enum.PartType.Cylinder
    marker.Transparency = 0.62
    marker.CanCollide = false

    task.delay(delayTime, function()
        if marker.Parent then
            marker:Destroy()
        end
        if state.Token ~= token or not state.Active or not state.Armed then
            return
        end
        damagePlayersNear(position, radius, 18)
        broadcast("OptionalOpPulse", {
            Position = position,
            Radius = radius,
        })
    end)
end

local function beginOverload(consolePosition)
    if state.Armed or state.Complete then
        return
    end
    state.Armed = true
    state.TimeLeft = 16
    state.Required = 16
    state.Progress = 0
    local token = state.Token
    pushState()
    notify("OPTIONAL OP ARMED — survive the cache purge for 16 seconds")

    task.spawn(function()
        local pulseClock = 0
        while state.Token == token and state.Active and state.Armed and state.TimeLeft > 0 do
            task.wait(0.25)
            state.TimeLeft -= 0.25
            state.Progress = math.clamp(state.Required - state.TimeLeft, 0, state.Required)
            pulseClock += 0.25
            if pulseClock >= 2.5 then
                pulseClock = 0
                local angle = rng:NextNumber(0, math.pi * 2)
                local distance = rng:NextNumber(5, 19)
                local target = consolePosition + Vector3.new(math.cos(angle) * distance, 0.2, math.sin(angle) * distance)
                pulseWarning(target, rng:NextNumber(5.5, 8.5), 0.8, token)
            end
            pushState()
        end
        if state.Token == token and state.Active and state.Armed and state.TimeLeft <= 0 then
            grantReward("OVERLOAD CACHE", 0.12)
        end
    end)
end

local function buildOverload(room)
    state.Kind = "OVERLOAD CACHE"
    state.Active = true
    state.Required = 16

    local model = Instance.new("Model")
    model.Name = "OptionalOp_OverloadCache"
    model.Parent = room.Folder
    rootModel = model

    local position = room.Origin + Vector3.new(28, 2.4, -27)
    local _, screen, prompt = makeConsole(model, CFrame.new(position), "BREACH CACHE", "Encrypted Armory Cache", 1)
    prompt.HoldDuration = 1.25
    prompt.Triggered:Connect(function(player)
        if not ctx.Run.IsParticipant(player) or state.Room ~= ctx.Run.GetCurrentRoom() then
            return
        end
        prompt.Enabled = false
        screen.Color = COLORS.Danger
        beginOverload(position)
    end)
end

local function buildRelaySweep(room)
    state.Kind = "RELAY SWEEP"
    state.Active = true
    state.Required = 3

    local model = Instance.new("Model")
    model.Name = "OptionalOp_RelaySweep"
    model.Parent = room.Folder
    rootModel = model

    local offsets = {
        Vector3.new(-29, 2.4, -25),
        Vector3.new(30, 2.4, 1),
        Vector3.new(-18, 2.4, 29),
    }

    for index, offset in ipairs(offsets) do
        local _, screen, prompt = makeConsole(model, CFrame.new(room.Origin + offset) * CFrame.Angles(0, math.rad(index * 74), 0), "LINK RELAY", "Ghost Relay " .. tostring(index), index)
        prompt.Triggered:Connect(function(player)
            if state.Complete or not state.Active or not ctx.Run.IsParticipant(player) then
                return
            end
            if state.Interacted[index] then
                return
            end
            state.Interacted[index] = true
            state.Progress += 1
            prompt.Enabled = false
            screen.Color = COLORS.Complete
            pushState()
            if state.Progress >= state.Required then
                grantReward("RELAY SWEEP", 0.08)
            else
                notify(string.format("Ghost relay linked — %d / %d", state.Progress, state.Required))
            end
        end)
    end
end

local function buildContainment(room)
    state.Kind = "CONTAINMENT HOLD"
    state.Active = true
    state.Required = 12
    state.TimeLeft = 12

    local model = Instance.new("Model")
    model.Name = "OptionalOp_ContainmentHold"
    model.Parent = room.Folder
    rootModel = model

    local center = room.Origin + Vector3.new(0, 0.3, 0)
    local zone = makePart(model, "ContainmentZone", Vector3.new(0.18, 28, 28), CFrame.new(center) * CFrame.Angles(0, 0, math.rad(90)), COLORS.Active, Enum.Material.Neon)
    zone.Shape = Enum.PartType.Cylinder
    zone.Transparency = 0.72
    zone.CanCollide = false

    local _, screen, prompt = makeConsole(model, CFrame.new(room.Origin + Vector3.new(0, 2.4, -10)), "START CONTAINMENT", "Anomaly Regulator", 1)
    prompt.HoldDuration = 1
    prompt.Triggered:Connect(function(player)
        if state.Armed or state.Complete or not ctx.Run.IsParticipant(player) then
            return
        end
        state.Armed = true
        prompt.Enabled = false
        screen.Color = COLORS.Danger
        pushState()
        notify("CONTAINMENT HOLD — keep at least one operator inside the ring")
        local token = state.Token
        task.spawn(function()
            local hazardClock = 0
            while state.Token == token and state.Active and state.Armed and state.Progress < state.Required do
                task.wait(0.2)
                local occupied = false
                for _, participant in ipairs(participants()) do
                    local root = participant.Character and participant.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local flat = Vector3.new(root.Position.X - center.X, 0, root.Position.Z - center.Z)
                        if flat.Magnitude <= 14 then
                            occupied = true
                            break
                        end
                    end
                end
                if occupied then
                    state.Progress = math.min(state.Required, state.Progress + 0.2)
                    state.TimeLeft = math.max(0, state.Required - state.Progress)
                end
                hazardClock += 0.2
                if hazardClock >= 3.2 then
                    hazardClock = 0
                    local angle = rng:NextNumber(0, math.pi * 2)
                    local target = center + Vector3.new(math.cos(angle) * rng:NextNumber(16, 26), 0, math.sin(angle) * rng:NextNumber(16, 26))
                    pulseWarning(target, 6, 0.75, token)
                end
                pushState()
            end
            if state.Token == token and state.Active and state.Progress >= state.Required then
                grantReward("CONTAINMENT HOLD", 0.18)
            end
        end)
    end)
end

local BUILDERS = {
    buildOverload,
    buildRelaySweep,
    buildContainment,
}

local function startRoom(roomIndex)
    resetState()
    if not ELIGIBLE_ROOMS[roomIndex] then
        return
    end
    local room = ctx.World.GetRoom(roomIndex)
    if not room then
        return
    end

    state.Room = roomIndex
    state.Token += 1
    local builder = BUILDERS[rng:NextInteger(1, #BUILDERS)]
    builder(room)
    pushState()
    notify("OPTIONAL FIELD OP DETECTED — complete it for an extra augment")
end

function OptionalOpsService.Init(context)
    ctx = context
    local observedRoom = 0
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if not ctx.Run.IsActive() then
            if observedRoom ~= 0 then
                observedRoom = 0
                resetState()
                broadcast("OptionalOp", payload())
            end
            return
        end

        local currentRoom = ctx.Run.GetCurrentRoom()
        if currentRoom ~= observedRoom then
            observedRoom = currentRoom
            startRoom(currentRoom)
        end
    end)
end

function OptionalOpsService.PushState(player)
    if player and player.Parent then
        ctx.Remotes.State:FireClient(player, "OptionalOp", payload())
    end
end

function OptionalOpsService.Reset()
    resetState()
end

function OptionalOpsService.Destroy()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    resetState()
end

return OptionalOpsService
