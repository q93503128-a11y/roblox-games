# Asset Import Checklist

> verified: 2026-09-03

모든 Creator Store/외부 3D asset/kit에 적용한다.

## Source
- [ ] source URL
- [ ] asset ID if Roblox
- [ ] creator
- [ ] usage/license basis
- [ ] verified date
- [ ] `ASSET_SOURCES.md` 기록

## Security
- [ ] Script count
- [ ] LocalScript count
- [ ] ModuleScript count
- [ ] numeric `require()` search
- [ ] `loadstring` search
- [ ] HttpService / InsertService / AssetService runtime loading
- [ ] obfuscation/encoded strings
- [ ] unknown capabilities
- [ ] visual-only import이면 unnecessary scripts removed

Reject if behavior cannot be explained.

## Model integrity
- [ ] meaningful name
- [ ] pivot
- [ ] scale against avatar
- [ ] model moves with `PivotTo()` correctly
- [ ] eyes/accessories/weapons/attachments stay together
- [ ] rig/Motor6D/constraints sane

## Geometry
- [ ] collision fidelity appropriate
- [ ] no invisible blocking parts
- [ ] no duplicate coplanar surfaces
- [ ] no tiny excessive decorative parts
- [ ] normals/rendering sane

## Materials/textures
- [ ] project palette/style match
- [ ] resolution appropriate to role
- [ ] transparency cost considered
- [ ] texture ownership/source valid
- [ ] no unexpected external dependency

## Performance
- [ ] instance count
- [ ] mesh/material count
- [ ] particle/light count
- [ ] bones/rig complexity
- [ ] repeated usage worst case
- [ ] mobile visual/perf check for frequently used asset

## Gameplay
- [ ] interaction/collision matches visual
- [ ] pathfinding/nav not obstructed unintentionally
- [ ] camera doesn't clip badly
- [ ] projectile/raycast interactions defined

## Final status
Choose one:
- `S_APPROVED`
- `A_APPROVED_WITH_MODS`
- `B_PROTOTYPE_ONLY`
- `C_REFERENCE_ONLY`
- `REJECT_SECURITY`
- `REJECT_SOURCE`
- `REJECT_QUALITY`
- `REJECT_PERFORMANCE`

## Sanitized copy rule

외부 model을 그대로 production hierarchy에서 수정하기보다:
1. quarantine/test place에 insert
2. inspect
3. remove scripts/dependencies
4. normalize pivot/material/name
5. approved sanitized copy를 project로 이동

## Kit-specific extra
- [ ] Remote schema/security
- [ ] DataStore namespace
- [ ] marketplace/payment code
- [ ] global singleton/hardcoded paths
- [ ] dependency versions
- [ ] remove/replace plan
- [ ] test in isolated place

Official security reference:
https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities
