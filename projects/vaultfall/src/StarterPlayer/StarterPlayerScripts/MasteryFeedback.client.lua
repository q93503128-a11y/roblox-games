local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local entriesByArchetype = {}
local flashSerial = 0

local gui = Instance.new("ScreenGui")
gui.Name = "WeaponMasteryFeedback"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 14
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "MasteryStrip"
panel.AnchorPoint = Vector2.new(1, 1)
panel.Position = UDim2.new(1, -16, 1, -112)
panel.Size = UDim2.fromOffset(300, 48)
panel.BackgroundColor3 = Color3.fromRGB(16, 20, 24)
panel.BackgroundTransparency = 0.12
panel.BorderSizePixel = 0
panel.Parent = gui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(89, 119, 132)
outline.Transparency = 0.45
outline.Thickness = 1
outline.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(10, 5)
title.Size = UDim2.new(1, -20, 0, 18)
title.Font = Enum.Font.GothamBold
title.Text = "CARBINE MASTERY  •  Lv.0"
title.TextColor3 = Color3.fromRGB(220, 231, 235)
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local xpText = Instance.new("TextLabel")
xpText.Name = "XP"
xpText.BackgroundTransparency = 1
xpText.AnchorPoint = Vector2.new(1, 0)
xpText.Position = UDim2.new(1, -10, 0, 5)
xpText.Size = UDim2.fromOffset(120, 18)
xpText.Font = Enum.Font.GothamMedium
xpText.Text = "0 / 45 XP"
xpText.TextColor3 = Color3.fromRGB(153, 170, 177)
xpText.TextSize = 10
xpText.TextXAlignment = Enum.TextXAlignment.Right
xpText.Parent = panel

local progressBack = Instance.new("Frame")
progressBack.Name = "ProgressBack"
progressBack.Position = UDim2.fromOffset(10, 29)
progressBack.Size = UDim2.new(1, -20, 0, 8)
progressBack.BackgroundColor3 = Color3.fromRGB(43, 49, 54)
progressBack.BorderSizePixel = 0
progressBack.Parent = panel

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progressBack

local progressFill = Instance.new("Frame")
progressFill.Name = "Progress"
progressFill.Size = UDim2.fromScale(0, 1)
progressFill.BackgroundColor3 = Color3.fromRGB(95, 181, 202)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = progressFill

local levelBanner = Instance.new("Frame")
levelBanner.Name = "LevelBanner"
levelBanner.AnchorPoint = Vector2.new(0.5, 0.5)
levelBanner.Position = UDim2.fromScale(0.5, 0.33)
levelBanner.Size = UDim2.fromOffset(480, 116)
levelBanner.BackgroundColor3 = Color3.fromRGB(11, 16, 20)
levelBanner.BackgroundTransparency = 1
levelBanner.BorderSizePixel = 0
levelBanner.Visible = false
levelBanner.Parent = gui

local bannerCorner = Instance.new("UICorner")
bannerCorner.CornerRadius = UDim.new(0, 12)
bannerCorner.Parent = levelBanner

local bannerStroke = Instance.new("UIStroke")
bannerStroke.Color = Color3.fromRGB(99, 206, 231)
bannerStroke.Thickness = 2
bannerStroke.Transparency = 1
bannerStroke.Parent = levelBanner

local bannerHeader = Instance.new("TextLabel")
bannerHeader.BackgroundTransparency = 1
bannerHeader.Position = UDim2.fromOffset(16, 16)
bannerHeader.Size = UDim2.new(1, -32, 0, 26)
bannerHeader.Font = Enum.Font.GothamBold
bannerHeader.Text = "WEAPON CALIBRATION ADVANCED"
bannerHeader.TextSize = 14
bannerHeader.TextColor3 = Color3.fromRGB(112, 218, 241)
bannerHeader.TextTransparency = 1
bannerHeader.TextXAlignment = Enum.TextXAlignment.Center
bannerHeader.Parent = levelBanner

local bannerLevel = Instance.new("TextLabel")
bannerLevel.BackgroundTransparency = 1
bannerLevel.Position = UDim2.fromOffset(16, 41)
bannerLevel.Size = UDim2.new(1, -32, 0, 34)
bannerLevel.Font = Enum.Font.GothamBold
bannerLevel.Text = "CARBINE  •  MASTERY Lv.1"
bannerLevel.TextSize = 22
bannerLevel.TextColor3 = Color3.fromRGB(239, 246, 248)
bannerLevel.TextTransparency = 1
bannerLevel.TextXAlignment = Enum.TextXAlignment.Center
bannerLevel.Parent = levelBanner

