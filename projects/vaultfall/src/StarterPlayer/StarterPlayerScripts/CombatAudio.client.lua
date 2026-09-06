local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

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

local weaponGroup = Instance.new("SoundGroup")
weaponGroup.Name = "VaultfallWeapons"
weaponGroup.Volume = 0.92
weaponGroup.Parent = SoundService

local uiGroup = Instance.new("SoundGroup")
uiGroup.Name = "VaultfallFeedback"
uiGroup.Volume = 0.84
uiGroup.Parent = SoundService

local ambienceGroup = Instance.new("SoundGroup")
ambienceGroup.Name = "VaultfallAmbience"
ambienceGroup.Volume = 0.72
ambienceGroup.Parent = SoundService

-- Roblox-bundled resources keep the first-play build audible without external
-- Creator Store permissions. This script owns all game audio so startup order
-- cannot delete or duplicate another presentation mix.
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
local lastArchetypeShotAt = 0
local lastShotArchetype = ""
local burstShotCount = 0
local shotCounter = 0
local ambienceToken = 0
local transientDuckToken = 0

local function makeSound(parent, name, id, volume, playbackSpeed, looped, group)
    local sound = Instance.new("Sound")
    sound.Name = name
    sound.SoundId = id
    sound.Volume = volume or 0.2
    sound.PlaybackSpeed = playbackSpeed or 1
    sound.Looped = looped == true
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.SoundGroup = group
    sound.Parent = parent
    return sound
end

local sectorAir = makeSound(ambienceRoot, "SectorAir", SOUND.Wind, 0.018, 0.31, true, ambienceGroup)
local safehouseHum = makeSound(ambienceRoot, "SafehouseMachinery", SOUND.Step, 0.018, 0.17, true, ambienceGroup)
sectorAir:Play()
safehouseHum:Play()

local function duckAmbience(amount, duration)
    transientDuckToken += 1
    local token = transientDuckToken
    local target = math.clamp(0.72 - amount, 0.28, 0.72)
    TweenService:Create(ambienceGroup, TweenInfo.new(0.035), { Volume = target }):Play()
    task.delay(duration or 0.12, function()
        if token == transientDuckToken and ambienceGroup.Parent then
            TweenService:Create(ambienceGroup, TweenInfo.new(0.16), { Volume = 0.72 }):Play()
        end
    end)
end

local function oneShot(name, id, volume, playbackSpeed, lifetime, group)
    local sound = makeSound(transientRoot, name, id, volume, playbackSpeed, false, group or weaponGroup)
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

local function nextBurstShot(archetype, now)
    local resetWindow = archetype == "SMG" and 0.20 or 0.28
    if archetype ~= lastShotArchetype or now - lastArchetypeShotAt > resetWindow then
        burstShotCount = 1
    else
        burstShotCount += 1
    end
    lastShotArchetype = archetype
    lastArchetypeShotAt = now
    return burstShotCount
end

