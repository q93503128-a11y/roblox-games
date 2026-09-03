local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local TrainingService = {}
local ctx
local sessions = {}
local targetCooldowns = {}

local RANGE_CENTER = Vector3.new(-142, 4, -72)
local RANGE_RADIUS = 78
local TARGET_DOT = 0.982
local SESSION_TIMEOUT = 4

local function rootFor(player)
    local character = player.Character
    if not character then
        return nil
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not root then
        return nil
    end
    return root
end

local function inRange(player)
    if ctx.Run.IsParticipant(player) then
        return false
    end
    local root = rootFor(player)
    if not root then
        return false
    end
    local delta = root.Position - RANGE_CENTER
    return Vector3.new(delta.X, 0, delta.Z).Magnitude <= RANGE_RADIUS
end

local function targets()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    local safehouse = world and world:FindFirstChild("Safehouse")
    if not safehouse then
        return {}
    end
    local result = {}
    for _, item in ipairs(safehouse:GetDescendants()) do
        if item:IsA("BasePart") and item.Name == "Target" then
            table.insert(result, item)
        end
    end
    return result
end

local function pickTarget(origin, direction, maxRange, character)
    local best
    local bestScore = TARGET_DOT
    for _, target in ipairs(targets()) do
        local offset = target.Position - origin
        local distance = offset.Magnitude
        if distance > 1 and distance <= maxRange then
            local dot = direction:Dot(offset.Unit)
            local angularSlack = math.clamp(math.max(target.Size.X, target.Size.Y) / math.max(distance, 1) * 0.34, 0, 0.018)
            local threshold = TARGET_DOT - angularSlack
            if dot >= threshold and dot > bestScore - angularSlack then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = character and { character } or {}
                params.IgnoreWater = true
                local cast = Workspace:Raycast(origin, offset, params)
                if cast and cast.Instance == target then
                    best = target
                    bestScore = dot
                end
            end
        end
    end
    return best
end

local function animateTarget(target, strength)
    if targetCooldowns[target] then
        return
    end
    targetCooldowns[target] = true
    local original = target.CFrame
    local originalColor = target.Color
    local tilt = math.rad(math.clamp(strength * 0.22, 5, 16))
    local direction = math.random() > 0.5 and 1 or -1
    local kick = original * CFrame.Angles(tilt, 0, math.rad(direction * tilt * 0.45))
    target.Color = Color3.fromRGB(215, 129, 92)
    TweenService:Create(target, TweenInfo.new(0.055, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = kick }):Play()
    task.delay(0.07, function()
        if target.Parent then
            TweenService:Create(target, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                CFrame = original,
                Color = originalColor,
            }):Play()
        end
        task.delay(0.22, function()
            targetCooldowns[target] = nil
        end)
    end)
end

local function push(player, session, damage, hit)
    if not player.Parent then
        return
    end
    local elapsed = math.max(os.clock() - session.StartedAt, 0.01)
    ctx.Remotes.State:FireClient(player, "Training", {
        Active = true,
        Hit = hit == true,
        LastDamage = math.floor(damage + 0.5),
        TotalDamage = math.floor(session.TotalDamage + 0.5),
        Hits = session.Hits,
        Shots = session.Shots,
        Accuracy = session.Shots > 0 and session.Hits / session.Shots or 0,
        DPS = session.TotalDamage / elapsed,
        BestHit = math.floor(session.BestHit + 0.5),
        Archetype = session.Archetype,
    })
end

local function sessionFor(player, archetype)
    local now = os.clock()
    local current = sessions[player]
    if not current or now - current.LastShot > SESSION_TIMEOUT or current.Archetype ~= archetype then
        current = {
            StartedAt = now,
            LastShot = now,
            TotalDamage = 0,
            Hits = 0,
            Shots = 0,
            BestHit = 0,
            Archetype = archetype,
            Token = 0,
        }
        sessions[player] = current
    end
    current.LastShot = now
    return current
end

function TrainingService.IsAvailable(player)
    return inRange(player)
end

function TrainingService.RecordShot(player, direction, maxRange, damage, archetype)
    if not inRange(player) then
        return false
    end
    local root = rootFor(player)
    if not root or typeof(direction) ~= "Vector3" or direction.Magnitude < 0.05 then
        return false
    end

    local session = sessionFor(player, archetype or "Carbine")
    session.Shots += 1
    session.Token += 1
    local token = session.Token
    local target = pickTarget(root.Position + Vector3.new(0, 1.4, 0), direction.Unit, maxRange or 180, player.Character)
    if target then
        local dealt = math.max(1, damage or 1)
        if archetype == "Shotgun" then
            dealt *= 3.25
        end
        session.Hits += 1
        session.TotalDamage += dealt
        session.BestHit = math.max(session.BestHit, dealt)
        animateTarget(target, dealt)
        ctx.Remotes.State:FireClient(player, "Hit", {
            Damage = math.floor(dealt + 0.5),
            Crit = false,
            Kill = false,
            Enemy = "Training Target",
        })
        push(player, session, dealt, true)
    else
        push(player, session, 0, false)
    end

    task.delay(SESSION_TIMEOUT + 0.15, function()
        local latest = sessions[player]
        if latest == session and latest.Token == token and os.clock() - latest.LastShot >= SESSION_TIMEOUT then
            ctx.Remotes.State:FireClient(player, "Training", {
                Active = false,
                TotalDamage = math.floor(latest.TotalDamage + 0.5),
                Hits = latest.Hits,
                Shots = latest.Shots,
                Accuracy = latest.Shots > 0 and latest.Hits / latest.Shots or 0,
                DPS = latest.TotalDamage / math.max(latest.LastShot - latest.StartedAt, 0.01),
                BestHit = math.floor(latest.BestHit + 0.5),
                Archetype = latest.Archetype,
            })
        end
    end)
    return true
end

function TrainingService.Init(context)
    ctx = context
end

function TrainingService.ClearPlayer(player)
    sessions[player] = nil
end

return TrainingService
