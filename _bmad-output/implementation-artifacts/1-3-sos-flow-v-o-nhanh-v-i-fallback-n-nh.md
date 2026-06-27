---
baseline_commit: 85df7d975edaa1bd95eec8849ed73707faaf19b9
source_app_commit: 4c39e674017dc64a6d46330740f9976c913fad73
created: 2026-06-24
contexted: 2026-06-27T12:54:16+07:00
---
# Story 1.3: SOS flow vao nhanh voi fallback on dinh

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a nguoi dung dang qua tai,  
I want nhan SOS va vao breathing flow trong vai giay,  
So that toi ha duoc muc kich hoat cam xuc ngay lap tuc.

## Acceptance Criteria

1. **Entry tu Home:** Given nguoi dung o Home, When cham SOS capsule `cta-sos` trong `CalmTopAppBar.trailing`, Then app dieu huong toi `/sos` voi `_SosEntryArgs(contextAvailable, sensorAvailable)`, And `_SosEntryScreen.initState` goi `_SosRuntime.evaluateMode` de quyet dinh mode.
2. **Mode decision on dinh:** Given `_SosRuntime.evaluateMode` chay, When kiem tra dieu kien, Then tra `calmSafe` khi `!contextAvailable || context == null || !sensorAvailable || repeated (lastStart <60s) || (lastCheckin == overload && night)`; nguoc lai tra `active`.
3. **Active entry:** Given mode = `active`, When render entry, Then headline `'Chúng tôi ở đây với bạn.'` va nut `sos-start-btn` (`EmergencySOSButton`, label `'60 giây'` / `'bình ổn'`, icon `air`) hien thi; onTap chuyen `/sos/active` mode=active, goi `registerEntry(now)`, va haptic medium.
4. **Calm-safe entry:** Given mode = `calmSafe`, When render entry, Then copy `'Không đủ điều kiện SOS nhanh, chuyển sang calm-safe.'` va nut `sos-safe-btn` (label `'Yên vị'` / `'nhẹ nhàng'`, icon `self_improvement`) chuyen `/sos/active` mode=calmSafe.
5. **Active 60s flow:** Given o `/sos/active` mode=active, When man render, Then `_timeoutSeconds=60`, `Timer.periodic(1s)`, headline `'Cùng nhịp thở, giữ chậm lại.'`, sub `'Không cần hoàn hảo, chỉ cần quay về.'`, `ProgressRing(progress=elapsed/60)`, va `BreathingCircle` phase 4s hien thi.
6. **Timeout calm-safe exit:** Given active chay den elapsed >= 60s, When cham `_timeoutSeconds`, Then `_isTimedOut` dat `_calmSafeExitTriggered=true`, goi `recordSosTimeoutExit()` voi timeline event `sos_timeout_exit`, va chuyen sang calm-safe (`SOS Safe`, headline `'Calm-safe exit: hạ cường độ, quay ra an toàn.'`).
7. **Exit/Return trong toi da 2 thao tac:** Given nguoi dung can thoat o bat ky screen SOS nao, When cham Exit/Return (`sos-exit-btn`, `sos-return-btn`, `sos-active-exit`, `sos-calm-safe-return` label `'Trở về Home an toàn'`), Then ghi `recordSosInterrupt(reason: 'sos_interrupt')` khi la interrupt path, pop ve Home bang `popUntil(isFirst)`, va toan bo loi thoat nam trong <=2 thao tac.
8. **Haptic/text fallback:** Given audio-off hoac haptic-disabled/reduce-motion, When render SOS, Then pacing visual + haptic/text fallback van hoat dong, khong them audio path bat buoc trong SOS, va hien fallback copy/key `sos-haptic-text-fallback` voi noi dung `'SOS haptic fallback: text pacing remains available.'` hoac cue text hien co.
9. **Repeated SOS guardrail:** Given SOS lien tiep <60s, When `evaluateMode` chay, Then ep calm-safe voi reason `'repeated-sos'`.
10. **DistressBoundary bat buoc:** Given SOS entry hoac active render, When flow hien thi, Then `DistressBoundary` luon hien voi keys `sos-distress-boundary` va `sos-active-distress-boundary`, message `'Đây là công cụ tự chăm sóc nhẹ nhàng, không thay thế hỗ trợ chuyên môn…'`, va action `'Tìm hỗ trợ'` mac dinh mo `_SupportResourcesSheet` (hotline / ho tro chuyen mon / nguoi tin cay).
11. **Release clean:** Given release build voi `--dart-define=ELARO_RELEASE=true`, When SOS render, Then runtime telemetry cua SOS (reason, elapsed, QA controls) nam sau `DevSection` va bi an sach khi `DevGate.enabled == false`.

