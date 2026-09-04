local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "RunOutcomePresentation"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 55
gui.Parent = player:WaitForChild("PlayerGui")

local dim = Instance.new("Frame")
dim.Name = "Dim"
dim.Size = UDim2.fromScale(1, 1)
dim.BackgroundColor3 = Color3.fromRGB(4, 7, 9)
dim.BackgroundTransparency = 1
dim.BorderSizePixel = 0
dim.Visible = false
dim.Parent = gui

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Position = UDim2.fromScale(0.5, 0)
topBar.Size = UDim2.new(1, 0, 0, 7)
topBar.BackgroundColor3 = Color3.fromRGB(93, 222, 198)
topBar.BackgroundTransparency = 1
topBar.BorderSizePixel = 0
topBar.Parent = dim

local card = Instance.new("Frame")
card.Name = "OutcomeCard"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.fromScale(0.5, 0.53)
card.Size = UDim2.fromOffset(520, 250)
card.BackgroundColor3 = Color3.fromRGB(13, 18, 21)
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.Parent = dim

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 14)
cardCorner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(93, 222, 198)
stroke.Transparency = 1
stroke.Parent = card

local eyebrow = Instance.new("TextLabel")
eyebrow.Name = "Eyebrow"
eyebrow.BackgroundTransparency = 1
eyebrow.Position = UDim2.fromOffset(26, 24)
eyebrow.Size = UDim2.new(1, -52, 0, 20)
eyebrow.Font = Enum.Font.GothamBold
eyebrow.Text = "OPERATION REPORT"
eyebrow.TextSize = 12
eyebrow.TextColor3 = Color3.fromRGB(134, 151, 157)
eyebrow.TextTransparency = 1
eyebrow.TextXAlignment = Enum.TextXAlignment.Left
eyebrow.Parent = card

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(26, 47)
title.Size = UDim2.new(1, -52, 0, 48)
title.Font = Enum.Font.GothamBlack
title.Text = "EXTRACTION SECURED"
title.TextSize = 30
title.TextColor3 = Color3.fromRGB(238, 244, 244)
title.TextTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

local divider = Instance.new("Frame")
divider.Name = "Divider"
divider.Position = UDim2.fromOffset(26, 105)
divider.Size = UDim2.new(1, -52, 0, 2)
divider.BackgroundColor3 = Color3.fromRGB(93, 222, 198)
divider.BackgroundTransparency = 1
divider.BorderSizePixel = 0
divider.Parent = card

local amount = Instance.new("TextLabel")
amount.Name = "Amount"
amount.BackgroundTransparency = 1
amount.Position = UDim2.fromOffset(26, 118)
amount.Size = UDim2.new(0.56, -26, 0, 55)
amount.Font = Enum.Font.GothamBlack
amount.Text = "+0 ESSENCE"
amount.TextSize = 34
amount.TextColor3 = Color3.fromRGB(113, 238, 211)
amount.TextTransparency = 1
amount.TextXAlignment = Enum.TextXAlignment.Left
amount.Parent = card

local detail = Instance.new("TextLabel")
detail.Name = "Detail"
detail.BackgroundTransparency = 1
detail.Position = UDim2.new(0.56, 0, 0, 121)
detail.Size = UDim2.new(0.44, -26, 0, 54)
detail.Font = Enum.Font.GothamMedium
detail.Text = "Banked safely\nRisk bonus applied"
detail.TextSize = 13
detail.TextColor3 = Color3.fromRGB(178, 192, 195)
detail.TextTransparency = 1
detail.TextWrapped = true
detail.TextXAlignment = Enum.TextXAlignment.Right
detail.TextYAlignment = Enum.TextYAlignment.Center
detail.Parent = card

local progressBack = Instance.new("Frame")
progressBack.Name = "ProgressBack"
progressBack.Position = UDim2.fromOffset(26, 190)
progressBack.Size = UDim2.new(1, -52, 0, 8)
progressBack.BackgroundColor3 = Color3.fromRGB(37, 47, 50)
progressBack.BackgroundTransparency = 1
progressBack.BorderSizePixel = 0
progressBack.Parent = card
local progressBackCorner = Instance.new("UICorner")
progressBackCorner.CornerRadius = UDim.new(1, 0)
progressBackCorner.Parent = progressBack

