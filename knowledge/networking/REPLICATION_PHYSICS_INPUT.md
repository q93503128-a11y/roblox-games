# Replication, Physics, Networking, and Input

> verified: 2026-09-03

이 문서는 Roblox의 client/server replication, physics ownership, Remote 설계, 입력을 하나의 gameplay boundary로 본다.

## 1. Mental model

Roblox multiplayer는 단순히 "서버 script + client script"가 아니다.

설계 질문:
- 이 state는 누가 생성하는가?
- 누가 수정 권한을 가지는가?
- 누구에게 replicate되어야 하는가?
- 지연이 있을 때 client가 예측해도 되는가?
- stream out되면 어떻게 되는가?
- exploit client가 임의 값을 보내면 server는 무엇을 검증하는가?

## 2. RemoteEvent vs RemoteFunction

### RemoteEvent
fire-and-forget request/notification.
Use for:
- input intent
- UI request
- state notification

### RemoteFunction
synchronous request/response semantics가 꼭 필요할 때만.
주의:
- client/server yield chain
- timeout/leave/error path
- server → client invoke는 신뢰/응답 지연 문제

대부분의 gameplay action은 RemoteEvent + server-owned state가 더 안전하고 단순하다.

## 3. Payload design

좋은 request는 최소 정보만 보낸다.

```text
Attack { attackId, aimDirection }
Interact { targetId }
Purchase { itemId }
Equip { inventoryItemId }
```

서버가 계산:
- damage
- price
- reward
- ownership
- cooldown
- valid range
- progression requirement

## 4. Validation layers

Remote마다 가능한 범위에서:
1. type validation
2. finite number / sane range
3. string/table size
4. instance class / ancestry
5. ownership
6. current player state
7. spatial distance / LOS
8. cooldown/rate limit
9. progression/unlock
10. duplicate/idempotency

`typeof()` 검사 하나로 security validation이 끝나지 않는다.

Official: https://create.roblox.com/docs/scripting/security/client-server-boundary

## 5. Rate limiting

한 global limit보다 action별 budget이 낫다.

예:
- basic movement intent: high frequency
- purchase: low frequency
- trade accept: low frequency
- cosmetic aim: UnreliableRemoteEvent 후보

서버가 너무 많이 들어온 request를 drop/reject하고 관찰 가능한 metric을 남긴다.

## 6. UnreliableRemoteEvent

loss가 허용되는 transient/cosmetic high-frequency state에만 검토.

좋은 후보:
- cursor/aim cosmetic
- frequent noncritical transform hint
- temporary VFX signal

금지:
- inventory
- reward
- purchase
- authoritative hit
- quest completion

## 7. Physics/network ownership

Traditional automatic authority에서는 client가 일부 unanchored physics ownership을 가질 수 있다. client는 해당 physics를 조작할 수 있다고 가정한다.

취약한 설계 예:
- `Touched`만으로 rare reward 지급
- client-owned projectile position만 믿고 damage
- unanchored object proximity만 믿고 purchase/interact

대응:
- server state + independent checks
- manual network ownership when needed
- server authority model 검토
- suspicious movement를 reversible하게 neutralize

Official: https://create.roblox.com/docs/scripting/security/network-ownership

## 8. Server Authority current model

`Workspace.AuthorityMode = Server`는 current engine server-authoritative simulation + client prediction/rollback path다.

Official:
- https://create.roblox.com/docs/projects/server-authority
- https://create.roblox.com/docs/reference/engine/enums/AuthorityMode

도입할 때:
- required workspace settings 확인
- beta/rollout status 확인
- resimulation-safe side effects 설계
- gameplay + visual prediction 분리
- network simulation test

## 9. Prediction philosophy

Client prediction은 UX 개선이지 authoritative truth가 아니다.

예:
- client 즉시 sword swing animation/VFX
- server가 cooldown/hit/damage 최종 판정
- server 결과와 client prediction 불일치 시 reconciliation

"서버 판정이니까 모든 client feedback을 round-trip 뒤에 보여준다"도 나쁜 UX가 될 수 있다.

## 10. Streaming-aware code

StreamingEnabled에서는 client가 멀리 있는 object를 항상 가지고 있지 않다.

금지 가정:
- `workspace.Map.Zone.Boss`가 client에 항상 존재
- long-lived cached Instance가 절대 stream out되지 않음

대안:
- tags/attributes + stream lifecycle
- server source of truth
- client find/wait with timeout where appropriate
- UI state와 world Instance lifetime 분리

## 11. Input Action System

Official: https://create.roblox.com/docs/input/input-action-system

Gameplay action을 hardware key와 분리한다.

권장 action 이름:
- Move
- Jump
- PrimaryAttack
- SecondaryAttack
- Dodge
- Interact
- Ability1...
- Inventory

binding은 keyboard/gamepad/touch마다 다를 수 있다.

장점:
- control remap/context
- device hint 표시
- mode별 action swap
- input code 흩어짐 감소

## 12. Preferred input / UI hints

사용자가 keyboard에서 gamepad/touch로 바꿀 수 있다고 가정한다.
- 현재 preferred binding에 맞게 prompt 갱신
- "Press E"를 texture/text로 영구 하드코딩 금지
- mobile 버튼과 gamepad focus path를 별도 검증

## 13. Combat network checklist

- [ ] input intent가 client → server
- [ ] attack definition은 trusted catalog
- [ ] cooldown server check
- [ ] weapon ownership server check
- [ ] hit timing tolerance 정의
- [ ] range sanity check
- [ ] raycast/overlap 권위 위치 정의
- [ ] lag tolerance가 exploit window가 되지 않게 제한
- [ ] damage/reward server-only
- [ ] client VFX는 predicted 가능
- [ ] duplicate hit id 방지

## 14. Network test matrix

최소:
- normal local Studio
- multi-client test
- latency
- packet loss
- jitter
- player leave mid-action
- character respawn
- stream in/out
- server shutdown/rejoin if persistence related

Studio testing modes:
https://create.roblox.com/docs/studio/testing-modes

## 15. Observability

Remote abuse와 networking bug를 구분하기 위해:
- remote name
- reject reason
- frequency bucket
- server id
- anonymized/user id where policy allows
- latency category
를 debug/analytics strategy에 넣는다.

Production에서 모든 request를 무제한 로그하지 말고 sampling/rate limiting한다.
