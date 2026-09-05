local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local ROOT_NAME = "VaultfallAudio"
local oldRoot = SoundService:FindFirstChild(ROOT_NAME)
if oldRoot then
    oldRoot:Destroy()
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = SoundService

local ambienceRoot = Instance.new("Folder")
ambienceRoot.Name = "Ambience"
ambienceRoot.Parent = root

local transientRoot = Instance.new("Folder")
transientRoot.Name = "Transients"
transientRoot.Parent = root

-- Roblox-bundled resources keep the first-play build audible without external
-- Creator Store permissions. Layering, pitch, timing and run-state mixing are
-- owned here by one script so client startup order cannot delete another mix.
local SOUND = {
    Ping = "rbxasset://sounds/electronicpingshort.wav",
    Bass = "rbxasset://sounds/bass.wav",
    Mechanical = "rbxasset://sounds/action_get_up.mp3",
    Impact = "rbxasset://sounds/action_jump_land.mp3",
    Step = "rbxasset://sounds/action_footsteps_plastic.mp3",
    Wind = "rbxasset://sounds/action_falling.ogg",
    Water = "rbxasset://sounds/impact_water.mp3",
}

local activeRun = false
local currentRoom = 0
local currentArchetype = "Carbine"
local lastShotAt = 0
local lastImpactAt = 0
local shotCounter = 0
local ambienceToken = 0

local function makeSound(parent, name, id, volume, playbackSpeed, looped)
    local sound = Instance.new("Sound")
    sound.Name = name
    sound.SoundId = id
    sound.Volume = volume or 0.2
    sound.PlaybackSpeed = playbackSpeed or 1
    sound.Looped = looped == true
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.Parent = parent
    return sound
end

local sectorAir = makeSound(ambienceRoot, "SectorAir", SOUND.Wind, 0.018, 0.31, true)
local safehouseHum = makeSound(ambienceRoot, "SafehouseMachinery", SOUND.Step, 0.018, 0.17, true)
sectorAir:Play()
safehouseHum:Play()

local function oneShot(name, id, volume, playbackSpeed, lifetime)
    local sound = makeSound(transientRoot, name, id, volume, playbackSpeed, false)
    sound:Play()
    Debris:AddItem(sound, lifetime or 3)
    return sound
end

local function setRunMix(isActive, room)
    activeRun = isActive == true
    currentRoom = room or currentRoom

    if activeRun then
        local depth = math.clamp(currentRoom / 12, 0, 1)
        sectorAir.Volume = 0.038 + depth * 0.018
        sectorAir.PlaybackSpeed = 0.34 + depth * 0.08
        safehouseHum.Volume = 0
    else
        sectorAir.Volume = 0.012
        sectorAir.PlaybackSpeed = 0.28
        safehouseHum.Volume = 0.018
        safehouseHum.PlaybackSpeed = 0.17
    end
end

local function layeredShot(archetype)
    local now = os.clock()
    if now - lastShotAt < 0.035 then
        return
    end
    lastShotAt = now
    shotCounter += 1

    if archetype == "Shotgun" then
        oneShot("ShotgunBody", SOUND.Impact, 0.62, 0.54, 2)
        oneShot("ShotgunLow", SOUND.Bass, 0.54, 1.48, 2)
        oneShot("ShotgunCrack", SOUND.Step, 0.32, 0.78, 2)
        task.delay(0.055, function()
            oneShot("ShotgunAction", SOUND.Mechanical, 0.22, 0.73, 2)
        end)
    elseif archetype == "RailRifle" then
        oneShot("RailChargeRelease", SOUND.Ping, 0.48, 0.43, 3)
        oneShot("RailBody", SOUND.Bass, 0.54, 2.1, 2)
        oneShot("RailAir", SOUND.Wind, 0.14, 2.12, 2)
        task.delay(0.07, function()
            oneShot("RailSnap", SOUND.Ping, 0.28, 1.72, 2)
        end)
    elseif archetype == "SMG" then
        local variation = (shotCounter % 3) * 0.025
        oneShot("SmgBody", SOUND.Step, 0.26, 1.55 + variation, 2)
        oneShot("SmgSnap", SOUND.Ping, 0.13, 2.38 + variation, 2)
    else
        local variation = (shotCounter % 2) * 0.025
        oneShot("CarbineBody", SOUND.Impact, 0.35, 0.92 + variation, 2)
        oneShot("CarbineCrack", SOUND.Ping, 0.16, 1.95, 2)
        oneShot("CarbineLow", SOUND.Bass, 0.16, 2.28, 2)
    end
end

local function reloadCue(archetype, duration)
    local total = math.max(duration or 1.8, 0.7)
    local durationScale = math.clamp(total / 1.8, 0.75, 1.55)

    oneShot("ReloadRelease", SOUND.Mechanical, 0.26, 0.88 / durationScale, 2)
    task.delay(total * 0.30, function()
        oneShot("ReloadMagazine", SOUND.Impact, 0.18, archetype == "Shotgun" and 1.30 or 1.68, 2)
    end)
    task.delay(total * 0.74, function()
        oneShot("ReloadBolt", SOUND.Ping, 0.18, archetype == "RailRifle" and 1.22 or 1.45, 2)
        oneShot("ReloadLock", SOUND.Mechanical, 0.16, 1.28, 2)
    end)
end

local function dashCue()
    oneShot("DashAir", SOUND.Wind, 0.19, 1.78, 2)
    oneShot("DashImpulse", SOUND.Bass, 0.18, 2.46, 2)
end

