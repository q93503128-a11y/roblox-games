local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local attackRemote = remotes:WaitForChild("Attack")
local skillRemote = remotes:WaitForChild("Skill")
local claimLootRemote = remotes:WaitForChild("ClaimLoot")
local stateRemote = remotes:WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "VaultfallHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function stroke(parent, transparency)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(116, 108, 133)
    s.Transparency = transparency or 0.45
    s.Thickness = 1
    s.Parent = parent
end

local function label(parent, name, text, size, position, textSize, alignment)
    local item = Instance.new("TextLabel")
    item.Name = name
    item.BackgroundTransparency = 1
    item.Size = size
    item.Position = position
    item.Font = Enum.Font.GothamMedium
    item.Text = text
    item.TextSize = textSize or 15
    item.TextColor3 = Color3.fromRGB(236, 235, 241)
    item.TextXAlignment = alignment or Enum.TextXAlignment.Left
    item.Parent = parent
    return item
end

local top = Instance.new("Frame")
top.Name = "RunBar"
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 12)
top.Size = UDim2.new(0, 370, 0, 48)
top.BackgroundColor3 = Color3.fromRGB(28, 27, 33)
top.BackgroundTransparency = 0.08
top.BorderSizePixel = 0
top.Parent = gui
corner(top, 10)
stroke(top)

local runTitle = label(top, "RunTitle", "HUB  •  Enter the Vault", UDim2.new(1, -24, 1, 0), UDim2.fromOffset(12, 0), 16, Enum.TextXAlignment.Center)

local stats = Instance.new("Frame")
stats.Name = "Stats"
stats.AnchorPoint = Vector2.new(1, 0)
stats.Position = UDim2.new(1, -14, 0, 14)
stats.Size = UDim2.fromOffset(190, 70)
stats.BackgroundColor3 = Color3.fromRGB(28, 27, 33)
stats.BackgroundTransparency = 0.08
stats.BorderSizePixel = 0
stats.Parent = gui
corner(stats, 10)
stroke(stats)

local essenceLabel = label(stats, "Essence", "Essence  0", UDim2.new(1, -20, 0, 28), UDim2.fromOffset(10, 7), 14)
local rankLabel = label(stats, "Rank", "Power Rank  0", UDim2.new(1, -20, 0, 28), UDim2.fromOffset(10, 35), 14)

local healthPanel = Instance.new("Frame")
healthPanel.Name = "HealthPanel"
healthPanel.AnchorPoint = Vector2.new(0, 1)
healthPanel.Position = UDim2.new(0, 16, 1, -18)
healthPanel.Size = UDim2.fromOffset(260, 54)
healthPanel.BackgroundColor3 = Color3.fromRGB(28, 27, 33)
healthPanel.BackgroundTransparency = 0.08
healthPanel.BorderSizePixel = 0
healthPanel.Parent = gui
corner(healthPanel, 10)
stroke(healthPanel)

local healthText = label(healthPanel, "HealthText", "HP  -- / --", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 5), 13)
local healthBack = Instance.new("Frame")
healthBack.Position = UDim2.fromOffset(10, 31)
healthBack.Size = UDim2.new(1, -20, 0, 12)
healthBack.BackgroundColor3 = Color3.fromRGB(48, 46, 53)
healthBack.BorderSizePixel = 0
healthBack.Parent = healthPanel
corner(healthBack, 6)
local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1, 1)
healthFill.BackgroundColor3 = Color3.fromRGB(116, 171, 120)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthBack
corner(healthFill, 6)

local controls = Instance.new("Frame")
controls.Name = "Controls"
controls.AnchorPoint = Vector2.new(0.5, 1)
controls.Position = UDim2.new(0.5, 0, 1, -18)
controls.Size = UDim2.fromOffset(420, 64)
controls.BackgroundColor3 = Color3.fromRGB(28, 27, 33)
controls.BackgroundTransparency = 0.08
controls.BorderSizePixel = 0
controls.Parent = gui
corner(controls, 10)
stroke(controls)

local weaponLabel = label(controls, "Weapon", "Worn Blade  •  12 Power", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 5), 14, Enum.TextXAlignment.Center)
local controlLabel = label(controls, "Keys", "LMB Attack     E Heavy     Q Dash     R Whirl", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(10, 32), 12, Enum.TextXAlignment.Center)
controlLabel.TextColor3 = Color3.fromRGB(183, 180, 193)

local notice = label(gui, "Notice", "", UDim2.new(0, 520, 0, 38), UDim2.new(0.5, -260, 0, 70), 16, Enum.TextXAlignment.Center)
notice.BackgroundColor3 = Color3.fromRGB(22, 21, 27)
notice.BackgroundTransparency = 1
notice.TextTransparency = 1
notice.BorderSizePixel = 0
corner(notice, 8)

local hitText = label(gui, "HitFeedback", "", UDim2.fromOffset(220, 38), UDim2.new(0.5, -110, 0.5, -100), 22, Enum.TextXAlignment.Center)
hitText.TextTransparency = 1
hitText.TextStrokeTransparency = 0.4

local loot = Instance.new("Frame")
loot.Name = "LootOffer"
loot.AnchorPoint = Vector2.new(0.5, 0.5)
loot.Position = UDim2.fromScale(0.5, 0.5)
loot.Size = UDim2.fromOffset(390, 250)
loot.BackgroundColor3 = Color3.fromRGB(26, 25, 31)
loot.BorderSizePixel = 0
loot.Visible = false
loot.Parent = gui
corner(loot, 14)
stroke(loot, 0.2)

local lootHeader = label(loot, "Header", "VAULT DROP", UDim2.new(1, -28, 0, 34), UDim2.fromOffset(14, 12), 13, Enum.TextXAlignment.Center)
lootHeader.TextColor3 = Color3.fromRGB(174, 160, 210)
local lootName = label(loot, "Name", "Weapon", UDim2.new(1, -28, 0, 36), UDim2.fromOffset(14, 48), 22, Enum.TextXAlignment.Center)
local lootStats = label(loot, "Stats", "", UDim2.new(1, -28, 0, 70), UDim2.fromOffset(14, 91), 14, Enum.TextXAlignment.Center)
lootStats.TextWrapped = true
local currentStats = label(loot, "Current", "", UDim2.new(1, -28, 0, 42), UDim2.fromOffset(14, 151), 12, Enum.TextXAlignment.Center)
currentStats.TextColor3 = Color3.fromRGB(174, 172, 184)

local function button(parent, text, position)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(150, 42)
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(70, 63, 86)
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(244, 243, 247)
    b.Parent = parent
    corner(b, 8)
    return b
end

local equipButton = button(loot, "EQUIP", UDim2.new(0.5, -160, 1, -55))
local skipButton = button(loot, "SKIP", UDim2.new(0.5, 10, 1, -55))
skipButton.BackgroundColor3 = Color3.fromRGB(52, 50, 58)

equipButton.Activated:Connect(function()
    loot.Visible = false
    claimLootRemote:FireServer(true)
end)
skipButton.Activated:Connect(function()
    loot.Visible = false
    claimLootRemote:FireServer(false)
end)

local noticeToken = 0
local function showNotice(text)
    noticeToken += 1
    local token = noticeToken
    notice.Text = tostring(text)
    notice.BackgroundTransparency = 0.12
    notice.TextTransparency = 0
    task.delay(2.4, function()
        if token ~= noticeToken then
            return
        end
        TweenService:Create(notice, TweenInfo.new(0.3), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
    end)
end

local hitToken = 0
local function showHit(payload)
    hitToken += 1
    local token = hitToken
    if payload.Kill and (payload.Damage or 0) <= 0 then
        hitText.Text = "DEFEATED " .. tostring(payload.Enemy or "ENEMY")
    else
        hitText.Text = string.format("%s%d", payload.Crit and "CRIT  " or "", payload.Damage or 0)
    end
    hitText.TextColor3 = payload.Crit and Color3.fromRGB(236, 188, 91) or Color3.fromRGB(242, 239, 246)
    hitText.TextTransparency = 0
    hitText.Position = UDim2.new(0.5, -110, 0.5, -100)
    TweenService:Create(hitText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -110, 0.5, -128),
        TextTransparency = 1,
    }):Play()
    task.delay(0.55, function()
        if token == hitToken then
            hitText.Text = ""
        end
    end)
