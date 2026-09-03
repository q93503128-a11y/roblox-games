# Admin Commands, Moderation, Live Operations, and Developer Tools

> verified: 2026-09-03

Official:
- TextChatService: https://create.roblox.com/docs/reference/engine/classes/TextChatService
- Custom text chat commands: https://create.roblox.com/docs/chat/examples/custom-text-chat-commands
- Security boundary: https://create.roblox.com/docs/scripting/security/client-server-boundary

## 1. Admin tooling is privileged server code

Never trust a LocalScript/admin UI alone to authorize commands.
Every privileged action verifies server-side identity/role/permission.

## 2. Permission model

Prefer named capability roles over scattered UserId checks.

Example:
```text
owner: all operations
developer: debug/test operations
moderator: kick/mute/game moderation subset
support: inspect/recovery subset
```

Map users/groups to roles in one server policy layer.

Do not replicate secret permission logic/keys as security mechanism; client code is inspectable.

## 3. Commands as structured operations

Command definition:
```text
id
aliases
permission
arguments/schema
server handler
audit category
```

Central router validates argument types/ranges and target existence.

## 4. TextChatCommand

Roblox `TextChatCommand` provides custom slash command integration with TextChatService. Useful for developer/admin commands if permissions are checked in server handler.

Do not rely on command alias obscurity as security.

Built-in Roblox chat commands already cover common local actions such as help, mute/unmute, whisper/team where configured.

## 5. Admin UI

For complex live ops, a dedicated developer UI may be better than chat commands.
Still:
- client sends requested operation
- server permission + validation
- server executes

## 6. Dangerous command tiers

### Low risk
- show debug state
- teleport self in test
- toggle dev visualization

### Medium
- restart round
- spawn test enemy
- grant test-only temporary state

### High
- mutate permanent inventory/currency
- ban/kick
- wipe/reset profile
- production event/config change

High-risk commands need stronger permissions, confirmation, environment guard, audit.

## 7. Environment guard

Test commands must not accidentally work in production.

Example policy:
```text
allowCheats = environment ~= "PRODUCTION"
```

Production recovery commands are separate, explicitly named, logged and permissioned.

## 8. Never create generic arbitrary code execution

Avoid production admin command like:
`/eval <luau>`

Arbitrary code execution dramatically expands compromise impact. Prefer finite audited commands.

## 9. Audit trail

For impactful operations record minimally:
- command id
- actor user id
- target user id if any
- timestamp
- server/job
- safe structured args/result

Do not log secrets or arbitrary personal chat content.

## 10. Player moderation

Use Roblox platform moderation/chat/safety capabilities where applicable. Game-specific moderation can supplement for game behavior such as:
- griefing
- exploit evidence
- inappropriate custom creations where relevant

Do not implement a custom system that bypasses platform filtering/safety.

## 11. Kick/ban design

Kick is immediate session removal, not durable ban by itself.

If game maintains bans:
- server-side persistent record
- reason/category
- start/expiry if temporary
- appeal/support process appropriate to product
- join check failure-safe policy

Avoid public shaming messages with sensitive details.

## 12. Anti-cheat actions

Roblox security guidance favors server validation and preventing harm first.
When detection fires:
- reject invalid action
- neutralize impossible state
- rate limit
- gather evidence/score over time

Do not build fragile instant permanent bans around one noisy heuristic.

## 13. Recovery tools

High-value live game should have scoped recovery actions:
- inspect profile schema/status
- regrant transaction by known transaction ID
- repair known migration issue

Never use `setGold(999999)` as substitute for incident recovery discipline.

## 14. Config/LiveOps tools

If using Roblox Configs/external ops:
- bounds/type validation
- environment separation
- rollback
- audit who changed what outside game when platform supports

In-game admin UI should not expose raw secrets.

## 15. Remote admin endpoint

If admin UI uses RemoteEvent/Function:
- role validation every call
- strict schema
- rate limit
- exact allowlisted operation IDs

Never accept target Instance/path and arbitrary property/function from client as a generic reflection API in production.

## 16. Dev visualization toggle

Useful safe commands:
- hitboxes
- AI state/path
- network ownership
- zone IDs
- performance counters

These improve debugging without mutating permanent data.

## 17. Acceptance

- [ ] server permission on every privileged operation
- [ ] structured command registry
- [ ] environment separation
- [ ] no generic eval/arbitrary reflection in production
- [ ] high-risk confirmation/audit
- [ ] permanent economy mutation tightly scoped
- [ ] platform safety/filtering respected
- [ ] anti-cheat prevents harm before punishment
- [ ] recovery operations transaction-specific