local function hitCue(payload)
    local now = os.clock()
    if now - lastImpactAt < 0.028 then
        return
    end
    lastImpactAt = now

    local killed = payload and payload.Kill == true
    local crit = payload and payload.Crit == true
    if killed then
        oneShot("KillConfirm", SOUND.Ping, 0.31, crit and 1.62 or 1.18, 2)
        oneShot("KillBody", SOUND.Impact, 0.14, 1.85, 2)
        task.delay(0.05, function()
            oneShot("KillConfirmTail", SOUND.Ping, 0.18, 1.48, 2)
        end)
    elseif crit then
        oneShot("CriticalConfirm", SOUND.Ping, 0.24, 1.68, 2)
        oneShot("CriticalBody", SOUND.Bass, 0.10, 2.55, 2)
    else
        oneShot("HitConfirm", SOUND.Impact, 0.11, 1.95, 2)
    end
end

local function rewardCue()
    oneShot("RewardRiseA", SOUND.Ping, 0.22, 1.0, 3)
    task.delay(0.08, function()
        oneShot("RewardRiseB", SOUND.Ping, 0.20, 1.25, 3)
    end)
    task.delay(0.16, function()
        oneShot("RewardRiseC", SOUND.Ping, 0.18, 1.52, 3)
    end)
end

local function warningCue(heavy)
    oneShot("ThreatPulse", SOUND.Bass, heavy and 0.42 or 0.25, heavy and 0.72 or 1.0, 3)
    oneShot("ThreatTick", SOUND.Ping, heavy and 0.24 or 0.14, heavy and 0.62 or 0.82, 3)
end

local function classifyNotice(text)
    local lower = string.lower(tostring(text or ""))
    if string.find(lower, "warden", 1, true)
        or string.find(lower, "boss", 1, true)
        or string.find(lower, "phase", 1, true)
        or string.find(lower, "overload", 1, true) then
        warningCue(true)
    elseif string.find(lower, "extraction", 1, true)
        or string.find(lower, "extract", 1, true)
        or string.find(lower, "hvt", 1, true)
        or string.find(lower, "reinforcement", 1, true) then
        warningCue(false)
    elseif string.find(lower, "recovered", 1, true)
        or string.find(lower, "reward", 1, true)
        or string.find(lower, "mastery", 1, true)
        or string.find(lower, "cleared", 1, true)
        or string.find(lower, "complete", 1, true) then
        rewardCue()
    end
end

local function startAmbientDetails()
    ambienceToken += 1
    local token = ambienceToken
    task.spawn(function()
        while token == ambienceToken do
            task.wait(activeRun and (6 + math.random() * 5) or (10 + math.random() * 8))
            if token ~= ambienceToken then
                break
            end

            if activeRun then
                local depth = math.clamp(currentRoom / 12, 0, 1)
                oneShot("SectorMachinery", SOUND.Bass, 0.035 + depth * 0.018, 0.55 + depth * 0.11, 3)
                if math.random() < 0.45 then
                    task.delay(0.12 + math.random() * 0.30, function()
                        if token == ambienceToken and activeRun then
                            oneShot("SectorTick", SOUND.Ping, 0.025, 0.48 + math.random() * 0.20, 2)
                        end
                    end)
                end
            else
                oneShot("SafehouseRelay", SOUND.Ping, 0.025, 0.55 + math.random() * 0.18, 2)
                if math.random() < 0.35 then
                    oneShot("SafehouseVent", SOUND.Wind, 0.020, 0.42, 3)
                end
            end
        end
    end)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and type(payload) == "table" then
        currentArchetype = tostring(payload.Archetype or currentArchetype)
        oneShot("WeaponReady", SOUND.Mechanical, 0.13, currentArchetype == "RailRifle" and 0.82 or 1.08, 2)
    elseif kind == "Combat" and type(payload) == "table" then
        currentArchetype = tostring(payload.Archetype or currentArchetype)
    elseif kind == "WeaponFX" and type(payload) == "table" then
        local archetype = tostring(payload.Archetype or currentArchetype)
        currentArchetype = archetype
        if payload.Kind == "Shot" then
            layeredShot(archetype)
        elseif payload.Kind == "Reload" then
            reloadCue(archetype, payload.Duration)
        elseif payload.Kind == "Dash" then
            dashCue()
        end
    elseif kind == "Hit" and type(payload) == "table" then
        hitCue(payload)
    elseif kind == "Notice" then
        classifyNotice(payload)
    elseif kind == "LootOffer" then
        rewardCue()
    elseif kind == "Run" and type(payload) == "table" then
        local wasActive = activeRun
        local previousRoom = currentRoom
        setRunMix(payload.Active == true, payload.Room or 0)

        if activeRun and not wasActive then
            oneShot("DeploymentLock", SOUND.Mechanical, 0.28, 0.90, 2)
            oneShot("DeploymentTone", SOUND.Ping, 0.22, 0.74, 2)
        elseif not activeRun and wasActive then
            rewardCue()
        elseif activeRun and currentRoom > 0 and currentRoom ~= previousRoom then
            oneShot("SectorTransition", SOUND.Ping, 0.10, 0.88 + math.min(currentRoom, 12) * 0.025, 2)
        end
    end
end)

player.CharacterAdded:Connect(function()
    if not sectorAir.IsPlaying then
        sectorAir:Play()
    end
    if not safehouseHum.IsPlaying then
        safehouseHum:Play()
    end
    oneShot("OperatorSpawn", SOUND.Mechanical, 0.09, 1.35, 2)
end)

setRunMix(false, 0)
startAmbientDetails()
