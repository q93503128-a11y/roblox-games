local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "BreachDamageFeedback"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 80
gui.Parent = playerGui

local function frame(name, anchor, position, size)
    local item = Instance.new("Frame")
    item.Name = name
    item.AnchorPoint = anchor
    item.Position = position
    item.Size = size
    item.BorderSizePixel = 0
    item.BackgroundColor3 = Color3.fromRGB(181, 28, 31)
    item.BackgroundTransparency = 1
    item.Parent = gui
    return item
end

local topEdge = frame("TopEdge", Vector2.new(0.5, 0), UDim2.fromScale(0.5, 0), UDim2.new(1, 0, 0, 82))
local bottomEdge = frame("BottomEdge", Vector2.new(0.5, 1), UDim2.fromScale(0.5, 1), UDim2.new(1, 0, 0, 96))
local leftEdge = frame("LeftEdge", Vector2.new(0, 0.5), UDim2.fromScale(0, 0.5), UDim2.new(0, 92, 1, 0))
local rightEdge = frame("RightEdge", Vector2.new(1, 0.5), UDim2.fromScale(1, 0.5), UDim2.new(0, 92, 1, 0))
local edges = { topEdge, rightEdge, bottomEdge, leftEdge }

local centerFlash = Instance.new("Frame")
centerFlash.Name = "DamageFlash"
centerFlash.Size = UDim2.fromScale(1, 1)
centerFlash.BorderSizePixel = 0
centerFlash.BackgroundColor3 = Color3.fromRGB(128, 16, 18)
centerFlash.BackgroundTransparency = 1
centerFlash.Parent = gui

local direction = Instance.new("TextLabel")
direction.Name = "DamageDirection"
direction.AnchorPoint = Vector2.new(0.5, 0.5)
direction.Position = UDim2.fromScale(0.5, 0.32)
direction.Size = UDim2.fromOffset(52, 52)
direction.BackgroundTransparency = 1
direction.Font = Enum.Font.GothamBold
direction.Text = "▲"
direction.TextSize = 34
direction.TextColor3 = Color3.fromRGB(247, 101, 101)
direction.TextStrokeColor3 = Color3.fromRGB(45, 8, 10)
direction.TextStrokeTransparency = 0.15
direction.TextTransparency = 1
direction.Parent = gui

local critical = Instance.new("TextLabel")
critical.Name = "CriticalHealth"
critical.AnchorPoint = Vector2.new(0.5, 1)
critical.Position = UDim2.new(0.5, 0, 1, -126)
critical.Size = UDim2.fromOffset(360, 30)
critical.BackgroundTransparency = 1
critical.Font = Enum.Font.GothamBold
critical.Text = "CRITICAL CONDITION"
critical.TextSize = 13
critical.TextColor3 = Color3.fromRGB(242, 98, 98)
critical.TextStrokeTransparency = 0.4
critical.TextTransparency = 1
critical.Parent = gui

local shakePitch = 0
local shakeYaw = 0
local shakeRoll = 0
local shakeOffset = Vector3.zero
local lowHealthPulse = 0
local hitToken = 0
local boundHumanoid = nil
local lastHealth = 0

local function enemyFolder()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    return world and world:FindFirstChild("Enemies")
end

local function nearestThreat(position)
    local folder = enemyFolder()
    if not folder then
        return nil
    end

    local bestRoot = nil
    local bestDistance = 95
    for _, enemy in ipairs(folder:GetChildren()) do
        if enemy:IsA("Model") then
            local root = enemy:FindFirstChild("Root") or enemy.PrimaryPart
            if root and root:IsA("BasePart") then
                local distance = (root.Position - position).Magnitude
                if distance < bestDistance then
                    bestDistance = distance
                    bestRoot = root
                end
            end
        end
    end
    return bestRoot
end

local function threatScreenAngle(characterRoot)
    local camera = Workspace.CurrentCamera
    if not camera or not characterRoot then
        return 0
    end

    local threat = nearestThreat(characterRoot.Position)
    if not threat then
        return 0
    end

    local delta = threat.Position - characterRoot.Position
    local localDelta = camera.CFrame:VectorToObjectSpace(delta)
    if math.abs(localDelta.X) < 0.001 and math.abs(localDelta.Z) < 0.001 then
        return 0
    end

    return math.deg(math.atan2(localDelta.X, -localDelta.Z))
end

local function directionalEdge(angle)
    local normalized = (angle + 360) % 360
    if normalized >= 315 or normalized < 45 then
        return topEdge
    elseif normalized < 135 then
        return rightEdge
    elseif normalized < 225 then
        return bottomEdge
    end
    return leftEdge
end

