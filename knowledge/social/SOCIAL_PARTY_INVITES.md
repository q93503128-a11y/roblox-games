# Social, Friends, Parties, Invites, and Co-Play

> verified: 2026-09-03

Official:
- Developer Modules: https://create.roblox.com/docs/resources/modules
- Player invite prompts: https://create.roblox.com/docs/production/promotion/invite-prompts
- SocialService: https://create.roblox.com/docs/reference/engine/classes/SocialService
- Spawn With Friends: https://create.roblox.com/docs/resources/modules/spawn-with-friends

## 1. Social feature should support the fantasy

Don't add invite buttons solely to manipulate growth metrics.
Useful social loops:
- party adventure
- shared boss
- building/showcase
- trading where appropriate
- team challenge
- social hub
- friend spawn

## 2. Official modules first

Before custom implementation inspect:
- Friends Locator
- Spawn With Friends
- Profile Card
- Emote Bar
- Social Interactions

They are current Roblox official starting points, not mandatory architecture.

## 3. Invite prompts

Current flow:
1. client checks `SocialService:CanSendGameInviteAsync()` in `pcall`
2. if allowed, `PromptGameInvite()`
3. ExperienceInviteOptions can customize prompt/invite message and LaunchData

Invite capability can vary by user/platform; failure is normal.

## 4. LaunchData

Invite LaunchData can route/personalize join context.
Treat it as untrusted/transient context.

Good:
- intended area/party referral id
- invite campaign/context token

Bad:
- gold reward amount
- permanent ownership proof

Server resolves trusted state from IDs.

## 5. Party server state

Party definition:
```text
partyId
leaderUserId
memberUserIds
invite/ready state
activity target
version
```

Server owns membership/readiness.
Client cannot add arbitrary user ID to party state.

## 6. Invite state machine

```text
invited
→ accepted/declined/expired
→ membership added server-side
```

Invite has TTL and spam controls.

## 7. Leader behavior

Define:
- transfer if leader leaves
- kick permissions
- matchmaking start permission
- activity selection
- dissolution

Avoid party becoming stuck when leader disconnects.

## 8. Cross-server party

If party persists across servers, needs cross-server ephemeral coordination and durable-enough identity. MemoryStore/MessagingService may participate depending architecture.

Don't build cross-server party before same-server party is correct unless core product requires it.

## 9. Matchmaking integration

Party enters queue as one unit where game promises co-play.
Atomic enqueue and partial teleport handling from matchmaking docs apply.

## 10. Friend spawn

Official Spawn With Friends verifies enough free space before moving player near a friend. This illustrates an important rule: social teleport/spawn needs geometry safety, not just `PivotTo(friend.CFrame)`.

## 11. Co-play rewards

If giving party/friend bonus:
- server verifies relationship/context using supported platform/game state
- avoid exploitable client friend claims
- cap/define stacking

Reward should support social fun rather than require alt-account farming.

## 12. Social UI

Show:
- party members
- leader
- ready/status
- current activity
- invite/kick/leave

Gamepad/mobile support.

Do not spam full-screen invite prompts automatically every session.

## 13. Presence/friend location

Use platform-supported APIs/modules where possible. Respect privacy/availability; not every friend/presence detail is necessarily available.

## 14. Voice/chat

Use Roblox platform communication systems and current eligibility/moderation behavior. Don't bypass platform safety with custom raw external chat.

## 15. Social analytics

Useful product metrics:
- party formed
- invited friend joined
- party activity completed
- solo vs co-play retention

Do not collect unnecessary friend graph/personal data externally.

## 16. Griefing

Social/co-op mechanics need:
- loot ownership policy
- friendly fire
- kick/host abuse protection
- shared objective grief prevention
- AFK behavior

## 17. Acceptance

- [ ] social feature tied to game value
- [ ] official modules inspected
- [ ] invite capability failures handled
- [ ] LaunchData not authority
- [ ] server-owned party state
- [ ] leader leave behavior
- [ ] spam/rate limits
- [ ] geometry-safe friend spawn/teleport
- [ ] cross-platform party UI
- [ ] grief cases tested
