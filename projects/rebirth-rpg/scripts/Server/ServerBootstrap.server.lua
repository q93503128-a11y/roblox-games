--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local projectRoot = ReplicatedStorage:FindFirstChild("RebirthRPG")
if projectRoot == nil then
	projectRoot = Instance.new("Folder")
	projectRoot.Name = "RebirthRPG"
	projectRoot.Parent = ReplicatedStorage
end

local shared = projectRoot:WaitForChild("Shared")
local Protocol = require(shared:WaitForChild("Protocol"))

local remotesFolder = projectRoot:FindFirstChild("Remotes")
if remotesFolder == nil then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = projectRoot
end

local function ensureRemoteEvent(name: string): RemoteEvent
	local existing = remotesFolder:FindFirstChild(name)
	if existing ~= nil then
		assert(existing:IsA("RemoteEvent"), string.format("%s must be a RemoteEvent", existing:GetFullName()))
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotesFolder
	return remote
end

local function ensureRemoteFunction(name: string): RemoteFunction
	local existing = remotesFolder:FindFirstChild(name)
	if existing ~= nil then
		assert(existing:IsA("RemoteFunction"), string.format("%s must be a RemoteFunction", existing:GetFullName()))
		return existing
	end

	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = remotesFolder
	return remote
end

local AttackIntent = ensureRemoteEvent(Protocol.Remotes.AttackIntent)
local SkillIntent = ensureRemoteEvent(Protocol.Remotes.SkillIntent)
local EquipItem = ensureRemoteEvent(Protocol.Remotes.EquipItem)
local RequestRebirth = ensureRemoteEvent(Protocol.Remotes.RequestRebirth)
local StateUpdated = ensureRemoteEvent(Protocol.Remotes.StateUpdated)
local CombatFeedback = ensureRemoteEvent(Protocol.Remotes.CombatFeedback)
local GetState = ensureRemoteFunction(Protocol.Remotes.GetState)

local ProfileService = require(script.Parent.ProfileService)
local RewardService = require(script.Parent.RewardService)
local CombatService = require(script.Parent.CombatService)
local EnemyService = require(script.Parent.EnemyService)
local RebirthService = require(script.Parent.RebirthService)
local StudioSmokeHarness = require(script.Parent.StudioSmokeHarness)

ProfileService.Init(StateUpdated)
RewardService.Init(ProfileService)
CombatService.Init(ProfileService, RewardService, AttackIntent, SkillIntent, CombatFeedback)
RebirthService.Init(ProfileService, RequestRebirth, CombatFeedback)
StudioSmokeHarness.Start()
EnemyService.Start()

local lastEquipAt: { [Player]: number } = {}
local lastStateRequestAt: { [Player]: number } = {}

local function bindPlayer(player: Player)
	ProfileService.Create(player)

	player.CharacterAdded:Connect(function()
		task.defer(function()
			if player.Parent == Players then
				ProfileService.Push(player)
			end
		end)
	end)
end

Players.PlayerAdded:Connect(bindPlayer)
Players.PlayerRemoving:Connect(function(player)
	ProfileService.Remove(player)
	lastEquipAt[player] = nil
	lastStateRequestAt[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(bindPlayer, player)
end

GetState.OnServerInvoke = function(player: Player)
	local now = os.clock()
	local previous = lastStateRequestAt[player] or -math.huge
	if now - previous < 0.20 then
		return nil
	end
	lastStateRequestAt[player] = now
	return ProfileService.GetSnapshot(player)
end

EquipItem.OnServerEvent:Connect(function(player: Player, itemId: any)
	if typeof(itemId) ~= "string" or #itemId > 64 then
		return
	end

	local now = os.clock()
	local previous = lastEquipAt[player] or -math.huge
	if now - previous < 0.10 then
		return
	end
	lastEquipAt[player] = now

	ProfileService.EquipItem(player, itemId)
end)

print("[RebirthRPG] Server bootstrap ready: profile/combat/reward/enemy/rebirth core loaded")
