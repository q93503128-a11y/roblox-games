local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local decoratedModel = nil
local rebuildRequested = true

local DARK = Color3.fromRGB(24, 28, 31)
local BLACK = Color3.fromRGB(12, 15, 17)
local STEEL = Color3.fromRGB(70, 78, 83)
local GLASS = Color3.fromRGB(86, 160, 180)
local SHELL = Color3.fromRGB(132, 43, 34)

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

local function detailPart(model, name, size, localCFrame, color, material)
    local root = model.PrimaryPart
    if not root then
        return nil
    end
    local part = Instance.new("Part")
    part.Name = "ProductionDetail_" .. name
    part.Size = size
    part.CFrame = root.CFrame * localCFrame
    part.Color = color or STEEL
    part.Material = material or Enum.Material.Metal
    configure(part)
    part.Parent = model
    return part
end

local function detailCylinder(model, name, size, localCFrame, color, material)
    local part = detailPart(model, name, size, localCFrame, color, material)
    if part then
        part.Shape = Enum.PartType.Cylinder
    end
    return part
end

local function detailWedge(model, name, size, localCFrame, color, material)
    local root = model.PrimaryPart
    if not root then
        return nil
    end
    local part = Instance.new("WedgePart")
    part.Name = "ProductionDetail_" .. name
    part.Size = size
    part.CFrame = root.CFrame * localCFrame
    part.Color = color or DARK
    part.Material = material or Enum.Material.Metal
    configure(part)
    part.Parent = model
    return part
end

local function pointLight(parent, color, brightness, range)
    if not parent then
        return
    end
    local light = Instance.new("PointLight")
    light.Name = "ProductionDetailLight"
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Shadows = false
    light.Parent = parent
end

