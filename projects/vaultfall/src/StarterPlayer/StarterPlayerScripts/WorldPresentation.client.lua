local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

-- The server-side polish layer already creates a dark cinematic grade. Disable
-- its duplicate post effects locally so the client presentation does not stack
-- two dark grades and crush visibility.
local serverColor = Lighting:FindFirstChild("VaultfallColor")
if serverColor and serverColor:IsA("ColorCorrectionEffect") then
    serverColor.Enabled = false
end
local serverBloom = Lighting:FindFirstChild("VaultfallBloom")
if serverBloom and serverBloom:IsA("BloomEffect") then
    serverBloom.Enabled = false
end

local root = Lighting:FindFirstChild("VaultfallClientLighting")
if root then
    root:Destroy()
end
root = Instance.new("Folder")
root.Name = "VaultfallClientLighting"
root.Parent = Lighting

local color = Instance.new("ColorCorrectionEffect")
color.Name = "VaultfallColorGrade"
color.Brightness = 0.04
color.Contrast = 0.05
color.Saturation = -0.02
color.TintColor = Color3.fromRGB(239, 245, 247)
color.Parent = root

local bloom = Instance.new("BloomEffect")
bloom.Name = "VaultfallBloom"
bloom.Intensity = 0.18
bloom.Size = 18
bloom.Threshold = 1.28
bloom.Parent = root

local rays = Instance.new("SunRaysEffect")
rays.Name = "VaultfallRays"
rays.Intensity = 0.01
rays.Spread = 0.35
rays.Parent = root

local depth = Instance.new("DepthOfFieldEffect")
depth.Name = "VaultfallDepth"
depth.FarIntensity = 0
depth.FocusDistance = 42
depth.InFocusRadius = 50
depth.NearIntensity = 0
depth.Parent = root

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
atmosphere.Color = Color3.fromRGB(204, 216, 220)
atmosphere.Decay = Color3.fromRGB(112, 124, 130)
atmosphere.Density = 0.09
atmosphere.Glare = 0.025
atmosphere.Haze = 0.35
atmosphere.Offset = 0.08

Lighting.ShadowSoftness = 0.38

local presets = {
    Hub = {
        Brightness = 3.0,
        Exposure = 0.22,
        ClockTime = 14.0,
        Ambient = Color3.fromRGB(118, 126, 132),
        OutdoorAmbient = Color3.fromRGB(136, 145, 151),
        FogColor = Color3.fromRGB(117, 128, 134),
        FogEnd = 1050,
        Tint = Color3.fromRGB(242, 247, 248),
        Contrast = 0.045,
        Saturation = -0.015,
        Bloom = 0.17,
        Haze = 0.24,
    },
    Field = {
        Brightness = 2.55,
        Exposure = 0.14,
        ClockTime = 14.5,
        Ambient = Color3.fromRGB(92, 101, 108),
        OutdoorAmbient = Color3.fromRGB(113, 122, 128),
        FogColor = Color3.fromRGB(99, 112, 119),
        FogEnd = 820,
        Tint = Color3.fromRGB(233, 242, 244),
        Contrast = 0.07,
        Saturation = -0.025,
        Bloom = 0.21,
        Haze = 0.42,
    },
    Pressure = {
        Brightness = 2.28,
        Exposure = 0.08,
        ClockTime = 15.0,
        Ambient = Color3.fromRGB(91, 82, 84),
        OutdoorAmbient = Color3.fromRGB(105, 94, 97),
        FogColor = Color3.fromRGB(107, 89, 92),
        FogEnd = 680,
        Tint = Color3.fromRGB(246, 228, 226),
        Contrast = 0.095,
        Saturation = -0.015,
        Bloom = 0.25,
        Haze = 0.62,
    },
}

local runActive = false
local pressure = false
local lastRoom = 0
local pulse = 0

local function tween(instance, duration, properties)
    TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties):Play()
end

local function selectedPreset()
    if pressure then
        return presets.Pressure
    elseif runActive then
        return presets.Field
    end
    return presets.Hub
end

local function applyPreset(duration)
    local preset = selectedPreset()
    local t = duration or 0.8
    tween(Lighting, t, {
        Brightness = preset.Brightness,
        ExposureCompensation = preset.Exposure,
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

local function pulseRoom(roomIndex)
    if roomIndex <= 0 or roomIndex == lastRoom then
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
        applyPreset(0.55)
    elseif kind == "Room" and payload then
        pulseRoom(tonumber(payload.Index or payload.Room or payload.CurrentRoom) or 0)
    elseif kind == "PressureOverride" or kind == "Pressure" then
        if type(payload) == "table" then
            pressure = payload.Active == true or payload.Enabled == true
        else
            pressure = payload == true
        end
        applyPreset(0.4)
    elseif kind == "Notice" and type(payload) == "string" then
        local upper = string.upper(payload)
        if string.find(upper, "PRESSURE", 1, true) and string.find(upper, "OVERRIDE", 1, true) then
            pressure = true
            applyPreset(0.35)
        elseif string.find(upper, "EXTRACT", 1, true) or string.find(upper, "CLEARED", 1, true) then
            pulse = math.max(pulse, 0.75)
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local baseBrightness = 0.04
    if pulse <= 0.001 then
        color.Brightness = baseBrightness
        return
    end

    pulse *= math.exp(-dt * 4.8)
    local flash = math.clamp(pulse, 0, 1)
    local preset = selectedPreset()
    color.Brightness = baseBrightness + flash * 0.035
    bloom.Intensity = preset.Bloom + flash * 0.12
end)

applyPreset(0)
