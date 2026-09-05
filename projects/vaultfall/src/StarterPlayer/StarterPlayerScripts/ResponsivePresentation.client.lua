local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SCALE_NAME = "VaultfallResponsiveScale"
local tracked = setmetatable({}, { __mode = "k" })
local lastViewport = Vector2.zero

local function ensureScale(guiObject)
    if not guiObject or not guiObject:IsA("GuiObject") then
        return nil
    end

    local existing = guiObject:FindFirstChild(SCALE_NAME)
    if existing and existing:IsA("UIScale") then
        return existing
    end

    local scale = Instance.new("UIScale")
    scale.Name = SCALE_NAME
    scale.Scale = 1
    scale.Parent = guiObject
    return scale
end

local function findContainerByChild(root, childName)
    local child = root and root:FindFirstChild(childName, true)
    if not child then
        return nil
    end

    local current = child.Parent
    while current and current ~= root do
        if current:IsA("GuiObject") and current.Parent == root then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function scaleForViewport(viewport)
    local width = viewport.X
    local height = viewport.Y

    if width <= 0 or height <= 0 then
        return 1, false
    end

    local portrait = height > width
    if width < 390 then
        return 0.64, portrait
    elseif width < 520 then
        return 0.70, portrait
    elseif width < 700 then
        return 0.80, portrait
    elseif width < 900 then
        return 0.90, portrait
    end

    return 1, portrait
end

local function applyMainHud(viewport)
    local hud = playerGui:FindFirstChild("BreachHUD")
    if not hud or not hud:IsA("ScreenGui") then
        return
    end

    local scale, portrait = scaleForViewport(viewport)
    local compact = viewport.X < 700
    local narrow = viewport.X < 520

    local mission = hud:FindFirstChild("MissionBar")
    local stats = findContainerByChild(hud, "Essence")
    local health = findContainerByChild(hud, "HealthText")
    local weapon = findContainerByChild(hud, "WeaponName")
    local loot = hud:FindFirstChild("LootOffer")
    local controls = hud:FindFirstChild("Controls")
    local notice = hud:FindFirstChild("Notice")
    local hit = hud:FindFirstChild("HitFeedback")

    for _, object in ipairs({ mission, stats, health, weapon, loot, notice, hit }) do
        local uiScale = ensureScale(object)
        if uiScale then
            uiScale.Scale = scale
        end
    end

    if controls and controls:IsA("GuiObject") then
        local uiScale = ensureScale(controls)
        if uiScale then
            uiScale.Scale = math.max(0.72, scale)
        end
        controls.Visible = not UserInputService.TouchEnabled and not narrow
    end

    if mission and mission:IsA("GuiObject") then
        mission.Position = compact and UDim2.new(0.5, 0, 0, 8) or UDim2.new(0.5, 0, 0, 12)
    end

    if stats and stats:IsA("GuiObject") then
        if narrow then
            stats.Position = UDim2.new(1, -8, 0, 48)
        else
            stats.Position = UDim2.new(1, -14, 0, 14)
        end
    end

    if health and health:IsA("GuiObject") then
        if narrow or portrait then
            health.Position = UDim2.new(0, 10, 1, -116)
        else
            health.Position = UDim2.new(0, 16, 1, -18)
        end
    end

    if weapon and weapon:IsA("GuiObject") then
        weapon.Position = narrow and UDim2.new(1, -10, 1, -14) or UDim2.new(1, -16, 1, -18)
    end

    if loot and loot:IsA("GuiObject") then
        loot.Position = UDim2.fromScale(0.5, compact and 0.47 or 0.5)
    end

    if notice and notice:IsA("GuiObject") then
        notice.Position = compact and UDim2.new(0.5, -260, 0, 62) or UDim2.new(0.5, -260, 0, 72)
    end
end

local function applyEncounterHud(viewport)
    local hud = playerGui:FindFirstChild("BreachEncounterHUD")
    if not hud or not hud:IsA("ScreenGui") then
        return
    end

    local banner = hud:FindFirstChild("ThreatBanner")
    if not banner or not banner:IsA("GuiObject") then
        return
    end

    local scale = scaleForViewport(viewport)
    local uiScale = ensureScale(banner)
    if uiScale then
        uiScale.Scale = scale
    end

    banner.Position = viewport.X < 520 and UDim2.new(0.5, 0, 0, 58) or UDim2.new(0.5, 0, 0, 72)
end

local function applyResponsiveLayout(force)
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    if not force and (viewport - lastViewport).Magnitude < 1 then
        return
    end
    lastViewport = viewport

    applyMainHud(viewport)
    applyEncounterHud(viewport)
end

local function watchGui(child)
    if child.Name ~= "BreachHUD" and child.Name ~= "BreachEncounterHUD" then
        return
    end

    if tracked[child] then
        return
    end
    tracked[child] = true

    child.DescendantAdded:Connect(function()
        task.defer(applyResponsiveLayout, true)
    end)
    task.defer(applyResponsiveLayout, true)
end

for _, child in ipairs(playerGui:GetChildren()) do
    watchGui(child)
end
playerGui.ChildAdded:Connect(watchGui)

RunService.RenderStepped:Connect(function()
    applyResponsiveLayout(false)
end)
