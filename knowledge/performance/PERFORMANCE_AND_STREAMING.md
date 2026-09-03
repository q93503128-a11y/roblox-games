# Performance & Streaming

> 검증 기준일: 2026-09-03

공식 참고:

- Performance optimization: https://create.roblox.com/docs/performance-optimization
- Design for performance: https://create.roblox.com/docs/performance-optimization/design
- Test on hardware: https://create.roblox.com/docs/performance-optimization/test-on-hardware
- Identify issues: https://create.roblox.com/docs/performance-optimization/identify
- MicroProfiler: https://create.roblox.com/docs/performance-optimization/microprofiler
- Scene Analysis: https://create.roblox.com/docs/performance-optimization/scene-analysis
- Improve performance: https://create.roblox.com/docs/performance-optimization/improve
- Monitor performance: https://create.roblox.com/docs/performance-optimization/monitor
- Streaming: https://create.roblox.com/docs/workspace/streaming
- SLIM: https://create.roblox.com/docs/workspace/streaming/slim

## 1. 최적화는 추측이 아니라 측정

순서:

```text
증상 확인
→ profiler/metrics로 병목 위치 확인
→ 한 원인 수정
→ 같은 조건 재측정
```

"파트가 많아 보여서 줄였다" 같은 감각 최적화보다 실제 CPU/GPU/memory/network 병목을 먼저 찾는다.

## 2. 예산 사고

프로젝트마다 최소 target을 정한다.

- low-end mobile을 지원하는가
- 목표 FPS
- 최대 player count
- 월드 크기
- 동시 NPC/projectile 수
- UI/VFX density
- memory target

높은 사양 PC에서만 정상이라는 것은 Roblox production 품질 기준으로 충분하지 않다.

## 3. Studio와 실제 기기

Studio 테스트만으로 끝내지 않는다.

- Device Emulator
- 실제 low/mid mobile
- desktop
- controller/console 대상이면 해당 환경

공식 문서도 target hardware에서 테스트하라고 강조한다.

## 4. CPU 병목

흔한 원인:

- 매 프레임 대규모 loops
- Workspace:GetDescendants 반복
- 대량 raycast/spatial query
- NPC pathfinding 남발
- UI layout/thrash
- 너무 많은 event connections
- 매 frame table/string allocation
- 잘못된 polling

대응:

- event-driven
- cache
- update frequency 낮추기
- spatial partitioning/tag
- inactive entity sleep
- work batching
- 필요 시 Parallel Luau 검토

## 5. RunService 예산

Heartbeat/RenderStepped/PreSimulation 연결은 기능마다 쉽게 늘어난다.

질문:

- 정말 매 프레임인가?
- 10Hz/5Hz로도 되는가?
- 이벤트로 바꿀 수 있는가?
- 화면에 보이는 entity만 update 가능한가?

RenderStepped는 주로 camera/로컬 presentation처럼 render 직전이 필요한 작업에 제한.

## 6. GPU 병목

흔한 원인:

- 너무 많은 geometry
- 큰 투명 object 중첩
- particle overdraw
- shadow-heavy lights
- 고해상도 texture
- 복잡한 SurfaceAppearance
- 화면을 가득 채우는 VFX

특히 transparency는 모바일에서 비쌀 수 있다. 큰 반투명 layer 여러 장을 겹치지 않는다.

## 7. Instance count

Instance가 많다고 무조건 느린 것은 아니지만 replication/memory/iteration 비용이 커진다.

- 장식용 수천 ValueObject 금지
- 반복 설정은 attributes/data table 검토
- 작은 visual detail을 무조건 Part로 분해하지 않음
- MeshPart/modular asset으로 적절히 통합

## 8. Physics

비용 높은 패턴:

- 불필요한 unanchored parts
- 복잡한 collisions
- 많은 constraints
- 장식 object도 모두 collision
- 대량 moving assemblies

환경 장식은 가능하면 anchored. collision shape를 단순화하고 decorative clutter는 CanCollide=false.

## 9. NPC

대량 NPC는 다음을 분리한다.

```text
perception
decision
pathfinding
movement
animation
combat
presentation
```

모든 NPC가 매 frame 모든 플레이어와 거리 계산하지 않도록 한다.

- coarse update
- target acquisition 주기 제한
- spatial filtering
- active range
- path recompute 제한
- dead/inactive disconnect cleanup

## 10. Pathfinding

경로를 매 frame 다시 계산하지 않는다.

재계산 조건 예:

- target이 의미 있는 거리 이동
- path blocked
- 일정 timeout
- 상태 전환

많은 NPC가 같은 목적지라면 공유 가능한 정보도 검토.

