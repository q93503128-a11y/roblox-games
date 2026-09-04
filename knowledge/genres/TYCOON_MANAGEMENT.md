# Tycoon / Management Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

단순 button conveyor가 아니라 **건설 → 운영 → 병목 발견 → 개선 → 확장**이 반복되는 tycoon/management 게임을 만든다.

## Reference vocabulary

대표 참고 축:
- Theme Park Tycoon 2 — player-authored layout/creation depth
- Retail Tycoon 2 — stock, customer flow, store layout, staff/vehicle management
- Restaurant Tycoon 2 — build/decorate + service loop + social visit

참고:
- https://www.roblox.com/games/5865858426/Retail-Tycoon-2
- https://www.roblox.com/games/3398014311/Restaurant-Tycoon-2

## Core loop

```text
작은 시설 배치
→ 손님/생산 simulation 시작
→ revenue + 문제 발생
→ 병목 관찰
→ layout/staff/equipment 개선
→ capacity/variety 확장
```

## Vertical slice

- plot 1
- build mode
- 8~15 buildable pieces
- customer/worker agent 1~2종
- product/service 3종
- revenue/cost
- simple save/load
- one visible bottleneck (queue, stock, travel, capacity)
- one meaningful upgrade

## Build mode quality

필수:
- grid/snap consistency
- rotate/remove/move
- invalid placement feedback
- camera pan/zoom
- mobile placement support
- undo 또는 최소한 destructive confirmation

배치 UI가 불편하면 simulation이 좋아도 게임이 무너진다.

## Simulation

NPC는 완벽한 현실 simulation보다 **플레이어가 원인을 읽을 수 있어야** 한다.
- queue
- need
- destination
- service time
- satisfaction
- path failure fallback

상태를 debugging overlay로 시각화할 수 있게 한다.

## Economy

초반에는 돈이 목적이 아니라 새로운 decision을 여는 수단이어야 한다.
- capacity
- speed
- quality
- variety
- aesthetics
- automation

모든 upgrade가 단순 `+10% income`이면 경영이 아니라 숫자 클릭이 된다.

## Social

잘 맞는 기능:
- 친구 plot 방문
- like/favorite/showcase
- co-op role
- shared build permission

협업은 grief protection과 permission 모델이 먼저다.

## P0 routes

1. empty plot → first build → customer completes transaction
2. invalid build → understandable feedback
3. stock/capacity bottleneck 발생 → upgrade로 해결
4. NPC path blocked → fallback/stuck recovery
5. save/load retains layout and economy
6. mobile build/rotate/delete
7. large repeated placement performance smoke test

## Scale gate

아래 전에는 큰 catalog를 만들지 않는다.
- 첫 5분에 build/operate/improve loop가 완성됨
- NPC가 왜 실패하는지 보임
- placement UX가 PC/mobile 둘 다 쓸 만함
- save schema가 versioned
- 50~100개 object 배치에서도 기본 성능 유지
