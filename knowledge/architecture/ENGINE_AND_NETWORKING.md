# Engine & Networking Mental Model

> 검증 기준일: 2026-09-03

Roblox 코드를 잘 짜기 전에 **데이터모델 + 클라이언트/서버 + 물리 소유권 + 복제 범위**를 정확히 이해해야 한다.

공식 참고:

- Client/server: https://create.roblox.com/docs/projects/client-server
- Remote events/functions: https://create.roblox.com/docs/scripting/events/remote
- Server authority: https://create.roblox.com/docs/projects/server-authority
- Network ownership: https://create.roblox.com/docs/physics/network-ownership
- Streaming: https://create.roblox.com/docs/workspace/streaming
- Script locations: https://create.roblox.com/docs/scripting/locations

## 1. 기본 모델

Roblox 경험은 기본적으로 멀티플레이어다.

```text
Client A  ─┐
Client B  ─┼── Server ── persistent/cloud services
Client C  ─┘
```

클라이언트는:

- 화면/UI
- 로컬 입력
- 카메라
- 시각 효과
- 예측 가능한 presentation

을 담당하기 좋다.

서버는:

- 재화
- 보상
- 인벤토리 소유권
- 진행도
- 거래
- 중요한 전투 판정
- 스폰/웨이브/매치 상태
- 저장

을 최종 판정해야 한다.

## 2. 데이터모델 위치와 의미

### ServerScriptService

서버 전용 로직. 클라이언트에 복제되지 않아야 하는 보안/비밀/권한 코드를 둔다.

### ServerStorage

서버 전용 Instance/템플릿. 클라이언트가 볼 필요 없는 적 원본, 민감한 데이터, 서버 전용 에셋에 적합.

### ReplicatedStorage

서버와 클라이언트 모두 접근하는 공유 영역.

적합:

- RemoteEvent / RemoteFunction
- 공유 타입/상수
- 클라이언트도 필요한 카탈로그
- 공용 모듈

주의: **여기 놓인 ModuleScript는 클라이언트가 볼 수 있다.** 비밀 로직을 숨기는 장소가 아니다.

### StarterPlayerScripts / StarterCharacterScripts

플레이어 로컬 동작, 입력, 카메라, presentation.

### StarterGui

초기 GUI 템플릿. 런타임 실제 화면은 PlayerGui에서 동작.

### Workspace

3D 월드. StreamingEnabled를 쓰면 클라이언트에 항상 전체 Workspace가 존재한다고 가정하면 안 된다.

## 3. Remote 설계

### RemoteEvent

일방향 비동기 메시지.

대표 패턴:

```text
client: "이 행동을 시도했다"
server: 검증 후 상태 변경
server: 필요한 결과를 client(s)에 통보
```

### RemoteFunction

요청자가 응답까지 yield하는 양방향 호출.

주의:

- 클라이언트 → 서버 질의에는 신중히 사용 가능
- 서버가 클라이언트 응답을 기다리는 구조는 클라이언트 지연/중단에 영향을 받기 쉬우므로 가능하면 피한다
- 지속적/고빈도 상태 동기화에는 부적합

### UnreliableRemoteEvent

지속적으로 바뀌지만 유실되어도 치명적이지 않은 데이터에 유용.

예:

- 보간 가능한 순간 presentation 정보
- 일부 실시간 이펙트/방향/시각 상태

재화·인벤토리·구매 결과처럼 반드시 전달되어야 하는 상태에는 사용하지 않는다.

## 4. 서버 검증 체크

클라이언트 요청 하나에 최소 다음을 생각한다.

```text
타입 → 범위 → 권한 → 소유권 → 현재 상태 → 거리/맥락 → cooldown → rate limit → 중복/재전송
```

예: `BuyItem(itemId)`

서버가 확인할 것:

- itemId가 string인가
- 허용된 카탈로그 key인가
- 판매 가능한 상품인가
- 플레이어가 현재 vendor를 사용할 수 있는 상태인가
- 가격은 서버 카탈로그에서 읽었는가
- 돈이 충분한가
- 이미 소유 불가능한 중복 아이템인가
- 요청 rate가 정상인가
- 차감과 지급이 하나의 서버 트랜잭션처럼 처리되는가

클라이언트가 `price`, `reward`, `newBalance`를 보내서 서버가 믿는 구조는 금지.

## 5. 전투 네트워크 기본

전투는 반응성과 공정성 사이의 절충이다.

### 서버만 모든 것을 계산

장점:

- 단순하고 권한 명확

단점:

- 입력 지연이 그대로 체감될 수 있음

### 클라이언트 presentation + 서버 authoritative 결과

권장 기본.

