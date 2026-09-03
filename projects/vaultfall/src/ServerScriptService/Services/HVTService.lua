local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local HVTService = {}
local ctx
local rng = Random.new()
local active
local lastObservedRoom = 0
local accumulator = 0

local function getLivingRoots()
    local result = {}
    if not ctx.Run or not ctx.Run.GetLivingParticipants then
        return result
    end
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if root and humanoid and humanoid.Health > 0 then
            table.insert(result, { Player = player, Root = root, Humanoid = humanoid })
        end
    end
    return result
end

local function damageNear(position, radius, amount)
    for _, entry in ipairs(getLivingRoots()) do
        if (entry.Root.Position - position).Magnitude <= radius then
            entry.Humanoid:TakeDamage(amount)
        end
    end
end

local function broadcast(payload)
    if not ctx.Run or not ctx.Run.GetLivingParticipants then
        return
    end
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        if player.Parent then
            ctx.Remotes.State:FireClient(player, "HVT", payload)
        end
    end
end

local function inactivePayload()
    return {
        Active = false,
        Name = "",
        Room = 0,
        Health = 0,
        MaxHealth = 0,
        Ability = "",
    }
end

local function statePayload(ability)
    if not active or not active.Enemy or not active.Enemy.Alive then
        return inactivePayload()
    end
    return {
        Active = true,
        Name = active.Variant,
        Room = active.Room,
        Health = active.Enemy.Health,
        MaxHealth = active.Enemy.MaxHealth,
        Ability = ability or "",
    }
end

local function makeDisk(parent, position, radius, color, lifetime)
    local disk = Instance.new("Part")
    disk.Name = "HVTTelegraph"
    disk.Shape = Enum.PartType.Cylinder
    disk.Size = Vector3.new(0.16, radius * 2, radius * 2)
    disk.CFrame = CFrame.new(position - Vector3.new(0, 2.65, 0)) * CFrame.Angles(0, 0, math.rad(90))
    disk.Material = Enum.Material.Neon
    disk.Color = color
    disk.Transparency = 0.52
    disk.Anchored = true
    disk.CanCollide = false
    disk.CanTouch = false
    disk.Parent = parent
    TweenService:Create(disk, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Transparency = 0.12,
    }):Play()
    return disk
end

