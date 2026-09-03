local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local MonsterConfig = require(ReplicatedStorage.Shared.MonsterConfig)

local DISPLAY_TO_DEF = {}
for monsterId, def in pairs(MonsterConfig.Definitions) do
    DISPLAY_TO_DEF[def.DisplayName] = {
        Id = monsterId,
        Def = def,
    }
end

local STYLE_BY_ID = {
    Slime = "slime",
    Mushroom = "mushroom",
    Bee = "bee",
    Wolf = "beast",
    Golem = "golem",
    Sandling = "slime",
    Scarab = "scarab",
    Jackal = "beast",
    Mummy = "humanoid",
    Sphinx = "sphinx",
    Snowball = "snowball",
    Penguin = "penguin",
    IceWolf = "beast",
    Yeti = "yeti",
    FrostDragon = "dragon",
    FactoryBot = "bot",
}

local RARITY_COLOR = {
    Common = Color3.fromRGB(190, 201, 215),
    Uncommon = Color3.fromRGB(95, 232, 130),
    Rare = Color3.fromRGB(85, 174, 255),
    Epic = Color3.fromRGB(183, 105, 255),
    Legendary = Color3.fromRGB(255, 196, 65),
    Exclusive = Color3.fromRGB(75, 229, 255),
}

local active = {}

local function part(model, name, size, localCF, color, material, shape)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = model.PrimaryPart.CFrame * localCF
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Shape = shape or Enum.PartType.Block
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CanQuery = false
    p.CastShadow = true
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = model
    return p
end

local function eye(model, x, y, z, scale)
    return part(
        model,
        "Eye",
        Vector3.new(0.28, 0.38, 0.16) * (scale or 1),
        CFrame.new(x, y, z),
        Color3.fromRGB(20, 25, 31),
        Enum.Material.SmoothPlastic
    )
end

local function addNameplate(model, displayName, rarity, bonus, shiny)
    local root = model.PrimaryPart
    local gui = Instance.new("BillboardGui")
    gui.Name = "WorkerNameplate"
    gui.Size = UDim2.fromOffset(168, 48)
    gui.StudsOffset = Vector3.new(0, 4.9, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 90
    gui.Adornee = root
    gui.Parent = root

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(17, 22, 30)
    frame.BackgroundTransparency = 0.08
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = shiny and Color3.fromRGB(255, 221, 87) or (RARITY_COLOR[rarity] or Color3.new(1, 1, 1))
    stroke.Thickness = shiny and 2 or 1
    stroke.Transparency = 0.15
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -8, 0, 27)
    title.Position = UDim2.fromOffset(4, 2)
    title.BackgroundTransparency = 1
    title.Text = (shiny and "SHINY " or "") .. displayName
    title.TextColor3 = Color3.fromRGB(246, 249, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = frame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, -8, 0, 17)
    sub.Position = UDim2.fromOffset(4, 27)
    sub.BackgroundTransparency = 1
    sub.Text = string.format("%s  •  +%d%%", rarity or "Worker", math.floor((bonus or 0) * 100))
    sub.TextColor3 = RARITY_COLOR[rarity] or Color3.fromRGB(175, 188, 205)
    sub.Font = Enum.Font.GothamMedium
    sub.TextSize = 10
    sub.Parent = frame
end

