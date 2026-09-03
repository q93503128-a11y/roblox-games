# Animation and Rigging Pipeline

> verified: 2026-09-03

Animation은 장식이 아니라 movement/combat timing과 gameplay readability의 일부다.

## 1. Rig contract

Character/NPC마다:
- rig type
- root
- Animator ownership
- attachments
- Motor6D/bones
- weapon sockets
을 명시한다.

Asset을 바꾸더라도 gameplay code가 body part 이름에 과도하게 의존하지 않게 한다.

## 2. Animation states

기본 category:
- idle
- locomotion
- jump/fall/land
- equip/unequip
- attack anticipation/active/recovery
- hit reaction
- stun
- death
- emote/interaction

게임에 없는 상태를 억지로 만들지 않는다.

## 3. Gameplay timing sheet

Combat animation마다 time markers를 문서화한다.

```text
Attack Light 1
input 0.000
windup end 0.145
hitbox open 0.150
hitbox close 0.205
impact expected 0.170~0.220
recovery cancellable 0.330
end 0.480
```

Animation length만 보고 cooldown을 결정하지 않는다.

## 4. Animation events/markers

Marker를 활용하면:
- footstep
- swing whoosh
- hitbox activation cue
- VFX attachment
를 animation과 동기화할 수 있다.

단, critical damage authority를 client animation marker 하나에 의존시키지 않는다. Server timeline/validation과 연결한다.

## 5. Priority / blending

상태별 animation priority와 blend time을 정의한다.

문제 사례:
- idle이 attack을 덮음
- hurt reaction이 locomotion과 싸움
- equip loop가 death 후 계속

State transition에서 이전 track cleanup/fade를 확인.

## 6. Locomotion

걷기/달리기 animation speed가 실제 Humanoid/root movement와 어울려야 한다.

Foot sliding 체크:
- speed
- stride
- root motion policy

## 7. Weapon sockets

검/총/스태프 등은 임시 world CFrame offset를 여기저기 하드코딩하지 않고:
- attachment
- Motor6D/weld
- equip service
로 일관된 socket system을 만든다.

## 8. NPC model integrity

Animation/pivot 때:
- face
- horns
- weapon
- VFX emitters
- BillboardGui
가 분리되지 않음.

하위 BasePart를 독립적으로 teleport하지 않고 Model root/pivot/rig로 이동.

## 9. Additive visual feedback

공격 feel:
- animation anticipation
- trail
- whoosh
- hitstop
- target reaction
- impact sound
을 함께 조정.

좋은 animation만으로 weak hit feedback을 해결할 수 없다.

## 10. Animation reuse

Reuse가 좋은 것:
- locomotion family
- common interaction

Class/weapon identity를 만드는 hero attack은 silhouette/timing 차이를 확보한다.

## 11. Avatar variation

Player avatar를 직접 사용하는 experience는 supported rig/body/avatar variation에서 weapon/animation이 깨지지 않는지 확인한다.

Custom character를 강제하는 game이면 import/setup pipeline과 avatar restrictions를 명시.

Official avatar resources:
https://create.roblox.com/docs/avatar/resources

## 12. Performance

- NPC 수 × active tracks
- bone/rig complexity
- hidden/far animation need
을 profile.

멀리 있는 NPC에게 full cosmetic animation logic이 필요한지 server/client LOD를 고려.

## 13. Animation source

외부 animation asset:
- creator/permission
- asset ownership
- publication rights
- game group/user ownership
을 확인.

## 14. Acceptance

- [ ] idle→move→jump transition
- [ ] equip/unequip
- [ ] attack markers match hit timing
- [ ] combo transition
- [ ] hit/stun/death interrupts
- [ ] respawn cleanup
- [ ] weapon socket no drift
- [ ] enemy accessories intact
- [ ] mobile/low fps still readable

## 15. Reference analysis

레퍼런스 attack은 video frame 기준으로 가능한 한:
- anticipation duration
- active duration
- recovery
- forward movement
- arc/silhouette
- camera reaction
를 기록한다.

"애니메이션이 화려하다"가 아니라 timing grammar를 배운다.
