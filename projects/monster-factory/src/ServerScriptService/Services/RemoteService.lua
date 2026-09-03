local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteService = {}
local folder

local REMOTES = {
    StateUpdated = "RemoteEvent",
    MonsterStateUpdated = "RemoteEvent",
    ZoneStateUpdated = "RemoteEvent",
    QuestStateUpdated = "RemoteEvent",
    RewardStateUpdated = "RemoteEvent",
    AchievementStateUpdated = "RemoteEvent",
    OnboardingStateUpdated = "RemoteEvent",
    WorkerVisualStateUpdated = "RemoteEvent",
    ContextOffer = "RemoteEvent",
    Toast = "RemoteEvent",

    RequestUpgrade = "RemoteEvent",
    RequestCollect = "RemoteEvent",
    RequestHatch = "RemoteEvent",
    RequestToggleEquip = "RemoteEvent",
    RequestEquipBest = "RemoteEvent",
    RequestFuse = "RemoteEvent",

    RequestZoneUnlock = "RemoteEvent",
    RequestZoneTravel = "RemoteEvent",
    RequestRebirth = "RemoteEvent",

    RequestQuestClaim = "RemoteEvent",
    RequestDailyClaim = "RemoteEvent",
    RequestPlaytimeClaim = "RemoteEvent",
    RequestAchievementClaim = "RemoteEvent",

    RequestFullState = "RemoteFunction",
    RequestMonsterState = "RemoteFunction",
    RequestZoneState = "RemoteFunction",
    RequestQuestState = "RemoteFunction",
    RequestRewardState = "RemoteFunction",
    RequestAchievementState = "RemoteFunction",
    RequestOnboardingState = "RemoteFunction",
    RequestWorkerVisualState = "RemoteFunction",
}

function RemoteService.Init()
    folder = ReplicatedStorage:FindFirstChild("Remotes")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Remotes"
        folder.Parent = ReplicatedStorage
    end

    for name, className in pairs(REMOTES) do
        if not folder:FindFirstChild(name) then
            local remote = Instance.new(className)
            remote.Name = name
            remote.Parent = folder
        end
    end
end

function RemoteService.Get(name)
    assert(folder, "RemoteService.Init() must run first")
    local remote = folder:FindFirstChild(name)
    assert(remote, "Unknown remote: " .. tostring(name))
    return remote
end

return RemoteService
