local Workspace = game:GetService("Workspace")

local world = Workspace:WaitForChild("VaultfallWorld", 20)
if not world then
    warn("[Vaultfall SafehouseUX] world unavailable; UX finish skipped")
    return
end

local safehouse = world:FindFirstChild("Safehouse")
if not safehouse then
    warn("[Vaultfall SafehouseUX] safehouse unavailable; UX finish skipped")
    return
end

local previous = world:FindFirstChild("SafehouseUXFinish")
if previous then
    previous:Destroy()
end

local root = Instance.new("Folder")
root.Name = "SafehouseUXFinish"
root.Parent = world

local ORIGIN = Vector3.new(-220, 0, -120)
local palette = {
    dark = Color3.fromRGB(35, 41, 46),
    metal = Color3.fromRGB(69, 76, 82),
    text = Color3.fromRGB(226, 235, 238),
    cyan = Color3.fromRGB(88, 171, 190),
    amber = Color3.fromRGB(221, 166, 91),
    green = Color3.fromRGB(103, 176, 143),
    warm = Color3.fromRGB(231, 210, 177),
    storage = Color3.fromRGB(202, 145, 65),
}

local function part(parent, name, size, cframe, material, color, transparency)
    local item = Instance.new("Part")
    item.Name = name
    item.Size = size
    item.CFrame = cframe
    item.Anchored = true
    item.CanCollide = false
    item.CanTouch = false
    item.CanQuery = false
    item.CastShadow = false
    item.TopSurface = Enum.SurfaceType.Smooth
    item.BottomSurface = Enum.SurfaceType.Smooth
    item.Material = material or Enum.Material.Metal
    item.Color = color or palette.metal
    item.Transparency = transparency or 0
    item.Parent = parent
    return item
end

local function surfaceLabel(host, text, color, face, textSize)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "UXLabel"
    gui.Face = face or Enum.NormalId.Front
    gui.AlwaysOnTop = false
    gui.PixelsPerStud = 34
    gui.Parent = host

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextColor3 = color or palette.text
    label.TextStrokeTransparency = 0.82
    if textSize then
        label.TextScaled = false
        label.TextSize = textSize
    else
        label.TextScaled = true
    end
    label.Parent = gui
    return label
end

local function pointLight(host, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Name = "UXLight"
    light.Color = color
    light.Brightness = brightness or 0.25
    light.Range = range or 9
    light.Shadows = false
    light.Parent = host
end

local function hangingSign(parent, name, position, title, subtitle, accent, yaw)
    local group = Instance.new("Folder")
    group.Name = name
    group.Parent = parent

    local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
    part(group, "SignBracketLeft", Vector3.new(0.35, 2.8, 0.35), cf * CFrame.new(-7.6, 2, 0), Enum.Material.Metal, palette.dark)
    part(group, "SignBracketRight", Vector3.new(0.35, 2.8, 0.35), cf * CFrame.new(7.6, 2, 0), Enum.Material.Metal, palette.dark)
    local panel = part(group, "SignPanel", Vector3.new(16.5, 4.6, 0.55), cf, Enum.Material.Metal, palette.dark)
    local edge = part(group, "SignAccent", Vector3.new(16.7, 0.28, 0.16), cf * CFrame.new(0, -2.35, -0.36), Enum.Material.Neon, accent, 0.12)
    pointLight(edge, accent, 0.18, 8)
    surfaceLabel(panel, title .. "\n" .. subtitle, palette.text, Enum.NormalId.Front)
end

local function breadcrumb(parent, position, size, accent, yaw)
    local marker = part(
        parent,
        "RouteBreadcrumb",
        size,
        CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0),
        Enum.Material.Neon,
        accent,
        0.48
    )
    pointLight(marker, accent, 0.12, 6)
end

local facilities = Instance.new("Folder")
facilities.Name = "FacilityWayfinding"
facilities.Parent = root

hangingSign(facilities, "ArmoryWayfinding", ORIGIN + Vector3.new(-58, 12.2, -21), "ARMORY", "LOADOUT  •  WEAPONS", palette.cyan, 0)
hangingSign(facilities, "OperationsWayfinding", ORIGIN + Vector3.new(58, 12.2, -21), "OPERATIONS", "CONTRACTS  •  DEPLOY", palette.amber, 0)
hangingSign(facilities, "SystemsWayfinding", ORIGIN + Vector3.new(-57, 12.2, 34), "SYSTEMS LAB", "UPGRADES  •  CALIBRATION", palette.green, 180)
hangingSign(facilities, "RangeWayfinding", ORIGIN + Vector3.new(58, 12.2, 34), "FIRING RANGE", "AIM  •  RECOIL  •  RELOAD", palette.warm, 180)
hangingSign(facilities, "StorageWayfinding", ORIGIN + Vector3.new(-25, 12.2, 63), "FIELD STORAGE", "RECOVERED ASSETS", palette.storage, 180)
hangingSign(facilities, "DeployWayfinding", ORIGIN + Vector3.new(22, 12.2, 63), "DEPLOYMENT", "CONTRACT READY AREA", palette.amber, 180)

