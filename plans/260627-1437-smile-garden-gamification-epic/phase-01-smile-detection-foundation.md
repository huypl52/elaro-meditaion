# Phase 01 - Smile Detection Runtime Foundation

## Context Links

- Plan: [plan.md](plan.md)
- Brainstorm: [../reports/brainstorm-260627-1437-smile-garden-gamification-epic.md](../reports/brainstorm-260627-1437-smile-garden-gamification-epic.md)
- Implementation root: `/mnt/Data/Projects/codex_hackathon/elaro-meditaion/apps/mobile`
- Current refs: `lib/runtime/microphone_permission_runtime.dart`, `lib/runtime/session.dart`, `lib/domain/timeline.dart`

## Overview

- Priority: P0
- Status: pending
- Build smile detection runtime seam that compiles in current repo and can attach to real camera once platform folders exist.

## Key Insights

- Current repo has no `ios/` or `android/`; native camera permission files cannot be edited yet.
- `pubspec.yaml` has only Flutter + test/lints deps.
- Current code uses normal imports and public classes, not `part of`.
- Testable signal analysis should be separate from platform camera adapter.

## Requirements

- Functional:
  - Define `SmileSignal` with probability, face-present flag, timestamp, source status.
  - Define smile threshold/hold helpers independent from camera plugin.
  - Define runtime/source interface usable by Smile Break UI.
  - Add real camera adapter only when platform dirs are restored.
- Non-functional:
  - No image bytes exposed outside adapter.
  - No disk write, no network.
  - Compile/test without camera hardware.

## Architecture

- `SmileSignalSource` abstracts signal stream.
- `SmileDetectionRuntime` owns start/stop/listen lifecycle.
- `SmileHoldAnalyzer` converts signal stream into "soft bloom ready" state.
- Optional future adapter: `CameraSmileSignalSource` with `camera` + `google_mlkit_face_detection`.
- Test fake source lives only in test files.

## Related Code Files

- Create: `apps/mobile/lib/runtime/smile_detector.dart`
- Modify: `apps/mobile/pubspec.yaml` only if implementing real camera adapter in this phase
- Modify later: platform `ios/` and `android/` permission files after folders exist
- Create tests: `apps/mobile/test/story_smile_detection_runtime_test.dart`

## Implementation Steps

1. Confirm whether platform folders will be restored before coding.
2. Create `SmileSignal`, `SmileSignalSource`, `SmileDetectionRuntime`, `SmileHoldAnalyzer`.
3. Add threshold constants: start at probability `0.7`, hold `2s`, clamp `0..1`.
4. Keep production fallback state explicit: unavailable camera source returns denied/unavailable, not fake smile data.
5. If platform dirs exist, add camera/ML Kit deps and real adapter; otherwise document native-blocked status in code comments/tests.
6. Run `flutter analyze` and targeted runtime tests.

## Todo

- [ ] Platform folder decision recorded
- [ ] `runtime/smile_detector.dart`
- [ ] Signal clamp/threshold/hold helpers
- [ ] Runtime lifecycle start/stop/dispose
- [ ] Tests for clamp, sustained hold, unavailable source
- [ ] Analyze clean

## Success Criteria

- Runtime helpers compile and pass tests without camera hardware.
- No production fake smile data.
- Real camera adapter path is either implemented with platform dirs, or explicitly blocked with follow-up.

## Risk Assessment

- Missing platform dirs block native validation. Mitigate by separating signal logic from adapter.
- ML Kit frame conversion is platform-sensitive. Keep contained in adapter, not UI.
- Camera battery/perf risk. Future adapter must throttle and stop on dispose.

## Security Considerations

- No frame persistence.
- No image payload in timeline.
- Runtime exposes only probability/status.

## Next Steps

- Phase 2 consumes runtime seam in Smile Break UI.

## Unresolved Questions

1. Will platform folders be restored before implementing camera adapter?
