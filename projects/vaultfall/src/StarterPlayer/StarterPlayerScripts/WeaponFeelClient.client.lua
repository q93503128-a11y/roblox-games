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
local lastShotAt = -100
local shotIndex = 0
local cameraPitch = 0
local cameraYaw = 0
local cameraRoll = 0
local hitPulse = 0
local killPulse = 0
local trackedModel = nil
local trackedRoot = nil
local trackedParts = {}
local rightHand = nil
local leftHand = nil
local lastViewRefresh = 0

local function noCollision(part)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Massless = true
end

local function clearHand(part)
    if part then
        part:Destroy()
    end
end

local function cleanClone(source, name)
    if not source or not source:IsA("BasePart") then
        return nil
    end

    local clone = source:Clone()
    clone.Name = name
    for _, descendant in ipairs(clone:GetDescendants()) do
        if descendant:IsA("Motor6D")
            or descendant:IsA("Weld")
            or descendant:IsA("WeldConstraint")
            or descendant:IsA("Script")
            or descendant:IsA("LocalScript") then
            descendant:Destroy()
        end
    end
    noCollision(clone)
    return clone
end

local function fallbackHand(name, color)
    local hand = Instance.new("Part")
    hand.Name = name
    hand.Size = Vector3.new(0.36, 0.44, 0.52)
    hand.Color = color
    hand.Material = Enum.Material.SmoothPlastic
    noCollision(hand)
    return hand
end

local function skinColor()
    local character = player.Character
    if not character then
        return Color3.fromRGB(216, 176, 144)
    end

    local head = character:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        return head.Color
    end

    return Color3.fromRGB(216, 176, 144)
end

local function rebuildHands(model)
    clearHand(rightHand)
    clearHand(leftHand)
    rightHand = nil
    leftHand = nil

    if not model then
        return
    end

    local character = player.Character
    local color = skinColor()
    if character then
        rightHand = cleanClone(character:FindFirstChild("RightHand"), "FeelRightHand")
        leftHand = cleanClone(character:FindFirstChild("LeftHand"), "FeelLeftHand")
    end

    rightHand = rightHand or fallbackHand("FeelRightHand", color)
    leftHand = leftHand or fallbackHand("FeelLeftHand", color)
    rightHand.Parent = model
    leftHand.Parent = model
end

local function trackCurrentViewModel(force)
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local now = os.clock()
    if not force and now - lastViewRefresh < 0.25 then
        return
    end
    lastViewRefresh = now

    local model = camera:FindFirstChild("BreachWeaponViewmodel")
    if model == trackedModel and trackedRoot and trackedRoot.Parent then
        return
    end

    trackedModel = model
    trackedRoot = model and model.PrimaryPart or nil
    table.clear(trackedParts)

    if not model or not trackedRoot then
        clearHand(rightHand)
        clearHand(leftHand)
        rightHand = nil
        leftHand = nil
        return
    end

    for _, name in ipairs({ "Receiver", "Muzzle", "Magazine", "Pump", "Cell", "Sight", "Scope", "RailTop", "Handguard" }) do
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            trackedParts[name] = {
                Part = part,
                Local = trackedRoot.CFrame:ToObjectSpace(part.CFrame),
                Transparency = part.Transparency,
            }
        end
    end

    rebuildHands(model)
end

local function safePart(parent, name, size, cframe, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = cframe
    part.Color = color
    part.Material = material or Enum.Material.Neon
    part.Transparency = 0
    noCollision(part)
    part.Parent = parent
    return part
end

local function fadePart(part, duration, goalSize)
    local goal = { Transparency = 1 }
    if goalSize then
        goal.Size = goalSize
    end
    TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal):Play()
    Debris:AddItem(part, duration + 0.05)
end

