--!strict

local Players = game:GetService("Players")

local RebirthService = {}

local ProfileService: any = nil
local requestRemote: RemoteEvent? = nil
local feedbackRemote: RemoteEvent? = nil
local lastRequestAt: { [Player]: number } = {}

local function onRequest(player: Player)
	local now = os.clock()
	local previous = lastRequestAt[player] or -math.huge
	if now - previous < 1.0 then
		return
	end
	lastRequestAt[player] = now

	local success, reason = ProfileService.PerformRebirth(player)
	if feedbackRemote ~= nil then
		feedbackRemote:FireClient(player, {
			type = "rebirth",
			success = success,
			reason = reason,
		})
	end
end

function RebirthService.Init(profileService: any, requestRebirth: RemoteEvent, combatFeedback: RemoteEvent)
	ProfileService = profileService
	requestRemote = requestRebirth
	feedbackRemote = combatFeedback
	requestRemote.OnServerEvent:Connect(onRequest)

	Players.PlayerRemoving:Connect(function(player)
		lastRequestAt[player] = nil
	end)
end

return RebirthService
