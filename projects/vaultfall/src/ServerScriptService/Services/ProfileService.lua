local DataStoreService = game:GetService("DataStoreService")

local ProfileService = {}
local ctx
local store
local profiles = {}

local DEFAULT = {
    Essence = 0,
    Runs = 0,
    BestDepth = 0,
    PowerRank = 0,
    AttackUpgrade = 0,
    HealthUpgrade = 0,
    Extractions = 0,
    FailedRuns = 0,
    TotalSecured = 0,
    HighestExtraction = 0,
    BossKills = 0,
}

local function cloneDefault()
    local result = {}
    for key, value in pairs(DEFAULT) do
        result[key] = value
    end
    return result
end

local function sanitize(data)
    local result = cloneDefault()
    if type(data) ~= "table" then
        return result
    end

    for key, defaultValue in pairs(DEFAULT) do
        if type(data[key]) == type(defaultValue) then
            if type(defaultValue) == "number" then
                result[key] = math.max(0, math.floor(data[key] + 0.5))
            else
                result[key] = data[key]
            end
        end
    end
    return result
end

local function publicProfile(profile)
    return {
        Essence = profile.Essence,
        Runs = profile.Runs,
        BestDepth = profile.BestDepth,
        PowerRank = profile.PowerRank,
        AttackUpgrade = profile.AttackUpgrade,
        HealthUpgrade = profile.HealthUpgrade,
        Extractions = profile.Extractions,
        FailedRuns = profile.FailedRuns,
        TotalSecured = profile.TotalSecured,
        HighestExtraction = profile.HighestExtraction,
        BossKills = profile.BossKills,
    }
end

function ProfileService.Init(context)
    ctx = context

    local ok, result = pcall(function()
        return DataStoreService:GetDataStore(ctx.Config.SaveKey)
    end)

    if ok then
        store = result
    else
        store = nil
        warn("[Vaultfall] DataStore unavailable; using session-only profile data:", result)
    end
end

function ProfileService.Get(player)
    return profiles[player]
end

function ProfileService.GetPublic(player)
    local profile = profiles[player]
    if not profile then
        return nil
    end
    return publicProfile(profile)
end

function ProfileService.Push(player)
    local profile = profiles[player]
    if profile and player.Parent then
        ctx.Remotes.State:FireClient(player, "Profile", publicProfile(profile))
    end
end

function ProfileService.ApplyCharacter(player, character)
    local profile = profiles[player]
    if not profile then
        return
    end

    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then
        return
    end

    local bonus = 1 + (profile.HealthUpgrade * ctx.Config.Meta.HealthPerLevel)
    local oldMaxHealth = math.max(humanoid.MaxHealth, 1)
    local healthRatio = math.clamp(humanoid.Health / oldMaxHealth, 0, 1)
    local newMaxHealth = math.floor(ctx.Config.BasePlayerHealth * bonus + 0.5)
    humanoid.MaxHealth = newMaxHealth
    humanoid.Health = math.max(1, math.floor(newMaxHealth * healthRatio + 0.5))
    humanoid.WalkSpeed = ctx.Config.BaseWalkSpeed

    if not humanoid:GetAttribute("VaultfallDeathHookBound") then
        humanoid:SetAttribute("VaultfallDeathHookBound", true)
        humanoid.Died:Connect(function()
            if ctx.Run and ctx.Run.OnPlayerDied then
                ctx.Run.OnPlayerDied(player)
            end
        end)
    end
end

function ProfileService.Load(player)
    if profiles[player] then
        return profiles[player]
    end

    local data
    if store then
        local ok, err = pcall(function()
            data = store:GetAsync("u_" .. player.UserId)
        end)

        if not ok then
            warn("[Vaultfall] DataStore load failed for", player.UserId, err)
        end
    end

    local profile = sanitize(data)
    profiles[player] = profile

    player.CharacterAdded:Connect(function(character)
        task.defer(function()
            ProfileService.ApplyCharacter(player, character)
        end)
    end)

    if player.Character then
        task.defer(ProfileService.ApplyCharacter, player, player.Character)
    end

    ProfileService.Push(player)
    return profile
