# Creator Store Harvester and Quarantine Pipeline

> 검증 기준일: 2026-09-04

이 문서는 Creator Store를 **검색 → 메타데이터 triage → 격리 Studio 감사 → 시각 검토 → production-fit 테스트 → S/A/B/C/Reject**로 운영하는 Godbase 표준 절차다.

## 공식 API 근거

현행 Creator Hub는 Creator Store 검색/상세조회에 다음 Open Cloud 표면을 제공한다.

- Search Creator Store Assets (Beta): `/toolbox-service/v2/assets:search`
- Get Creator Store Asset Details (Beta): `/toolbox-service/v2/assets/{id}`
- required scope: `creator-store-product:read`

공식 reference:
- https://create.roblox.com/docs/cloud/reference/features/creator-store
- https://create.roblox.com/docs/cloud/reference/scopes
- source OpenAPI: Roblox/creator-docs `content/en-us/reference/cloud/toolbox-service/v1.json`

2026-09-04 기준 live reference는 POST search를 권장하고, checked-in OpenAPI에는 GET search의 상세 query schema가 남아 있다. Godbase harvester는 이 transition을 감안해 `auto/post/get` 모드를 제공한다. API가 바뀌면 **스크립트보다 공식 문서를 우선**한다.

## 보안

API key는 절대 repository에 저장하지 않는다.

환경변수:

```text
ROBLOX_OPEN_CLOUD_API_KEY
```

권장 scope는 `creator-store-product:read`만 부여한다. 별도 업무가 없다면 write scope를 추가하지 않는다.

## 1. Metadata harvest

도구:

```text
tools/godbase/creator_store_harvest.py
```

예시:

```bash
python tools/godbase/creator_store_harvest.py search \
  --category Model \
  --query "stylized low poly nature forest" \
  --sort Ratings \
  --view Full \
  --page-size 100 \
  --pages 3 \
  --output tmp/godbase/nature-search.json
```

특정 ID 상세조회:

```bash
python tools/godbase/creator_store_harvest.py details \
  --asset-id 123 \
  --asset-id 456 \
  --output tmp/godbase/details.json
```

Harvester는 metadata만 저장하며 asset binary/source를 내려받거나 실행하지 않는다.

## 2. Metadata triage

도구:

```text
tools/godbase/creator_store_metadata_score.py
```

```bash
python tools/godbase/creator_store_metadata_score.py \
  tmp/godbase/nature-search.json \
  --output tmp/godbase/nature-triage.json
```

이 단계가 찾는 것은 **감사 우선순위**다.

예:
- backdoor/virus/malware 신고 텍스트
- 과도한 script surface
- 거대한 geometry/mesh source library
- 무관한 trending-keyword spam
- verified creator signal

중요: metadata가 깨끗해도 `productionReady=false`다. S/A 승격은 Studio audit 없이 불가능하다.

## 3. Search profiles

`knowledge/assets/CREATOR_STORE_SEARCH_PROFILES.json`은 generic queue를 제공한다.

포함 범위:
- stylized/realistic nature
- medieval/city modular environments
- weapons
- NPC/enemy rigs
- combat VFX
- UI icons
- combat/UI audio
- building/VFX Studio plugins

각 프로젝트는 이 generic profile 외에 **그 게임의 art bible/genre reference에 맞는 별도 검색어**를 반드시 추가한다.

## 4. Quarantine Studio audit

Creator Store 결과를 production place에 바로 넣지 않는다.

격리 place 순서:

1. 새 빈 Studio place 또는 버려도 되는 전용 quarantine place를 연다.
2. 후보 asset 하나만 삽입한다.
3. asset root 하나를 Selection으로 선택한다.
4. `tools/godbase/quarantine_audit.luau`를 Command Bar/통제된 MCP 실행으로 돌린다.
5. 스크립트는 실행 전에 BaseScript 단위로 disable한다.
6. JSON report를 저장한다.
7. `Source`가 읽히지 않는 항목은 clean으로 간주하지 말고 `uninspected`로 기록한다.

