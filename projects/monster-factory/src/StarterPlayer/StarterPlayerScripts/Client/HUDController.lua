local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local HUDView = require(script.Parent:WaitForChild("HUDView"))

local shared = ReplicatedStorage:WaitForChild("Shared")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local MonetizationConfig = require(shared:WaitForChild("MonetizationConfig"))
local CapsuleConfig = require(shared:WaitForChild("CapsuleConfig"))
local MonsterConfig = require(shared:WaitForChild("MonsterConfig"))

local HUDController = {}

local REMOTE_NAMES = {
    "StateUpdated", "MonsterStateUpdated", "ZoneStateUpdated",
    "QuestStateUpdated", "RewardStateUpdated", "AchievementStateUpdated",
    "OnboardingStateUpdated", "ContextOffer", "Toast",
    "RequestUpgrade", "RequestCollect", "RequestHatch",
    "RequestToggleEquip", "RequestEquipBest", "RequestFuse",
    "RequestZoneUnlock", "RequestZoneTravel", "RequestRebirth",
    "RequestQuestClaim", "RequestDailyClaim", "RequestPlaytimeClaim",
    "RequestAchievementClaim",
    "RequestFullState", "RequestMonsterState", "RequestZoneState",
    "RequestQuestState", "RequestRewardState", "RequestAchievementState",
    "RequestOnboardingState",
}

