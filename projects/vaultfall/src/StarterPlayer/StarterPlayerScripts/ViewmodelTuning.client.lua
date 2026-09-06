local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local correction = CFrame.identity
local tunedModel

-- The legacy viewmodel animator still supplies recoil/reload/bob. This layer is the
-- final ergonomic pass and deliberately keeps the fallback weapon away from the
-- center of the target, especially while aiming.
local tuning = {
    Carbine = {
        Scale = 0.80,
        Hip = CFrame.new(0.08, -0.05, -0.20),
        ADS = CFrame.new(0.24, -0.13, -0.38),
        HipFov = 72,
        AdsFov = 64,
    },
    SMG = {
        Scale = 0.82,
        Hip = CFrame.new(0.10, -0.06, -0.18),
        ADS = CFrame.new(0.27, -0.14, -0.34),
        HipFov = 73,
        AdsFov = 66,
    },
    Shotgun = {
        Scale = 0.76,
        Hip = CFrame.new(0.15, -0.09, -0.30),
        ADS = CFrame.new(0.30, -0.17, -0.48),
        HipFov = 72,
        AdsFov = 67,
    },
    RailRifle = {
        Scale = 0.72,
        Hip = CFrame.new(0.18, -0.11, -0.38),
        ADS = CFrame.new(0.31, -0.18, -0.56),
        HipFov = 71,
        AdsFov = 61,
    },
}

local function retuneModel(model)
    if tunedModel == model then
        return
    end

    tunedModel = model
    correction = CFrame.identity
    local config = tuning[currentArchetype] or tuning.Carbine

    -- The self-contained fallback was authored too large for a first-person camera.
    -- Scale it once per freshly-created model instead of covering the target with it.
    pcall(function()
        model:ScaleTo(config.Scale)
    end)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and payload then
        currentArchetype = payload.Archetype or "Carbine"
        tunedModel = nil
    end
end)

RunService:BindToRenderStep("BreachViewmodelTuning", Enum.RenderPriority.Last.Value - 1, function(dt)
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local config = tuning[currentArchetype] or tuning.Carbine
    local aiming = player:GetAttribute("VaultfallADS") == true
    local nearWall = tonumber(player:GetAttribute("VaultfallNearWall")) or 0
    local modal = player:GetAttribute("VaultfallInputModal") == true

    -- Client.client.lua still contains an old FOV lerp. Own the final camera value at
    -- the end of the render pipeline so ADS cannot oscillate between two controllers.
    local targetFov = aiming and config.AdsFov or config.HipFov
    local fovAlpha = 1 - math.exp(-dt * (aiming and 18 or 13))
    camera.FieldOfView += (targetFov - camera.FieldOfView) * fovAlpha

    local model = camera:FindFirstChild("BreachWeaponViewmodel")
    if not model or not model:IsA("Model") or not model.PrimaryPart then
        tunedModel = nil
        return
    end
    retuneModel(model)

    local target = aiming and config.ADS or config.Hip

    -- Near a wall the weapon drops aggressively and pulls inward. At full obstruction
    -- it is almost entirely below the sightline instead of clipping through geometry.
    if nearWall > 0 then
        target *= CFrame.new(0.12 * nearWall, -0.62 * nearWall, 0.40 * nearWall)
            * CFrame.Angles(math.rad(24 * nearWall), math.rad(-6 * nearWall), math.rad(7 * nearWall))
    end

    -- Keep menus visually clear without deleting the weapon model or disturbing state.
    if modal then
        target *= CFrame.new(0.18, -0.44, 0.18)
    end

    local alpha = 1 - math.exp(-dt * (aiming and 20 or 15))
    correction = correction:Lerp(target, alpha)

    -- Client.client.lua owns recoil/reload/bob. Apply only a final ergonomic correction
    -- after that animation so those systems remain intact.
    model:PivotTo(model:GetPivot() * correction)
end)
