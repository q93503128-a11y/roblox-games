# Loading, Memory, Streaming, and Performance Budgets

> verified: 2026-09-03

성능 최적화는 마지막에 FPS가 낮을 때 하는 청소 작업이 아니다. Roblox 공식 workflow도 **design → identify → improve → monitor** 순환을 권장한다.

Official:
- https://create.roblox.com/docs/performance-optimization
- https://create.roblox.com/docs/performance-optimization/improve
- https://create.roblox.com/docs/performance-optimization/microprofiler

## 1. 숫자 목표는 프로젝트별

Godbase는 universal triangle/FPS memory 숫자를 맹신하지 않는다.

각 프로젝트가 target device를 정하고 baseline을 기록한다.

예:
```text
Target low device: <project-defined>
Target FPS: <project-defined>
Max acceptable join-to-control time: <project-defined>
Server player count: <project-defined>
World streaming: on/off + reason
```

## 2. 측정 순서

1. Performance Summary
2. Developer Console stats
3. MicroProfiler
4. Script profiler / custom profile labels
5. device/server analytics
6. controlled A/B or before/after build

추측으로 "mesh가 문제"라고 결정하지 않는다.

## 3. Frame budget

매 frame callback에 질문:
- 진짜 every frame이어야 하는가?
- event-driven 가능한가?
- 10Hz/5Hz로 줄일 수 있는가?
- distance-based disable 가능한가?

`PreRender`, `PreSimulation`, `PostSimulation`, `Heartbeat`에 expensive code를 무분별하게 연결하지 않는다.

## 4. NPC server LOD

많은 NPC:
- nearby: full AI/combat
- medium: low-rate navigation/state
- far/no players: sleep/despawn/simplified simulation

시야 밖 AI도 모든 frame에서 pathfind/raycast하지 않는다.

## 5. Parallel Luau

CPU-heavy independent calculations를 profiler로 찾았을 때 검토한다.

도입 전:
- pure computation 분리
- Actor boundary
- thread-safe API 확인
- synchronize 구간 최소화
- serial baseline과 결과 비교

Parallel overhead가 작업보다 크면 사용하지 않는다.

## 6. Instance Streaming

큰 world에서 memory/join time에 매우 중요.

Checklist:
- critical spawn region이 빠르게 들어오는가?
- streamed-out object reference를 code가 안전하게 처리하는가?
- quest/UI는 world instance absence와 독립적인가?
- unnecessary Persistent models가 있는가?
- long-distance decorations가 gameplay logic을 들고 있지 않은가?

## 7. Asset loading

`ContentProvider:PreloadAsync()`는 반드시 시작 전에 필요한 asset에만 사용한다.

Preload 후보:
- loading screen itself
- first spawn UI
- first equip animation/sound
- immediate first encounter

Preload 금지 default:
- entire Workspace
- entire ReplicatedStorage asset library
- future biomes
- every cosmetics

join time은 retention 문제다.

## 8. Mesh/texture reuse

- 동일 visual을 unique copies로 계속 import하지 않음
- atlas/reuse 가능성 검토
- background prop에 hero-level texture 불필요
- invisible/high-frequency transparent layers 감소
- texture/material variations를 asset role에 맞춤

## 9. Part count / hierarchy

Part가 많다는 사실만으로 무조건 문제는 아니지만:
- tiny decoration pieces
- unnecessary nested folders/models
- invisible collision pieces
- duplicate effects
가 scene complexity를 늘린다.

Procedural generation 결과는 생성 후 instance count까지 검수한다.

## 10. Physics

- 움직일 필요 없는 것은 anchored
- cosmetic physics에 복잡한 constraints 남용 금지
- collision groups 사용
- Mesh collision fidelity는 필요한 만큼만
- unanchored debris lifetime 제한
- projectile pooling은 profiler로 benefit 확인 후

## 11. Particles / lights

VFX budget은 simultaneous worst-case를 본다.

테스트:
- 1 player skill
- 8 players same skill
- boss attack + players
- mobile camera close-up

particle emit rate뿐 아니라 transparency/size/screen coverage가 중요하다.

## 12. UI

- hidden ScreenGui expensive animation 중지
- viewport frames 수 제한
- repeated event connections cleanup
- reactive framework에서 unnecessary recomputation 검사

## 13. Memory lifecycle

Leak suspects:
- RBXScriptConnection
- task loops
- tables retaining player/character
- cached Instances
- UI screens recreated without destroy
- effects/debris without cleanup

Round/respawn을 20회 반복하는 soak test가 유용하다.

## 14. Server load

Max player test에서:
- AI
- remotes
- save autosave
- matchmaking/global state
- physics
- pathfinding
을 동시에 본다.

한 명 local test에서 빠른 것은 server scalability 근거가 아니다.

## 15. Network cost

- large tables frequent replication 금지
- delta/intention만 전달
- cosmetic high-frequency는 UnreliableRemoteEvent 후보
- Attributes/value objects를 high-frequency bus로 남용하지 않음
- client별 필요한 정보만 보냄

## 16. Loading UX

좋은 loading:
- 짧음
- useful progress if reliable
- skip/fallback where appropriate
- user가 언제 control을 얻는지 명확

나쁜 loading:
- fake 0→100 bar
- unnecessary asset preload
- 10초 logo cinematic before control

## 17. Performance regression gate

Vertical Slice 완료 시 baseline:
```text
build/commit:
device:
join-to-control:
avg fps:
worst frame event:
client memory:
server frame/CPU notes:
instance count notes:
```

주요 content update 후 같은 route를 다시 측정한다.

## 18. MicroProfiler discipline

frame spike를 찾으면:
1. spike frame freeze
2. label/group identify
3. script/engine cause 좁히기
4. 한 번에 한 change
5. before/after capture

`debug.profilebegin()` / `debug.profileend()`로 custom critical loops를 label하는 것도 검토한다.

## 19. Device truth

Studio desktop emulator만으로 mobile GPU/thermal/memory를 완전히 대표하지 못한다. 출시 전 가능한 경우 실제 low/mid device test를 포함한다.

## 20. Done condition

성능 문제를 "나중에 최적화" backlog로 보내기 전에 core architecture에서 이미 scale risk가 명확하면 지금 수정한다.

특히:
- whole-world non-streamed design
- every-NPC every-frame AI
- enormous client replicated catalogs/state
- unlimited effect lifetime
은 콘텐츠가 커질수록 비용이 폭증한다.
