# Security & Anti-Cheat

> 검증 기준일: 2026-09-03

공식 참고:

- Security tactics: https://create.roblox.com/docs/scripting/security/security-tactics
- Client-server boundary: https://create.roblox.com/docs/scripting/security/client-server-boundary
- Server-side detection: https://create.roblox.com/docs/scripting/security/server-side-detection
- Network ownership: https://create.roblox.com/docs/scripting/security/network-ownership
- Access control: https://create.roblox.com/docs/scripting/security/access-control
- Third-party vulnerabilities: https://create.roblox.com/docs/scripting/security/third-party-vulnerabilities
- Script capabilities: https://create.roblox.com/docs/scripting/capabilities

## 1. 핵심 원칙: Never trust the client

클라이언트는 UX와 입력 장치이지 권한 서버가 아니다.

클라이언트가 보낸 값은 사실이 아니라 **요청/주장**이다.

```text
"나는 이 아이템을 100골드에 샀다" ❌
"item_id=X 구매를 시도한다" ✅
```

서버가 가격, 소유권, 진행도, 위치, cooldown을 다시 계산한다.

## 2. 보호할 가치 상태

반드시 서버 authoritative:

- currency
- inventory/equipment ownership
- paid entitlement/reward
- progression
- drops
- trade
- crafting result
- leaderboard score
- competitive combat result
- quest completion
- daily reward

## 3. Remote validation ladder

모든 가치 있는 Remote에서:

```text
1. type
2. enum/catalog membership
3. numeric range / finite check
4. state machine validity
5. ownership/permission
6. spatial/context validity
7. cooldown
8. rate limit
9. idempotency / duplicate handling
10. authoritative result calculation
```

NaN/inf, huge strings/tables, malformed nested payload도 고려한다.

## 4. Rate limiting

Remote spam은 exploit뿐 아니라 실수/버그에서도 발생한다.

- player별
- action별
- burst + sustained rate
- expensive operation은 더 엄격

단순히 초당 1회로 고정하면 정상 고핑 환경이나 빠른 UI interaction을 망칠 수 있다. action cost와 UX에 맞춘다.

## 5. State machine 검증

예: hatch

```text
Idle → Request → Server validates cost → Roll on server → Grant → Result
```

client가 `Grant` 단계로 바로 갈 수 없어야 한다.

예: dungeon chest

- 방 클리어됨?
- 해당 chest가 이번 run에서 아직 unopened?
- player가 해당 run participant?
- reward table은 server-owned?

## 6. 구매/Developer Product

Developer Product 보상은 `ProcessReceipt` 기반으로 처리하고 **idempotent**해야 한다.

- client purchase-finished event만으로 지급 금지
- 같은 receipt가 재처리되어도 중복 보상 없음
- receipt processing 실패 시 안전하게 retry 가능
- reward 기록과 지급 순서 설계

## 7. 거래

dupe 공격의 핵심 표적이다.

필수:

- 양쪽 inventory 서버 소유
- offer versioning
- accept 후 offer 변경 시 accept reset
- 거래 중 item lock
- commit 전에 ownership 재검증
- atomic하게 이전하거나 실패 시 원상태
- disconnect/cancel cleanup
- duplicated request idempotency

client가 최종 inventory snapshot을 보내는 구조는 금지.

## 8. DataStore 보안

- client가 datastore key 선택 금지
- 저장 API를 Remote로 일반 노출 금지
- profile session locking
- schema validation
- migration
- save 실패 처리
- rollback/duplicate session 고려

## 9. Movement / speed exploit

잘못된 anti-cheat:

```text
현재 위치 - 이전 위치 > 상수 → 즉시 영구 밴
```

문제:

- lag
- teleport
- knockback
- vehicle
- server correction
- legitimate movement ability

더 좋은 방식:

- 현재 gameplay state를 알고 있음
- 가능한 movement envelope 계산
- 여러 증거/누적 suspicion
- 서버가 중요한 보상을 막거나 위치 보정
- false positive가 큰 자동 영구 제재는 신중

## 10. Combat exploit

검사:

