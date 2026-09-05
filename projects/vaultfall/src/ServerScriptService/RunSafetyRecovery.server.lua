local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local services = script.Parent:WaitForChild("Services")
local Run = require(services:WaitForChild("RunService"))
local World = require(services:WaitForChild("WorldService"))

local CHECK_INTERVAL = 0.65
local MAX_ROOM_DISTANCE = 250
local FALL_Y = -80
local RESPAWN_COOLDOWN = 4
local RECOVERY_COOLDOWN = 2

local lastRespawn = {}
local lastRecovery = {}
local elapsed = 0

local function notify(player, message)
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("VaultfallRemotes")
    local state = remotes and remotes:FindFirstChild("State")
    if state then
        state:FireClient(player, "Notice", message)
    end
end

local function roomSpawn(roomIndex)
    local ok, result = pcall(function()
        return World.GetRoomSpawnCFrame(roomIndex)
    end)
    if ok then
        return result
    end
    return nil
end

local function recoverCharacter(player, character, root, roomIndex, reason)
    local now = os.clock()
    if now - (lastRecovery[player] or -100) < RECOVERY_COOLDOWN then
        return
    end

    local destination = roomSpawn(roomIndex)
    if not destination then
        return
    end

    lastRecovery[player] = now
    character:PivotTo(destination * CFrame.new((math.random() - 0.5) * 5, 2.5, (math.random() - 0.5) * 5))
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    notify(player, reason)
end

local function ensureParticipant(player, roomIndex)
    if not Run.IsParticipant(player) then
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoid or not root then
        local now = os.clock()
        if now - (lastRespawn[player] or -100) >= RESPAWN_COOLDOWN then
            lastRespawn[player] = now
            task.spawn(function()
                if player.Parent and Run.IsParticipant(player) then
                    player:LoadCharacter()
                end
            end)
        end
        return
    end

    if humanoid.Health <= 0 then
        return
    end

    local room = World.GetRoom(roomIndex)
    if not room or not room.Origin then
        return
    end

    local horizontalDelta = Vector3.new(root.Position.X - room.Origin.X, 0, root.Position.Z - room.Origin.Z)
    if root.Position.Y < FALL_Y then
        recoverCharacter(player, character, root, roomIndex, "FIELD RECOVERY — operator returned after a fall")
    elseif horizontalDelta.Magnitude > MAX_ROOM_DISTANCE then
        recoverCharacter(player, character, root, roomIndex, "FIELD RECOVERY — operator returned to the active sector")
    end
end

RunService.Heartbeat:Connect(function(dt)
    elapsed += dt
    if elapsed < CHECK_INTERVAL then
        return
    end
    elapsed = 0

    if not Run.IsActive() then
        return
    end

    local roomIndex = Run.GetCurrentRoom()
    if roomIndex <= 0 then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        ensureParticipant(player, roomIndex)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    lastRespawn[player] = nil
    lastRecovery[player] = nil
end)
