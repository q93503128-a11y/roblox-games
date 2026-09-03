local Workspace = game:GetService("Workspace")

local CombatService = {}
local ctx
local cooldowns = {}
local rng = Random.new()

local function isFiniteVector3(value)
    if typeof(value) ~= "Vector3" then
        return false
    end
    return value.X == value.X and value.Y == value.Y and value.Z == value.Z
        and math.abs(value.X) < 100000 and math.abs(value.Y) < 100000 and math.abs(value.Z) < 100000
end

local function getDirection(root, requested)
    if isFiniteVector3(requested) then
        local flat = Vector3.new(requested.X, 0, requested.Z)
        if flat.Magnitude > 0.05 then
            return flat.Unit
        end
    end
    local look = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
    return look.Magnitude > 0.05 and look.Unit or Vector3.new(0, 0, -1)
end

local function canUse(player, key, cooldown)
    local playerCooldowns = cooldowns[player]
    if not playerCooldowns then
        playerCooldowns = {}
        cooldowns[player] = playerCooldowns
    end

    local now = os.clock()
    local last = playerCooldowns[key] or 0
    if now - last < cooldown then
        return false
    end
    playerCooldowns[key] = now
    return true
end

local function characterRoot(player)
    local character = player.Character
    if not character then
        return nil
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or humanoid.Health <= 0 then
        return nil
    end
    return root, humanoid
end

local function calculateDamage(player, attackDef)
    local weapon = ctx.Run.GetEquippedWeapon(player) or ctx.Config.StartingWeapon
    local attackMultiplier = ctx.Profile.GetAttackMultiplier(player)
    return math.max(1, weapon.Power * attackMultiplier * attackDef.Multiplier), weapon
end

local function performAttack(player, attackName, requestedDirection)
    if not ctx.Run.IsParticipant(player) then
        return
    end

    local attack = ctx.Config.Attacks[attackName]
    if not attack or attackName == "Dash" then
        return
    end
    if not canUse(player, attackName, attack.Cooldown) then
        return
    end

    local root = characterRoot(player)
    if not root then
        return
    end

    local direction = getDirection(root, requestedDirection)
    local baseDamage, weapon = calculateDamage(player, attack)
    local targets = ctx.Enemies.GetInRange(root.Position, attack.Range, direction, attack.ConeDot, ctx.Run.GetCurrentRoom())
    local maxTargets = attackName == "Basic" and 3 or attackName == "Heavy" and 6 or 14

    local hitAny = false
    for index, enemy in ipairs(targets) do
        if index > maxTargets then
            break
        end
        hitAny = true
        local crit = rng:NextNumber() <= (weapon.CritChance or 0)
        local damage = baseDamage * (crit and (weapon.CritMultiplier or 1.5) or 1)
        damage = math.floor(damage + 0.5)
        local killed = ctx.Enemies.Damage(enemy, damage, player)
        ctx.Remotes.State:FireClient(player, "Hit", {
            Damage = damage,
            Crit = crit,
            Kill = killed,
            Enemy = enemy.Type,
        })
    end

    if not hitAny then
        ctx.Remotes.State:FireClient(player, "Swing", { Attack = attackName })
    end
end

local function performDash(player, requestedDirection)
    if not ctx.Run.IsParticipant(player) then
        return
    end

    local dash = ctx.Config.Attacks.Dash
    if not canUse(player, "Dash", dash.Cooldown) then
        return
    end

    local root = characterRoot(player)
    if not root then
        return
    end

    local direction = getDirection(root, requestedDirection)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filter = { player.Character }
    local world = Workspace:FindFirstChild("VaultfallWorld")
    local enemyFolder = world and world:FindFirstChild("Enemies")
    if enemyFolder then
        table.insert(filter, enemyFolder)
    end
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true

    local origin = root.Position
    local cast = Workspace:Raycast(origin, direction * dash.Distance, params)
    local distance = dash.Distance
    if cast then
        distance = math.max(0, cast.Distance - 3)
    end

    if distance < 2 then
        return
    end

    local destination = origin + direction * distance
    root.CFrame = CFrame.lookAt(destination, destination + direction)
    root.AssemblyLinearVelocity = Vector3.zero
end

function CombatService.Init(context)
    ctx = context

    ctx.Remotes.Attack.OnServerEvent:Connect(function(player, attackName, direction)
        if type(attackName) ~= "string" then
            return
        end
        performAttack(player, attackName, direction)
    end)

    ctx.Remotes.Skill.OnServerEvent:Connect(function(player, skillName, direction)
        if skillName == "Dash" then
            performDash(player, direction)
        end
    end)
end

return CombatService