local progress = Instance.new("Frame")
progress.Name = "Progress"
progress.Size = UDim2.new(0, 0, 1, 0)
progress.BackgroundColor3 = Color3.fromRGB(93, 222, 198)
progress.BorderSizePixel = 0
progress.Parent = progressBack
local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(1, 0)
progressCorner.Parent = progress

local footer = Instance.new("TextLabel")
footer.Name = "Footer"
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(26, 207)
footer.Size = UDim2.new(1, -52, 0, 24)
footer.Font = Enum.Font.GothamMedium
footer.Text = "RETURNING TO SAFEHOUSE"
footer.TextSize = 11
footer.TextColor3 = Color3.fromRGB(116, 132, 137)
footer.TextTransparency = 1
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = card

local bloom = Lighting:FindFirstChild("VaultfallOutcomeBloom")
if not bloom then
    bloom = Instance.new("BloomEffect")
    bloom.Name = "VaultfallOutcomeBloom"
    bloom.Intensity = 0
    bloom.Size = 26
    bloom.Threshold = 1.15
    bloom.Parent = Lighting
end

local presentationToken = 0

local function setTheme(accent, amountColor)
    topBar.BackgroundColor3 = accent
    stroke.Color = accent
    divider.BackgroundColor3 = accent
    progress.BackgroundColor3 = accent
    amount.TextColor3 = amountColor or accent
end

local function resetVisuals()
    dim.BackgroundTransparency = 1
    topBar.BackgroundTransparency = 1
    card.BackgroundTransparency = 1
    stroke.Transparency = 1
    eyebrow.TextTransparency = 1
    title.TextTransparency = 1
    divider.BackgroundTransparency = 1
    amount.TextTransparency = 1
    detail.TextTransparency = 1
    progressBack.BackgroundTransparency = 1
    progress.Size = UDim2.new(0, 0, 1, 0)
    footer.TextTransparency = 1
    card.Position = UDim2.fromScale(0.5, 0.55)
end

local function hide(token)
    if token ~= presentationToken then
        return
    end

    TweenService:Create(dim, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Position = UDim2.fromScale(0.5, 0.49),
        BackgroundTransparency = 1,
    }):Play()
    for _, object in ipairs({ eyebrow, title, amount, detail, footer }) do
        TweenService:Create(object, TweenInfo.new(0.22), { TextTransparency = 1 }):Play()
    end
    for _, object in ipairs({ topBar, divider, progressBack }) do
        TweenService:Create(object, TweenInfo.new(0.22), { BackgroundTransparency = 1 }):Play()
    end
    TweenService:Create(stroke, TweenInfo.new(0.22), { Transparency = 1 }):Play()
    TweenService:Create(bloom, TweenInfo.new(0.35), { Intensity = 0 }):Play()

    task.delay(0.38, function()
        if token == presentationToken then
            dim.Visible = false
        end
    end)
end

