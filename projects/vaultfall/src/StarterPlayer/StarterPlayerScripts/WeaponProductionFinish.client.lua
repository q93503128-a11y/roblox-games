local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local currentModel = nil
local tracked = {}
local finishBuiltFor = nil

local FINISH_PREFIX = "ProductionFinish_"
local DETAIL_PREFIX = "ProductionDetail_"

local DARK = Color3.fromRGB(20, 24, 27)
local STEEL = Color3.fromRGB(82, 91, 96)
local GLASS = Color3.fromRGB(91, 179, 198)
local ACCENTS = {
    Carbine = Color3.fromRGB(92, 160, 177),
    SMG = Color3.fromRGB(93, 187, 155),
    Shotgun = Color3.fromRGB(206, 126, 73),
    RailRifle = Color3.fromRGB(140, 112, 224),
}

local function configure(part)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Massless = true
end

local function remember(part, root, localCFrame)
    tracked[part] = localCFrame or root.CFrame:ToObjectSpace(part.CFrame)
end

local function makePart(model, name, size, localCFrame, color, material, shape)
    local root = model.PrimaryPart
    if not root then
        return nil
    end

    local part = Instance.new("Part")
    part.Name = FINISH_PREFIX .. name
    part.Size = size
    part.CFrame = root.CFrame * localCFrame
    part.Color = color or STEEL
    part.Material = material or Enum.Material.Metal
    if shape then
        part.Shape = shape
    end
    configure(part)
    part.Parent = model
    remember(part, root, localCFrame)
    return part
end

local function makeWedge(model, name, size, localCFrame, color)
    local root = model.PrimaryPart
    if not root then
        return nil
    end

    local part = Instance.new("WedgePart")
    part.Name = FINISH_PREFIX .. name
    part.Size = size
    part.CFrame = root.CFrame * localCFrame
    part.Color = color or DARK
    part.Material = Enum.Material.Metal
    configure(part)
    part.Parent = model
    remember(part, root, localCFrame)
    return part
end

