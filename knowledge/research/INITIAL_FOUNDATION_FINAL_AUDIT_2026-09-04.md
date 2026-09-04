# Roblox Godbase — Initial Foundation Final Audit

> 검증 기준일: 2026-09-04
> 상태: `INITIAL_FOUNDATION_COMPLETE`

이 문서는 Roblox Godbase의 **초기 기반 구축 단계 종료 감사**다. `Godbase가 영구적으로 완성되었다`는 뜻이 아니다. Roblox 엔진·정책·Creator Store·오픈소스·성공 장르가 계속 변하므로 Godbase는 계속 갱신한다. 여기서 완료됐다고 선언하는 것은 **새 Roblox 프로젝트가 빈 Baseplate와 모델의 기억만으로 시작하지 않아도 될 만큼 공통 개발 운영체계가 갖춰졌다는 것**이다.

## 1. 감사 기준점

초기 최종 감사 직전 `main` 기준:

- 장르 recipe까지 포함한 Godbase 정본이 main에 연결됨.
- 강화 전 CI 기준 Godbase inventory: **94 Markdown / 9 JSON**.
- 자동 unit tests: **17개**.
- Creator Store metadata/quarantine/promotion 테스트, MCP playtest contract 테스트가 존재.
- `Roblox Godbase Check`가 통과한 상태에서 최종 감사를 시작.

최종 감사 과정에서 `tools/godbase/validate.py`를 강화해 다음까지 검사하게 했다.

- Manifest가 가리키는 repository path 존재 여부
- 모든 Godbase JSON 파싱
- 모든 Godbase JSON 내부의 `knowledge/`, `tools/`, `.github/` 경로 존재 여부
- Markdown의 명시적 상대경로/저장소 경로 존재 여부
- 비정상적으로 빈 Markdown
- genre recipe matrix의 recipe/godbase/firstSlice/qualityGate 최소 계약
- `knowledge/genres/` recipe가 matrix에 누락되지 않았는지

강화 validator를 적용한 commit에서도 CI가 통과했다.

## 2. 현재 갖춘 공통 개발층

### A. 시작/판단 계층

- `knowledge/GODBASE_MANIFEST.json`
- `knowledge/AGENT_PROTOCOL.md`
- `knowledge/QUICK_REFERENCE.md`
- `knowledge/checklists/PROJECT_START_CHECKLIST.md`
- `knowledge/regressions/FAILURE_LIBRARY.md`
- `knowledge/catalogs/DEPRECATED_LEGACY_WATCHLIST.md`

새 작업은 구현보다 이 라우팅 계층을 먼저 사용한다.

### B. Studio-first AI 개발 계층

- Studio MCP + Script Sync workflow
- autonomous build/playtest harness
- machine-readable MCP playtest contract
- device simulation
- multi-client StudioTestService 방향
- Output/screenshot/input 기반 acceptance loop

핵심 변화는 **사용자가 첫 구조 QA를 맡는 workflow를 기본값에서 제거**한 것이다.

### C. 코드/엔진/보안 계층

- Luau engineering
- client/server ownership
- Remote validation
- networking/replication
- physics/network ownership
- server authority
- pathfinding/NPC AI
- persistence/migration/economy
- security/anti-cheat
- performance/streaming/loading

### D. 에셋/키트 공급망

Creator Store를 `검색해서 바로 삽입`하지 않는다.

```text
discovery/search
→ metadata triage
→ quarantine Studio audit
→ visual review
→ production-fit test
→ S/A/B/C/REJECT
→ canonical catalog promotion
```

공식 Roblox pack/module을 먼저 평가하고, scripted model·plugin은 더 높은 공급망 위험으로 취급한다.

### E. 시각/게임감 계층

- world/terrain/level design
- visual quality
- animation/rigging
- VFX/telegraph
- audio/mixing
- camera/game feel
- UI/UX/cross-platform/accessibility
- combat feel/hit detection/projectiles

`작동한다`와 `게임처럼 느껴진다`를 별도 품질축으로 취급한다.

### F. 장르 시작 계층

현재 primary starter recipe:

- Action RPG / Open World
- Battlegrounds / Fighting
- Simulator / Collection
- Tycoon / Management
- Tower Defense
- Horror / Run-based
- Survival / Extraction / Co-op
- Round / Minigame
- Social / Roleplay
- Shooter / Arena

`knowledge/genres/STARTER_RECIPE_MATRIX.json`이 각 장르의 first slice, 필요한 Godbase 문서, quality gate를 machine-readable하게 라우팅한다.

### G. 출시/운영 계층

