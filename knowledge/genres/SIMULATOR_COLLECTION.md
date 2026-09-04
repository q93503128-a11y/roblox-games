# Simulator / Collection Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

반복 행동이 짧고, 수집/성장이 자주 보이며, 다음 목표가 항상 시야에 있는 simulator/collection 게임을 만든다. 핵심은 **숫자 증가 자체가 아니라 반복 행동의 feedback + 선택 + collection aspiration**이다.

## Reference vocabulary

대표 참고 축:
- Grow a Garden — seed restock → plant → wait/grow → harvest/profit, offline growth, social flex
- Fisch — simple input skill loop + rare variation + exploration + gear progression
- Pet Simulator 계열 — currency → egg/collection → equip → zone unlock → trade/clan/minigame

참고:
- https://www.roblox.com/games/126884695634066/Grow-a-Garden
- https://www.roblox.com/games/16732694052/Fisch

## Core loop

```text
짧은 action
→ immediate feedback
→ currency/item/progress
→ visible upgrade or collection choice
→ action efficiency/possibility 변화
→ 새 target/zone/rarity
```

## 첫 3분

- 10초 내 첫 action
- 30초 내 첫 reward
- 90초 내 첫 구매/업그레이드
- 180초 내 rarity/collection/zone 같은 장기 목표 제시

## Vertical slice

- primary action 1개
- currency 1~2개
- upgrade axis 2개 이하
- collectible 12~30개
- rarity 4~5단계
- zone 2개 또는 shop restock/seasonal rotation 1개
- collection UI
- save/load
- offline progression이 핵심이면 실제 offline return test

## Feedback stack

좋은 반복 action은 동시에 3~5개 feedback을 쓴다.
- animation
- sound
- number/progress movement
- world state change
- collection reveal
- rarity-specific effect

모든 reward에 화면 전체 VFX를 쓰지 않는다. rarity hierarchy를 지킨다.

## Economy

초기 경제는 spreadsheet가 아니라 **time-to-choice**로 검증한다.
- 첫 구매: 1~3분
- 의미 있는 새 선택: 3~8분
- 첫 rare aspiration은 보여주되 즉시 필수는 아님

통화 수를 초반부터 늘리지 않는다.

## Collection design

수집품은 단순 reskin만 되지 않게 최소 하나를 가진다.
- 효율 변화
- action 방식 변화
- visual/social flex
- set bonus
- recipe/use value

## Social

simulator에서 친구는 장식이 아니라 loop를 증폭시킬 수 있다.
- garden/base 방문
- trade
- co-op boost
- showcase
- clan goal

단 trade는 duplication/rollback/economy audit 없이는 넣지 않는다.

## UI

- 현재 action 목표
- 다음 구매
- collection progress
- inventory capacity가 있다면 명확하게
- 숫자 단위 축약 일관

팝업 6개가 첫 세션을 덮는 구조 금지.

## P0 routes

1. 첫 action 5회 → reward 정상
2. 첫 구매 → 실제 efficiency 변화
3. collectible 획득 → collection 반영
4. save → Studio restart equivalent → restore
5. offline progression이 있으면 time delta abuse 검증
6. inventory full/edge case
7. mobile tap/drag primary action

## Scale gate

아래 전에는 새 currency/zone 3개를 추가하지 않는다.
- 5분 반복해도 feedback이 지루하지 않음
- 첫 upgrade가 체감됨
- collection 목표가 이해됨
- save/economy exploit 기본 회귀 통과
- mobile UI가 숫자/버튼으로 화면을 덮지 않음
