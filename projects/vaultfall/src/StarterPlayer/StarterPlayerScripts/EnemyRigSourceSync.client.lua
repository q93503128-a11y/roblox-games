local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local bindings = {}
local nextScanAt = 0

local ARTICULATED_NAMES = {
    LeftArm = true,
    RightArm = true,
    LeftLeg = true,
    RightLeg = true,
    MotionCore = true,
    LeftShoulderGlow = true,
    RightShoulderGlow = true,
}

local function findServerModel(presentation)
    local name = string.gsub(presentation.Name, "_LocalPresentation$", "")
    local world = Workspace:FindFirstChild("VaultfallWorld")
    local enemies = world and world:FindFirstChild("Enemies")
    local model = enemies and enemies:FindFirstChild(name)
    if model and model:IsA("Model") then
        return model
    end
    return nil
end

local function buildBinding(presentation)
    if bindings[presentation] then
        return
    end
    local model = findServerModel(presentation)
    if not model then
        return
    end

    local parts = {}
    for _, clone in ipairs(presentation:GetDescendants()) do
        if clone:IsA("BasePart") and ARTICULATED_NAMES[clone.Name] then
            local source = model:FindFirstChild(clone.Name, true)
            if source and source:IsA("BasePart") then
                table.insert(parts, {
                    clone = clone,
                    source = source,
                    cframe = clone.CFrame,
                })
            end
        end
    end

    if #parts > 0 then
        bindings[presentation] = {
            model = model,
            parts = parts,
        }
    end
end

local function scan()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and string.match(child.Name, "_LocalPresentation$") then
            buildBinding(child)
        end
    end
end

RunService:BindToRenderStep("VaultfallEnemyRigSourceSync", Enum.RenderPriority.Character.Value + 9, function(dt)
    local now = os.clock()
    if now >= nextScanAt then
        nextScanAt = now + 0.35
        scan()
    end

    local alpha = 1 - math.exp(-dt * 24)
    for presentation, binding in pairs(bindings) do
        if not presentation.Parent or not binding.model.Parent then
            bindings[presentation] = nil
        else
            for _, info in ipairs(binding.parts) do
                if info.clone.Parent and info.source.Parent then
                    info.cframe = info.cframe:Lerp(info.source.CFrame, alpha)
                    info.clone.CFrame = info.cframe
                end
            end
        end
    end
end)

script.AncestryChanged:Connect(function(_, parent)
    if parent then
        return
    end
    RunService:UnbindFromRenderStep("VaultfallEnemyRigSourceSync")
    table.clear(bindings)
end)
