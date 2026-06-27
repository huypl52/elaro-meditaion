# Phase 04 - Distress Carve-out, Polish, Full Validation

## Context Links

- Depends: [phase-03-restorative-garden-reflection.md](phase-03-restorative-garden-reflection.md)
- Current refs: `lib/runtime/sos_runtime.dart`, `lib/features/sos/sos.dart`, `lib/features/growth/growth.dart`

## Overview

- Priority: P1
- Status: pending
- Remove original percentile scope. Add distress suppression, copy polish, and full suite validation.

## Key Insights

- Percentile/top-X conflicts with no-comparison rule.
- SOS currently has `SosRuntime.registerEntry` and timeline events for interrupt/timeout.
- Garden is only in Growth, but runtime guard should exist before future prompts.
- Debug/telemetry must stay behind `DevSection`.

## Requirements

- Functional:
  - Runtime says whether distress cooldown is active.
  - SOS entry/active route activates distress context.
  - Garden/smile prompt widgets render nothing during distress cooldown.
  - Guardrail tests assert no garden/smile/quest/percentile in SOS.
- Non-functional:
  - No percentile or ranking UI.
  - No production debug labels.
  - Full Flutter test suite passes.

## Architecture

- Extend `SosRuntime` or create `DistressContextRuntime`.
- Preferred KISS path: extend `SosRuntime` with `lastDistressAt`, `markDistress()`, `isDistressCooldownActive(now)`.
- Garden and Smile Break entry widgets check runtime before rendering optional prompts.
- SOS screens call `markDistress()` on entry/active and when interrupt/timeout recorded.

## Related Code Files

- Modify: `apps/mobile/lib/runtime/sos_runtime.dart`
- Modify: `apps/mobile/lib/features/sos/sos.dart`
- Modify: `apps/mobile/lib/features/garden/smile_garden_view.dart`
- Modify/add tests:
  - `apps/mobile/test/story_1_3_sos_test.dart`
  - `apps/mobile/test/story_smile_garden_test.dart`
  - `apps/mobile/test/story_smile_break_test.dart`

## Implementation Steps

1. Add distress cooldown runtime API to `SosRuntime`.
2. Mark distress on SOS entry/active and exits.
3. Gate optional garden/smile prompt widgets during cooldown.
4. Add tests for SOS zero garden/smile/quest/percentile content.
5. Add copy guard tests for no streak/score/leaderboard/top-X.
6. Run `flutter analyze`.
7. Run full `flutter test`.

## Todo

- [ ] Distress cooldown runtime
- [ ] SOS mark hooks
- [ ] Garden/smile prompt gate
- [ ] SOS carve-out tests
- [ ] No-comparison copy tests
- [ ] Analyze clean
- [ ] Full test suite green

## Success Criteria

- SOS and cooldown have zero garden/smile/quest/percentile UI.
- No percentile/ranking code exists in this epic.
- `flutter analyze` passes.
- Full `flutter test` passes.

## Risk Assessment

- Cooldown can hide Growth unexpectedly after SOS. Mitigate with short explicit duration and tests.
- Future features may bypass guard. Mitigate by documenting optional prompts must check `SosRuntime`.
- Copy drift toward comparison. Mitigate with text tests.

## Security Considerations

- No identity or aggregate comparison payload.
- Distress flag is local runtime state only.

## Next Steps

- After this epic, decide whether to restore platform dirs and validate real camera on device.

## Unresolved Questions

1. What cooldown length should ship: 5 minutes, 15 minutes, or session-only?
