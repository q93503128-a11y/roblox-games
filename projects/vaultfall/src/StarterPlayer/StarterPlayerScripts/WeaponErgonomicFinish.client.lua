local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Arsenal = require(shared:WaitForChild("Arsenal"))
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local currentDefinition = Arsenal.Get(currentArchetype)
local trackedModel = nil
local upperOccluders = {}
local externalParts = {}
local accentParts = {}

-- These parts add useful silhouette when hip-fired but are the pieces most likely to
-- crowd the sightline when the weapon is shouldered. The actual front references stay
-- fully visible so ADS still has a readable weapon orientation.
local adsOccluderTokens = {
    Carbine = { "TopRail", "OpticBody", "CheekRest", "GasBlock" },
    SMG = { "TopRail", "MicroSight", "ChargingHandle", "StockStrut" },
    Shotgun = { "ReceiverRail", "StockComb", "ShellSaddle", "PumpRib" },
    RailRifle = { "ScopeTube", "StockFin", "CellCage", "RailSpine" },
}

local function containsToken(name, tokens)
    for _, token in ipairs(tokens) do
        if string.find(name, token, 1, true) then
            return true
        end
    end
    return false
end

local function refreshModel(model)
    if trackedModel == model then
        return
    end

    trackedModel = model
    table.clear(upperOccluders)
    table.clear(externalParts)
    table.clear(accentParts)

    if not model then
        return
    end

    local tokens = adsOccluderTokens[currentArchetype] or adsOccluderTokens.Carbine
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            local name = descendant.Name
            if containsToken(name, tokens) then
                table.insert(upperOccluders, descendant)
            end
            if descendant:FindFirstAncestor("ExternalVisual") then
                table.insert(externalParts, descendant)
            end
            if string.sub(name, 1, 17) == "ProductionDetail_" and descendant.Material == Enum.Material.Neon then
                table.insert(accentParts, descendant)
            end
        end
    end

    local accent = (currentDefinition and currentDefinition.Accent) or Color3.fromRGB(100, 160, 180)
    for _, part in ipairs(accentParts) do
        if part.Parent then
            part.Color = accent
        end
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and payload then
        currentArchetype = payload.Archetype or "Carbine"
        currentDefinition = Arsenal.Get(currentArchetype) or Arsenal.Get("Carbine")
        trackedModel = nil
    end
end)

RunService:BindToRenderStep("BreachWeaponErgonomicFinish", Enum.RenderPriority.Last.Value, function()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local model = camera:FindFirstChild("BreachWeaponViewmodel")
    if model ~= trackedModel then
        refreshModel(model)
    end
    if not model then
        return
    end

    local aiming = player:GetAttribute("VaultfallADS") == true
    if not aiming then
        return
    end

    local nearWall = tonumber(player:GetAttribute("VaultfallNearWall")) or 0
    local baseFade = math.clamp((nearWall - 0.58) / 0.42, 0, 1) * 0.84

    -- Keep authored silhouette at the hip, but make the high-profile furniture recede
    -- when ADS is held. This prevents rails/scopes/stocks from becoming an opaque slab
    -- across the target without making the whole gun disappear.
    for index = #upperOccluders, 1, -1 do
        local part = upperOccluders[index]
        if not part.Parent then
            table.remove(upperOccluders, index)
        else
            part.LocalTransparencyModifier = math.max(baseFade, 0.46)
        end
    end

    -- Imported weapon packs can have arbitrary proportions. A small ADS-only fade is
    -- a safety net so even a bulky optional mesh cannot recreate the original problem
    -- where aiming hid the enemy. The self-contained procedural gun remains crisper.
    for index = #externalParts, 1, -1 do
        local part = externalParts[index]
        if not part.Parent then
            table.remove(externalParts, index)
        else
            part.LocalTransparencyModifier = math.max(part.LocalTransparencyModifier, baseFade, 0.14)
        end
    end
end)
