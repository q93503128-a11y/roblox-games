local RunService = game:GetService("RunService")

local EnemyPresentationService = {}
local ctx
local rigs = {}
local accumulator = 0

local UPDATE_STEP = 1 / 30

local TYPE_ACCENTS = {
    Shade = Color3.fromRGB(150, 112, 220),
    Archer = Color3.fromRGB(87, 188, 151),
    Brute = Color3.fromRGB(224, 117, 72),
    Elite = Color3.fromRGB(222, 91, 176),
    VaultWarden = Color3.fromRGB(242, 77, 91),
}

local function motorPart(parent, root, name, size, offset, color)
    local limb = Instance.new("Part")
    limb.Name = name
    limb.Size = size
    limb.Material = Enum.Material.Slate
    limb.Color = color
    limb.Anchored = false
    limb.CanCollide = false
    limb.CanTouch = false
    limb.CanQuery = false
    limb.Massless = true
    limb.CFrame = root.CFrame * CFrame.new(offset)
    limb.TopSurface = Enum.SurfaceType.Smooth
    limb.BottomSurface = Enum.SurfaceType.Smooth
    limb.Parent = parent

    local motor = Instance.new("Motor6D")
    motor.Name = name .. "Motor"
    motor.Part0 = root
    motor.Part1 = limb
    motor.C0 = CFrame.new(offset)
    motor.C1 = CFrame.new()
    motor.Parent = root
    return limb, motor
end

local function addJointGlow(limb, name, accent, localOffset, radius)
    local glow = Instance.new("Part")
    glow.Name = name
    glow.Shape = Enum.PartType.Ball
    glow.Size = Vector3.new(radius, radius, radius)
    glow.Material = Enum.Material.Neon
    glow.Color = accent
    glow.Transparency = 0.08
    glow.Anchored = false
    glow.CanCollide = false
    glow.CanTouch = false
    glow.CanQuery = false
    glow.Massless = true
    glow.CFrame = limb.CFrame * CFrame.new(localOffset)
    glow.Parent = limb.Parent

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = limb
    weld.Part1 = glow
    weld.Parent = glow
end

local function baseColor(enemy)
    local body = enemy.Model:FindFirstChild("Body")
    if body and body:IsA("BasePart") then
        return body.Color
    end
    return Color3.fromRGB(74, 75, 83)
end

local function buildRig(enemy)
    if enemy.Model:FindFirstChild("ImportedVisual") then
        return nil
    end
    if enemy.Model:GetAttribute("ProceduralEnemyRig") then
        return nil
    end

    local radius = enemy.Data.Radius
    local root = enemy.Root
    local color = baseColor(enemy)
    local accent = TYPE_ACCENTS[enemy.Type] or Color3.fromRGB(183, 166, 235)
    local scale = enemy.Data.Boss and 1.18 or enemy.Data.Elite and 1.10 or 1

    local armSize = Vector3.new(radius * 0.48 * scale, radius * 1.52 * scale, radius * 0.52 * scale)
    local legSize = Vector3.new(radius * 0.58 * scale, radius * 1.55 * scale, radius * 0.68 * scale)
    local armX = radius * 0.96 * scale
    local armY = radius * 0.42
    local legX = radius * 0.43 * scale
    local legY = -radius * 1.05

    local leftArm, leftArmMotor = motorPart(enemy.Model, root, "LeftArm", armSize, Vector3.new(-armX, armY, 0), color)
    local rightArm, rightArmMotor = motorPart(enemy.Model, root, "RightArm", armSize, Vector3.new(armX, armY, 0), color)
    local leftLeg, leftLegMotor = motorPart(enemy.Model, root, "LeftLeg", legSize, Vector3.new(-legX, legY, 0), color:Lerp(Color3.new(0, 0, 0), 0.12))
    local rightLeg, rightLegMotor = motorPart(enemy.Model, root, "RightLeg", legSize, Vector3.new(legX, legY, 0), color:Lerp(Color3.new(0, 0, 0), 0.12))

    addJointGlow(leftArm, "LeftShoulderGlow", accent, Vector3.new(0, armSize.Y * 0.42, 0), math.max(0.28, radius * 0.22))
    addJointGlow(rightArm, "RightShoulderGlow", accent, Vector3.new(0, armSize.Y * 0.42, 0), math.max(0.28, radius * 0.22))

    local core = Instance.new("Part")
    core.Name = "MotionCore"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(radius * 0.46, radius * 0.46, radius * 0.46)
    core.Material = Enum.Material.Neon
    core.Color = accent
    core.Transparency = 0.12
    core.Anchored = false
    core.CanCollide = false
    core.CanTouch = false
    core.CanQuery = false
    core.Massless = true
    core.CFrame = root.CFrame * CFrame.new(0, radius * 0.42, -radius * 0.72)
    core.Parent = enemy.Model

    local coreMotor = Instance.new("Motor6D")
    coreMotor.Name = "MotionCoreMotor"
    coreMotor.Part0 = root
    coreMotor.Part1 = core
    coreMotor.C0 = CFrame.new(0, radius * 0.42, -radius * 0.72)
    coreMotor.Parent = root

    enemy.Model:SetAttribute("ProceduralEnemyRig", true)
    return {
        Enemy = enemy,
        LeftArm = leftArmMotor,
        RightArm = rightArmMotor,
        LeftLeg = leftLegMotor,
        RightLeg = rightLegMotor,
        Core = coreMotor,
        CorePart = core,
        Accent = accent,
        Phase = enemy.Id * 0.83,
        LastPosition = root.Position,
        MoveBlend = 0,
    }
