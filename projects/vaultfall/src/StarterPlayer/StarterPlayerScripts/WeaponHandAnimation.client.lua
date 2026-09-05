local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local currentArchetype = "Carbine"
local reloadStartedAt = -100
local reloadDuration = 0
local swapStartedAt = -100
local dashStartedAt = -100
local model = nil
local root = nil
local rightHand = nil
local leftHand = nil
local rightSize = Vector3.new(0.36, 0.44, 0.52)
local leftSize = Vector3.new(0.36, 0.44, 0.52)

local function smoothstep(value)
    local t = math.clamp(value, 0, 1)
    return t * t * (3 - (2 * t))
end

local function pulse01(value)
    local t = math.clamp(value, 0, 1)
    return math.sin(t * math.pi)
end

local function refreshViewmodel()
    local camera = workspace.CurrentCamera
    local candidate = camera and camera:FindFirstChild("BreachWeaponViewmodel")
    if candidate ~= model then
        model = candidate
        root = model and model.PrimaryPart or nil
        rightHand = nil
        leftHand = nil
    elseif model then
        root = model.PrimaryPart
    end

    if not model or not root then
        return false
    end

    local candidateRight = model:FindFirstChild("FeelRightHand")
    local candidateLeft = model:FindFirstChild("FeelLeftHand")
    if candidateRight and candidateRight:IsA("BasePart") then
        rightHand = candidateRight
        rightSize = candidateRight.Size
    end
    if candidateLeft and candidateLeft:IsA("BasePart") then
        leftHand = candidateLeft
        leftSize = candidateLeft.Size
    end

    return rightHand ~= nil and leftHand ~= nil
end

local function cframeLerp(a, b, alpha)
    return a:Lerp(b, math.clamp(alpha, 0, 1))
end

local function basePose(now, moveAmount)
    local breathing = math.sin(now * 1.75) * 0.012
    local step = math.sin(now * (5.8 + moveAmount * 2.2))
    local side = math.cos(now * (2.9 + moveAmount * 1.1))
    local motion = moveAmount * 0.026

    local right = CFrame.new(
        0.34 + side * motion * 0.45,
        -0.47 + breathing + math.abs(step) * motion * 0.35,
        0.26 + step * motion * 0.28
    ) * CFrame.Angles(
        math.rad(-18 + step * moveAmount * 1.4),
        math.rad(9 + side * moveAmount * 1.1),
        math.rad(-16 - side * moveAmount * 1.7)
    )

    local leftZ = currentArchetype == "RailRifle" and -0.82
        or (currentArchetype == "Shotgun" and -0.94 or -0.72)
    local left = CFrame.new(
        -0.28 - side * motion * 0.35,
        -0.38 - breathing - math.abs(step) * motion * 0.28,
        leftZ - step * motion * 0.22
    ) * CFrame.Angles(
        math.rad(-12 - step * moveAmount * 1.2),
        math.rad(-12 - side * moveAmount),
        math.rad(19 + side * moveAmount * 1.5)
    )

    return right, left
end

local function swapPose(now, right, left)
    local age = now - swapStartedAt
    if age < 0 or age > 0.72 then
        return right, left
    end

    local phase = age / 0.72
    local dip
    if phase < 0.42 then
        dip = smoothstep(phase / 0.42)
    else
        dip = 1 - smoothstep((phase - 0.42) / 0.58)
    end

    local rightSwap = CFrame.new(0.58, -0.86, 0.72) * CFrame.Angles(math.rad(-38), math.rad(18), math.rad(-31))
    local leftSwap = CFrame.new(-0.52, -0.72, -0.18) * CFrame.Angles(math.rad(-25), math.rad(-26), math.rad(31))
    return cframeLerp(right, rightSwap, dip), cframeLerp(left, leftSwap, dip)
end

local function magazineReloadPose(phase, right, left)
    local rightTarget = right
    local leftTarget = left

    if phase < 0.20 then
        local t = smoothstep(phase / 0.20)
        leftTarget = CFrame.new(-0.42, -0.62, 0.06) * CFrame.Angles(math.rad(-34), math.rad(-24), math.rad(36))
        left = cframeLerp(left, leftTarget, t)
    elseif phase < 0.46 then
        local t = smoothstep((phase - 0.20) / 0.26)
        leftTarget = CFrame.new(-0.62, -0.92, 0.52) * CFrame.Angles(math.rad(-62), math.rad(-34), math.rad(50))
        left = cframeLerp(CFrame.new(-0.42, -0.62, 0.06) * CFrame.Angles(math.rad(-34), math.rad(-24), math.rad(36)), leftTarget, t)
    elseif phase < 0.76 then
        local t = smoothstep((phase - 0.46) / 0.30)
        leftTarget = CFrame.new(-0.16, -0.58, 0.04) * CFrame.Angles(math.rad(-24), math.rad(-9), math.rad(24))
        left = cframeLerp(CFrame.new(-0.62, -0.92, 0.52) * CFrame.Angles(math.rad(-62), math.rad(-34), math.rad(50)), leftTarget, t)
    else
        local t = smoothstep((phase - 0.76) / 0.24)
        rightTarget = CFrame.new(0.46, -0.40, -0.10) * CFrame.Angles(math.rad(-10), math.rad(15), math.rad(-22))
        right = cframeLerp(rightTarget, right, t)
        left = cframeLerp(CFrame.new(-0.16, -0.58, 0.04) * CFrame.Angles(math.rad(-24), math.rad(-9), math.rad(24)), left, t)
    end

    return right, left
