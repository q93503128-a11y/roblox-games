local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Arsenal = require(shared:WaitForChild("Arsenal"))
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local attackRemote = remotes:WaitForChild("Attack")
local skillRemote = remotes:WaitForChild("Skill")
local claimLootRemote = remotes:WaitForChild("ClaimLoot")
local stateRemote = remotes:WaitForChild("State")
local readyRemote = remotes:WaitForChild("Ready")

local gui = Instance.new("ScreenGui")
gui.Name = "BreachHUD"
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
    s.Color = Color3.fromRGB(104, 126, 139)
    s.Transparency = transparency or 0.48
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
    item.TextColor3 = Color3.fromRGB(235, 239, 242)
    item.TextXAlignment = alignment or Enum.TextXAlignment.Left
    item.Parent = parent
    return item
end

local top = Instance.new("Frame")
top.Name = "MissionBar"
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 12)
top.Size = UDim2.fromOffset(420, 50)
top.BackgroundColor3 = Color3.fromRGB(18, 23, 28)
top.BackgroundTransparency = 0.08
top.BorderSizePixel = 0
top.Parent = gui
corner(top, 8)
stroke(top)
local runTitle = label(top, "RunTitle", "SAFEHOUSE  •  OPERATIONS READY", UDim2.new(1, -24, 1, 0), UDim2.fromOffset(12, 0), 15, Enum.TextXAlignment.Center)

local stats = Instance.new("Frame")
stats.AnchorPoint = Vector2.new(1, 0)
stats.Position = UDim2.new(1, -14, 0, 14)
stats.Size = UDim2.fromOffset(190, 70)
stats.BackgroundColor3 = Color3.fromRGB(18, 23, 28)
stats.BackgroundTransparency = 0.08
stats.BorderSizePixel = 0
stats.Parent = gui
corner(stats, 8)
stroke(stats)
local essenceLabel = label(stats, "Essence", "Essence  0", UDim2.new(1, -20, 0, 28), UDim2.fromOffset(10, 7), 13)
local rankLabel = label(stats, "Rank", "Power Rank  0", UDim2.new(1, -20, 0, 28), UDim2.fromOffset(10, 35), 13)

local healthPanel = Instance.new("Frame")
healthPanel.AnchorPoint = Vector2.new(0, 1)
healthPanel.Position = UDim2.new(0, 16, 1, -18)
healthPanel.Size = UDim2.fromOffset(260, 54)
healthPanel.BackgroundColor3 = Color3.fromRGB(18, 23, 28)
healthPanel.BackgroundTransparency = 0.08
healthPanel.BorderSizePixel = 0
healthPanel.Parent = gui
corner(healthPanel, 8)
stroke(healthPanel)
local healthText = label(healthPanel, "HealthText", "HP  -- / --", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 5), 13)
local healthBack = Instance.new("Frame")
healthBack.Position = UDim2.fromOffset(10, 31)
healthBack.Size = UDim2.new(1, -20, 0, 11)
healthBack.BackgroundColor3 = Color3.fromRGB(45, 50, 55)
healthBack.BorderSizePixel = 0
healthBack.Parent = healthPanel
corner(healthBack, 5)
local healthFill = Instance.new("Frame")
healthFill.Size = UDim2.fromScale(1, 1)
healthFill.BackgroundColor3 = Color3.fromRGB(100, 181, 129)
healthFill.BorderSizePixel = 0
healthFill.Parent = healthBack
corner(healthFill, 5)

local weaponPanel = Instance.new("Frame")
weaponPanel.AnchorPoint = Vector2.new(1, 1)
weaponPanel.Position = UDim2.new(1, -16, 1, -18)
weaponPanel.Size = UDim2.fromOffset(300, 86)
weaponPanel.BackgroundColor3 = Color3.fromRGB(18, 23, 28)
weaponPanel.BackgroundTransparency = 0.06
weaponPanel.BorderSizePixel = 0
weaponPanel.Parent = gui
corner(weaponPanel, 9)
stroke(weaponPanel, 0.34)
local weaponName = label(weaponPanel, "WeaponName", "PX-9 SERVICE CARBINE", UDim2.new(1, -20, 0, 24), UDim2.fromOffset(10, 7), 14, Enum.TextXAlignment.Right)
weaponName.Font = Enum.Font.GothamBold
local weaponTrait = label(weaponPanel, "WeaponTrait", "Balanced rifle", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 29), 11, Enum.TextXAlignment.Right)
weaponTrait.TextColor3 = Color3.fromRGB(157, 172, 181)
local ammoLabel = label(weaponPanel, "Ammo", "30 / 30", UDim2.new(1, -20, 0, 31), UDim2.fromOffset(10, 48), 25, Enum.TextXAlignment.Right)
ammoLabel.Font = Enum.Font.GothamBold

