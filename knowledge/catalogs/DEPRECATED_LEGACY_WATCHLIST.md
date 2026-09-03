# Deprecated and Legacy Watchlist

> verified: 2026-09-03

Purpose: prevent old tutorials, old package names and historically popular frameworks from silently becoming defaults in new projects.

## Knit — LEGACY_MAINTENANCE_ONLY

Repo: https://github.com/Sleitnick/Knit
Verified: `archived=true`.

Existing stable projects may retain Knit. New projects should use simpler domain modules or current tools chosen by actual needs.

## TestEZ — LEGACY_MAINTENANCE_ONLY

Repo: https://github.com/Roblox/testez
Verified: `archived=true`.
Replacement evaluation: https://github.com/Roblox/jest-roblox

Do not rewrite stable TestEZ tests solely for novelty, but new testing infrastructure starts with Jest Roblox evaluation.

## ProfileService — LEGACY_MAINTENANCE_ONLY FOR NEW WORK

Repo: https://github.com/MadStudioRoblox/ProfileService

Upstream README explicitly states:
- **FOR NEW PROJECTS - USE ProfileStore**
- ProfileService is no longer supported
- migration to ProfileStore is possible for most projects

Current successor:
https://github.com/MadStudioRoblox/ProfileStore

Existing games must not mass-migrate live save data without a tested schema/session migration plan.

## BridgeNet2 — LEGACY / REPLACED FOR NEW WORK

Repo: https://github.com/ffrostfall/BridgeNet2
Upstream README recommends ByteNet instead.

New projects:
- native RemoteEvent/UnreliableRemoteEvent first
- ByteNet if measured networking/schema needs justify it

## Foreman / Aftman — LEGACY OR PROJECT-SPECIFIC

Older Roblox toolchain tutorials commonly use Foreman/Aftman. Existing working project lockfiles may stay. New project bootstrap should evaluate current Rokit ecosystem and current project needs before copying old setup guides.

Do not churn toolchains when there is no concrete benefit.

## `wait()`, `spawn()`, `delay()` old patterns

Modern Luau code should generally prefer `task.wait`, `task.spawn`, `task.defer`, `task.delay` and event/structured async patterns.

Old code may still execute; this watchlist means **do not copy the legacy idiom into new code**.

## BodyMovers vs modern constraints/forces

Old vehicle/movement tutorials often rely on legacy BodyMover patterns. Before new implementation, check current constraints/forces such as LinearVelocity, VectorForce, AlignPosition/AlignOrientation and current Roblox physics docs.

Do not blindly rewrite a stable legacy vehicle without physics regression testing.

## ContextActionService / UserInputService hardcoding vs Input Action System

Older tutorials often wire individual keys directly throughout LocalScripts. Current new projects should evaluate Roblox's Input Action System first for cross-device action binding/context switching.

Direct UserInputService remains valid for specialized low-level input; the deprecated pattern is **scattered hardcoded key ownership**, not the service itself.

## Custom client-authoritative physics anti-cheat assumptions

Old architecture may treat network ownership as harmless. Current Godbase threat model assumes client-owned physics is attacker-controlled. Also evaluate current Roblox native Server Authority/prediction capabilities before adopting custom netcode from older tutorials.

## Old UI fixed-pixel tutorials

Avoid copying UI built around one PC resolution with absolute offsets everywhere. Current baseline includes adaptive layouts, touch/gamepad, safe areas, localization and story/component states.

## Free Model 'script works, so use it' culture

Old tutorials/community kits sometimes encouraged inserting models directly into production. Current default is quarantine → script/dependency audit → sanitize → Studio test → source record.

## Deprecation handling policy

When a library/API becomes legacy:
1. mark status in catalog/watchlist
2. record replacement/current native option
3. do not delete historical knowledge needed to maintain existing games
4. do not automatically migrate live projects
5. new projects stop selecting it by default
6. remove it only after regression/migration passes

## Refresh triggers

Re-audit immediately when:
- repository becomes archived
- upstream README declares replacement/deprecation
- Roblox ships a native replacement
- security vulnerability reported
- breaking release/rewrite changes default branch
- last meaningful maintenance becomes stale relative to risk
