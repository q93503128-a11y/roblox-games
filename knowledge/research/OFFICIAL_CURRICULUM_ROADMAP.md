# Official Curriculum Roadmap

> verified: 2026-09-03
> priority: S — Roblox official worked examples first

Godbase는 블로그/영상만 모으지 않는다. Roblox가 직접 제공하는 curriculum/template을 **실행 가능한 교재**로 활용한다.

## 1. Creator Docs 전체 지도

Agent index:
https://create.roblox.com/docs/llms.txt

Full text:
https://create.roblox.com/docs/llms-full.txt

Engine API:
https://create.roblox.com/docs/reference/engine/llms.txt

Open Cloud:
https://create.roblox.com/docs/cloud/llms.txt

새로운 Roblox 사실을 확인할 때 일반 검색보다 이 공식 색인을 먼저 사용한다.

## 2. Current learning paths

Creator Docs의 current experience/curriculum 영역에서 특히:
- Environmental Art
- Gameplay Scripting
- UI Design
를 장기 기본 축으로 본다.

Landing reference:
https://create.roblox.com/docs/experiences

## 3. Gameplay Scripting curriculum

https://create.roblox.com/docs/tutorials/curriculums/gameplay-scripting

Laser Tag style larger project를 통해 연구할 가치:
- team flow
- rounds
- spawn
- blaster architecture
- hit detection
- gameplay state

단순 syntax tutorial이 아니라 **실제 기능들이 서로 연결되는 방식**을 읽는다.

연구 방법:
1. 원본 실행
2. tree/service map 작성
3. one feature trace
4. server/client boundary 표시
5. 코드 삭제해 failure 관찰
6. 작은 별도 project에 principle 재구현

## 4. Assistant coding curriculum

https://create.roblox.com/docs/tutorials/curriculums/building/code-with-assistant

핵심 Godbase rule:
Assistant/AI output도 반드시 Playtest한다.

AI를 syntax generator로만 쓰지 않고:
- explain current data model
- write small change
- test
- inspect output
- revise
의 loop로 사용한다.

## 5. Build It, Play It official series

Index:
https://create.roblox.com/docs/education/landing-pages/build-it-play-it

### Mansion of Wonder
Focus:
- VFX
- magical visual feedback
- interactive environment

### Island of Move
Focus:
- animation
- character movement
- simulator-style loop ideas

### Galactic Speedway
Focus:
- 3D modeling
- racing/track
- environment construction

### Create and Destroy
Focus:
- level design
- destructible/interaction concepts

### Story Games
Focus:
- scripts
- branching/story logic fundamentals

초보자 교재라고 무시하지 않는다. Roblox 공식 example의 naming/data-model/interaction patterns를 추출한다.

## 6. Templates as curriculum

Templates는 uncopylocked executable textbooks다.

연구 우선순위 예:

### Action game
1. Combat
2. FPS System
3. Laser Tag
4. Platformer

### Racing
1. Racing
2. Classic Racing
3. Galactic Speedway

### Live event/social
1. Concert
2. Event Sequencer module
3. Developer Modules

### Simulator
1. Move It Simulator
2. Island of Move
3. official Feature Packages for progression/liveops

## 7. Performance curriculum

Required reading sequence:
1. https://create.roblox.com/docs/performance-optimization
2. improve performance
3. MicroProfiler basics
4. MicroProfiler walkthrough
5. actual project capture

성능 문서를 읽기만 하지 말고 같은 pattern을 자신의 Place에서 reproduce한다.

## 8. Security curriculum

Required:
- https://create.roblox.com/docs/scripting/security/security-tactics
- https://create.roblox.com/docs/scripting/security/client-server-boundary
- https://create.roblox.com/docs/scripting/security/network-ownership
- third-party vulnerabilities

Exercise:
각 core Remote에 대해 attacker가 arbitrary payload/position/rate를 보낸다고 가정하고 validation table을 작성한다.

## 9. Data curriculum

Required:
- DataStore
- MemoryStore
- service comparison
- Open Cloud
- Secrets

Practice:
- test namespace
- save/rejoin
- schema migration
- simulated failure

## 10. UI curriculum

Required:
- adaptive design
- UI sizing/positioning/layouts
- input systems
- localization

Practice:
동일 메뉴를 phone/tablet/desktop/gamepad로 실제 조작.

## 11. World art curriculum

Official art overview에서:
- modeling
- materials/PBR
- terrain
- avatar
- animation
- import/export
을 이어서 본다.

모든 분야를 즉시 전문가 수준으로 만들려 하지 말고 **현재 vertical slice에 직접 필요한 분야를 깊게** 학습한다.

## 12. Community learning after official baseline

Official source로 현재 API/mental model을 확보한 뒤:
- DevForum deep-dive
- reputable open source
- experienced creator talks/videos
로 확장한다.

Community tip를 넣을 때 SOURCE_POLICY B/C 등급을 붙이고 current Studio에서 재현한다.

## 13. 학습 결과 기록 포맷

새 강의/문서를 연구하면:

```text
Source:
Date verified:
Problem solved:
Key principle:
Current API involved:
What is outdated:
Studio reproduction:
Performance note:
Security note:
Where Godbase applies it:
```

영상 링크만 저장하는 것은 학습 완료가 아니다.

## 14. 반복 학습 루프

매 프로젝트에서:
`문서/예제 → 작은 reproduction → 실제 프로젝트 → regression lesson → Godbase`

실패도 학습 데이터다. 같은 실수를 두 번 하면 개인 기억 문제가 아니라 Godbase regression rule 부족으로 취급한다.
