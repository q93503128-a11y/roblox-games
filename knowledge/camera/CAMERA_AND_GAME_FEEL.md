# Camera and Game Feel

> verified: 2026-09-03

Official camera:
https://create.roblox.com/docs/workspace/camera

Roblox default camera는 강력한 baseline이다. custom camera는 게임이 실제로 필요할 때만 만들고, custom일수록 comfort/occlusion/input QA 책임이 커진다.

## 1. Camera is gameplay

측정할 것:
- distance
- pitch/yaw limits
- FOV
- character screen position
- target framing
- occlusion
- speed response

같은 combat code도 camera에 따라 완전히 다른 feel이 된다.

## 2. Default first

Default third-person/first-person 설정으로 fantasy가 성립하면 StarterPlayer camera settings를 활용한다.

Custom 후보:
- over shoulder shooter
- isometric
- lock-on action game
- vehicle
- cinematic
- weapon scope

## 3. Scriptable camera

Custom control은 client의 `Workspace.CurrentCamera`에서 수행.
핵심 properties:
- CFrame
- FieldOfView
- CameraType
- Focus

Scriptable camera에서 Focus update 관련 current rendering behavior를 official docs와 대조한다.

## 4. FOV

Default FOV는 current docs 기준 70이지만 프로젝트가 반드시 70일 필요는 없다.

FOV change는:
- speed perception
- motion sickness
- target size
- environment distortion
에 영향.

Sprint FOV kick는 작고 부드럽게. 매 hit마다 큰 FOV pulse 금지.

## 5. Camera smoothing

너무 느린 lerp는 input latency처럼 느껴진다.

분리:
- player orientation response: 빠름
- position smoothing: 적절히
- cinematic motion: 느릴 수 있음

Frame-rate independent spring/exp smoothing을 검토.

## 6. Occlusion

카메라가 wall 뒤로 들어갈 때:
- Roblox default occlusion mode 활용 가능
- custom raycast/cast if needed
- character/target가 완전히 가려지지 않게

좁은 실내에서 긴 third-person camera를 그대로 쓰지 않는다.

## 7. Combat lock-on

Lock-on이 필요하면:
- target eligibility
- switch target
- screen-edge behavior
- distance break
- target death
- camera collision
- mobile/gamepad switching
을 함께 설계.

Camera가 player movement를 강제로 망가뜨리지 않게 test.

## 8. Camera shake

Shake는 signal이다.

Small:
- light hit
- recoil

Medium:
- strong impact

Large:
- rare boss/environment event

Control:
- amplitude
- frequency
- duration
- translation vs rotation

Repeated combat에서 피로감 테스트.

## 9. Hitstop + camera

Hitstop/animation pause와 camera shake/impact sound를 같은 frame grammar로 조정한다.

잘못된 예:
VFX는 0ms, damage 100ms, camera 300ms 뒤 → impact가 분리됨.

## 10. Cinematic transition

Gameplay → cinematic:
- player input lock scope
- camera state save
- interruption/death/skip
- restoration

Event Sequencer 같은 official module이 적합한 경우 먼저 검토.

## 11. Device/input

Mouse:
- sensitivity
- lock center where appropriate

Touch:
- thumb drag region
- UI button conflict

Gamepad:
- stick curve/deadzone feeling
- target assist/turn speed as genre needs

## 12. Accessibility

설정 후보:
- camera shake scale/off
- motion blur/post effect controls if used
- sensitivity
- invert Y if project audience needs
- FOV range where safe

## 13. Reference measurement

레퍼런스 게임을 볼 때:
```text
FOV estimate
player height on screen
camera distance
horizontal offset
target distance
turn response
shake duration
sprint camera change
```
를 기록.

"비슷한 third-person"으로 끝내지 않는다.

## 14. Acceptance route

- [ ] open field
- [ ] near wall
- [ ] small room
- [ ] slope/stairs
- [ ] combat multiple targets
- [ ] death/respawn
- [ ] menu/cinematic transition
- [ ] touch
- [ ] gamepad if target
- [ ] sustained 10min comfort