local function buildSlime(model, color)
    part(model, "Body", Vector3.new(3.5, 3.2, 3.3), CFrame.new(0, 1.7, 0), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    part(model, "Foot", Vector3.new(3.2, 0.45, 2.8), CFrame.new(0, 0.35, 0.12), color:Lerp(Color3.new(0, 0, 0), 0.08))
    eye(model, -0.62, 2.0, -1.55, 1.1)
    eye(model, 0.62, 2.0, -1.55, 1.1)
end

local function buildMushroom(model, color)
    local cream = Color3.fromRGB(242, 224, 188)
    part(model, "Stem", Vector3.new(1.6, 2.4, 1.5), CFrame.new(0, 1.3, 0), cream)
    part(model, "Cap", Vector3.new(3.6, 1.7, 3.5), CFrame.new(0, 3.0, 0), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    part(model, "CapSpotL", Vector3.new(0.55, 0.25, 0.55), CFrame.new(-0.8, 3.72, -0.5), Color3.fromRGB(255, 240, 224), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    part(model, "CapSpotR", Vector3.new(0.45, 0.22, 0.45), CFrame.new(0.9, 3.55, 0.2), Color3.fromRGB(255, 240, 224), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    eye(model, -0.42, 1.65, -0.76, 0.8)
    eye(model, 0.42, 1.65, -0.76, 0.8)
end

local function buildBee(model, color)
    local dark = Color3.fromRGB(35, 38, 43)
    local wing = Color3.fromRGB(211, 247, 255)
    part(model, "Body", Vector3.new(3.4, 2.2, 2.4), CFrame.new(0, 2.0, 0), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    part(model, "StripeA", Vector3.new(0.45, 2.0, 2.05), CFrame.new(-0.55, 2.0, 0), dark)
    part(model, "StripeB", Vector3.new(0.45, 2.0, 2.05), CFrame.new(0.65, 2.0, 0), dark)
    part(model, "WingL", Vector3.new(1.7, 0.25, 2.2), CFrame.new(-1.45, 2.9, 0.35) * CFrame.Angles(0, 0, math.rad(24)), wing, Enum.Material.Glass)
    part(model, "WingR", Vector3.new(1.7, 0.25, 2.2), CFrame.new(1.45, 2.9, 0.35) * CFrame.Angles(0, 0, math.rad(-24)), wing, Enum.Material.Glass)
    eye(model, -0.5, 2.3, -1.15, 0.9)
    eye(model, 0.5, 2.3, -1.15, 0.9)
    part(model, "AntennaL", Vector3.new(0.16, 1.2, 0.16), CFrame.new(-0.55, 3.45, -0.7) * CFrame.Angles(math.rad(-20), 0, math.rad(-15)), dark)
    part(model, "AntennaR", Vector3.new(0.16, 1.2, 0.16), CFrame.new(0.55, 3.45, -0.7) * CFrame.Angles(math.rad(-20), 0, math.rad(15)), dark)
end

local function buildBeast(model, color)
    local dark = color:Lerp(Color3.new(0, 0, 0), 0.28)
    part(model, "Body", Vector3.new(3.3, 2.0, 4.0), CFrame.new(0, 2.0, 0.25), color)
    part(model, "Head", Vector3.new(2.4, 2.4, 2.4), CFrame.new(0, 2.65, -2.25), color)
    part(model, "Muzzle", Vector3.new(1.35, 0.8, 0.9), CFrame.new(0, 2.15, -3.35), dark)
    part(model, "EarL", Vector3.new(0.7, 1.2, 0.55), CFrame.new(-0.72, 4.0, -2.15) * CFrame.Angles(0, 0, math.rad(-14)), dark)
    part(model, "EarR", Vector3.new(0.7, 1.2, 0.55), CFrame.new(0.72, 4.0, -2.15) * CFrame.Angles(0, 0, math.rad(14)), dark)
    for _, x in ipairs({-1.05, 1.05}) do
        for _, z in ipairs({-1.0, 1.35}) do
            part(model, "Leg", Vector3.new(0.7, 1.55, 0.8), CFrame.new(x, 0.8, z), dark)
        end
    end
    part(model, "Tail", Vector3.new(0.55, 0.55, 2.5), CFrame.new(0, 2.25, 2.8) * CFrame.Angles(math.rad(-18), 0, 0), dark)
    eye(model, -0.48, 2.9, -3.45, 0.75)
    eye(model, 0.48, 2.9, -3.45, 0.75)
end

local function buildHumanoid(model, color, bulky)
    local dark = color:Lerp(Color3.new(0, 0, 0), 0.2)
    local torsoSize = bulky and Vector3.new(3.3, 3.0, 2.2) or Vector3.new(2.7, 2.8, 1.9)
    part(model, "Torso", torsoSize, CFrame.new(0, 2.35, 0), color)
    part(model, "Head", Vector3.new(2.0, 1.9, 1.9), CFrame.new(0, 4.65, -0.05), color:Lerp(Color3.new(1, 1, 1), 0.08))
    part(model, "ArmL", Vector3.new(0.75, 2.7, 0.85), CFrame.new(-1.95, 2.45, 0), dark)
    part(model, "ArmR", Vector3.new(0.75, 2.7, 0.85), CFrame.new(1.95, 2.45, 0), dark)
    part(model, "LegL", Vector3.new(0.9, 1.8, 1.0), CFrame.new(-0.72, 0.85, 0), dark)
    part(model, "LegR", Vector3.new(0.9, 1.8, 1.0), CFrame.new(0.72, 0.85, 0), dark)
    eye(model, -0.4, 4.82, -1.03, 0.8)
    eye(model, 0.4, 4.82, -1.03, 0.8)
end

local function buildGolem(model, color)
    buildHumanoid(model, color, true)
    part(model, "ShoulderL", Vector3.new(1.45, 1.3, 1.5), CFrame.new(-2.05, 3.6, 0), color:Lerp(Color3.new(0, 0, 0), 0.3))
    part(model, "ShoulderR", Vector3.new(1.45, 1.3, 1.5), CFrame.new(2.05, 3.6, 0), color:Lerp(Color3.new(0, 0, 0), 0.3))
    part(model, "Core", Vector3.new(0.8, 0.8, 0.25), CFrame.new(0, 2.5, -1.18), Color3.fromRGB(118, 255, 151), Enum.Material.Neon)
end

local function buildScarab(model, color)
    local gold = Color3.fromRGB(244, 193, 67)
    local dark = Color3.fromRGB(46, 38, 31)
    part(model, "Shell", Vector3.new(3.6, 1.6, 4.1), CFrame.new(0, 2.0, 0), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    part(model, "ShellLine", Vector3.new(0.25, 1.5, 3.7), CFrame.new(0, 2.08, 0), gold, Enum.Material.Metal)
    part(model, "Head", Vector3.new(2.1, 1.35, 1.65), CFrame.new(0, 1.95, -2.35), dark)
    for _, x in ipairs({-1, 1}) do
        for _, z in ipairs({-1.2, 0, 1.2}) do
            part(model, "Leg", Vector3.new(1.7, 0.28, 0.32), CFrame.new(1.7 * x, 1.25, z) * CFrame.Angles(0, 0, math.rad(12 * x)), dark)
        end
    end
    eye(model, -0.38, 2.08, -3.18, 0.7)
    eye(model, 0.38, 2.08, -3.18, 0.7)
end

local function buildSphinx(model, color)
    buildBeast(model, color)
    local gold = Color3.fromRGB(255, 205, 74)
    part(model, "Crown", Vector3.new(2.1, 0.55, 1.9), CFrame.new(0, 4.15, -2.25), gold, Enum.Material.Metal)
    part(model, "CrownGem", Vector3.new(0.45, 0.7, 0.25), CFrame.new(0, 4.42, -3.24), Color3.fromRGB(70, 210, 255), Enum.Material.Neon)
end

local function buildSnowball(model, color)
    part(model, "Body", Vector3.new(3.4, 3.4, 3.4), CFrame.new(0, 1.8, 0), color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    part(model, "Scarf", Vector3.new(3.0, 0.45, 3.0), CFrame.new(0, 2.2, -0.05), Color3.fromRGB(73, 166, 255))
    eye(model, -0.55, 2.2, -1.62, 0.9)
    eye(model, 0.55, 2.2, -1.62, 0.9)
end

local function buildPenguin(model)
    local dark = Color3.fromRGB(50, 64, 78)
    local white = Color3.fromRGB(236, 247, 255)
    local orange = Color3.fromRGB(255, 162, 51)
    part(model, "Body", Vector3.new(3.0, 3.8, 2.6), CFrame.new(0, 2.0, 0), dark, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
    part(model, "Belly", Vector3.new(1.8, 2.4, 0.3), CFrame.new(0, 1.95, -1.27), white)
    part(model, "Beak", Vector3.new(0.85, 0.4, 0.75), CFrame.new(0, 2.75, -1.7), orange)
    part(model, "WingL", Vector3.new(0.5, 2.2, 1.0), CFrame.new(-1.55, 2.05, 0) * CFrame.Angles(0, 0, math.rad(-18)), dark)
    part(model, "WingR", Vector3.new(0.5, 2.2, 1.0), CFrame.new(1.55, 2.05, 0) * CFrame.Angles(0, 0, math.rad(18)), dark)
    eye(model, -0.48, 3.1, -1.28, 0.75)
    eye(model, 0.48, 3.1, -1.28, 0.75)
end

local function buildYeti(model, color)
    buildHumanoid(model, color, true)
    part(model, "Brow", Vector3.new(1.7, 0.28, 0.3), CFrame.new(0, 5.1, -1.03), Color3.fromRGB(100, 150, 184))
    part(model, "Chest", Vector3.new(1.8, 1.5, 0.3), CFrame.new(0, 2.6, -1.18), Color3.fromRGB(232, 247, 255))
end

local function buildDragon(model, color)
    local dark = color:Lerp(Color3.new(0, 0, 0), 0.25)
    local light = color:Lerp(Color3.new(1, 1, 1), 0.25)
    part(model, "Body", Vector3.new(3.6, 2.4, 4.2), CFrame.new(0, 2.1, 0), color)
    part(model, "Head", Vector3.new(2.6, 2.1, 2.8), CFrame.new(0, 3.0, -2.7), color)
    part(model, "Snout", Vector3.new(1.8, 0.9, 1.2), CFrame.new(0, 2.65, -4.1), dark)
    part(model, "WingL", Vector3.new(3.0, 0.35, 3.3), CFrame.new(-2.3, 3.25, 0.3) * CFrame.Angles(math.rad(5), 0, math.rad(24)), light, Enum.Material.Glass)
    part(model, "WingR", Vector3.new(3.0, 0.35, 3.3), CFrame.new(2.3, 3.25, 0.3) * CFrame.Angles(math.rad(5), 0, math.rad(-24)), light, Enum.Material.Glass)
    for _, x in ipairs({-1.0, 1.0}) do
        part(model, "Leg", Vector3.new(0.75, 1.7, 0.85), CFrame.new(x, 0.9, 0.85), dark)
    end
    part(model, "Tail", Vector3.new(0.7, 0.7, 3.5), CFrame.new(0, 2.0, 3.3) * CFrame.Angles(math.rad(-12), 0, 0), dark)
    part(model, "HornL", Vector3.new(0.4, 1.1, 0.4), CFrame.new(-0.72, 4.25, -2.55) * CFrame.Angles(0, 0, math.rad(-20)), light)
    part(model, "HornR", Vector3.new(0.4, 1.1, 0.4), CFrame.new(0.72, 4.25, -2.55) * CFrame.Angles(0, 0, math.rad(20)), light)
    eye(model, -0.52, 3.25, -4.15, 0.75)
    eye(model, 0.52, 3.25, -4.15, 0.75)
end

local function buildBot(model, color)
    local dark = Color3.fromRGB(42, 52, 65)
    part(model, "Torso", Vector3.new(3.0, 2.7, 2.1), CFrame.new(0, 2.2, 0), dark, Enum.Material.Metal)
    part(model, "Screen", Vector3.new(2.25, 1.25, 0.25), CFrame.new(0, 2.35, -1.18), color, Enum.Material.Neon)
    part(model, "Head", Vector3.new(2.3, 1.6, 1.8), CFrame.new(0, 4.25, 0), dark, Enum.Material.Metal)
    part(model, "EyeBar", Vector3.new(1.45, 0.3, 0.22), CFrame.new(0, 4.35, -1.02), Color3.fromRGB(130, 236, 255), Enum.Material.Neon)
    part(model, "ArmL", Vector3.new(0.65, 2.2, 0.7), CFrame.new(-1.85, 2.2, 0), color, Enum.Material.Metal)
    part(model, "ArmR", Vector3.new(0.65, 2.2, 0.7), CFrame.new(1.85, 2.2, 0), color, Enum.Material.Metal)
    part(model, "LegL", Vector3.new(0.8, 1.5, 0.9), CFrame.new(-0.7, 0.75, 0), dark, Enum.Material.Metal)
    part(model, "LegR", Vector3.new(0.8, 1.5, 0.9), CFrame.new(0.7, 0.75, 0), dark, Enum.Material.Metal)
    part(model, "Antenna", Vector3.new(0.18, 1.0, 0.18), CFrame.new(0, 5.55, 0), color, Enum.Material.Metal)
    part(model, "AntennaTip", Vector3.new(0.42, 0.42, 0.42), CFrame.new(0, 6.05, 0), color, Enum.Material.Neon, Enum.PartType.Ball)
end

local BUILDERS = {
    slime = buildSlime,
    mushroom = buildMushroom,
    bee = buildBee,
    beast = buildBeast,
    golem = buildGolem,
    scarab = buildScarab,
    humanoid = function(model, color) buildHumanoid(model, color, false) end,
    sphinx = buildSphinx,
    snowball = buildSnowball,
    penguin = function(model) buildPenguin(model) end,
    yeti = buildYeti,
    dragon = buildDragon,
    bot = buildBot,
}

local function resolveWorker(orb)
    local name = "Worker"
    local billboard = orb:FindFirstChildOfClass("BillboardGui")
    if billboard then
        local label = billboard:FindFirstChildOfClass("TextLabel")
        if label and label.Text ~= "" then
            name = label.Text
        end
    end

    local shiny = string.sub(name, 1, 6) == "SHINY "
    if shiny then
        name = string.sub(name, 7)
    end

    local match = DISPLAY_TO_DEF[name]
    return name, shiny, match and match.Id, match and match.Def
end

local function convertOrb(orb, index)
    if not orb:IsA("BasePart") or orb:GetAttribute("MFRichConverted") then
        return
    end
    orb:SetAttribute("MFRichConverted", true)

    local displayName, shiny, monsterId, def = resolveWorker(orb)
    local color = (def and def.Color) or orb.Color
    local style = STYLE_BY_ID[monsterId] or "slime"
    local rarity = def and def.Rarity or "Common"
    local bonus = def and MonsterConfig.GetEffectiveBonus(monsterId, shiny) or 0

    local model = Instance.new("Model")
    model.Name = "WorkerCharacter_" .. tostring(index or 0) .. "_" .. tostring(monsterId or "Unknown")
    model:SetAttribute("MonsterId", monsterId or "Unknown")
    model:SetAttribute("Shiny", shiny)
    model.Parent = orb.Parent

    local root = Instance.new("Part")
    root.Name = "Root"
    root.Size = Vector3.new(1, 1, 1)
    root.Transparency = 1
    root.Anchored = true
    root.CanCollide = false
    root.CanTouch = false
    root.CanQuery = false
    root.CFrame = orb.CFrame * CFrame.new(0, -2.25, 0)
    root.Parent = model
    model.PrimaryPart = root

    local builder = BUILDERS[style] or buildSlime
    builder(model, color)

    if shiny then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ShinyHighlight"
        highlight.FillColor = Color3.fromRGB(255, 226, 104)
        highlight.FillTransparency = 0.72
        highlight.OutlineColor = Color3.fromRGB(255, 247, 190)
        highlight.OutlineTransparency = 0.08
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded
        highlight.Parent = model

        part(model, "ShinyHalo", Vector3.new(2.8, 0.16, 2.8), CFrame.new(0, 5.55, 0), Color3.fromRGB(255, 221, 86), Enum.Material.Neon)
    end

    addNameplate(model, displayName, rarity, bonus, shiny)

    active[model] = {
        base = root.CFrame,
        phase = (index or 1) * 0.83,
        shiny = shiny,
    }

    orb:Destroy()
end

local function convertFolder(folder)
    if not folder or folder.Name ~= "ClientWorkerVisuals" then
        return
    end

    task.defer(function()
        local list = {}
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("BasePart") and string.sub(child.Name, 1, 7) == "Worker_" then
                table.insert(list, child)
            end
        end
        table.sort(list, function(a, b) return a.Name < b.Name end)
        for index, orb in ipairs(list) do
            if orb.Parent == folder then
                convertOrb(orb, index)
            end
        end
    end)

    folder.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") and string.sub(child.Name, 1, 7) == "Worker_" then
            task.defer(function()
                if child.Parent == folder then
                    convertOrb(child, tonumber(string.match(child.Name, "(%d+)$")) or 1)
                end
            end)
        end
    end)
end

for _, child in ipairs(workspace:GetChildren()) do
    if child.Name == "ClientWorkerVisuals" then
        convertFolder(child)
    end
end

workspace.ChildAdded:Connect(function(child)
    if child.Name == "ClientWorkerVisuals" then
        convertFolder(child)
    end
end)

RunService.RenderStepped:Connect(function()
    local now = os.clock()
    for model, info in pairs(active) do
        if not model.Parent or not model.PrimaryPart then
            active[model] = nil
        else
            local bob = math.sin(now * 2.1 + info.phase) * 0.11
            local turn = math.sin(now * 0.55 + info.phase) * math.rad(4)
            model:PivotTo(info.base * CFrame.new(0, bob, 0) * CFrame.Angles(0, turn, 0))
        end
    end
end)
