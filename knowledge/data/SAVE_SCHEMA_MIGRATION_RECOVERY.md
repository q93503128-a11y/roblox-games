# Save Schema, Migration, Recovery, and Data Integrity

> verified: 2026-09-03

Related:
- `DATA_ECONOMY_AND_LIVEOPS.md`
- `CLOUD_SERVICES_DECISION_MATRIX.md`
- ProfileStore candidate: https://github.com/MadStudioRoblox/ProfileStore

## 1. Save data is an API

Once players have live data, schema changes are backward-compatibility work.
Never treat a save table as a temporary Lua table you can reshape freely.

## 2. Explicit schema version

Example:
```luau
{
    schemaVersion = 5,
    currencies = { gold = 1200 },
    inventory = {...},
    progression = {...},
    settings = {...},
    claims = {...},
}
```

Every breaking structural change increments version.

## 3. Ordered migrations

```text
v1 → v2
v2 → v3
v3 → v4
```

Avoid one giant `if old then convert somehow` function.
Each migration:
- accepts exact old schema
- transforms deterministically
- validates result
- is unit-testable

## 4. Missing field ≠ corrupt profile

New optional/default field can be reconciled without destroying player history.
Never replace entire profile with fresh template because one field is missing.

## 5. Stable IDs

Inventory/save stores internal IDs, not display names.
Good:
`weapon_iron_sword`

Bad:
`Iron Sword +3 🔥`

Display/localization can change without migration.

## 6. Numeric integrity

Validate:
- finite numbers
- min/max/domain
- integer where required
- overflow/absurd exploit-era values

Do not blindly `math.max(0, value)` every corrupt field and hide systemic problems; log/repair according to policy.

## 7. Unknown content IDs

Old/removed item handling:
- map to replacement
- refund value
- retain legacy placeholder
- remove with compensation

Policy must be explicit before deleting catalog items.

## 8. Unique items

Unique instance needs stable instance ID if:
- upgrades/enchantments
- trading
- durability
- custom rolls

Never identify two unique swords solely by catalog item ID.

## 9. Transaction idempotency

Track identifiers where duplicated execution can create value:
- Developer Product receipts
- mission claims
- season rewards
- trade transactions
- one-time codes

`request clicked once` is not proof of one execution.

## 10. Session locking

Player-oriented session locking prevents multiple servers editing same canonical profile simultaneously. ProfileStore is one current candidate; understand its lifecycle rather than copy snippets blindly.

Behavior to define:
- session requested while old server alive
- force/steal policy if supported
- player leaves during load
- shutdown

## 11. Load failure

Critical rule:
**load failure must not become fresh-profile overwrite.**

Flow:
```text
load
→ retry/backoff/critical-state handling
→ if unavailable, block or degraded mode
→ never save blank template over unknown existing data
```

## 12. Save failure

If autosave fails:
- keep session data in memory
- retry appropriately
- expose operational warning
- shutdown path continues attempts within platform constraints

Do not tell player save succeeded if system knows otherwise.

## 13. Recovery metadata

Useful optional metadata:
- schema version
- last successful save timestamp
- server/session marker
- migration history/version

Avoid storing excessive logs inside profile.

## 14. Backup/version history

Roblox standard DataStore supports platform version/recovery capabilities that should be understood for incident response. Profile wrappers may provide different operational interfaces. Document how a live incident would recover data before launch.

## 15. Environment isolation

Separate:
- Studio/local
- TEST
- STAGING
- PRODUCTION

Never casually enable Studio to write production datastore.

## 16. Migration tests

Fixture examples:
- v1 minimal
- v1 late-game
- v2 with missing optional field
- corrupt/unknown ID
- max-size inventory
- duplicate unique ID

For each current migration chain, test old fixture → current schema.

## 17. Live rollout

For dangerous migration:
1. backup/recovery plan
2. deploy code that reads old + new
3. small cohort/test environment
4. monitor failures
5. only then remove old compatibility later

## 18. Data deletion / privacy

User data handling and deletion requests must follow current Roblox platform requirements and law. Do not build custom personal-data retention beyond game need.

## 19. Acceptance

- [ ] schemaVersion
- [ ] ordered migrations
- [ ] old save fixtures
- [ ] load failure safe
- [ ] save failure observable
- [ ] stable content IDs
- [ ] unique instance IDs where needed
- [ ] receipt/claim idempotency
- [ ] session conflict behavior
- [ ] TEST/PROD isolation
- [ ] recovery procedure documented
