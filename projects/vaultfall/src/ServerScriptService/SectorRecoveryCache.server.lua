local RunService = game:GetService("RunService")

local services = script.Parent:WaitForChild("Services")
local Run = require(services:WaitForChild("RunService"))
local World = require(services:WaitForChild("WorldService"))
local Enemies = require(services:WaitForChild("EnemyService"))
local Objectives = require(services:WaitForChild("ObjectiveService"))
local Combat = require(services:WaitForChild("CombatService"))

local HOSTILE_ROOM_TYPES = {
    Combat = true,
    DeepCombat = true,
    Elite = true,
}

local activeModel
local activeRoom = 0
local spawnedForRoom = {}
local claimed = {}
local wasActive = false

local function makePart(parent, name, size, cframe, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.Metal
    part.Anchored = true
    part.CanCollide = name ~= "Glow"
    part.Parent = parent
    return part
end

local function clearCache()
    if activeModel then
        activeModel:Destroy()
        activeModel = nil
    end
    activeRoom = 0
    table.clear(claimed)
end

local function hasLivingEnemy(roomIndex)
    for _, enemy in pairs(Enemies.GetAll()) do
        if enemy.Alive and enemy.RoomIndex == roomIndex then
            return true
        end
    end
    return false
end

local function makeLabel(parent, text, color)
    local gui = Instance.new("BillboardGui")
    gui.Name = "RecoveryLabel"
    gui.Size = UDim2.fromOffset(250, 68)
    gui.StudsOffset = Vector3.new(0, 4.8, 0)
    gui.AlwaysOnTop = false
    gui.MaxDistance = 46
    gui.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.35
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = gui
end

local function spawnCache(roomIndex)
    local room = World.GetRoom(roomIndex)
    if not room or not room.Folder then
        return
    end

    clearCache()
    activeRoom = roomIndex
    spawnedForRoom[roomIndex] = true

    local model = Instance.new("Model")
    model.Name = "FieldRecoveryCache"
    model.Parent = room.Folder
    activeModel = model

    local origin = room.Origin + Vector3.new(30, 0, -30)
    local base = makePart(model, "Base", Vector3.new(12, 0.8, 7), CFrame.new(origin + Vector3.new(0, 0.5, 0)), Color3.fromRGB(39, 45, 49), Enum.Material.DiamondPlate)
    makePart(model, "Back", Vector3.new(11, 5.5, 0.7), CFrame.new(origin + Vector3.new(0, 3.1, 2.7)), Color3.fromRGB(29, 35, 39), Enum.Material.Metal)
    makePart(model, "Canopy", Vector3.new(12, 0.45, 4), CFrame.new(origin + Vector3.new(0, 5.8, 1.2)), Color3.fromRGB(52, 61, 66), Enum.Material.Metal)

    for _, x in ipairs({ -4.8, 4.8 }) do
        makePart(model, "Support", Vector3.new(0.5, 5.5, 0.5), CFrame.new(origin + Vector3.new(x, 3.1, 2.35)), Color3.fromRGB(67, 76, 82), Enum.Material.Metal)
    end

    local medical = makePart(model, "MedicalCore", Vector3.new(3.7, 2.6, 2.5), CFrame.new(origin + Vector3.new(-2.7, 2.05, 0.1)), Color3.fromRGB(43, 82, 77), Enum.Material.Metal)
    local ammo = makePart(model, "AmmoCore", Vector3.new(3.7, 2.6, 2.5), CFrame.new(origin + Vector3.new(2.7, 2.05, 0.1)), Color3.fromRGB(86, 69, 40), Enum.Material.Metal)

    local medicalGlow = makePart(model, "Glow", Vector3.new(2.5, 0.22, 1.3), medical.CFrame * CFrame.new(0, 1.42, -0.3), Color3.fromRGB(92, 238, 191), Enum.Material.Neon)
    local ammoGlow = makePart(model, "Glow", Vector3.new(2.5, 0.22, 1.3), ammo.CFrame * CFrame.new(0, 1.42, -0.3), Color3.fromRGB(255, 191, 79), Enum.Material.Neon)

    for _, glow in ipairs({ medicalGlow, ammoGlow }) do
        glow.CanCollide = false
        local light = Instance.new("PointLight")
        light.Brightness = 1.5
        light.Range = 11
        light.Color = glow.Color
        light.Parent = glow
    end

    for index = 1, 3 do
        makePart(model, "MedCanister", Vector3.new(0.65, 1.6, 0.65), medical.CFrame * CFrame.new(-1 + ((index - 1) * 1), 0, -1.45), Color3.fromRGB(81, 184, 151), Enum.Material.Metal)
        makePart(model, "AmmoPack", Vector3.new(0.85, 1.1, 0.5), ammo.CFrame * CFrame.new(-1 + ((index - 1) * 1), 0, -1.45), Color3.fromRGB(197, 145, 58), Enum.Material.Metal)
    end

    makeLabel(medical, "FIELD RECOVERY\nPATCH + RELOAD", Color3.fromRGB(121, 255, 208))
    makeLabel(ammo, "FIELD RECOVERY\nPATCH + RELOAD", Color3.fromRGB(255, 208, 112))

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "RecoveryPrompt"
    prompt.ActionText = "RECOVER"
    prompt.ObjectText = "Field Recovery Cache"
    prompt.HoldDuration = 0.75
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = base

    prompt.Triggered:Connect(function(player)
        if not Run.IsParticipant(player) or Run.GetCurrentRoom() ~= activeRoom or claimed[player] then
            return
        end

        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return
        end

        claimed[player] = true
        humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * 0.22)
        Combat.ResetPlayer(player)
        Combat.PushState(player)

        local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("VaultfallRemotes")
        local stateRemote = remotes and remotes:FindFirstChild("State")
        if stateRemote then
            stateRemote:FireClient(player, "Notice", "FIELD RECOVERY — 22% health restored and weapon fully serviced")
        end
    end)
end

local function resetRunTracking()
    clearCache()
    table.clear(spawnedForRoom)
end

RunService.Heartbeat:Connect(function()
    local active = Run.IsActive()
    if not active then
        if wasActive then
            resetRunTracking()
        end
        wasActive = false
        return
    end

    if not wasActive then
        table.clear(spawnedForRoom)
    end
    wasActive = true

    local roomIndex = Run.GetCurrentRoom()
    if roomIndex <= 0 then
        return
    end

    if activeRoom ~= 0 and activeRoom ~= roomIndex then
        clearCache()
    end

    if spawnedForRoom[roomIndex] then
        return
    end

    local room = World.GetRoom(roomIndex)
    if not room or not HOSTILE_ROOM_TYPES[room.Type] then
        return
    end

    if hasLivingEnemy(roomIndex) or not Objectives.IsComplete(roomIndex) then
        return
    end

    spawnedForRoom[roomIndex] = true
    task.delay(0.25, function()
        if Run.IsActive() and Run.GetCurrentRoom() == roomIndex and not hasLivingEnemy(roomIndex) and Objectives.IsComplete(roomIndex) then
            spawnCache(roomIndex)
        end
    end)
end)
