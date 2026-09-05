local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

-- Roblox-bundled client sounds keep the first test build self-contained and
-- avoid depending on private Creator Store audio permissions.  The mix below
-- layers and pitch-shapes them into compact mechanical/gameplay cues.
local SOUND = {
    Ping = "rbxasset://sounds/electronicpingshort.wav",
    Mechanical = "rbxasset://sounds/action_get_up.mp3",
    Impact = "rbxasset://sounds/action_jump_land.mp3",
    Splash = "rbxasset://sounds/impact_water.mp3",
    Wind = "rbxasset://sounds/action_falling.ogg",
    Footstep = "rbxasset://sounds/action_footsteps_plastic.mp3",
}

local root = SoundService:FindFirstChild("VaultfallAudio")
if root then
    root:Destroy()
end
root = Instance.new("Folder")
root.Name = "VaultfallAudio"
root.Parent = SoundService

local currentArchetype = "Carbine"
local runActive = false
local shotCounter = 0
local lastHitAt = 0

local function sound(name, soundId, volume, speed, looped)
    local item = Instance.new("Sound")
    item.Name = name
    item.SoundId = soundId
    item.Volume = volume or 0.4
    item.PlaybackSpeed = speed or 1
    item.Looped = looped == true
    item.RollOffMode = Enum.RollOffMode.InverseTapered
    item.Parent = root
    return item
end

local ambience = sound("SectorAir", SOUND.Wind, 0.035, 0.34, true)
ambience:Play()

local safehouseHum = sound("SafehouseMachinery", SOUND.Footstep, 0.018, 0.17, true)
safehouseHum:Play()

local function clonePlay(templateId, volume, speed)
    local item = sound("Transient", templateId, volume, speed, false)
    item.Ended:Connect(function()
        if item.Parent then
            item:Destroy()
        end
    end)
    item:Play()
    task.delay(4, function()
        if item.Parent then
            item:Destroy()
        end
    end)
end

local function playShot(archetype)
    shotCounter += 1
    if archetype == "SMG" then
        clonePlay(SOUND.Ping, 0.28, 0.72 + ((shotCounter % 3) * 0.025))
        clonePlay(SOUND.Impact, 0.17, 1.68)
    elseif archetype == "Shotgun" then
        clonePlay(SOUND.Impact, 0.62, 0.54)
        clonePlay(SOUND.Splash, 0.18, 1.55)
        task.delay(0.055, function()
            clonePlay(SOUND.Mechanical, 0.24, 0.72)
        end)
    elseif archetype == "RailRifle" then
        clonePlay(SOUND.Ping, 0.48, 0.42)
        clonePlay(SOUND.Wind, 0.16, 2.15)
        task.delay(0.075, function()
            clonePlay(SOUND.Ping, 0.25, 1.42)
        end)
    else
        clonePlay(SOUND.Impact, 0.38, 0.91 + ((shotCounter % 2) * 0.025))
        clonePlay(SOUND.Ping, 0.14, 0.57)
    end
end

local function playReload(archetype, duration)
    local multiplier = math.clamp((duration or 1.8) / 1.8, 0.75, 1.5)
    clonePlay(SOUND.Mechanical, 0.34, 0.86 / multiplier)
    task.delay(math.min(0.48, (duration or 1.8) * 0.28), function()
        clonePlay(SOUND.Impact, 0.2, archetype == "Shotgun" and 1.35 or 1.7)
    end)
    task.delay(math.max(0.6, (duration or 1.8) * 0.78), function()
        clonePlay(SOUND.Mechanical, 0.3, archetype == "RailRifle" and 1.28 or 1.08)
    end)
end

local function playHit(payload)
    local now = os.clock()
    if now - lastHitAt < 0.025 then
        return
    end
    lastHitAt = now

    if payload.Kill then
        clonePlay(SOUND.Ping, 0.34, payload.Crit and 1.68 or 1.42)
        clonePlay(SOUND.Impact, 0.16, 1.9)
    elseif payload.Crit then
        clonePlay(SOUND.Ping, 0.27, 1.56)
    else
        clonePlay(SOUND.Impact, 0.11, 1.95)
    end
end

local function playDash()
    clonePlay(SOUND.Wind, 0.22, 1.72)
end

local function playRewardNotice(text)
    local upper = string.upper(tostring(text or ""))
    if string.find(upper, "EXTRACT", 1, true)
        or string.find(upper, "RECOVERY", 1, true)
        or string.find(upper, "COMPLETE", 1, true)
        or string.find(upper, "CLEARED", 1, true)
        or string.find(upper, "MASTERY", 1, true) then
        clonePlay(SOUND.Ping, 0.22, 1.18)
        task.delay(0.11, function()
            clonePlay(SOUND.Ping, 0.18, 1.48)
        end)
    end
end

local function setRunMix(active)
    runActive = active == true
    if runActive then
        ambience.Volume = 0.052
        ambience.PlaybackSpeed = 0.39
        safehouseHum.Volume = 0
    else
        ambience.Volume = 0.018
        ambience.PlaybackSpeed = 0.3
        safehouseHum.Volume = 0.018
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" then
        currentArchetype = (payload and payload.Archetype) or currentArchetype
        clonePlay(SOUND.Mechanical, 0.18, currentArchetype == "RailRifle" and 0.82 or 1.08)
    elseif kind == "WeaponFX" and payload then
        if payload.Kind == "Shot" then
            playShot(currentArchetype)
        elseif payload.Kind == "Reload" then
            playReload(currentArchetype, payload.Duration)
        elseif payload.Kind == "Dash" then
            playDash()
        end
    elseif kind == "Hit" and payload then
        playHit(payload)
    elseif kind == "Run" and payload then
        setRunMix(payload.Active)
        if payload.Active and not runActive then
            clonePlay(SOUND.Ping, 0.2, 0.78)
        end
    elseif kind == "Notice" then
        playRewardNotice(payload)
    end
end)

player.CharacterAdded:Connect(function()
    if not ambience.IsPlaying then
        ambience:Play()
    end
    if not safehouseHum.IsPlaying then
        safehouseHum:Play()
    end
end)

setRunMix(false)
