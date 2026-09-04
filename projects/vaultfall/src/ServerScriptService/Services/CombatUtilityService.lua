local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CombatUtilityService = {}
local ctx

local ROOT_NAME = "VaultfallCombatUtilities"
local NODE_RANGE = 34
local BACKLASH_RANGE = 13
local RESET_DELAY = 5

local nodes = {}

local function part(parent, name, size, cframe, material, color, transparency, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Anchored = true
    p.Material = material or Enum.Material.Metal
    p.Color = color or Color3.fromRGB(60, 66, 71)
    p.Transparency = transparency or 0
    p.CanCollide = collide ~= false
    p.CanTouch = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function neon(parent, name, size, cframe, color, transparency)
    return part(parent, name, size, cframe, Enum.Material.Neon, color, transparency or 0.08, false)
end

local function addPointLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Shadows = true
    light.Parent = host
    return light
end

local function livingEnemies(roomIndex)
    local result = {}
    for _, enemy in pairs(ctx.Enemies.GetAll()) do
        if enemy.Alive and enemy.RoomIndex == roomIndex and enemy.Root and enemy.Root.Parent then
            table.insert(result, enemy)
        end
    end
    return result
end

local function playersInRange(position, range)
    local result = {}
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if root and humanoid and humanoid.Health > 0 and (root.Position - position).Magnitude <= range then
            table.insert(result, {
                Player = player,
                Humanoid = humanoid,
            })
        end
    end
    return result
end

local function pulseRing(parent, position, color, diameter, duration)
    local ring = neon(parent, "DischargeWave", Vector3.new(0.22, 2, 2), CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)), color, 0.2)
    ring.Shape = Enum.PartType.Cylinder
    TweenService:Create(ring, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.22, diameter, diameter),
        Transparency = 0.92,
    }):Play()
    task.delay(duration + 0.1, function()
        if ring.Parent then
            ring:Destroy()
        end
    end)
end

local function setNodeVisual(node, state)
    if not node.Model.Parent then
        return
    end
    if state == "Ready" then
        node.Core.Color = Color3.fromRGB(74, 170, 196)
        node.Core.Transparency = 0.05
        node.Light.Color = node.Core.Color
        node.Light.Brightness = 1.35
        node.Prompt.Enabled = true
        node.Prompt.ActionText = "Overload"
        node.Screen.Color = Color3.fromRGB(71, 149, 170)
    elseif state == "Charging" then
        node.Core.Color = Color3.fromRGB(255, 185, 76)
        node.Light.Color = node.Core.Color
        node.Light.Brightness = 2.3
        node.Prompt.Enabled = false
        node.Screen.Color = Color3.fromRGB(213, 141, 60)
    else
        node.Core.Color = Color3.fromRGB(66, 70, 73)
        node.Core.Transparency = 0.45
        node.Light.Color = Color3.fromRGB(70, 78, 81)
        node.Light.Brightness = 0.2
        node.Prompt.Enabled = false
        node.Screen.Color = Color3.fromRGB(67, 71, 74)
    end
end

local function activateNode(node, player)
    if node.Used or node.Busy then
        return
    end

    local enemies = livingEnemies(node.RoomIndex)
    if #enemies == 0 then
        ctx.Remotes.State:FireClient(player, "Notice", "ARC NODE STANDBY — no hostile circuit detected")
        return
    end

    node.Busy = true
    node.Used = true
    setNodeVisual(node, "Charging")
    ctx.Remotes.State:FireClient(player, "Notice", "ARC DISCHARGE ARMED — clear the backlash radius")

    pulseRing(node.Model, node.Position + Vector3.new(0, 0.8, 0), Color3.fromRGB(255, 179, 70), 15, 0.7)
    TweenService:Create(node.Core, TweenInfo.new(0.65, Enum.EasingStyle.Quad), {
        Size = Vector3.new(6.4, 6.4, 6.4),
    }):Play()

    task.delay(0.72, function()
        if not node.Model.Parent then
            return
        end

        node.Core.Size = Vector3.new(3.8, 3.8, 3.8)
        node.Core.Color = Color3.fromRGB(122, 224, 255)
        node.Light.Color = node.Core.Color
        node.Light.Brightness = 3
        pulseRing(node.Model, node.Position + Vector3.new(0, 1, 0), node.Core.Color, NODE_RANGE * 2, 0.55)
        pulseRing(node.Model, node.Position + Vector3.new(0, 1.1, 0), Color3.fromRGB(215, 246, 255), NODE_RANGE * 1.35, 0.38)

        local hitCount = 0
        for _, enemy in ipairs(livingEnemies(node.RoomIndex)) do
            local distance = (enemy.Root.Position - node.Position).Magnitude
            if distance <= NODE_RANGE then
                hitCount += 1
                local fraction = enemy.Data.Elite and 0.12 or 0.22
                local damage = math.max(18, math.floor(enemy.MaxHealth * fraction + 0.5))
                local oldSpeed = enemy.Speed
                enemy.Speed = math.max(2, oldSpeed * 0.24)
                ctx.Enemies.Damage(enemy, damage, player)
                task.delay(2.4, function()
                    if enemy.Alive then
                        enemy.Speed = math.max(enemy.Speed, oldSpeed)
                    end
                end)
            end
        end

        local backlash = playersInRange(node.Position, BACKLASH_RANGE)
        for _, target in ipairs(backlash) do
            local damage = math.max(6, math.floor(target.Humanoid.MaxHealth * 0.11 + 0.5))
            target.Humanoid:TakeDamage(damage)
            ctx.Remotes.State:FireClient(target.Player, "Notice", "ARC BACKLASH — operator inside unsafe radius")
        end

        ctx.Remotes.State:FireClient(player, "Notice", string.format("ARC DISCHARGE — %d hostiles disrupted", hitCount))
        node.Busy = false
        setNodeVisual(node, "Spent")
    end)
