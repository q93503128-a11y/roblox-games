local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local stateRemote = ReplicatedStorage:WaitForChild("VaultfallRemotes"):WaitForChild("State")

local gui = Instance.new("ScreenGui")
gui.Name = "AugmentReactiveFX"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 16
gui.Parent = player:WaitForChild("PlayerGui")

local flash = Instance.new("Frame")
flash.Name = "ProtocolFlash"
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.fromRGB(65, 204, 255)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.Parent = gui

local reticlePulse = Instance.new("Frame")
reticlePulse.Name = "ReticlePulse"
reticlePulse.AnchorPoint = Vector2.new(0.5, 0.5)
reticlePulse.Position = UDim2.fromScale(0.5, 0.5)
reticlePulse.Size = UDim2.fromOffset(18, 18)
reticlePulse.BackgroundTransparency = 1
reticlePulse.Visible = false
reticlePulse.Parent = gui

local reticleCorner = Instance.new("UICorner")
reticleCorner.CornerRadius = UDim.new(1, 0)
reticleCorner.Parent = reticlePulse

local reticleStroke = Instance.new("UIStroke")
reticleStroke.Thickness = 2
reticleStroke.Transparency = 1
reticleStroke.Color = Color3.fromRGB(105, 221, 255)
reticleStroke.Parent = reticlePulse

local protocolTag = Instance.new("TextLabel")
protocolTag.Name = "ProtocolTag"
protocolTag.AnchorPoint = Vector2.new(0.5, 0)
protocolTag.Position = UDim2.new(0.5, 0, 0.67, 0)
protocolTag.Size = UDim2.fromOffset(380, 26)
protocolTag.BackgroundTransparency = 1
protocolTag.Font = Enum.Font.GothamBold
protocolTag.Text = ""
protocolTag.TextSize = 12
protocolTag.TextTransparency = 1
protocolTag.TextColor3 = Color3.fromRGB(183, 236, 255)
protocolTag.Parent = gui

local lowEdge = Instance.new("Frame")
lowEdge.Name = "GlassCannonEdge"
lowEdge.Size = UDim2.fromScale(1, 1)
lowEdge.BackgroundTransparency = 1
lowEdge.BorderSizePixel = 0
lowEdge.Parent = gui

local topEdge = Instance.new("Frame")
topEdge.Size = UDim2.new(1, 0, 0, 3)
topEdge.BackgroundColor3 = Color3.fromRGB(255, 78, 74)
topEdge.BackgroundTransparency = 1
topEdge.BorderSizePixel = 0
topEdge.Parent = lowEdge
local bottomEdge = topEdge:Clone()
bottomEdge.AnchorPoint = Vector2.new(0, 1)
bottomEdge.Position = UDim2.fromScale(0, 1)
bottomEdge.Parent = lowEdge
local leftEdge = topEdge:Clone()
leftEdge.Size = UDim2.new(0, 3, 1, 0)
leftEdge.Parent = lowEdge
local rightEdge = leftEdge:Clone()
rightEdge.AnchorPoint = Vector2.new(1, 0)
rightEdge.Position = UDim2.fromScale(1, 0)
rightEdge.Parent = lowEdge

local stacks = {}
local pursuitTrailClock = 0
local overclockShotClock = 0
local activeRun = false
local installSerial = 0

local function stack(id)
    return stacks[id] or 0
end

local function pulseScreen(color, transparency, duration)
    flash.BackgroundColor3 = color
    flash.BackgroundTransparency = transparency
    TweenService:Create(flash, TweenInfo.new(duration or 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
    }):Play()
end

local function pulseReticle(color, scale, duration)
    reticlePulse.Visible = true
    reticlePulse.Size = UDim2.fromOffset(18, 18)
    reticleStroke.Color = color
    reticleStroke.Transparency = 0.05
    TweenService:Create(reticlePulse, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(scale or 56, scale or 56),
    }):Play()
    TweenService:Create(reticleStroke, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1,
    }):Play()
    task.delay(duration or 0.2, function()
        reticlePulse.Visible = false
    end)
end

local function announce(text, color)
    installSerial += 1
    local serial = installSerial
    protocolTag.Text = text
    protocolTag.TextColor3 = color or Color3.fromRGB(183, 236, 255)
    protocolTag.TextTransparency = 0
    protocolTag.Position = UDim2.new(0.5, 0, 0.66, 0)
    TweenService:Create(protocolTag, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, 0, 0.63, 0),
    }):Play()
    task.delay(1.05, function()
        if installSerial ~= serial then
            return
        end
        TweenService:Create(protocolTag, TweenInfo.new(0.28), { TextTransparency = 1 }):Play()
    end)
end

local function makeWorldPulse(position, color, startSize, endSize, duration)
    local part = Instance.new("Part")
    part.Name = "AugmentPulse"
    part.Shape = Enum.PartType.Cylinder
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = 0.16
    part.Size = Vector3.new(0.16, startSize, startSize)
    part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    part.Parent = workspace
    TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.08, endSize, endSize),
        Transparency = 1,
    }):Play()
    task.delay(duration + 0.05, function()
        part:Destroy()
    end)
end

local function characterRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function updatePersistentIdentity()
    local glass = stack("glass_cannon")
    local transparency = glass > 0 and math.clamp(0.88 - glass * 0.08, 0.62, 0.88) or 1
    topEdge.BackgroundTransparency = transparency
    bottomEdge.BackgroundTransparency = transparency
    leftEdge.BackgroundTransparency = transparency
    rightEdge.BackgroundTransparency = transparency
