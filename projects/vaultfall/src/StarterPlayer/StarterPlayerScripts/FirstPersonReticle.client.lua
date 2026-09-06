local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local stateRemote = remotes:WaitForChild("State")

local reloading = false
local arms = {}
local crosshair
local hud

local function captureCrosshair()
    hud = playerGui:FindFirstChild("BreachHUD")
    crosshair = hud and hud:FindFirstChild("Crosshair")
    if not crosshair or not crosshair:IsA("GuiObject") then
        table.clear(arms)
        return false
    end

    table.clear(arms)
    for _, child in ipairs(crosshair:GetChildren()) do
        if child:IsA("Frame") then
            local x = child.Position.X.Offset
            local y = child.Position.Y.Offset
            if math.abs(y) > math.abs(x) then
                table.insert(arms, { Part = child, Axis = "Y", Sign = y < 0 and -1 or 1 })
            elseif math.abs(x) > 0 then
                table.insert(arms, { Part = child, Axis = "X", Sign = x < 0 and -1 or 1 })
            end
        end
    end
    return true
end

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Combat" and payload then
        reloading = payload.Reloading == true
    end
end)

RunService:BindToRenderStep("BreachFirstPersonReticle", Enum.RenderPriority.Last.Value - 2, function(dt)
    if not crosshair or crosshair.Parent == nil then
        if not captureCrosshair() then
            return
        end
    end

    local modal = player:GetAttribute("VaultfallInputModal") == true
    crosshair.Visible = not modal
    if modal then
        return
    end

    local aiming = player:GetAttribute("VaultfallADS") == true
    local nearWall = tonumber(player:GetAttribute("VaultfallNearWall")) or 0
    local blocked = player:GetAttribute("VaultfallWeaponBlocked") == true
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local moving = humanoid and humanoid.MoveDirection.Magnitude > 0.08

    local targetSpread = aiming and 7 or 11
    if moving then
        targetSpread += aiming and 1.5 or 3.5
    end
    if reloading then
        targetSpread += 2
    end
    targetSpread += nearWall * 3

    local alpha = 1 - math.exp(-dt * 18)
    for _, arm in ipairs(arms) do
        local part = arm.Part
        if part.Parent then
            local current = arm.Axis == "X" and part.Position.X.Offset or part.Position.Y.Offset
            local target = targetSpread * arm.Sign
            local value = current + (target - current) * alpha
            if arm.Axis == "X" then
                part.Position = UDim2.new(0.5, value, 0.5, 0)
            else
                part.Position = UDim2.new(0.5, 0, 0.5, value)
            end
            part.BackgroundTransparency = reloading and 0.38 or 0
        end
    end

    crosshair.BackgroundTransparency = reloading and 0.28 or 0
    local targetColor = blocked and Color3.fromRGB(235, 155, 94) or Color3.fromRGB(235, 243, 246)
    crosshair.BackgroundColor3 = targetColor
    for _, arm in ipairs(arms) do
        if arm.Part.Parent then
            arm.Part.BackgroundColor3 = targetColor
        end
    end
end)