local function muzzleBurst()
    trackCurrentViewModel(true)
    local muzzleEntry = trackedParts.Muzzle
    if not muzzleEntry then
        return
    end

    local muzzle = muzzleEntry.Part
    local definition = currentDefinition or Arsenal.Get("Carbine")
    local accent = definition.Accent or Color3.fromRGB(230, 220, 185)
    local scale = currentArchetype == "Shotgun" and 1.45 or (currentArchetype == "RailRifle" and 1.65 or 1)

    local orb = safePart(workspace, "BreachMuzzleBurst", Vector3.new(0.16, 0.16, 0.16) * scale, muzzle.CFrame, accent, Enum.Material.Neon)
    orb.Shape = Enum.PartType.Ball
    fadePart(orb, 0.07, Vector3.new(0.72, 0.72, 0.72) * scale)

    for index = 1, 3 do
        local length = (0.55 + index * 0.18) * scale
        local ray = safePart(
            workspace,
            "BreachMuzzleRay",
            Vector3.new(0.035 + index * 0.012, 0.035 + index * 0.012, length),
            muzzle.CFrame * CFrame.Angles(0, 0, math.rad((index - 2) * 18)) * CFrame.new(0, 0, -length * 0.5),
            accent,
            Enum.Material.Neon
        )
        fadePart(ray, 0.055 + index * 0.012, ray.Size + Vector3.new(0.08, 0.08, 0.35))
    end
end

local function ejectionPort()
    if not trackedRoot then
        return nil
    end
    return trackedRoot.CFrame * CFrame.new(0.36, 0.14, -0.15)
end

local function ejectShell()
    if currentArchetype == "RailRifle" then
        return
    end

    local port = ejectionPort()
    if not port then
        return
    end

    local shell = Instance.new("Part")
    shell.Name = "BreachCasing"
    shell.Size = currentArchetype == "Shotgun" and Vector3.new(0.18, 0.18, 0.48) or Vector3.new(0.10, 0.10, 0.34)
    shell.CFrame = port
    shell.Color = currentArchetype == "Shotgun" and Color3.fromRGB(135, 39, 32) or Color3.fromRGB(190, 145, 65)
    shell.Material = Enum.Material.Metal
    shell.CanCollide = false
    shell.CanTouch = false
    shell.CanQuery = false
    shell.Massless = false
    shell.Parent = workspace

    local camera = workspace.CurrentCamera
    local right = camera and camera.CFrame.RightVector or Vector3.new(1, 0, 0)
    local back = camera and -camera.CFrame.LookVector or Vector3.new(0, 0, 1)
    shell.AssemblyLinearVelocity = right * (7 + math.random() * 3) + Vector3.new(0, 5 + math.random() * 2, 0) + back * 2
    shell.AssemblyAngularVelocity = Vector3.new(math.random(-12, 12), math.random(-18, 18), math.random(-12, 12))
    Debris:AddItem(shell, 1.4)
end

local function impactBurst()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    trackCurrentViewModel(false)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {}
    if player.Character then
        table.insert(filter, player.Character)
    end
    if trackedModel then
        table.insert(filter, trackedModel)
    end
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true

    local range = (currentDefinition and currentDefinition.Range) or 170
    local result = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * range, params)
    if not result then
        return
    end

    local accent = (currentDefinition and currentDefinition.Accent) or Color3.fromRGB(210, 225, 235)
    local center = result.Position + result.Normal * 0.025
    for index = 1, 5 do
        local spark = Instance.new("Part")
        spark.Name = "BreachImpactSpark"
        spark.Size = Vector3.new(0.035, 0.035, 0.18 + math.random() * 0.10)
        spark.Color = index <= 2 and accent or Color3.fromRGB(235, 215, 160)
        spark.Material = Enum.Material.Neon
        spark.CFrame = CFrame.lookAt(center, center + result.Normal)
        spark.CanCollide = false
        spark.CanTouch = false
        spark.CanQuery = false
        spark.Massless = true
        spark.Parent = workspace

        local tangent = Vector3.new(math.random() - 0.5, math.random() * 0.65, math.random() - 0.5)
        if tangent.Magnitude < 0.05 then
            tangent = Vector3.new(0.2, 0.4, 0.1)
        end
        spark.AssemblyLinearVelocity = result.Normal * (7 + math.random() * 5) + tangent.Unit * (3 + math.random() * 4)
        spark.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
        TweenService:Create(spark, TweenInfo.new(0.16), { Transparency = 1 }):Play()
        Debris:AddItem(spark, 0.2)
    end

    if not result.Instance:FindFirstAncestorOfClass("Model") then
        local mark = safePart(workspace, "BreachImpactMark", Vector3.new(0.11, 0.11, 0.025), CFrame.lookAt(center, center + result.Normal), Color3.fromRGB(35, 38, 40), Enum.Material.SmoothPlastic)
        mark.Transparency = 0.24
        fadePart(mark, 1.8, Vector3.new(0.14, 0.14, 0.025))
    end