end

local function aimDirection()
    local camera = workspace.CurrentCamera
    if camera then
        return camera.CFrame.LookVector
    end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    return root and root.CFrame.LookVector or Vector3.new(0, 0, -1)
end

local function fireAttack(name)
    attackRemote:FireServer(name, aimDirection())
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or loot.Visible then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        fireAttack("Basic")
    elseif input.KeyCode == Enum.KeyCode.E then
        fireAttack("Heavy")
    elseif input.KeyCode == Enum.KeyCode.R then
        fireAttack("Whirl")
    elseif input.KeyCode == Enum.KeyCode.Q then
        skillRemote:FireServer("Dash", aimDirection())
    end
end)

local function touchAction(name, inputState)
    if inputState ~= Enum.UserInputState.Begin or loot.Visible then
        return Enum.ContextActionResult.Sink
    end
    if name == "VaultfallAttack" then
        fireAttack("Basic")
    elseif name == "VaultfallHeavy" then
        fireAttack("Heavy")
    elseif name == "VaultfallWhirl" then
        fireAttack("Whirl")
    elseif name == "VaultfallDash" then
        skillRemote:FireServer("Dash", aimDirection())
    end
    return Enum.ContextActionResult.Sink
end

if UserInputService.TouchEnabled then
    ContextActionService:BindAction("VaultfallAttack", touchAction, true, Enum.KeyCode.ButtonR2)
    ContextActionService:BindAction("VaultfallHeavy", touchAction, true, Enum.KeyCode.ButtonX)
    ContextActionService:BindAction("VaultfallDash", touchAction, true, Enum.KeyCode.ButtonB)
    ContextActionService:BindAction("VaultfallWhirl", touchAction, true, Enum.KeyCode.ButtonY)
    ContextActionService:SetTitle("VaultfallAttack", "ATTACK")
    ContextActionService:SetTitle("VaultfallHeavy", "HEAVY")
    ContextActionService:SetTitle("VaultfallDash", "DASH")
    ContextActionService:SetTitle("VaultfallWhirl", "WHIRL")
end

local function bindHealth(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then
        return
    end
    local function refresh()
        local ratio = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth or 0
        healthFill.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
        healthText.Text = string.format("HP  %d / %d", math.ceil(humanoid.Health), math.ceil(humanoid.MaxHealth))
    end
    humanoid.HealthChanged:Connect(refresh)
    humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(refresh)
    refresh()
end

player.CharacterAdded:Connect(bindHealth)
if player.Character then
    task.spawn(bindHealth, player.Character)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Profile" then
        essenceLabel.Text = string.format("Essence  %d", payload.Essence or 0)
        rankLabel.Text = string.format("Power Rank  %d", payload.PowerRank or 0)
    elseif kind == "Run" then
        if payload.Active then
            runTitle.Text = string.format("ROOM %d / %d   •   %s   •   %d LEFT", payload.Room or 0, payload.TotalRooms or 8, tostring(payload.RoomType or ""), payload.EnemyCount or 0)
        else
            runTitle.Text = "HUB  •  Enter the Vault"
        end
    elseif kind == "Weapon" then
        weaponLabel.Text = string.format("%s  •  %d Power  •  %s", payload.Name or "Weapon", payload.Power or 0, payload.Rarity or "Common")
    elseif kind == "LootOffer" then
        local offered = payload.Offered
        local equipped = payload.Equipped
        lootName.Text = string.format("%s  [%s]", offered.Name or "Unknown", offered.Rarity or "Common")
        lootStats.Text = string.format("Power  %d\nCrit  %d%%  •  Crit Damage  %.2fx", offered.Power or 0, math.floor((offered.CritChance or 0) * 100 + 0.5), offered.CritMultiplier or 1.5)
        currentStats.Text = equipped and string.format("Current: %s  •  %d Power", equipped.Name or "Weapon", equipped.Power or 0) or ""
        loot.Visible = true
    elseif kind == "Notice" then
        showNotice(payload)
    elseif kind == "Hit" then
        showHit(payload)
    end
end)