end

local function onAugmentState(payload)
    local previous = {}
    for id, count in pairs(stacks) do
        previous[id] = count
    end
    table.clear(stacks)
    for _, item in ipairs(payload.Augments or {}) do
        stacks[item.Id] = item.Stacks or 1
    end
    updatePersistentIdentity()

    for id, count in pairs(stacks) do
        if count > (previous[id] or 0) then
            local labels = {
                overclock = "OVERCLOCK // CYCLING UP",
                glass_cannon = "GLASS CANNON // DAMAGE LIMITERS OFF",
                deep_mag = "DEEP MAG // CAPACITY EXPANDED",
                field_loader = "FIELD LOADER // RELOAD PATH OPTIMIZED",
                deadeye = "DEADEYE // CRITICAL LINK ONLINE",
                kinetic_shell = "KINETIC SHELL // ARMOR LAYERED",
                blood_circuit = "BLOOD CIRCUIT // KILL RECOVERY ONLINE",
                pursuit = "PURSUIT VECTOR // MOBILITY BOOSTED",
                stabilizer = "GYRO STABILIZER // RECOIL DAMPED",
                capacitor = "BREACH CAPACITOR // OUTPUT AMPLIFIED",
                emergency_mesh = "EMERGENCY MESH // FIELD REPAIRED",
                hunter_protocol = "HUNTER PROTOCOL // PRIORITY TARGETING",
            }
            announce(labels[id] or "BREACH AUGMENT INSTALLED", Color3.fromRGB(112, 218, 255))
            pulseScreen(Color3.fromRGB(62, 185, 225), 0.91, 0.32)
            local root = characterRoot()
            if root then
                makeWorldPulse(root.Position - Vector3.new(0, 2.5, 0), Color3.fromRGB(75, 207, 255), 4, 13, 0.38)
            end
            break
        end
    end
end

local function onHit(payload)
    if payload.Crit and stack("deadeye") > 0 then
        pulseReticle(Color3.fromRGB(255, 227, 99), 50 + stack("deadeye") * 4, 0.2)
        announce("DEADEYE // CRITICAL " .. tostring(payload.Damage or ""), Color3.fromRGB(255, 227, 99))
    elseif stack("capacitor") > 0 then
        pulseReticle(Color3.fromRGB(84, 192, 255), 38, 0.13)
    end

    if payload.Kill and stack("blood_circuit") > 0 then
        pulseScreen(Color3.fromRGB(82, 255, 158), 0.9, 0.34)
        announce("BLOOD CIRCUIT // VITALS RECOVERED", Color3.fromRGB(116, 255, 178))
        local root = characterRoot()
        if root then
            makeWorldPulse(root.Position - Vector3.new(0, 2.4, 0), Color3.fromRGB(78, 255, 148), 2, 8, 0.3)
        end
    end
end

local function onWeaponFX(payload)
    if payload.Kind == "Shot" and stack("overclock") > 0 then
        local now = os.clock()
        if now - overclockShotClock > 0.075 then
            overclockShotClock = now
            pulseReticle(Color3.fromRGB(89, 205, 255), 26 + stack("overclock") * 2, 0.08)
        end
    elseif payload.Kind == "Reload" and stack("field_loader") > 0 then
        announce("FIELD LOADER // RAPID CYCLE", Color3.fromRGB(123, 218, 255))
    elseif payload.Kind == "Dash" and stack("pursuit") > 0 then
        pulseScreen(Color3.fromRGB(81, 186, 255), 0.94, 0.16)
    end
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "AugmentState" then
        onAugmentState(payload or {})
    elseif kind == "Hit" then
        onHit(payload or {})
    elseif kind == "WeaponFX" then
        onWeaponFX(payload or {})
    elseif kind == "Run" then
        activeRun = payload and payload.Active == true
        if not activeRun then
            table.clear(stacks)
            updatePersistentIdentity()
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not activeRun or stack("pursuit") <= 0 then
        return
    end
    local root = characterRoot()
    if not root then
        return
    end
    local speed = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude
    if speed < 14 then
        return
    end
    pursuitTrailClock -= dt
    if pursuitTrailClock > 0 then
        return
    end
    pursuitTrailClock = math.max(0.08, 0.18 - stack("pursuit") * 0.025)

    local streak = Instance.new("Part")
    streak.Name = "PursuitVectorTrail"
    streak.Anchored = true
    streak.CanCollide = false
    streak.CanQuery = false
    streak.CanTouch = false
    streak.Material = Enum.Material.Neon
    streak.Color = Color3.fromRGB(64, 184, 255)
    streak.Transparency = 0.35
    streak.Size = Vector3.new(0.08, 0.08, 2.5 + stack("pursuit") * 0.45)
    local offset = Vector3.new(math.random(-14, 14) / 10, math.random(-18, 10) / 10, math.random(15, 28) / 10)
    streak.CFrame = root.CFrame * CFrame.new(offset)
    streak.Parent = workspace
    TweenService:Create(streak, TweenInfo.new(0.18), {
        Transparency = 1,
        Size = Vector3.new(0.03, 0.03, 5.5),
    }):Play()
    task.delay(0.2, function()
        streak:Destroy()
    end)
end)