end

local function attackPose(rig, enemy, attackAge)
    if attackAge < 0 or attackAge > 0.42 then
        return nil
    end

    local t = math.clamp(attackAge / 0.42, 0, 1)
    local punch = math.sin(t * math.pi)
    if enemy.Data.Ranged then
        return {
            LeftArm = -1.05 * punch,
            RightArm = -1.28 * punch,
            Roll = 0.18 * punch,
            Core = 0.32 * punch,
        }
    end

    return {
        LeftArm = -1.45 * punch,
        RightArm = 1.05 * punch,
        Roll = -0.32 * punch,
        Core = 0.46 * punch,
    }
end

local function animateRig(rig, dt, now)
    local enemy = rig.Enemy
    if not enemy.Alive or not enemy.Model.Parent then
        rigs[enemy.Id] = nil
        return
    end

    local currentPosition = enemy.Root.Position
    local planarDelta = Vector2.new(currentPosition.X - rig.LastPosition.X, currentPosition.Z - rig.LastPosition.Z)
    rig.LastPosition = currentPosition

    local moving = planarDelta.Magnitude > 0.025
    local targetMoveBlend = moving and 1 or 0
    rig.MoveBlend += (targetMoveBlend - rig.MoveBlend) * math.min(1, dt * 8)

    local gait = math.sin(now * (6.4 + enemy.Speed * 0.08) + rig.Phase)
    local stride = gait * 0.62 * rig.MoveBlend
    local idle = math.sin(now * 2.2 + rig.Phase) * 0.045 * (1 - rig.MoveBlend)
    local attack = attackPose(rig, enemy, now - enemy.LastAttack)

    local leftArm = -stride + idle
    local rightArm = stride - idle
    local bodyRoll = math.sin(now * 3.2 + rig.Phase) * 0.025 * rig.MoveBlend
    local corePulse = 0

    if attack then
        leftArm += attack.LeftArm
        rightArm += attack.RightArm
        bodyRoll += attack.Roll
        corePulse = attack.Core
    end

    rig.LeftArm.Transform = CFrame.Angles(leftArm, 0, -0.08 + bodyRoll)
    rig.RightArm.Transform = CFrame.Angles(rightArm, 0, 0.08 + bodyRoll)
    rig.LeftLeg.Transform = CFrame.Angles(stride, 0, 0)
    rig.RightLeg.Transform = CFrame.Angles(-stride, 0, 0)

    local bob = math.abs(gait) * 0.08 * rig.MoveBlend
    rig.Core.Transform = CFrame.new(0, bob, -corePulse * 0.28) * CFrame.Angles(0, now * 0.9 + rig.Phase, 0)
    rig.CorePart.Transparency = 0.12 - math.min(0.08, corePulse * 0.14)
end

local function discoverEnemies()
    for id, enemy in pairs(ctx.Enemies.GetAll()) do
        if not rigs[id] and enemy.Alive and enemy.Model.Parent then
            local rig = buildRig(enemy)
            if rig then
                rigs[id] = rig
            end
        end
    end
end

function EnemyPresentationService.Init(context)
    ctx = context

    RunService.Heartbeat:Connect(function(dt)
        accumulator += dt
        if accumulator < UPDATE_STEP then
            return
        end

        local step = accumulator
        accumulator = 0
        discoverEnemies()
        local now = os.clock()
        for _, rig in pairs(rigs) do
            animateRig(rig, step, now)
        end
    end)
end

return EnemyPresentationService
