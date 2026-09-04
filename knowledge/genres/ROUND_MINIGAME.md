# Round / Minigame Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

30초~수분 단위의 역할/규칙을 빠르게 이해하고, 실패 후 즉시 다시 참여하고 싶은 round-based Roblox 게임을 만든다.

## Reference vocabulary

대표 참고 축:
- Murder Mystery 2 — role asymmetry, social deduction, short round reset, collection/trade meta
- fashion/contest/minigame 계열 — theme → preparation → reveal/vote → reward 구조

참고:
- https://www.roblox.com/games/142823291/Murder-Mystery-2

## Core loop

```text
lobby/ready
→ role/rule reveal
→ 15~30초 preparation
→ 1~5분 round
→ result/reward
→ 짧은 intermission
→ 다시 시작
```

## Vertical slice

- lobby 1
- map 2개
- round state machine
- role/condition 2~3개
- timer
- win/loss
- spectator 또는 dead-state
- reward 1종
- rematch loop

## State architecture

명시적 상태를 사용한다.

```text
Lobby
Intermission
Loading
Preparing
Active
Resolving
Results
Resetting
```

모든 timer/UI/interaction은 현재 round state를 기준으로 동작한다.

## Onboarding

라운드 시작 전에 긴 규칙책을 읽히지 않는다.
- role card 1장
- 목표 1문장
- control hint 1~3개
- 첫 라운드는 forgiving

## Fairness

- spawn advantage 최소화
- role distribution 검증
- late join policy
- AFK policy
- teaming/exploit 가능성
- spectator information leakage

## Social

라운드 게임의 대기 시간은 dead time이 되기 쉽다.
- voting
- emote
- spectate
- cosmetic showcase
- map preview

하지만 intermission을 retention padding 용도로 길게 만들지 않는다.

## P0 routes

1. lobby → round start → result → reset → second round
2. 각 role win condition
3. player death → spectator → next round 복귀
4. late join
5. disconnect of critical role
6. 4~8 simulated clients multiplayer test
7. timer/state/UI desync 확인

## Scale gate

아래 전에는 map 10개 추가 금지:
- 두 map 모두 같은 ruleset이 안정적
- round reset 후 stale object/state 없음
- critical role disconnect 처리 가능
- 한 판 끝나고 다음 판까지 friction 낮음
- 첫 유저가 60초 안에 목적 이해