```text
입력
→ 클라이언트 즉시 애니메이션/VFX 시작
→ 서버에 attack intent
→ 서버가 상태/쿨다운/거리/히트 조건 검증
→ authoritative damage
→ 결과 복제
```

피격 숫자나 swing animation은 즉시 보여줄 수 있지만 **실제 HP 감소/보상은 서버 결과**를 따른다.

### 중요한 PvP / 물리 전투

Roblox의 Server Authority Model과 network ownership 관련 최신 공식 문서를 우선 조사한다. 수동 anti-cheat를 덧대기 전에 엔진이 제공하는 권한 모델을 이해한다.

## 6. Network ownership

Roblox 물리 assembly는 네트워크 소유권에 따라 어떤 머신이 시뮬레이션을 주도하는지가 달라질 수 있다.

위험:

- 플레이어가 물리 객체를 소유할 때 로컬 물리 상태를 조작할 가능성
- 서버가 클라이언트 물리 결과를 무조건 신뢰하면 이동/투사체/차량 exploit에 취약

대응:

- 민감한 물리 객체의 ownership 정책 명확화
- 중요한 결과는 서버에서 plausibility 검증
- 이동/속도/거리/시간 기반 검증 시 정상 네트워크 지연을 고려
- 단순히 "클라이언트 위치가 다르면 ban" 같은 취약한 규칙 금지

## 7. StreamingEnabled

큰 월드에서는 streaming을 적극 고려한다.

하지만 코드가 다음을 가정하면 깨진다.

- 특정 Workspace descendant가 클라이언트에 항상 존재
- 멀리 있는 NPC/파트를 LocalScript에서 즉시 찾을 수 있음
- `WaitForChild()`가 언젠가 무조건 돌아옴

대응:

- gameplay truth는 서버에 유지
- 클라이언트는 현재 streamed state를 고려
- streaming-aware API/pattern 사용
- 중요 persistent reference를 무한 WaitForChild로 해결하지 않음
- 맵을 "전부 클라이언트에 있음" 전제로 UI marker 시스템을 만들지 않음

## 8. 태그 / 컴포넌트

반복되는 world object는 이름 문자열 탐색보다 `CollectionService` tag와 컴포넌트 패턴이 관리하기 쉽다.

예:

```text
Interactable
EnemySpawner
LootChest
DamageZone
QuestNPC
```

각 인스턴스의 attributes는 설정값에 적합하지만, 중요한 권한 상태를 클라이언트가 바꿀 수 있는 복제 객체 하나에 의존하지 않는다.

## 9. 이벤트 기반 설계

Roblox는 이벤트 기반 엔진이다. 필요하지 않은 매 프레임 polling을 피한다.

나쁜 예:

```text
Heartbeat마다 Workspace 전체 GetDescendants → 목표 검색
```

더 나은 예:

- tag add/remove event
- property changed signal
- player/character lifecycle event
- timer / scheduler
- 공간 쿼리를 필요한 시점에만 수행

RunService frame loop는 카메라, presentation, 물리 보정처럼 정말 매 프레임 필요한 작업에 쓴다.

## 10. 서비스 경계 권장

중형 이상 프로젝트 예:

```text
Server
├─ ProfileService/DataService
├─ InventoryService
├─ EconomyService
├─ CombatService
├─ EnemyService
├─ QuestService
├─ MatchService
└─ MonetizationService

Client
├─ InputController
├─ CameraController
├─ UIController
├─ CombatPresentation
└─ Audio/VFX controllers

Shared
├─ Types
├─ Catalogs
├─ Constants
└─ pure utilities
```

서비스를 많이 만드는 것이 목적은 아니다. **상태 소유권이 명확해야 한다.**

## 11. 피해야 할 구조

- LocalScript가 Gold를 직접 증가
- client가 damage amount를 서버에 제출
- client가 "enemy died"를 보상 근거로 제출
- Remote 하나에 `actionName` 문자열 50개를 몰아넣고 검증 없음
- Workspace.ValueObject를 전체 데이터베이스처럼 사용
- 모든 ModuleScript를 ReplicatedStorage에 넣어서 서버 비밀까지 노출
- 서버가 매 입력마다 RemoteFunction으로 client를 기다림
- 하나의 5,000줄 Manager Script가 저장/전투/UI/몹/상점을 모두 관리

## 설계 질문

새 기능마다 먼저 답한다.

1. 이 상태의 최종 owner는 서버인가 client인가?
2. 다른 client가 알아야 하는가?
3. 지속 저장되는가?
4. exploit으로 변조되면 가치 손상이 있는가?
5. streaming으로 해당 Instance가 없을 수 있는가?
6. 이벤트로 처리 가능한가, 정말 frame loop가 필요한가?
7. 네트워크 메시지가 유실되거나 중복되면 어떻게 되는가?
