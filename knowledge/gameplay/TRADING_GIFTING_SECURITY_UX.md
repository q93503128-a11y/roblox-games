# Trading and Gifting — Security, Transactions, and UX

> verified: 2026-09-03

Trading is one of the highest-risk economy features because it combines unique ownership, concurrency, social pressure, persistence, and exploit incentives. Do not add it casually.

Official security baseline:
https://create.roblox.com/docs/scripting/security/client-server-boundary

## 1. Prerequisites

Before trading:
- stable inventory instance IDs
- session locking / one active profile owner
- item locks
- atomic/idempotent server transaction design
- save/recovery plan
- clear UI confirmation

If these don't exist, trading is premature.

## 2. Trade state machine

```text
REQUESTED
→ OPEN
→ OFFERING
→ BOTH_LOCKED
→ FINAL_REVALIDATE
→ COMMITTING
→ COMPLETED / CANCELLED / FAILED
```

Any offer mutation resets both ready/accept states.

## 3. Server owns offer

Client sends:
`AddOffer(instanceId)`

Server validates:
- player owns instance
- item tradeable
- not equipped/locked/listed
- unique ID valid
- trade still open

Server publishes sanitized offer state to both clients.

## 4. Final confirmation

Use at least a clear final confirmation stage where both users see the exact final offer after latest mutation.

Prevent bait-and-switch:
- changing offer clears acceptance
- disabled controls during commit
- visible item count/stats

## 5. Commit validation

Immediately before transfer:
- both players still present
- profiles/session valid
- all items still owned
- no duplicate instance IDs
- capacities/overflow policy
- trade restrictions

Then perform one server transaction in memory, mark transaction ID, save/recovery according to architecture.

## 6. Atomicity reality

Roblox DataStore does not magically provide a general multi-profile ACID transaction across arbitrary keys.

Therefore trade architecture should minimize cross-key inconsistency:
- same live server/session for both profiles where possible
- lock items during transaction
- durable transaction journal/id
- recovery path if save partially fails

Do not promise impossible atomicity without a real strategy.

## 7. Transaction ID

Every committed trade gets stable unique ID.
Use for:
- idempotency
- recovery
- audit/support

Retrying commit must not duplicate items.

## 8. Cancel conditions

Cancel safely if:
- player leaves before commit
- item invalid
- timeout
- trade partner dies if game design requires
- server shutting down before commit

Unlock all offered items exactly once.

## 9. Gifting

Gifting is not just a one-sided trade.
Define:
- item/currency giftability
- recipient capacity
- account/progression restrictions
- spam limits
- confirmation

Premium/purchased product gifting may involve separate current Roblox commerce rules; re-check official documentation before implementation.

## 10. Social scam resistance

UI should show:
- exact item image/name
- quantity
- modifiers/rarity
- partner identity clearly
- final changed state indication

Do not use tiny text/colors alone for valuable differences.

## 11. Cooldowns and limits

Potential:
- request spam cooldown
- trade frequency
- new account/progression gate if product design/security needs
- high-value monitoring

Avoid arbitrary friction unless it solves a measured abuse problem.

## 12. Tradeable flags

Item definition/instance can define:
- tradeable
- bound
- account-bound after equip/use
- temporary lock

Server source only.

## 13. Economy implications

Trading creates a secondary economy.
Monitor:
- item supply
- item velocity
- hoarding
- concentration
- suspicious repeated one-way transfers

Do not auto-ban from one heuristic; server can neutralize impossible transactions and collect evidence.

## 14. Cross-server trading

Far more complex. Requires temporary listings/coordination, expiry, claim semantics and durable ownership transfer.
MemoryStore can coordinate ephemeral listing state but permanent ownership stays DataStore/profile authoritative.

Start same-server unless cross-server market is core fantasy.

## 15. Exploit tests

- same item offered twice
- item sold/crafted while offered
- client changes offer after accept
- duplicate commit request
- one player leaves at final confirm
- full recipient inventory
- save failure after in-memory transfer
- fake instance ID
- negative/huge quantity
- simultaneous two trades with same item

## 16. Support/recovery

For valuable live economy, keep sufficient transaction metadata to diagnose disputes without storing unnecessary personal content.

## 17. Acceptance

- [ ] item instance IDs
- [ ] server offer authority
- [ ] offer mutation resets accept
- [ ] final revalidation
- [ ] item locks
- [ ] transaction ID/idempotency
- [ ] partial-save recovery strategy
- [ ] scam-resistant UI
- [ ] abuse/rate limits
- [ ] trade analytics/audit