local function huntsmanBarrage(enemy)
    local roots = getLivingRoots()
    if #roots == 0 then
        return
    end
    broadcast(statePayload("PRECISION BARRAGE"))
    local room = ctx.World.GetRoom(active.Room)
    local parent = room and room.Folder or workspace
    local count = math.min(3, #roots + 1)
    for index = 1, count do
        local target = roots[((index - 1) % #roots) + 1]
        local offset = Vector3.new(rng:NextNumber(-5, 5), 0, rng:NextNumber(-5, 5))
        local position = target.Root.Position + offset
        local disk = makeDisk(parent, position, 6.5, Color3.fromRGB(224, 102, 72), 1.05)
        task.delay(1.05, function()
            if disk.Parent then
                damageNear(position, 6.5, math.floor(enemy.Damage * 1.15))
                disk:Destroy()
            end
        end)
    end
end

local function bulwarkQuake(enemy)
    broadcast(statePayload("SEISMIC BREAK"))
    local room = ctx.World.GetRoom(active.Room)
    local parent = room and room.Folder or workspace
    local position = enemy.Root.Position
    local disk = makeDisk(parent, position, 15, Color3.fromRGB(237, 184, 75), 0.95)
    TweenService:Create(disk, TweenInfo.new(0.95, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.16, 38, 38),
    }):Play()
    task.delay(0.95, function()
        if disk.Parent then
            damageNear(position, 19, math.floor(enemy.Damage * 1.35))
            disk:Destroy()
        end
    end)
end

local function reaperCross(enemy)
    local roots = getLivingRoots()
    if #roots == 0 then
        return
    end
    local target = roots[rng:NextInteger(1, #roots)]
    local position = target.Root.Position
    broadcast(statePayload("CROSS EXECUTION"))
    local room = ctx.World.GetRoom(active.Room)
    local parent = room and room.Folder or workspace
    local parts = {}
    for _, angle in ipairs({ 45, -45 }) do
        local slash = Instance.new("Part")
        slash.Name = "ReaperTelegraph"
        slash.Size = Vector3.new(2.4, 0.18, 28)
        slash.CFrame = CFrame.new(position - Vector3.new(0, 2.55, 0)) * CFrame.Angles(0, math.rad(angle), 0)
        slash.Material = Enum.Material.Neon
        slash.Color = Color3.fromRGB(194, 84, 222)
        slash.Transparency = 0.48
        slash.Anchored = true
        slash.CanCollide = false
        slash.CanTouch = false
        slash.Parent = parent
        table.insert(parts, slash)
        TweenService:Create(slash, TweenInfo.new(0.72, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Transparency = 0.08,
        }):Play()
    end
    task.delay(0.72, function()
        damageNear(position, 7.5, math.floor(enemy.Damage * 1.45))
        for _, part in ipairs(parts) do
            if part.Parent then
                part:Destroy()
            end
        end
    end)
end

local function executeAbility()
    if not active or not active.Enemy or not active.Enemy.Alive then
        return
    end
    if active.Variant == "Huntsman" then
        huntsmanBarrage(active.Enemy)
    elseif active.Variant == "Bulwark" then
        bulwarkQuake(active.Enemy)
    else
        reaperCross(active.Enemy)
    end
end

local function rewardHVT()
    if not active or active.Rewarded then
        return
    end
    active.Rewarded = true
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.18)
        end
        ctx.Remotes.State:FireClient(player, "Notice", string.format("HVT %s neutralized — bounty protocol unlocked", active.Variant))
    end
    if ctx.Augments then
        ctx.Augments.OfferParty("HVT BOUNTY")
    end
    broadcast(inactivePayload())
end

local function clearTracking()
    active = nil
end

local function replaceEnemyWithHVT(roomIndex)
    local chance = ctx.Config.HVT and ctx.Config.HVT.Rooms and ctx.Config.HVT.Rooms[roomIndex]
    if not chance or rng:NextNumber() > chance then
        return
    end

    local candidates = {}
    local allEnemies = ctx.Enemies.GetAll()
    for id, enemy in pairs(allEnemies) do
        if enemy.Alive and enemy.RoomIndex == roomIndex and not enemy.Data.Boss and not enemy.Data.HVT then
            table.insert(candidates, { Id = id, Enemy = enemy })
        end
    end
    if #candidates == 0 then
        return
    end

    local selected = candidates[rng:NextInteger(1, #candidates)]
    local position = selected.Enemy.Root.Position
    selected.Enemy.Alive = false
    if selected.Enemy.Model then
        selected.Enemy.Model:Destroy()
    end
    allEnemies[selected.Id] = nil

    local variants = ctx.Config.HVT.Variants
    local variant = variants[rng:NextInteger(1, #variants)]
    local partyCount = math.max(1, #ctx.Run.GetLivingParticipants())
    local difficulty = (1 + ((partyCount - 1) * 0.30)) * (1 + ((roomIndex - 1) * 0.12))
    local enemy = ctx.Enemies.Spawn(variant, roomIndex, position, difficulty)
    active = {
        Room = roomIndex,
        Variant = variant,
        Enemy = enemy,
        LastAbility = os.clock(),
        Rewarded = false,
    }

    broadcast(statePayload("BOUNTY TARGET ACQUIRED"))
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        ctx.Remotes.State:FireClient(player, "Notice", string.format("HVT DETECTED — %s has entered the sector", variant))
    end
end

local function step()
    if not ctx.Run or not ctx.Run.IsActive or not ctx.Run.IsActive() then
        if active then
            clearTracking()
        end
        lastObservedRoom = 0
        return
    end

    local roomIndex = ctx.Run.GetCurrentRoom()
    if roomIndex ~= lastObservedRoom then
        lastObservedRoom = roomIndex
        if active and active.Room ~= roomIndex then
            clearTracking()
            broadcast(inactivePayload())
        end
        task.delay(0.35, function()
            if ctx.Run.IsActive() and ctx.Run.GetCurrentRoom() == roomIndex and not active then
                replaceEnemyWithHVT(roomIndex)
            end
        end)
    end

    if not active then
        return
    end

    local enemy = active.Enemy
    if not enemy or not enemy.Alive or not enemy.Model.Parent then
        rewardHVT()
        clearTracking()
        return
    end

    local now = os.clock()
    if now - active.LastAbility >= 5.2 then
        active.LastAbility = now
        executeAbility()
    end
    broadcast(statePayload(""))
end

function HVTService.Init(context)
    ctx = context
    RunService.Heartbeat:Connect(function(dt)
        accumulator += dt
        if accumulator < 0.35 then
            return
        end
        accumulator = 0
        step()
    end)
end

function HVTService.PushState(player)
    if player and player.Parent then
        ctx.Remotes.State:FireClient(player, "HVT", statePayload(""))
    end
end

return HVTService
