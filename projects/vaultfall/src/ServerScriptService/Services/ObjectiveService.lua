local Workspace = game:GetService("Workspace")

local ObjectiveService = {}
local ctx

local active = {
    RoomIndex = 0,
    Type = nil,
    Title = nil,
    Current = 0,
    Target = 0,
    TimeRemaining = nil,
    Token = 0,
    Complete = false,
    Folder = nil,
}

local deviceOffsets = {
    Vector3.new(-24, 0, -18),
    Vector3.new(22, 0, -15),
    Vector3.new(0, 0, 24),
}

local function getWorld()
    return Workspace:FindFirstChild("VaultfallWorld")
end

local function destroyFolder()
    if active.Folder and active.Folder.Parent then
        active.Folder:Destroy()
    end
    active.Folder = nil
end

local function payload()
    return {
        Active = active.Type ~= nil and not active.Complete,
        Type = active.Type,
        Title = active.Title,
        Current = active.Current,
        Target = active.Target,
        TimeRemaining = active.TimeRemaining,
        Complete = active.Complete,
    }
end

local function broadcast()
    local data = payload()
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        if player.Parent then
            ctx.Remotes.State:FireClient(player, "Objective", data)
        end
    end
end

local function setDeviceState(model, done)
    local core = model:FindFirstChild("Core")
    local light = core and core:FindFirstChildOfClass("PointLight")
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if core and core:IsA("BasePart") then
        core.Color = done and Color3.fromRGB(104, 235, 171) or Color3.fromRGB(93, 176, 255)
    end
    if light then
        light.Color = done and Color3.fromRGB(104, 235, 171) or Color3.fromRGB(93, 176, 255)
    end
    if prompt then
        prompt.Enabled = not done
    end
end

local function rewardObjectiveCompletion()
    local participants = ctx.Run.GetLivingParticipants()
    for _, player in ipairs(participants) do
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.08)
        end
        ctx.Remotes.State:FireClient(player, "Notice", "Objective secured — field repair + protocol choice unlocked")
    end

    if ctx.Augments then
        ctx.Augments.OfferParty("OBJECTIVE PROTOCOL")
    end
end

local function completeObjective()
    if active.Complete or not active.Type then
        return
    end
    active.Complete = true
    active.Current = active.Target
    active.TimeRemaining = 0
    broadcast()
    rewardObjectiveCompletion()
    if ctx.Run and ctx.Run.OnObjectiveComplete then
        ctx.Run.OnObjectiveComplete(active.RoomIndex)
    end
end

local function incrementObjective(model)
    if active.Complete then
        return
    end
    setDeviceState(model, true)
    active.Current = math.min(active.Target, active.Current + 1)
    broadcast()
    if active.Current >= active.Target then
        completeObjective()
    end
end

