local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "EnemyDeathAndPhaseFX"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 74
gui.Parent = playerGui

local banner = Instance.new("TextLabel")
banner.Name = "ThreatBanner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0.135, -10)
banner.Size = UDim2.fromOffset(520, 46)
banner.BackgroundTransparency = 1
banner.Font = Enum.Font.GothamBlack
banner.TextSize = 18
banner.TextStrokeTransparency = 0.5
banner.TextTransparency = 1
banner.Text = ""
banner.Parent = gui

local subBanner = Instance.new("TextLabel")
subBanner.Name = "ThreatSubBanner"
subBanner.AnchorPoint = Vector2.new(0.5, 0)
subBanner.Position = UDim2.new(0.5, 0, 0.135, 18)
subBanner.Size = UDim2.fromOffset(520, 28)
subBanner.BackgroundTransparency = 1
subBanner.Font = Enum.Font.GothamMedium
subBanner.TextSize = 11
subBanner.TextStrokeTransparency = 0.65
subBanner.TextTransparency = 1
subBanner.Text = ""
subBanner.Parent = gui

local tracked = {}
local bannerToken = 0

local PROFILE = {
    Elite = { color = Color3.fromRGB(198, 112, 255), shards = 8, radius = 8, label = "ELITE NEUTRALIZED" },
    Huntsman = { color = Color3.fromRGB(255, 129, 82), shards = 10, radius = 10, label = "HVT HUNTSMAN DOWN" },
    Bulwark = { color = Color3.fromRGB(255, 198, 83), shards = 11, radius = 10, label = "HVT BULWARK DOWN" },
    Reaper = { color = Color3.fromRGB(218, 92, 255), shards = 12, radius = 11, label = "HVT REAPER DOWN" },
    VaultWarden = { color = Color3.fromRGB(255, 77, 91), shards = 22, radius = 18, label = "VAULT WARDEN TERMINATED" },
}

local function prefix(name)
    return string.match(name, "^([^_]+)") or name
end

local function noCollision(part)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
end

local function localPart(name, size, cframe, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.Neon
    part.Transparency = 0
    noCollision(part)
    part.Parent = Workspace
    return part
end

local function cameraPulse(amount)
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end
    local base = camera.FieldOfView
    TweenService:Create(camera, TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        FieldOfView = base + amount,
    }):Play()
    task.delay(0.08, function()
        if Workspace.CurrentCamera == camera then
            TweenService:Create(camera, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                FieldOfView = base,
            }):Play()
        end
    end)
end

local function showBanner(text, subtext, color, duration)
    bannerToken += 1
    local token = bannerToken
    banner.Text = text
    banner.TextColor3 = color
    banner.TextTransparency = 0
    banner.Position = UDim2.new(0.5, 0, 0.125, -10)
    subBanner.Text = subtext or ""
    subBanner.TextColor3 = color:Lerp(Color3.new(1, 1, 1), 0.4)
    subBanner.TextTransparency = subtext and 0 or 1
    TweenService:Create(banner, TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.135, -10),
    }):Play()
    task.delay(duration or 0.95, function()
        if token ~= bannerToken then
            return
        end
        TweenService:Create(banner, TweenInfo.new(0.22), { TextTransparency = 1 }):Play()
        TweenService:Create(subBanner, TweenInfo.new(0.22), { TextTransparency = 1 }):Play()
    end)
end

local function ring(position, radius, color, duration, height)
    local part = localPart(
        "EnemyDeathRing",
        Vector3.new(height or 0.16, 1, 1),
        CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
        color,
        Enum.Material.Neon
    )
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(height or 0.16, radius * 0.25, radius * 0.25)
    part.Transparency = 0.18
    TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(height or 0.16, radius, radius),
        Transparency = 1,
    }):Play()
    Debris:AddItem(part, duration + 0.05)
end