local controls = label(gui, "Controls", "LMB FIRE   •   RMB AIM   •   R RELOAD   •   Q DASH", UDim2.fromOffset(520, 26), UDim2.new(0.5, -260, 1, -43), 11, Enum.TextXAlignment.Center)
controls.TextColor3 = Color3.fromRGB(151, 162, 170)

local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
crosshair.Position = UDim2.fromScale(0.5, 0.5)
crosshair.Size = UDim2.fromOffset(4, 4)
crosshair.BackgroundColor3 = Color3.fromRGB(235, 243, 246)
crosshair.BorderSizePixel = 0
crosshair.Parent = gui
corner(crosshair, 2)
local crossParts = {}
for index, offset in ipairs({ Vector2.new(0, -11), Vector2.new(0, 11), Vector2.new(-11, 0), Vector2.new(11, 0) }) do
    local piece = Instance.new("Frame")
    piece.AnchorPoint = Vector2.new(0.5, 0.5)
    piece.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)
    piece.Size = (index <= 2) and UDim2.fromOffset(2, 7) or UDim2.fromOffset(7, 2)
    piece.BackgroundColor3 = crosshair.BackgroundColor3
    piece.BorderSizePixel = 0
    piece.Parent = crosshair
    table.insert(crossParts, piece)
end

local notice = label(gui, "Notice", "", UDim2.fromOffset(520, 38), UDim2.new(0.5, -260, 0, 72), 15, Enum.TextXAlignment.Center)
notice.BackgroundColor3 = Color3.fromRGB(15, 20, 24)
notice.BackgroundTransparency = 1
notice.TextTransparency = 1
notice.BorderSizePixel = 0
corner(notice, 7)

local hitText = label(gui, "HitFeedback", "", UDim2.fromOffset(220, 38), UDim2.new(0.5, -110, 0.5, -82), 21, Enum.TextXAlignment.Center)
hitText.TextTransparency = 1
hitText.TextStrokeTransparency = 0.45

local loot = Instance.new("Frame")
loot.Name = "LootOffer"
loot.AnchorPoint = Vector2.new(0.5, 0.5)
loot.Position = UDim2.fromScale(0.5, 0.5)
loot.Size = UDim2.fromOffset(430, 282)
loot.BackgroundColor3 = Color3.fromRGB(18, 23, 28)
loot.BorderSizePixel = 0
loot.Visible = false
loot.Parent = gui
corner(loot, 12)
stroke(loot, 0.2)
local lootHeader = label(loot, "Header", "FIELD CACHE", UDim2.new(1, -28, 0, 30), UDim2.fromOffset(14, 12), 12, Enum.TextXAlignment.Center)
lootHeader.TextColor3 = Color3.fromRGB(139, 189, 202)
local lootName = label(loot, "Name", "Weapon", UDim2.new(1, -28, 0, 38), UDim2.fromOffset(14, 44), 21, Enum.TextXAlignment.Center)
lootName.Font = Enum.Font.GothamBold
local lootRole = label(loot, "Role", "", UDim2.new(1, -28, 0, 26), UDim2.fromOffset(14, 82), 12, Enum.TextXAlignment.Center)
lootRole.TextColor3 = Color3.fromRGB(158, 176, 186)
local lootStats = label(loot, "Stats", "", UDim2.new(1, -28, 0, 70), UDim2.fromOffset(14, 111), 13, Enum.TextXAlignment.Center)
lootStats.TextWrapped = true
local currentStats = label(loot, "Current", "", UDim2.new(1, -28, 0, 38), UDim2.fromOffset(14, 176), 11, Enum.TextXAlignment.Center)
currentStats.TextColor3 = Color3.fromRGB(163, 169, 176)

local function button(parent, text, position)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(164, 42)
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(47, 92, 104)
    b.BorderSizePixel = 0
    b.AutoButtonColor = true
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(241, 246, 248)
    b.Parent = parent
    corner(b, 7)
    return b
