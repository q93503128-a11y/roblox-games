# Creator Store Batch Search and Catalog Promotion

> 검증 기준일: 2026-09-04

이 문서는 Creator Store 공급망의 **대량 discovery**와 **감사 완료 자산의 canonical catalog 승격**을 다룬다. 자동화는 검색과 증거 정리를 빠르게 하지만, S/A 등급 자체를 자동 생성하지 않는다.

## Batch search runner

도구:

```text
tools/godbase/run_creator_store_profiles.py
```

기본 profile:

```text
knowledge/assets/CREATOR_STORE_SEARCH_PROFILES.json
```

전체 profile 실행:

```bash
python tools/godbase/run_creator_store_profiles.py
```

일부 profile만:

```bash
python tools/godbase/run_creator_store_profiles.py \
  --profile stylized-nature \
  --profile stylized-weapons
```

실제 API 호출 전 명령만 확인:

```bash
python tools/godbase/run_creator_store_profiles.py --dry-run
```

각 profile 디렉터리는 다음을 만든다.

```text
search.json
triage.json
```

batch root에는 `batch-manifest.json`을 남긴다. 따라서 어떤 profile/query가 어떤 결과를 만들었는지 재현할 수 있다.

Batch runner는 asset binary를 받지 않으며 Studio에 삽입하지 않는다. 결과는 전부 `PENDING_STUDIO` 성격이다.

## 왜 profile을 고정하는가

무작위 검색은 결과 품질과 재현성이 떨어진다. Profile은 다음을 고정한다.

- category
- query
- sort
- verified-only 여부
- page size/pages
- intended role

단, generic profile은 art direction을 대체하지 않는다. 게임마다 project-specific query를 추가해야 한다.

## Audit record 완성

Studio quarantine audit + visual review + production-fit test 후 review JSON을 완성한다.

최소 근거:
- asset ID / creator / source URL
- metadata triage
- 격리 Studio 검사
- script/dependency 상태
- pivot/collision/origin integrity
- screenshot evidence
- silhouette/material/style/scale/readability 평가
- production-fit/performance notes
- allowed use
- attribution/source record
- reviewer/reviewedAt

## Catalog promotion gate

도구:

```text
tools/godbase/promote_creator_store_asset.py
```

예:

```bash
python tools/godbase/promote_creator_store_asset.py \
  --review tmp/godbase/asset-123-review.json \
  --catalog knowledge/assets/CREATOR_STORE_SUPPLY_CATALOG.json \
  --output tmp/godbase/CREATOR_STORE_SUPPLY_CATALOG.proposed.json
```

이 도구는 canonical 파일을 직접 덮어쓰지 않는다. **proposal JSON만 만든다.** diff/review 후 별도 commit한다.

## 승격 거부 조건

다음 중 하나라도 있으면 S/A catalog promotion을 거부한다.

- grade가 `S` 또는 `A`가 아님
- creator/source/reviewer/reviewedAt 누락
- attribution/source record 누락
- metadata가 REJECT 상태
- quarantine place 증거 없음
- script disable 검사 절차 불충족
- unresolved suspicious source finding
- pivot/collision 미검증 또는 실패
- unexpected origin parts 미해결
- screenshot evidence 없음
- silhouette/material/style/scale/readability 평가 누락

### S 추가 조건

`S`는 intended production role에서 충분히 검증된 상태이므로 추가로 요구한다.

- mobile measured
- Streaming test
- expected repetition count test

### A 조건

`A`는 강한 후보지만 조건/수정이 남을 수 있다. 최소한 명시적인 production-fit/performance note가 있어야 한다.

## Canonical status

승격 결과는:

```text
AUDITED_S
AUDITED_A
```

로 들어간다.

이 상태도 영구 면허가 아니다. Roblox engine/API, asset dependency, creator terms, 프로젝트 art direction이 바뀌면 재검증할 수 있다.

## 안전 규칙

- S/A는 자동 scoring 결과가 아니라 evidence-backed review 결과다.
- Creator Store rating은 승격 근거의 일부일 뿐이다.
- 구체적 malware/backdoor finding은 rating보다 우선한다.
- source terms가 불명확하면 promotion 금지.
- 대형 pack은 pack 전체가 아니라 승인 subset을 별도 package로 관리한다.
- 기존 catalog entry가 같은 assetId를 갖는 경우 proposal은 감사된 새 entry로 교체하지만, 실제 canonical 반영 전 diff를 반드시 확인한다.
