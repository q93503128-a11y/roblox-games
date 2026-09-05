local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local ROOT_NAME = "VaultfallClientLighting"
local old = Lighting:FindFirstChild(ROOT_NAME)
if old then
    old:Destroy()
end

local root = Instance.new("Folder")
root.Name = ROOT_NAME
root.Parent = Lighting

local color = Instance.new("ColorCorrectionEffect")
color.Name = "VaultfallColorGrade"
color.Brightness = -0.015
color.Contrast = 0.14
color.Saturation = -0.08
color.TintColor = Color3.fromRGB(222, 233, 236)
color.Parent = root

local bloom = Instance.new("BloomEffect")
bloom.Name = "VaultfallBloom"
bloom.Intensity = 0.34
bloom.Size = 22
bloom.Threshold = 1.12
bloom.Parent = root

local rays = Instance.new("SunRaysEffect")
rays.Name = "VaultfallRays"
rays.Intensity = 0.018
rays.Spread = 0.42
rays.Parent = root

local depth = Instance.new("DepthOfFieldEffect")
depth.Name = "VaultfallDepth"
depth.FarIntensity = 0.03
depth.FocusDistance = 38
depth.InFocusRadius = 27
depth.NearIntensity = 0
ndepth = depth
ndepth.Parent = root

local atmosphere = Lighting:FindFirstChild("VaultfallAtmosphere")
if atmosphere and not atmosphere:IsA("Atmosphere") then
    atmosphere:Destroy()
    atmosphere = nil
end
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Name = "VaultfallAtmosphere"
    atmosphere.Parent = Lighting
end
atmosphere.Color = Color3.fromRGB(172, 188, 194)
atmosphere.Decay = Color3.fromRGB(57, 66, 72)
atmosphere.Density = 0.235
atmosphere.Glare = 0.08
atmosphere.Haze = 1.45
atmosphere.Offset = 0.12

local runActive = false
local pressure = false
local lastRoom = 0
local pulse = 0

local HUB = {
    Brightness = 1.85,
    ClockTime = 18.7,
    Ambient = Color3.fromRGB(64, 70, 76),
    OutdoorAmbient = Color3.fromRGB(74, 81, 86),
    FogColor = Color3.fromRGB(65, 76, 83),
    FogEnd = 720,
    Tint = Color3.fromRGB(225, 236, 238),
    Contrast = 0.13,
    Saturation = -0.07,
    Bloom = 0.30,
    Haze = 1.20,
}

local FIELD = {
    Brightness = 1.42,
    ClockTime = 1.25,
    Ambient = Color3.fromRGB(41, 45, 51),
    OutdoorAmbient = Color3.fromRGB(49, 54, 60),
    FogColor = Color3.fromRGB(42, 50, 56),
    FogEnd = 430,
    Tint = Color3.fromRGB(205, 223, 227),
    Contrast = 0.19,
    Saturation = -0.13,
    Bloom = 0.38,
    Haze = 1.78,
}

local PRESSURE = {
    Brightness = 1.28,
    ClockTime = 0.75,
    Ambient = Color3.fromRGB(48, 38, 42),
    OutdoorAmbient = Color3.fromRGB(54, 42, 46),
    FogColor = Color3.fromRGB(64, 44, 47),
    FogEnd = 360,
    Tint = Color3.fromRGB(228, 199, 196),
    Contrast = 0.23,
    Saturation = -0.08,
    Bloom = 0.46,
    Haze = 2.05,
}

local function tween(instance, duration, properties)
    TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

local function applyPreset(preset, duration)
    local t = duration or 0.8
    tween(Lighting, t, {
        Brightness = preset.Brightness,
        ClockTime = preset.ClockTime,
        Ambient = preset.Ambient,
        OutdoorAmbient = preset.OutdoorAmbient,
        FogColor = preset.FogColor,
        FogEnd = preset.FogEnd,
    })
    tween(color, t, {
        TintColor = preset.Tint,
        Contrast = preset.Contrast,
        Saturation = preset.Saturation,
    })
    tween(bloom, t, { Intensity = preset.Bloom })
    tween(atmosphere, t, { Haze = preset.Haze })
end

local function refreshPreset(duration)
    if pressure then
        applyPreset(PRESSURE, duration)
    elseif runActive then
        applyPreset(FIELD, duration)
    else
        applyPreset(HUB, duration)
    end
end

local function roomPulse(roomIndex)
    if roomIndex == lastRoom or roomIndex <= 0 then
        return
    end
    lastRoom = roomIndex
    pulse = 1
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Run" and payload then
        runActive = payload.Active == true
        if not runActive then
            pressure = false
            lastRoom = 0
        end
        refreshPreset(0.9)
    elseif kind == "Room" and payload then
        local roomIndex = tonumber(payload.Index or payload.Room or payload.CurrentRoom) or 0
        roomPulse(roomIndex)
    elseif kind == "PressureOverride" or kind == "Pressure" then
        if type(payload) == "table" then
            pressure = payload.Active == true or payload.Enabled == true
        else
            pressure = payload == true
        end
        refreshPreset(0.55)
    elseif kind == "Notice" and type(payload) == "string" then
        local upper = string.upper(payload)
        if string.find(upper, "PRESSURE", 1, true) and string.find(upper, "OVERRIDE", 1, true) then
            pressure = true
            refreshPreset(0.45)
        elseif string.find(upper, "EXTRACT", 1, true) or string.find(upper, "CLEARED", 1, true) then
            pulse = math.max(pulse, 0.75)
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if pulse <= 0.001 then
        return
    end

    pulse *= math.exp(-dt * 4.8)
    local flash = math.clamp(pulse, 0, 1)
    color.Brightness = -0.015 + flash * 0.045
    bloom.Intensity = (pressure and PRESSURE.Bloom or (runActive and FIELD.Bloom or HUB.Bloom)) + flash * 0.22
end)

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    depth.Enabled = Workspace.CurrentCamera ~= nil
end)

refreshPreset(0)
