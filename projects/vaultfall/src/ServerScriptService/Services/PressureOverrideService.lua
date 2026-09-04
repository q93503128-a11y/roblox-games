local TweenService = game:GetService("TweenService")

local PressureOverrideService = {}
local ctx

local armed = false
local activeRoom = 0
local consoleModel
local promptBusy = false

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

local function addLabel(parent, text, subtext)
    local gui = Instance.new("BillboardGui")
    gui.Name = "PressureReadout"
    gui.Size = UDim2.fromOffset(330, 92)
    gui.StudsOffset = Vector3.new(0, 5.2, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 70
    gui.Parent = parent

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0.52, 0)
    title.Font = Enum.Font.GothamBold
    title.Text = text
    title.TextColor3 = Color3.fromRGB(255, 180, 72)
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

    local railLeft = neon(model, "PowerRail", Vector3.new(0.32, 0.32, 7.5), CFrame.new(origin + Vector3.new(-2.1, 0.9, 0)), Color3.fromRGB(255, 126, 36))
    local railRight = neon(model, "PowerRail", Vector3.new(0.32, 0.32, 7.5), CFrame.new(origin + Vector3.new(2.1, 0.9, 0)), Color3.fromRGB(255, 126, 36))
    railLeft.Transparency = 0.22
    railRight.Transparency = 0.22

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 152, 52)
    light.Range = 18
    light.Brightness = 2.2
    light.Shadows = true
    light.Parent = screen

    addLabel(screen, "PRESSURE OVERRIDE", "+35% ESSENCE  •  +LOOT  •  HEAVIER NEXT HOSTILE SECTOR")

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "PressureOverridePrompt"
    prompt.ActionText = "ARM OVERRIDE"
    prompt.ObjectText = "Breach Pressure Regulator"
    prompt.HoldDuration = 1.65
    prompt.MaxActivationDistance = 11
    prompt.RequiresLineOfSight = false
    prompt.Parent = screen

    local pulseTween = TweenService:Create(screen, TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Transparency = 0.28,
    })
    pulseTween:Play()

    prompt.Triggered:Connect(function(player)
        if promptBusy or armed or not ctx.Run.IsParticipant(player) then
            return
        end
        if ctx.Run.GetCurrentRoom() ~= roomIndex or not ctx.Run.IsRoomCleared() then
            return
        end

        promptBusy = true
        armed = true
        prompt.Enabled = false
        screen.Color = Color3.fromRGB(255, 78, 42)
        light.Color = screen.Color
        addLabel(screen, "OVERRIDE ARMED", "NEXT HOSTILE SECTOR: HIGH PRESSURE / HIGH YIELD")

        for _, teammate in ipairs(ctx.Run.GetLivingParticipants()) do
            ctx.Remotes.State:FireClient(teammate, "Notice", "PRESSURE OVERRIDE ARMED — next hostile sector gains reinforcements; Essence +35% and loot quality boosted")
        end

        task.delay(0.9, function()
            if model.Parent then
                for _, descendant in ipairs(model:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.Material == Enum.Material.Neon then
                        TweenService:Create(descendant, TweenInfo.new(0.35), { Transparency = math.max(descendant.Transparency, 0.48) }):Play()
                    end
                end
            end
        end)
    end)
end

function PressureOverrideService.Init(context)
    ctx = context
end

function PressureOverrideService.Reset()
    armed = false
    activeRoom = 0
    destroyConsole()
end

function PressureOverrideService.OnRoomActivated(roomIndex)
    destroyConsole()
    local roomType = ctx.Config.RoomSequence[roomIndex]
    if armed and HOSTILE_TYPES[roomType] then
        armed = false
        activeRoom = roomIndex
        for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
            ctx.Remotes.State:FireClient(player, "Notice", "HIGH-PRESSURE SECTOR — reinforced hostiles active; +35% Essence and enhanced clearance loot")
            ctx.Remotes.State:FireClient(player, "Pressure", {
                Active = true,
                Room = roomIndex,
                EssenceMultiplier = 1.35,
                LootLuck = 0.45,
            })
        end
    else
        activeRoom = 0
    end
end

function PressureOverrideService.OnRoomCleared(roomIndex)
    local wasActive = activeRoom == roomIndex
    activeRoom = 0
    if wasActive then
        for _, player in ipairs(ctx.Run.GetLivingParticipants()) do
            ctx.Remotes.State:FireClient(player, "Pressure", { Active = false, Room = roomIndex })
            ctx.Remotes.State:FireClient(player, "Notice", "PRESSURE BROKEN — enhanced sector rewards secured")
        end
    end
    buildConsole(roomIndex)
end

function PressureOverrideService.IsActive(roomIndex)
    return activeRoom == roomIndex
end

function PressureOverrideService.GetEssenceMultiplier(roomIndex)
    return activeRoom == roomIndex and 1.35 or 1
end

function PressureOverrideService.GetLootLuck(roomIndex)
    return activeRoom == roomIndex and 0.45 or 0
end

function PressureOverrideService.GetReinforcementCount(roomIndex, baseCount)
    if activeRoom ~= roomIndex then
        return 0
    end
    return math.max(2, math.ceil(baseCount * 0.28))
end

return PressureOverrideService
