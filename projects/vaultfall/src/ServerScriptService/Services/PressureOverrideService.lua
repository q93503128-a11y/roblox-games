local TweenService = game:GetService("TweenService")

local PressureOverrideService = {}
local ctx

local armed = false
local activeRoom = 0
local consoleModel
local promptBusy = false
local spawnSerial = 0
local hooksInstalled = false

local HOSTILE_TYPES = {
    Combat = true,
    DeepCombat = true,
    Elite = true,
    Boss = true,
}

local function destroyConsole()
    if consoleModel then
        consoleModel:Destroy()
        consoleModel = nil
    end
    promptBusy = false
end

local function resetState()
    armed = false
    activeRoom = 0
    spawnSerial = 0
    destroyConsole()
end

local function part(parent, name, size, cframe, color, material)
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.CFrame = cframe
    item.Color = color
    item.Material = material or Enum.Material.Metal
    item.Anchored = true
    item.Parent = parent
    return item
end

local function neon(parent, name, size, cframe, color)
    local item = part(parent, name, size, cframe, color, Enum.Material.Neon)
    item.CanCollide = false
    return item
end

local function addLabel(parent, name, text, subtext, titleColor)
    local previous = parent:FindFirstChild(name)
    if previous then
        previous:Destroy()
    end

    local gui = Instance.new("BillboardGui")
    gui.Name = name
    gui.Size = UDim2.fromOffset(350, 94)
    gui.StudsOffset = Vector3.new(0, 5.2, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 72
    gui.Parent = parent

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0.52, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = text
    title.TextColor3 = titleColor
    title.TextStrokeTransparency = 0.55
    title.TextScaled = true
    title.Parent = gui

    local detail = Instance.new("TextLabel")
    detail.BackgroundTransparency = 1
    detail.Position = UDim2.new(0, 0, 0.53, 0)
    detail.Size = UDim2.new(1, 0, 0.35, 0)
    detail.Font = Enum.Font.GothamMedium
    detail.Text = subtext
    detail.TextColor3 = Color3.fromRGB(225, 230, 234)
    detail.TextStrokeTransparency = 0.7
    detail.TextScaled = true
    detail.Parent = gui
end

local function hasFutureHostile(roomIndex)
    for index = roomIndex + 1, ctx.Config.RoomCount do
        if HOSTILE_TYPES[ctx.Config.RoomSequence[index]] then
            return true
        end
    end
    return false
end

local function notifyLiving(message)
    for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
        ctx.Remotes.State:FireClient(player, "Notice", message)
    end
end

local function buildConsole(roomIndex)
    destroyConsole()
    if armed or not hasFutureHostile(roomIndex) then
        return
    end

    local room = ctx.World.GetRoom(roomIndex)
    if not room then
        return
    end

    local model = Instance.new("Model")
    model.Name = "PressureOverrideConsole"
    model:SetAttribute("VaultfallRuntime", true)
    model.Parent = room.Folder
    consoleModel = model

    local origin = room.Origin + Vector3.new(31, 0, -31)
    local base = part(model, "Base", Vector3.new(9, 1.2, 7), CFrame.new(origin + Vector3.new(0, 0.6, 0)), Color3.fromRGB(32, 37, 42))
    base.Material = Enum.Material.DiamondPlate

    part(model, "Pedestal", Vector3.new(5.4, 4.4, 3.8), CFrame.new(origin + Vector3.new(0, 2.8, 0)), Color3.fromRGB(47, 54, 60))
    local screen = neon(model, "OverrideScreen", Vector3.new(4.4, 2.45, 0.28), CFrame.new(origin + Vector3.new(0, 4.05, -2.02)) * CFrame.Angles(math.rad(-8), 0, 0), Color3.fromRGB(255, 146, 46))

    for side = -1, 1, 2 do
        local tower = part(model, "Capacitor", Vector3.new(1.15, 5.8, 1.15), CFrame.new(origin + Vector3.new(side * 3.2, 3.4, 0.8)), Color3.fromRGB(29, 33, 38))
        tower.Shape = Enum.PartType.Cylinder
        tower.CFrame = tower.CFrame * CFrame.Angles(0, 0, math.rad(90))
        local core = neon(model, "CapacitorCore", Vector3.new(0.72, 4.6, 0.72), tower.CFrame, Color3.fromRGB(255, 174, 58))
        core.Shape = Enum.PartType.Cylinder
    end

    for _, x in ipairs({ -2.1, 2.1 }) do
        local rail = neon(model, "PowerRail", Vector3.new(0.32, 0.32, 7.5), CFrame.new(origin + Vector3.new(x, 0.9, 0)), Color3.fromRGB(255, 126, 36))
        rail.Transparency = 0.22
    end

    local warningPlate = neon(model, "WarningPlate", Vector3.new(7.4, 0.12, 2.2), CFrame.new(origin + Vector3.new(0, 1.25, -3.0)), Color3.fromRGB(255, 92, 40))
    warningPlate.Transparency = 0.25

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 152, 52)
    light.Range = 18
    light.Brightness = 2.2
    light.Shadows = true
    light.Parent = screen

    addLabel(screen, "PressureReadout", "PRESSURE OVERRIDE", "+35% ESSENCE  •  BETTER LOOT  •  HARDER NEXT HOSTILE SECTOR", Color3.fromRGB(255, 180, 72))

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "PressureOverridePrompt"
    prompt.ActionText = "ARM OVERRIDE"
    prompt.ObjectText = "Breach Pressure Regulator"
    prompt.HoldDuration = 1.65
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = screen

    TweenService:Create(screen, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Transparency = 0.28,
    }):Play()

    prompt.Triggered:Connect(function(player)
        if promptBusy or armed or not ctx.Run.IsParticipant(player) then
            return
        end
        if ctx.Run.GetCurrentRoom() ~= roomIndex then
            return
        end

        promptBusy = true
        armed = true
        prompt.Enabled = false
        screen.Color = Color3.fromRGB(255, 78, 42)
        light.Color = screen.Color
        addLabel(screen, "PressureReadout", "OVERRIDE ARMED", "NEXT HOSTILE SECTOR: HIGH PRESSURE / HIGH YIELD", Color3.fromRGB(255, 100, 58))
        notifyLiving("PRESSURE OVERRIDE ARMED — next hostile sector hits harder; Essence +35% and clearance loot quality boosted")
    end)
