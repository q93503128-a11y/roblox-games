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
        State = makeRemote("State"),
    },
    Profile = Profile,
    World = World,
    Enemies = Enemies,
    Run = Run,
    Combat = Combat,
}

Profile.Init(context)
World.Init(context)
Enemies.Init(context)
Run.Init(context)
Combat.Init(context)
World.Build()

local function onPlayerAdded(player)
    Profile.Load(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
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

print("[Vaultfall] server boot complete")
