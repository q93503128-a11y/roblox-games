# Loot, Drop Tables, Crafting, and Reward Generation

> verified: 2026-09-03

## 1. Reward generation is server authoritative

Client may show anticipation/animation, but server chooses:
- whether drop occurs
- item/reward ID
- quantity
- rarity/rolls
- ownership

Never accept client `rolledItemId` or `rewardAmount`.

## 2. Data-driven drop tables

```luau
DropTable = {
 id = "enemy_slime_01",
 rolls = 1,
 entries = {
   {id="mat_slime_gel", weight=70, min=1, max=3},
   {id="weapon_slime_blade", weight=2, min=1, max=1},
 }
}
```

Separate definition from generator algorithm.

## 3. Weight semantics

Document whether weights mean:
- relative weighted choice
- independent percentage rolls
- guaranteed category then weighted item

Do not mix semantics in same table without explicit type.

Validators:
- weight finite/nonnegative
- referenced item exists
- quantity sane
- required table not empty

## 4. Deterministic RNG when useful

Use a controlled `Random` instance for reproducible tests/content generation.

For reward fairness/security, server owns seed/state. Do not expose a predictable client-controlled seed for valuable randomness.

Deterministic test seed helps reproduce bugs.

## 5. Pity / bad luck protection

For rare progression-critical drops, consider:
- guaranteed after N failures
- increasing chance
- token/currency alternative

Pity state must be server persisted if it matters across sessions.

Paid randomized items have separate Roblox policy requirements; re-check current policy before implementation.

## 6. Personal vs shared loot

Define:
- personal drop
- first pickup
- need/greed
- contribution-based
- party-shared

Shared world pickup needs ownership window/claim rules to avoid griefing.

## 7. World drop representation

World model is presentation of server reward state.

Store server metadata:
- dropId
- item instance/reward
- owner/party eligibility
- expiration
- pickup position

Pickup interaction revalidates distance/eligibility and atomic claim.

## 8. Drop lifetime

Bound world loot lifetime.
Cleanup:
- claimed
- expired
- round end
- server shutdown save policy if necessary

Thousands of abandoned drop parts are not acceptable.

## 9. Crafting recipe

```text
recipeId
inputs
currency cost
requirements
output policy
craft duration optional
```

Server flow:
1. validate recipe/unlock
2. validate and lock ingredients
3. consume atomically
4. generate output
5. add output / overflow policy
6. analytics/result

## 10. Crafting UI preview

UI can show expected inputs/results from replicated catalog, but final server result uses trusted server catalog.

For randomized craft:
- disclose relevant design info/policy as required
- server rolls result

## 11. Upgrade/crafting failure

If system includes failure chance:
- consequence explicit
- no ambiguous destructive click
- transaction idempotent
- retry cannot duplicate output

## 12. Salvage

Salvage is a useful economy sink/source bridge.
Define output based on trusted item definition/instance, not client-submitted item value.

## 13. Generated modifiers

Unique item roll:
```text
instanceId
baseItemId
rollSeed or stored modifier values
qualityTier
```

Choose storing seed vs explicit rolls based on future algorithm compatibility. If generation algorithm may change, explicit rolled stats are safer for preserving old items.

## 14. Reward inbox/overflow

For important rewards when inventory is full:
- claim inbox/mailbox
- overflow queue
- guaranteed conversion

Never silently lose purchase/event/boss reward due to capacity.

## 15. Economy integration

Every source reason tagged:
- enemy_drop
- boss_drop
- chest
- quest
- craft
- salvage

Monitor item/currency supply and inflation.

## 16. Testing

Monte Carlo simulation:
- expected rarity rates
- pity distribution
- average rewards/session
- extreme outcomes

Unit tests with fixed RNG seeds.

## 17. Security tests

- claim same world drop twice
- claim another player's drop
- pickup from impossible distance
- craft missing ingredients
- craft same unique item twice concurrently
- client sends fake recipe/output
- spam claim/craft

## 18. Acceptance

- [ ] server owns RNG/reward
- [ ] drop table semantics explicit
- [ ] validators/simulation
- [ ] atomic claim/craft
- [ ] shared loot ownership policy
- [ ] lifetime cleanup
- [ ] full inventory overflow policy
- [ ] pity persisted where needed
- [ ] reward sources analytics-tagged
