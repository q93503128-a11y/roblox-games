-- Client gameplay source for Build 1 micro-slice
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local remotes = RS:WaitForChild("SlayAndLoot")
local attackRE = remotes:WaitForChild("Attack")
local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("SlayAndLootUI")
local coinsLbl = gui:WaitForChild("Coins")
local weaponLbl = gui:WaitForChild("Weapon")
local notifyLbl = gui:WaitForChild("Notify")

local slime = workspace:WaitForChild("SlayAndLoot"):WaitForChild("Slime")

local function show(msg)
    notifyLbl.Text = msg
    task.delay(2, function() if notifyLbl.Text == msg then notifyLbl.Text = "" end end)
end

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local gen = slime:GetAttribute("Generation")
        attackRE:FireServer(gen)
    end
end)

attackRE.OnClientEvent:Connect(function(kind, a, b, c, d)
    if kind == "hit" then
        show("Hit for "..d)
    elseif kind == "kill" then
        coinsLbl.Text = "Coins: "..a
        weaponLbl.Text = "Rusty Sword Lv."..b.."  "..c.."/1 XP"
        if b == 2 and c == 0 then
            show("WEAPON LEVEL UP! Lv.1 -> Lv.2  (damage 10 -> 12)")
        else
            show("DUPLICATE +1 Weapon XP")
        end
    end
end)