## Tasks / Subtasks

- [x] Xac nhan/hoan thien entry tu Home vao SOS (AC: 1)
  - [x] Giu `cta-sos` la header capsule, khong dua vao tap body CTA ranked.
  - [x] Truyen `_SosEntryArgs(contextSnapshot, contextAvailable, sensorAvailable)` tu Home sang `/sos`.
  - [x] Khong them tab SOS hoac man trung gian moi.
- [x] Xac nhan/hoan thien `_SosRuntime.evaluateMode` va stability floor (AC: 2,9)
  - [x] Giu cac guardrail: missing context, missing sensor, repeated <60s, overload+night.
  - [x] `registerEntry(now)` chi duoc goi khi user start active SOS, khong goi khi chi mo entry.
  - [x] Reason/debug text neu co phai nam trong `DevSection`.
- [x] Xac nhan/hoan thien entry UI active/calm-safe (AC: 3,4,10)
  - [x] Dung `EmergencySOSButton` va copy/key frozen trong AC.
  - [x] Giu `DistressBoundary` tren entry va action mac dinh toi support sheet.
  - [x] Body co the tran phai scrollable.
- [x] Xac nhan/hoan thien active 60s runtime va calm-safe timeout (AC: 5,6)
  - [x] Giu `_timeoutSeconds=60`, timer 1s, `ProgressRing`, `BreathingCircle` phase 4s.
  - [x] Timeout chi ghi `sos_timeout_exit` mot lan.
  - [x] Khong dung `AnimationController.repeat()`.
- [x] Xac nhan/hoan thien exit/return va timeline logging (AC: 7)
  - [x] Interrupt paths ghi `sos_interrupt` qua `_SessionRuntime.recordSosInterrupt`.
  - [x] Return ve Home bang `Navigator.popUntil((route) => route.isFirst)`.
  - [x] `sos-calm-safe-return` ghi `sos_interrupt` khi dang o active flow truoc timeout; khi da calm-safe/timeout thi return an toan khong ghi interrupt moi.
- [x] Xac nhan/hoan thien haptic-first + text fallback (AC: 8)
  - [x] Khong them dependency audio cho SOS trong story nay.
  - [x] Haptic cue ton trong settings/reduce-motion; text fallback van san sang.
- [x] Bo sung/giu regression tests rieng, khong sua frozen contract (AC: 1-11)
  - [x] Khong sua `apps/mobile/test/widget_test.dart` tru khi co task unfreeze rieng.
  - [x] Them targeted regression test file moi, khong doi frozen keys/text.

## Dev Notes

### Current State

- BMAD artifacts song trong `/Users/lee/code/projects/elaro-high/_bmad-output/implementation-artifacts`.
- Source app/runtime thuc te hien o `/Users/lee/code/projects/elaro-med/apps/mobile`; `elaro-high` khong co `apps/mobile/` tai thoi diem context story.
- Story 1.3 backlog draft da co AC chi tiet va source code hien co da implement phan lon flow SOS. DEV nen doc code/test truoc, sau do chi sua nhung gap that su, khong rewrite.
- Recent BMAD commits: `2f092dc chore(bmad): close story 1.1`, `85df7d9 chore(bmad): close story 1.2`.
- Source-app baseline khi context story: `4c39e674017dc64a6d46330740f9976c913fad73`.

### Files To Inspect Before Coding

- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/features/home/home.dart`
  - `_HomeContext`, `_buildSosCapsule`, `_sensorAvailable`, `_lastCheckin`, `_rankCtas`.
  - Current behavior: `cta-sos` push `/sos` voi `_SosEntryArgs(contextSnapshot: snapshot, contextAvailable: true, sensorAvailable: _sensorAvailable)`.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/features/sos/sos.dart`
  - `_SosEntryArgs`, `_SosActiveArgs`, `_SosEntryScreen`, `_SosActiveScreen`, `_timeoutSeconds`, exit handlers.
  - Current behavior: entry/active bodies da scrollable; `sos-reason` va elapsed telemetry nam trong `DevSection`; `DistressBoundary` co tren entry + active.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/runtime/runtimes.dart`
  - `_SosRuntime.evaluateMode`, `registerEntry`, `lastStartTime`, `resetForTests`.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/runtime/session.dart`
  - `_SessionRuntime.recordSosInterrupt`, `recordSosTimeoutExit`, timeline append.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/domain/timeline.dart`
  - `SessionTimelineEventType.sosInterrupt` -> `sos_interrupt`; `sosTimeoutExit` -> `sos_timeout_exit`; timeline validation/sort.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/components/actions/actions.dart`
  - `EmergencySOSButton`; static aura only, no infinite animation.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/components/breathing/breathing.dart`
  - `ProgressRing`, `BreathingCircle`; host-driven phase, no `repeat()`.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/components/trust/trust.dart`
  - `DistressBoundary` va `_SupportResourcesSheet`; action `'Tìm hỗ trợ'` default mo calm bottom sheet scrollable.