local function pulseDamage(amount, maxHealth)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local angle = threatScreenAngle(root)
    local edge = directionalEdge(angle)
    local severity = math.clamp(amount / math.max(maxHealth, 1), 0.04, 0.7)

    hitToken += 1
    local token = hitToken

    direction.Rotation = angle
    direction.Position = UDim2.new(0.5, math.sin(math.rad(angle)) * 72, 0.32, -math.cos(math.rad(angle)) * 24)
    direction.TextTransparency = 0.05
    direction.TextColor3 = severity > 0.25 and Color3.fromRGB(255, 74, 76) or Color3.fromRGB(247, 112, 112)

    centerFlash.BackgroundTransparency = math.clamp(0.92 - severity * 0.34, 0.64, 0.9)
    edge.BackgroundTransparency = math.clamp(0.42 + severity * 0.2, 0.38, 0.66)

    shakePitch += (0.35 + severity * 1.5) * (math.random() > 0.5 and 1 or -1)
    shakeYaw += (0.25 + severity * 1.15) * (math.random() > 0.5 and 1 or -1)
    shakeRoll += (0.35 + severity * 1.8) * (math.random() > 0.5 and 1 or -1)
    shakeOffset += Vector3.new((math.random() - 0.5) * severity * 0.16, (math.random() - 0.5) * severity * 0.12, 0)

    TweenService:Create(centerFlash, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(edge, TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
    }):Play()
    TweenService:Create(direction, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1,
    }):Play()

    task.delay(0.45, function()
        if token == hitToken then
            direction.TextTransparency = 1
        end
    end)
end

local function bindCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then
        return
    end

    boundHumanoid = humanoid
    lastHealth = humanoid.Health
    lowHealthPulse = humanoid.MaxHealth > 0 and (humanoid.Health / humanoid.MaxHealth) or 1

    humanoid.HealthChanged:Connect(function(health)
        if humanoid ~= boundHumanoid then
            return
        end

        if health < lastHealth - 0.05 then
            pulseDamage(lastHealth - health, humanoid.MaxHealth)
        end
        lastHealth = health
        lowHealthPulse = humanoid.MaxHealth > 0 and math.clamp(health / humanoid.MaxHealth, 0, 1) or 1

        if health <= 0 then
            critical.Text = "OPERATOR DOWN"
            critical.TextTransparency = 0
            centerFlash.BackgroundColor3 = Color3.fromRGB(58, 8, 9)
            centerFlash.BackgroundTransparency = 0.5
            TweenService:Create(centerFlash, TweenInfo.new(0.9), { BackgroundTransparency = 0.82 }):Play()
        end
    end)
end

player.CharacterAdded:Connect(function(character)
    centerFlash.BackgroundColor3 = Color3.fromRGB(128, 16, 18)
    centerFlash.BackgroundTransparency = 1
    critical.Text = "CRITICAL CONDITION"
    critical.TextTransparency = 1
    task.spawn(bindCharacter, character)
end)

if player.Character then
    task.spawn(bindCharacter, player.Character)
end

RunService:BindToRenderStep("BreachDamageFeedback", Enum.RenderPriority.Camera.Value + 4, function(dt)
    shakePitch *= math.exp(-dt * 18)
    shakeYaw *= math.exp(-dt * 17)
    shakeRoll *= math.exp(-dt * 15)
    shakeOffset *= math.exp(-dt * 19)

    local camera = Workspace.CurrentCamera
    if camera and (math.abs(shakePitch) > 0.002 or math.abs(shakeYaw) > 0.002 or math.abs(shakeRoll) > 0.002 or shakeOffset.Magnitude > 0.0005) then
        camera.CFrame *= CFrame.new(shakeOffset) * CFrame.Angles(math.rad(shakePitch), math.rad(shakeYaw), math.rad(shakeRoll))
    end

    local humanoid = boundHumanoid
    if not humanoid or not humanoid.Parent or humanoid.Health <= 0 then
        return
    end

    local ratio = humanoid.MaxHealth > 0 and humanoid.Health / humanoid.MaxHealth or lowHealthPulse
    if ratio < 0.28 then
        local intensity = math.clamp((0.28 - ratio) / 0.28, 0, 1)
        local wave = (math.sin(os.clock() * (4.4 + intensity * 2.6)) + 1) * 0.5
        local edgeTransparency = 0.96 - wave * 0.13 * intensity
        for _, edge in ipairs(edges) do
            if edge.BackgroundTransparency > edgeTransparency then
                edge.BackgroundTransparency = edgeTransparency
            end
        end
        critical.TextTransparency = 0.58 - wave * 0.38 * intensity
    else
        critical.TextTransparency += (1 - critical.TextTransparency) * math.min(1, dt * 7)
    end
end)