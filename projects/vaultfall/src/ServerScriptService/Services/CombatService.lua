local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Arsenal = require(shared:WaitForChild("Arsenal"))

local CombatService = {}
local ctx
local rng = Random.new()
local weaponStates = {}
local dashCooldowns = {}

local function isFiniteVector3(value)
    if typeof(value) ~= "Vector3" then
        return false
    end
    return value.X == value.X and value.Y == value.Y and value.Z == value.Z
        and math.abs(value.X) < 100000 and math.abs(value.Y) < 100000 and math.abs(value.Z) < 100000
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

local function getDirection(root, requested)
    if isFiniteVector3(requested) then
        local unit = requested.Magnitude > 0.05 and requested.Unit or nil
        if unit then
            return unit
        end
    end
    return root.CFrame.LookVector
end

local function equippedWeapon(player)
    return ctx.Run.GetEquippedWeapon(player) or ctx.Config.StartingWeapon
end

local function weaponDefinition(weapon)
    return Arsenal.Get(weapon.Archetype or "Carbine") or Arsenal.Get("Carbine")
end

local function modifiers(player)
    if ctx.Augments then
        return ctx.Augments.GetModifiers(player)
    end
    return {
        Damage = 1, FireInterval = 1, Magazine = 1, Reload = 1, Recoil = 1,
        Spread = 1, CritChance = 0, CritDamage = 1, EliteDamage = 1,
    }
end

local function magazineSize(player, weapon, definition)
    local mods = modifiers(player)
    return math.max(1, math.floor(definition.Magazine * (weapon.MagazineMultiplier or 1) * mods.Magazine + 0.5))
end

local function stateFor(player)
    local weapon = equippedWeapon(player)
    local definition = weaponDefinition(weapon)
    local key = string.format("%s|%s|%s", tostring(weapon.Name), tostring(weapon.Archetype), tostring(weapon.Trait))
    local state = weaponStates[player]
    if not state or state.Key ~= key then
        state = {
            Key = key,
            Ammo = magazineSize(player, weapon, definition),
            Reloading = false,
            ReloadToken = 0,
            LastShot = 0,
        }
        weaponStates[player] = state
    end
    return state, weapon, definition
end

local function combatPayload(player, state, weapon, definition)
    local mods = modifiers(player)
    return {
        Ammo = state.Ammo,
        Magazine = magazineSize(player, weapon, definition),
        Reloading = state.Reloading,
        Archetype = weapon.Archetype or "Carbine",
        WeaponName = weapon.Name,
        FireMode = definition.FireMode,
        ReloadTime = definition.ReloadTime * (weapon.ReloadMultiplier or 1) * mods.Reload,
    }
end

local function pushCombat(player)
    if not player.Parent then
        return
    end
    local state, weapon, definition = stateFor(player)
    ctx.Remotes.State:FireClient(player, "Combat", combatPayload(player, state, weapon, definition))
end

local function canUseWeapon(player)
    return ctx.Run.IsParticipant(player) or (ctx.Training and ctx.Training.IsAvailable(player))
end

local function beginReload(player)
    if not canUseWeapon(player) then
        return
    end
    local state, weapon, definition = stateFor(player)
    local capacity = magazineSize(player, weapon, definition)
    if state.Reloading or state.Ammo >= capacity then
        return
    end

    local mods = modifiers(player)
    local reloadDuration = definition.ReloadTime * (weapon.ReloadMultiplier or 1) * mods.Reload
    state.Reloading = true
    state.ReloadToken += 1
    local token = state.ReloadToken
    pushCombat(player)
    ctx.Remotes.State:FireClient(player, "WeaponFX", {
        Kind = "Reload",
        Duration = reloadDuration,
        Archetype = weapon.Archetype or "Carbine",
    })

    task.delay(reloadDuration, function()
        local current = weaponStates[player]
        if current ~= state or state.ReloadToken ~= token then
            return
        end
        state.Reloading = false
        state.Ammo = magazineSize(player, weapon, definition)
        pushCombat(player)
    end)
end

local function calculateDamage(player, weapon, definition)
    local attackMultiplier = ctx.Profile.GetAttackMultiplier(player)
    local archetypeScale = definition.BaseDamage / Arsenal.Weapons.Carbine.BaseDamage
    local mods = modifiers(player)
    return math.max(1, weapon.Power * archetypeScale * (weapon.DamageMultiplier or 1) * attackMultiplier * mods.Damage)
end

local function damageEnemy(player, enemy, amount, weapon, multiplier)
    local mods = modifiers(player)
    local critChance = math.clamp((weapon.CritChance or 0) + mods.CritChance, 0, 0.85)
    local crit = rng:NextNumber() <= critChance
    local eliteMultiplier = (enemy.Data.Elite or enemy.Data.Boss) and mods.EliteDamage or 1
    local critMultiplier = (weapon.CritMultiplier or 1.5) * mods.CritDamage
    local damage = amount * (multiplier or 1) * eliteMultiplier * (crit and critMultiplier or 1)
    damage = math.floor(damage + 0.5)
    local killed = ctx.Enemies.Damage(enemy, damage, player)
    ctx.Remotes.State:FireClient(player, "Hit", {
        Damage = damage,
        Crit = crit,
        Kill = killed,
        Enemy = enemy.Type,
    })
    if killed and ctx.Augments then
        ctx.Augments.OnEnemyKilled(player)
    end
    return killed
