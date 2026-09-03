# Packages, Team Create, and Collaboration

> verified: 2026-09-03

Official Packages:
https://create.roblox.com/docs/projects/assets/packages

## 1. Packages purpose

Roblox Packages provide:
- reusable asset branches
- update copies to latest/specific version
- AutoUpdate
- permissions
- version history / restore
- consistency/deduplication across places/projects

Godbase uses package concept for **authored Studio assets**, while Git/shared modules can handle code-first reusable pieces.

## 2. Good package candidates

- modular building kit
- common door/elevator
- approved tree/rock prop family
- common NPC visual prefab
- UI model/screen only if package hierarchy is stable
- shared interactable with well-defined interface

## 3. Bad package candidates

- one-off tiny decoration
- project-specific giant hierarchy with many unrelated systems
- constantly locally customized copies where package update has no meaning

## 4. Placeholder packages

Official docs explicitly support package-based graybox workflow: placeholder copies can later update as package improves.

Useful art pipeline:
`graybox package → art iteration → publish package → controlled update`.

이 방식은 random local copies보다 consistency가 높다.

## 5. AutoUpdate

AutoUpdate는 편하지만 blast radius가 있다.

Enable when:
- backward-compatible visual/component updates
- test/staging receives first

Be careful:
- gameplay-critical script behavior
- physics/collision changes
- package schema changes

Production critical package는 version update를 test 후 수동 적용하는 것이 나을 수 있다.

## 6. PackageLink

PackageLink를 삭제/이동하면 package behavior를 잃을 수 있으므로 hierarchy policy를 이해하고 다룬다.

## 7. Ownership

Package owner를 만들 때 개인/group ownership을 신중히 결정. asset ownership transfer limitation/current permissions를 공식 docs에서 확인.

## 8. Restricted assets

Package 내부 asset이 current experience permission을 갖지 않으면 runtime에서 보이지/들리지 않을 수 있다.

따라서 package가 Studio에서 보여도:
- target experience permission
- audio/image/model availability
를 actual playtest.

## 9. Team Create + Script Sync

Script Sync는 Team Create와 함께 동작할 수 있다.

주의:
- 여러 사람이 같은 script를 disk sync하여 동시에 편집하면 overwrite 가능
- ownership/working area를 나누기
- branch/commit discipline

## 10. Rojo collaboration

Rojo project에서는 filesystem Git이 source-of-truth. Studio-managed art area와 Rojo-owned code/data area를 명확히 나눈다.

한 object를 Studio/FS 두 source가 동시에 소유하지 않게.

## 11. Asset pipeline ownership

각 asset family에 owner를 정의.

Example:
```text
Environment package → Studio package owner
Gameplay code → Git
Balance catalogs → Git
Hero mesh source → Blender + exported asset
Runtime Place → Studio/test environment
```

## 12. Package update test

Update 전에:
- affected copies count
- local modifications
- collision
- scripts
- attributes/tags
- dependencies

Update 후 regression route.

## 13. Shared repository code vs Roblox Package

Use Git/shared module when:
- pure Luau
- code review/version diff 중요
- CI tests

Use Roblox Package when:
- DataModel objects + visual assets
- Studio authoring
- live asset version propagation

둘을 같이 사용할 수 있다.

## 14. Collaboration docs

Project README에:
- current workflow
- source-of-truth per area
- package ownership
- Script Sync roots / Rojo paths
- generated artifacts
- test/live place IDs handling
를 기록.

## 15. Done checklist

- [ ] ownership clear
- [ ] update strategy
- [ ] source assets permissions
- [ ] no dual ownership conflict
- [ ] package version tested
- [ ] local override understood
- [ ] production package update rollback path