end

local function createHitMarker(crit, killed)
    local gui = player:FindFirstChildOfClass("PlayerGui")
    local breachHud = gui and gui:FindFirstChild("BreachHUD")
    if not breachHud then
        return
    end

    local holder = Instance.new("Frame")
    holder.Name = "ImpactMarker"
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.fromScale(0.5, 0.5)
    holder.Size = UDim2.fromOffset(46, 46)
    holder.BackgroundTransparency = 1
    holder.Parent = breachHud

    local color = killed and Color3.fromRGB(239, 91, 91) or (crit and Color3.fromRGB(242, 190, 79) or Color3.fromRGB(236, 243, 246))
    for _, spec in ipairs({
        { UDim2.fromOffset(7, 7), 45 },
        { UDim2.new(1, -13, 0, 7), -45 },
        { UDim2.fromOffset(7, 33), -45 },
        { UDim2.new(1, -13, 0, 33), 45 },
    }) do
        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Position = spec[1]
        line.Size = UDim2.fromOffset(killed and 13 or 10, 2)
        line.Rotation = spec[2]
        line.BackgroundColor3 = color
        line.BorderSizePixel = 0
        line.Parent = holder
        TweenService:Create(line, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(killed and 18 or 14, 2),
        }):Play()
    end
    Debris:AddItem(holder, 0.18)
end

local function animateCrosshair(dt)
    local gui = player:FindFirstChildOfClass("PlayerGui")
    local breachHud = gui and gui:FindFirstChild("BreachHUD")
    local crosshair = breachHud and breachHud:FindFirstChild("Crosshair")
    if not crosshair then
        return
    end

    hitPulse *= math.exp(-dt * 16)
    killPulse *= math.exp(-dt * 13)

    local timeSinceShot = os.clock() - lastShotAt
    local shotGap = math.exp(-timeSinceShot * 8) * ((currentDefinition and currentDefinition.Recoil) or 0.6) * 5
    local gap = math.clamp(10 + shotGap + hitPulse * 1.5, 7, 24)
    local color = killPulse > 0.12 and Color3.fromRGB(239, 91, 91)
        or (hitPulse > 0.12 and Color3.fromRGB(242, 190, 79))
        or Color3.fromRGB(235, 243, 246)

    local pieces = {}
    for _, child in ipairs(crosshair:GetChildren()) do
        if child:IsA("Frame") then
            table.insert(pieces, child)
        end
    end
    if #pieces >= 4 then
        pieces[1].Position = UDim2.new(0.5, 0, 0.5, -gap)
        pieces[2].Position = UDim2.new(0.5, 0, 0.5, gap)
        pieces[3].Position = UDim2.new(0.5, -gap, 0.5, 0)
        pieces[4].Position = UDim2.new(0.5, gap, 0.5, 0)
        for _, piece in ipairs(pieces) do
            piece.BackgroundColor3 = color
        end
        crosshair.BackgroundColor3 = color
    end
end

local function setPartTransform(name, transform)
    local entry = trackedParts[name]
    if not entry or not entry.Part.Parent or not trackedRoot then
        return
    end
    entry.Part.CFrame = trackedRoot.CFrame * entry.Local * transform
end

