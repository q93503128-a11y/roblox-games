local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local zoneUpdated = remotes:WaitForChild("ZoneStateUpdated")
local requestZoneState = remotes:WaitForChild("RequestZoneState")

local atmosphere = Lighting:WaitForChild("Atmosphere", 10)
local colorCorrection = Lighting:WaitForChild("ColorCorrection", 10)
local bloom = Lighting:WaitForChild("Bloom", 10)

if not (atmosphere and colorCorrection and bloom) then
    warn("[MonsterFactory] ZoneMood skipped: canonical Lighting effects are missing.")
    return
end

local MOODS = {
    [1] = {
        AtmosphereColor = Color3.fromRGB(200, 230, 247),
        AtmosphereDecay = Color3.fromRGB(96, 132, 156),
        Density = 0.24,
        Haze = 1.05,
        Tint = Color3.fromRGB(255, 250, 229),
        Saturation = 0.12,
        Contrast = 0.07,
        Bloom = 0.30,
    },
    [2] = {
        AtmosphereColor = Color3.fromRGB(245, 205, 156),
        AtmosphereDecay = Color3.fromRGB(150, 88, 58),
        Density = 0.29,
        Haze = 1.65,
        Tint = Color3.fromRGB(255, 225, 190),
        Saturation = 0.16,
        Contrast = 0.10,
        Bloom = 0.27,
    },
    [3] = {
        AtmosphereColor = Color3.fromRGB(193, 225, 255),
        AtmosphereDecay = Color3.fromRGB(89, 116, 159),
        Density = 0.27,
        Haze = 1.28,
        Tint = Color3.fromRGB(222, 242, 255),
        Saturation = 0.08,
        Contrast = 0.12,
        Bloom = 0.38,
    },
}

local tweenInfo = TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function applyMood(zoneId)
    local mood = MOODS[zoneId] or MOODS[1]

    TweenService:Create(atmosphere, tweenInfo, {
        Color = mood.AtmosphereColor,
        Decay = mood.AtmosphereDecay,
        Density = mood.Density,
        Haze = mood.Haze,
    }):Play()

    TweenService:Create(colorCorrection, tweenInfo, {
        TintColor = mood.Tint,
        Saturation = mood.Saturation,
        Contrast = mood.Contrast,
    }):Play()

    TweenService:Create(bloom, tweenInfo, {
        Intensity = mood.Bloom,
    }):Play()
end

zoneUpdated.OnClientEvent:Connect(function(state)
    if type(state) == "table" then
        applyMood(state.CurrentZone or 1)
    end
end)

task.spawn(function()
    local ok, state = pcall(function()
        return requestZoneState:InvokeServer()
    end)

    if ok and type(state) == "table" then
        applyMood(state.CurrentZone or 1)
    else
        applyMood(1)
    end
end)
