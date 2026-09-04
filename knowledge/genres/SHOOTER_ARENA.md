# Shooter / Arena Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

짧은 spawn-to-action, 명확한 weapon identity, latency에서도 납득 가능한 hit validation, cross-platform controls를 갖춘 Roblox shooter를 만든다.

## Reference vocabulary

대표 참고 축:
- Arsenal — fast arcade pace, rotating weapon variety, cosmetics/meta
- RIVALS — 1v1~5v5 duel structure, first-to-X rounds, weapon unlock/contracts, cross-platform

참고:
- https://www.roblox.com/games/286090429/Arsenal
- https://www.roblox.com/games/17625359962/RIVALS

## Core loop

```text
loadout/queue
→ 5~15초 내 contact
→ aim/movement/weapon decision
→ kill/death/round result
→ 즉시 respawn 또는 next round
→ unlock/mastery/cosmetic progress
```

## Vertical slice

- map 1개
- mode 1개
- weapon 5종: rifle/SMG/shotgun/precision/utility 또는 equivalent
- hitscan/projectile 최소 1개씩
- reload/ammo
- respawn or round reset
- scoreboard
- mobile aim/fire controls
- 2~4 player simulated test

## Gun feel

weapon identity는 숫자표가 아니라 다음의 조합이다.
- fire cadence
- recoil
- spread
- ADS/FOV
- movement penalty
- reload rhythm
- sound
- tracer/impact
- time-to-kill range

## Networking

- client sends shot intent/input evidence
- server validates impossible rate/range/state
- latency compensation policy를 명시
- projectile ownership/replication 테스트
- kill attribution은 server final

`보이는 총알`과 `실제 판정`이 과도하게 어긋나지 않게 한다.

## Map

- spawn-to-contact 목표 시간 설정
- lane/cover/vertical angle 다양화
- spawn trap 방지
- sniper sightline에 counter-route
- close-range route 존재
- landmark naming/readability

## Cross-platform

- mouse, touch, gamepad separately test
- aim assist는 platform fairness 정책 명시
- mobile HUD가 view center를 가리지 않음
- button hold/toggle behavior 일관

## Anti-cheat

server에서 최소 검증:
- fire rate
- ammo/reload
- impossible origin/direction
- alive/equipped state
- impossible movement correlation

false positive가 높은 행동 기반 ban을 바로 하지 말고 telemetry/score/escalation 구조를 쓴다.

## P0 routes

1. each weapon fire/reload/kill
2. rapid weapon switch edge case
3. death during reload/fire
4. server/client latency simulation
5. respawn protection and spawn selection
6. mobile aim/fire/reload
7. 4-client duel/team test

## Scale gate

아래 전에는 weapon 30개 추가 금지:
- 5개가 실제로 서로 다른 역할
- hit feedback와 server result 일치
- 10분 match에서 spawn trap/major desync 없음
- mobile/gamepad route 정상
- network abuse 기본 회귀 통과
