local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "BreachObjectiveHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "ObjectivePanel"
panel.Position = UDim2.fromOffset(18, 92)
panel.Size = UDim2.fromOffset(320, 94)
panel.BackgroundColor3 = Color3.fromRGB(16, 20, 27)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(77, 113, 142)
stroke.Transparency = 0.28
stroke.Thickness = 1
stroke.Parent = panel

local tag = Instance.new("TextLabel")
tag.BackgroundTransparency = 1
tag.Position = UDim2.fromOffset(12, 8)
tag.Size = UDim2.new(1, -24, 0, 18)
tag.Font = Enum.Font.GothamBold
tag.Text = "SECTOR OBJECTIVE"
tag.TextSize = 11
tag.TextColor3 = Color3.fromRGB(105, 176, 226)
tag.TextXAlignment = Enum.TextXAlignment.Left
tag.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(12, 28)
title.Size = UDim2.new(1, -24, 0, 25)
title.Font = Enum.Font.GothamBold
title.Text = "OBJECTIVE"
title.TextSize = 17
title.TextColor3 = Color3.fromRGB(237, 242, 247)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local progressBack = Instance.new("Frame")
progressBack.Position = UDim2.fromOffset(12, 63)
progressBack.Size = UDim2.new(1, -94, 0, 12)
progressBack.BackgroundColor3 = Color3.fromRGB(38, 44, 53)
progressBack.BorderSizePixel = 0
progressBack.Parent = panel

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progressBack

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.fromScale(0, 1)
progressFill.BackgroundColor3 = Color3.fromRGB(91, 174, 230)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = progressFill

local progressText = Instance.new("TextLabel")
progressText.BackgroundTransparency = 1
progressText.AnchorPoint = Vector2.new(1, 0)
progressText.Position = UDim2.new(1, -12, 0, 57)
progressText.Size = UDim2.fromOffset(68, 24)
progressText.Font = Enum.Font.GothamBold
progressText.Text = "0 / 0"
progressText.TextSize = 13
progressText.TextColor3 = Color3.fromRGB(197, 211, 222)
progressText.TextXAlignment = Enum.TextXAlignment.Right
progressText.Parent = panel

local function setVisible(visible)
    if visible then
        panel.Visible = true
        panel.BackgroundTransparency = 0.32
        panel.Position = UDim2.fromOffset(8, 92)
        TweenService:Create(panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.08,
            Position = UDim2.fromOffset(18, 92),
        }):Play()
    else
        panel.Visible = false
    end
end

local function updateObjective(data)
    if not data or not data.Active then
        setVisible(false)
        return
    end

    title.Text = tostring(data.Title or data.Type or "OBJECTIVE")
    local current = tonumber(data.Current) or 0
    local target = math.max(1, tonumber(data.Target) or 1)
    local ratio = math.clamp(current / target, 0, 1)

    TweenService:Create(progressFill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromScale(ratio, 1),
    }):Play()

    if data.Type == "Holdout" and data.TimeRemaining ~= nil then
        progressText.Text = string.format("%ds", math.max(0, math.ceil(data.TimeRemaining)))
    else
        progressText.Text = string.format("%d / %d", math.floor(current + 0.5), math.floor(target + 0.5))
    end

    if not panel.Visible then
        setVisible(true)
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Objective" then
        updateObjective(payload)
    elseif kind == "Run" and payload and not payload.Active then
        setVisible(false)
    end
end)
