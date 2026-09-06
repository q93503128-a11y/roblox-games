local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Arsenal = require(shared:WaitForChild("Arsenal"))
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local impactWindowStarted = 0
local impactCount = 0

local IMPACT_BUDGET = {
    Carbine = 2,
    SMG = 1,
    Shotgun = 3,
    RailRifle = 2,
}

local FLASH_PROFILE = {
    Carbine = { Core = 0.12, Lance = Vector3.new(0.045, 0.045, 0.72), Duration = 0.052 },
    SMG = { Core = 0.085, Lance = Vector3.new(0.032, 0.032, 0.46), Duration = 0.038 },
    Shotgun = { Core = 0.15, Lance = Vector3.new(0.065, 0.065, 0.62), Duration = 0.058 },
    RailRifle = { Core = 0.095, Lance = Vector3.new(0.028, 0.028, 1.35), Duration = 0.075 },
}

local function configureFxPart(part)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Massless = true
end

local function currentMuzzle()
    local camera = workspace.CurrentCamera
    local model = camera and camera:FindFirstChild("BreachWeaponViewmodel")
    if not model then
        return nil
    end
    local muzzle = model:FindFirstChild("Muzzle", true)
    if muzzle and muzzle:IsA("BasePart") then
        return muzzle
    end
    return nil
end

local function fade(part, duration, goalSize)
    TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1,
        Size = goalSize,
    }):Play()
    Debris:AddItem(part, duration + 0.04)
end

local function makeFlashPart(name, size, cframe, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = Enum.Material.Neon
    configureFxPart(part)
    part.Parent = workspace
    return part
end

local function screenSafeMuzzleFlash()
    local muzzle = currentMuzzle()
    if not muzzle then
        return
    end

    local definition = Arsenal.Get(currentArchetype) or Arsenal.Get("Carbine")
    local profile = FLASH_PROFILE[currentArchetype] or FLASH_PROFILE.Carbine
    local accent = definition.Accent or Color3.fromRGB(220, 230, 235)

    local core = makeFlashPart(
        "BreachReadableMuzzleCore",
        Vector3.new(profile.Core, profile.Core, profile.Core),
        muzzle.CFrame * CFrame.new(0, 0, -0.05),
        accent
    )
    core.Shape = Enum.PartType.Ball
    fade(core, profile.Duration, core.Size * 1.75)

    local lanceLength = profile.Lance.Z
    local lance = makeFlashPart(
        "BreachReadableMuzzleLance",
        profile.Lance,
        muzzle.CFrame * CFrame.new(0, 0, -lanceLength * 0.5),
        accent
    )
    fade(lance, profile.Duration * 0.9, Vector3.new(profile.Lance.X * 0.7, profile.Lance.Y * 0.7, lanceLength * 1.12))

    if currentArchetype == "Shotgun" then
        for _, offset in ipairs({ -0.11, 0.11 }) do
            local petal = makeFlashPart(
                "BreachReadableShotgunPetal",
                Vector3.new(0.035, 0.035, 0.38),
                muzzle.CFrame * CFrame.Angles(0, math.rad(offset * 32), 0) * CFrame.new(offset, 0, -0.19),
                accent
            )
            fade(petal, 0.045, Vector3.new(0.02, 0.02, 0.48))
        end
    end
end

local function suppressGenericFx(child)
    if not child:IsA("BasePart") then
        return
    end

    if child.Name == "BreachMuzzleBurst" or child.Name == "BreachMuzzleRay" then
        child.Transparency = 1
        return
    end

    if child.Name ~= "BreachImpactSpark" then
        return
    end

    local now = os.clock()
    if now - impactWindowStarted > 0.055 then
        impactWindowStarted = now
        impactCount = 0
    end
    impactCount += 1

    local budget = IMPACT_BUDGET[currentArchetype] or IMPACT_BUDGET.Carbine
    if impactCount > budget then
        child.Transparency = 1
        return
    end

    local definition = Arsenal.Get(currentArchetype) or Arsenal.Get("Carbine")
    if impactCount == 1 then
        child.Color = definition.Accent or child.Color
    end
    child.Size = Vector3.new(
        math.min(child.Size.X, 0.035),
        math.min(child.Size.Y, 0.035),
        math.min(child.Size.Z, currentArchetype == "Shotgun" and 0.24 or 0.20)
    )
end

workspace.ChildAdded:Connect(suppressGenericFx)

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Combat" and payload then
        currentArchetype = payload.Archetype or currentArchetype
    elseif kind == "WeaponFX" and payload then
        currentArchetype = payload.Archetype or currentArchetype
        if payload.Kind == "Shot" then
            screenSafeMuzzleFlash()
        end
    end
end)
