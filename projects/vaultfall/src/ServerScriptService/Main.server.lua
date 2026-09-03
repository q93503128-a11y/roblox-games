local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Config = require(shared:WaitForChild("Config"))
local Loot = require(shared:WaitForChild("Loot"))

local servicesFolder = script.Parent:WaitForChild("Services")
local Profile = require(servicesFolder:WaitForChild("ProfileService"))
local World = require(servicesFolder:WaitForChild("WorldService"))
local Enemies = require(servicesFolder:WaitForChild("EnemyService"))
local Run = require(servicesFolder:WaitForChild("RunService"))
local Combat = require(servicesFolder:WaitForChild("CombatService"))
local EncounterDirector = require(servicesFolder:WaitForChild("EncounterDirector"))
local Augments = require(servicesFolder:WaitForChild("AugmentService"))
local Objectives = require(servicesFolder:WaitForChild("ObjectiveService"))
local OptionalOps = require(servicesFolder:WaitForChild("OptionalOpsService"))
local HVT = require(servicesFolder:WaitForChild("HVTService"))
local SectorModifiers = require(servicesFolder:WaitForChild("SectorModifierService"))
local VisualAssets = require(servicesFolder:WaitForChild("VisualAssetService"))

local remotesFolder = ReplicatedStorage:FindFirstChild("VaultfallRemotes")
if remotesFolder then
    remotesFolder:Destroy()
end
remotesFolder = Instance.new("Folder")
remotesFolder.Name = "VaultfallRemotes"
remotesFolder.Parent = ReplicatedStorage

local function makeRemote(name)
    local remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = remotesFolder
    return remote
end

local context = {
    Config = Config,
    Loot = Loot,
    Remotes = {
        Attack = makeRemote("Attack"),
        Skill = makeRemote("Skill"),
        ClaimLoot = makeRemote("ClaimLoot"),
        ClaimAugment = makeRemote("ClaimAugment"),
        State = makeRemote("State"),
        Ready = makeRemote("Ready"),
    },
    Profile = Profile,
    World = World,
    Enemies = Enemies,
    Run = Run,
    Combat = Combat,
    EncounterDirector = EncounterDirector,
    Augments = Augments,
    Objectives = Objectives,
    OptionalOps = OptionalOps,
    HVT = HVT,
    SectorModifiers = SectorModifiers,
    VisualAssets = VisualAssets,
}

-- Publish any installed, sanitized Creator Store weapon visuals before clients
-- build their first-person viewmodels. Missing packs never block a playable build.
VisualAssets.Init(context)

-- World construction must never depend on persistence. A local .rbxlx can have
-- DataStore access disabled, but the player still needs a complete playable map.
World.Init(context)
Enemies.Init(context)
Run.Init(context)
Augments.Init(context)
Objectives.Init(context)
Combat.Init(context)
EncounterDirector.Init(context)
OptionalOps.Init(context)
HVT.Init(context)
SectorModifiers.Init(context)
World.Build()
Profile.Init(context)

local function placeAtHub(player, character)
    if Run.IsParticipant(player) then
        return
    end

    local root = character:WaitForChild("HumanoidRootPart", 10)
    if not root or not character.Parent then
        return
    end

    character:PivotTo(World.GetHubSpawnCFrame())
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

context.Remotes.Ready.OnServerEvent:Connect(function(player)
    if not Profile.Get(player) then
        Profile.Load(player)
    end
    Profile.Push(player)
    Run.PushState(player)
    Augments.PushState(player)
    Objectives.PushState(player)
    OptionalOps.PushState(player)
    HVT.PushState(player)
    SectorModifiers.PushState(player)
end)

local function onPlayerAdded(player)
    Profile.Load(player)

    player.CharacterAdded:Connect(function(character)
        task.defer(placeAtHub, player, character)
    end)

    if player.Character then
        task.defer(placeAtHub, player, player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
    Augments.ClearPlayer(player)
    Profile.Unload(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(onPlayerAdded, player)
end

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        Profile.Save(player)
    end
end)

print("[Vaultfall] server boot complete; world ready")