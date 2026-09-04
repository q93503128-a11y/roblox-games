local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local stateRemote = ReplicatedStorage:WaitForChild("VaultfallRemotes"):WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "PressureOverrideHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 16
gui.Parent = playerGui

local edge = Instance.new("Frame")
edge.Name = "PressureEdge"
edge.Size = UDim2.fromScale(1, 1)
edge.BackgroundTransparency = 1
edge.BorderSizePixel = 0
edge.Visible = false
edge.Parent = gui

local edgeStroke = Instance.new("UIStroke")
edgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
edgeStroke.Color = Color3.fromRGB(255, 105, 42)
edgeStroke.Thickness = 7
edgeStroke.Transparency = 1
edgeStroke.Parent = edge

local card = Instance.new("Frame")
card.Name = "PressureCard"
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position = UDim2.fromScale(0.5, 0.155)
card.Size = UDim2.fromOffset(470, 66)
card.BackgroundColor3 = Color3.fromRGB(25, 18, 15)
card.BackgroundTransparency = 0.06
card.BorderSizePixel = 0
card.Visible = false
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 7)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 121, 42)
stroke.Thickness = 1.8
stroke.Transparency = 0.12
stroke.Parent = card

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 6, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(255, 104, 35)
bar.BorderSizePixel = 0
bar.Parent = card

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(22, 8)
title.Size = UDim2.new(1, -32, 0, 23)
title.Font = Enum.Font.GothamBlack
title.Text = "HIGH-PRESSURE SECTOR"
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 214, 172)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

local detail = Instance.new("TextLabel")
detail.BackgroundTransparency = 1
detail.Position = UDim2.fromOffset(22, 33)
detail.Size = UDim2.new(1, -32, 0, 20)
detail.Font = Enum.Font.GothamMedium
detail.Text = "HOSTILES +24%  •  +35% ESSENCE  •  ENHANCED CLEARANCE LOOT"
detail.TextSize = 12
detail.TextColor3 = Color3.fromRGB(230, 226, 220)
detail.TextXAlignment = Enum.TextXAlignment.Left
detail.Parent = card

local active = false
local pulseToken = 0

local function setActive(enabled)
    active = enabled
    pulseToken += 1
    local token = pulseToken

    if enabled then
        card.Visible = true
        edge.Visible = true
        card.Position = UDim2.fromScale(0.5, 0.125)
        card.BackgroundTransparency = 1
        edgeStroke.Transparency = 1

        TweenService:Create(card, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.fromScale(0.5, 0.155),
            BackgroundTransparency = 0.06,
        }):Play()
        TweenService:Create(edgeStroke, TweenInfo.new(0.22), { Transparency = 0.45 }):Play()
        task.delay(0.55, function()
            if active and token == pulseToken then
                TweenService:Create(edgeStroke, TweenInfo.new(0.65), { Transparency = 0.88 }):Play()
            end
        end)
    else
        if card.Visible then
            TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.fromScale(0.5, 0.13),
                BackgroundTransparency = 1,
            }):Play()
        end
        if edge.Visible then
            TweenService:Create(edgeStroke, TweenInfo.new(0.22), { Transparency = 1 }):Play()
        end
        task.delay(0.23, function()
            if not active and token == pulseToken then
                card.Visible = false
                edge.Visible = false
            end
        end)
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Pressure" then
        if type(payload) == "table" and payload.Active == true then
            local essence = tonumber(payload.EssenceMultiplier) or 1.35
            local luck = tonumber(payload.LootLuck) or 0.45
            detail.Text = string.format("HOSTILES UPGRADED  •  +%d%% ESSENCE  •  +%d%% LOOT LUCK", math.floor((essence - 1) * 100 + 0.5), math.floor(luck * 100 + 0.5))
            setActive(true)
        else
            setActive(false)
        end
    elseif kind == "Run" and type(payload) == "table" and payload.Active == false then
        setActive(false)
    end
end)
