local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Arsenal = require(shared:WaitForChild("Arsenal"))
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local currentDefinition = Arsenal.Get(currentArchetype)
local reloadStarted = -100
local reloadDuration = 0
local reloadToken = 0
local lastWeaponName = ""
local activeGhosts = {}

local function getHud()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    return playerGui and playerGui:FindFirstChild("BreachHUD")
end

local function ensureActionHud()
    local hud = getHud()
    if not hud then
        return nil
    end

    local existing = hud:FindFirstChild("WeaponAction")
    if existing then
        return existing
    end

    local holder = Instance.new("Frame")
    holder.Name = "WeaponAction"
    holder.AnchorPoint = Vector2.new(0.5, 1)
    holder.Position = UDim2.new(0.5, 0, 1, -76)
    holder.Size = UDim2.fromOffset(250, 38)
    holder.BackgroundTransparency = 1
    holder.Visible = false
    holder.Parent = hud

    local label = Instance.new("TextLabel")
    label.Name = "Stage"
    label.AnchorPoint = Vector2.new(0.5, 0)
    label.Position = UDim2.new(0.5, 0, 0, 0)
    label.Size = UDim2.fromOffset(250, 18)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(215, 226, 232)
    label.Text = ""
    label.Parent = holder

    local back = Instance.new("Frame")
    back.Name = "Back"
    back.AnchorPoint = Vector2.new(0.5, 0)
    back.Position = UDim2.new(0.5, 0, 0, 23)
    back.Size = UDim2.fromOffset(180, 4)
    back.BackgroundColor3 = Color3.fromRGB(43, 50, 56)
    back.BorderSizePixel = 0
    back.Parent = holder

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = Color3.fromRGB(134, 185, 199)
    fill.BorderSizePixel = 0
    fill.Parent = back

    local left = Instance.new("Frame")
    left.Name = "LeftCap"
    left.Size = UDim2.fromOffset(2, 8)
    left.Position = UDim2.fromOffset(-1, -2)
    left.BackgroundColor3 = Color3.fromRGB(134, 185, 199)
    left.BorderSizePixel = 0
    left.Parent = back

    local right = left:Clone()
    right.Name = "RightCap"
    right.Position = UDim2.new(1, -1, 0, -2)
    right.Parent = back

    return holder
end

local function noCollision(part)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
end

local function viewModel()
    local camera = workspace.CurrentCamera
    return camera and camera:FindFirstChild("BreachWeaponViewmodel")
end

local function sourcePart(name)
    local model = viewModel()
    local part = model and model:FindFirstChild(name)
    if part and part:IsA("BasePart") then
        return part
    end
    return nil
end

local function ghostFromPart(source, name)
    if not source then
        return nil
    end
    local ghost = source:Clone()
    ghost.Name = name
    for _, child in ipairs(ghost:GetDescendants()) do
        if child:IsA("JointInstance") or child:IsA("Constraint") or child:IsA("Script") or child:IsA("LocalScript") then
            child:Destroy()
        end
    end
    noCollision(ghost)
    ghost.Transparency = math.min(0.08, source.Transparency)
    ghost.Parent = workspace.CurrentCamera or workspace
    table.insert(activeGhosts, ghost)
    return ghost
end

