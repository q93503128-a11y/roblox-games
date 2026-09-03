# Roblox Godbase Quick Reference

> verified: 2026-09-03

이 문서는 새 작업을 시작할 때 2~3분 안에 의사결정을 내리기 위한 Godbase 요약표다. 세부 근거는 각 전문 문서에서 확인한다.

## 0. 무조건 먼저

1. 목표 게임과 가장 가까운 **실제 Roblox 레퍼런스 1~3개**를 정한다.
2. Roblox 공식 Template / Feature Package / Developer Module에 이미 해결책이 있는지 찾는다.
3. Studio에서 직접 만들어야 한다면 가능하면 **Studio MCP + 실제 Playtest** 루프를 사용한다.
4. 외부 에셋·코드는 출처/라이선스/스크립트부터 검사한다.
5. 게임 전체가 아니라 **5~10분 Vertical Slice** 하나를 먼저 완성한다.

## 개발 방식 선택

| 상황 | 기본 선택 |
|---|---|
| Studio가 맵/모델/UI의 정본이고 코드만 Git으로 관리 | Studio + Script Sync |
| AI가 Studio 안을 읽고 수정하고 플레이테스트해야 함 | Studio MCP |
| 전체 DataModel을 파일시스템 정본으로 관리 | Rojo |
| 여러 CLI 버전을 재현 가능하게 관리 | Rokit |
| Luau 패키지 설치 | Wally |
| 코드 포맷 | StyLua |
| 정적 린트 | selene |
| 외부 편집기 타입/자동완성 | Luau LSP + Studio companion |

공식 Script Sync는 코드만 양방향 동기화하며, 전체 프로젝트를 파일시스템 정본으로 둘 때는 Roblox 문서도 Rojo를 대안으로 안내한다.

## 구현하기 전에 공식 부품 확인

### Templates
Platformer, Laser Tag, FPS System, Racing, Combat, Concert, Move It Simulator 등은 공식 uncopylocked starting experience다. 기능을 직접 재발명하기 전에 구조와 코드를 먼저 분석한다.

### Feature Packages
- Core
- Bundles
- Missions
- Season Passes
- Engagement Rewards

백엔드 코드 + 기본 UI + 설계 관행 + funnel analytics까지 포함한다. LiveOps/상업 기능은 맨땅 구현보다 먼저 검토한다.

### Developer Modules
Friends Locator, Spawn With Friends, Emote Bar, Profile Card, Photo Booth, Scavenger Hunt, Event Sequencer 등. 소셜/이벤트 기능을 다시 만들기 전에 확인한다.

## 서버 / 클라이언트 한 줄 원칙

**클라이언트는 의도(intent)를 보내고, 서버가 결과(state)를 결정한다.**

서버가 최종 판정해야 하는 것:
- 돈/재화/아이템
- 구매 보상/영수증
- 드랍/가챠 결과
- XP/레벨/퀘스트 완료
- 거래 소유권
- 중요한 전투 판정
- 영구 저장 상태

Remote 입력은 타입, 값 범위, 문자열/테이블 크기, 인스턴스 소유권, 거리, 진행상태, 호출 빈도를 검증한다.

## 데이터 서비스 선택

| 필요 | 서비스 |
|---|---|
| 영구 플레이어 진행/인벤토리 | DataStore / 검증된 player profile wrapper |
| 영구 숫자 순위 | OrderedDataStore |
| 빠른 크로스서버 임시 상태/매치메이킹 | MemoryStore |
| 서버 재시작 없이 읽기 전용 튜닝/feature flag | Configs |
| 외부 API 키/토큰 | Secrets Store |
| 한 서버에서만 필요한 즉시 상태 | Luau memory |

ProfileStore는 player-data/session locking에 적합하지만 global state나 leaderboard용이 아니다.

## 성능 한 줄 원칙

- 먼저 측정하고 최적화한다.
- 큰 월드는 Instance Streaming을 우선 검토한다.
- 매 프레임 RunService 코드를 최소화한다.
- `PreloadAsync`는 시작에 반드시 필요한 자산만.
- Parallel Luau는 계산량이 큰 독립 작업에만.
- 저사양 모바일을 실제 성능 기준에 포함한다.
- MicroProfiler와 Performance Summary로 원인을 확인한다.

## UI / 입력 한 줄 원칙

- PC만 보고 UI 완료 판정 금지.
- touch / keyboard+mouse / gamepad에서 핵심 행동을 모두 수행할 수 있어야 한다.
- 최신 프로젝트는 Input Action System을 우선 검토한다.
- safe zones, thumb reach, text legibility, focus navigation, dynamic sizing을 확인한다.
- 레퍼런스 UI의 **정보 구조와 시각 언어**를 분석하되 그대로 복사하지 않는다.

## 전투 한 줄 원칙

좋은 전투는 `damage code`가 아니라 다음의 합이다.

`input latency + anticipation + animation + hit timing + hitstop + sound + VFX + camera + knockback + enemy telegraph + arena/readability + recovery`

한 무기/한 적부터 이 전체 사이클을 완성한 뒤 콘텐츠를 늘린다.

## 외부 에셋 한 줄 원칙

Creator Store/무료 모델은 삽입 즉시:
1. Script / LocalScript / ModuleScript 수 확인
2. `require(<assetId>)`, `loadstring`, HttpService, InsertService, AssetService 검사
3. 시각용이면 불필요한 스크립트 제거
4. asset ID / creator / 수정사항 기록
5. 실제 viewport에서 scale, collision, pivot, LOD/performance 확인

## AI 개발 한 줄 원칙

AI가 만든 결과는 **사용자에게 넘기기 전에 AI가 먼저 Studio에서 테스트**한다.

최소 gate:
- Play 시작 가능
- 예상치 못한 Output error 0
- spawn 정상
- primary loop 1회 완주
- viewport screenshot 검토
- 모델 파츠 분리/z-fighting 없음
- Desktop + Mobile UI 확인

## 출시 전 우선순위

1. crash/error/performance
2. first-play bounce / FTUE friction
3. D1 retention + first session retention
4. core loop engagement
5. D7/D30 progression
6. monetization value alignment
7. acquisition/discovery scaling

Roblox Analytics도 신규 게임이 광고 확장 전에 retention/engagement/monetization을 먼저 개선하는 흐름을 권장한다.

## 금지 기본값

- 사용자가 첫 구조 테스트를 하게 만들기
- Baseplate에서 모든 시스템을 재발명하기
- 임시 Part 무기/나무/몹을 최종 미술처럼 취급하기
- 모든 Workspace를 preload하기
- Remote가 보내온 가격/보상/데미지를 신뢰하기
- Free Model script를 무검사 실행하기
- 수십 개 시스템을 만들고 마지막에 첫 플레이테스트하기
- 라이선스 불명 dump/decompile/place를 정본으로 사용하기

## 공식 출발점

- Creator Docs index: https://create.roblox.com/docs/llms.txt
- Studio MCP: https://create.roblox.com/docs/studio/mcp
- Script Sync: https://create.roblox.com/docs/scripting/sync
- Templates: https://create.roblox.com/docs/resources/templates
- Feature Packages: https://create.roblox.com/docs/resources/feature-packages
- Developer Modules: https://create.roblox.com/docs/resources/modules
- Security: https://create.roblox.com/docs/scripting/security/security-tactics
- Performance: https://create.roblox.com/docs/performance-optimization
- Discovery: https://create.roblox.com/docs/discovery
