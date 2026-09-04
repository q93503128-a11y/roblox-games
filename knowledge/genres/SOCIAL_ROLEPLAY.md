# Social / Roleplay Starter Recipe

> 검증 기준일: 2026-09-04

## 목표

퀘스트가 없어도 친구/낯선 사람과 **자기표현 → 만남 → 즉흥 역할극 → 공유 가능한 순간**이 계속 생기는 social/RP sandbox를 만든다.

## Reference vocabulary

대표 참고 축:
- Brookhaven RP — houses, vehicles, city landmarks, identity freedom, private-server controls
- Dress To Impress — timed self-expression + social comparison/voting + rank
- Adopt Me/Bloxburg류 — home/customization/collection/social visit 구조 연구용

참고:
- https://www.roblox.com/games/4924922222/Brookhaven-RP

Brookhaven의 공개 설명은 houses, vehicles, city exploration, 자유로운 roleplay를 핵심으로 둔다.

## Core loop

```text
identity 선택
→ 장소/prop/vehicle 선택
→ 다른 플레이어와 접촉
→ 즉흥 상황 생성
→ 표현/소유/공유
→ 다른 장소/역할로 전환
```

## Vertical slice

- compact town/neighborhood 1
- landmark 5~8개
- house/interior 2~3개
- vehicle 2개
- job/role presets 4개
- emote/pose 8개 내외
- prop interaction 10개
- friend teleport/invite 또는 location marker
- private/social safety controls 최소

## World design

social map은 넓이보다 **encounter density**가 중요하다.
- landmark 사이 이동 20~60초 내
- 중앙 meeting point
- 역할극이 자연히 생기는 paired locations: hospital/ambulance, school/home, shop/vehicle 등
- 숨겨진 장소는 대화 소재가 되지만 핵심 기능은 숨기지 않음

## Identity / expression

- avatar outfit을 존중
- role/job는 강제 progression보다 즉시 전환 가능
- houses/vehicles/props가 screenshot/story material을 제공
- pose/emote는 UI에서 빠르게 접근

## Interaction

- seat/door/vehicle/prop state가 여러 플레이어에서 일관
- ownership/permission 명확
- griefable props는 rate limit/cleanup/owner control
- private server admin은 moderation 권한과 분리해서 설계

## Safety / moderation

social game은 운영 설계가 core feature다.
- block/report 흐름을 방해하지 않음
- user-generated text/voice는 플랫폼 policy를 따른다.
- prop spam, vehicle blocking, teleport harassment 대응
- age/maturity target에 맞는 interaction scope

## Monetization

power가 아니라 expression/space convenience 중심이 자연스럽다.
- cosmetics
- house/vehicle variants
- extra prop slots
- private server conveniences

## P0 routes

1. spawn → role 선택 → landmark 이동 → prop interaction
2. 두 플레이어가 house/vehicle interaction 공유
3. owner/non-owner permission 차이
4. player leaves → owned transient props cleanup
5. friend join/teleport flow
6. mobile emote/vehicle/house UI
7. 6~8 simulated clients에서 shared state smoke test

## Scale gate

아래 전에는 도시를 크게 확장하지 않는다.
- 3명만 있어도 encounter가 발생
- 5개 landmark가 각각 다른 roleplay prompt를 만듦
- vehicle/house ownership이 안정적
- 화면이 UI보다 world/avatars를 먼저 보여줌
- grief cleanup path가 있음
