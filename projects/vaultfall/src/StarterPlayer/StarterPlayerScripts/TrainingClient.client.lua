local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "BreachTrainingHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "RangeTelemetry"
panel.AnchorPoint = Vector2.new(0, 0.5)
panel.Position = UDim2.new(0, 18, 0.5, -24)
panel.Size = UDim2.fromOffset(248, 178)
panel.BackgroundColor3 = Color3.fromRGB(16, 22, 27)
panel.BackgroundTransparency = 1
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 9)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(88, 146, 160)
stroke.Transparency = 1
stroke.Thickness = 1
stroke.Parent = panel

local function makeLabel(name, text, y, height, size, bold)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = UDim2.fromOffset(14, y)
    label.Size = UDim2.new(1, -28, 0, height)
    label.BackgroundTransparency = 1
    label.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
    label.Text = text
    label.TextSize = size
    label.TextColor3 = Color3.fromRGB(228, 238, 241)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTransparency = 1
    label.Parent = panel
    return label
end

local header = makeLabel("Header", "FIRING RANGE  //  LIVE TEST", 11, 20, 12, true)
header.TextColor3 = Color3.fromRGB(105, 190, 207)
local weapon = makeLabel("Weapon", "CARBINE", 34, 24, 17, true)
local dps = makeLabel("DPS", "DPS   0", 66, 22, 14, false)
local total = makeLabel("Total", "DAMAGE   0", 89, 22, 14, false)
local accuracy = makeLabel("Accuracy", "ACCURACY   --", 112, 22, 14, false)
local best = makeLabel("Best", "BEST HIT   0", 135, 22, 14, false)

local pulse = Instance.new("Frame")
pulse.Name = "HitPulse"
pulse.AnchorPoint = Vector2.new(1, 0)
pulse.Position = UDim2.new(1, -12, 0, 12)
pulse.Size = UDim2.fromOffset(8, 8)
pulse.BackgroundColor3 = Color3.fromRGB(102, 205, 171)
pulse.BackgroundTransparency = 1
pulse.BorderSizePixel = 0
pulse.Parent = panel
local pulseCorner = Instance.new("UICorner")
pulseCorner.CornerRadius = UDim.new(1, 0)
pulseCorner.Parent = pulse

local visibleToken = 0
local function setVisible(visible, hold)
    visibleToken += 1
    local token = visibleToken
    panel.Visible = true
    if visible then
        TweenService:Create(panel, TweenInfo.new(0.14), { BackgroundTransparency = 0.08 }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.14), { Transparency = 0.32 }):Play()
        for _, item in ipairs({ header, weapon, dps, total, accuracy, best }) do
            TweenService:Create(item, TweenInfo.new(0.14), { TextTransparency = 0 }):Play()
        end
    else
        task.delay(hold or 2.6, function()
            if token ~= visibleToken then
                return
            end
            TweenService:Create(panel, TweenInfo.new(0.28), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.28), { Transparency = 1 }):Play()
            for _, item in ipairs({ header, weapon, dps, total, accuracy, best }) do
                TweenService:Create(item, TweenInfo.new(0.28), { TextTransparency = 1 }):Play()
            end
            task.delay(0.3, function()
                if token == visibleToken then
                    panel.Visible = false
                end
            end)
        end)
    end
end

local function hitPulse(hit)
    pulse.BackgroundColor3 = hit and Color3.fromRGB(102, 205, 171) or Color3.fromRGB(205, 105, 102)
    pulse.BackgroundTransparency = 0
    pulse.Size = UDim2.fromOffset(11, 11)
    TweenService:Create(pulse, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(8, 8),
    }):Play()
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind ~= "Training" or type(payload) ~= "table" then
        return
    end

    weapon.Text = string.upper(tostring(payload.Archetype or "WEAPON"))
    dps.Text = string.format("DPS   %d", math.floor((payload.DPS or 0) + 0.5))
    total.Text = string.format("DAMAGE   %d", math.floor((payload.TotalDamage or 0) + 0.5))
    accuracy.Text = string.format("ACCURACY   %d%%   (%d/%d)", math.floor((payload.Accuracy or 0) * 100 + 0.5), payload.Hits or 0, payload.Shots or 0)
    best.Text = string.format("BEST HIT   %d", payload.BestHit or 0)

    if payload.Active then
        setVisible(true)
        hitPulse(payload.Hit == true)
    else
        header.Text = "FIRING RANGE  //  SESSION RESULT"
        setVisible(false, 3.2)
        task.delay(3.5, function()
            header.Text = "FIRING RANGE  //  LIVE TEST"
        end)
    end
end)