end

local function installHooks()
    if hooksInstalled then
        return
    end
    hooksInstalled = true

    local originalStartRun = ctx.Run.StartRun
    ctx.Run.StartRun = function(requester)
        resetState()
        return originalStartRun(requester)
    end

    local originalActivateRoom = ctx.Run.ActivateRoom
    ctx.Run.ActivateRoom = function(roomIndex)
        destroyConsole()
        spawnSerial = 0
        if armed and HOSTILE_TYPES[ctx.Config.RoomSequence[roomIndex]] then
            armed = false
            activeRoom = roomIndex
        else
            activeRoom = 0
        end

        local result = originalActivateRoom(roomIndex)
        if activeRoom == roomIndex then
            notifyLiving("HIGH-PRESSURE SECTOR — hostiles upgraded; +35% unsecured Essence and enhanced clearance loot")
            for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
                ctx.Remotes.State:FireClient(player, "Pressure", {
                    Active = true,
                    Room = roomIndex,
                    EssenceMultiplier = 1.35,
                    LootLuck = 0.45,
                })
            end
        end
        return result
    end

    local originalSpawn = ctx.Enemies.Spawn
    ctx.Enemies.Spawn = function(enemyType, roomIndex, position, difficulty)
        if activeRoom == roomIndex then
            spawnSerial += 1
            difficulty *= 1.24
            if enemyType == "Shade" and spawnSerial % 4 == 0 then
                enemyType = roomIndex >= 6 and "Brute" or "Archer"
            elseif enemyType == "Archer" and roomIndex >= 8 and spawnSerial % 5 == 0 then
                enemyType = "Brute"
            end
        end
        return originalSpawn(enemyType, roomIndex, position, difficulty)
    end

    local originalGenerateWeapon = ctx.Loot.GenerateWeapon
    ctx.Loot.GenerateWeapon = function(rng, depth, rank, luckBonus)
        local pressureLuck = activeRoom > 0 and 0.45 or 0
        return originalGenerateWeapon(rng, depth, rank, (luckBonus or 0) + pressureLuck)
    end

    local originalEnemyDied = ctx.Run.OnEnemyDied
    ctx.Run.OnEnemyDied = function(enemy, attacker)
        if activeRoom == enemy.RoomIndex and enemy.Data then
            local proxy = table.clone(enemy)
            proxy.Data = table.clone(enemy.Data)
            proxy.Data.Essence = math.max(1, math.floor((proxy.Data.Essence or 1) * 1.35 + 0.5))
            return originalEnemyDied(proxy, attacker)
        end
        return originalEnemyDied(enemy, attacker)
    end

    local originalClearRoom = ctx.Run.ClearRoom
    ctx.Run.ClearRoom = function()
        local roomIndex = ctx.Run.GetCurrentRoom()
        local wasPressure = activeRoom == roomIndex
        local result = originalClearRoom()
        local room = ctx.World.GetRoom(roomIndex)
        local cleared = room and room.ExitGate and room.ExitGate.Transparency >= 0.95

        if cleared then
            if wasPressure then
                for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
                    ctx.Remotes.State:FireClient(player, "Pressure", { Active = false, Room = roomIndex })
                end
                notifyLiving("PRESSURE BROKEN — enhanced sector rewards secured")
            end
            activeRoom = 0
            buildConsole(roomIndex)
        end
        return result
    end

    local originalCompleteRun = ctx.Run.CompleteRun
    ctx.Run.CompleteRun = function(...)
        activeRoom = 0
        destroyConsole()
        return originalCompleteRun(...)
    end

    local originalFailRun = ctx.Run.FailRun
    ctx.Run.FailRun = function(...)
        activeRoom = 0
        destroyConsole()
        return originalFailRun(...)
    end
end

function PressureOverrideService.Init(context)
    ctx = context
    installHooks()
end

function PressureOverrideService.Reset()
    resetState()
end

function PressureOverrideService.IsActive(roomIndex)
    return activeRoom == roomIndex
end

return PressureOverrideService