- cooldown
- attack state
- weapon ownership
- range
- line/angle if relevant
- target alive/team
- impossible attack rate
- server-known hitbox/raycast

client는 aim/input 정보를 줄 수 있지만 damage amount와 kill reward를 결정하지 않는다.

## 11. Network ownership 위험

client-owned physics는 클라이언트가 simulation에 영향 줄 수 있음을 전제로 한다.

민감:

- vehicle competitive result
- physics projectile
- movable objective
- pickup

서버 plausibility 검증과 ownership policy를 설계한다.

## 12. Server-side detection

좋은 detector는 exploit signature 하나보다 **불가능한 게임 상태**를 찾는다.

예:

- 1초에 존재할 수 없는 재화 증가
- 잠긴 지역 item 획득
- cooldown보다 빠른 casts
- 소유하지 않은 item equip
- 같은 unique item 두 profile에 존재

탐지 후 response ladder:

```text
ignore/reject action
→ corrective state
→ log/suspicion
→ temporary restriction
→ moderation action
```

## 13. Honeypot Remote

정상 client가 절대로 호출하지 않는 Remote를 탐지 신호로 쓰는 기법이 가능하지만 단독 영구 ban 근거로 만들지 않는다. version drift와 accidental call 가능성을 관리한다.

## 14. Secret과 source visibility

- ReplicatedStorage 코드는 client-visible
- LocalScript는 client-visible
- API keys/secrets를 Luau source에 넣지 않음
- Open Cloud credentials는 GitHub Secrets/secure environment
- 서버 전용 logic은 ServerScriptService/ServerStorage

"ModuleScript니까 숨겨진다"는 가정 금지.

## 15. HttpService / 외부 API

- allowlist endpoint
- secret은 secure store/서버 side
- timeout/retry
- response validation
- 외부 서비스 장애가 game loop를 마비시키지 않음
- user-controlled URL을 그대로 fetch하지 않음

## 16. Third-party models/plugins

Creator Store 자산은 삽입 직후 스크립트 검사.

위험 신호:

- numeric remote `require`
- loadstring
- obfuscation
- 숨겨진 Script
- 이상한 service access
- Network/DataStore/AssetRequire capability

필요하면 scripts 전부 제거하고 visual만 보존.

## 17. Admin commands

Cmdr 등 admin console을 production에서 쓸 때:

- permission은 서버에서 userId/group/role로 검증
- client-side hidden UI를 보안으로 사용하지 않음
- dangerous command audit log
- arbitrary code execution command 금지 또는 강한 제한
- live economy command 이중 확인 고려

## 18. Privacy / logging

필요한 운영 로그만 수집하고 Roblox 정책과 개인정보 보호를 따른다.

- chat/private content 불필요 저장 금지
- secret/token 로그 금지
- exploit telemetry와 player-facing data 분리

## 19. 보안 코드 리뷰 질문

새 Remote마다:

```text
client가 거짓말하면 무엇을 훔칠 수 있는가?
이 요청을 1000번 보내면?
순서를 바꾸면?
두 번 보내면?
다른 player의 ID를 넣으면?
NaN/inf/huge value면?
현재 region에 실제로 없어도 요청 가능한가?
disconnect 중이면?
server 두 대에서 동시에 profile을 열면?
```

## 20. 금지 패턴

- `Remote.OnServerEvent(function(player, damage) target.Health -= damage end)`
- client-side cooldown만 존재
- local currency를 저장
- paid reward를 client purchase callback만 보고 지급
- Free Model script 무검수
- 난독화 script 허용
- "Remote 이름을 어렵게 하면 안전"
- exploit 감지 한 번으로 무조건 permanent ban
- API key를 repository에 commit

## 21. 출시 보안 체크

- [ ] 모든 Remote inventory
- [ ] value-changing Remote server validation
- [ ] rate limit
- [ ] DataStore session locking
- [ ] receipt idempotency
- [ ] trade atomicity
- [ ] third-party scripts audit
- [ ] secrets scan
- [ ] admin permission server-side
- [ ] movement/combat impossible-state tests
- [ ] 멀티클라이언트 exploit-style QA