local function present(config)
    presentationToken += 1
    local token = presentationToken

    resetVisuals()
    dim.Visible = true
    eyebrow.Text = config.Eyebrow or "OPERATION REPORT"
    title.Text = config.Title or "OPERATION COMPLETE"
    amount.Text = config.Amount or ""
    detail.Text = config.Detail or ""
    footer.Text = config.Footer or "RETURNING TO SAFEHOUSE"
    setTheme(config.Accent or Color3.fromRGB(93, 222, 198), config.AmountColor)

    TweenService:Create(dim, TweenInfo.new(0.22), { BackgroundTransparency = 0.22 }):Play()
    TweenService:Create(topBar, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
    TweenService:Create(card, TweenInfo.new(0.34, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 0.035,
    }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.3), { Transparency = 0.2 }):Play()
    TweenService:Create(bloom, TweenInfo.new(0.2), { Intensity = config.Bloom or 0.8 }):Play()

    task.delay(0.09, function()
        if token ~= presentationToken then return end
        TweenService:Create(eyebrow, TweenInfo.new(0.22), { TextTransparency = 0 }):Play()
        TweenService:Create(title, TweenInfo.new(0.28), { TextTransparency = 0 }):Play()
    end)
    task.delay(0.2, function()
        if token ~= presentationToken then return end
        TweenService:Create(divider, TweenInfo.new(0.22), { BackgroundTransparency = 0.12 }):Play()
        TweenService:Create(amount, TweenInfo.new(0.28), { TextTransparency = 0 }):Play()
        TweenService:Create(detail, TweenInfo.new(0.28), { TextTransparency = 0 }):Play()
    end)
    task.delay(0.32, function()
        if token ~= presentationToken then return end
        TweenService:Create(progressBack, TweenInfo.new(0.2), { BackgroundTransparency = 0.08 }):Play()
        TweenService:Create(progress, TweenInfo.new(config.Hold or 2.8, Enum.EasingStyle.Linear), {
            Size = UDim2.new(1, 0, 1, 0),
        }):Play()
        TweenService:Create(footer, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
    end)

    task.delay((config.Hold or 2.8) + 0.45, function()
        hide(token)
    end)
end

local function parseExtraction(text)
    local secured, bank, bonus = string.match(text, "EXTRACTED.*(%d+) Essence secured %((%d+) bank %+ (%d+) risk bonus%)")
    if not secured then
        return nil
    end
    return tonumber(secured) or 0, tonumber(bank) or 0, tonumber(bonus) or 0
end

local function parseComplete(text)
    local bank = string.match(text, "BREACH COMPLETE.*(%d+) unsecured Essence banked")
    if not bank then
        return nil
    end
    return tonumber(bank) or 0
end

local function parseFailure(text)
    local reason, lost = string.match(text, "BREACH FAILED.*— (.-) — (%d+) unsecured Essence lost")
    if not lost then
        return nil
    end
    return reason or "Squad lost", tonumber(lost) or 0
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind ~= "Notice" or type(payload) ~= "string" then
        return
    end

    if string.sub(payload, 1, 9) == "EXTRACTED" then
        local secured, bank, bonus = parseExtraction(payload)
        if secured then
            present({
                Eyebrow = "EMERGENCY EXTRACTION",
                Title = "ASSETS SECURED",
                Amount = string.format("+%d ESSENCE", secured),
                Detail = string.format("%d field bank\n+%d risk bonus", bank, bonus),
                Footer = "OPERATOR RETURNED TO SAFEHOUSE",
                Accent = Color3.fromRGB(93, 222, 198),
                AmountColor = Color3.fromRGB(122, 244, 218),
                Hold = 2.6,
                Bloom = 0.75,
            })
        end
        return
    end

    if string.sub(payload, 1, 15) == "BREACH COMPLETE" then
        local bank = parseComplete(payload)
        if bank then
            present({
                Eyebrow = "VAULT BREACH // COMPLETE",
                Title = "MISSION ACCOMPLISHED",
                Amount = string.format("+%d ESSENCE", bank),
                Detail = "Full-depth clear\nCompletion record updated",
                Footer = "DEBRIEF AND CAREER REWARDS PENDING IN SAFEHOUSE",
                Accent = Color3.fromRGB(238, 191, 93),
                AmountColor = Color3.fromRGB(255, 218, 132),
                Hold = 3.45,
                Bloom = 1.05,
            })
        end
        return
    end

    if string.sub(payload, 1, 13) == "BREACH FAILED" then
        local reason, lost = parseFailure(payload)
        if lost then
            present({
                Eyebrow = "OPERATION TERMINATED",
                Title = "BREACH FAILED",
                Amount = string.format("-%d ESSENCE", lost),
                Detail = string.format("%s\nUnsecured field bank lost", string.upper(reason)),
                Footer = "REGROUP // REARM // REDEPLOY",
                Accent = Color3.fromRGB(218, 79, 72),
                AmountColor = Color3.fromRGB(255, 111, 102),
                Hold = 2.35,
                Bloom = 0.7,
            })
        end
    end
end)
