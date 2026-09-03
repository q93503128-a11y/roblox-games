# Source Policy

> 검증 기준일: 2026-09-03

Roblox Godbase는 링크 수가 아니라 **검증 가능한 품질**을 목표로 한다. 자료를 추가할 때 아래 등급과 재사용 규칙을 적용한다.

## 신뢰도 등급

### S — 공식 정본

- Roblox Creator Documentation
- Roblox Engine API / Open Cloud API
- Roblox가 직접 소유·관리하는 공식 GitHub 저장소
- Roblox 정책/약관/Creator Hub 공지

용도: 사실 판정, API 동작, 보안/정책, 최신 플랫폼 기능의 1차 근거.

### A — 검증된 오픈소스 / 장기 실사용 자료

조건 중 다수를 만족해야 한다.

- 명확한 라이선스
- 공개 소스
- 유지보수 중이거나 안정 상태가 명확함
- 문서/테스트/릴리스 기록 존재
- Roblox 개발 커뮤니티에서 장기간 사용
- 코드가 난독화되지 않음

예: ProfileStore, RbxUtil, Promise, Fusion, Rojo, Wally, StyLua, selene, luau-lsp 등. 단, **프로젝트별 적합성 검토 후 사용**한다.

### B — 유용한 커뮤니티 지식

- DevForum의 기술 글
- 신뢰할 만한 제작자의 강의/블로그
- 오픈소스 샘플 프로젝트
- 특정 분야 전문가의 패턴/튜토리얼

용도: 구현 아이디어와 실전 팁. 공식 API 사실과 충돌하면 공식 문서를 우선한다.

### C — 탐색용 후보

- Creator Store 일반 제작자 모델
- Reddit/YouTube 댓글/커뮤니티 경험담
- 라이선스가 불명확한 코드 조각
- 오래된 튜토리얼

용도: 검색 키워드, 레퍼런스 발견. 검증 전 실제 프로젝트 코드/에셋에 넣지 않는다.

### Reject

다음은 재사용 소스로 채택하지 않는다.

- 도난 place / decompile / executor dump
- 라이선스·제작자 불명 코드
- 난독화된 스크립트
- `loadstring`, 숨겨진 외부 `require(assetId)`, 임의 AssetService/InsertService 로딩 등 출처 불명 동작
- 백도어/익스플로잇 목적 자료
- 저작권이 명백히 제한된 상용 게임 에셋을 무단 복제한 파일

연구 목적으로 존재를 알 수는 있지만, Godbase의 재사용 후보가 되지 않는다.

## 코드 재사용 체크

오픈소스 코드를 프로젝트에 넣기 전 확인한다.

1. 저장소 URL과 정확한 라이선스
2. 마지막 유지보수 시점 / archived 여부
3. 최신 Roblox API와 충돌 여부
4. 서버/클라이언트 realm
5. 외부 의존성 및 transitive dependency
6. `require(assetId)` 등 런타임 외부 로딩 여부
7. Remote/Event 경계 검증 수준
8. DataStore/거래/경제 코드라면 session locking, idempotency, retry, schema migration 고려 여부
9. API surface가 프로젝트 규모에 비해 과도하지 않은지
10. 제거/교체 가능한 구조인지

## Creator Store 에셋 체크

Roblox 공식 문서는 Creator Store 제3자 에셋에 악성 스크립트(backdoor)가 포함될 수 있음을 명시한다.

삽입 직후:

- Script / LocalScript / ModuleScript 개수 확인
- `require(<숫자>)`, `loadstring`, HttpService, InsertService, AssetService 외부 로딩 검색
- 난독화·거대한 문자열·숨긴 코드 검색
- 필요 없으면 모든 스크립트 제거 후 시각 에셋만 사용
- 가능하면 sandbox/capabilities를 최소 권한으로 설정
- DataStore, Network, AssetRequire, CapabilityControl, LoadString 계열 권한은 이유를 이해하지 못하면 허용하지 않음
- 프로젝트 `ASSET_SOURCES.md`에 asset ID, creator, 사용 범위, 수정 사항 기록

공식 참고: https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities

## 라이선스 기록

Godbase 카탈로그에는 최소한 다음 필드를 남긴다.

```text
name:
source:
creator:
license:
verified_date:
maintenance_status:
category:
recommended_for:
not_recommended_for:
security_notes:
replacement:
```

Creator Store의 "사용 가능"과 외부 GitHub 코드의 오픈소스 라이선스는 같은 개념이 아니다. 외부 자료는 각 라이선스 조건을 따르고, 재배포 여부와 게임 내 사용 여부를 구분한다.

## 오래된 자료 처리

오래됐다는 이유만으로 삭제하지 않는다. 대신:

- `CURRENT` — 현재 권장
- `USE_WITH_CAUTION` — 조건부 권장
- `LEGACY` — 기존 프로젝트 유지용
- `DEPRECATED` — 새 프로젝트 금지, 대체재 명시
- `ARCHIVED` — 역사/마이그레이션 참고용

예: Roblox `Roact` 저장소는 deprecated/archived이며 새 프로젝트에는 `react-lua` 등 현재 대체재를 검토한다.

## 강의/팁 검증 규칙

강의에서 본 패턴은 다음 순서로 검증한다.

1. 현재 공식 API 문서와 대조
2. Studio에서 최소 재현
3. 보안 경계 확인
4. 모바일/콘솔 입력 여부 확인
5. 성능/메모리 영향 확인
6. 실제 프로젝트 적용 전 작은 vertical slice에서 테스트

"영상에서 돌아갔다"는 이유만으로 정본 패턴으로 승격하지 않는다.