local function formatTime(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    if h > 0 then return string.format("%dh %02dm", h, m) end
    return string.format("%dm %02ds", m, s)
end

function HUDController.Start()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local camera = workspace.CurrentCamera
    local view = HUDView.Create(playerGui, camera)
    local C = HUDView.Colors

    local R = {}
    for _, name in ipairs(REMOTE_NAMES) do
        R[name] = remotes:WaitForChild(name)
    end

    local latestEconomy
    local latestMonsters
    local latestZones
    local currentContextPass
    local lastEconomy

    local function refreshPrimaryTexts()
        if latestEconomy then
            view.Buttons.Collect.Text = latestEconomy.Passes and latestEconomy.Passes.AutoCollect
                and "AUTO COLLECT ON"
                or ("COLLECT  $" .. tostring(math.floor(latestEconomy.PendingCash or 0)))
            view.Buttons.Upgrade.Text = string.format(
                "UPGRADE  Lv.%d  $%d",
                latestEconomy.GeneratorLevel or 1,
                latestEconomy.NextUpgradeCost or 0
            )
            view.Buttons.Rebirth.Text = "REBIRTH  $" .. tostring(latestEconomy.NextRebirthRequirement or 0)
        end

        if latestZones then
            for _, zone in ipairs(latestZones.Zones or {}) do
                if zone.Current then
                    local capsule = CapsuleConfig.Get(zone.CapsuleId)
                    if capsule then
                        if zone.Id == 1 and latestMonsters and (latestMonsters.HatchCount or 0) == 0 then
                            view.Buttons.Hatch.Text = "FREE FIRST HATCH"
                        else
                            view.Buttons.Hatch.Text = "HATCH  $" .. tostring(capsule.Cost)
                        end
                    end
                    break
                end
            end
        end
    end

    local function applyEconomy(state)
        if type(state) ~= "table" then return end
        latestEconomy = state

        view:SetStat("Cash", "$" .. tostring(math.floor(state.Cash or 0)))
        view:SetStat("Collector", "Collector $" .. tostring(math.floor(state.PendingCash or 0)))
        view:SetStat("Gems", "Gems " .. tostring(math.floor(state.Gems or 0)))
        view:SetStat("Production", "+" .. tostring(math.floor(state.ProductionPerSecond or 0)) .. "/s")
        view:SetStat("Friends", "Friends +" .. tostring(math.floor((state.FriendBonus or 0) * 100)) .. "%")
        view:SetStat("Rebirths", "R" .. tostring(state.Rebirths or 0))

        if lastEconomy then
            local oldCash = tonumber(lastEconomy.Cash) or 0
            local newCash = tonumber(state.Cash) or 0
            local oldPending = tonumber(lastEconomy.PendingCash) or 0
            local newPending = tonumber(state.PendingCash) or 0
            local oldLevel = tonumber(lastEconomy.GeneratorLevel) or 1
            local newLevel = tonumber(state.GeneratorLevel) or 1
            if newLevel > oldLevel then
                view:Feedback("GENERATOR LV." .. tostring(newLevel), C.gold)
            elseif newCash > oldCash and newPending < oldPending then
                view:Feedback("COLLECTED  +$" .. tostring(math.floor(newCash - oldCash)), C.green)
            end
        end
        lastEconomy = state
        refreshPrimaryTexts()
    end

    local function rebuildMonsters(state)
        if type(state) ~= "table" then return end
        latestMonsters = state
        view:Clear("Monsters")

        for _, item in ipairs(state.Inventory or {}) do
            local _, equip, fuse = view:MonsterCard(item)
            equip.Activated:Connect(function()
                R.RequestToggleEquip:FireServer(item.Uid)
            end)
            fuse.Activated:Connect(function()
                if not item.Shiny then R.RequestFuse:FireServer(item.MonsterId) end
            end)
        end
        refreshPrimaryTexts()
    end

    local function rebuildZones(state)
        if type(state) ~= "table" then return end
        latestZones = state
        view:Clear("Zones")

        for _, zone in ipairs(state.Zones or {}) do
            local text
            local accent
            if zone.Unlocked then
                if zone.Current then
                    text = "HERE  •  " .. zone.DisplayName
                    accent = C.green
                else
                    text = "TRAVEL  •  " .. zone.DisplayName
                    accent = C.cyan
                end
            else
                text = "LOCKED  •  " .. zone.DisplayName .. "  •  $" .. tostring(zone.UnlockCost)
                accent = C.gold
            end
            local b = view:ListButton("Zones", text, 72, accent, "World")
            b.Activated:Connect(function()
                if zone.Unlocked then
                    R.RequestZoneTravel:FireServer(zone.Id)
                else
                    R.RequestZoneUnlock:FireServer(zone.Id)
                end
            end)
        end
        refreshPrimaryTexts()
    end

    local function rebuildQuests(state)
        if type(state) ~= "table" then return end
        view:Clear("Quests")
        for _, quest in ipairs(state.Quests or {}) do
            local status = quest.Claimed and "DONE"
                or (quest.Complete and "CLAIM" or (tostring(quest.Progress) .. "/" .. tostring(quest.Target)))
            local b = view:ListButton("Quests", quest.DisplayName .. "\n" .. status, 74, quest.Complete and C.gold or C.line, "Quest")
            b.Active = quest.Complete and not quest.Claimed
            b.Activated:Connect(function()
                if b.Active then R.RequestQuestClaim:FireServer(quest.Id) end
            end)
        end
    end

    local function rebuildAchievements(state)
        if type(state) ~= "table" then return end
        view:Clear("Achievements")
        for _, item in ipairs(state.Achievements or {}) do
            local status = item.Claimed and "DONE"
                or (item.Complete and "CLAIM" or (tostring(item.Progress) .. "/" .. tostring(item.Target)))
            local b = view:ListButton(
                "Achievements",
                item.DisplayName .. "\n" .. item.Description .. "\n" .. status,
                94,
                item.Complete and C.purple or C.line,
                "Achievement"
            )
            b.Active = item.Complete and not item.Claimed
            b.Activated:Connect(function()
                if b.Active then R.RequestAchievementClaim:FireServer(item.Id) end
            end)
        end
    end

    local function rebuildRewards(state)
        if type(state) ~= "table" then return end
        view:Clear("Rewards")
        if state.Daily then
            local dailyText = state.Daily.CanClaim
                and "DAILY REWARD  •  CLAIM"
                or ("DAILY REWARD  •  " .. formatTime(state.Daily.NextAvailableSeconds))
            local daily = view:ListButton("Rewards", dailyText, 70, state.Daily.CanClaim and C.gold or C.line, "Reward")
            daily.Active = state.Daily.CanClaim == true
            daily.Activated:Connect(function()
                if daily.Active then R.RequestDailyClaim:FireServer() end
            end)
        end

        for _, item in ipairs(state.Playtime or {}) do
            local text
            if item.Claimed then
                text = "PLAYTIME " .. formatTime(item.Seconds) .. "  •  DONE"
            elseif item.Available then
                text = "PLAYTIME " .. formatTime(item.Seconds) .. "  •  CLAIM"
            else
                text = "PLAYTIME " .. formatTime(item.Seconds) .. "  •  " .. formatTime(item.Progress)
            end
            local b = view:ListButton("Rewards", text, 66, item.Available and C.gold or C.line, "Reward")
            b.Active = item.Available == true
            b.Activated:Connect(function()
                if b.Active then R.RequestPlaytimeClaim:FireServer(item.Id) end
            end)
        end
    end

    local function rebuildIndex()
        view:Clear("Index")
        local discovered = {}
        if latestMonsters then
            for _, item in ipairs(latestMonsters.Inventory or {}) do
                discovered[item.MonsterId] = true
            end
        end

        local entries = {}
        for monsterId, def in pairs(MonsterConfig.Definitions) do
            if not def.Exclusive then
                table.insert(entries, {
                    MonsterId = monsterId,
                    Zone = def.Zone,
                    DisplayName = discovered[monsterId] and def.DisplayName or "???",
                    Rarity = discovered[monsterId] and def.Rarity or "Unknown",
                })
            end
        end
        table.sort(entries, function(a, b)
            if a.Zone == b.Zone then return a.MonsterId < b.MonsterId end
            return a.Zone < b.Zone
        end)
        for _, entry in ipairs(entries) do
            local discoveredEntry = entry.DisplayName ~= "???"
            view:ListButton(
                "Index",
                "ZONE " .. tostring(entry.Zone) .. "  •  " .. entry.DisplayName .. "  •  " .. entry.Rarity,
                56,
                discoveredEntry and C.cyan or C.line,
                "IndexEntry"
            ).Active = false
        end
    end

    local function applyOnboarding(state)
        if type(state) ~= "table" or state.Finished then
            view:SetOnboarding(nil)
            return
        end
        view:SetOnboarding(
            "NEXT  •  " .. tostring(state.DisplayName)
            .. "  " .. tostring(state.Progress) .. "/" .. tostring(state.Target)
        )
    end

    local function promptPass(pass)
        if not pass or pass.Id == 0 then
            view:ShowToast("Purchase IDs are not configured yet.", C.red)
            return
        end
        MarketplaceService:PromptGamePassPurchase(player, pass.Id)
    end

    local function promptProduct(product)
        if not product or product.Id == 0 then
            view:ShowToast("Purchase IDs are not configured yet.", C.red)
            return
        end
        MarketplaceService:PromptProductPurchase(player, product.Id)
    end

    local function populateShop()
        view:Clear("Shop")
        local order = {
            { "pass", MonetizationConfig.Passes.StarterPack },
            { "pass", MonetizationConfig.Passes.AutoCollect },
            { "pass", MonetizationConfig.Passes.ExtraEquip },
            { "pass", MonetizationConfig.Passes.VIP },
            { "pass", MonetizationConfig.Passes.BiggerStorage },
            { "pass", MonetizationConfig.Passes.FastHatch },
            { "product", MonetizationConfig.Products.Overdrive15 },
            { "product", MonetizationConfig.Products.Overdrive60 },
            { "product", MonetizationConfig.Products.GemsSmall },
            { "product", MonetizationConfig.Products.GemsMedium },
            { "product", MonetizationConfig.Products.RebirthSmall },
        }

        for _, entry in ipairs(order) do
            local kind, item = entry[1], entry[2]
            local suffix = item.Id == 0 and "  •  DEV" or ""
            local b = view:ListButton("Shop", item.DisplayName .. suffix, 58, C.green, "Product")
            if item.Id ~= 0 then
                task.spawn(function()
                    local infoType = kind == "pass" and Enum.InfoType.GamePass or Enum.InfoType.Product
                    local ok, info = pcall(function()
                        return MarketplaceService:GetProductInfo(item.Id, infoType)
                    end)
                    if ok and info and info.PriceInRobux and b.Parent then
                        b.Text = item.DisplayName .. "  •  " .. tostring(info.PriceInRobux) .. " R$"
                    end
                end)
            end
            b.Activated:Connect(function()
                if kind == "pass" then promptPass(item) else promptProduct(item) end
            end)
        end
    end

    local function handleContextOffer(payload)
        if type(payload) ~= "table" or type(payload.Key) ~= "string" then return end
        local pass = MonetizationConfig.Passes[payload.Key]
        if not pass then return end
        currentContextPass = pass
        view:SetContextOffer(pass.DisplayName, true)
    end

    view.Buttons.Collect.Activated:Connect(function() R.RequestCollect:FireServer() end)
    view.Buttons.Upgrade.Activated:Connect(function() R.RequestUpgrade:FireServer() end)
    view.Buttons.Hatch.Activated:Connect(function()
        if not latestZones then return end
        for _, zone in ipairs(latestZones.Zones or {}) do
            if zone.Current then
                R.RequestHatch:FireServer(zone.CapsuleId)
                return
            end
        end
    end)
    view.Buttons.EquipBest.Activated:Connect(function() R.RequestEquipBest:FireServer() end)
    view.Buttons.Rebirth.Activated:Connect(function() R.RequestRebirth:FireServer() end)

    for _, name in ipairs({ "Monsters", "Zones", "Quests", "Achievements", "Shop", "Rewards" }) do
        view.Buttons[name].Activated:Connect(function() view:OpenWindow(name) end)
    end
    view.Buttons.Index.Activated:Connect(function()
        rebuildIndex()
        view:OpenWindow("Index")
    end)
    view.Buttons.ViewOffer.Activated:Connect(function()
        if currentContextPass then promptPass(currentContextPass) end
        currentContextPass = nil
        view:SetContextOffer(nil, false)
    end)
    view.Buttons.NoThanks.Activated:Connect(function()
        currentContextPass = nil
        view:SetContextOffer(nil, false)
    end)

    R.StateUpdated.OnClientEvent:Connect(applyEconomy)
    R.MonsterStateUpdated.OnClientEvent:Connect(function(state)
        rebuildMonsters(state)
        rebuildIndex()
    end)
    R.ZoneStateUpdated.OnClientEvent:Connect(rebuildZones)
    R.QuestStateUpdated.OnClientEvent:Connect(rebuildQuests)
    R.RewardStateUpdated.OnClientEvent:Connect(rebuildRewards)
    R.AchievementStateUpdated.OnClientEvent:Connect(rebuildAchievements)
    R.OnboardingStateUpdated.OnClientEvent:Connect(applyOnboarding)
    R.ContextOffer.OnClientEvent:Connect(handleContextOffer)
    R.Toast.OnClientEvent:Connect(function(message)
        if type(message) ~= "string" then return end
        local accent = C.cyan
        if string.find(message, "Not enough", 1, true) then accent = C.red end
        if string.find(message, "Shiny", 1, true) then accent = C.gold end
        view:ShowToast(message, accent)
    end)

    populateShop()

    task.spawn(function()
        local requests = {
            { R.RequestFullState, applyEconomy },
            { R.RequestMonsterState, rebuildMonsters },
            { R.RequestZoneState, rebuildZones },
            { R.RequestQuestState, rebuildQuests },
            { R.RequestRewardState, rebuildRewards },
            { R.RequestAchievementState, rebuildAchievements },
            { R.RequestOnboardingState, applyOnboarding },
        }
        for _, pair in ipairs(requests) do
            local ok, state = pcall(function() return pair[1]:InvokeServer() end)
            if ok then pair[2](state) end
        end
        rebuildIndex()
        refreshPrimaryTexts()
    end)

    print("[MonsterFactory] HUD Controller 007 active.")
    return view
end

return HUDController
