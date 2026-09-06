local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Vaultfall")
local Arsenal = require(shared:WaitForChild("Arsenal"))
local remotes = ReplicatedStorage:WaitForChild("VaultfallRemotes")
local attackRemote = remotes:WaitForChild("Attack")
local stateRemote = remotes:WaitForChild("State")

local currentWeapon = {
    Archetype = "Carbine",
    FireIntervalMultiplier = 1,
}
local currentDefinition = Arsenal.Get("Carbine")
local triggerHeld = false
local aiming = false
local nextShotAt = 0

local function makeButtonModal(instance)
    if instance:IsA("GuiButton") then
        instance.Modal = true
    end
end

for _, descendant in ipairs(playerGui:GetDescendants()) do
    makeButtonModal(descendant)
end
playerGui.DescendantAdded:Connect(makeButtonModal)

local function hideLocalCharacter(character)
    local function hide(instance)
        if instance:IsA("BasePart") then
            instance.LocalTransparencyModifier = 1
        end
    end

    for _, descendant in ipairs(character:GetDescendants()) do
        hide(descendant)
    end
    character.DescendantAdded:Connect(hide)
end

player.CameraMode = Enum.CameraMode.LockFirstPerson
player.CameraMinZoomDistance = 0.5
player.CameraMaxZoomDistance = 0.5

player.CharacterAdded:Connect(function(character)
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    task.defer(hideLocalCharacter, character)
end)
if player.Character then
    task.defer(hideLocalCharacter, player.Character)
end

local function actualVisible(object)
    if not object or not object:IsA("GuiObject") or not object.Visible then
        return false
    end

    local current = object.Parent
    while current and current ~= playerGui do
        if current:IsA("GuiObject") and not current.Visible then
            return false
        end
        current = current.Parent
    end
    return true
end

local function modalOpen()
    local hud = playerGui:FindFirstChild("BreachHUD")
    local loot = hud and hud:FindFirstChild("LootOffer")
    if actualVisible(loot) then
        return true
    end

    local augments = playerGui:FindFirstChild("BreachAugments")
    local choice = augments and augments:FindFirstChild("ChoicePanel")
    if actualVisible(choice) then
        return true
    end

    for _, guiName in ipairs({ "ContractUI", "OperatorRecordUI", "WeaponMasteryUI" }) do
        local gui = playerGui:FindFirstChild(guiName)
        if gui then
            for _, child in ipairs(gui:GetChildren()) do
                if actualVisible(child) then
                    return true
                end
            end
        end
    end

    return false
end

local function requestFire()
    if modalOpen() or UserInputService:GetFocusedTextBox() then
        return
    end

    local now = os.clock()
    local interval = (currentDefinition.FireInterval or 0.15) * (currentWeapon.FireIntervalMultiplier or 1)
    if now < nextShotAt then
        return
    end
    nextShotAt = now + math.max(0.025, interval * 0.92)

    local camera = workspace.CurrentCamera
    local direction = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
    attackRemote:FireServer("Fire", direction)
end

local function fireAction(_, inputState)
    if modalOpen() or UserInputService:GetFocusedTextBox() then
        triggerHeld = false
        return Enum.ContextActionResult.Pass
    end

    if inputState == Enum.UserInputState.Begin then
        triggerHeld = true
        requestFire()
        return Enum.ContextActionResult.Sink
    elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
        triggerHeld = false
        return Enum.ContextActionResult.Sink
    end

    return Enum.ContextActionResult.Sink
end

local function aimAction(_, inputState)
    if modalOpen() or UserInputService:GetFocusedTextBox() then
        aiming = false
        return Enum.ContextActionResult.Pass
    end

    if inputState == Enum.UserInputState.Begin then
        aiming = true
    elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
        aiming = false
    end
    return Enum.ContextActionResult.Sink
end

local function reloadAction(_, inputState)
    if inputState ~= Enum.UserInputState.Begin then
        return Enum.ContextActionResult.Sink
    end
    if modalOpen() or UserInputService:GetFocusedTextBox() then
        return Enum.ContextActionResult.Pass
    end

    attackRemote:FireServer("Reload")
    return Enum.ContextActionResult.Sink
end

-- Own the desktop FPS inputs at a higher priority than the legacy HUD client.
-- This prevents rejected safehouse shots from locally consuming fake ammo.
ContextActionService:BindActionAtPriority(
    "BreachFPSFire",
    fireAction,
    false,
    3000,
    Enum.UserInputType.MouseButton1
)
ContextActionService:BindActionAtPriority(
    "BreachFPSAim",
    aimAction,
    false,
    3000,
    Enum.UserInputType.MouseButton2
)
ContextActionService:BindActionAtPriority(
    "BreachFPSReload",
    reloadAction,
    false,
    3000,
    Enum.KeyCode.R
)

stateRemote.OnClientEvent:Connect(function(kind, payload)
    if kind == "Weapon" and payload then
        currentWeapon = payload
        currentWeapon.Archetype = currentWeapon.Archetype or "Carbine"
        currentDefinition = Arsenal.Get(currentWeapon.Archetype) or Arsenal.Get("Carbine")
        nextShotAt = 0
    end
end)

RunService:BindToRenderStep("BreachFirstPerson", Enum.RenderPriority.Last.Value - 5, function(dt)
    if player.CameraMode ~= Enum.CameraMode.LockFirstPerson then
        player.CameraMode = Enum.CameraMode.LockFirstPerson
    end

    if triggerHeld and currentDefinition.FireMode == "Auto" then
        requestFire()
    end

    local camera = workspace.CurrentCamera
    if camera then
        -- Keep RMB as a clean focus aim instead of moving the blocky fallback gun
        -- into the middle of the target. The server ray still follows camera aim.
        local targetFov = aiming and 64 or 72
        camera.FieldOfView += (targetFov - camera.FieldOfView) * math.min(1, dt * 16)
    end
end)
