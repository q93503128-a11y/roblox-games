# Vertical Slice Definition of Done

> verified: 2026-09-03

Vertical Slice는 "시스템의 일부"가 아니라 **짧지만 실제 출시 게임의 품질 방향을 보여주는 완성 구간**이다.

## 범위

기본 목표: 5~10분.

포함 예:
- spawn/entry
- core action
- enemy/challenge
- reward
- progression choice
- short continuation hook

포함하지 않아도 되는 것:
- 모든 biome
- 모든 class
- endgame
- full LiveOps
- 모든 shop product

## Design
- [ ] target fantasy 한 문장
- [ ] primary loop 한 문장
- [ ] reference games 1~3개
- [ ] slice 시작/끝 정의
- [ ] 첫 fun까지 불필요한 friction 없음
- [ ] next-goal hook 존재

## Studio / Boot
- [ ] actual Studio Play test
- [ ] unexpected Output error 0
- [ ] spawn safe
- [ ] camera normal
- [ ] no hidden manual setup needed

## World
- [ ] authored path/landmark
- [ ] player가 목적지를 이해
- [ ] combat/traversal space가 camera와 맞음
- [ ] no random decoration soup
- [ ] no visible z-fighting
- [ ] collisions intentional

## Art
- [ ] hero placeholder 0
- [ ] palette/material direction consistent
- [ ] weapon/enemy silhouette readable
- [ ] model parts stay attached
- [ ] lighting readable on target devices
- [ ] VFX doesn't obscure action

## Character/Input
- [ ] movement responsive
- [ ] keyboard/touch/gamepad scope에 맞게 core action 가능
- [ ] contextual prompt current binding과 일치
- [ ] respawn/reset works

## Combat/action
- [ ] one full action cycle polished
- [ ] anticipation readable
- [ ] active timing matches animation
- [ ] hit confirmation sound/VFX/reaction
- [ ] recovery intentional
- [ ] enemy telegraph fair
- [ ] camera stable/readable
- [ ] spam input handled

## UI
- [ ] HUD shows only needed info
- [ ] information hierarchy clear
- [ ] loading/error/disabled states
- [ ] small phone no critical clipping
- [ ] gamepad navigation if supported
- [ ] style tokens consistent

## Progression
- [ ] first reward meaningful
- [ ] player understands what improved
- [ ] number change matches gameplay effect
- [ ] invalid/duplicate reward blocked

## Networking/Security
- [ ] server owns valuable state
- [ ] Remote inputs validated
- [ ] rate limit on abuseable requests
- [ ] multiplayer path tested
- [ ] client cannot submit reward/price/result

## Data
Persistence가 slice 범위라면:
- [ ] test environment
- [ ] save/rejoin
- [ ] schema version
- [ ] migration/defaults
- [ ] failed load does not create destructive overwrite

## Performance
- [ ] join-to-control acceptable for project target
- [ ] low/mid device baseline
- [ ] no runaway frame loop
- [ ] VFX worst case checked
- [ ] memory does not monotonically leak in repeat route

## Experience quality
1~5 자체 점수:
- [ ] visual cohesion ≥ project threshold
- [ ] responsiveness ≥ threshold
- [ ] readability ≥ threshold
- [ ] reference similarity of *quality*, not copied identity ≥ threshold
- [ ] core fun ≥ threshold

점수 기준을 프로젝트 docs에 정의한다. 낮은 점수를 feature count로 보상하지 않는다.

## FTUE
- [ ] first objective clear
- [ ] first 3 min core loop
- [ ] tutorial by doing
- [ ] no forced long text before fun
- [ ] funnel event plan where analytics relevant

## Regression route
정확한 조작 순서를 기록한다.

```text
1. spawn
2. interact X
3. perform action Y
4. defeat/complete Z
5. claim reward
6. open/equip
7. die/respawn
```

MCP automation이 가능하면 같은 route를 반복한다.

## Handoff
- [ ] version/name
- [ ] exact test instructions
- [ ] known limitations
- [ ] clean output verified
- [ ] screenshots reviewed

모든 핵심 section을 통과한 뒤에야 다음 biome/class/content batch로 확장한다.
