local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Config = require(shared:WaitForChild("Config"))
local world = Workspace:WaitForChild("VaultfallWorld", 20)
if not world then
    warn("[Vaultfall Visibility] world unavailable; fill lighting skipped")
    return
end

local old = world:FindFirstChild("VisibilityFill")
if old then
    old:Destroy()
end

local folder = Instance.new("Folder")
folder.Name = "VisibilityFill"
folder.Parent = world

local function fillLight(name, position, color, brightness, range)
    local host = Instance.new("Part")
    host.Name = name
    host.Size = Vector3.new(0.4, 0.4, 0.4)
    host.Position = position
    host.Transparency = 1
    host.Anchored = true
    host.CanCollide = false
    host.CanTouch = false
    host.CanQuery = false
    host.CastShadow = false
    host.Parent = folder

    local light = Instance.new("PointLight")
    light.Name = "GameplayFill"
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Shadows = false
    light.Parent = host
end

local neutral = Color3.fromRGB(218, 232, 236)
local warm = Color3.fromRGB(239, 224, 202)
local safehouseOrigin = Vector3.new(-220, 0, -120)

-- Broad neutral fill keeps the safehouse readable between the authored cyan
-- accent fixtures. These lights are intentionally shadowless: they expose
-- geometry rather than trying to be decorative fixtures themselves.
for _, offset in ipairs({
    Vector3.new(-82, 13, -62),
    Vector3.new(0, 14, -62),
    Vector3.new(82, 13, -62),
    Vector3.new(-82, 13, 18),
    Vector3.new(0, 14, 18),
    Vector3.new(82, 13, 18),
    Vector3.new(-58, 13, 76),
    Vector3.new(0, 14, 76),
    Vector3.new(58, 13, 76),
}) do
    fillLight("SafehouseFill", safehouseOrigin + offset, neutral, 2.5, 66)
end

-- Give the firing range slightly warmer fill so targets do not disappear into
-- the same dark values as the back wall.
for _, offset in ipairs({ Vector3.new(-24, 12, 52), Vector3.new(24, 12, 52) }) do
    fillLight("RangeFill", safehouseOrigin + Vector3.new(78, 0, 48) + offset, warm, 2.6, 58)
end

local dungeonOffset = Vector3.new(100, 0, 0)
for index, gridPosition in ipairs(Config.RoomPath) do
    local origin = dungeonOffset + (gridPosition * Config.RoomSpacing)
    local accent = index % 3 == 0 and Color3.fromRGB(226, 217, 204) or neutral
    fillLight(string.format("Sector%02dCenterFill", index), origin + Vector3.new(0, 14, 0), accent, 2.35, 58)
    fillLight(string.format("Sector%02dLeftFill", index), origin + Vector3.new(-30, 11, 22), neutral, 1.45, 42)
    fillLight(string.format("Sector%02dRightFill", index), origin + Vector3.new(30, 11, -22), neutral, 1.45, 42)
end

print("[Vaultfall Visibility] gameplay fill lighting ready")
