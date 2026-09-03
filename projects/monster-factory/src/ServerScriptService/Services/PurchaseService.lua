local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConfig = require(ReplicatedStorage.Shared.MonetizationConfig)

local PurchaseService = {}
local PlayerDataService
local PassService
local MonsterService

local function receiptWasProcessed(data, purchaseId)
    return data.Purchases
        and data.Purchases.ProcessedReceipts
        and data.Purchases.ProcessedReceipts[tostring(purchaseId)] == true
end

local function markReceiptProcessed(data, purchaseId)
    data.Purchases = data.Purchases or {}
    data.Purchases.ProcessedReceipts = data.Purchases.ProcessedReceipts or {}
    data.Purchases.ProcessedReceipts[tostring(purchaseId)] = true
end

local function grantDeveloperProduct(player, product, purchaseId)
    local data = PlayerDataService.Get(player)
    if not data then
        return false
    end

    if receiptWasProcessed(data, purchaseId) then
        -- A previous attempt already applied the grant to this profile.
        -- Save again before acknowledgement so a transient save failure
        -- cannot turn into a paid item loss.
        return PlayerDataService.Save(player)
    end

    local grant = product.Grant or {}

    if grant.Gems then
        data.Currency.Gems += grant.Gems
    end
    if grant.RebirthTokens then
        data.Currency.RebirthTokens += grant.RebirthTokens
    end
    if grant.UpgradeTokens then
        data.Factory.UpgradeTokens += grant.UpgradeTokens
    end
    if grant.OverdriveSeconds then
        local now = os.time()
        local currentUntil = math.max(now, data.Factory.OverdriveUntil or 0)
        data.Factory.OverdriveUntil = currentUntil + grant.OverdriveSeconds
    end

    data.Stats.PurchasesGranted += 1
    markReceiptProcessed(data, purchaseId)

    return PlayerDataService.Save(player)
end

local function grantStarterPackIfNeeded(player)
    local data = PlayerDataService.Get(player)
    if not data or not PassService.Get(player, "StarterPack") then
        return
    end

    if not data.Entitlements.StarterPackGranted then
        data.Currency.Gems += 250
        data.Factory.UpgradeTokens += 3
        data.Entitlements.StarterPackGranted = true
    end

    if not data.Entitlements.StarterPackMonsterGranted then
        local monster = MonsterService.GrantMonster(player, "FactoryBot", {
            AutoEquip = true,
            IgnoreStorage = true,
        })
        if monster then
            data.Entitlements.StarterPackMonsterGranted = true
        end
    end
end

function PurchaseService.Init(playerDataService, passService, monsterService)
    PlayerDataService = playerDataService
    PassService = passService
    MonsterService = monsterService

    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        local data = PlayerDataService.Get(player)
        if not data then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        local product = MonetizationConfig.FindProductById(receiptInfo.ProductId)
        if not product then
            warn("Unknown developer product:", receiptInfo.ProductId)
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        local persisted = grantDeveloperProduct(player, product, receiptInfo.PurchaseId)
        if not persisted then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        return Enum.ProductPurchaseDecision.PurchaseGranted
    end

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, _, wasPurchased)
        if not wasPurchased then
            return
        end

        PassService.Refresh(player)
        grantStarterPackIfNeeded(player)
        PlayerDataService.Save(player)
    end)
end

function PurchaseService.OnPlayerReady(player)
    grantStarterPackIfNeeded(player)
end

return PurchaseService
