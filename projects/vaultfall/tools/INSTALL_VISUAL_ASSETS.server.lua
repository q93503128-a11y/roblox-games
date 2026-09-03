-- Vaultfall visual asset installer.
-- Run this once in Roblox Studio after adding the listed free Creator Store models to your inventory.
-- This script intentionally removes all executable scripts from imported assets.

local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

assert(RunService:IsStudio(), "Vaultfall asset installer is Studio-only")

local manifest = {
    -- Established 95%-rated pack with modular dungeon pieces and a complete sample dungeon build.
    DungeonKit = 9492405836,
    WeaponPack = 17351010368,
    MonsterPack = 14483015744,
    NaturePack = 79195618410265,
}

local root = ServerStorage:FindFirstChild("VaultfallAssets")
if root then
    root:Destroy()
end
root = Instance.new("Folder")
root.Name = "VaultfallAssets"
root.Parent = ServerStorage

local function sanitize(instance)
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

local successes = 0
for packName, assetId in pairs(manifest) do
    local packFolder = Instance.new("Folder")
    packFolder.Name = packName
    packFolder:SetAttribute("SourceAssetId", assetId)
    packFolder.Parent = root

    local ok, containerOrError = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)

    if not ok then
        warn(string.format("[Vaultfall Installer] %s failed (%d): %s", packName, assetId, tostring(containerOrError)))
        packFolder:SetAttribute("InstallFailed", true)
    else
        local container = containerOrError
        sanitize(container)
        local children = container:GetChildren()
        for _, child in ipairs(children) do
            child.Parent = packFolder
        end
        container:Destroy()
        successes += 1
        print(string.format("[Vaultfall Installer] installed %s (%d), %d top-level object(s)", packName, assetId, #children))
    end
end

print(string.format("[Vaultfall Installer] finished: %d/%d packs installed into ServerStorage/VaultfallAssets", successes, 4))
print("[Vaultfall Installer] Save the place after installation. Imported third-party scripts were removed.")