local function clearDetails(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if string.sub(descendant.Name, 1, 17) == "ProductionDetail_" or descendant.Name == "ProductionDetailLight" then
            descendant:Destroy()
        end
    end
end

local function railSegment(model, index, z, accent)
    detailPart(model, "TopRail" .. index, Vector3.new(0.36, 0.08, 0.24), CFrame.new(0, 0.43, z), index % 2 == 0 and STEEL or accent)
end

local function addCarbine(model, accent)
    detailCylinder(model, "Barrel", Vector3.new(0.18, 1.35, 0.18), CFrame.new(0, 0.02, -2.33) * CFrame.Angles(math.rad(90), 0, 0), BLACK)
    detailCylinder(model, "MuzzleBrake", Vector3.new(0.28, 0.34, 0.28), CFrame.new(0, 0.02, -2.98) * CFrame.Angles(math.rad(90), 0, 0), STEEL)
    detailPart(model, "GasBlock", Vector3.new(0.42, 0.44, 0.28), CFrame.new(0, 0.12, -1.84), DARK)
    detailWedge(model, "PistolGrip", Vector3.new(0.34, 0.92, 0.42), CFrame.new(0, -0.63, 0.88) * CFrame.Angles(0, 0, math.rad(180)), BLACK)
    detailPart(model, "CheekRest", Vector3.new(0.38, 0.22, 1.06), CFrame.new(0, 0.22, 1.72), DARK)
    detailPart(model, "ButtPad", Vector3.new(0.52, 0.72, 0.16), CFrame.new(0, -0.05, 2.36), BLACK)
    for index, z in ipairs({ -1.25, -0.91, -0.57, -0.23, 0.11 }) do
        railSegment(model, index, z, accent)
    end
    detailPart(model, "OpticBody", Vector3.new(0.42, 0.34, 0.48), CFrame.new(0, 0.68, -0.18), BLACK)
    local lens = detailPart(model, "OpticLens", Vector3.new(0.31, 0.22, 0.035), CFrame.new(0, 0.69, -0.43), GLASS, Enum.Material.Glass)
    if lens then
        lens.Transparency = 0.28
    end
    for index, x in ipairs({ -0.34, 0.34 }) do
        detailPart(model, "Vent" .. index, Vector3.new(0.06, 0.25, 0.58), CFrame.new(x, 0.05, -1.35), accent, Enum.Material.Neon)
    end
end

local function addSmg(model, accent)
    detailCylinder(model, "CompactBarrel", Vector3.new(0.16, 0.74, 0.16), CFrame.new(0, 0, -1.70) * CFrame.Angles(math.rad(90), 0, 0), BLACK)
    detailCylinder(model, "PortedBrake", Vector3.new(0.30, 0.31, 0.30), CFrame.new(0, 0, -2.06) * CFrame.Angles(math.rad(90), 0, 0), STEEL)
    detailWedge(model, "Grip", Vector3.new(0.36, 0.82, 0.40), CFrame.new(0, -0.59, 0.66) * CFrame.Angles(0, 0, math.rad(180)), BLACK)
    detailPart(model, "ForeGrip", Vector3.new(0.28, 0.62, 0.30), CFrame.new(0, -0.49, -1.05), DARK)
    detailPart(model, "ChargingHandle", Vector3.new(0.36, 0.10, 0.18), CFrame.new(0.42, 0.22, -0.10), STEEL)
    detailPart(model, "StockStrutL", Vector3.new(0.08, 0.12, 1.08), CFrame.new(-0.18, 0.04, 1.31), STEEL)
    detailPart(model, "StockStrutR", Vector3.new(0.08, 0.12, 1.08), CFrame.new(0.18, 0.04, 1.31), STEEL)
    detailPart(model, "StockPad", Vector3.new(0.46, 0.58, 0.14), CFrame.new(0, 0.02, 1.88), BLACK)
    for index, z in ipairs({ -0.78, -0.48, -0.18, 0.12 }) do
        railSegment(model, index, z, accent)
    end
    detailPart(model, "MicroSight", Vector3.new(0.34, 0.30, 0.30), CFrame.new(0, 0.62, -0.10), BLACK)
    local glass = detailPart(model, "MicroGlass", Vector3.new(0.22, 0.16, 0.025), CFrame.new(0, 0.63, -0.26), GLASS, Enum.Material.Glass)
    if glass then
        glass.Transparency = 0.3
    end
    detailPart(model, "SideAccent", Vector3.new(0.05, 0.20, 0.84), CFrame.new(0.32, 0.05, -0.80), accent, Enum.Material.Neon)
end

local function addShotgun(model, accent)
    detailCylinder(model, "UpperBarrel", Vector3.new(0.18, 2.45, 0.18), CFrame.new(0, 0.16, -2.06) * CFrame.Angles(math.rad(90), 0, 0), BLACK)
    detailCylinder(model, "MuzzleCollar", Vector3.new(0.40, 0.30, 0.40), CFrame.new(0, 0.16, -3.22) * CFrame.Angles(math.rad(90), 0, 0), STEEL)
    detailWedge(model, "ShotgunGrip", Vector3.new(0.42, 0.92, 0.50), CFrame.new(0, -0.67, 0.82) * CFrame.Angles(0, 0, math.rad(180)), BLACK)
    detailPart(model, "StockComb", Vector3.new(0.46, 0.28, 1.10), CFrame.new(0, 0.17, 1.76), DARK)
    detailPart(model, "RecoilPad", Vector3.new(0.58, 0.76, 0.18), CFrame.new(0, -0.05, 2.48), BLACK)
    for index, z in ipairs({ -1.48, -1.18, -0.88 }) do
        detailPart(model, "PumpRib" .. index, Vector3.new(0.76, 0.10, 0.08), CFrame.new(0, -0.03, z), DARK)
    end
    for index, z in ipairs({ 0.18, 0.53, 0.88 }) do
        local shell = detailCylinder(model, "ShellSaddle" .. index, Vector3.new(0.16, 0.48, 0.16), CFrame.new(0.42, 0.02, z) * CFrame.Angles(math.rad(90), 0, 0), SHELL, Enum.Material.SmoothPlastic)
        if shell then
            shell.Transparency = 0.02
        end
    end
    detailPart(model, "ReceiverRail", Vector3.new(0.34, 0.10, 1.16), CFrame.new(0, 0.42, 0.20), STEEL)
    detailPart(model, "FrontBead", Vector3.new(0.10, 0.16, 0.10), CFrame.new(0, 0.39, -2.78), accent, Enum.Material.Neon)
end

local function addRailRifle(model, accent)
    detailPart(model, "RailSpineL", Vector3.new(0.16, 0.18, 2.52), CFrame.new(-0.30, 0.12, -1.72), STEEL)
    detailPart(model, "RailSpineR", Vector3.new(0.16, 0.18, 2.52), CFrame.new(0.30, 0.12, -1.72), STEEL)
    detailPart(model, "LowerRail", Vector3.new(0.34, 0.13, 2.32), CFrame.new(0, -0.36, -1.55), BLACK)
    for index, z in ipairs({ -0.75, -1.25, -1.75, -2.25 }) do
        detailCylinder(model, "Coil" .. index, Vector3.new(0.58, 0.10, 0.58), CFrame.new(0, 0.04, z) * CFrame.Angles(0, 0, math.rad(90)), accent, Enum.Material.Neon)
    end
    for index, x in ipairs({ -0.36, 0.36 }) do
        detailPart(model, "MuzzleProng" .. index, Vector3.new(0.10, 0.16, 0.84), CFrame.new(x, 0.06, -3.34), accent, Enum.Material.Neon)
    end
    detailWedge(model, "RailGrip", Vector3.new(0.40, 0.92, 0.48), CFrame.new(0, -0.67, 1.03) * CFrame.Angles(0, 0, math.rad(180)), BLACK)
    detailPart(model, "CellCageL", Vector3.new(0.08, 0.76, 0.78), CFrame.new(-0.31, -0.58, 0.35), STEEL)
    detailPart(model, "CellCageR", Vector3.new(0.08, 0.76, 0.78), CFrame.new(0.31, -0.58, 0.35), STEEL)
    detailCylinder(model, "ScopeTube", Vector3.new(0.42, 1.14, 0.42), CFrame.new(0, 0.58, 0.30) * CFrame.Angles(math.rad(90), 0, 0), BLACK)
    local frontLens = detailCylinder(model, "ScopeLens", Vector3.new(0.34, 0.03, 0.34), CFrame.new(0, 0.58, -0.28) * CFrame.Angles(math.rad(90), 0, 0), GLASS, Enum.Material.Glass)
    if frontLens then
        frontLens.Transparency = 0.2
    end
    local core = detailPart(model, "ChargeCore", Vector3.new(0.20, 0.20, 0.58), CFrame.new(0, 0.04, -2.78), accent, Enum.Material.Neon)
    pointLight(core, accent, 0.9, 5)
    for index, z in ipairs({ 1.22, 1.58, 1.94 }) do
        detailPart(model, "StockFin" .. index, Vector3.new(0.54, 0.07, 0.18), CFrame.new(0, 0.27, z), index == 2 and accent or STEEL, index == 2 and Enum.Material.Neon or Enum.Material.Metal)
    end
end

local function decorate(model)
    if not model or not model.PrimaryPart then
        return
    end
    clearDetails(model)
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
    decoratedModel = model
    rebuildRequested = false
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and payload then
        currentArchetype = payload.Archetype or "Carbine"
        rebuildRequested = true
        task.delay(0.08, function()
            rebuildRequested = true
        end)
    end
end)

RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    local model = camera and camera:FindFirstChild("BreachWeaponViewmodel")
    if model ~= decoratedModel then
        rebuildRequested = true
    end
    if rebuildRequested and model and model:IsA("Model") and model.PrimaryPart then
        decorate(model)
    end
end)