- `/Users/lee/code/projects/elaro-med/apps/mobile/test/widget_test.dart`
  - Frozen behavioral contract. Read, do not edit unless explicitly unfreezing.

### Implementation Guardrails

- Khong implement code trong buoc create-story nay; story chi expose context cho DEV.
- `apps/mobile/lib/main.dart` la barrel-only; anchor behavior vao owning part file trong `lib/features/*`, `lib/runtime/*`, `lib/domain/*`.
- Khong tao feature slice, router, storage, audio runtime, hoac social/support subsystem moi cho Story 1.3 neu code hien co da co primitive.
- Moi debug/QA/telemetry phai nam trong `DevSection`; release build dung `flutter build ... --dart-define=ELARO_RELEASE=true`.
- Moi body/sheet co the tran phai scrollable; test voi Dynamic Type/text scale lon neu cham UI.
- Khong dung `AnimationController.repeat()`. Motion breathing phai settle-able va degrade sang static/haptic/text khi Reduce Motion.
- User-facing string moi viet tieng Viet. Ba string contract-locked khong lien quan story nay: `Ritual Builder`, `Session start`, `Pack type: Core`.
- Giữ tone night-calm: khong gamification, streak, score, diagnosis, pressure copy, hoac claim thay the ho tro chuyen mon.
- Timeline la system-of-record; SOS interrupt/timeout phai ghi event qua `_SessionRuntime` thay vi state rieng song song.

### Previous Story Intelligence

- Story 1.1 da dong: Home body CTA cap `take(2)`, SOS o rieng header capsule `cta-sos`, khong phai body CTA. Story 1.3 khong duoc lam SOS thanh tab hoac CTA thu 3 trong body.
- Story 1.2 da dong: Home quick check-in dung `_CheckinState {calm, low, overload}` va `_lastCheckin` duoc truyen vao session context. Story 1.3 dung `_lastCheckin == overload && night` de ep calm-safe; khong doi enum/vocab nay.
- Story 1.2 them regression test rieng va khong sua `widget_test.dart`; giu pattern nay neu can test moi.
- Recent source pattern: prefer targeted tests and minimal/no production code change when existing implementation already satisfies AC.

### Architecture / Product Constraints

- Architecture pins: Flutter 3.41.0, Dart 3.10.x, Riverpod 3.3.2, go_router 17.3.0, Supabase 2.14.0, Drift 2.34.0, just_audio 0.10.5, health 13.3.1.
- Khong can dependency moi cho Story 1.3. Neu `pubspec.yaml` drift so voi architecture pins, khong upgrade trong story nay; raise follow-up.
- AD-2: Session timeline la system-of-record; SOS events thuoc timeline, khong ghi summary rieng de lam source chinh.
- AD-3: Offline-first; SOS entry/active khong phu thuoc network/sensor de co safe fallback.
- AD-4: Sensor/mic/health phai qua permission-gated adapters. Story 1.3 chi dung `sensorAvailable` boolean/fallback; khong goi raw microphone.
- NFR safety: app khong thay the tri lieu/ho tro khung hoang; `DistressBoundary` + support sheet bat buoc.

### Testing Requirements

- Run Flutter commands from `/Users/lee/code/projects/elaro-med/apps/mobile`. Use `uv` only if invoking Python helpers.
- Minimum DEV validation:
  - `flutter test`
  - `flutter analyze`
  - Targeted SOS tests if production code changes.
- Suggested SOS assertions:
  - `cta-sos` opens `/sos` and renders `sos-start-btn` or `sos-safe-btn` based on mode.
  - Sensor unavailable or overload+night path renders calm-safe copy and `sos-safe-btn`.
  - Repeated SOS <60s enters calm-safe with dev reason `repeated-sos` visible only under `DevSection`.
  - Active flow timeout after >=60s renders `SOS Safe`, calm-safe headline, and logs `sos_timeout_exit`.
  - Exit paths return Home in <=2 taps and interrupt paths log `sos_interrupt`.
  - Haptics disabled/reduce-motion still exposes `sos-haptic-text-fallback`.
  - `DistressBoundary` action opens `_SupportResourcesSheet` on entry and active.
