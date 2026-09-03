local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local visualRoot = ReplicatedStorage:WaitForChild("VaultfallVisuals", 10)
local weaponFolder = visualRoot and visualRoot:FindFirstChild("Weapons")
if not weaponFolder or #weaponFolder:GetChildren() == 0 then
    return
end

local archetypeOrder = {
    Carbine = 1,
    SMG = 2,
    Shotgun = 3,
    RailRifle = 4,
}

local targetLengths = {
    Carbine = 4.6,
    SMG = 3.5,
    Shotgun = 5.0,
    RailRifle = 5.7,
}

local candidates = weaponFolder:GetChildren()
table.sort(candidates, function(a, b)
    return a.Name < b.Name
end)

local currentArchetype = "Carbine"
local currentModel = nil

local function hasGeometry(instance)
    if instance:IsA("BasePart") then
        return true
    end
    return instance:FindFirstChildWhichIsA("BasePart", true) ~= nil
end

local function makeSafe(instance)
    if instance:IsA("BasePart") then
        instance.Anchored = true
        instance.CanCollide = false
        instance.CanTouch = false
        instance.CanQuery = false
        instance.CastShadow = false
    end
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
            descendant.CastShadow = false
        elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
            descendant:Destroy()
        end
    end
end

local function asModel(source)
    local clone = source:Clone()
    makeSafe(clone)

    if clone:IsA("Model") then
        return clone
    end

    if clone:IsA("BasePart") then
        local wrapper = Instance.new("Model")
        wrapper.Name = "ExternalVisual"
        clone.Parent = wrapper
        wrapper.PrimaryPart = clone
        return wrapper
    end

    clone:Destroy()
    return nil
end

local function hideProceduralShell(model)
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("BasePart") and child.Name ~= "Muzzle" then
            child.Transparency = 1
        end
    end
end

local function chooseCandidate(archetype)
    if #candidates == 0 then
        return nil
    end
    local preferred = archetypeOrder[archetype] or 1
    local index = ((preferred - 1) % #candidates) + 1
    local candidate = candidates[index]
    if hasGeometry(candidate) then
        return candidate
    end
    for _, fallback in ipairs(candidates) do
        if hasGeometry(fallback) then
            return fallback
        end
    end
    return nil
end

local function orientToWeaponAxis(size)
    if size.X >= size.Y and size.X >= size.Z then
        return CFrame.Angles(0, math.rad(90), 0)
    elseif size.Y >= size.X and size.Y >= size.Z then
        return CFrame.Angles(math.rad(90), 0, 0)
    end
    return CFrame.new()
end

local function attachExternalVisual(model, archetype)
    if not model or not model.PrimaryPart then
        return false
    end

    local old = model:FindFirstChild("ExternalVisual")
    if old then
        old:Destroy()
    end

    local source = chooseCandidate(archetype)
    if not source then
        return false
    end

    local clone = asModel(source)
    if not clone then
        return false
    end
    clone.Name = "ExternalVisual"
    clone:SetAttribute("Archetype", archetype)
    clone:SetAttribute("SourceName", source:GetAttribute("SourceName") or source.Name)
    clone.Parent = model

    local ok, _, initialSize = pcall(function()
        return clone:GetBoundingBox()
    end)
    if not ok or not initialSize then
        clone:Destroy()
        return false
    end

    local longest = math.max(initialSize.X, initialSize.Y, initialSize.Z)
    if longest < 0.05 then
        clone:Destroy()
        return false
    end

    local targetLength = targetLengths[archetype] or targetLengths.Carbine
    pcall(function()
        clone:ScaleTo(targetLength / longest)
    end)

    local _, scaledSize = clone:GetBoundingBox()
    local rotation = orientToWeaponAxis(scaledSize)
    local receiver = model.PrimaryPart
    local verticalOffset = archetype == "RailRifle" and 0.02 or -0.02
    clone:PivotTo(receiver.CFrame * CFrame.new(0, verticalOffset, -0.25) * rotation)

    hideProceduralShell(model)
    return true
end

local function inferArchetype(model)
    if model:FindFirstChild("RailTop") or model:FindFirstChild("Cell") then
        return "RailRifle"
    elseif model:FindFirstChild("Pump") or model:FindFirstChild("Tube") then
        return "Shotgun"
    elseif model:FindFirstChild("Shroud") and not model:FindFirstChild("Handguard") then
        return "SMG"
    end
    return currentArchetype
end

local function refresh()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local model = camera:FindFirstChild("BreachWeaponViewmodel")
    if model ~= currentModel then
        currentModel = model
        if model and model:IsA("Model") then
            currentArchetype = inferArchetype(model)
            task.defer(function()
                if model.Parent and not attachExternalVisual(model, currentArchetype) then
                    warn("[Vaultfall Visuals] installed WeaponPack had no usable first-person candidate")
                end
            end)
        end
    end
end

RunService.RenderStepped:Connect(refresh)