local function shardBurst(position, profile, verticalScale)
    for index = 1, profile.shards do
        local angle = (index / profile.shards) * math.pi * 2 + math.random() * 0.35
        local up = 0.25 + math.random() * (verticalScale or 1.6)
        local direction = Vector3.new(math.cos(angle), up, math.sin(angle)).Unit
        local shard = localPart(
            "EnemyDeathShard",
            Vector3.new(0.08 + math.random() * 0.08, 0.08 + math.random() * 0.08, 0.35 + math.random() * 0.45),
            CFrame.lookAt(position, position + direction),
            index % 3 == 0 and profile.color:Lerp(Color3.new(1, 1, 1), 0.45) or profile.color,
            Enum.Material.Neon
        )
        local distance = profile.radius * (0.45 + math.random() * 0.65)
        local destination = position + direction * distance + Vector3.new(0, math.random() * 2.2, 0)
        TweenService:Create(shard, TweenInfo.new(0.32 + math.random() * 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            CFrame = CFrame.lookAt(destination, destination + direction) * CFrame.Angles(0, 0, math.rad(math.random(-100, 100))),
            Transparency = 1,
        }):Play()
        Debris:AddItem(shard, 0.55)
    end
end

local function coreBurst(position, profile, scale)
    local orb = localPart(
        "EnemyDeathCore",
        Vector3.new(0.5, 0.5, 0.5) * scale,
        CFrame.new(position),
        profile.color,
        Enum.Material.Neon
    )
    orb.Shape = Enum.PartType.Ball
    local light = Instance.new("PointLight")
    light.Color = profile.color
    light.Brightness = 4 * scale
    light.Range = 10 * scale
    light.Shadows = false
    light.Parent = orb
    TweenService:Create(orb, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(4.5, 4.5, 4.5) * scale,
        Transparency = 1,
    }):Play()
    TweenService:Create(light, TweenInfo.new(0.2), { Brightness = 0, Range = 2 }):Play()
    Debris:AddItem(orb, 0.3)
end

local function deathFX(model, entry)
    if entry and entry.dead then
        return
    end
    if entry then
        entry.dead = true
    end

    local enemyType = entry and entry.enemyType or prefix(model.Name)
    local profile = PROFILE[enemyType]
    if not profile then
        return
    end

    local root = model:FindFirstChild("Root")
    local cframe = root and root.CFrame or (entry and entry.lastCFrame)
    if not cframe then
        return
    end

    local position = cframe.Position + Vector3.new(0, enemyType == "VaultWarden" and 2.3 or 1.2, 0)
    local scale = enemyType == "VaultWarden" and 1.75 or (enemyType == "Elite" and 1.05 or 1.25)
    coreBurst(position, profile, scale)
    shardBurst(position, profile, enemyType == "VaultWarden" and 2.4 or 1.5)
    ring(cframe.Position + Vector3.new(0, 0.18, 0), profile.radius, profile.color, 0.42, enemyType == "VaultWarden" and 0.28 or 0.16)

    if enemyType == "VaultWarden" then
        task.delay(0.08, function()
            ring(cframe.Position + Vector3.new(0, 0.22, 0), profile.radius * 1.35, profile.color:Lerp(Color3.new(1, 1, 1), 0.28), 0.55, 0.22)
        end)
        task.delay(0.18, function()
            ring(cframe.Position + Vector3.new(0, 0.26, 0), profile.radius * 1.7, profile.color, 0.7, 0.18)
        end)
        cameraPulse(5.5)
        showBanner(profile.label, "BREACH SECURED — EXTRACTION WINDOW OPEN", profile.color, 1.8)
    elseif enemyType ~= "Elite" then
        cameraPulse(2.2)
        showBanner(profile.label, "HIGH VALUE TARGET REMOVED", profile.color, 1.05)
    else
        cameraPulse(1.2)
        showBanner(profile.label, nil, profile.color, 0.7)
    end
end

local function findHealthFill(model)
    local bar = model:FindFirstChild("HealthBar", true)
    local background = bar and bar:FindFirstChild("Background")
    local fill = background and background:FindFirstChild("Fill")
    return fill
end

