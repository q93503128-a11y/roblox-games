# Assets, Kits & Plugins

> 검증 기준일: 2026-09-03

Roblox 게임 품질을 맨땅 제작 능력에만 맡기지 않는다. **검증된 에셋·키트·패키지·플러그인을 적극적으로 사용하되, 출처·권한·스크립트 안전성·성능을 먼저 확인한다.**

공식 참고:

- Creator Store: https://create.roblox.com/docs/production/creator-store
- Assets: https://create.roblox.com/docs/assets
- Packages: https://create.roblox.com/docs/projects/assets/packages
- Asset privacy: https://create.roblox.com/docs/projects/assets/privacy
- Third-party asset vulnerabilities: https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities
- Importer: https://create.roblox.com/docs/studio/importer

## 1. Creator Store를 기본 검색원으로

Creator Store에는 Roblox와 커뮤니티가 만든 수백만 개의 다음 유형이 있다.

- 3D models
- mesh
- materials
- plugins
- gameplay scripts
- UI elements
- sound effects/audio
- packages

새 프로젝트에서 다음을 직접 primitive로 만들기 전에 먼저 검색한다.

- 나무/바위/건물
- 무기/소품
- 환경 prop
- UI icon/component
- VFX base
- animation helper
- vehicle/building system

**단, 검색 결과가 있다는 것과 바로 사용 가능하다는 것은 다르다.**

## 2. 에셋 평가표

Godbase 카탈로그에 후보를 넣을 때:

```text
name:
asset_id:
creator:
source_url:
asset_type:
visual_style:
script_count:
mesh_complexity:
mobile_fit:
license_or_usage_status:
security_status:
quality_grade: S/A/B/C/Reject
best_for:
risks:
verified_date:
```

### 품질 등급 예

S:

- Roblox official 또는 매우 신뢰 높은 제작자
- 시각 품질 높음
- 불필요한 스크립트 없음
- 성능 적절
- 여러 프로젝트에 재사용 가치 큼

A:

- 바로 production 후보
- 약간의 수정/최적화 필요

B:

- prototype/보조 prop에 유용

C:

- 레퍼런스만

Reject:

- 출처 불명
- 악성/난독화 script
- 과도한 poly/texture
- 품질이 목표 아트 방향과 안 맞음

## 3. 삽입 직후 보안 검사

Creator Store third-party model은 **sandbox first** 사고방식으로 다룬다.

검사 키워드:

```text
require(<number>)
loadstring
HttpService
InsertService
AssetService
GetObjects
LinkedSource
getfenv
setfenv
obfuscated strings
very long encoded strings
```

Roblox Creator Store 정책도 공개 asset에서 난독화, 원격 asset require, loadstring 계열을 제한한다.

시각 모델만 필요하면:

1. 별도 test place에 삽입
2. 스크립트 전수 확인
3. 필요 없는 Script/LocalScript/ModuleScript 삭제
4. texture/mesh permission 확인
5. collision/anchored 설정 정리
6. 이름/폴더 정리
7. 성능 확인
8. clean model만 본 프로젝트로 이동

## 4. Script Capabilities / Sandboxing

Roblox는 third-party asset의 backdoor 위험 대응으로 sandbox/capabilities를 제공한다.

특히 민감한 capability:

- Network
- DataStore
- AssetRequire
- CapabilityControl
- LoadString

에셋이 왜 필요한지 설명할 수 없는 권한은 주지 않는다.

## 5. Packages 활용

Roblox Packages는 동일 asset hierarchy를 여러 place/game에서 재사용하고 versioning/auto-update할 수 있다.

적합:

- 공용 문/상자/스폰 시스템
- 환경 prop family
- 표준 UI component
- 공용 VFX prefab
- 동일 vehicle logic
- 팀/여러 프로젝트에서 반복되는 model

주의:

- 외부 package도 malicious scripts 위험은 동일
- nested package 수정 순서 이해
- PackageLink를 임의 삭제하면 package capability 상실
- AutoUpdate는 production asset에 무조건 켜지 말고 change control 필요

## 6. Feature Packages

Roblox 공식 문서에는 common game feature용 사전 제작 Feature Package가 있다. `Creator Docs llms.txt`의 feature packages 영역을 주기적으로 확인한다.

사용 원칙:

