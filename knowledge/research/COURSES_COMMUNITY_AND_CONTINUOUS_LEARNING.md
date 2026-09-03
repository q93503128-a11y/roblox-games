# Courses, Community & Continuous Learning

> 검증 기준일: 2026-09-03

Godbase는 문서만 읽고 끝나는 저장소가 아니다. **공식 curriculum → 현재 API → 실전 예제 → Studio 재현 → 프로젝트 적용** 순서로 학습한다.

## 1. 1차 학습원: Roblox 공식

### Creator Docs

- 전체 색인: https://create.roblox.com/docs/llms.txt
- Get Started: https://create.roblox.com/docs/get-started
- Core curriculum: https://create.roblox.com/docs/getting-started/introduction-to-roblox-studio
- Coding fundamentals/curricula: Creator Docs Tutorials/Curriculums 섹션
- UI design curriculum: https://create.roblox.com/docs/tutorials/curriculums/user-interface-design
- Avatar tutorials: https://create.roblox.com/docs/avatar/tutorials
- Engine API: https://create.roblox.com/docs/reference/engine
- Open Cloud: https://create.roblox.com/docs/cloud

### Creator Docs GitHub

https://github.com/Roblox/creator-docs

공식 문서 소스 자체를 검색할 수 있어 문서 구조와 코드 샘플을 대규모로 분석하기 좋다. 문서 저장소의 라이선스 조건은 해당 저장소의 LICENSE를 확인한다.

### Roblox Developer Forum

https://devforum.roblox.com/

유용한 분야:

- engine feature announcement
- scripting support
- community resources
- performance findings
- UI/art/workflow discussion
- release notes / breaking changes

DevForum 답변은 **공식 API 정본이 아니다.** 날짜와 현재 API를 대조한다.

## 2. 학습 우선순위

### Stage 0 — Studio

- Explorer/Properties
- DataModel
- Play/Test modes
- Output
- Device emulator
- package/asset manager
- Script Editor
- MCP / Script Sync

목표: Studio에서 문제가 생겼을 때 어디를 봐야 하는지 안다.

### Stage 1 — Luau

- variables/tables/functions
- events/connections
- modules
- metatables는 필요할 때
- type checking
- task scheduling
- errors/assertions

목표: 거대한 script 복붙이 아니라 작은 상태와 기능을 설명할 수 있다.

### Stage 2 — Client/server

- replication
- script locations
- RemoteEvent/Function
- server authority
- network ownership
- streaming

목표: "이 코드는 어디서 실행되고 누가 신뢰 가능한가"를 항상 답한다.

### Stage 3 — Core gameplay

- input
- camera
- raycast/spatial queries
- character
- animation
- physics
- AI/pathfinding
- UI
- audio/VFX

### Stage 4 — Production

- persistent data
- security
- monetization
- analytics
- localization
- accessibility
- performance
- publishing

### Stage 5 — Tooling

- Studio MCP
- Script Sync/Rojo
- Git
- formatter/linter/LSP
- package manager
- CI
- Open Cloud automation

## 3. 추천 학습법

문서 하나를 읽은 뒤 다음을 만든다.

```text
5~20분짜리 isolated Studio repro
```

예:

Remote 보안 공부:

1. 잘못된 client-trust 구매 시스템 작성
2. exploit-style malformed requests 시뮬레이션
3. server-authoritative version으로 수정
4. rate limit/duplicate 요청 테스트

Streaming 공부:

1. 큰 테스트 월드
2. StreamingEnabled
3. 멀리 있는 instance를 LocalScript가 찾는 실패 재현
4. streaming-aware 설계로 수정

이런 재현이 단순 요약보다 오래 남는다.

## 4. 강의 평가 기준

YouTube/강의/블로그를 Godbase에 넣기 전:

- 언제 제작됐는가
- 현재 Roblox API와 맞는가
- 작성자가 코드를 이해시키는가, 복붙만 시키는가
- server/client security를 제대로 설명하는가
- source code가 공개되어 있는가
- 결과물이 실제 production pattern인가, tutorial shortcut인가
- comments/issue에서 깨진 부분이 보고됐는가

오래된 튜토리얼의 흔한 문제:

