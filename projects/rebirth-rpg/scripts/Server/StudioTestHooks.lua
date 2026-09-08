--!strict

local RunService = game:GetService("RunService")

local GameConfig = require(script.Parent.GameConfig)
local ProfileService = require(script.Parent.ProfileService)

local StudioTestHooks = {}

local function assertStudio()
	assert(RunService:IsStudio(), "RebirthRPG StudioTestHooks are disabled outside Studio")
end

function StudioTestHooks.PrepareRebirthEligible(player: Player)
	assertStudio()
	local profile = ProfileService.Get(player)
	assert(profile ~= nil, "Player profile is not loaded")

	profile.progression.level = GameConfig.Rebirth.SliceRequiredLevel
	profile.progression.xp = 0
	profile.progression.regionProgress[GameConfig.Rebirth.RequiredClearFlag] = true
	ProfileService.Push(player)
end

function StudioTestHooks.GrantWeaponB(player: Player)
	assertStudio()
	ProfileService.AddItem(player, "weapon_start_b", 1)
end

function StudioTestHooks.SetRebirthCount(player: Player, rebirths: number)
	assertStudio()
	assert(rebirths >= 0 and rebirths <= 100, "Rebirth test count out of range")
	local profile = ProfileService.Get(player)
	assert(profile ~= nil, "Player profile is not loaded")

	profile.progression.rebirths = math.floor(rebirths)
	ProfileService.Push(player)
end

return StudioTestHooks