end
local equipButton = button(loot, "EQUIP", UDim2.new(0.5, -174, 1, -55))
local skipButton = button(loot, "SALVAGE / SKIP", UDim2.new(0.5, 10, 1, -55))
skipButton.BackgroundColor3 = Color3.fromRGB(47, 51, 56)
equipButton.Activated:Connect(function()
    loot.Visible = false
    claimLootRemote:FireServer(true)
end)
skipButton.Activated:Connect(function()
    loot.Visible = false
    claimLootRemote:FireServer(false)
end)

local currentWeapon = {
    Name = "PX-9 Service Carbine",
    Archetype = "Carbine",
    Power = 14,
    Rarity = "Common",
}
local currentDefinition = Arsenal.Get("Carbine")
local ammo = currentDefinition.Magazine
local magazine = currentDefinition.Magazine
local reloading = false
local triggerHeld = false
local aiming = false
local nextLocalShot = 0

local viewModel
local muzzle
local viewAccent
local recoilKick = 0
local recoilSide = 0
local reloadStarted = 0
local reloadDuration = 0
local swapStarted = 0
local lastPosition = Vector3.zero
local movementSpeed = 0

local function part(parent, name, size, cframe, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cframe
    p.Color = color
    p.Material = material or Enum.Material.Metal
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = false
    p.Parent = parent
    return p
end

local function clearViewModel()
    if viewModel then
        viewModel:Destroy()
        viewModel = nil
    end
end

local function buildViewModel(archetype)
    clearViewModel()
    local definition = Arsenal.Get(archetype) or Arsenal.Get("Carbine")
    viewAccent = definition.Accent
    local model = Instance.new("Model")
    model.Name = "BreachWeaponViewmodel"
    viewModel = model

    local dark = Color3.fromRGB(31, 36, 40)
    local black = Color3.fromRGB(16, 19, 21)
    local accent = definition.Accent
    local root = part(model, "Receiver", Vector3.new(0.5, 0.55, 2.35), CFrame.new(), dark)
    model.PrimaryPart = root

    if archetype == "SMG" then
        root.Size = Vector3.new(0.52, 0.58, 1.72)
        part(model, "Shroud", Vector3.new(0.62, 0.48, 0.95), CFrame.new(0, 0.02, -1.15), accent)
        part(model, "Stock", Vector3.new(0.28, 0.3, 0.82), CFrame.new(0, 0.05, 1.28), black)
        part(model, "Magazine", Vector3.new(0.33, 0.92, 0.45), CFrame.new(0, -0.62, 0.2) * CFrame.Angles(math.rad(-10), 0, 0), black)
        muzzle = part(model, "Muzzle", Vector3.new(0.22, 0.22, 0.55), CFrame.new(0, 0, -1.92), accent, Enum.Material.Neon)
    elseif archetype == "Shotgun" then
        root.Size = Vector3.new(0.62, 0.62, 2.65)
        part(model, "Pump", Vector3.new(0.72, 0.54, 0.88), CFrame.new(0, -0.05, -1.36), accent)
        part(model, "Stock", Vector3.new(0.45, 0.52, 1.35), CFrame.new(0, -0.03, 1.78), black)
        part(model, "Tube", Vector3.new(0.20, 0.20, 2.1), CFrame.new(0, -0.36, -1.35), black)
        muzzle = part(model, "Muzzle", Vector3.new(0.36, 0.36, 0.62), CFrame.new(0, 0.03, -2.72), accent, Enum.Material.Neon)
    elseif archetype == "RailRifle" then
        root.Size = Vector3.new(0.58, 0.6, 3.15)
        part(model, "RailTop", Vector3.new(0.26, 0.22, 2.65), CFrame.new(0, 0.42, -0.5), accent, Enum.Material.Neon)
        part(model, "Stock", Vector3.new(0.48, 0.48, 1.48), CFrame.new(0, -0.02, 2.02), black)
        part(model, "Cell", Vector3.new(0.42, 0.72, 0.72), CFrame.new(0, -0.58, 0.35), accent, Enum.Material.Neon)
        part(model, "Scope", Vector3.new(0.35, 0.34, 0.95), CFrame.new(0, 0.55, 0.35), black)
        muzzle = part(model, "Muzzle", Vector3.new(0.28, 0.28, 0.78), CFrame.new(0, 0.03, -3.18), accent, Enum.Material.Neon)
    else
        part(model, "Handguard", Vector3.new(0.62, 0.52, 1.35), CFrame.new(0, 0, -1.48), accent)
        part(model, "Stock", Vector3.new(0.40, 0.48, 1.25), CFrame.new(0, -0.02, 1.72), black)
        part(model, "Magazine", Vector3.new(0.34, 0.86, 0.52), CFrame.new(0, -0.63, 0.35) * CFrame.Angles(math.rad(-8), 0, 0), black)
        part(model, "Sight", Vector3.new(0.24, 0.28, 0.55), CFrame.new(0, 0.48, -0.15), black)
        muzzle = part(model, "Muzzle", Vector3.new(0.24, 0.24, 0.72), CFrame.new(0, 0.02, -2.72), accent, Enum.Material.Neon)
    end

    muzzle.Transparency = 0.55
    local flash = Instance.new("PointLight")
    flash.Name = "Flash"
    flash.Color = accent
    flash.Brightness = 0
    flash.Range = 12
    flash.Parent = muzzle

    local camera = workspace.CurrentCamera
    if camera then
        model.Parent = camera
    end
    swapStarted = os.clock()
end

local function visualRay()
    local camera = workspace.CurrentCamera
    if not camera then
        return Vector3.new(0, 0, -1), nil
    end
    local direction = camera.CFrame.LookVector
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = player.Character and { player.Character, viewModel } or { viewModel }
    params.IgnoreWater = true
    local cast = workspace:Raycast(camera.CFrame.Position, direction * (currentDefinition.Range or 160), params)
    return direction, cast and cast.Position or (camera.CFrame.Position + direction * (currentDefinition.Range or 160))
end

local function tracer(target)
    if not muzzle or not target then
        return
    end
    local origin = muzzle.Position
    local distance = (target - origin).Magnitude
    if distance <= 0.1 then
        return
    end
    local beam = Instance.new("Part")
    beam.Name = "LocalTracer"
    beam.Anchored = true
    beam.CanCollide = false
    beam.CanTouch = false
    beam.CanQuery = false
    beam.Material = Enum.Material.Neon
    beam.Color = viewAccent or Color3.new(1, 1, 1)
    beam.Size = Vector3.new(0.035, 0.035, distance)
    beam.CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -distance / 2)
    beam.Transparency = currentWeapon.Archetype == "RailRifle" and 0.08 or 0.28
    beam.Parent = workspace
    TweenService:Create(beam, TweenInfo.new(currentWeapon.Archetype == "RailRifle" and 0.18 or 0.08), { Transparency = 1 }):Play()
    Debris:AddItem(beam, 0.22)