- "공식이라서 무조건 사용"이 아님
- 해당 feature가 프로젝트 요구와 맞는지 확인
- 내부 data/store/remote 구조를 읽고 연결
- 테스트 place에서 먼저 검증

## 7. 외부 3D 에셋 소스

Roblox Creator Store 외에도 외부 DCC/asset ecosystem을 사용할 수 있지만 **각 사이트/개별 asset 라이선스가 다르다.**

우선 검토하기 좋은 범주:

- CC0/public-domain 성격의 3D/texture library
- 명시적 commercial-use 허용 pack
- 직접 Blender에서 제작/변형한 asset

사용 전 확인:

- Roblox/게임 배포 허용
- commercial use
- attribution
- redistribution 제한
- derivative work 허용
- texture/normal map까지 같은 license인지

"무료 다운로드"는 "게임에 자유롭게 재배포 가능"과 같은 뜻이 아니다.

## 8. 모델 최적화

좋은 모델도 그대로 넣으면 게임이 무거워질 수 있다.

검사:

- triangle/vertex count
- texture resolution
- material slot 수
- transparency 사용
- collisions
- shadow 필요 여부
- 반복 object 수
- StreamingEnabled 상황
- mobile GPU 부담

멀리서 작게 보이는 prop에 과도한 geometry를 쓰지 않는다.

## 9. Collision 정책

장식 mesh가 복잡한 collision을 그대로 가지면 physics cost와 플레이 감각이 나빠진다.

권장:

- 장식은 CanCollide=false + 별도 단순 invisible collider
- 큰 바위/건물은 필요한 면만 collision
- 작은 clutter는 collision 제거
- 캐릭터가 걸리는 얇은 장식 제거

## 10. 무기/캐릭터

무기는 단순 Part 조합보다 **실제 silhouette와 애니메이션 축**이 중요하다.

검사:

- grip/orientation
- R6/R15 호환
- Motor6D / attachment
- swing animation과 hitbox 정합
- 1인칭/3인칭 카메라에서 clipping
- trail attachment 위치

캐릭터/몹은 눈·장식 파트를 월드 좌표로 따로 움직이지 않는다. Model:PivotTo, Motor6D, WeldConstraint, rig attachment를 활용해 하나의 assembly/model로 관리한다.

## 11. UI asset

UI kit를 선택할 때 단순 "예쁨"보다:

- 9-slice 가능
- 다양한 aspect ratio
- icon consistency
- font legibility
- touch target
- theme tokens
- hover/pressed/disabled state

를 본다.

디자인 시스템으로 묶지 않은 UI asset pack 여러 개를 섞으면 즉시 조악해 보인다.

## 12. Plugin 정책

플러그인은 Studio 권한을 가지므로 source/reputation을 특히 확인한다.

검사:

- 제작자
- 업데이트 이력
- 필요 권한
- 외부 통신
- 자동 삽입/자동 수정 범위
- source 공개 여부

프로젝트 필수 플러그인은 `docs/DEV_SETUP.md` 또는 프로젝트 README에 기록한다.

## 13. 에셋 사용 기록 예

`ASSET_SOURCES.md`:

```md
| Asset | Source | Creator | Usage | Scripts | Modified | Verified |
|---|---|---|---|---:|---|---|
| Forest Rocks | Creator Store #... | ... | visual only | removed 2 | collisions simplified | 2026-09-03 |
```

## 14. 금지 패턴

- Free Model을 production place에 바로 삽입하고 Play
- scripts가 몇 개인지 확인하지 않음
- style이 다른 asset pack 10개를 무작정 혼합
- 모든 나무/바위를 직접 block part로 만들어 품질을 낮춤
- 고해상도/고폴리 asset을 모바일 검증 없이 대량 배치
- 외부 게임 rip asset을 "개인용이니까" 정본으로 저장
- 저작권/라이선스 없는 audio 사용

## 향후 카탈로그 확장

Godbase v2부터 실제 Creator Store 후보를 장르별로 수집한다.

```text
assets/catalogs/
├─ environment-stylized.md
├─ medieval-rpg.md
├─ sci-fi.md
├─ simulator.md
├─ ui-icons.md
├─ vfx.md
├─ audio.md
└─ plugins.md
```

각 카탈로그는 **asset ID 나열보다 검수 결과**가 핵심이다.
