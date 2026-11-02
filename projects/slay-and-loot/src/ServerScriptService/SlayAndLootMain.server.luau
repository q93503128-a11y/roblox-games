-- Server gameplay source for Build 1 micro-slice
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS:WaitForChild("SlayAndLoot")
local attackRE = remotes:WaitForChild("Attack")

local slime = workspace:WaitForChild("SlayAndLoot"):WaitForChild("Slime")
local state = {coins=0, weaponLevel=1, weaponXP=0}
local lastAttack = 0
local slimeGen = 1
local slimeHP = 45
local slimeMax = 45

local function damageForLevel(lvl)
    if lvl == 1 then return 10 end
    return 12
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

attackRE.OnServerEvent:Connect(function(player, targetGen)
    local now = tick()
    if now - lastAttack < 0.6 then return end
    lastAttack = now
    if targetGen ~= slime:GetAttribute("Generation") then return end
    if slimeHP <= 0 then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if (hrp.Position - slime.Position).Magnitude > 12 then return end
    local dmg = damageForLevel(state.weaponLevel)
    slimeHP = math.max(0, slimeHP - dmg)
    local bb = slime:FindFirstChildOfClass("BillboardGui")
    if bb then local l=bb:FindFirstChildOfClass("TextLabel"); if l then l.Text="Slime "..slimeHP.."/"..slimeMax end end
    if slimeHP <= 0 then
        state.coins = state.coins + 12
        if state.weaponLevel < 2 then
            state.weaponXP = state.weaponXP + 1
            if state.weaponXP >= 1 then
                state.weaponLevel = 2
                state.weaponXP = 0
            end
        end
        attackRE:FireClient(player, "kill", state.coins, state.weaponLevel, state.weaponXP, dmg)
        respawnSlime()
    else
        attackRE:FireClient(player, "hit", slimeHP, dmg)
    end
end)

slime:SetAttribute("Generation", slimeGen)