local bannerPerk = Instance.new("TextLabel")
bannerPerk.BackgroundTransparency = 1
bannerPerk.Position = UDim2.fromOffset(18, 77)
bannerPerk.Size = UDim2.new(1, -36, 0, 22)
bannerPerk.Font = Enum.Font.GothamMedium
bannerPerk.Text = "Combat calibration improved"
bannerPerk.TextSize = 11
bannerPerk.TextColor3 = Color3.fromRGB(170, 184, 190)
bannerPerk.TextTransparency = 1
bannerPerk.TextXAlignment = Enum.TextXAlignment.Center
bannerPerk.TextTruncate = Enum.TextTruncate.AtEnd
bannerPerk.Parent = levelBanner

local function findEntry(archetype)
    return entriesByArchetype[archetype]
end

local function perkForLevel(entry, level)
    if not entry or type(entry.Perks) ~= "table" then
        return "Combat calibration improved"
    end
    if level == 5 then
        return entry.Perks[3] or entry.Perks[#entry.Perks] or "Milestone calibration unlocked"
    elseif level == 10 then
        return entry.Perks[4] or entry.Perks[#entry.Perks] or "Apex calibration unlocked"
    end
    return entry.Perks[1] or "Combat calibration improved"
end

local function refreshStrip()
    local entry = findEntry(currentArchetype)
    if not entry then
        panel.Visible = false
        return
    end

    panel.Visible = true
    local level = entry.Level or 0
    local maxLevel = entry.MaxLevel or 10
    title.Text = string.format("%s MASTERY  •  Lv.%d", string.upper(currentArchetype), level)

    if level >= maxLevel then
        xpText.Text = "MAX CALIBRATION"
    else
        xpText.Text = string.format("%d / %d XP", entry.XP or 0, entry.NextXP or 0)
    end

    TweenService:Create(progressFill, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromScale(math.clamp(entry.Progress or 0, 0, 1), 1),
    }):Play()
end

local function showLevelUp(levelUp)
    if type(levelUp) ~= "table" then
        return
    end

    flashSerial += 1
    local serial = flashSerial
    local archetype = levelUp.Archetype or currentArchetype
    local level = levelUp.Level or 0
    local entry = findEntry(archetype)

    levelBanner.Visible = true
    levelBanner.Size = UDim2.fromOffset(420, 94)
    levelBanner.BackgroundTransparency = 1
    bannerStroke.Transparency = 1
    bannerHeader.TextTransparency = 1
    bannerLevel.TextTransparency = 1
    bannerPerk.TextTransparency = 1
    bannerLevel.Text = string.format("%s  •  MASTERY Lv.%d", string.upper(archetype), level)
    bannerPerk.Text = perkForLevel(entry, level)

    TweenService:Create(levelBanner, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(480, 116),
        BackgroundTransparency = 0.12,
    }):Play()
    TweenService:Create(bannerStroke, TweenInfo.new(0.18), { Transparency = 0.12 }):Play()
    TweenService:Create(bannerHeader, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
    TweenService:Create(bannerLevel, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
    TweenService:Create(bannerPerk, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()

    outline.Color = Color3.fromRGB(99, 206, 231)
    outline.Transparency = 0.05
    progressFill.BackgroundColor3 = Color3.fromRGB(126, 226, 247)

    task.delay(2.7, function()
        if serial ~= flashSerial then
            return
        end
        TweenService:Create(levelBanner, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(450, 104),
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(bannerStroke, TweenInfo.new(0.28), { Transparency = 1 }):Play()
        TweenService:Create(bannerHeader, TweenInfo.new(0.28), { TextTransparency = 1 }):Play()
        TweenService:Create(bannerLevel, TweenInfo.new(0.28), { TextTransparency = 1 }):Play()
        TweenService:Create(bannerPerk, TweenInfo.new(0.28), { TextTransparency = 1 }):Play()
        task.delay(0.38, function()
            if serial == flashSerial then
                levelBanner.Visible = false
            end
        end)
        TweenService:Create(outline, TweenInfo.new(0.45), {
            Color = Color3.fromRGB(89, 119, 132),
            Transparency = 0.45,
        }):Play()
        TweenService:Create(progressFill, TweenInfo.new(0.45), {
            BackgroundColor3 = Color3.fromRGB(95, 181, 202),
        }):Play()
    end)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and type(payload) == "table" then
        currentArchetype = payload.Archetype or currentArchetype
        refreshStrip()
    elseif kind == "Mastery" and type(payload) == "table" then
        if type(payload.Entries) == "table" then
            for _, entry in ipairs(payload.Entries) do
                if type(entry) == "table" and entry.Archetype then
                    entriesByArchetype[entry.Archetype] = entry
                end
            end
        end
        refreshStrip()
        if payload.LevelUp then
            showLevelUp(payload.LevelUp)
        end
    elseif kind == "Run" and type(payload) == "table" then
        panel.BackgroundTransparency = payload.Active and 0.12 or 0.22
    end
end)