local function addBillboard(part, text)
    local gui = Instance.new("BillboardGui")
    gui.Name = "ObjectiveLabel"
    gui.Size = UDim2.fromOffset(170, 34)
    gui.StudsOffset = Vector3.new(0, 4.6, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 75
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.BackgroundColor3 = Color3.fromRGB(15, 20, 27)
    label.BackgroundTransparency = 0.18
    label.BorderSizePixel = 0
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(224, 238, 247)
    label.Text = text
    label.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = label
end

local function createDevice(parent, name, position, actionText, objectText, accent, callback)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Anchored = true
    base.Size = Vector3.new(4.8, 0.7, 4.8)
    base.Material = Enum.Material.Metal
    base.Color = Color3.fromRGB(42, 48, 57)
    base.CFrame = CFrame.new(position + Vector3.new(0, 0.35, 0))
    base.Parent = model

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Anchored = true
    body.Size = Vector3.new(3.1, 3.8, 2.2)
    body.Material = Enum.Material.Metal
    body.Color = Color3.fromRGB(58, 65, 75)
    body.CFrame = CFrame.new(position + Vector3.new(0, 2.55, 0))
    body.Parent = model

    local core = Instance.new("Part")
    core.Name = "Core"
    core.Anchored = true
    core.Size = Vector3.new(2.15, 1.1, 0.3)
    core.Material = Enum.Material.Neon
    core.Color = accent
    core.CFrame = body.CFrame * CFrame.new(0, 0.35, -1.16)
    core.Parent = model

    local light = Instance.new("PointLight")
    light.Brightness = 1.8
    light.Range = 11
    light.Color = accent
    light.Parent = core

    local antenna = Instance.new("Part")
    antenna.Name = "Antenna"
    antenna.Anchored = true
    antenna.Size = Vector3.new(0.35, 2.2, 0.35)
    antenna.Material = Enum.Material.Metal
    antenna.Color = Color3.fromRGB(74, 82, 92)
    antenna.CFrame = CFrame.new(position + Vector3.new(0, 5.55, 0))
    antenna.Parent = model

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = actionText
    prompt.ObjectText = objectText
    prompt.HoldDuration = 1.15
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = body

    addBillboard(body, objectText)

    prompt.Triggered:Connect(function(player)
        if not ctx.Run.IsParticipant(player) or ctx.Run.GetCurrentRoom() ~= active.RoomIndex or active.Complete then
            return
        end
        if not prompt.Enabled then
            return
        end
        prompt.Enabled = false
        callback(model, player)
    end)

    return model
end

local function makeInteractiveObjective(room, mission)
    local world = getWorld()
    if not world then
        return false
    end

    local folder = Instance.new("Folder")
    folder.Name = "ActiveObjective"
    folder.Parent = world
    active.Folder = folder

    local accent = mission.Type == "Sabotage" and Color3.fromRGB(255, 126, 88)
        or mission.Type == "Recovery" and Color3.fromRGB(255, 211, 99)
        or Color3.fromRGB(93, 176, 255)

    for index = 1, active.Target do
        local offset = deviceOffsets[((index - 1) % #deviceOffsets) + 1]
        local actionText = mission.Type == "Recovery" and "Secure Core"
            or mission.Type == "Sabotage" and "Plant Charge"
            or "Link Terminal"
        local objectText = mission.Type == "Recovery" and string.format("DATA CORE %d", index)
            or mission.Type == "Sabotage" and string.format("COOLANT NODE %d", index)
            or string.format("UPLINK %d", index)

        createDevice(folder, mission.Type .. tostring(index), room.Origin + offset, actionText, objectText, accent, function(model)
            incrementObjective(model)
        end)
    end

    return true
end

local function makeHoldoutObjective(room, mission)
    local world = getWorld()
    if not world then
        return false
    end

    local folder = Instance.new("Folder")
    folder.Name = "ActiveObjective"
    folder.Parent = world
    active.Folder = folder

    local beacon = Instance.new("Part")
    beacon.Name = "DefenseBeacon"
    beacon.Anchored = true
    beacon.Shape = Enum.PartType.Cylinder
    beacon.Size = Vector3.new(5.5, 4.2, 4.2)
    beacon.Material = Enum.Material.Neon
    beacon.Color = Color3.fromRGB(111, 194, 255)
    beacon.CFrame = CFrame.new(room.Origin + Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
    beacon.Parent = folder
    addBillboard(beacon, "DEFENSE UPLINK")

    local light = Instance.new("PointLight")
    light.Brightness = 2.5
    light.Range = 20
    light.Color = beacon.Color
    light.Parent = beacon

    active.TimeRemaining = mission.Duration or 25
    active.Target = active.TimeRemaining
    active.Current = 0
    local token = active.Token

    task.spawn(function()
        while active.Token == token and not active.Complete and active.TimeRemaining and active.TimeRemaining > 0 do
            task.wait(1)
            if active.Token ~= token or active.Complete then
                return
            end
            active.TimeRemaining = math.max(0, active.TimeRemaining - 1)
            active.Current = active.Target - active.TimeRemaining
            broadcast()
        end
        if active.Token == token and not active.Complete then
            completeObjective()
        end
    end)

    return true
end

function ObjectiveService.Init(context)
    ctx = context
end

function ObjectiveService.StartRoom(roomIndex)
    ObjectiveService.Reset()

    local mission = ctx.Config.Missions and ctx.Config.Missions[roomIndex]
    if not mission then
        return false
    end

    local room = ctx.World.GetRoom(roomIndex)
    if not room then
        return false
    end

    active.RoomIndex = roomIndex
    active.Type = mission.Type
    active.Title = mission.Title
    active.Current = 0
    active.Target = mission.Target or 1
    active.TimeRemaining = nil
    active.Complete = false
    active.Token += 1

    local created = mission.Type == "Holdout" and makeHoldoutObjective(room, mission) or makeInteractiveObjective(room, mission)
    if not created then
        ObjectiveService.Reset()
        return false
    end

    broadcast()
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        ctx.Remotes.State:FireClient(player, "Notice", mission.Brief or mission.Title)
    end
    return true
end

function ObjectiveService.PushState(player)
    if player and player.Parent then
        ctx.Remotes.State:FireClient(player, "Objective", payload())
    end
end

function ObjectiveService.IsComplete(roomIndex)
    return active.RoomIndex ~= roomIndex or active.Type == nil or active.Complete
end

function ObjectiveService.EndRoom()
    if active.Type then
        active.Complete = true
        broadcast()
    end
    active.Token += 1
    destroyFolder()
    active.RoomIndex = 0
    active.Type = nil
    active.Title = nil
    active.Current = 0
    active.Target = 0
    active.TimeRemaining = nil
end

function ObjectiveService.Reset()
    active.Token += 1
    destroyFolder()
    active.RoomIndex = 0
    active.Type = nil
    active.Title = nil
    active.Current = 0
    active.Target = 0
    active.TimeRemaining = nil
    active.Complete = false
end

return ObjectiveService