end

local function buildNode(root, wing)
    local roomIndex = wing:GetAttribute("RoomIndex")
    local floor = wing:FindFirstChild("WingFloor")
    if type(roomIndex) ~= "number" or not floor or not floor:IsA("BasePart") then
        return
    end

    local room = ctx.World.GetRoom(roomIndex)
    if not room then
        return
    end

    local delta = floor.Position - room.Origin
    local flat = Vector3.new(delta.X, 0, delta.Z)
    if flat.Magnitude < 1 then
        return
    end
    local direction = flat.Unit
    local across = Vector3.new(-direction.Z, 0, direction.X)
    local position = floor.Position + direction * 14 - across * 17

    local model = Instance.new("Model")
    model.Name = string.format("ArcNode_%02d", roomIndex)
    model.Parent = root

    part(model, "Base", Vector3.new(10, 1.3, 10), CFrame.new(position + Vector3.new(0, 0.7, 0)), Enum.Material.DiamondPlate, Color3.fromRGB(50, 56, 60))
    part(model, "Pedestal", Vector3.new(6, 4.2, 6), CFrame.new(position + Vector3.new(0, 2.9, 0)), Enum.Material.Metal, Color3.fromRGB(65, 72, 77))
    local core = neon(model, "ArcCore", Vector3.new(3.8, 3.8, 3.8), CFrame.new(position + Vector3.new(0, 6.2, 0)), Color3.fromRGB(74, 170, 196), 0.05)
    core.Shape = Enum.PartType.Ball
    local light = addPointLight(core, core.Color, 1.35, 23)

    for _, side in ipairs({ -1, 1 }) do
        local coilPos = position + across * (side * 3.5) + Vector3.new(0, 5.7, 0)
        local coil = neon(model, "ArcCoil", Vector3.new(1.1, 5.4, 1.1), CFrame.new(coilPos), Color3.fromRGB(93, 191, 213), 0.12)
        addPointLight(coil, coil.Color, 0.45, 10)
    end

    local screen = neon(model, "ControlScreen", Vector3.new(4.8, 2.2, 0.35), CFrame.lookAt(position + Vector3.new(0, 3.5, 3.1), position + Vector3.new(0, 3.5, 7)), Color3.fromRGB(71, 149, 170), 0.04)
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ArcDischargePrompt"
    prompt.ActionText = "Overload"
    prompt.ObjectText = "ARC DISCHARGE NODE"
    prompt.HoldDuration = 0.7
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.Parent = screen

    local node = {
        Model = model,
        RoomIndex = roomIndex,
        Position = position,
        Core = core,
        Light = light,
        Screen = screen,
        Prompt = prompt,
        Used = false,
        Busy = false,
        EmptySince = os.clock(),
    }
    table.insert(nodes, node)
    prompt.Triggered:Connect(function(player)
        activateNode(node, player)
    end)
    setNodeVisual(node, "Spent")
end

local function refreshNodes()
    local now = os.clock()
    for _, node in ipairs(nodes) do
        if node.Model.Parent and not node.Busy then
            local hasEnemies = #livingEnemies(node.RoomIndex) > 0
            if hasEnemies then
                node.EmptySince = now
                if not node.Used then
                    setNodeVisual(node, "Ready")
                end
            else
                setNodeVisual(node, "Spent")
                if node.Used and now - node.EmptySince >= RESET_DELAY then
                    node.Used = false
                end
            end
        end
    end
end

function CombatUtilityService.Init(context)
    ctx = context
end

function CombatUtilityService.Build()
    local previous = Workspace:FindFirstChild(ROOT_NAME)
    if previous then
        previous:Destroy()
    end
    table.clear(nodes)

    local root = Instance.new("Folder")
    root.Name = ROOT_NAME
    root.Parent = Workspace

    local expansions = Workspace:FindFirstChild("VaultfallCombatExpansions")
    if expansions then
        for _, wing in ipairs(expansions:GetChildren()) do
            if wing:GetAttribute("PlayableExpansion") == true then
                buildNode(root, wing)
            end
        end
    end

    root:SetAttribute("SelfContained", true)
    root:SetAttribute("NodeCount", #nodes)
    root:SetAttribute("RiskRewardInteractables", true)

    task.spawn(function()
        while root.Parent do
            refreshNodes()
            task.wait(0.65)
        end
    end)
end

return CombatUtilityService