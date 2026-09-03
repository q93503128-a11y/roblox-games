local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "OptionalOpsHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "FieldOpPanel"
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.Position = UDim2.new(0, 16, 0.5, 8)
panel.Size = UDim2.fromOffset(286, 104)
panel.BackgroundColor3 = Color3.fromRGB(16, 21, 25)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 9)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(74, 120, 135)
stroke.Transparency = 0.28
stroke.Thickness = 1
stroke.Parent = panel

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Position = UDim2.fromOffset(12, 8)
header.Size = UDim2.new(1, -24, 0, 20)
header.Font = Enum.Font.GothamBold
header.TextSize = 12
header.TextXAlignment = Enum.TextXAlignment.Left
header.TextColor3 = Color3.fromRGB(118, 183, 199)
header.Text = "OPTIONAL FIELD OP"
header.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 29)
title.Size = UDim2.new(1, -24, 0, 23)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(238, 242, 244)
title.Text = "FIELD OP"
title.Parent = panel

local detail = Instance.new("TextLabel")
detail.BackgroundTransparency = 1
detail.Position = UDim2.fromOffset(12, 52)
detail.Size = UDim2.new(1, -24, 0, 18)
detail.Font = Enum.Font.GothamMedium
detail.TextSize = 11
detail.TextXAlignment = Enum.TextXAlignment.Left
detail.TextColor3 = Color3.fromRGB(164, 174, 181)
detail.Text = "Locate the optional objective"
detail.Parent = panel

local barBack = Instance.new("Frame")
barBack.Position = UDim2.fromOffset(12, 79)
barBack.Size = UDim2.new(1, -24, 0, 10)
barBack.BackgroundColor3 = Color3.fromRGB(42, 49, 54)
barBack.BorderSizePixel = 0
barBack.Parent = panel

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 5)
backCorner.Parent = barBack

local bar = Instance.new("Frame")
bar.Size = UDim2.fromScale(0, 1)
bar.BackgroundColor3 = Color3.fromRGB(91, 183, 151)
bar.BorderSizePixel = 0
bar.Parent = barBack

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 5)
barCorner.Parent = bar

local warning = Instance.new("TextLabel")
warning.Name = "PulseWarning"
warning.AnchorPoint = Vector2.new(0.5, 0.5)
warning.Position = UDim2.fromScale(0.5, 0.72)
warning.Size = UDim2.fromOffset(390, 42)
warning.BackgroundColor3 = Color3.fromRGB(68, 21, 20)
warning.BackgroundTransparency = 1
warning.BorderSizePixel = 0
warning.Font = Enum.Font.GothamBold
warning.Text = "FIELD HAZARD — MOVE"
warning.TextSize = 17
warning.TextColor3 = Color3.fromRGB(255, 195, 181)
warning.TextTransparency = 1
warning.Parent = gui

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 8)
warningCorner.Parent = warning

local warningToken = 0
local current = {
    Active = false,
    Armed = false,
    Complete = false,
    Kind = nil,
    Progress = 0,
    Required = 0,
    TimeLeft = 0,
}

local function description(kind, armed)
    if kind == "OVERLOAD CACHE" then
        return armed and "Survive the purge field" or "Breach the encrypted armory cache"
    elseif kind == "RELAY SWEEP" then
        return "Link all ghost relays"
    elseif kind == "CONTAINMENT HOLD" then
        return armed and "Keep an operator inside the ring" or "Arm the anomaly regulator"
    end
    return "Optional objective available"
end

local function updatePanel(payload)
    current = payload or current
    panel.Visible = payload and payload.Active == true
    if not panel.Visible then
        return
    end

    local kind = tostring(payload.Kind or "FIELD OP")
    title.Text = kind
    detail.Text = description(kind, payload.Armed == true)

    local required = tonumber(payload.Required) or 0
    local progress = tonumber(payload.Progress) or 0
    local ratio = required > 0 and math.clamp(progress / required, 0, 1) or 0
    TweenService:Create(bar, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromScale(ratio, 1),
    }):Play()

    if kind == "RELAY SWEEP" then
        detail.Text = string.format("Link ghost relays  •  %d / %d", math.floor(progress + 0.5), math.floor(required + 0.5))
    elseif payload.Armed and required > 0 then
        local timeLeft = tonumber(payload.TimeLeft) or math.max(0, required - progress)
        detail.Text = string.format("%s  •  %.1fs", description(kind, true), math.max(0, timeLeft))
    end
end

local function flashWarning()
    warningToken += 1
    local token = warningToken
    warning.TextTransparency = 0
    warning.BackgroundTransparency = 0.15
    warning.Position = UDim2.fromScale(0.5, 0.72)
    TweenService:Create(warning, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.695),
    }):Play()
    task.delay(0.55, function()
        if token ~= warningToken then
            return
        end
        TweenService:Create(warning, TweenInfo.new(0.28), {
            TextTransparency = 1,
            BackgroundTransparency = 1,
        }):Play()
    end)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "OptionalOp" then
        updatePanel(payload)
    elseif kind == "OptionalOpPulse" then
        flashWarning()
    elseif kind == "Run" and payload and payload.Active == false then
        panel.Visible = false
    end
end)
