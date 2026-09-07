local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "SafehousePrepFlow"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 18
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "PrepFlow"
panel.Position = UDim2.fromOffset(18, 88)
panel.Size = UDim2.fromOffset(322, 134)
panel.BackgroundColor3 = Color3.fromRGB(15, 21, 25)
panel.BackgroundTransparency = 0.11
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 9)
corner.Parent = panel

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(73, 111, 121)
outline.Transparency = 0.42
outline.Thickness = 1
outline.Parent = panel

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Position = UDim2.fromOffset(14, 9)
header.Size = UDim2.new(1, -28, 0, 20)
header.Font = Enum.Font.GothamBold
header.Text = "BREACH PREP  //  SAFEHOUSE"
header.TextSize = 12
header.TextColor3 = Color3.fromRGB(172, 205, 213)
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local squad = Instance.new("TextLabel")
squad.AnchorPoint = Vector2.new(1, 0)
squad.BackgroundTransparency = 1
squad.Position = UDim2.new(1, -14, 0, 9)
squad.Size = UDim2.fromOffset(118, 20)
squad.Font = Enum.Font.GothamMedium
squad.Text = "1 OPERATOR AVAILABLE"
squad.TextSize = 10
squad.TextColor3 = Color3.fromRGB(132, 151, 158)
squad.TextXAlignment = Enum.TextXAlignment.Right
squad.Parent = panel

local rows = {}
local function makeRow(index, titleText)
    local row = Instance.new("Frame")
    row.Name = titleText
    row.Position = UDim2.fromOffset(12, 35 + ((index - 1) * 29))
    row.Size = UDim2.new(1, -24, 0, 25)
    row.BackgroundColor3 = Color3.fromRGB(24, 31, 35)
    row.BackgroundTransparency = 0.32
    row.BorderSizePixel = 0
    row.Parent = panel

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local marker = Instance.new("Frame")
    marker.Name = "Marker"
    marker.AnchorPoint = Vector2.new(0, 0.5)
    marker.Position = UDim2.new(0, 8, 0.5, 0)
    marker.Size = UDim2.fromOffset(7, 7)
    marker.BackgroundColor3 = Color3.fromRGB(91, 111, 119)
    marker.BorderSizePixel = 0
    marker.Parent = row
    local markerCorner = Instance.new("UICorner")
    markerCorner.CornerRadius = UDim.new(1, 0)
    markerCorner.Parent = marker

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(23, 0)
    title.Size = UDim2.fromOffset(78, 25)
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextSize = 10
    title.TextColor3 = Color3.fromRGB(177, 191, 197)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = row

    local value = Instance.new("TextLabel")
    value.Name = "Value"
    value.BackgroundTransparency = 1
    value.Position = UDim2.fromOffset(100, 0)
    value.Size = UDim2.new(1, -108, 1, 0)
    value.Font = Enum.Font.GothamMedium
    value.Text = "--"
    value.TextSize = 10
    value.TextColor3 = Color3.fromRGB(213, 222, 226)
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.TextTruncate = Enum.TextTruncate.AtEnd
    value.Parent = row

    rows[index] = {
        Frame = row,
        Marker = marker,
        Value = value,
    }
end

makeRow(1, "CONTRACT")
makeRow(2, "RANGE")
makeRow(3, "DEPLOY")

local runActive = false
local selectedContract = "CONTRACT READY"
local rangeTested = false
local pulseToken = 0

local readyColor = Color3.fromRGB(93, 195, 160)
local optionalColor = Color3.fromRGB(91, 147, 164)
local actionColor = Color3.fromRGB(220, 149, 77)

local function updateSquad()
    local count = #Players:GetPlayers()
    squad.Text = string.format("%d OPERATOR%s AVAILABLE", count, count == 1 and "" or "S")
end

local function setRow(row, text, color)
    row.Value.Text = text
    row.Marker.BackgroundColor3 = color
end

local function pulseDeploy()
    pulseToken += 1
    local token = pulseToken
    rows[3].Frame.BackgroundTransparency = 0.12
    TweenService:Create(rows[3].Frame, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.32,
    }):Play()
    task.delay(0.48, function()
        if token == pulseToken then
            rows[3].Frame.BackgroundTransparency = 0.32
        end
    end)
end

local function refresh()
    panel.Visible = not runActive
    if runActive then
        return
    end

    setRow(rows[1], selectedContract, readyColor)
    if rangeTested then
        setRow(rows[2], "TEST COMPLETE", readyColor)
    else
        setRow(rows[2], "OPTIONAL WEAPON CHECK", optionalColor)
    end
    setRow(rows[3], "HOLD AT BREACH LIFT", actionColor)
end

local function resolveSelected(payload)
    local selectedId = payload.Selected
    if type(selectedId) ~= "string" then
        return
    end
    for _, offer in ipairs(payload.Offers or {}) do
        if offer.Id == selectedId then
            selectedContract = tostring(offer.Name or "CONTRACT READY") .. " / " .. tostring(offer.Threat or "READY")
            return
        end
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Run" and type(payload) == "table" then
        runActive = payload.Active == true
        if not runActive then
            rangeTested = false
        end
        refresh()
    elseif kind == "Contracts" and type(payload) == "table" then
        resolveSelected(payload)
        refresh()
        if payload.Open ~= true then
            pulseDeploy()
        end
    elseif kind == "ContractActive" then
        runActive = true
        refresh()
    elseif kind == "Training" and type(payload) == "table" then
        if payload.Active == false then
            rangeTested = true
            refresh()
            pulseDeploy()
        end
    end
end)

Players.PlayerAdded:Connect(updateSquad)
Players.PlayerRemoving:Connect(function()
    task.defer(updateSquad)
end)

updateSquad()
refresh()
