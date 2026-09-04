# Tower Defense Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

배치 위치, tower role, upgrade timing, wave information이 실제 decision을 만드는 tower defense를 만든다. 핵심은 **unit 수집보다 전투 읽기와 선택**이다.

## Reference vocabulary

대표 참고 축:
- Tower Defense Simulator — unit 배치, co-op, boss wave, unit unlock/evolution, lobby/matchmaking

참고:
- https://www.roblox.com/games/3260590327/Tower-Defense-Simulator

## Core loop

```text
wave preview
→ 제한 자원으로 tower 배치
→ enemy route/trait 관찰
→ upgrade/sell/reposition decision
→ boss/special counter
→ match reward
→ 새로운 tower/loadout 선택
```

## Vertical slice

- map 1
- lane 1~2
- wave 10개
- enemy archetype 5개: basic/fast/tank/special/boss
- tower 5개: cheap DPS/range/AOE/control/support 또는 economy
- 각 tower upgrade 2~3단계
- solo + 2-player co-op
- match reward/loadout UI 최소

## Readability

- enemy HP/trait를 과잉 UI 없이 식별
- tower range preview
- target mode 표시
- placement invalid reason
- wave start/remaining/boss warning
- damage effect가 enemy silhouette를 가리지 않음

## Balance

Tower role이 겹치지 않아야 한다.
- early efficiency
- single-target
- crowd/AOE
- control
- support/economy

모든 tower를 DPS/price 하나로만 비교하게 만들지 않는다.

## Map

- route length와 bend가 placement decision을 만든다.
- best spot 하나만 존재하지 않게 한다.
- visual clutter가 range circle/target reading을 망치지 않는다.
- enemy path는 deterministic하고 debugging 가능해야 한다.

## Co-op

- shared/individual currency 정책 명확
- tower ownership/UI 명확
- griefing 가능한 sell/placement permission 제한
- late join 정책 명확

## P0 routes

1. solo wave 1~10 clear
2. intentionally poor placement → loss가 납득 가능
3. fast/tank/special counter가 서로 다름
4. boss wave telegraph/ability 정상
5. 2-player simulated clients로 shared match
6. player disconnect/leave handling
7. mobile tower select/place/upgrade/sell

## Scale gate

아래 전에는 tower 20개를 만들지 않는다.
- 5 tower가 서로 다른 decision을 만듦
- 10-wave match가 지루하지 않음
- co-op state desync 없음
- path/placement edge case 회귀 통과
- VFX 중첩에도 적/route가 읽힘
