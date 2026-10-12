# Slay & Loot — Asset Sources

Every external production asset used in Slay & Loot must be recorded here after audit.

## Required fields

| Asset | Asset ID / Source | Creator | Category | Intended Use | Scripts Removed | Modified | Security | Scale/Pivot/Collision | Visual Fit | Status | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|

No production assets approved yet.

## Status meanings

- `CANDIDATE` — discovered, not yet approved
- `QUARANTINED` — inserted only for inspection; must not ship
- `APPROVED` — source/security/visual/technical checks passed for the stated use
- `REJECTED` — do not use; explain why in Notes
- `REPLACED` — historical source retained for traceability, but no longer active

## Minimum audit before APPROVED

- source and creator known
- usage basis acceptable
- scripts/dependencies inspected
- suspicious runtime loading/obfuscation absent or removed
- pivot/rig usable
- avatar-relative scale checked
- collision suitable or replaced with proxy
- gameplay camera appearance checked
- performance cost reasonable for intended repetition count
- visually coherent with the accepted project direction

If only a visual model is needed, prefer a sanitized script-free copy.
