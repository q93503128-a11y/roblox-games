local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AnalyticsConfig = require(ReplicatedStorage.Shared.AnalyticsConfig)

local AnalyticsService = {}

local enabled = true
local allowed = {}

for _, eventName in pairs(AnalyticsConfig.Events) do
    allowed[eventName] = true
end

function AnalyticsService.Track(player, eventName, fields)
    if not enabled then
        return
    end

    if not allowed[eventName] then
        warn("Unknown analytics event:", eventName)
        return
    end

    -- MVP-004 uses structured server logging as the canonical event contract.
    -- Replace this body with Roblox AnalyticsService / approved pipeline later.
    local payload = {
        Event = eventName,
        UserId = player and player.UserId or 0,
        Timestamp = os.time(),
        Fields = fields or {},
    }

    print("[ANALYTICS]", payload.Event, payload.UserId)
end

function AnalyticsService.SetEnabled(value)
    enabled = value == true
end

return AnalyticsService
