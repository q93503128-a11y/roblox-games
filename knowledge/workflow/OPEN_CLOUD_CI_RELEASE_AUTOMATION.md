# Open Cloud, CI, and Release Automation

> verified: 2026-09-03

Official:
- Open Cloud: https://create.roblox.com/docs/cloud
- Place publishing guide: https://create.roblox.com/docs/cloud/guides/usage-place-publishing

## 1. Principle

자동화는 live game에 더 빨리 bug를 넣는 도구가 아니다.

기본 pipeline:
```text
commit
→ static checks
→ build
→ automated tests
→ TEST/STAGING publish
→ Studio/integration playtest
→ approval/gate
→ PRODUCTION publish
→ post-release monitoring
```

## 2. Separate TEST and LIVE

가능하면:
- TEST experience/place
- PRODUCTION experience/place
를 분리한다.

At minimum:
- DataStore namespace
- product IDs
- Open Cloud credentials
- analytics tagging
환경을 구분.

## 3. Open Cloud credentials

- GitHub Secrets / secure secret manager only
- least privilege
- universe/place scope 최소화
- write permission 필요한 workflow만
- key rotation
- never echo in logs

## 4. Place Publishing API

Official current guide says existing place versions can be updated through API and can be called from CI such as GitHub Actions.

Current limitations matter: certain instance types may not be updated correctly/at all through this publishing path (official guide lists types such as EditableImage, EditableMesh, PartOperation, SurfaceAppearance, BaseWrap at verification date). Those projects must verify Studio publish requirements.

Do not assume CI publishing supports every future instance type.

## 5. Build artifact

Rojo project:
- deterministic `rojo build` artifact

Studio-first project:
- define how binary place/source reaches CI
- Script Sync code CI may run independently of place publish
- Studio MCP/test harness can perform local/integration QA

Do not invent a headless pipeline if Studio-authored assets are not reproducibly available.

## 6. Static checks

Suggested:
- StyLua check
- selene
- Luau tests
- catalog validation
- duplicate ID detection
- JSON schema
- forbidden secrets
- forbidden external require patterns according to project policy
- asset source manifest completeness

## 7. Project-specific validators

Examples RPG:
- item IDs unique
- loot table weights valid
- upgrade graph no dead ends
- enemy references exist

Simulator:
- costs monotonic sanity
- rebirth formula finite
- product reward definitions

Tycoon:
- purchase dependency DAG
- no unreachable purchase

## 8. Test publish

CI first publish target must be TEST.

Then automated/manual Studio QA:
- boot
- output
- primary loop
- data test namespace
- network test

## 9. Production approval

작은 solo project에서도 production publish는 명시적 step으로 둔다.

Approval checklist references:
`knowledge/checklists/SHIP_CHECKLIST.md`.

## 10. Rollback

항상 기록:
- last known good version
- source commit
- place version
- data schema compatibility

Code rollback이 data migration을 자동 rollback한다는 가정 금지.

## 11. Multi-place experiences

Place마다:
- Place ID
- role
- publish artifact/path
- teleport dependency
를 manifest에 기록.

한 place publish만 성공하고 다른 place가 old schema이면 version mismatch가 날 수 있다.

## 12. Deploy ordering

Cross-place/server API schema 변경:
- backward compatible server first
- client/other place update
- old compatibility cleanup later

가능하면 one-shot breaking rollout을 피한다.

## 13. Server restart / rollout

Roblox servers는 update 순간 모두 즉시 동일 version이 되지 않을 수 있다고 가정하고 old/new server coexistence를 설계한다.

Cross-server messages/data schema가 compatible해야 함.

## 14. Secrets inside Roblox

External API key가 experience server에서 필요하면 current Roblox Secrets Store를 검토. GitHub CI secret와 Roblox runtime secret은 별도 scope.

## 15. CI failure policy

Fail deployment if:
- lint/test critical failure
- build failure
- missing secret/config
- project validator failure
- artifact mismatch

Do not `continue-on-error` critical gates to make pipeline green.

## 16. Observability

Release record:
```text
version
commit
publish time
place version
data schema
feature flags
known risks
```

Post release에서 Creator Analytics/error/performance changes를 correlate.

## 17. Automation maturity levels

### Level 0
Manual Studio publish, checklist.

### Level 1
Git CI lint/test/build.

### Level 2
Automatic TEST publish.

### Level 3
Studio MCP regression + screenshots/console.

### Level 4
Controlled production promotion + monitoring/rollback.

Project가 필요 이상으로 Level 4 infrastructure를 먼저 만들지 않는다. vertical slice stage에서는 Level 1~2로 충분할 수 있음.