end

local function shotgunReloadPose(phase, right, left)
    local cycle = math.clamp((phase - 0.12) / 0.70, 0, 0.999)
    local shellPhase = (cycle * 4) % 1
    local insertion = pulse01(shellPhase)
    local prep = smoothstep(math.clamp(phase / 0.16, 0, 1))
    local settle = smoothstep(math.clamp((phase - 0.84) / 0.16, 0, 1))

    local rightHold = CFrame.new(0.42, -0.42, 0.38) * CFrame.Angles(math.rad(-26), math.rad(7), math.rad(-19))
    local leftFeed = CFrame.new(-0.44 + insertion * 0.28, -0.78 + insertion * 0.31, -0.02 - insertion * 0.23)
        * CFrame.Angles(math.rad(-52 + insertion * 28), math.rad(-22), math.rad(42 - insertion * 18))

    right = cframeLerp(right, rightHold, prep * (1 - settle))
    left = cframeLerp(left, leftFeed, prep * (1 - settle))
    return right, left
end

local function railReloadPose(phase, right, left)
    local cradle = CFrame.new(-0.54, -0.72, 0.22) * CFrame.Angles(math.rad(-46), math.rad(-30), math.rad(43))
    local cellSeat = CFrame.new(-0.20, -0.48, 0.10) * CFrame.Angles(math.rad(-24), math.rad(-10), math.rad(27))
    local rightCharge = CFrame.new(0.47, -0.34, -0.32) * CFrame.Angles(math.rad(-7), math.rad(16), math.rad(-22))

    if phase < 0.38 then
        left = cframeLerp(left, cradle, smoothstep(phase / 0.38))
    elseif phase < 0.78 then
        left = cframeLerp(cradle, cellSeat, smoothstep((phase - 0.38) / 0.40))
    else
        local t = smoothstep((phase - 0.78) / 0.22)
        right = cframeLerp(rightCharge, right, t)
        left = cframeLerp(cellSeat, left, t)
    end

    return right, left
end

local function applyReloadPose(now, right, left)
    if reloadDuration <= 0 then
        return right, left
    end

    local phase = (now - reloadStartedAt) / reloadDuration
    if phase < 0 or phase >= 1 then
        reloadDuration = 0
        return right, left
    end

    if currentArchetype == "Shotgun" then
        return shotgunReloadPose(phase, right, left)
    elseif currentArchetype == "RailRifle" then
        return railReloadPose(phase, right, left)
    end
    return magazineReloadPose(phase, right, left)
end

local function applyDashPose(now, right, left)
    local age = now - dashStartedAt
    if age < 0 or age > 0.36 then
        return right, left
    end

    local amount = pulse01(age / 0.36)
    local rightDash = CFrame.new(0.50, -0.70, 0.82) * CFrame.Angles(math.rad(-42), math.rad(20), math.rad(-32))
    local leftDash = CFrame.new(-0.40, -0.63, 0.12) * CFrame.Angles(math.rad(-30), math.rad(-20), math.rad(30))
    return cframeLerp(right, rightDash, amount), cframeLerp(left, leftDash, amount)
end

local function currentMoveAmount()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return 0
    end
    return math.clamp(humanoid.MoveDirection.Magnitude, 0, 1)
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" then
        currentArchetype = (payload and payload.Archetype) or currentArchetype
        swapStartedAt = os.clock()
        reloadDuration = 0
    elseif kind == "WeaponFX" and payload then
        if payload.Kind == "Reload" then
            currentArchetype = payload.Archetype or currentArchetype
            reloadStartedAt = os.clock()
            reloadDuration = math.max(0.3, payload.Duration or 1.8)
        elseif payload.Kind == "Dash" then
            dashStartedAt = os.clock()
        end
    elseif kind == "Combat" and payload and payload.Reloading == false then
        if reloadDuration > 0 and os.clock() - reloadStartedAt > reloadDuration * 0.72 then
            reloadDuration = 0
        end
    end
end)

player.CharacterAdded:Connect(function()
    model = nil
    root = nil
    rightHand = nil
    leftHand = nil
    reloadDuration = 0
    swapStartedAt = os.clock()
end)

RunService:BindToRenderStep("VaultfallHandAnimation", Enum.RenderPriority.Camera.Value + 4, function()
    if not refreshViewmodel() or not root or not rightHand or not leftHand then
        return
    end

    local now = os.clock()
    local rightPose, leftPose = basePose(now, currentMoveAmount())
    rightPose, leftPose = swapPose(now, rightPose, leftPose)
    rightPose, leftPose = applyReloadPose(now, rightPose, leftPose)
    rightPose, leftPose = applyDashPose(now, rightPose, leftPose)

    rightHand.Size = rightSize
    leftHand.Size = leftSize
    rightHand.CFrame = root.CFrame * rightPose
    leftHand.CFrame = root.CFrame * leftPose
end)
