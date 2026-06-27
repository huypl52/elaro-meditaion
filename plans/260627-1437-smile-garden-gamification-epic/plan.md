---
status: pending
created: 2026-06-27
updated: 2026-06-27
source: plans/reports/brainstorm-260627-1437-smile-garden-gamification-epic.md
implementation_root: /mnt/Data/Projects/codex_hackathon/elaro-meditaion/apps/mobile
---

# Plan: Smile Break + Restorative Garden Reflection

Adapted for current implementation repo, not sibling `../elaro-med/apps/mobile`.

## Reality Check

Current code is modular Flutter, not old `part of main.dart` prototype:

- `main.dart`: app shell, named routes, tab scaffold, inline Library/Settings stubs.
- Runtime: `SessionRuntime`, `SosRuntime`, `MicrophonePermissionRuntime`, `SensorRuntime`.
- Features: `home`, `session`, `sos`, `growth`, `voice_journal`.
- Tests: story tests through Epic 3.2.
- No `ios/` or `android/` platform dirs.
- No Drift/Supabase/Riverpod/go_router.

Product guardrail: Elaro says no gamification, no streak, no score, no leaderboard. Therefore this plan changes "Smile Garden gamification" into restorative garden reflection.

## Phases

| # | Phase | Status |
|---|-------|--------|
| 1 | [Smile detection runtime foundation](phase-01-smile-detection-foundation.md) | pending |
| 2 | [Smile Break micro-session](phase-02-smile-break-session.md) | pending |
| 3 | [Restorative Garden in Growth](phase-03-restorative-garden-reflection.md) | pending |
| 4 | [Distress carve-out, polish, full validation](phase-04-distress-carveout-polish.md) | pending |

## Dependencies

- Phase 2 depends on Phase 1 runtime seam.
- Phase 3 depends on Phase 2 timeline event.
- Phase 4 depends on Phase 3 garden widget and SOS/runtime guard.

## Guardrails

- Use current repo `apps/mobile/` as delivery root.
- Use Dart imports, no `part`/`part of`.
- Do not add Drift/Supabase/Riverpod/go_router.
- Do not add streak, score, badge collection, percentile, leaderboard, quest, top-X copy.
- Camera frames stay on-device, never written/uploaded.
- Smile Break never blocks, never fails, always skippable.
- SOS/distress and cooldown show no smile/garden prompt.
- Keep big existing files from growing except small route/import/event hooks.

## Out Of Scope

- Real backend percentile.
- Public or anonymous ranking.
- Disk persistence for garden.
- Platform-specific camera validation until `ios/` and `android/` dirs exist.
- Marketing repositioning as gamified meditation.

## Unresolved Questions

1. Restore platform folders before Phase 1, or implement compile-safe runtime seam first?
2. Add Smile Break on Home, or keep Library + Re-entry only?
