-- Monster Factory external visual intake helper.
--
-- Run this ONLY from Roblox Studio's Command Bar when a grouped art-intake
-- session is intentionally being performed. This file is outside the Rojo
-- source tree and never executes in a live game.
--
-- Before running, acquire the listed free Creator Store models on the same
-- Roblox account if InsertService requires ownership.

local InsertService = game:GetService("InsertService")
local ServerStorage = game:GetService("ServerStorage")

local ASSETS = {
    {
        Id = 7436760067,
        Key = "EnvironmentPrimary",
        Name = "Low Poly Asset Pack",
    },
    {
        Id = 130347426228193,
        Key = "InterfacePrimary",
        Name = "GUI Asset Pack",
    },
}

local staging = ServerStorage:FindFirstChild("MonsterFactoryExternalAssetStaging")
if staging then
    staging:Destroy()
end

staging = Instance.new("Folder")
staging.Name = "MonsterFactoryExternalAssetStaging"
staging.Parent = ServerStorage

local REMOVE_CLASSES = {
    RemoteEvent = true,
    RemoteFunction = true,
    BindableEvent = true,
    BindableFunction = true,
    Tool = true,
    ClickDetector = true,
    ProximityPrompt = true,
    Humanoid = true,
    AnimationController = true,
}

local function sanitize(root)
    local stats = {
        ScriptsRemoved = 0,
        InteractiveRemoved = 0,
        Parts = 0,
        Guis = 0,
    }

    for _, instance in ipairs(root:GetDescendants()) do
        if instance:IsA("LuaSourceContainer") then
            stats.ScriptsRemoved += 1
            instance:Destroy()
        elseif REMOVE_CLASSES[instance.ClassName] then
            stats.InteractiveRemoved += 1
            instance:Destroy()
        elseif instance:IsA("BasePart") then
            stats.Parts += 1
            instance.Anchored = true
            instance.CanCollide = false
            instance.CanTouch = false
        elseif instance:IsA("GuiObject") then
            stats.Guis += 1
        end
    end

    return stats
end

for _, asset in ipairs(ASSETS) do
    local ok, container = pcall(function()
        return InsertService:LoadAsset(asset.Id)
    end)

    if not ok or not container then
        warn(string.format(
            "[MonsterFactory Intake] Could not load %s (%d): %s",
            asset.Name,
            asset.Id,
            tostring(container)
        ))
        continue
    end

    container.Name = string.format("%s__%d", asset.Key, asset.Id)
    container:SetAttribute("MFSourceAssetId", asset.Id)
    container:SetAttribute("MFSourceName", asset.Name)
    container:SetAttribute("MFIntakeSanitized", true)

    local stats = sanitize(container)
    container.Parent = staging

    print(string.format(
        "[MonsterFactory Intake] %s (%d): scripts=%d interactive=%d parts=%d guis=%d",
        asset.Name,
        asset.Id,
        stats.ScriptsRemoved,
        stats.InteractiveRemoved,
        stats.Parts,
        stats.Guis
    ))
end

print("[MonsterFactory Intake] Sanitized candidates are staged in ServerStorage/MonsterFactoryExternalAssetStaging.")
print("[MonsterFactory Intake] Do NOT keep the entire packs. Retain only reviewed visual descendants needed by the game.")