local function makeGhost(name, size, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Color = color
    part.Material = material or Enum.Material.Metal
    noCollision(part)
    part.Parent = workspace.CurrentCamera or workspace
    table.insert(activeGhosts, part)
    return part
end

local function clearGhosts()
    for _, ghost in ipairs(activeGhosts) do
        if ghost and ghost.Parent then
            ghost:Destroy()
        end
    end
    table.clear(activeGhosts)
end

local function accent()
    return (currentDefinition and currentDefinition.Accent) or Color3.fromRGB(120, 180, 196)
end

local function animateMagazineReload(token, duration)
    task.delay(duration * 0.10, function()
        if token ~= reloadToken then return end
        local source = sourcePart("Magazine")
        local ghost = ghostFromPart(source, "ReloadMagazine")
        if not ghost then
            ghost = makeGhost("ReloadMagazine", Vector3.new(0.34, 0.86, 0.52), Color3.fromRGB(20, 23, 25))
            local model = viewModel()
            local root = model and model.PrimaryPart
            ghost.CFrame = root and (root.CFrame * CFrame.new(0, -0.63, 0.35)) or CFrame.new()
        end
        local start = ghost.CFrame
        TweenService:Create(ghost, TweenInfo.new(duration * 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            CFrame = start * CFrame.new(0.20, -1.25, 0.36) * CFrame.Angles(math.rad(35), 0, math.rad(28)),
            Transparency = 0.55,
        }):Play()
        task.delay(duration * 0.30, function()
            if ghost.Parent then ghost:Destroy() end
        end)
    end)

    task.delay(duration * 0.48, function()
        if token ~= reloadToken then return end
        local model = viewModel()
        local root = model and model.PrimaryPart
        if not root then return end
        local ghost = makeGhost("FreshMagazine", Vector3.new(0.34, 0.86, 0.52), Color3.fromRGB(20, 23, 25))
        local goal = root.CFrame * CFrame.new(0, -0.63, 0.35) * CFrame.Angles(math.rad(-8), 0, 0)
        ghost.CFrame = goal * CFrame.new(-0.42, -0.85, 0.36) * CFrame.Angles(math.rad(35), math.rad(-18), math.rad(-24))
        TweenService:Create(ghost, TweenInfo.new(duration * 0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            CFrame = goal,
        }):Play()
        task.delay(duration * 0.32, function()
            if ghost.Parent then ghost:Destroy() end
        end)
    end)
end

local function animateShotgunReload(token, duration)
    local shells = 4
    for index = 1, shells do
        task.delay(duration * (0.16 + (index - 1) * 0.16), function()
            if token ~= reloadToken then return end
            local model = viewModel()
            local root = model and model.PrimaryPart
            if not root then return end
            local shell = makeGhost("ReloadShell", Vector3.new(0.16, 0.16, 0.52), Color3.fromRGB(151, 48, 38), Enum.Material.SmoothPlastic)
            shell.CFrame = root.CFrame * CFrame.new(-0.48, -0.85, 0.20) * CFrame.Angles(math.rad(75), 0, math.rad(20))
            local goal = root.CFrame * CFrame.new(-0.12, -0.32, -0.28) * CFrame.Angles(math.rad(90), 0, 0)
            TweenService:Create(shell, TweenInfo.new(duration * 0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                CFrame = goal,
            }):Play()
            TweenService:Create(shell, TweenInfo.new(duration * 0.12), { Transparency = 1 }):Play()
            Debris:AddItem(shell, duration * 0.14)
        end)
    end
end

local function animateRailReload(token, duration)
    task.delay(duration * 0.14, function()
        if token ~= reloadToken then return end
        local source = sourcePart("Cell")
        local ghost = ghostFromPart(source, "SpentRailCell")
        if not ghost then return end
        local start = ghost.CFrame
        TweenService:Create(ghost, TweenInfo.new(duration * 0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            CFrame = start * CFrame.new(0.42, -0.72, 0.32) * CFrame.Angles(0, 0, math.rad(80)),
            Transparency = 0.72,
        }):Play()
        Debris:AddItem(ghost, duration * 0.32)
    end)

    task.delay(duration * 0.48, function()
        if token ~= reloadToken then return end
        local model = viewModel()
        local root = model and model.PrimaryPart
        if not root then return end
        local cell = makeGhost("FreshRailCell", Vector3.new(0.42, 0.72, 0.72), accent(), Enum.Material.Neon)
        local goal = root.CFrame * CFrame.new(0, -0.58, 0.35)
        cell.CFrame = goal * CFrame.new(-0.55, -0.75, 0.38) * CFrame.Angles(0, math.rad(-30), math.rad(-65))
        TweenService:Create(cell, TweenInfo.new(duration * 0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            CFrame = goal,
        }):Play()
        task.delay(duration * 0.32, function()
            if cell.Parent then cell:Destroy() end
        end)
    end)
end

local function beginReload(payload)
    reloadToken += 1
    local token = reloadToken
    clearGhosts()
    currentArchetype = (payload and payload.Archetype) or currentArchetype
    currentDefinition = Arsenal.Get(currentArchetype) or currentDefinition
    reloadStarted = os.clock()
    reloadDuration = math.max(0.3, (payload and payload.Duration) or (currentDefinition and currentDefinition.ReloadTime) or 1.8)

    if currentArchetype == "Shotgun" then
        animateShotgunReload(token, reloadDuration)
    elseif currentArchetype == "RailRifle" then
        animateRailReload(token, reloadDuration)
    else
        animateMagazineReload(token, reloadDuration)
    end
end

local function stageFor(archetype, phase)
    if archetype == "Shotgun" then
        if phase < 0.18 then return "OPEN ACTION" end
        if phase < 0.80 then return "LOAD SHELLS" end
        return "CHAMBER"
    elseif archetype == "RailRifle" then
        if phase < 0.34 then return "PURGE CELL" end
        if phase < 0.82 then return "SEAT POWER CELL" end
        return "CHARGE RAIL"
    end
    if phase < 0.34 then return "MAG OUT" end
    if phase < 0.82 then return "MAG IN" end
    return "CHAMBER"
end

local function weaponReadyPulse(payload)
    local hud = ensureActionHud()
    if not hud then return end
    local name = tostring((payload and payload.Name) or (payload and payload.WeaponName) or "WEAPON READY")
    if name == lastWeaponName then return end
    lastWeaponName = name

    local stage = hud:FindFirstChild("Stage")
    local back = hud:FindFirstChild("Back")
    local fill = back and back:FindFirstChild("Fill")
    if not stage or not fill then return end

    hud.Visible = true
    stage.Text = string.upper(name)
    stage.TextColor3 = accent()
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = accent()
    stage.TextTransparency = 0
    fill.BackgroundTransparency = 0

    task.delay(0.55, function()
        if reloadDuration > 0 then return end
        TweenService:Create(stage, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
        TweenService:Create(fill, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
        task.delay(0.2, function()
            if reloadDuration <= 0 and hud.Parent then hud.Visible = false end
        end)
    end)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and payload then
        currentArchetype = payload.Archetype or currentArchetype
        currentDefinition = Arsenal.Get(currentArchetype) or currentDefinition
        task.defer(weaponReadyPulse, payload)
    elseif kind == "WeaponFX" and payload and payload.Kind == "Reload" then
        beginReload(payload)
    elseif kind == "Combat" and payload and payload.Reloading == false and reloadDuration > 0 then
        if os.clock() - reloadStarted >= reloadDuration * 0.75 then
            reloadDuration = 0
            clearGhosts()
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local hud = ensureActionHud()
    if not hud or reloadDuration <= 0 then
        return
    end

    local elapsed = os.clock() - reloadStarted
    local phase = math.clamp(elapsed / reloadDuration, 0, 1)
    local stage = hud:FindFirstChild("Stage")
    local back = hud:FindFirstChild("Back")
    local fill = back and back:FindFirstChild("Fill")
    if not stage or not fill then
        return
    end

    hud.Visible = true
    stage.Text = stageFor(currentArchetype, phase)
    stage.TextColor3 = accent()
    stage.TextTransparency = 0
    fill.BackgroundColor3 = accent()
    fill.BackgroundTransparency = 0
    fill.Size = UDim2.fromScale(phase, 1)

    if phase >= 1 then
        reloadDuration = 0
        clearGhosts()
        stage.Text = "READY"
        fill.Size = UDim2.fromScale(1, 1)
        task.delay(0.22, function()
            if reloadDuration <= 0 and hud.Parent then
                hud.Visible = false
            end
        end)
    end
end)

player.CharacterAdded:Connect(function()
    reloadToken += 1
    reloadDuration = 0
    clearGhosts()
end)
