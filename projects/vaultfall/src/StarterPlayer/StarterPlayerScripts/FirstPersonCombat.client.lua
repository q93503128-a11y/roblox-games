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

local hiddenCharacter
local function hideLocalCharacter(character)
    hiddenCharacter = character

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
player:SetAttribute("VaultfallADS", false)
player:SetAttribute("VaultfallInputModal", false)
player:SetAttribute("VaultfallNearWall", 0)

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
        player:SetAttribute("VaultfallADS", false)
        return Enum.ContextActionResult.Pass
    end

    if inputState == Enum.UserInputState.Begin then
        aiming = true
    elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
        aiming = false
    end
    player:SetAttribute("VaultfallADS", aiming)
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

-- Own desktop FPS inputs at a higher priority than the legacy HUD client.
-- R is deliberately the canonical keyboard reload binding.
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

local adsFov = {
    Carbine = 64,
    SMG = 66,
    Shotgun = 67,
    RailRifle = 61,
}

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true

RunService:BindToRenderStep("BreachFirstPerson", Enum.RenderPriority.Last.Value - 5, function(dt)
    if player.CameraMode ~= Enum.CameraMode.LockFirstPerson then
        player.CameraMode = Enum.CameraMode.LockFirstPerson
    end

    local isModal = modalOpen() or UserInputService:GetFocusedTextBox() ~= nil
    if isModal then
        triggerHeld = false
        aiming = false
    end
    player:SetAttribute("VaultfallADS", aiming)
    player:SetAttribute("VaultfallInputModal", isModal)

    -- LockFirstPerson normally owns the pointer. UI choices still need a usable cursor.
    UserInputService.MouseIconEnabled = isModal
    if isModal then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    if triggerHeld and currentDefinition.FireMode == "Auto" then
        requestFire()
    end

    -- Character transparency can be rewritten by Roblox character scripts after spawn.
    -- Reassert it cheaply so the head/arms never flash into the first-person camera.
    local character = player.Character
    if character and character == hiddenCharacter then
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.LocalTransparencyModifier < 1 then
                descendant.LocalTransparencyModifier = 1
            end
        end
    end

    local camera = workspace.CurrentCamera
    if camera then
        raycastParams.FilterDescendantsInstances = character and { character } or {}
        local wallHit = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 3, raycastParams)
        local nearWall = 0
        if wallHit then
            nearWall = 1 - math.clamp(wallHit.Distance / 3, 0, 1)
        end
        player:SetAttribute("VaultfallNearWall", nearWall)

        -- ADS focuses the view without forcing the weapon directly over the target.
        local archetype = currentWeapon.Archetype or "Carbine"
        local targetFov = aiming and (adsFov[archetype] or 64) or 72
        camera.FieldOfView += (targetFov - camera.FieldOfView) * math.min(1, dt * 14)
    end
end)