- Analytics event taxonomy
- Discovery/retention
- monetization/LiveOps
- policy/localization
- Open Cloud/CI release
- testing/release matrix
- admin/moderation

## 3. 최종 감사에서 정리한 구조 원칙

### Overview 문서와 전문 문서를 구분

초기 Batch에 만든 넓은 overview 문서는 삭제하지 않는다. 다만 신규 작업에서는 더 최신·세분화된 전문 문서를 우선한다.

예:

- `genre/GENRE_REFERENCE_MATRIX.md` = 장르를 분석하는 범용 프레임
- `genres/*.md` = 현재 신규 프로젝트용 구체 starter recipe

- `graphics/WORLD_ART_ANIMATION_AUDIO.md` = 넓은 overview
- `graphics/VISUAL_QUALITY_PIPELINE.md`, `animation/...`, `audio/...`, `camera/...` = 전문 실행 정본

- `data/DATA_ECONOMY_AND_LIVEOPS.md` = 넓은 overview
- `data/CLOUD_SERVICES_DECISION_MATRIX.md`, `SAVE_SCHEMA_MIGRATION_RECOVERY.md`, `ECONOMY_BALANCING_INFLATION.md`, production/analytics 문서 = 전문 실행 정본

이렇게 하면 오래된 유용한 지식을 버리지 않으면서도 새 프로젝트가 구식 overview만 집는 일을 줄인다.

## 4. 품질 상태

초기 Foundation의 품질 판정:

| 영역 | 상태 |
|---|---|
| 공식 Roblox 지식 지도 | READY / 계속 갱신 |
| 개발 workflow 선택 | READY |
| Studio MCP autonomous QA 설계 | READY, 실제 연결은 각 로컬 환경에서 수행 |
| OSS/library selection | READY / 버전 재검증 필요 |
| Creator Store 공급망 | READY, catalog는 계속 확장 |
| 보안/네트워크/저장 | READY |
| UI/아트/전투/월드 playbook | READY |
| 장르 starter recipes | READY, 실전 프로젝트에서 보정 |
| CI/self-validation | READY |
| 모든 Roblox 에셋 전수 catalog | NOT COMPLETE / 의도적으로 지속 조사 |
| 모든 인기 게임 실측 reverse engineering | NOT COMPLETE / 프로젝트별 지속 |

## 5. 남아 있는 의도적 미완성

다음은 실패가 아니라 **지속 운영 대상**이다.

1. Creator Store는 규모와 변화 속도 때문에 영구 전수 완료 상태가 없다.
2. Roblox 공식 Beta/engine capability는 major project 시작 전에 다시 확인한다.
3. library maintenance/license/version은 adoption 직전에 다시 확인한다.
4. 장르 recipe는 실제 프로젝트의 Studio 측정치/사용자 피드백으로 계속 보정한다.
5. Studio MCP 자동화는 문서만으로 실제 게임 품질을 보장하지 않는다. 반드시 열린 Studio에서 실행 증거가 필요하다.
6. 공용 production module은 문서만 보고 `shared/`로 승격하지 않는다. 실제 여러 프로젝트에서 검증 후 승격한다.

## 6. 초기 Foundation 종료 판정

다음이 모두 갖춰졌으므로 초기 공사를 종료한다.

- [x] 공통 entrypoint/manifest
- [x] source/freshness policy
- [x] engine/code/network/security/data playbooks
- [x] visual/UI/combat/world playbooks
- [x] official/OSS/toolchain decision layer
- [x] Creator Store quarantine + promotion pipeline
- [x] Studio MCP autonomous build/playtest harness
- [x] machine-readable acceptance contract
- [x] major genre starter recipes + routing matrix
- [x] regression library
- [x] CI validation + unit tests
- [x] continuous research roadmap
- [x] next-chat handoff

따라서 현재 상태는:

```text
INITIAL_FOUNDATION_COMPLETE
CONTINUOUS_RESEARCH_ACTIVE
PROJECT_USAGE_SHOULD_NOW_TAKE_PRIORITY
```

## 7. 앞으로의 운영 방식

이제 Godbase 자체를 계속 쌓기만 하는 것보다 **실제 새 게임/기존 게임에 적용하고 결과를 환류**하는 것이 더 가치가 크다.

권장 반복:

```text
latest main
→ Manifest
→ genre recipe
→ domain docs/catalog
→ project-specific contract
→ Studio MCP build/playtest
→ human feel feedback
→ regression / catalog / recipe update
```

즉 다음 성장 단계는 `더 많은 문서`가 아니라 **Godbase를 쓴 실제 게임의 성공·실패 데이터**다.