감사 항목:
- descendant/class histogram
- Script/LocalScript/ModuleScript 수
- numeric `require(assetId)`
- loadstring
- HttpGet / HttpService
- InsertService LoadAsset
- dynamic environment patterns
- referenced asset IDs
- MeshPart/Part/Decal/Texture/Sound/Animation/ParticleEmitter 수
- 큰 instance tree/script surface warning

문자열 패턴은 **악성 판결이 아니라 조사 신호**다. 예를 들어 HttpService 자체는 합법적인 코드에서도 쓰인다.

### Studio/MCP Output에서 JSON 추출

감사 스크립트는 아래 marker 사이에 JSON을 출력한다.

```text
GODBASE_QUARANTINE_AUDIT_BEGIN
...
GODBASE_QUARANTINE_AUDIT_END
```

Output 로그를 저장한 뒤:

```bash
python tools/godbase/extract_quarantine_report.py \
  tmp/godbase/studio-output.txt \
  --output tmp/godbase/studio-audit.json
```

이 단계는 사람이 복붙하다 JSON을 잘라먹는 오류를 줄이기 위한 것이다.

## 5. Evidence merge

Metadata triage와 Studio audit를 canonical review draft로 합친다.

```bash
python tools/godbase/merge_creator_store_audit.py \
  --asset-id 123 \
  --source-url "https://create.roblox.com/store/asset/123/example" \
  --creator "@creator" \
  --triage tmp/godbase/nature-triage.json \
  --studio-audit tmp/godbase/studio-audit.json \
  --output tmp/godbase/asset-123-review.json
```

Merge 결과의 `decision.grade`는 항상 `PENDING`에서 시작한다. 자동화가 S/A를 선언하지 않는다.

## 6. Visual audit

스크립트를 끈 상태에서 다음 스크린샷을 남긴다.

- neutral lighting hero shot
- avatar beside asset for scale
- close shot
- gameplay camera distance
- repeated-prop shot when applicable

평가:
- silhouette
- material quality
- texture integrity
- scale
- pivot
- collision
- style fit
- close/far readability
- rig/socket/animation integrity

`보기 좋음`과 `현재 게임에 맞음`은 다르다.

## 7. Production-fit test

최종 후보만 실제 프로젝트의 복사본/테스트 place에서 시험한다.

- project lighting/material
- target mobile profile
- expected repetition count
- StreamingEnabled
- NPC/pathfinding collision
- combat camera
- worst-case VFX overlap
- memory/performance profile

대형 source pack은 통째로 ship하지 않고 필요한 subset만 추출/normalize/package한다.

## 8. Canonical record

`knowledge/assets/CREATOR_STORE_QUARANTINE_AUDIT_SCHEMA.json`의 template을 따른다.

최종 grade:

```text
S / A / B / C / REJECT
```

S/A는 다음을 만족해야 한다.
- source/reuse terms 확인
- unresolved security finding 없음
- dependencies 정상
- visual/style review 통과
- production-fit test 수행
- 필요한 수정 사항 기록

## Studio MCP 목표

현행 Studio MCP는 `search_asset` 등 Creator Store/Inventory 관련 도구를 제공한다. 장기 목표는 아래를 AI가 반복하는 것이다.

```text
search_asset
→ quarantine insertion
→ scripts disabled
→ quarantine_audit.luau
→ extract_quarantine_report.py
→ metadata/studio evidence merge
→ screenshot(s)
→ visual review
→ production-fit smoke test
→ canonical audit record
```

하지만 자동화가 가능하다는 이유로 **수백 개 scripted model을 한 place에 자동 삽입하지 않는다.** batch size와 신뢰 경계를 유지한다.

## CI

Godbase CI는 다음을 검사한다.

```text
validate.py
→ Python unit tests
→ Python compileall
```

따라서 catalog/schema/path가 깨지는 문제뿐 아니라 metadata triage/report extraction/merge 로직의 기본 회귀도 막는다.

## 운영 규칙

- official Roblox asset/template/module 우선.
- marketplace rating은 discovery signal.
- 구체적인 security report가 높은 rating보다 우선.
- plugin은 runtime model보다 더 높은 Studio privilege를 가진 공급망 항목으로 취급.
- asset ID와 creator/source를 항상 기록.
- 검색 결과는 시간이 지나면 재검증.
- production asset을 바꿀 때도 기존 vertical slice visual regression을 다시 확인.
