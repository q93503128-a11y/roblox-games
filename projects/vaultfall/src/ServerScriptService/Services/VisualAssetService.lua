local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local VisualAssetService = {}

local MAX_WEAPON_CANDIDATES = 16
local MAX_DESCENDANTS = 320

local function destroyUnsafe(instance)
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("Script")
            or descendant:IsA("LocalScript")
            or descendant:IsA("ModuleScript")
            or descendant:IsA("RemoteEvent")
            or descendant:IsA("RemoteFunction")
            or descendant:IsA("ClickDetector")
            or descendant:IsA("ProximityPrompt") then
            descendant:Destroy()
        end
    end
end

local function hasVisualGeometry(instance)
    if instance:IsA("BasePart") then
        return true
    end
    return instance:FindFirstChildWhichIsA("BasePart", true) ~= nil
end

local function normalizeClientVisual(instance)
    destroyUnsafe(instance)
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
            descendant.CanCollide = false
            descendant.CanTouch = false
            descendant.CanQuery = false
            descendant.CastShadow = false
            descendant.Massless = true
        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
            descendant.Enabled = false
        end
    end
    if instance:IsA("BasePart") then
        instance.Anchored = true
        instance.CanCollide = false
        instance.CanTouch = false
        instance.CanQuery = false
        instance.CastShadow = false
        instance.Massless = true
    end
end

local function isLeafVisualModel(model)
    if not model:IsA("Model") or not hasVisualGeometry(model) then
        return false
    end
    if #model:GetDescendants() > MAX_DESCENDANTS then
        return false
    end

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("Model") and descendant ~= model and hasVisualGeometry(descendant) then
            return false
        end
    end
    return true
end

local function collectCandidates(pack)
    local candidates = {}

    -- Weapon packs are frequently wrapped in one top-level Model. Prefer the
    -- individual leaf models instead of accidentally publishing the entire pack
    -- as a single first-person weapon.
    for _, descendant in ipairs(pack:GetDescendants()) do
        if isLeafVisualModel(descendant) then
            table.insert(candidates, descendant)
        end
    end

    if #candidates == 0 then
        for _, child in ipairs(pack:GetChildren()) do
            if child:IsA("BasePart") and hasVisualGeometry(child) then
                table.insert(candidates, child)
            end
        end
    end

    if #candidates == 0 then
        for _, descendant in ipairs(pack:GetDescendants()) do
            if (descendant:IsA("MeshPart") or descendant:IsA("UnionOperation")) and hasVisualGeometry(descendant) then
                table.insert(candidates, descendant)
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a:GetFullName() < b:GetFullName()
    end)
    return candidates
end

local function publishWeapons(sourcePack, destination)
    local candidates = collectCandidates(sourcePack)
    local count = math.min(#candidates, MAX_WEAPON_CANDIDATES)

    for index = 1, count do
        local source = candidates[index]
        local clone = source:Clone()
        clone.Name = string.format("WeaponVisual_%02d", index)
        clone:SetAttribute("SourceName", source.Name)
        normalizeClientVisual(clone)
        clone.Parent = destination
    end

    destination:SetAttribute("CandidateCount", count)
    return count
end

function VisualAssetService.Init()
    local previous = ReplicatedStorage:FindFirstChild("VaultfallVisuals")
    if previous then
        previous:Destroy()
    end

    local published = Instance.new("Folder")
    published.Name = "VaultfallVisuals"
    published.Parent = ReplicatedStorage

    local weapons = Instance.new("Folder")
    weapons.Name = "Weapons"
    weapons.Parent = published

    local sourceRoot = ServerStorage:FindFirstChild("VaultfallAssets")
    local weaponPack = sourceRoot and sourceRoot:FindFirstChild("WeaponPack")
    if weaponPack then
        local count = publishWeapons(weaponPack, weapons)
        published:SetAttribute("ExternalWeaponsReady", count > 0)
        print(string.format("[Vaultfall Visuals] published %d sanitized weapon visual candidate(s)", count))
    else
        published:SetAttribute("ExternalWeaponsReady", false)
        print("[Vaultfall Visuals] no installed WeaponPack; procedural weapon fallback remains active")
    end

    return published
end

return VisualAssetService
