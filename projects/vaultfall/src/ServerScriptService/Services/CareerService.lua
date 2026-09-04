local Workspace = game:GetService("Workspace")

local CareerService = {}
local ctx
local bound = false

local TROPHIES = {
    { Id = "FirstBreach", Name = "FIRST BREACH", Description = "Complete one full breach", field = "Runs", threshold = 1 },
    { Id = "DeepOperator", Name = "DEEP OPERATOR", Description = "Reach sector 8", field = "BestDepth", threshold = 8 },
    { Id = "Extractor", Name = "CLEAN EXIT", Description = "Extract successfully 3 times", field = "Extractions", threshold = 3 },
    { Id = "HighRoller", Name = "HIGH ROLLER", Description = "Secure 500 Essence in one extraction", field = "HighestExtraction", threshold = 500 },
    { Id = "WardenBreaker", Name = "WARDEN BREAKER", Description = "Kill the Vault Warden", field = "BossKills", threshold = 1 },
    { Id = "Veteran", Name = "BREACH VETERAN", Description = "Complete 5 full breaches", field = "Runs", threshold = 5 },
    { Id = "Ascendant", Name = "ASCENDANT", Description = "Reach Power Rank 3", field = "PowerRank", threshold = 3 },
}

local function makeTrophyPayload(player)
    local profile = ctx.Profile.GetPublic(player)
    if not profile then
        return nil
    end

    local trophyStates = {}
    local unlocked = 0
    for index, trophy in ipairs(TROPHIES) do
        local value = profile[trophy.field] or 0
        local isUnlocked = value >= trophy.threshold
        if isUnlocked then
            unlocked += 1
        end
        trophyStates[index] = {
            Id = trophy.Id,
            Name = trophy.Name,
            Description = trophy.Description,
            Unlocked = isUnlocked,
            Progress = value,
            Target = trophy.threshold,
        }
    end

    return {
        Profile = profile,
        Trophies = trophyStates,
        Unlocked = unlocked,
        Total = #TROPHIES,
    }
end

function CareerService.PushState(player)
    if not player or not player.Parent then
        return
    end
    local payload = makeTrophyPayload(player)
    if payload then
        ctx.Remotes.State:FireClient(player, "OperatorRecord", payload)
    end
end

local function bindRunHooks()
    if bound then
        return
    end
    bound = true

    local originalExtract = ctx.Run.ExtractPlayer
    ctx.Run.ExtractPlayer = function(player)
        local before = ctx.Profile.Get(player)
        local oldExtractions = before and before.Extractions or 0
        local result = originalExtract(player)
        if result then
            local profile = ctx.Profile.Get(player)
            if profile and profile.Extractions == oldExtractions then
                -- RunService performs the secure payout; record career statistics after success.
                -- The exact payout is sent to the client there, while the career service tracks
                -- the persistent extraction count. HighestExtraction is updated through
                -- RecordExtraction when the payout can be inferred by the profile delta below.
                local public = ctx.Profile.GetPublic(player)
                local currentEssence = public and public.Essence or 0
                local previousEssence = before and before.Essence or currentEssence
                local secured = math.max(0, currentEssence - previousEssence)
                ctx.Profile.RecordExtraction(player, secured, ctx.Run.GetCurrentRoom())
                ctx.Profile.Save(player)
                CareerService.PushState(player)
            end
        end
        return result
    end

    local originalEnemyDied = ctx.Run.OnEnemyDied
    ctx.Run.OnEnemyDied = function(enemy, attacker)
        if enemy and enemy.Type == "VaultWarden" and attacker and attacker.Parent then
            ctx.Profile.RecordBossKill(attacker)
            CareerService.PushState(attacker)
        end
        return originalEnemyDied(enemy, attacker)
    end
end

function CareerService.BindWorld()
    local world = Workspace:FindFirstChild("VaultfallWorld")
    local safehouse = world and world:FindFirstChild("Safehouse")
    if not safehouse then
        warn("[Vaultfall] CareerService could not find safehouse trophy wall")
        return
    end

    local wall = safehouse:FindFirstChild("SafehouseWall")
    local marker
    for _, descendant in ipairs(safehouse:GetDescendants()) do
        if descendant.Name == "WorldLabel" and descendant:IsA("BillboardGui") then
            local label = descendant:FindFirstChildOfClass("TextLabel")
            if label and label.Text == "OPERATOR RECORD" then
                marker = descendant.Parent
                break
            end
        end
    end
    wall = marker or wall
    if not wall or not wall:IsA("BasePart") then
        warn("[Vaultfall] CareerService trophy wall marker unavailable")
        return
    end

    local prompt = wall:FindFirstChild("OperatorRecordPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.Name = "OperatorRecordPrompt"
        prompt.ActionText = "VIEW RECORD"
        prompt.ObjectText = "Operator Archive"
        prompt.HoldDuration = 0.25
        prompt.MaxActivationDistance = 12
        prompt.RequiresLineOfSight = false
        prompt.Parent = wall
        prompt.Triggered:Connect(function(player)
            CareerService.PushState(player)
        end)
    end
end

function CareerService.Init(context)
    ctx = context
    bindRunHooks()
end

return CareerService
