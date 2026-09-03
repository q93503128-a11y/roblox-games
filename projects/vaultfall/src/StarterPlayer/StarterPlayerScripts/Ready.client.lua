local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local ready = remotes:WaitForChild("Ready")

-- Client HUD listeners are created by Client.client.lua in the same PlayerScripts tree.
-- A short defer avoids racing the first authoritative state push against those listeners.
task.wait(0.15)
ready:FireServer()