- Release/dev-gating check:
  - Build or test release path with `--dart-define=ELARO_RELEASE=true` where feasible and confirm `sos-reason`, elapsed telemetry, and QA controls do not render.

### Latest Technical Note

- No new package/API research is required for this story because it uses existing Flutter widgets, Navigator routing, timeline runtime, and design-system components.
- Treat architecture versions as pins. Do not upgrade Flutter/packages while implementing Story 1.3.

## Project Structure Notes

- Expected owner files are under `/Users/lee/code/projects/elaro-med/apps/mobile/lib/features/sos`, `features/home`, `runtime`, `domain`, and `components`.
- Do not anchor behavior to `main.dart` except route table facts; `main.dart` is barrel-only.
- Do not create duplicate SOS components if `EmergencySOSButton`, `ProgressRing`, `BreathingCircle`, `DistressBoundary`, `PillButton`, and `SessionStateLabel` already cover the need.

## References

- [Source: _bmad-output/planning-artifacts/epics.md#story-1-3]
- [Source: _bmad-output/planning-artifacts/prds/prd-meditation-community-2026-06-24/prd.md#fr-5-sos-protocol]
- [Source: _bmad-output/planning-artifacts/architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md#ad-2--session-timeline-is-the-system-of-record]
- [Source: _bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/EXPERIENCE.md#flow-2--sos-entry--active--calm-safe-exit]
- [Source: _bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/DESIGN.md#calm-player-pattern-canonical]
- [Source: _bmad-output/planning-artifacts/ENGINEERING-RULES.md]

## Dev Agent Record

### Agent Model Used

Codex GPT-5

### Debug Log References

- RED: `flutter test test/story_1_3_sos_test.dart` failed as expected because active `sos-calm-safe-return` did not log `sos_interrupt`.
- GREEN: `flutter test test/story_1_3_sos_test.dart` passed.
- `flutter analyze` passed with no issues.
- `flutter test` passed: 74 tests passed, 3 skipped.

### Completion Notes List

- Confirmed Home `cta-sos` remains a header capsule outside ranked body CTAs and still routes to `/sos` with `_SosEntryArgs`.
- Confirmed existing `_SosRuntime.evaluateMode`, active/calm-safe entry UI, 60s timer, timeout logging, haptic/text fallback, DistressBoundary/support sheet, and DevSection gating against targeted tests.
- Fixed active SOS safe-return path so `sos-calm-safe-return` records `sos_interrupt` before returning Home when the active flow is interrupted before timeout; calm-safe/timeout return remains a non-interrupt safe return.
- Added targeted Story 1.3 regression tests for active return interrupt logging, repeated SOS guardrail, support sheet, reduce-motion text fallback, and SOS DevSection release gating.
- Did not edit frozen `apps/mobile/test/widget_test.dart`; no commit performed.

### File List

- /Users/lee/code/projects/elaro-high/_bmad-output/implementation-artifacts/1-3-sos-flow-v-o-nhanh-v-i-fallback-n-nh.md
- /Users/lee/code/projects/elaro-high/_bmad-output/implementation-artifacts/sprint-status.yaml
- /Users/lee/code/projects/elaro-med/apps/mobile/lib/features/sos/sos.dart
- /Users/lee/code/projects/elaro-med/apps/mobile/test/story_1_3_sos_test.dart

## Status

- created: 2026-06-24
- create_story: done
- contexted: 2026-06-27
- dev_status: done
- code_review: done

## Senior Developer Review (AI)

- Review outcome: PASS
- Date: 2026-06-27
- Blocker: None
- Reviewer recommendation: Story 1.3 da pass review va duoc dong.

### Action Items

- [x] [High] Stage/commit Story 1.3 source change `apps/mobile/lib/features/sos/sos.dart`.
- [x] [High] Stage/commit Story 1.3 regression test `apps/mobile/test/story_1_3_sos_test.dart`.

### Change Log

- 2026-06-24: Initial backlog story created from Epic 1.
- 2026-06-26: Reconciled source behavior against `apps/mobile/`; ACs match shipped behavior draft.
- 2026-06-27: Create-story workflow applied; status moved to ready-for-dev with full DEV context and guardrails.
- 2026-06-27: Development started; story moved to in-progress.
- 2026-06-27: Implemented Story 1.3 regression coverage and active SOS return interrupt logging; story moved to review.
- 2026-06-27: Review PASS recorded; story closed as done.
