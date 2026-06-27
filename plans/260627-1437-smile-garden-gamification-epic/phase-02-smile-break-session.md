# Phase 02 - Smile Break Micro-session

## Context Links

- Depends: [phase-01-smile-detection-foundation.md](phase-01-smile-detection-foundation.md)
- Current refs: `lib/main.dart`, `lib/features/session/session.dart`, `lib/runtime/session.dart`, `lib/domain/timeline.dart`

## Overview

- Priority: P0
- Status: pending
- Add optional Smile Break flow. It must be no-fail, skippable, and safe when camera unavailable.

## Key Insights

- `main.dart` has inline `_LibraryScreen`; adding Smile Break should first move Library to a feature file to keep shell small.
- `SessionReEntryScreen` exists near end of large `session.dart`; edit minimally.
- Timeline is source of truth. Add one event, do not create separate completion store.
- User-facing strings should be Vietnamese.

## Requirements

- Functional:
  - Route `/smile-break`.
  - Optional entry from Library.
  - Optional entry from session Re-entry.
  - Skip button always visible.
  - Camera unavailable/denied path uses self-report intention.
  - Completion records timeline event.
- Non-functional:
  - No raw probability/score shown.
  - No fail state.
  - Scrollable UI.
  - Reduce-motion friendly.

## Architecture

- `features/smile_break/smile_break.dart`
  - `SmileBreakScreen`
  - `SmileBreakArgs`
  - soft meter widget
  - self-report fallback
- `features/library/library.dart`
  - move current Library stub out of `main.dart`
  - add Smile Break card/button
- `SessionRuntime.recordSmileBreak(...)`
  - appends `SessionTimelineEventType.smileBreak`
  - payload: source, self_reported, completed/skipped, no image data

## Related Code Files

- Create: `apps/mobile/lib/features/smile_break/smile_break.dart`
- Create: `apps/mobile/lib/features/library/library.dart`
- Modify: `apps/mobile/lib/main.dart`
- Modify: `apps/mobile/lib/features/session/session.dart`
- Modify: `apps/mobile/lib/runtime/session.dart`
- Modify: `apps/mobile/lib/domain/timeline.dart`
- Create tests: `apps/mobile/test/story_smile_break_test.dart`

## Implementation Steps

1. Extract inline Library screen from `main.dart` to `features/library/library.dart`.
2. Add `SmileBreakScreen` and route `/smile-break`.
3. Add Library CTA to open Smile Break.
4. Add Re-entry CTA with minimal edit in `SessionReEntryScreen`.
5. Wire `SmileDetectionRuntime` from Phase 1.
6. Implement self-report fallback for denied/unavailable source.
7. Add `smileBreak` timeline type and `recordSmileBreak`.
8. Add widget tests for skip, fallback, and route reachability.
9. Run `flutter analyze` and targeted tests.

## Todo

- [ ] Library feature extraction
- [ ] Smile Break route and args
- [ ] Smile Break UI, skip, completion state
- [ ] Camera unavailable/self-report fallback
- [ ] Re-entry optional CTA
- [ ] Timeline event + runtime recorder
- [ ] Widget tests
- [ ] Analyze clean

## Success Criteria

- Smile Break reachable from Library and Re-entry.
- Skip completes without failure copy.
- Camera unavailable path completes via self-report.
- Timeline records `smile_break` without image data.

## Risk Assessment

- Re-entry edit can bloat `session.dart`. Mitigate by putting new widgets in `smile_break.dart`.
- Camera source may be unavailable. Mitigate with explicit fallback path.
- Raw score pressure. Mitigate by never rendering probability text.

## Security Considerations

- Timeline stores only derived completion metadata.
- No frame/image data stored or uploaded.

## Next Steps

- Phase 3 derives garden reflection from timeline events.

## Unresolved Questions

1. Should Home also expose Smile Break, or keep Home single-path and avoid extra choice?
