-- Server gameplay source for Build 1 micro-slice (final authority repair)
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS:WaitForChild("SlayAndLoot")
local attackRE = remotes:WaitForChild("Attack")

local slime = workspace:WaitForChild("SlayAndLoot"):WaitForChild("Slime")
local slimeGen = 1
local slimeHP = 45
local slimeMax = 45

local playerStates = {}

local function newState()
    return {
        coins = 0,
        weaponLevel = 1,
        weaponXP = 0,
        lastAttack = 0,
    }
end

local function damageForLevel(lvl)
    if lvl == 1 then return 10 end
    return 12
end

local function hasRustySword(player)
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChild("Rusty Sword")
    return tool ~= nil and tool:IsA("Tool")
end

local function respawnSlime()
    task.delay(3, function()
        slimeGen = slimeGen + 1
        slimeHP = slimeMax
        slime:SetAttribute("Generation", slimeGen)
        local bb = slime:FindFirstChildOfClass("BillboardGui")
        if bb then local l=bb:FindFirstChildOfClass("TextLabel"); if l then l.Text="Slime "..slimeHP.."/"..slimeMax end end
    end)
end

Players.PlayerAdded:Connect(function(p)
    playerStates[p] = newState()
end)
for _,p in ipairs(Players:GetPlayers()) do
    if not playerStates[p] then playerStates[p]=newState() end
end
Players.PlayerRemoving:Connect(function(p)
    playerStates[p] = nil
end)

attackRE.OnServerEvent:Connect(function(player, targetGen)
    local st = playerStates[player]
    if not st then return end
    local now = tick()
    if now - st.lastAttack < 0.6 then return end
    if not hasRustySword(player) then return end
    if targetGen ~= slime:GetAttribute("Generation") then return end
    if slimeHP <= 0 then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if (hrp.Position - slime.Position).Magnitude > 12 then return end
    st.lastAttack = now
    local dmg = damageForLevel(st.weaponLevel)
    slimeHP = math.max(0, slimeHP - dmg)
    local bb = slime:FindFirstChildOfClass("BillboardGui")
    if bb then local l=bb:FindFirstChildOfClass("TextLabel"); if l then l.Text="Slime "..slimeHP.."/"..slimeMax end end
    if slimeHP <= 0 then
        st.coins = st.coins + 12
        if st.weaponLevel < 2 then
            st.weaponXP = st.weaponXP + 1
            if st.weaponXP >= 1 then
                st.weaponLevel = 2
                st.weaponXP = 0
            end
        end
        attackRE:FireClient(player, "kill", st.coins, st.weaponLevel, st.weaponXP, dmg)
        respawnSlime()
    else
        attackRE:FireClient(player, "hit", slimeHP, dmg)
    end
end)

slime:SetAttribute("Generation", slimeGen)
