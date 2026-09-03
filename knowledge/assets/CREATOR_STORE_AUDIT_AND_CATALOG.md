# Creator Store Audit and Catalog Policy

> verified: 2026-09-03

Creator Store는 단순 검색창이 아니라 **프로덕션 부품 공급망**으로 취급한다. 많이 수집하는 것보다 적절한 asset을 안전하게 선별하는 것이 중요하다.

## 1. 검색 순서

새 art/system asset이 필요할 때:
1. Roblox official/template/module/feature package 확인
2. Roblox/@Roblox/CreatorKnowledge 등 공식 제작자 asset 확인
3. 검증된 creator 후보
4. 일반 Creator Store 후보
5. 외부 marketplace/GitHub는 라이선스 별도 검증
6. 직접 제작/AI generation

직접 primitive로 급조하는 것은 **blockout** 용도이며 art acceptance를 통과하지 못한다.

## 2. Catalog 필수 필드

```text
asset_id:
name:
creator:
creator_verified:
source_url:
category:
visual_style:
license_or_usage_basis:
verified_date:
script_count:
security_status:
quality_grade:
performance_grade:
mobile_grade:
recommended_for:
not_recommended_for:
modifications_required:
project_usage:
notes:
```

## 3. 품질 등급

### S
- 공식/검증 출처
- 시각 완성도 높음
- pivot/collision/scale 정상
- 성능 합리적
- project style과 바로 맞음
- script security clear

### A
좋지만 일부 수정 필요.

### B
prototype/secondary asset에는 가능. hero asset에는 보완 필요.

### C
아이디어/참고용. production import 전면 재작업 필요.

### Reject
- malware/backdoor/obfuscation
- stolen content 의심
- license/source 불명 외부 dump
- 심각한 performance problem
- broken rig/pivot/texture
- visual direction과 불일치

## 4. Import 즉시 security inspection

모든 descendant에서 검사:
- Script
- LocalScript
- ModuleScript
- `require(<number>)`
- `loadstring`
- HttpService
- InsertService
- AssetService runtime loading
- 난독화/거대한 encoded strings
- capability/permission 요구

시각 asset만 필요하면 scripts를 제거한 sanitized copy를 만든다.

Roblox official warning:
https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities

## 5. 3D visual inspection

### Model integrity
- pivot 위치
- PrimaryPart / model pivot
- rig joints
- attachments
- face/accessories가 movement 때 분리되지 않음

### Scale
Roblox avatar와 함께 viewport에서 비교한다.
- door
- weapon
- furniture
- enemy
- tree
- road/path

실제 gameplay camera에서 scale이 맞는지가 중요하다.

### Collision
- visual mesh와 collision이 과도하게 복잡하지 않은가?
- player가 작은 decoration에 걸리지 않는가?
- projectile/raycast가 이상하게 막히지 않는가?

가능하면 simple collision proxy를 사용한다.

### Materials/textures
- project palette와 맞음
- texture resolution이 hero/secondary/background 역할에 맞음
- PBR이 필요한지
- transparency overdraw가 과도한지

## 6. Performance inspection

하드 universal triangle cutoff를 만들지 않는다. 대신 target device에서 profile한다.

Catalog에는 상대 평가를 저장:
- geometry complexity
- material/texture count
- transparency
- particle/light count
- rig/bone complexity
- duplicate unique meshes/textures 여부

반복 environment asset은 reuse/instancing-friendly design을 우선한다.

## 7. Scripted kit review

Kit는 visual model보다 위험도가 높다.

질문:
- server authority인가?
- Remote validation 있는가?
- DataStore schema가 어떤가?
- global singletons/hardcoded paths가 있는가?
- game hierarchy를 강제하는가?
- update/maintenance는?
- 라이선스는?
- 삭제/교체 가능한가?

Kit 전체를 core architecture로 삼기 전에 작은 isolated place에서 실행한다.

## 8. Asset style board

프로젝트 시작 시 category마다 3~8개의 **승인 exemplar**를 정한다.

예:
```text
Environment: stylized low-poly, muted stone, saturated foliage
Weapons: broad readable silhouettes, metal + accent emissive
Enemies: simple body shapes, large readable attack parts
UI icons: filled, rounded, 2px equivalent stroke family
VFX: short, high contrast, no giant opaque particles
```

새 asset은 이 board에 맞춰 평가한다. asset마다 예쁘더라도 서로 미술 방향이 다르면 reject할 수 있다.

## 9. Creator Store search through MCP

Studio MCP에서 `search_asset` / `insert_asset`가 사용 가능한 current workflow라면:
- query를 구체적으로 작성
- 후보를 여러 개 preview
- 첫 검색 결과를 자동 채택하지 않음
- insert 후 Explorer/script audit
- viewport capture

## 10. Asset source file

프로젝트 `ASSET_SOURCES.md` 예:

```markdown
| Asset | ID/source | Creator | Use | Scripts removed | Modified |
|---|---|---|---|---|---|
| Forest rock set | ... | ... | biome A | yes | material recolor |
```

## 11. Blockout → Production 승격

Blockout asset은 명확히 tag/name을 붙인다.
- `_BLOCKOUT`
- `_PLACEHOLDER`

Vertical Slice acceptance 전에 hero-facing placeholder 0을 목표로 한다.

Gameplay prototyping에서 primitive가 필요한 것은 정상이다. **사용자에게 visual quality 평가를 받는 build까지 primitive를 그대로 가져가는 것이 문제**다.

## 12. 정기 재검수

Creator Store asset은 업데이트/삭제/권한 변경 가능성이 있다.
- source URL
- asset ID
- verified date
- local sanitized copy strategy
를 남긴다.

공식/외부 asset의 재배포 권한과 game 내 사용 권한을 혼동하지 않는다.