for _, entry in ipairs({
    { ORIGIN + Vector3.new(-34, 1.06, -9), Vector3.new(18, 0.1, 0.7), palette.cyan, 0 },
    { ORIGIN + Vector3.new(34, 1.06, -9), Vector3.new(18, 0.1, 0.7), palette.amber, 0 },
    { ORIGIN + Vector3.new(-36, 1.06, 30), Vector3.new(18, 0.1, 0.7), palette.green, 0 },
    { ORIGIN + Vector3.new(36, 1.06, 30), Vector3.new(18, 0.1, 0.7), palette.warm, 0 },
    { ORIGIN + Vector3.new(0, 1.06, 50), Vector3.new(0.7, 0.1, 20), palette.amber, 0 },
}) do
    breadcrumb(facilities, entry[1], entry[2], entry[3], entry[4])
end

local range = Instance.new("Folder")
range.Name = "FiringRangeUX"
range.Parent = root

local RANGE_CENTER = ORIGIN + Vector3.new(78, 0, 48)
local firingLineZ = RANGE_CENTER.Z - 10

local rangeHeader = part(
    range,
    "RangeInstructionBoard",
    Vector3.new(42, 7, 0.65),
    CFrame.new(RANGE_CENTER + Vector3.new(0, 9.5, -28)),
    Enum.Material.Metal,
    palette.dark
)
surfaceLabel(
    rangeHeader,
    "LIVE WEAPON TEST BAY\nLMB FIRE   •   RMB ADS   •   R RELOAD   •   Q DASH",
    palette.text,
    Enum.NormalId.Front
)
local headerEdge = part(range, "RangeInstructionEdge", Vector3.new(42.4, 0.28, 0.16), rangeHeader.CFrame * CFrame.new(0, -3.6, -0.4), Enum.Material.Neon, palette.warm, 0.12)
pointLight(headerEdge, palette.warm, 0.22, 10)

local laneData = {
    { -27, "SMG", "TRACK / BURST", palette.cyan },
    { -9, "CARBINE", "CONTROL / ADS", palette.green },
    { 9, "SHOTGUN", "BURST / RECOVERY", palette.amber },
    { 27, "RAIL RIFLE", "PRECISION / TIMING", palette.warm },
}

for _, lane in ipairs(laneData) do
    local x = lane[1]
    local accent = lane[4]
    local divider = part(
        range,
        lane[2] .. "LaneRail",
        Vector3.new(0.22, 0.12, 52),
        CFrame.new(RANGE_CENTER + Vector3.new(x, 1.08, 14)),
        Enum.Material.Neon,
        accent,
        0.62
    )
    pointLight(divider, accent, 0.08, 5)

    local plate = part(
        range,
        lane[2] .. "LanePlate",
        Vector3.new(14.5, 2.8, 0.48),
        CFrame.new(Vector3.new(RANGE_CENTER.X + x, 4.4, firingLineZ - 2.8)),
        Enum.Material.Metal,
        palette.dark
    )
    surfaceLabel(plate, lane[2] .. "\n" .. lane[3], accent, Enum.NormalId.Front)
end

for _, studs in ipairs({ 20, 40, 60 }) do
    local z = firingLineZ + studs
    local tick = part(
        range,
        "Distance" .. tostring(studs),
        Vector3.new(69, 0.1, 0.32),
        CFrame.new(Vector3.new(RANGE_CENTER.X, 1.1, z)),
        Enum.Material.Neon,
        studs == 60 and palette.warm or palette.text,
        0.7
    )
    local distancePlate = part(
        range,
        "DistancePlate" .. tostring(studs),
        Vector3.new(7.2, 2.2, 0.4),
        CFrame.new(Vector3.new(RANGE_CENTER.X - 35, 2.8, z)),
        Enum.Material.Metal,
        palette.dark
    )
    surfaceLabel(distancePlate, tostring(studs) .. " STUDS", palette.text, Enum.NormalId.Front)
    tick:SetAttribute("RangeDistance", studs)
end

local function decorateTarget(target)
    if target:GetAttribute("UXRangeTarget") then
        return
    end
    target:SetAttribute("UXRangeTarget", true)

    local horizontal = Vector3.new(target.Position.X - RANGE_CENTER.X, 0, target.Position.Z - firingLineZ)
    local distance = math.floor(horizontal.Magnitude + 0.5)

    local gui = Instance.new("BillboardGui")
    gui.Name = "TargetDistanceReadout"
    gui.Size = UDim2.fromOffset(120, 28)
    gui.StudsOffset = Vector3.new(0, target.Size.Y * 0.5 + 1.6, 0)
    gui.AlwaysOnTop = false
    gui.MaxDistance = 90
    gui.Adornee = target
    gui.Parent = target

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 0.32
    label.BackgroundColor3 = palette.dark
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.GothamBold
    label.Text = tostring(distance) .. " STUDS"
    label.TextSize = 14
    label.TextColor3 = palette.text
    label.TextStrokeTransparency = 0.9
    label.Parent = gui
end

for _, item in ipairs(safehouse:GetDescendants()) do
    if item:IsA("BasePart") and item.Name == "Target" then
        decorateTarget(item)
    end
end

safehouse.DescendantAdded:Connect(function(item)
    if item:IsA("BasePart") and item.Name == "Target" then
        decorateTarget(item)
    end
end)

root:SetAttribute("ReadableFacilities", 6)
root:SetAttribute("RangeIdentityLanes", 4)
root:SetAttribute("CanonicalReloadInput", "R")
root:SetAttribute("SelfContained", true)