local function phaseFX(entry, phase)
    local profile = PROFILE.VaultWarden
    local root = entry.model:FindFirstChild("Root")
    if not root or not root:IsA("BasePart") then
        return
    end
    local position = root.Position + Vector3.new(0, 0.22, 0)
    local radius = phase == 2 and 16 or 22
    ring(position, radius, profile.color, 0.7, 0.24)
    task.delay(0.09, function()
        if root.Parent then
            ring(root.Position + Vector3.new(0, 0.25, 0), radius * 1.25, profile.color:Lerp(Color3.new(1, 1, 1), 0.35), 0.85, 0.18)
        end
    end)
    coreBurst(root.Position + Vector3.new(0, 3, 0), profile, phase == 3 and 1.25 or 0.8)
    cameraPulse(phase == 3 and 4.2 or 2.8)
    showBanner(
        phase == 3 and "WARDEN PHASE III" or "WARDEN PHASE II",
        phase == 3 and "CRITICAL PATTERN ESCALATION" or "ATTACK PATTERN ESCALATING",
        profile.color,
        1.15
    )
end

local function entranceFX(entry)
    local profile = PROFILE[entry.enemyType]
    local root = entry.model:FindFirstChild("Root")
    if not profile or not root or not root:IsA("BasePart") then
        return
    end
    local radius = entry.enemyType == "VaultWarden" and 14 or 7
    ring(root.Position + Vector3.new(0, 0.2, 0), radius, profile.color, 0.55, 0.16)
    if entry.enemyType == "VaultWarden" then
        showBanner("VAULT WARDEN", "MULTI-PATTERN THREAT DETECTED", profile.color, 1.25)
        cameraPulse(3.5)
    end
end

local function bindEnemy(model)
    if tracked[model] then
        return
    end
    local root = model:FindFirstChild("Root")
    if not root or not root:IsA("BasePart") then
        return
    end
    local enemyType = prefix(model.Name)
    local entry = {
        model = model,
        enemyType = enemyType,
        lastCFrame = root.CFrame,
        healthFill = findHealthFill(model),
        phase = 1,
        dead = false,
    }
    tracked[model] = entry
    if PROFILE[enemyType] then
        task.delay(0.08, function()
            if tracked[model] == entry and model.Parent then
                entranceFX(entry)
            end
        end)
    end
end

local function bindFolder(folder)
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") then
            task.defer(bindEnemy, child)
        end
    end
    folder.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            task.defer(function()
                child:WaitForChild("Root", 2)
                bindEnemy(child)
            end)
        end
    end)
    folder.ChildRemoving:Connect(function(child)
        local entry = tracked[child]
        if entry then
            deathFX(child, entry)
            tracked[child] = nil
        end
    end)
end

local boundFolders = {}
local function inspectWorld(world)
    local folder = world:FindFirstChild("Enemies")
    if folder and folder:IsA("Folder") and not boundFolders[folder] then
        boundFolders[folder] = true
        bindFolder(folder)
    end
    world.ChildAdded:Connect(function(child)
        if child.Name == "Enemies" and child:IsA("Folder") and not boundFolders[child] then
            boundFolders[child] = true
            bindFolder(child)
        end
    end)
end

local existingWorld = Workspace:FindFirstChild("VaultfallWorld")
if existingWorld then
    inspectWorld(existingWorld)
end
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "VaultfallWorld" then
        inspectWorld(child)
    end
end)

RunService.RenderStepped:Connect(function()
    for model, entry in pairs(tracked) do
        if not model.Parent then
            deathFX(model, entry)
            tracked[model] = nil
        else
            local root = model:FindFirstChild("Root")
            if root and root:IsA("BasePart") then
                entry.lastCFrame = root.CFrame
            end
            if entry.enemyType == "VaultWarden" then
                if not entry.healthFill or not entry.healthFill.Parent then
                    entry.healthFill = findHealthFill(model)
                end
                local fill = entry.healthFill
                if fill and fill.Parent then
                    local ratio = math.clamp(fill.Size.X.Scale, 0, 1)
                    local targetPhase = ratio <= 0.34 and 3 or (ratio <= 0.67 and 2 or 1)
                    if targetPhase > entry.phase then
                        entry.phase = targetPhase
                        phaseFX(entry, targetPhase)
                    end
                end
            end
        end
    end
end)
