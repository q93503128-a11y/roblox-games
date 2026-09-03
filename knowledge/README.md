# Roblox Godbase

> 검증 기준일: 2026-09-03

`knowledge/`는 이 monorepo의 모든 Roblox 프로젝트가 공통으로 참조하는 **개발 지식 정본**이다. 특정 게임의 기획서가 아니라, Roblox Studio·Luau·아키텍처·에셋·UI/UX·3D 아트·전투·보안·성능·저장·경제·LiveOps·분석·배포·오픈소스 도구를 지속적으로 조사하고 검증하는 지식층이다.

목표는 "모든 것을 외워서 매번 처음부터 만드는 것"이 아니라 다음 개발에서 **검증된 해결책을 먼저 검색하고, 이미 실패가 알려진 접근을 반복하지 않는 것**이다.

## 핵심 원칙

1. **공식 문서 우선** — Roblox Creator Documentation과 Engine API를 1차 사실 정본으로 사용한다.
2. **실제 Studio 검증 우선** — 코드가 그럴듯한 것보다 Studio에서 실제로 실행·플레이테스트된 결과를 우선한다.
3. **재사용보다 출처 확인이 먼저** — Creator Store, GitHub, 강의 자료는 라이선스·제작자·유지보수 상태·포함 스크립트를 검사한다.
4. **클라이언트를 믿지 않는다** — 경제·저장·보상·전투 판정처럼 가치가 있는 상태는 서버가 최종 판정한다.
5. **레퍼런스를 먼저 본다** — UI, 월드, 전투, 성장 구조를 맨땅에서 상상하지 않고 목표 장르의 우수 Roblox 게임과 공식 디자인 자료를 먼저 분석한다.
6. **Vertical Slice 우선** — 넓고 얕은 시스템 20개보다 실제로 재미있고 보기 좋은 5~10분짜리 플레이 루프 하나를 먼저 완성한다.
7. **Playtest before scale** — MVP를 일찍 테스트하고 실제 사용자 행동과 Studio 출력/프로파일링 결과를 바탕으로 반복한다.
8. **지식은 유통기한이 있다** — Roblox는 빠르게 변한다. 각 문서의 검증일과 폐기/대체 정보를 유지한다.

## 사용 순서

새 프로젝트를 시작할 때 최소한 다음 순서로 확인한다.

1. `checklists/PROJECT_START_CHECKLIST.md`
2. `workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`
3. `design/GAME_DESIGN_AND_FTUE.md`
4. `design/UI_UX_PLAYBOOK.md`
5. `architecture/ENGINE_AND_NETWORKING.md`
6. 전투 게임이면 `combat/COMBAT_FEEL_PLAYBOOK.md`
7. `security/SECURITY_AND_ANTICHEAT.md`
8. 장르에 맞는 `genre/GENRE_REFERENCE_MATRIX.md`
9. 필요한 경우 `code/OPEN_SOURCE_STACK.md`, `assets/ASSETS_KITS_AND_PLUGINS.md`
10. 첫 Vertical Slice 후 `testing/TESTING_RELEASE_ANALYTICS.md`
11. 성능 문제가 보이기 시작하면 `performance/PERFORMANCE_AND_STREAMING.md`

## 디렉터리

```text
knowledge/
├─ README.md
├─ SOURCE_POLICY.md
├─ official/
│  └─ CREATOR_DOCS_MAP.md
├─ workflow/
│  └─ STUDIO_MCP_AND_SCRIPT_SYNC.md
├─ architecture/
│  └─ ENGINE_AND_NETWORKING.md
├─ code/
│  └─ OPEN_SOURCE_STACK.md
├─ assets/
│  └─ ASSETS_KITS_AND_PLUGINS.md
├─ design/
│  ├─ GAME_DESIGN_AND_FTUE.md
│  └─ UI_UX_PLAYBOOK.md
├─ graphics/
│  └─ WORLD_ART_ANIMATION_AUDIO.md
├─ combat/
│  └─ COMBAT_FEEL_PLAYBOOK.md
├─ performance/
│  └─ PERFORMANCE_AND_STREAMING.md
├─ security/
│  └─ SECURITY_AND_ANTICHEAT.md
├─ data/
│  └─ DATA_ECONOMY_AND_LIVEOPS.md
├─ testing/
│  └─ TESTING_RELEASE_ANALYTICS.md
├─ genre/
│  └─ GENRE_REFERENCE_MATRIX.md
├─ research/
│  └─ COURSES_COMMUNITY_AND_CONTINUOUS_LEARNING.md
└─ checklists/
   └─ PROJECT_START_CHECKLIST.md
```

## 공식 정본 링크

- Roblox Creator Docs 전체 AI/에이전트용 색인: https://create.roblox.com/docs/llms.txt
- 전체 본문: https://create.roblox.com/docs/llms-full.txt
- Engine API 색인: https://create.roblox.com/docs/reference/engine/llms.txt
- Open Cloud API 색인: https://create.roblox.com/docs/cloud/llms.txt
- Creator Docs 원본 GitHub: https://github.com/Roblox/creator-docs

Roblox 공식 `llms.txt`는 2026-09-02 기준 문서 트리를 제공하며, 이 Godbase의 공식 자료 지도는 이를 기반으로 한다.

## 현재 가장 중요한 발견

2026년 현재 Roblox Studio에는 **공식 MCP 서버**가 내장되어 있다. MCP 클라이언트는 열린 Studio 세션의 데이터 모델 탐색, 스크립트 읽기/수정, Luau 실행, 플레이 모드 테스트, 캐릭터 이동, 키보드/마우스 입력 시뮬레이션까지 수행할 수 있다. Codex CLI도 Studio의 Quick Connect 지원 클라이언트에 포함된다.

따라서 이 저장소의 장기 권장 방향은 단순히 `.rbxlx`를 외부에서 생성하는 것이 아니라 **AI/코딩 하네스 ↔ Studio MCP ↔ 실제 Playtest** 루프를 활용하는 것이다. 자세한 절차는 `workflow/STUDIO_MCP_AND_SCRIPT_SYNC.md`를 따른다.

## 업데이트 규칙

- 새 자료를 발견했다고 즉시 S-tier로 올리지 않는다.
- `SOURCE_POLICY.md`에 따라 출처 등급을 붙인다.
- 도구·라이브러리는 **유지보수 상태, 라이선스, 문서화, 실제 적합성, 대체재**를 함께 적는다.
- Deprecated/Archived 자료는 지우기보다 `DEPRECATED` 상태와 대체 경로를 명시한다.
- 실제 프로젝트에서 반복 검증된 코드는 `shared/`로 승격할 수 있지만, 지식 문서에 있다는 이유만으로 공용 코드가 되는 것은 아니다.
- 장르별 레퍼런스 분석은 관찰 사실과 해석을 분리한다.
- 실제 실패는 `증상 → 원인 → 놓친 이유 → 올바른 workflow → regression test`로 기록해 재발 방지 규칙으로 승격한다.

## 다음 조사 배치

1. Creator Store 실제 에셋/키트/플러그인 장르별 검수 카탈로그
2. 장르별 상위/성장 Roblox 게임 실제 플레이 레퍼런스 연구
3. 공식 Feature Packages 전수 지도
4. DevForum/공식 튜토리얼에서 반복적으로 검증되는 실전 패턴 수집
5. Studio MCP + Codex CLI 실제 연결/자동 Playtest recipe
6. 기존 프로젝트에서 발생한 버그를 regression knowledge로 환류
