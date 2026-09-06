local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local correction = CFrame.identity
local tunedModel

local tuning = {
    Carbine = {
        Scale = 0.84,
        Hip = CFrame.new(0.06, -0.02, -0.14),
        ADS = CFrame.new(-0.10, 0.05, -0.27),
    },
    SMG = {
        Scale = 0.86,
        Hip = CFrame.new(0.08, -0.03, -0.12),
        ADS = CFrame.new(-0.09, 0.05, -0.23),
    },
    Shotgun = {
        Scale = 0.80,
        Hip = CFrame.new(0.11, -0.05, -0.24),
        ADS = CFrame.new(-0.07, 0.03, -0.34),
    },
    RailRifle = {
        Scale = 0.76,
        Hip = CFrame.new(0.14, -0.07, -0.30),
        ADS = CFrame.new(-0.05, 0.01, -0.42),
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

    local model = camera:FindFirstChild("BreachWeaponViewmodel")
    if not model or not model:IsA("Model") or not model.PrimaryPart then
        tunedModel = nil
        return
    end
    retuneModel(model)

    local config = tuning[currentArchetype] or tuning.Carbine
    local aiming = player:GetAttribute("VaultfallADS") == true
    local nearWall = tonumber(player:GetAttribute("VaultfallNearWall")) or 0
    local modal = player:GetAttribute("VaultfallInputModal") == true

    local target = aiming and config.ADS or config.Hip

    -- Near a wall the weapon drops and pulls inward instead of occupying the entire
    -- screen or visibly passing through nearby geometry.
    if nearWall > 0 then
        target *= CFrame.new(0.08 * nearWall, -0.44 * nearWall, 0.32 * nearWall)
            * CFrame.Angles(math.rad(18 * nearWall), math.rad(-5 * nearWall), math.rad(5 * nearWall))
    end

    -- Keep menus visually clear without deleting the weapon model or disturbing state.
    if modal then
        target *= CFrame.new(0.12, -0.30, 0.12)
    end

    local alpha = 1 - math.exp(-dt * 15)
    correction = correction:Lerp(target, alpha)

    -- Client.client.lua owns recoil/reload/bob. Apply only a final ergonomic correction
    -- after that animation so those systems remain intact.
    model:PivotTo(model:GetPivot() * correction)
end)
