local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local services = script.Parent:WaitForChild("Services")
local Run = require(services:WaitForChild("RunService"))

-- RunService keeps a participant in the expedition roster after death so the
-- result screen, pending rewards, and cleanup can still address that player.
-- Combat code historically used IsParticipant as its authorization gate,
-- though, which meant Roblox's automatic character respawn could make an
-- eliminated operator combat-capable again while the same run was active.
--
-- Keep roster membership intact, but narrow the public runtime eligibility
-- predicate for eliminated operators. This also lets Main/RunSafety place a
-- respawned eliminated character back in the safehouse instead of pulling it
-- into the active sector again.

local originalIsParticipant = Run.IsParticipant
local eliminated = {}
local boundCharacters = setmetatable({}, { __mode = "k" })
local wasActive = Run.IsActive()

local function bindCharacter(player, character)
    if not character or boundCharacters[character] then
        return
    end
    boundCharacters[character] = true

    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
    if not humanoid then
        return
    end

    humanoid.Died:Connect(function()
        if originalIsParticipant(player) then
            eliminated[player] = true
        end
    end)
end

Run.IsParticipant = function(player)
    return originalIsParticipant(player) and eliminated[player] ~= true
end

local function observePlayer(player)
    player.CharacterAdded:Connect(function(character)
        bindCharacter(player, character)
    end)
    if player.Character then
        task.defer(bindCharacter, player, player.Character)
    end
end

Players.PlayerAdded:Connect(observePlayer)
Players.PlayerRemoving:Connect(function(player)
    eliminated[player] = nil
end)

for _, player in ipairs(Players:GetPlayers()) do
    observePlayer(player)
end

RunService.Heartbeat:Connect(function()
    local active = Run.IsActive()
    if active and not wasActive then
        -- A new expedition starts with a fresh eligibility slate. The canonical
        -- RunService roster is authoritative for who joined the new run.
        table.clear(eliminated)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                bindCharacter(player, player.Character)
            end
        end
    elseif not active and wasActive then
        table.clear(eliminated)
    end
    wasActive = active
end)