end

local function fireWeapon(player, requestedDirection)
    local isRun = ctx.Run.IsParticipant(player)
    local isTraining = not isRun and ctx.Training and ctx.Training.IsAvailable(player)
    if not isRun and not isTraining then
        return
    end

    local root = characterRoot(player)
    if not root then
        return
    end

    local state, weapon, definition = stateFor(player)
    if state.Reloading then
        return
    end

    local mods = modifiers(player)
    local interval = definition.FireInterval * (weapon.FireIntervalMultiplier or 1) * mods.FireInterval
    local now = os.clock()
    if now - state.LastShot < interval * 0.9 then
        return
    end
    if state.Ammo <= 0 then
        beginReload(player)
        return
    end

    state.LastShot = now
    state.Ammo -= 1
    local direction = getDirection(root, requestedDirection)
    local baseDamage = calculateDamage(player, weapon, definition)
    local archetype = weapon.Archetype or "Carbine"

    if isRun then
        local spread = definition.Spread * (weapon.SpreadMultiplier or 1) * mods.Spread
        local coneDot = 1 - math.clamp(spread * 3.2, 0.002, 0.24)
        local candidates = ctx.Enemies.GetInRange(root.Position, definition.Range, direction, coneDot, ctx.Run.GetCurrentRoom())

        if archetype == "Shotgun" then
            local pelletCount = definition.Pellets or 8
            if #candidates > 0 then
                local remaining = pelletCount
                local targetCount = math.min(3, #candidates)
                for index = 1, targetCount do
                    local pellets = index == 1 and math.ceil(remaining * 0.65) or math.max(1, math.floor(remaining / (targetCount - index + 1)))
                    remaining -= pellets
                    damageEnemy(player, candidates[index], baseDamage * pellets * 0.42, weapon, 1 - ((index - 1) * 0.16))
                end
            end
        elseif archetype == "RailRifle" then
            for index = 1, math.min(3, #candidates) do
                local penetration = ({ 1, 0.68, 0.46 })[index]
                damageEnemy(player, candidates[index], baseDamage, weapon, penetration)
            end
        elseif candidates[1] then
            damageEnemy(player, candidates[1], baseDamage, weapon, 1)
        end
    else
        ctx.Training.RecordShot(player, direction, definition.Range, baseDamage, archetype)
    end

    ctx.Remotes.State:FireClient(player, "WeaponFX", {
        Kind = "Shot",
        Archetype = archetype,
        Recoil = definition.Recoil * (weapon.RecoilMultiplier or 1) * mods.Recoil,
        EmptyAfter = state.Ammo <= 0,
    })
    pushCombat(player)

    if state.Ammo <= 0 then
        task.delay(0.16, function()
            if player.Parent then
                beginReload(player)
            end
        end)
    end
end

local function performDash(player, requestedDirection)
    if not ctx.Run.IsParticipant(player) then
        return
    end

    local dash = ctx.Config.Attacks.Dash
    local now = os.clock()
    local last = dashCooldowns[player] or 0
    if now - last < dash.Cooldown then
        return
    end
    dashCooldowns[player] = now

    local root = characterRoot(player)
    if not root then
        return
    end

    local direction = getDirection(root, requestedDirection)
    local flat = Vector3.new(direction.X, 0, direction.Z)
    if flat.Magnitude <= 0.05 then
        return
    end
    flat = flat.Unit

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
    local cast = Workspace:Raycast(origin, flat * ctx.Config.Attacks.Dash.Distance, params)
    local distance = ctx.Config.Attacks.Dash.Distance
    if cast then
        distance = math.max(0, cast.Distance - 3)
    end
    if distance < 2 then
        return
    end

    local destination = origin + flat * distance
    root.CFrame = CFrame.lookAt(destination, destination + flat)
    root.AssemblyLinearVelocity = Vector3.zero
    ctx.Remotes.State:FireClient(player, "WeaponFX", { Kind = "Dash" })
end

function CombatService.Init(context)
    ctx = context

    ctx.Remotes.Attack.OnServerEvent:Connect(function(player, action, direction)
        if action == "Fire" then
            fireWeapon(player, direction)
        elseif action == "Reload" then
            beginReload(player)
        end
    end)

    ctx.Remotes.Skill.OnServerEvent:Connect(function(player, skillName, direction)
        if skillName == "Dash" then
            performDash(player, direction)
        end
    end)
end

function CombatService.PushState(player)
    pushCombat(player)
end

function CombatService.ResetPlayer(player)
    weaponStates[player] = nil
    dashCooldowns[player] = nil
end

return CombatService