## 11. VFX pooling

매 타격마다 Part/Attachment/Emitter를 새로 생성·파괴하면 allocation/GC spike가 생길 수 있다.

고빈도 effect는 object pool을 검토하되, pooling 자체가 복잡도를 키우는 저빈도 effect에는 불필요.

## 12. Memory

검사:

- texture/audio assets
- leaked connections
- tables retaining player references
- unequipped/destroyed UI leftovers
- cloned models not destroyed
- event connections cleanup

Trove 같은 cleanup utility가 도움이 될 수 있다.

PlayerRemoving/character lifecycle에서 참조를 해제한다.

## 13. Network

고빈도 Remote 남발 금지.

- 매 frame exact CFrame를 reliable RemoteEvent로 보낼 필요가 있는가
- Roblox replication이 이미 제공하는 정보인가
- quantization/interpolation 가능한가
- UnreliableRemoteEvent가 적합한 presentation data인가
- payload가 불필요하게 큰가

중요 state는 reliability, ephemeral presentation은 bandwidth를 고려.

## 14. DataStore performance

DataStore는 frame-loop 저장소가 아니다.

- 값 하나 바뀔 때마다 SetAsync 금지
- session state는 서버 memory에서 유지
- autosave interval + leave/save lifecycle
- UpdateAsync/locking/queue/retry 패턴
- request budget 고려

ProfileStore 같은 검증된 persistence layer를 우선 검토.

## 15. StreamingEnabled

큰 월드/메모리 제약에서 중요.

장점:

- client memory 감소
- join/load 개선 가능
- 큰 place 지원

설계 영향:

- client에 모든 Workspace instance가 없음
- 멀리 있는 target reference가 사라질 수 있음
- LocalScript world search가 불완전
- teleport/spawn 전 region 준비 고려

## 16. Streaming architecture

권장:

- server state는 world streaming과 독립
- UI objective는 instance가 stream out되어도 논리 상태를 유지
- marker는 streamed object 존재 여부에 대응
- 중요한 spawn/interior는 필요 시 streaming APIs로 준비
- 거대한 world 전체를 ReplicatedStorage에 복사해 streaming 이점을 상쇄하지 않음

## 17. SLIM

Roblox의 Server/Lightweight Instance Management 관련 최신 공식 문서를 확인해 매우 큰 월드/서버 메모리 문제에서 검토한다. 플랫폼 기능은 변할 수 있으므로 도입 시점에 최신 지원 범위를 다시 읽는다.

## 18. MicroProfiler 사용 사고

- spike가 발생하는 정확한 frame 찾기
- CPU lane에서 긴 task 확인
- script label/engine subsystem 확인
- 동일 재현 조건에서 비교

한 번 캡처해서 숫자를 보고 끝내지 말고 gameplay scenario별로 본다.

## 19. Script Profiler

스크립트별 실행 비용을 확인해 hot path를 찾는다.

특히:

- frame callbacks
- NPC loops
- expensive table processing
- serialization

## 20. Scene Analysis

Studio의 Scene Analysis와 관련 도구로 과도한 scene complexity 후보를 확인한다. 자동 경고를 절대 법칙으로 보지 말고 실제 rendering/gameplay 맥락과 함께 판단.

## 21. 로딩 경험

최적화는 평균 FPS만이 아니다.

- first interactive time
- spawn 후 world 준비
- UI가 먼저 뜨고 player가 void에 떨어지는 문제
- asset preload 필요 여부
- loading screen이 실제 loading state와 정합

게임 world/persistence startup 순서를 명시한다.

권장 예:

```text
server bootstrap
→ 필수 world/spawn 준비
→ player session/profile 준비
→ character spawn/enable
→ UI ready
```

## 22. 최적화 금지 패턴

- 모든 것을 local script로 옮기면 빠르다고 생각
- visible하지 않은 UI도 무한 update
- 대규모 polling
- 매 공격 new task.spawn 수십 개
- random wait로 race condition을 숨김
- 장식용 physics part 수천 개
- streaming을 켜고 client code는 full world를 가정
- profiler 없이 architecture를 갈아엎음

## 23. Release performance checklist

- [ ] target mobile 실제 테스트
- [ ] 10~20분 memory 증가 확인
- [ ] 전투 최대 밀도 FPS 확인
- [ ] VFX 최대 동시 상황 확인
- [ ] player count가 늘었을 때 server script time 확인
- [ ] Remote traffic 확인
- [ ] Streaming 지역 이동/teleport 확인
- [ ] join/spawn 시간 확인
- [ ] Studio Output warning/error 없음
- [ ] MicroProfiler 또는 Script Profiler로 알려진 spike 확인
