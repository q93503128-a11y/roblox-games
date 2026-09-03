local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "BreachEncounterHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 20
gui.Parent = playerGui

local banner = Instance.new("Frame")
banner.Name = "ThreatBanner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 72)
banner.Size = UDim2.fromOffset(390, 42)
banner.BackgroundColor3 = Color3.fromRGB(26, 31, 36)
banner.BackgroundTransparency = 1
banner.BorderSizePixel = 0
banner.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 7)
corner.Parent = banner

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(213, 91, 91)
stroke.Transparency = 1
stroke.Thickness = 1
stroke.Parent = banner

local bannerText = Instance.new("TextLabel")
bannerText.BackgroundTransparency = 1
bannerText.Size = UDim2.fromScale(1, 1)
bannerText.Font = Enum.Font.GothamBold
bannerText.TextSize = 14
bannerText.TextColor3 = Color3.fromRGB(245, 237, 237)
bannerText.Text = ""
bannerText.TextTransparency = 1
bannerText.Parent = banner

local vignette = Instance.new("Frame")
vignette.Name = "DangerFlash"
vignette.Size = UDim2.fromScale(1, 1)
vignette.BackgroundColor3 = Color3.fromRGB(125, 24, 28)
vignette.BackgroundTransparency = 1
vignette.BorderSizePixel = 0
vignette.ZIndex = -1
vignette.Parent = gui

local bannerToken = 0
local function showBanner(text, duration)
    bannerToken += 1
    local token = bannerToken
    bannerText.Text = text
    banner.BackgroundTransparency = 0.12
    bannerText.TextTransparency = 0
    stroke.Transparency = 0.28
    TweenService:Create(banner, TweenInfo.new(0.12), {
        Size = UDim2.fromOffset(420, 46),
    }):Play()
    task.delay(duration or 1.25, function()
        if token ~= bannerToken then
            return
        end
        TweenService:Create(banner, TweenInfo.new(0.22), {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(390, 42),
        }):Play()
        TweenService:Create(bannerText, TweenInfo.new(0.22), { TextTransparency = 1 }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.22), { Transparency = 1 }):Play()
    end)
end

local shakeUntil = 0
local shakeStrength = 0
local function kickShake(strength, duration)
    shakeStrength = math.max(shakeStrength, strength)
    shakeUntil = math.max(shakeUntil, os.clock() + duration)
end

RunService:BindToRenderStep("BreachEncounterCamera", Enum.RenderPriority.Camera.Value + 1, function()
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end
    if os.clock() < shakeUntil then
        local fade = math.clamp((shakeUntil - os.clock()) / 0.32, 0, 1)
        local x = (math.noise(os.clock() * 37, 2) - 0.5) * 0.014 * shakeStrength * fade
        local y = (math.noise(5, os.clock() * 41) - 0.5) * 0.011 * shakeStrength * fade
        camera.CFrame *= CFrame.Angles(y, x, 0)
    else
        shakeStrength = 0
    end
end)

local watched = {}
local function watchEffect(effect)
    if watched[effect] then
        return
    end
    watched[effect] = true
    if effect.Name == "SweepLaser" then
        showBanner("SWEEP DETECTED  •  MOVE THROUGH THE GAP", 1.3)
        TweenService:Create(vignette, TweenInfo.new(0.1), { BackgroundTransparency = 0.94 }):Play()
        task.delay(0.22, function()
            TweenService:Create(vignette, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
        end)
        kickShake(0.55, 0.35)
    elseif effect.Name == "TelegraphDisc" then
        local radius = math.max(effect.Size.Y, effect.Size.Z) * 0.5
        if radius > 8 then
            showBanner("SHOCKWAVE  •  CLEAR THE IMPACT RADIUS", 1.05)
            kickShake(0.35, 0.28)
        else
            showBanner("ARTILLERY LOCK  •  KEEP MOVING", 0.9)
        end
    end

    effect.AncestryChanged:Connect(function(_, parent)
        if not parent then
            watched[effect] = nil
        end
    end)
end

local function attachFolder(folder)
    for _, child in ipairs(folder:GetChildren()) do
        watchEffect(child)
    end
    folder.ChildAdded:Connect(watchEffect)
end

local function discoverEffects()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    local folder = world and world:FindFirstChild("EncounterEffects")
    if folder then
        attachFolder(folder)
        return true
    end
    return false
end

if not discoverEffects() then
    task.spawn(function()
        while gui.Parent do
            if discoverEffects() then
                break
            end
            task.wait(0.5)
        end
    end)
end