end

local function muzzleFlash()
    if not muzzle then
        return
    end
    local flash = muzzle:FindFirstChild("Flash")
    if flash then
        flash.Brightness = currentWeapon.Archetype == "RailRifle" and 8 or 5
        task.delay(0.035, function()
            if flash.Parent then
                flash.Brightness = 0
            end
        end)
    end
    local old = muzzle.Transparency
    muzzle.Transparency = 0.02
    task.delay(0.045, function()
        if muzzle.Parent then
            muzzle.Transparency = old
        end
    end)
end

local function fireLocal()
    if reloading or loot.Visible or ammo <= 0 then
        if ammo <= 0 and not reloading then
            attackRemote:FireServer("Reload")
        end
        return
    end
    local now = os.clock()
    local interval = (currentDefinition.FireInterval or 0.15) * (currentWeapon.FireIntervalMultiplier or 1)
    if now < nextLocalShot then
        return
    end
    nextLocalShot = now + interval
    ammo = math.max(0, ammo - 1)
    ammoLabel.Text = string.format("%d / %d", ammo, magazine)
    local direction, target = visualRay()
    attackRemote:FireServer("Fire", direction)
    recoilKick = math.min(3.2, recoilKick + (currentDefinition.Recoil or 0.6) * (currentWeapon.RecoilMultiplier or 1))
    recoilSide += (math.random() - 0.5) * 0.35
    muzzleFlash()
    tracer(target)
end

