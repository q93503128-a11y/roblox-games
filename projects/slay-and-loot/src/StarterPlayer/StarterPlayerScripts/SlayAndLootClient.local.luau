-- Client gameplay source for Build 1 micro-slice (structural repair)
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

local function bindTool(tool)
    if not tool or tool.Name ~= "Rusty Sword" then return end
    tool.Activated:Connect(function()
        local gen = slime:GetAttribute("Generation")
        attackRE:FireServer(gen)
    end)
end

local function watchCharacter(char)
    for _,c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then bindTool(c) end
    end
    char.ChildAdded:Connect(function(c)
        if c:IsA("Tool") then bindTool(c) end
    end)
end

if player.Character then watchCharacter(player.Character) end
player.CharacterAdded:Connect(watchCharacter)

attackRE.OnClientEvent:Connect(function(kind, a, b, c, d)
    if kind == "hit" then
        show("Hit for "..b)
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