- deprecated API
- client-authoritative currency
- DataStore misuse
- old UI patterns
- legacy body movers
- 오래된 Roact/ProfileService stack
- mobile/input 미고려

## 5. Community resource를 정본으로 승격하는 과정

```text
발견
→ SOURCE_POLICY 등급 C/B
→ 공식 문서 대조
→ source/license 확인
→ 최소 Studio test
→ 장단점 기록
→ 실제 프로젝트에서 성공
→ A 후보
```

GitHub stars 하나만으로 승격하지 않는다.

## 6. GitHub 탐색 키워드

```text
Roblox Luau framework
Roblox combat system Luau
Roblox UI Fusion
Roblox datastore session locking
Roblox ECS Luau
Roblox networking typed remote
Roblox procedural generation
Roblox pathfinding AI
Roblox VFX Luau
Roblox testing
```

검색 후 `license`, `archived`, release, issue activity를 확인.

## 7. Creator Store 탐색법

검색어를 기능/스타일로 분리한다.

예:

```text
stylized forest pack
low poly medieval village
RPG weapon pack
sci-fi modular kit
UI icon pack
impact VFX
slash trail
```

후보를 바로 프로젝트에 삽입하지 않고 test place에서 검사한다.

## 8. 게임에서 배우기

가장 중요한 강의 중 하나는 **잘 만든 Roblox 게임 자체**다.

관찰은 느낌이 아니라 기록한다.

```text
timestamp
player action
system response
UI response
sound/VFX
reward
next objective
```

예:

```text
00:00 spawn
00:08 첫 상호작용
00:24 첫 reward
01:10 첫 upgrade
03:40 첫 zone unlock
```

이렇게 해야 "초반이 빠르다"를 실제 설계 데이터로 바꿀 수 있다.

## 9. 영상 분석

직접 플레이할 수 없는 오래된 게임/버전은 영상이 유용하다.

추출 가능한 것:

- HUD 변화
- animation timing
- map layout
- combat pacing
- onboarding
- progression presentation

추출할 수 없는 것:

- 실제 source code
- 정확한 server logic
- hidden probability

관찰과 추측을 구분해서 기록.

## 10. Release Notes 습관

Roblox 기능은 빠르게 바뀐다.

정기적으로 확인:

- Studio release notes
- Creator Docs update
- DevForum announcements
- Engine deprecated APIs
- Open Cloud changes
- monetization/policy changes

큰 프로젝트 작업 전에는 관련 기능의 최신 문서를 다시 확인.

## 11. Godbase 업데이트 배치

권장 반복 배치:

### Official batch

새 공식 기능/문서 반영.

### Open-source batch

라이브러리 유지보수/대체재 확인.

### Asset batch

장르별 Creator Store 후보 실제 검수.

### Reference batch

성공 게임 5~10개 분석.

### Failure batch

우리 프로젝트에서 실제 실패한 사례를 원인/재발방지로 저장.

## 12. 실패에서 배우기

실패 기록 형식:

```text
symptom:
root cause:
why it was missed:
correct workflow:
regression test:
```

예:

- 스크립트 한 줄 부팅 오류 때문에 runtime map 전체 생성 실패
- model body만 이동하고 child visual이 분리
- static/runtime geometry 겹쳐 화면 flicker
- Studio를 직접 검증하지 않고 `.rbxlx`를 완성품으로 전달

이런 사례는 `testing`과 workflow 규칙으로 승격해 반복하지 않는다.

## 13. 주간 학습 질문

```text
이번 주 Roblox에 새로 생긴 기능은?
우리가 쓰는 dependency 중 deprecated/archived된 것은?
현재 장르 상위 게임 UI/FTUE에 바뀐 convention은?
Creator Store에서 새로 검증할 asset pack은?
최근 실제 프로젝트 버그에서 공용 규칙으로 승격할 것은?
```

## 14. 최종 목표

Godbase가 충분히 성장하면 새 프로젝트에서:

```text
아이디어
→ genre/reference 검색
→ 검증된 workflow 선택
→ starter/tool stack 선택
→ asset shortlist
→ vertical slice
→ Studio MCP automated playtest
→ human taste test
→ 확장
```

으로 시작한다.

"빈 Baseplate에서 ChatGPT가 기억만으로 모든 것을 만든다"는 기본 전략으로 돌아가지 않는다.
