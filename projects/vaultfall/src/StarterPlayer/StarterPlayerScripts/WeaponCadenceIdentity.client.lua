local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local pitch = 0
local yaw = 0
local roll = 0
local push = 0
local shotIndex = 0
local burstCount = 0
local lastShotAt = -100

local function addShotImpulse(archetype)
    local now = os.clock()
    local gap = now - lastShotAt
    lastShotAt = now
    shotIndex += 1

    local side = shotIndex % 2 == 0 and 1 or -1

    if archetype == "SMG" then
        if gap <= 0.13 then
            burstCount = math.min(burstCount + 1, 9)
        else
            burstCount = 1
        end
        local climb = 1 + math.clamp((burstCount - 1) / 8, 0, 1) * 0.45
        pitch += 0.050 * climb
        yaw += 0.046 * side
        roll -= 0.026 * side
        push += 0.012
    elseif archetype == "Shotgun" then
        burstCount = 0
        pitch += 0.310
        yaw += 0.055 * side
        roll += 0.090 * side
        push += 0.075
    elseif archetype == "RailRifle" then
        burstCount = 0
        pitch += 0.245
        yaw += 0.018 * side
        roll -= 0.040 * side
        push += 0.060
    else
        burstCount = 0
        pitch += 0.115
        yaw += 0.030 * side
        roll -= 0.018 * side
        push += 0.020
    end

    pitch = math.clamp(pitch, 0, 0.65)
    yaw = math.clamp(yaw, -0.22, 0.22)
    roll = math.clamp(roll, -0.20, 0.20)
    push = math.clamp(push, 0, 0.12)
end

local function recover(dt)
    local pitchRate = 20
    local yawRate = 22
    local rollRate = 24
    local pushRate = 28

    if currentArchetype == "SMG" then
        pitchRate = 25
        yawRate = 19
        rollRate = 22
        pushRate = 32
    elseif currentArchetype == "Shotgun" then
        pitchRate = 11
        yawRate = 15
        rollRate = 12
        pushRate = 13
    elseif currentArchetype == "RailRifle" then
        pitchRate = 8.5
        yawRate = 12
        rollRate = 10
        pushRate = 10
    end

    pitch *= math.exp(-dt * pitchRate)
    yaw *= math.exp(-dt * yawRate)
    roll *= math.exp(-dt * rollRate)
    push *= math.exp(-dt * pushRate)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" then
        currentArchetype = payload and payload.Archetype or "Carbine"
        burstCount = 0
    elseif kind == "WeaponFX" and payload then
        if payload.Kind == "Shot" then
            currentArchetype = payload.Archetype or currentArchetype
            addShotImpulse(currentArchetype)
        elseif payload.Kind == "Reload" then
            burstCount = 0
        end
    end
end)

RunService:BindToRenderStep("BreachWeaponCadenceIdentity", Enum.RenderPriority.Camera.Value + 3, function(dt)
    recover(dt)

    if pitch < 0.0001 and math.abs(yaw) < 0.0001 and math.abs(roll) < 0.0001 and push < 0.0001 then
        return
    end

    local camera = workspace.CurrentCamera
    if camera then
        local offset = CFrame.new(0, 0, push) * CFrame.Angles(math.rad(-pitch), math.rad(yaw), math.rad(roll))
        camera.CFrame = camera.CFrame * offset
    end
end)