end

function ProfileService.Save(player)
    local profile = profiles[player]
    if not profile or not store then
        return true
    end

    local snapshot = publicProfile(profile)
    local ok, err = pcall(function()
        store:SetAsync("u_" .. player.UserId, snapshot)
    end)

    if not ok then
        warn("[Vaultfall] DataStore save failed for", player.UserId, err)
    end
    return ok
end

function ProfileService.Unload(player)
    ProfileService.Save(player)
    profiles[player] = nil
end

function ProfileService.AddEssence(player, amount)
    local profile = profiles[player]
    if not profile then
        return
    end
    profile.Essence = math.max(0, profile.Essence + math.floor(amount + 0.5))
    ProfileService.Push(player)
end

function ProfileService.SetBestDepth(player, depth)
    local profile = profiles[player]
    if not profile then
        return
    end
    profile.BestDepth = math.max(profile.BestDepth, math.floor(depth))
    ProfileService.Push(player)
end

function ProfileService.RecordExtraction(player, secured, depth)
    local profile = profiles[player]
    if not profile then
        return
    end
    local securedAmount = math.max(0, math.floor((secured or 0) + 0.5))
    profile.Extractions += 1
    profile.TotalSecured += securedAmount
    profile.HighestExtraction = math.max(profile.HighestExtraction, securedAmount)
    profile.BestDepth = math.max(profile.BestDepth, math.floor(depth or 0))
    ProfileService.Push(player)
end

function ProfileService.RecordFailure(player)
    local profile = profiles[player]
    if not profile then
        return
    end
    profile.FailedRuns += 1
    ProfileService.Push(player)
end

function ProfileService.RecordBossKill(player)
    local profile = profiles[player]
    if not profile then
        return
    end
    profile.BossKills += 1
    ProfileService.Push(player)
end

function ProfileService.RecordCompletion(player)
    local profile = profiles[player]
    if not profile then
        return
    end

    profile.Runs += 1
    if profile.Runs % ctx.Config.Meta.CompletionRankEvery == 0 then
        profile.PowerRank += 1
    end
    profile.Essence += ctx.Config.Meta.CompletionEssence + (profile.PowerRank * 10)
    ProfileService.Push(player)
end

function ProfileService.GetUpgradeCost(player, upgradeName)
    local profile = profiles[player]
    if not profile then
        return math.huge
    end

    local field
    if upgradeName == "Attack" then
        field = "AttackUpgrade"
    elseif upgradeName == "Health" then
        field = "HealthUpgrade"
    else
        return math.huge
    end

    local level = profile[field]
    return math.floor(ctx.Config.Meta.UpgradeBaseCost * (ctx.Config.Meta.UpgradeCostGrowth ^ level) + 0.5)
end

function ProfileService.BuyUpgrade(player, upgradeName)
    local profile = profiles[player]
    if not profile then
        return false, "Profile unavailable"
    end

    local field
    if upgradeName == "Attack" then
        field = "AttackUpgrade"
    elseif upgradeName == "Health" then
        field = "HealthUpgrade"
    else
        return false, "Unknown upgrade"
    end

    local cost = ProfileService.GetUpgradeCost(player, upgradeName)
    if profile.Essence < cost then
        return false, string.format("Need %d Essence", cost)
    end

    profile.Essence -= cost
    profile[field] += 1
    ProfileService.Push(player)

    if upgradeName == "Health" and player.Character then
        ProfileService.ApplyCharacter(player, player.Character)
    end

    return true, string.format("%s upgraded to Lv.%d", upgradeName, profile[field])
end

function ProfileService.GetAttackMultiplier(player)
    local profile = profiles[player]
    if not profile then
        return 1
    end
    return 1 + (profile.AttackUpgrade * ctx.Config.Meta.AttackPerLevel)
end

return ProfileService
