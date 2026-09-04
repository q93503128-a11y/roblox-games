local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local lastShotAt = -100
local reloadStarted = -100
local reloadDuration = 0
local trackedModel = nil
local trackedRoot = nil
local tracked = {}

local function refreshModel()
    local camera = workspace.CurrentCamera
    local model = camera and camera:FindFirstChild("BreachWeaponViewmodel")
    if model == trackedModel and trackedRoot and trackedRoot.Parent then
        return
    end

    trackedModel = model
    trackedRoot = model and model:IsA("Model") and model.PrimaryPart or nil
    table.clear(tracked)
    if not trackedModel or not trackedRoot then
        return
    end

    for _, part in ipairs(trackedModel:GetDescendants()) do
        if part:IsA("BasePart") and string.sub(part.Name, 1, 17) == "ProductionDetail_" then
            tracked[part.Name] = {
                Part = part,
                Local = trackedRoot.CFrame:ToObjectSpace(part.CFrame),
                Transparency = part.Transparency,
                Size = part.Size,
            }
        end
    end
end

local function entry(name)
    return tracked["ProductionDetail_" .. name]
end

local function transform(name, offset)
    local item = entry(name)
    if item and item.Part.Parent and trackedRoot then
        item.Part.CFrame = trackedRoot.CFrame * item.Local * offset
    end
end

local function restoreVisual(name)
    local item = entry(name)
    if item and item.Part.Parent then
        item.Part.Transparency = item.Transparency
        item.Part.Size = item.Size
    end
end

local function setGlow(name, transparency, scale)
    local item = entry(name)
    if item and item.Part.Parent then
        item.Part.Transparency = transparency
        item.Part.Size = item.Size * scale
    end
end

local function animateShotgun(age)
    local travel = 0
    if age >= 0.10 and age <= 0.62 then
        local phase = math.clamp((age - 0.10) / 0.52, 0, 1)
        travel = math.sin(phase * math.pi) * 0.48
    end
    for index = 1, 3 do
        transform("PumpRib" .. index, CFrame.new(0, 0, travel))
    end

    local reloadPhase = reloadDuration > 0 and math.clamp((os.clock() - reloadStarted) / reloadDuration, 0, 1) or 0
    for index = 1, 3 do
        local shell = entry("ShellSaddle" .. index)
        if shell and shell.Part.Parent then
            local threshold = 0.20 + ((index - 1) * 0.15)
            local hidden = reloadDuration > 0 and reloadPhase > threshold and reloadPhase < threshold + 0.10
            shell.Part.Transparency = hidden and 0.82 or shell.Transparency
        end
    end
end

local function animateSmg(age)
    local kick = age <= 0.10 and math.exp(-age * 24) or 0
    transform("ChargingHandle", CFrame.new(0, 0, 0.20 * kick))
    transform("PortedBrake", CFrame.new(0, 0, 0.035 * kick))
end

local function animateCarbine(age)
    local kick = age <= 0.14 and math.exp(-age * 20) or 0
    transform("MuzzleBrake", CFrame.new(0, 0, 0.045 * kick))
    transform("GasBlock", CFrame.new(0, 0, 0.025 * kick))
    local optic = entry("OpticLens")
    if optic and optic.Part.Parent then
        optic.Part.Transparency = math.clamp(optic.Transparency - kick * 0.18, 0.05, 0.7)
    end
end

local function animateRail(age)
    local pulse = age <= 0.62 and math.sin(math.clamp(age / 0.62, 0, 1) * math.pi) or 0
    for index = 1, 4 do
        local delayOffset = (index - 1) * 0.035
        local localAge = math.max(0, age - delayOffset)
        local localPulse = localAge <= 0.52 and math.sin(math.clamp(localAge / 0.52, 0, 1) * math.pi) or 0
        setGlow("Coil" .. index, math.clamp(0.12 - localPulse * 0.10, 0, 0.45), 1 + localPulse * 0.14)
    end
    setGlow("ChargeCore", math.clamp(0.08 - pulse * 0.07, 0, 0.4), 1 + pulse * 0.18)
    transform("MuzzleProng1", CFrame.new(-0.04 * pulse, 0, 0))
    transform("MuzzleProng2", CFrame.new(0.04 * pulse, 0, 0))
end

local function restoreAll()
    restoreVisual("OpticLens")
    restoreVisual("ChargeCore")
    for index = 1, 4 do
        restoreVisual("Coil" .. index)
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and payload then
        currentArchetype = payload.Archetype or "Carbine"
        trackedModel = nil
    elseif kind == "WeaponFX" and payload then
        if payload.Kind == "Shot" then
            currentArchetype = payload.Archetype or currentArchetype
            lastShotAt = os.clock()
        elseif payload.Kind == "Reload" then
            reloadStarted = os.clock()
            reloadDuration = math.max(0.25, payload.Duration or 1.5)
        end
    elseif kind == "Combat" and payload and payload.Reloading == false and reloadDuration > 0 then
        if os.clock() - reloadStarted > reloadDuration * 0.75 then
            reloadDuration = 0
        end
    end
end)

RunService:BindToRenderStep("BreachWeaponMechanicalDetails", Enum.RenderPriority.Camera.Value + 4, function()
    refreshModel()
    if not trackedRoot then
        return
    end

    local age = os.clock() - lastShotAt
    restoreAll()
    if currentArchetype == "Shotgun" then
        animateShotgun(age)
    elseif currentArchetype == "SMG" then
        animateSmg(age)
    elseif currentArchetype == "RailRifle" then
        animateRail(age)
    else
        animateCarbine(age)
    end

    if reloadDuration > 0 and os.clock() - reloadStarted >= reloadDuration then
        reloadDuration = 0
    end
end)