local function animateWeaponParts(now)
    if not trackedModel or not trackedRoot or not trackedRoot.Parent then
        return
    end

    local age = now - lastShotAt
    local kick = math.exp(-age * 13)
    if age > 1.2 then
        kick = 0
    end

    setPartTransform("Magazine", CFrame.new())
    setPartTransform("Pump", CFrame.new())
    setPartTransform("Cell", CFrame.new())
    setPartTransform("Sight", CFrame.new())
    setPartTransform("Scope", CFrame.new())
    setPartTransform("RailTop", CFrame.new())

    if currentArchetype == "Shotgun" and age >= 0.10 and age <= 0.62 then
        local phase = (age - 0.10) / 0.52
        local travel = math.sin(math.clamp(phase, 0, 1) * math.pi)
        setPartTransform("Pump", CFrame.new(0, 0, 0.48 * travel))
    elseif currentArchetype == "RailRifle" and age <= 0.55 then
        local pulse = math.sin(math.clamp(age / 0.55, 0, 1) * math.pi)
        setPartTransform("Cell", CFrame.new(0, -0.08 * pulse, 0.10 * pulse) * CFrame.Angles(0, 0, math.rad(8 * pulse)))
        setPartTransform("RailTop", CFrame.new(0, 0.035 * pulse, 0))
    elseif currentArchetype == "SMG" then
        setPartTransform("Magazine", CFrame.Angles(math.rad(1.8 * kick), 0, math.rad(-2.5 * kick)))
    else
        setPartTransform("Sight", CFrame.new(0, 0, 0.045 * kick))
    end

    if rightHand and rightHand.Parent then
        local handBob = math.sin(now * 2.2) * 0.008
        rightHand.CFrame = trackedRoot.CFrame * CFrame.new(0.34, -0.47 + handBob, 0.26) * CFrame.Angles(math.rad(-18), math.rad(9), math.rad(-16))
    end
    if leftHand and leftHand.Parent then
        local leftZ = currentArchetype == "RailRifle" and -0.82 or (currentArchetype == "Shotgun" and -0.94 or -0.72)
        leftHand.CFrame = trackedRoot.CFrame * CFrame.new(-0.28, -0.38 - math.sin(now * 2.2) * 0.007, leftZ) * CFrame.Angles(math.rad(-12), math.rad(-12), math.rad(19))
    end
end

local function onShot(payload)
    shotIndex += 1
    lastShotAt = os.clock()
    local definition = currentDefinition or Arsenal.Get("Carbine")
    local recoil = (payload and payload.Recoil) or definition.Recoil or 0.6

    local pitchScale = currentArchetype == "Shotgun" and 1.35 or (currentArchetype == "RailRifle" and 1.5 or 1)
    cameraPitch = math.clamp(cameraPitch + recoil * 0.34 * pitchScale, 0, 3.4)
    cameraYaw = math.clamp(cameraYaw + ((shotIndex % 2 == 0) and 1 or -1) * recoil * 0.065, -0.9, 0.9)
    cameraRoll = math.clamp(cameraRoll + ((shotIndex % 3) - 1) * recoil * 0.045, -0.5, 0.5)

    muzzleBurst()
    ejectShell()
    impactBurst()
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" then
        currentArchetype = (payload and payload.Archetype) or "Carbine"
        currentDefinition = Arsenal.Get(currentArchetype) or Arsenal.Get("Carbine")
        task.defer(function()
            trackCurrentViewModel(true)
        end)
    elseif kind == "WeaponFX" and payload then
        if payload.Kind == "Shot" then
            if payload.Archetype then
                currentArchetype = payload.Archetype
                currentDefinition = Arsenal.Get(currentArchetype) or currentDefinition
            end
            onShot(payload)
        elseif payload.Kind == "Dash" then
            cameraRoll = math.clamp(cameraRoll + 0.75, -1, 1)
        elseif payload.Kind == "Reload" then
            cameraPitch = math.max(cameraPitch, 0.16)
        end
    elseif kind == "Hit" and payload then
        hitPulse = payload.Crit and 1.25 or 0.8
        if payload.Kill then
            killPulse = 1
        end
        createHitMarker(payload.Crit == true, payload.Kill == true)
    end
end)

player.CharacterAdded:Connect(function()
    task.delay(0.5, function()
        trackCurrentViewModel(true)
    end)
end)

RunService:BindToRenderStep("BreachWeaponFeel", Enum.RenderPriority.Camera.Value + 2, function(dt)
    trackCurrentViewModel(false)

    cameraPitch *= math.exp(-dt * 17)
    cameraYaw *= math.exp(-dt * 15)
    cameraRoll *= math.exp(-dt * 13)

    local camera = workspace.CurrentCamera
    if camera and (cameraPitch > 0.001 or math.abs(cameraYaw) > 0.001 or math.abs(cameraRoll) > 0.001) then
        camera.CFrame *= CFrame.Angles(math.rad(-cameraPitch), math.rad(cameraYaw), math.rad(cameraRoll))
    end

    animateWeaponParts(os.clock())
    animateCrosshair(dt)
end)

trackCurrentViewModel(true)
