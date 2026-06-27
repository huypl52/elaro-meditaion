# Brainstorm: Smile Garden, aligned to current implementation

- Date: 2026-06-27
- Product: Elaro mobile meditation app
- Plan path: `../elaro-med/plans/260627-1437-smile-garden-gamification-epic/`
- Implementation root: current repo `apps/mobile/`
- Status: adapted to current code, ready for implementation planning

## Problem

Existing plan was created against another implementation shape. Current delivery repo is leaner:
- `apps/mobile/lib/main.dart` owns app shell, routes, tab scaffold.
- Real code is modular imports under `domain/`, `runtime/`, `features/`, `components/`, `theme/`.
- No `part of main.dart`, no Riverpod, no go_router, no Drift, no Supabase.
- No `ios/` or `android/` platform folders in current `apps/mobile`.
- No generic `features/permissions` or `features/library` file yet. Library and Settings are inline stubs in `main.dart`.

Need adapt plan to current code, not sibling repo.

## Hard Truths

- Original "gamification" framing conflicts with README/spec/engineering rules: no gamification, no streak, no score, no leaderboard.
- Percentile/top-X social metric is functionally a comparison mechanic. It should not ship in this epic.
- Camera implementation cannot be fully native-configured until Flutter platform folders are restored/generated.
- `features/session/session.dart` and `features/sos/sos.dart` already exceed 200 LOC. Plan must avoid adding bulk there.

## Evaluated Approaches

### A. Keep original gamification plan

Pros:
- More engagement hooks.
- Easy marketing phrase.

Cons:
- Violates product DNA and current tests around no streak/score/leaderboard.
- Percentile creates pressure and privacy review scope.
- Pulls backend/storage before MVP needs it.

Decision: reject for current implementation.

### B. Restorative Garden reflection

Pros:
- Keeps visual progress without score/competition.
- Can derive from existing `SessionRuntime.timeline`.
- Fits Growth screen and no-comparison copy.
- Smaller implementation surface.

Cons:
- Less "game-like".
- Needs careful copy to avoid toxic positivity.

Decision: recommended.

### C. Smile Break only, no garden

Pros:
- Smallest scope.
- Proves camera/smile feasibility first.

Cons:
- Weak continuity value after session.
- Does not use existing Growth surface.

Decision: viable fallback if camera risk dominates.

## Recommended Solution

Build "Smile Break + Restorative Garden":

1. Smile detection foundation behind testable runtime interfaces.
2. Optional Smile Break micro-session. No gating, no fail, always skippable, self-report fallback.
3. Garden as narrative reflection inside Growth. No streak, no badge, no percentile, no leaderboard.
4. SOS/distress carve-out. Garden and smile prompts hidden during distress and cooldown.

## Implementation Considerations

- Use current Dart import style. No `part` files.
- Add new files instead of growing large `session.dart`/`sos.dart`.
- Create `features/library/library.dart` and move inline library screen out of `main.dart` before adding Smile Break entry.
- `SessionRuntime` remains in-memory source of truth.
- Add `SessionTimelineEventType.smileBreak` and a `recordSmileBreak` method.
- Garden runtime derives elements from timeline events, not separate duplicate counters.
- Camera native setup is blocked until platform dirs exist. Production camera adapter should be implemented only after platform dirs are restored; test fake source allowed only in tests.

## Risks

| Risk | Mitigation |
|---|---|
| Camera/platform missing | Phase 1 makes platform prerequisite explicit and keeps compile-safe runtime seam |
| Toxic positivity | No pass/fail, fallback self-report, validating copy for hard days |
| Product DNA drift | No streak/score/badge/percentile; garden is reflection only |
| Large-file churn | New focused files; only small route/import/event edits in existing files |
| Test fragility | Add focused tests; preserve existing frozen strings/keys |

## Success Metrics

- Smile Break reachable and skippable.
- Camera denied/unavailable path completes via self-report.
- Garden renders from timeline events without comparison copy.
- SOS/distress routes show zero garden/smile/quest UI.
- `flutter analyze` and full `flutter test` pass.

## Next Steps

- Use adapted phase plan in `../elaro-med/plans/260627-1437-smile-garden-gamification-epic/`.
- Implement current-repo code only under `apps/mobile/`.
- Restore/generate platform folders before real camera permission strings and native hardware validation.

## Unresolved Questions

1. Should platform folders be restored before Phase 1, or should Phase 1 ship compile-safe runtime interfaces first?
2. Should Smile Break appear on Home as a second CTA, or only Library + Re-entry?
