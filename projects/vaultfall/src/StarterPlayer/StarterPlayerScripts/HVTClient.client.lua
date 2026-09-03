local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "HVTHud"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 18
gui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.Name = "HVTCard"
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position = UDim2.new(0.5, 0, 0, 82)
card.Size = UDim2.fromOffset(430, 74)
card.BackgroundColor3 = Color3.fromRGB(17, 18, 23)
card.BackgroundTransparency = 0.08
card.BorderSizePixel = 0
card.Visible = false
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(217, 101, 78)
stroke.Transparency = 0.16
stroke.Parent = card

local tag = Instance.new("TextLabel")
tag.BackgroundTransparency = 1
tag.Position = UDim2.fromOffset(14, 8)
tag.Size = UDim2.fromOffset(108, 18)
tag.Font = Enum.Font.GothamBold
tag.TextSize = 12
tag.TextXAlignment = Enum.TextXAlignment.Left
tag.TextColor3 = Color3.fromRGB(239, 129, 96)
tag.Text = "HIGH VALUE TARGET"
tag.Parent = card

local nameLabel = Instance.new("TextLabel")
nameLabel.BackgroundTransparency = 1
nameLabel.Position = UDim2.fromOffset(14, 24)
nameLabel.Size = UDim2.new(1, -28, 0, 24)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 19
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextColor3 = Color3.fromRGB(244, 244, 248)
nameLabel.Text = "TARGET"
nameLabel.Parent = card

local barBack = Instance.new("Frame")
barBack.Position = UDim2.fromOffset(14, 54)
barBack.Size = UDim2.new(1, -28, 0, 8)
barBack.BackgroundColor3 = Color3.fromRGB(45, 46, 54)
barBack.BorderSizePixel = 0
barBack.Parent = card

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = barBack

local bar = Instance.new("Frame")
bar.Size = UDim2.fromScale(1, 1)
bar.BackgroundColor3 = Color3.fromRGB(215, 82, 77)
bar.BorderSizePixel = 0
bar.Parent = barBack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = bar

local ability = Instance.new("TextLabel")
ability.BackgroundColor3 = Color3.fromRGB(215, 82, 77)
ability.BackgroundTransparency = 0.08
ability.AnchorPoint = Vector2.new(0.5, 0)
ability.Position = UDim2.new(0.5, 0, 0, 161)
ability.Size = UDim2.fromOffset(310, 34)
ability.Font = Enum.Font.GothamBold
ability.TextSize = 14
ability.TextColor3 = Color3.new(1, 1, 1)
ability.Text = ""
ability.Visible = false
ability.BorderSizePixel = 0
ability.Parent = gui

local abilityCorner = Instance.new("UICorner")
abilityCorner.CornerRadius = UDim.new(0, 7)
abilityCorner.Parent = ability

local lastAbility = ""
local abilityToken = 0

local function showAbility(text)
    if text == "" or text == lastAbility then
        return
    end
    lastAbility = text
    abilityToken += 1
    local token = abilityToken
    ability.Text = text
    ability.TextTransparency = 0
    ability.BackgroundTransparency = 0.08
    ability.Visible = true
    ability.Size = UDim2.fromOffset(310, 34)
    TweenService:Create(ability, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(350, 38),
    }):Play()
    task.delay(1.35, function()
        if token ~= abilityToken then
            return
        end
        local tween = TweenService:Create(ability, TweenInfo.new(0.22), {
            TextTransparency = 1,
            BackgroundTransparency = 1,
        })
        tween:Play()
        tween.Completed:Wait()
        if token == abilityToken then
            ability.Visible = false
        end
    end)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind ~= "HVT" or type(payload) ~= "table" then
        return
    end
    if not payload.Active then
        card.Visible = false
        ability.Visible = false
        lastAbility = ""
        abilityToken += 1
        return
    end

    card.Visible = true
    nameLabel.Text = string.format("%s  //  SECTOR %d", tostring(payload.Name or "TARGET"), tonumber(payload.Room) or 0)
    local health = tonumber(payload.Health) or 0
    local maxHealth = math.max(1, tonumber(payload.MaxHealth) or 1)
    local fraction = math.clamp(health / maxHealth, 0, 1)
    TweenService:Create(bar, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
        Size = UDim2.fromScale(fraction, 1),
    }):Play()

    local abilityName = tostring(payload.Ability or "")
    if abilityName ~= "" then
        showAbility(abilityName)
    elseif abilityName == "" then
        lastAbility = ""
    end
end)
