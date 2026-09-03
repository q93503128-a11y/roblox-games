# Device and Network Test Matrix

> verified: 2026-09-03

모든 project가 모든 조합을 매 build 테스트할 필요는 없지만, 출시 범위에 포함된 device/input/network를 명시적으로 커버한다.

## Viewport/device matrix

### Small touch
- narrow phone
- touch controls
- low visual quality preset if project supports it

Check:
- thumb reach
- text
- buttons
- safe area
- camera obstruction
- effect screen coverage

### Typical phone
core mobile baseline.

### Tablet
- landscape/portrait if supported
- layout가 지나치게 넓어지지 않는지

### Laptop/720p-ish
작은 desktop viewport에서 menus가 clip되지 않는지.

### Desktop 1080p+
main PC quality check.

### Console/TV
- gamepad only
- distance readability
- focus navigation
- no tiny text

### VR
지원한다고 명시한 프로젝트만 별도 UX/comfort matrix를 만든다.

## Input matrix

| Action | Keyboard/Mouse | Touch | Gamepad |
|---|---|---|---|
| Move | required | required | required if console |
| Camera | required | required | required |
| Primary | bind | touch | bind |
| Secondary | bind | touch/context | bind |
| Interact | bind | touch/prompt | bind |
| Menu | bind | button | bind |
| Back | Esc/button | UI | B/Circle style |

Current project should prefer Input Action System where suitable.

## Multiplayer matrix

### 1 player
basic smoke.

### 2 players
- join order
- same enemy/reward
- trade/co-op if applicable
- replication

### target server size
bot/manual simulated users where possible.
- AI CPU
- remote volume
- physics
- leaderboard/UI
- spawn distribution

## Network conditions

Studio network simulation:
- baseline
- moderate latency
- high latency
- packet loss
- jitter

Test important flows:
- attack
- dodge
- vehicle
- interaction
- inventory action
- trade
- round transitions

Non-realtime purchase/save systems should survive retries/duplicate requests rather than depend on perfect network timing.

## Lifecycle matrix

- fresh join
- rejoin
- character reset
- death
- teleport/return if multi-place
- leave during combat
- leave during purchase request
- leave during trade
- server shutdown if persistence related

## Data state matrix

- new player
- returning normal player
- max/high progression
- empty inventory
- full inventory
- insufficient currency
- very large numeric values within supported range
- old save schema
- missing optional fields

## UI state matrix

- no data / empty state
- loading
- success
- server error
- disabled
- modal open
- multiple notification queue
- translated long strings
- gamepad selected state

## Combat state matrix

- attack while grounded/airborne where relevant
- spam input
- target dies during wind-up
- attacker dies
- simultaneous hits
- knockback against wall
- edge/void
- high latency
- multiple enemies
- multiple players hitting same target

## Visual matrix

- daylight/dark scene if time changes
- first-person/third-person if both supported
- camera near wall
- camera inside dense VFX
- high player count cosmetics
- avatar size/rig variations supported by game

## Regression route

각 project는 3~10분 길이의 deterministic regression route를 docs에 기록한다.

예:
```text
Spawn
→ Shop open/close
→ Starter enemy x2
→ Equip drop
→ Die/respawn
→ Buy upgrade
→ Save/rejoin
```

Studio MCP automation이 가능한 경우 이 route를 AI가 반복 수행한다.

## Severity

### S0 blocker
- place doesn't boot
- data loss/duplication
- purchase duplication
- exploit grants economy
- crash/unplayable

### S1 critical
- main loop broken
- major device cannot play
- severe replication bug

### S2 major
- important secondary system broken
- major clipping/animation failure

### S3 polish
- small visual issue
- typo/non-blocking feedback

S0/S1이 열린 상태로 content release 금지.