local function layeredShot(archetype)
    local now = os.clock()
    if now - lastShotAt < 0.035 then
        return
    end
    lastShotAt = now
    shotCounter += 1
    local burstIndex = nextBurstShot(archetype, now)

    if archetype == "Shotgun" then
        duckAmbience(0.34, 0.22)
        oneShot("ShotgunBody", SOUND.Impact, 0.66, 0.50, 2)
        oneShot("ShotgunLow", SOUND.Bass, 0.58, 1.43, 2)
        oneShot("ShotgunCrack", SOUND.Step, 0.27, 0.82, 2)
        task.delay(0.050, function()
            oneShot("ShotgunRoomTail", SOUND.Wind, 0.075, 2.36, 2)
        end)
        task.delay(0.115, function()
            oneShot("ShotgunAction", SOUND.Mechanical, 0.22, 0.73, 2)
        end)
    elseif archetype == "RailRifle" then
        duckAmbience(0.30, 0.28)
        oneShot("RailChargeRelease", SOUND.Ping, 0.47, 0.40, 3)
        oneShot("RailBody", SOUND.Bass, 0.57, 2.02, 2)
        oneShot("RailAir", SOUND.Wind, 0.16, 2.20, 2)
        task.delay(0.055, function()
            oneShot("RailSnap", SOUND.Ping, 0.30, 1.78, 2)
        end)
        task.delay(0.14, function()
            oneShot("RailTail", SOUND.Ping, 0.085, 0.66, 2)
        end)
    elseif archetype == "SMG" then
        duckAmbience(burstIndex == 1 and 0.13 or 0.08, 0.07)
        local variation = (shotCounter % 4) * 0.018
        oneShot("SmgBody", SOUND.Step, burstIndex == 1 and 0.27 or 0.22, 1.54 + variation, 1.2)

        -- Preserve a crisp first-round signature while reducing stacked transient
        -- voices during sustained automatic fire. The high snap returns every
        -- third round so the burst stays legible without becoming a wall of pings.
        if burstIndex == 1 or burstIndex % 3 == 0 then
            oneShot("SmgSnap", SOUND.Ping, burstIndex == 1 and 0.14 or 0.09, 2.34 + variation, 1.2)
        end
        if burstIndex == 1 or burstIndex % 5 == 0 then
            oneShot("SmgLow", SOUND.Bass, burstIndex == 1 and 0.070 or 0.045, 2.72, 1.4)
        end
    else
        duckAmbience(burstIndex == 1 and 0.19 or 0.13, 0.10)
        local variation = (shotCounter % 3) * 0.018
        oneShot("CarbineBody", SOUND.Impact, burstIndex == 1 and 0.38 or 0.33, 0.90 + variation, 1.5)
        oneShot("CarbineCrack", SOUND.Ping, burstIndex == 1 and 0.18 or 0.14, 1.92 + variation, 1.4)

        -- The carbine keeps a weightier first shot, then a lighter sustained body
        -- so controlled bursts sound intentional instead of progressively louder.
        if burstIndex == 1 or burstIndex % 3 == 0 then
            oneShot("CarbineLow", SOUND.Bass, burstIndex == 1 and 0.19 or 0.12, 2.24, 1.5)
        end
        if burstIndex == 1 or burstIndex % 4 == 0 then
            task.delay(0.035, function()
                oneShot("CarbineTail", SOUND.Wind, burstIndex == 1 and 0.050 or 0.032, 2.52, 1.3)
            end)
        end
    end
end

local function reloadCue(archetype, duration)
    local total = math.max(duration or 1.8, 0.7)
    local durationScale = math.clamp(total / 1.8, 0.75, 1.55)

    if archetype == "Shotgun" then
        oneShot("ShotgunReloadOpen", SOUND.Mechanical, 0.23, 0.82, 2)
        for shell = 1, 3 do
            task.delay(total * (0.18 + shell * 0.16), function()
                oneShot("ShotgunShell", SOUND.Impact, 0.16, 1.45 + shell * 0.05, 2)
                oneShot("ShotgunShellTick", SOUND.Ping, 0.07, 1.75 + shell * 0.06, 2)
            end)
        end
        task.delay(total * 0.84, function()
            oneShot("ShotgunReloadClose", SOUND.Mechanical, 0.27, 0.96, 2)
        end)
        return
    end

    oneShot("ReloadRelease", SOUND.Mechanical, 0.26, 0.88 / durationScale, 2)
    task.delay(total * 0.30, function()
        oneShot("ReloadMagazine", SOUND.Impact, 0.18, archetype == "RailRifle" and 1.32 or 1.68, 2)
    end)
    task.delay(total * 0.54, function()
        oneShot("ReloadSeat", SOUND.Mechanical, 0.11, archetype == "RailRifle" and 0.78 or 1.22, 2)
    end)
    task.delay(total * 0.76, function()
        oneShot("ReloadBolt", SOUND.Ping, 0.18, archetype == "RailRifle" and 1.22 or 1.45, 2)
        oneShot("ReloadLock", SOUND.Mechanical, 0.16, 1.28, 2)
    end)
