local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local pitchImpulse = 0
local yawImpulse = 0
local rollImpulse = 0
local pushImpulse = 0
local shotSequence = 0
local lastShotAt = -100
local smgBurstCount = 0

-- This layer intentionally stays small. WeaponFeelClient owns the main recoil,
-- while this script gives each archetype a different cadence signature without
-- changing server-authoritative fire rate, spread, ammo, or damage.
local PROFILES = {
    Carbine = {
        Pitch = 0.115,
        Yaw = 0.030,
        Roll = 0.018,
        Push = 0.020,
        PitchRecovery = 20,
        YawRecovery = 22,
        RollRecovery = 24,
        PushRecovery = 28,
    },
    SMG = {
        Pitch = 0.050,
        Yaw = 0.046,
        Roll = 0.026,
        Push = 0.012,
        PitchRecovery = 25,
        YawRecovery = 19,
        RollRecovery = 22,
        PushRecovery = 32,
    },
    Shotgun = {
        Pitch = 0.310,
        Yaw = 0.055,
        Roll = 0.090,
        Push = 0.075,
        PitchRecovery = 11,
        YawRecovery = 15,
        RollRecovery = 12,
        PushRecovery = 13,
    },
    RailRifle = {
        Pitch = 0.245,
        Yaw = 0.018,
        Roll = 0.040,
        Push = 0.060,
        PitchRecovery = 8.5,
        YawRecovery = 12,
        RollRecovery = 10,
        PushRecovery = 10,
    },
}

local function profile()
    return PROFILES[currentArchetype] or PROFILES.Carbine
end

local function registerShot(payload)
    if payload and payload.Archetype then
        currentArchetype = payload.Archetype
    end

    local now = os.clock()
    local gap = now - lastShotAt
    lastShotAt = now
    shotSequence += 1

    if currentArchetype == "SMG" then
        if gap <= 0.13 then
            smgBurstCount = math.min(smgBurstCount + 1, 9)
        else
            smgBurstCount = 1
        end
    else
        smgBurstCount = 0
    end

    local p = profile()
    local side = (shotSequence % 2 == 0) and 1 or -1

    if currentArchetype == "Carbine" then
        -- Stable service-rifle rhythm: mostly vertical, tiny alternating side step.
        pitchImpulse += p.Pitch
        yawImpulse += p.Yaw * side
        rollImpulse += p.Roll * -side
        pushImpulse += p.Push
    elseif currentArchetype == "SMG" then
        -- Fast fire should feel lively rather than heavy. Sustained bursts climb a
        -- little while lateral chatter grows, encouraging short controlled bursts.
        local burst = math.clamp((smgBurstCount - 1) / 8, 0, 1)
        pitchImpulse += p.Pitch * (1 + burst * 0.48)
        yawImpulse += p.Yaw * side * (1 + burst * 0.35)
        rollImpulse += p.Roll * -side
        pushImpulse += p.Push
    elseif currentArchetype == "Shotgun" then
        -- One blunt rearward thump with a brief uneven shoulder roll.
        pitchImpulse += p.Pitch
        yawImpulse += p.Yaw * side
        rollImpulse += p.Roll * side
        pushImpulse += p.Push
    elseif currentArchetype == "RailRifle" then
        -- Rail recoil is deliberate rather than snappy: strong straight impulse,
        -- very little horizontal noise, and slower recovery than the shotgun.
        pitchImpulse += p.Pitch
        yawImpulse += p.Yaw * side
        rollImpulse += p.Roll * -side
        pushImpulse += p.Push
    end

    pitchImpulse = math.clamp(pitchImpulse, 0, 0.65)
    yawImpulse = math.clamp(yawImpulse, -0.22, 0.22)
    rollImpulse = math.clamp(rollImpulse, -0.20, 0.20)
    pushImpulse = math.clamp(pushImpulse, 0, 0.12)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" then
        currentArchetype = (payload and payload.Archetype) or "Carbine"
        smgBurstCount = 0
    elseif kind == "WeaponFX" and payload then
        if payload.Kind == "Shot" then
            registerShot(payload)
        elseif payload.Kind == "Reload" then
            -- Reset automatic-fire cadence so the first post-reload burst does not
            -- inherit artificial climb from the previous magazine.
            smgBurstCount = 0
        end
    end
end)

RunService:BindToRenderStep("BreachWeaponCadenceIdentity", Enum.RenderPriority.Camera.Value + 3, function(dt)
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local p = profile()
    pitchImpulse *= math.exp(-dt * p.PitchRecovery)
    yawImpulse *= math.exp(-dt * p.YawRecovery)
    rollImpulse *= math.exp(-dt * p.RollRecovery)
    pushImpulse *= math.exp(-dt * p.PushRecovery)

    if pitchImpulse < 0.0001 and math.abs(yawImpulse) < 0.0001 and math.abs(rollImpulse) < 0.0001 and pushImpulse < 0.0001 then
        return
    end

    -- Apply after the core camera/viewmodel pass. Translation is intentionally
    -- tiny so recoil reads through feel without causing motion sickness or ADS loss.
    camera.CFrame *= CFrame.new(0, 0, pushImpulse)
        * CFrame.Angles(math.rad(-pitchImpulse), math.rad(yawImpulse), math.rad(rollImpulse))
end)

player.CharacterAdded:Connect(function()
    pitchImpulse = 0
    yawImpulse = 0
    rollImpulse = 0
    pushImpulse = 0
    smgBurstCount = 0
end)
