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

-- These are Roblox-bundled legacy audio resources. They do not require a
-- Creator Store install and keep the first test build audible even when no
-- external asset pack is present.
local IDS = {
    Ping = "rbxasset://sounds/electronicpingshort.wav",
    Bass = "rbxasset://sounds/bass.wav",
    Step = "rbxasset://sounds/action_footsteps_plastic.mp3",
    Land = "rbxasset://sounds/action_get_up.mp3",
    Fall = "rbxasset://sounds/action_falling.mp3",
}

local activeRun = false
local currentRoom = 0
local lastShotAt = 0
local lastImpactAt = 0
local ambienceToken = 0

local function sound(name, id, volume, playbackSpeed)
    local s = Instance.new("Sound")
    s.Name = name
    s.SoundId = id
    s.Volume = volume
    s.PlaybackSpeed = playbackSpeed or 1
    s.RollOffMode = Enum.RollOffMode.InverseTapered
    s.Parent = root
    return s
end

local function oneShot(name, id, volume, playbackSpeed, lifetime)
    local s = sound(name, id, volume, playbackSpeed)
    s:Play()
    Debris:AddItem(s, lifetime or 3)
    return s
end

local function layeredShot(archetype)
    local now = os.clock()
    if now - lastShotAt < 0.035 then
        return
    end
    lastShotAt = now

    if archetype == "Shotgun" then
        oneShot("ShotgunBody", IDS.Bass, 0.62, 1.6, 2)
        oneShot("ShotgunCrack", IDS.Step, 0.42, 0.76, 2)
        oneShot("ShotgunTail", IDS.Land, 0.22, 1.25, 2)
    elseif archetype == "RailRifle" then
        oneShot("RailChargeRelease", IDS.Ping, 0.52, 0.56, 3)
        oneShot("RailBody", IDS.Bass, 0.54, 2.15, 2)
        task.delay(0.045, function()
            oneShot("RailSnap", IDS.Ping, 0.32, 1.8, 2)
        end)
    elseif archetype == "SMG" then
        oneShot("SmgBody", IDS.Step, 0.26, 1.58, 2)
        oneShot("SmgClick", IDS.Ping, 0.13, 2.45, 2)
    else
        oneShot("CarbineBody", IDS.Step, 0.34, 1.22, 2)
        oneShot("CarbineCrack", IDS.Ping, 0.16, 2.0, 2)
        oneShot("CarbineLow", IDS.Bass, 0.17, 2.35, 2)
    end
end

local function reloadCue(duration)
    local total = math.max(duration or 1.8, 0.7)
    oneShot("ReloadRelease", IDS.Step, 0.18, 1.55, 2)
    task.delay(total * 0.34, function()
        oneShot("ReloadMagazine", IDS.Land, 0.21, 1.7, 2)
    end)
    task.delay(total * 0.76, function()
        oneShot("ReloadBolt", IDS.Ping, 0.18, 1.45, 2)
        oneShot("ReloadLock", IDS.Step, 0.15, 1.95, 2)
    end)
end

local function dashCue()
    oneShot("DashAir", IDS.Fall, 0.18, 2.2, 2)
    oneShot("DashImpulse", IDS.Bass, 0.20, 2.5, 2)
end

local function hitCue(payload)
    local now = os.clock()
    if now - lastImpactAt < 0.028 then
        return
    end
    lastImpactAt = now

    local killed = payload and payload.Killed == true
    local crit = payload and payload.Crit == true
    if killed then
        oneShot("KillConfirm", IDS.Ping, 0.30, 1.08, 2)
        task.delay(0.045, function()
            oneShot("KillConfirmTail", IDS.Ping, 0.20, 1.46, 2)
        end)
    elseif crit then
        oneShot("CriticalConfirm", IDS.Ping, 0.23, 1.68, 2)
        oneShot("CriticalBody", IDS.Bass, 0.11, 2.6, 2)
    else
        oneShot("HitConfirm", IDS.Ping, 0.12, 2.05, 2)
    end
end

local function rewardCue()
    oneShot("RewardRiseA", IDS.Ping, 0.22, 1.0, 3)
    task.delay(0.08, function()
        oneShot("RewardRiseB", IDS.Ping, 0.20, 1.25, 3)
    end)
    task.delay(0.16, function()
        oneShot("RewardRiseC", IDS.Ping, 0.18, 1.52, 3)
    end)
end

local function warningCue(heavy)
    oneShot("ThreatPulse", IDS.Bass, heavy and 0.42 or 0.25, heavy and 0.72 or 1.0, 3)
    oneShot("ThreatTick", IDS.Ping, heavy and 0.24 or 0.14, heavy and 0.62 or 0.82, 3)
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
        or string.find(lower, "cleared", 1, true) then
        rewardCue()
    end
end

local function startAmbienceLoop()
    ambienceToken += 1
    local token = ambienceToken
    task.spawn(function()
        while token == ambienceToken do
            local waitTime = activeRun and (6 + math.random() * 5) or (10 + math.random() * 8)
            task.wait(waitTime)
            if token ~= ambienceToken then
                break
            end

            if activeRun then
                local depth = math.clamp(currentRoom / 12, 0, 1)
                oneShot("SectorBed", IDS.Bass, 0.055 + depth * 0.035, 0.52 + depth * 0.10, 4)
                if math.random() < 0.55 then
                    task.delay(0.12 + math.random() * 0.35, function()
                        if token == ambienceToken and activeRun then
                            oneShot("SectorMachine", IDS.Ping, 0.035, 0.46 + math.random() * 0.18, 3)
                        end
                    end)
                end
            else
                oneShot("SafehouseMachine", IDS.Ping, 0.035, 0.54 + math.random() * 0.20, 3)
                if math.random() < 0.45 then
                    oneShot("SafehouseVent", IDS.Fall, 0.025, 0.44, 3)
                end
            end
        end
    end)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "WeaponFX" and type(payload) == "table" then
        if payload.Kind == "Shot" then
            layeredShot(tostring(payload.Archetype or "Carbine"))
        elseif payload.Kind == "Reload" then
            reloadCue(payload.Duration)
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
        activeRun = payload.Active == true
        currentRoom = payload.Room or 0
        if activeRun and not wasActive then
            oneShot("DeploymentLock", IDS.Land, 0.28, 0.9, 2)
            oneShot("DeploymentTone", IDS.Ping, 0.22, 0.74, 2)
        elseif not activeRun and wasActive then
            rewardCue()
        elseif activeRun and payload.Room and payload.Room ~= 0 then
            oneShot("SectorTransition", IDS.Ping, 0.10, 0.88 + math.min(payload.Room, 12) * 0.025, 2)
        end
    end
end)

player.CharacterAdded:Connect(function()
    oneShot("OperatorSpawn", IDS.Land, 0.09, 1.35, 2)
end)

startAmbienceLoop()
