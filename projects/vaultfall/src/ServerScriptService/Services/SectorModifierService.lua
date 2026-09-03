local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SectorModifierService = {}
local ctx

local currentRoom = 0
local currentModifier
local generation = 0
local accumulator = 0
local appliedEnemyIds = {}
local rng = Random.new()

local MODIFIERS = {
    {
        Id = "OVERCLOCK_GRID",
        Title = "OVERCLOCK GRID",
        Description = "Hostiles move faster and attack more aggressively.",
        EnemySpeed = 1.24,
        EnemyDamage = 1.10,
        EnemyCooldown = 0.84,
        Accent = Color3.fromRGB(255, 153, 76),
    },
    {
        Id = "ARMORED_RESPONSE",
        Title = "ARMORED RESPONSE",
        Description = "Reinforced hostile shells increase enemy durability and pressure.",
        EnemyHealth = 1.32,
        EnemyDamage = 1.12,
        Accent = Color3.fromRGB(204, 94, 94),
    },
    {
        Id = "GLASS_CIRCUIT",
        Title = "GLASS CIRCUIT",
        Description = "Enemies are fragile, but their weapons hit much harder.",
        EnemyHealth = 0.78,
        EnemyDamage = 1.38,
        EnemySpeed = 1.08,
        Accent = Color3.fromRGB(119, 204, 255),
    },
    {
        Id = "ION_STORM",
        Title = "ION STORM",
        Description = "Unstable discharge zones repeatedly lock onto active operators.",
        EnemySpeed = 1.08,
        Hazard = "IonStrike",
        Accent = Color3.fromRGB(115, 139, 255),
    },
}

local ELIGIBLE_ROOM_TYPES = {
    Combat = true,
    DeepCombat = true,
    Elite = true,
}

local function livingParticipants()
    if not ctx or not ctx.Run or not ctx.Run.GetLivingParticipants then
        return {}
    end
    return ctx.Run.GetLivingParticipants()
end

local function payload()
    if not currentModifier or currentRoom <= 0 then
        return {
            Active = false,
            Room = currentRoom,
        }
    end
    return {
        Active = true,
        Room = currentRoom,
        Id = currentModifier.Id,
        Title = currentModifier.Title,
        Description = currentModifier.Description,
        Accent = currentModifier.Accent,
    }
end

local function broadcast()
    for _, player in ipairs(livingParticipants()) do
        if player.Parent then
            ctx.Remotes.State:FireClient(player, "SectorModifier", payload())
        end
    end
end

local function applyToEnemy(enemy)
    if not enemy or not enemy.Alive or enemy.RoomIndex ~= currentRoom then
        return
    end
    if appliedEnemyIds[enemy.Id] or not currentModifier then
        return
    end

    appliedEnemyIds[enemy.Id] = true
    enemy.SectorModifierId = currentModifier.Id

    local healthMultiplier = currentModifier.EnemyHealth or 1
    if healthMultiplier ~= 1 then
        local ratio = enemy.MaxHealth > 0 and (enemy.Health / enemy.MaxHealth) or 1
        enemy.MaxHealth = math.max(1, math.floor(enemy.MaxHealth * healthMultiplier + 0.5))
        enemy.Health = math.max(1, math.floor(enemy.MaxHealth * ratio + 0.5))
        if enemy.HealthFill then
            enemy.HealthFill.Size = UDim2.fromScale(math.clamp(enemy.Health / enemy.MaxHealth, 0, 1), 1)
        end
    end

    enemy.Damage = math.max(1, math.floor(enemy.Damage * (currentModifier.EnemyDamage or 1) + 0.5))
    enemy.Speed *= currentModifier.EnemySpeed or 1
    enemy.AttackCooldown *= currentModifier.EnemyCooldown or 1

    if enemy.Root and enemy.Root.Parent then
        local highlight = Instance.new("Highlight")
        highlight.Name = "SectorModifierHighlight"
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.FillTransparency = 0.88
        highlight.OutlineTransparency = 0.35
        highlight.FillColor = currentModifier.Accent
        highlight.OutlineColor = currentModifier.Accent
        highlight.Parent = enemy.Model
    end
end

local function applyToCurrentEnemies()
    if not currentModifier then
        return
    end
    for _, enemy in pairs(ctx.Enemies.GetAll()) do
        applyToEnemy(enemy)
    end
