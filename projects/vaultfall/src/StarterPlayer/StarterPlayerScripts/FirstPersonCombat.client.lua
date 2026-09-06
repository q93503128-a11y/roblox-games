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
local hiddenCharacter
local hiddenParts = {}

local function makeButtonModal(instance)
    if instance:IsA("GuiButton") then
        instance.Modal = true
    end
end

for _, descendant in ipairs(playerGui:GetDescendants()) do
    makeButtonModal(descendant)
end
playerGui.DescendantAdded:Connect(makeButtonModal)

local function registerHiddenPart(instance)
    if instance:IsA("BasePart") then
        hiddenParts[instance] = true
        instance.LocalTransparencyModifier = 1
    end
end

local function hideLocalCharacter(character)
    hiddenCharacter = character
    table.clear(hiddenParts)

    for _, descendant in ipairs(character:GetDescendants()) do
        registerHiddenPart(descendant)
    end
    character.DescendantAdded:Connect(registerHiddenPart)
end

local function enforceFirstPerson()
    player.CameraMode = Enum.CameraMode.LockFirstPerson
    player.CameraMinZoomDistance = 0.5
    player.CameraMaxZoomDistance = 0.5
end

enforceFirstPerson()
player:SetAttribute("VaultfallADS", false)
player:SetAttribute("VaultfallInputModal", false)
player:SetAttribute("VaultfallNearWall", 0)

player.CharacterAdded:Connect(function(character)
    enforceFirstPerson()
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
    elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
        triggerHeld = false
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

    -- Canonical keyboard reload. The server remains authoritative for ammo state.
    attackRemote:FireServer("Reload")
    return Enum.ContextActionResult.Sink
end

-- Own desktop FPS inputs at a higher priority than the legacy HUD client. This keeps
-- the old local-ammo path from consuming ammunition before server confirmation.
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

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
local smoothedNearWall = 0

RunService:BindToRenderStep("BreachFirstPerson", Enum.RenderPriority.Last.Value - 5, function(dt)
    if player.CameraMode ~= Enum.CameraMode.LockFirstPerson then
        enforceFirstPerson()
    end

    local isModal = modalOpen() or UserInputService:GetFocusedTextBox() ~= nil
    if isModal then
        triggerHeld = false
        aiming = false
    end
    player:SetAttribute("VaultfallADS", aiming)
    player:SetAttribute("VaultfallInputModal", isModal)

    -- Lock the pointer every frame outside menus so closing a modal cannot leave the
    -- player in an accidental free-cursor state.
    UserInputService.MouseIconEnabled = isModal
    UserInputService.MouseBehavior = isModal and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter

    if triggerHeld and currentDefinition.FireMode == "Auto" then
        requestFire()
    end

    -- Reassert only registered character parts instead of walking the full hierarchy
    -- every render frame. This prevents body/head flashes without unnecessary work.
    if player.Character == hiddenCharacter then
        for part in pairs(hiddenParts) do
            if part.Parent == nil then
                hiddenParts[part] = nil
            elseif part.LocalTransparencyModifier < 1 then
                part.LocalTransparencyModifier = 1
            end
        end
    end

    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local character = player.Character
    raycastParams.FilterDescendantsInstances = character and { character } or {}
    local wallHit = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * 3.4, raycastParams)
    local nearWall = 0
    if wallHit then
        nearWall = 1 - math.clamp(wallHit.Distance / 3.4, 0, 1)
    end

    -- Smooth wall proximity so the gun does not snap up/down on railings and doorframes.
    local wallAlpha = 1 - math.exp(-dt * 18)
    smoothedNearWall += (nearWall - smoothedNearWall) * wallAlpha
    player:SetAttribute("VaultfallNearWall", smoothedNearWall)
end)