local function setWeapon(payload)
    currentWeapon = payload or currentWeapon
    currentWeapon.Archetype = currentWeapon.Archetype or "Carbine"
    currentDefinition = Arsenal.Get(currentWeapon.Archetype) or Arsenal.Get("Carbine")
    magazine = math.max(1, math.floor(currentDefinition.Magazine * (currentWeapon.MagazineMultiplier or 1) + 0.5))
    ammo = magazine
    reloading = false
    weaponName.Text = string.upper(currentWeapon.Name or currentDefinition.DisplayName)
    local trait = currentWeapon.TraitName and ("  •  " .. currentWeapon.TraitName) or ""
    weaponTrait.Text = string.format("%s%s  •  %d POWER", currentDefinition.Role, trait, currentWeapon.Power or 0)
    ammoLabel.Text = string.format("%d / %d", ammo, magazine)
    buildViewModel(currentWeapon.Archetype)
end

local noticeToken = 0
local function showNotice(text)
    noticeToken += 1
    local token = noticeToken
    notice.Text = tostring(text)
    notice.BackgroundTransparency = 0.12
    notice.TextTransparency = 0
    task.delay(2.35, function()
        if token == noticeToken then
            TweenService:Create(notice, TweenInfo.new(0.28), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
        end
    end)
end

local hitToken = 0
local function showHit(payload)
    hitToken += 1
    local token = hitToken
    if payload.Kill and (payload.Damage or 0) <= 0 then
        hitText.Text = "TARGET DOWN"
    else
        hitText.Text = string.format("%s%d", payload.Crit and "CRIT  " or "", payload.Damage or 0)
    end
    hitText.TextColor3 = payload.Crit and Color3.fromRGB(239, 190, 93) or Color3.fromRGB(238, 245, 247)
    hitText.TextTransparency = 0
    hitText.Position = UDim2.new(0.5, -110, 0.5, -82)
    TweenService:Create(hitText, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -110, 0.5, -108),
        TextTransparency = 1,
    }):Play()
    task.delay(0.45, function()
        if token == hitToken then
            hitText.Text = ""
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or loot.Visible then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        triggerHeld = true
        fireLocal()
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    elseif input.KeyCode == Enum.KeyCode.R then
        attackRemote:FireServer("Reload")
    elseif input.KeyCode == Enum.KeyCode.Q then
        local direction = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.LookVector or Vector3.new(0, 0, -1)
        skillRemote:FireServer("Dash", direction)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        triggerHeld = false
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

local function touchAction(name, inputState)
    if inputState ~= Enum.UserInputState.Begin or loot.Visible then
        return Enum.ContextActionResult.Sink
    end
    if name == "BreachFire" then
        fireLocal()
    elseif name == "BreachReload" then
        attackRemote:FireServer("Reload")
    elseif name == "BreachDash" then
        local direction = workspace.CurrentCamera and workspace.CurrentCamera.CFrame.LookVector or Vector3.new(0, 0, -1)
        skillRemote:FireServer("Dash", direction)
    end
    return Enum.ContextActionResult.Sink
end

if UserInputService.TouchEnabled then
    ContextActionService:BindAction("BreachFire", touchAction, true, Enum.KeyCode.ButtonR2)
    ContextActionService:BindAction("BreachReload", touchAction, true, Enum.KeyCode.ButtonX)
    ContextActionService:BindAction("BreachDash", touchAction, true, Enum.KeyCode.ButtonB)
    ContextActionService:SetTitle("BreachFire", "FIRE")
    ContextActionService:SetTitle("BreachReload", "RELOAD")
    ContextActionService:SetTitle("BreachDash", "DASH")
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

RunService.RenderStepped:Connect(function(dt)
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end
    if viewModel and viewModel.Parent ~= camera then
        viewModel.Parent = camera
    end

    if triggerHeld and currentDefinition.FireMode == "Auto" then
        fireLocal()
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        if lastPosition.Magnitude > 0 then
            movementSpeed = math.clamp((root.Position - lastPosition).Magnitude / math.max(dt, 0.001), 0, 22)
        end
        lastPosition = root.Position
    end

    recoilKick *= math.exp(-dt * 13)
    recoilSide *= math.exp(-dt * 11)
    local t = os.clock()
    local moveFactor = math.clamp(movementSpeed / 16, 0, 1)
    local bobX = math.sin(t * 9.2) * 0.018 * moveFactor
    local bobY = math.abs(math.cos(t * 9.2)) * 0.018 * moveFactor
    local idle = math.sin(t * 1.8) * 0.006
    local baseX = aiming and 0.02 or 0.62
    local baseY = aiming and -0.38 or -0.62
    local baseZ = aiming and -1.45 or -1.78
    local animation = CFrame.new(baseX + bobX + recoilSide * 0.02, baseY + bobY + idle, baseZ + recoilKick * 0.09)
        * CFrame.Angles(math.rad(-4 - recoilKick * 1.7), math.rad(recoilSide), math.rad(aiming and 0 or -2.5))

    if reloadDuration > 0 then
        local phase = math.clamp((t - reloadStarted) / reloadDuration, 0, 1)
        if phase < 1 then
            local arc = math.sin(phase * math.pi)
            animation *= CFrame.new(0.1 * arc, -0.48 * arc, 0.24 * arc) * CFrame.Angles(math.rad(44 * arc), 0, math.rad(24 * arc))
        else
            reloadDuration = 0
        end
    end

    local swapPhase = math.clamp((t - swapStarted) / 0.5, 0, 1)
    if swapPhase < 1 then
        local drop = (1 - swapPhase) ^ 2
        animation *= CFrame.new(0, -0.8 * drop, 0.35 * drop) * CFrame.Angles(math.rad(25 * drop), 0, 0)
    end

    if viewModel and viewModel.PrimaryPart then
        viewModel:PivotTo(camera.CFrame * animation)
    end

    local targetFov = aiming and 58 or 70
    camera.FieldOfView += (targetFov - camera.FieldOfView) * math.min(1, dt * 10)
end)

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Profile" then
        essenceLabel.Text = string.format("Essence  %d", payload.Essence or 0)
        rankLabel.Text = string.format("Power Rank  %d", payload.PowerRank or 0)
    elseif kind == "Run" then
        if payload.Active then
            runTitle.Text = string.format("SECTOR %02d / %02d   •   %s   •   %d HOSTILES", payload.Room or 0, payload.TotalRooms or 12, string.upper(tostring(payload.RoomType or "")), payload.EnemyCount or 0)
        else
            runTitle.Text = "SAFEHOUSE  •  OPERATIONS READY"
        end
    elseif kind == "Weapon" then
        setWeapon(payload)
    elseif kind == "Combat" then
        ammo = payload.Ammo or ammo
        magazine = payload.Magazine or magazine
        reloading = payload.Reloading == true
        ammoLabel.Text = reloading and string.format("RELOADING  •  %d / %d", ammo, magazine) or string.format("%d / %d", ammo, magazine)
    elseif kind == "WeaponFX" then
        if payload.Kind == "Reload" then
            reloadStarted = os.clock()
            reloadDuration = payload.Duration or 1.8
            reloading = true
        elseif payload.Kind == "Shot" then
            recoilKick = math.max(recoilKick, (payload.Recoil or 0.5) * 0.55)
        elseif payload.Kind == "Dash" then
            recoilKick = math.max(recoilKick, 0.8)
        end
    elseif kind == "LootOffer" then
        local offered = payload.Offered
        local equipped = payload.Equipped
        local definition = Arsenal.Get(offered.Archetype or "Carbine") or Arsenal.Get("Carbine")
        lootName.Text = string.format("%s  [%s]", offered.Name or "Unknown", offered.Rarity or "Common")
        lootRole.Text = string.format("%s  •  %s", definition.Role, offered.TraitName or "Standard issue")
        lootStats.Text = string.format("Power  %d\nCrit  %d%%  •  Crit Damage  %.2fx\n%d rounds  •  %.2fs reload", offered.Power or 0, math.floor((offered.CritChance or 0) * 100 + 0.5), offered.CritMultiplier or 1.5, math.floor(definition.Magazine * (offered.MagazineMultiplier or 1) + 0.5), definition.ReloadTime * (offered.ReloadMultiplier or 1))
        currentStats.Text = equipped and string.format("CURRENT  •  %s  •  %d POWER", equipped.Name or "Weapon", equipped.Power or 0) or ""
        loot.Visible = true
    elseif kind == "Notice" then
        showNotice(payload)
    elseif kind == "Hit" then
        showHit(payload)
    end
end)

setWeapon(currentWeapon)
readyRemote:FireServer()
