local clientModules = script.Parent:WaitForChild("Client")
local HUDController = require(clientModules:WaitForChild("HUDController"))

HUDController.Start()
