# Monster Factory Simulator — Remote Security Audit v0.1

Build: MVP-005

## Security baseline

All state-changing client requests are validated server-side.

### Rate-limited actions
- Collect
- Upgrade
- Hatch
- ToggleEquip
- EquipBest
- Fuse
- ZoneUnlock
- ZoneTravel
- Rebirth
- QuestClaim
- DailyClaim
- PlaytimeClaim
- AchievementClaim

The limits are centralized in `SecurityService.lua`.

## Validation rules

### String IDs
`SecurityService.IsSafeId` allows:
- letters
- numbers
- underscore
- hyphen

Unknown IDs are rejected by the canonical config lookup after format validation.

### Integer requests
Zone IDs are required to be whole numbers in the currently valid range 1–3.

### Economy
The client never supplies:
- reward amount,
- Cash amount,
- Gem amount,
- Rebirth Token amount,
- hatch result,
- production multiplier,
- upgrade cost,
- purchase grant.

Those values are always computed or looked up on the server.

### Hatch
The server checks:
- capsule exists,
- capsule ID format,
- rate limit,
- current zone matches capsule,
- highest unlocked zone allows it,
- storage has capacity,
- currency cost,
- weighted random result.

### Equipment
The server checks:
- monster instance UID belongs to the requesting player's inventory,
- equip slot limit,
- requested monster exists.

### Fusion
The server checks:
- monster definition exists,
- at least five valid unequipped non-Shiny duplicates exist.

### Zone unlock
The server checks:
- ordered next-zone progression,
- unlock cost,
- valid zone ID.

### Rebirth
The server computes the required Cash itself.

### Claims
Quest/Achievement/Reward completion is recalculated from authoritative profile metrics.

## Remaining security surface

Developer Product receipt flow is not initiated by a RemoteEvent and remains under `MarketplaceService.ProcessReceipt`.

Game Pass benefits are checked through MarketplaceService and cached server-side.

## Result

Static architecture audit: PASS for the MVP security model.

Runtime exploit testing in Roblox Studio is still required.