local function clearFinish(model)
    for part in pairs(tracked) do
        if not part.Parent then
            tracked[part] = nil
        end
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if string.sub(descendant.Name, 1, #FINISH_PREFIX) == FINISH_PREFIX then
            tracked[descendant] = nil
            descendant:Destroy()
        end
    end
end

local function addCarbine(model, accent)
    makeWedge(model, "ReceiverShoulderL", Vector3.new(0.14, 0.42, 1.18), CFrame.new(-0.39, 0.19, -0.28) * CFrame.Angles(0, math.rad(90), 0), DARK)
    makeWedge(model, "ReceiverShoulderR", Vector3.new(0.14, 0.42, 1.18), CFrame.new(0.39, 0.19, -0.28) * CFrame.Angles(0, math.rad(-90), 0), DARK)
    makePart(model, "MagazineWell", Vector3.new(0.58, 0.42, 0.52), CFrame.new(0, -0.28, 0.42) * CFrame.Angles(math.rad(-7), 0, 0), STEEL)
    makePart(model, "Magazine", Vector3.new(0.44, 0.92, 0.34), CFrame.new(0, -0.79, 0.56) * CFrame.Angles(math.rad(-10), 0, 0), DARK, Enum.Material.Metal)
    makePart(model, "StatusStrip", Vector3.new(0.06, 0.15, 0.82), CFrame.new(-0.34, 0.10, 0.12), accent, Enum.Material.Neon)
    makePart(model, "ForwardSight", Vector3.new(0.12, 0.24, 0.14), CFrame.new(0, 0.50, -1.60), DARK)
end

local function addSmg(model, accent)
    makePart(model, "CompactReceiver", Vector3.new(0.74, 0.58, 1.25), CFrame.new(0, 0.05, -0.15), DARK)
    makePart(model, "BoxMagazine", Vector3.new(0.40, 0.92, 0.30), CFrame.new(0, -0.72, 0.34) * CFrame.Angles(math.rad(-4), 0, 0), STEEL)
    makePart(model, "RearBrace", Vector3.new(0.56, 0.34, 0.18), CFrame.new(0, 0.02, 1.76), DARK)
    makePart(model, "SideCharge", Vector3.new(0.12, 0.16, 0.42), CFrame.new(0.45, 0.25, 0.10), accent, Enum.Material.Neon)
    makePart(model, "MuzzleCage", Vector3.new(0.36, 0.30, 0.36), CFrame.new(0, 0, -1.95) * CFrame.Angles(math.rad(90), 0, 0), STEEL, Enum.Material.Metal, Enum.PartType.Cylinder)
end

local function addShotgun(model, accent)
    makePart(model, "TubeMagazine", Vector3.new(0.15, 2.10, 0.15), CFrame.new(0, -0.23, -1.95) * CFrame.Angles(math.rad(90), 0, 0), STEEL, Enum.Material.Metal, Enum.PartType.Cylinder)
    makePart(model, "PumpBody", Vector3.new(0.78, 0.46, 0.82), CFrame.new(0, -0.08, -1.30), DARK)
    for index, x in ipairs({ -0.30, -0.15, 0, 0.15, 0.30 }) do
        makePart(model, "PumpGroove" .. index, Vector3.new(0.035, 0.48, 0.70), CFrame.new(x, -0.08, -1.30), STEEL)
    end
    makePart(model, "ReceiverPlateL", Vector3.new(0.05, 0.36, 0.90), CFrame.new(-0.40, 0.09, 0.10), accent, Enum.Material.Metal)
    makePart(model, "ReceiverPlateR", Vector3.new(0.05, 0.36, 0.90), CFrame.new(0.40, 0.09, 0.10), accent, Enum.Material.Metal)
    makePart(model, "ShellPort", Vector3.new(0.06, 0.22, 0.48), CFrame.new(0.43, 0.08, 0.18), Color3.fromRGB(8, 10, 11), Enum.Material.SmoothPlastic)
end

local function addRailRifle(model, accent)
    makePart(model, "PowerCell", Vector3.new(0.48, 0.72, 0.50), CFrame.new(0, -0.64, 0.34), DARK)
    local cellWindow = makePart(model, "PowerCellWindow", Vector3.new(0.36, 0.48, 0.055), CFrame.new(0, -0.64, 0.085), accent, Enum.Material.Neon)
    if cellWindow then
        cellWindow.Transparency = 0.08
    end
    makePart(model, "RearCapacitorL", Vector3.new(0.18, 0.30, 1.05), CFrame.new(-0.34, 0.10, 1.18), STEEL)
    makePart(model, "RearCapacitorR", Vector3.new(0.18, 0.30, 1.05), CFrame.new(0.34, 0.10, 1.18), STEEL)
    makePart(model, "ScopeBridge", Vector3.new(0.58, 0.12, 1.42), CFrame.new(0, 0.46, 0.20), DARK)
    local emitter = makePart(model, "EmitterGlass", Vector3.new(0.30, 0.30, 0.05), CFrame.new(0, 0.04, -3.74), GLASS, Enum.Material.Glass)
    if emitter then
        emitter.Transparency = 0.16
        local light = Instance.new("PointLight")
        light.Name = FINISH_PREFIX .. "EmitterLight"
        light.Color = accent
        light.Brightness = 0.65
        light.Range = 4
        light.Shadows = false
        light.Parent = emitter
    end
end

local function buildFinish(model)
    if not model.PrimaryPart then
        return
    end

    clearFinish(model)
    local accent = ACCENTS[currentArchetype] or ACCENTS.Carbine
    if currentArchetype == "SMG" then
        addSmg(model, accent)
    elseif currentArchetype == "Shotgun" then
        addShotgun(model, accent)
    elseif currentArchetype == "RailRifle" then
        addRailRifle(model, accent)
    else
        addCarbine(model, accent)
    end
    finishBuiltFor = currentArchetype
end

local function captureUntrackedDetails(model)
    local root = model.PrimaryPart
    if not root then
        return
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart")
            and string.sub(descendant.Name, 1, #DETAIL_PREFIX) == DETAIL_PREFIX
            and tracked[descendant] == nil then
            remember(descendant, root)
        end
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and payload then
        currentArchetype = payload.Archetype or "Carbine"
        finishBuiltFor = nil
    end
end)

RunService:BindToRenderStep("VaultfallWeaponProductionFinish", Enum.RenderPriority.Camera.Value + 3, function()
    local camera = workspace.CurrentCamera
    local model = camera and camera:FindFirstChild("BreachWeaponViewmodel")
    if not model or not model:IsA("Model") or not model.PrimaryPart then
        currentModel = nil
        table.clear(tracked)
        finishBuiltFor = nil
        return
    end

    if model ~= currentModel then
        currentModel = model
        table.clear(tracked)
        finishBuiltFor = nil
    end

    if finishBuiltFor ~= currentArchetype then
        buildFinish(model)
    end

    captureUntrackedDetails(model)

    local root = model.PrimaryPart
    for part, localCFrame in pairs(tracked) do
        if part.Parent and part:IsDescendantOf(model) then
            part.CFrame = root.CFrame * localCFrame
        else
            tracked[part] = nil
        end
    end
end)