end

local function createIonTelegraph(position, token)
    local ring = Instance.new("Part")
    ring.Name = "IonStormTelegraph"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.18, 4, 4)
    ring.Material = Enum.Material.Neon
    ring.Color = Color3.fromRGB(113, 132, 255)
    ring.Transparency = 0.28
    ring.Anchored = true
    ring.CanCollide = false
    ring.CanTouch = false
    ring.CFrame = CFrame.new(position - Vector3.new(0, 2.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
    ring.Parent = Workspace

    TweenService:Create(ring, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.18, 17, 17),
        Transparency = 0.48,
    }):Play()

    task.delay(0.95, function()
        if ring.Parent then
            ring:Destroy()
        end
        if token ~= generation or not currentModifier or currentModifier.Id ~= "ION_STORM" then
            return
        end

        local column = Instance.new("Part")
        column.Name = "IonStormStrike"
        column.Size = Vector3.new(2.4, 26, 2.4)
        column.Material = Enum.Material.Neon
        column.Color = Color3.fromRGB(160, 181, 255)
        column.Transparency = 0.18
        column.Anchored = true
        column.CanCollide = false
        column.CanTouch = false
        column.CFrame = CFrame.new(position + Vector3.new(0, 10, 0))
        column.Parent = Workspace

        local light = Instance.new("PointLight")
        light.Color = column.Color
        light.Brightness = 3
        light.Range = 18
        light.Parent = column

        for _, player in ipairs(livingParticipants()) do
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and root and humanoid.Health > 0 and (root.Position - position).Magnitude <= 8.5 then
                humanoid:TakeDamage(math.max(8, math.floor(humanoid.MaxHealth * 0.12)))
            end
        end

        TweenService:Create(column, TweenInfo.new(0.32), { Transparency = 1 }):Play()
        task.delay(0.34, function()
            if column.Parent then
                column:Destroy()
            end
        end)
    end)
end

local function fireIonStorm()
    local targets = livingParticipants()
    if #targets == 0 then
        return
    end

    local target = targets[rng:NextInteger(1, #targets)]
    local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        return
    end

    ctx.Remotes.State:FireClient(target, "Notice", "ION LOCK — move out of the marked zone")
    createIonTelegraph(root.Position, generation)
end

local function chooseModifier(roomIndex)
    local room = ctx.World.GetRoom(roomIndex)
    if not room or not ELIGIBLE_ROOM_TYPES[room.Type] then
        return nil
    end

    local index = rng:NextInteger(1, #MODIFIERS)
    return MODIFIERS[index]
end

local function activateRoom(roomIndex)
    generation += 1
    currentRoom = roomIndex
    table.clear(appliedEnemyIds)
    currentModifier = chooseModifier(roomIndex)

    if currentModifier then
        task.delay(0.15, function()
            if currentRoom == roomIndex and currentModifier then
                applyToCurrentEnemies()
                broadcast()
                for _, player in ipairs(livingParticipants()) do
                    ctx.Remotes.State:FireClient(player, "Notice", string.format("SECTOR CONDITION — %s", currentModifier.Title))
                end
            end
        end)
    else
        broadcast()
    end
end

function SectorModifierService.Init(context)
    ctx = context
    rng = Random.new(math.floor(os.clock() * 100000) % 2147483646)

    RunService.Heartbeat:Connect(function(dt)
        accumulator += dt
        if accumulator < 0.25 then
            return
        end
        accumulator = 0

        local roomIndex = ctx.Run and ctx.Run.GetCurrentRoom and ctx.Run.GetCurrentRoom() or 0
        local active = ctx.Run and ctx.Run.IsActive and ctx.Run.IsActive()
        if not active then
            if currentRoom ~= 0 or currentModifier then
                generation += 1
                currentRoom = 0
                currentModifier = nil
                table.clear(appliedEnemyIds)
            end
            return
        end

        if roomIndex ~= currentRoom then
            activateRoom(roomIndex)
        elseif currentModifier then
            applyToCurrentEnemies()
            if currentModifier.Hazard == "IonStrike" and rng:NextNumber() <= 0.055 then
                fireIonStorm()
            end
        end
    end)
end

function SectorModifierService.PushState(player)
    if player and player.Parent then
        ctx.Remotes.State:FireClient(player, "SectorModifier", payload())
    end
end

return SectorModifierService