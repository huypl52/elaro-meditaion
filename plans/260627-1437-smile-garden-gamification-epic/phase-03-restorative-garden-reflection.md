# Phase 03 - Restorative Garden in Growth

## Context Links

- Depends: [phase-02-smile-break-session.md](phase-02-smile-break-session.md)
- Current refs: `lib/features/growth/growth.dart`, `lib/runtime/session.dart`, `lib/domain/timeline.dart`
- Product guardrail: no gamification, no streak, no score, no leaderboard

## Overview

- Priority: P1
- Status: pending
- Add garden as visual/narrative reflection inside Growth, not competitive gamification.

## Key Insights

- Existing Growth already says "không chỉ số, không so sánh".
- Garden should derive from `SessionRuntime.timeline` to stay DRY.
- Hard check-ins should become validating "rain/rest" elements, not failure.
- No badges, rare blooms, watering streak, percentile, top-X, quests.

## Requirements

- Functional:
  - Garden view in Growth below existing no-comparison bento.
  - Derive elements from session complete, Smile Break, and manual check-in payloads.
  - Empty state when no timeline events.
  - Mood-inclusive labels for calm/low/overload.
- Non-functional:
  - No score/streak/leaderboard copy.
  - Accessible labels for decorative elements.
  - Reduce-motion safe.
  - Does not replace existing Growth stats.

## Architecture

- `GardenRuntime` is a pure derived runtime over `SessionRuntime.timeline`.
- `GardenElement` has type, tone, source, label, timestamp.
- `SmileGardenView` renders small responsive tiles using existing `SectionCard`, `ElaroColors`, `GrowthTokens`.
- Growth screen embeds `SmileGardenView(runtime: GardenRuntime(sessionRuntime))`.

## Related Code Files

- Create: `apps/mobile/lib/runtime/garden_runtime.dart`
- Create: `apps/mobile/lib/features/garden/smile_garden_view.dart`
- Modify: `apps/mobile/lib/features/growth/growth.dart`
- Modify tests: add `apps/mobile/test/story_smile_garden_test.dart`

## Implementation Steps

1. Implement `GardenRuntime` derivation from timeline.
2. Map `sessionComplete` to steady sprout.
3. Map `smileBreak` completion to soft bloom; skipped/self-reported gets gentler label.
4. Map manual check-in payloads to mood-inclusive element tone.
5. Render `SmileGardenView` in Growth without changing existing stats/copy.
6. Add tests for derivation, no-comparison copy, and negative mood validation.
7. Run `flutter analyze` and relevant tests.

## Todo

- [ ] `runtime/garden_runtime.dart`
- [ ] `features/garden/smile_garden_view.dart`
- [ ] Growth embed
- [ ] Mood-inclusive mapping
- [ ] Tests for derivation and copy guardrails
- [ ] Analyze clean

## Success Criteria

- Growth shows garden reflection from existing timeline.
- Existing Growth stats and no-comparison copy remain.
- Tests prove no streak/score/leaderboard/top-X text.
- Hard-day check-in creates validating element, not failure copy.

## Risk Assessment

- Garden can drift into gamification. Mitigate with tests checking forbidden words/copy.
- Duplicate state can diverge. Mitigate by deriving from timeline.
- UI can overflow. Mitigate with scrollable Growth already present and responsive tiles.

## Security Considerations

- Garden stores/derives aggregate session metadata only.
- No image, biometric, or identity data.

## Next Steps

- Phase 4 adds distress suppression and full validation.

## Unresolved Questions

1. Should garden elements survive app restart now, or remain in-memory with current runtime?