end

local function dashCue()
    duckAmbience(0.12, 0.18)
    oneShot("DashAir", SOUND.Wind, 0.19, 1.78, 2)
    oneShot("DashImpulse", SOUND.Bass, 0.18, 2.46, 2)
    task.delay(0.09, function()
        oneShot("DashTail", SOUND.Wind, 0.08, 2.82, 2)
    end)
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
        oneShot("KillConfirm", SOUND.Ping, 0.31, crit and 1.62 or 1.18, 2, uiGroup)
        oneShot("KillBody", SOUND.Impact, 0.14, 1.85, 2, uiGroup)
        task.delay(0.05, function()
            oneShot("KillConfirmTail", SOUND.Ping, 0.18, 1.48, 2, uiGroup)
        end)
    elseif crit then
        oneShot("CriticalConfirm", SOUND.Ping, 0.24, 1.68, 2, uiGroup)
        oneShot("CriticalBody", SOUND.Bass, 0.10, 2.55, 2, uiGroup)
    else
        oneShot("HitConfirm", SOUND.Impact, 0.11, 1.95, 2, uiGroup)
    end
end

local function rewardCue()
    oneShot("RewardRiseA", SOUND.Ping, 0.22, 1.0, 3, uiGroup)
    task.delay(0.08, function()
        oneShot("RewardRiseB", SOUND.Ping, 0.20, 1.25, 3, uiGroup)
    end)
    task.delay(0.16, function()
        oneShot("RewardRiseC", SOUND.Ping, 0.18, 1.52, 3, uiGroup)
    end)
end

local function warningCue(heavy)
    duckAmbience(heavy and 0.23 or 0.11, heavy and 0.30 or 0.16)
    oneShot("ThreatPulse", SOUND.Bass, heavy and 0.42 or 0.25, heavy and 0.72 or 1.0, 3, uiGroup)
    oneShot("ThreatTick", SOUND.Ping, heavy and 0.24 or 0.14, heavy and 0.62 or 0.82, 3, uiGroup)
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
                oneShot("SectorMachinery", SOUND.Bass, 0.035 + depth * 0.018, 0.55 + depth * 0.11, 3, ambienceGroup)
                if math.random() < 0.45 then
                    task.delay(0.12 + math.random() * 0.30, function()
                        if token == ambienceToken and activeRun then
                            oneShot("SectorTick", SOUND.Ping, 0.025, 0.48 + math.random() * 0.20, 2, ambienceGroup)
                        end
                    end)
                end
            else
                oneShot("SafehouseRelay", SOUND.Ping, 0.025, 0.55 + math.random() * 0.18, 2, ambienceGroup)
                if math.random() < 0.35 then
                    oneShot("SafehouseVent", SOUND.Wind, 0.020, 0.42, 3, ambienceGroup)
                end
            end
        end
    end)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and type(payload) == "table" then
        currentArchetype = tostring(payload.Archetype or currentArchetype)
        oneShot("WeaponReady", SOUND.Mechanical, 0.13, currentArchetype == "RailRifle" and 0.82 or 1.08, 2, uiGroup)
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
            duckAmbience(0.18, 0.35)
            oneShot("DeploymentLock", SOUND.Mechanical, 0.28, 0.90, 2, uiGroup)
            oneShot("DeploymentTone", SOUND.Ping, 0.22, 0.74, 2, uiGroup)
        elseif not activeRun and wasActive then
            rewardCue()
        elseif activeRun and currentRoom > 0 and currentRoom ~= previousRoom then
            oneShot("SectorTransition", SOUND.Ping, 0.10, 0.88 + math.min(currentRoom, 12) * 0.025, 2, uiGroup)
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
    oneShot("OperatorSpawn", SOUND.Mechanical, 0.09, 1.35, 2, uiGroup)
end)

setRunMix(false, 0)
startAmbientDetails()
