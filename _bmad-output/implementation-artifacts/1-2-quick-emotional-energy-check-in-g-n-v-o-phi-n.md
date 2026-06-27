---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
created: 2026-06-24
contexted: 2026-06-27T12:39:47+07:00
---
# Story 1.2: Quick emotional/energy check-in gắn vào phiên

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a người dùng,  
I want chọn nhanh cảm xúc/năng lượng trước phiên,  
So that app có thể cá nhân hóa gợi ý nhanh mà không tốn thời gian.

## Acceptance Criteria

1. **Quick check-in inline trên Home:** khi Home render, người dùng thấy đúng 3 `EmotionChip` trong `_buildQuickCheckinRow`: `checkin-calm` (`'Ấm/nhẹ'`), `checkin-low` (`'Mệt'`), `checkin-overload` (`'Quá tải'`). Mỗi chip chọn được trong 1 thao tác, không mở màn phụ/dialog/form.
2. **Gắn trạng thái vào session context:** khi chọn chip, `_lastCheckin` cập nhật thành `_CheckinState` tương ứng; khi bắt đầu phiên từ Home body CTA hoặc ritual replay, giá trị đó được truyền vào `_SessionStartArgs.manualCheckin`, sang `_SessionRuntime.startSession(manualCheckin: ...)`, rồi lưu trong timeline start event dưới key `manual_checkin`.
3. **Skip không khóa flow:** người dùng có thể bỏ qua check-in bằng cách không chọn chip; phiên vẫn bắt đầu với `manualCheckin == null` và default context. Dev-only control có label `'Bỏ qua check-in'` đang nằm trong `DevSection`, không được dùng làm UX chính cho production.
4. **Không thêm ma sát trước phiên:** chọn chip hoặc bỏ qua không được tạo bước bắt buộc mới giữa Home và `/session/start` hoặc `/session/active`; Home vẫn giữ tối đa 2 body CTA và `cta-sos` ở header riêng theo Story 1.1.
5. **Manual context downstream đúng vocab:** khi thiếu microphone hoặc confidence thấp ở runtime, `_SessionTimerState.noiseContextLabel` phải tạo `manual-calm`, `manual-low`, hoặc `manual-overload`; không dùng nhãn spec cũ `yên/vừa/ồn`.

## Tasks / Subtasks

- [x] Xác nhận hoặc hoàn thiện check-in chips trên Home (AC: 1,4)
  - [x] Giữ `_buildQuickCheckinRow` inline trong Home, dùng `EmotionChip`, không tạo route/sheet mới.
  - [x] Giữ nguyên keys `checkin-calm`, `checkin-low`, `checkin-overload` và copy tiếng Việt hiện có.
- [x] Xác nhận hoặc hoàn thiện propagation vào session start/runtime (AC: 2,5)
  - [x] Home CTA start truyền `_lastCheckin` vào `_SessionStartArgs.manualCheckin`.
  - [x] `_SessionStartScreen` truyền `widget.args.manualCheckin` vào `_SessionRuntime.startSession`.
  - [x] `_SessionRuntime.startSession` lưu `manual_checkin: manualCheckin?.name` trong start event.
  - [x] `_SessionTimerState.fromStartEvent` decode đúng `manual_checkin` về `_CheckinState`.
- [x] Xác nhận skip/default context (AC: 3,4)
  - [x] Không chọn chip vẫn start session được.
  - [x] Không thêm production button bắt buộc "skip" nếu flow hiện tại đã cho phép bỏ qua bằng cách start ngay.
  - [x] Nếu thêm skip affordance production, copy phải là tiếng Việt, 1-tap, và vẫn start flow hoặc giữ Home không bị chặn.
- [x] Bổ sung/điều chỉnh test nếu cần, không sửa frozen contract (AC: 1-5)
  - [x] Widget test nên kiểm keys chip, selected state, start session với manual context.
  - [x] Không sửa `apps/mobile/test/widget_test.dart` trừ khi có task unfreeze riêng.

## Dev Notes

### Current State

- Source app/runtime hiện ở `/Users/lee/code/projects/elaro-med/apps/mobile`, được Story 1.1 ghi nhận sau implementation reconciliation.
- Home owner: `/Users/lee/code/projects/elaro-med/apps/mobile/lib/features/home/home.dart`.
- Session UI owner: `/Users/lee/code/projects/elaro-med/apps/mobile/lib/features/session/session.dart`.
- Session runtime owner: `/Users/lee/code/projects/elaro-med/apps/mobile/lib/runtime/session.dart`.
- Timeline owner: `/Users/lee/code/projects/elaro-med/apps/mobile/lib/domain/timeline.dart`.
- `_CheckinState {calm, low, overload}` hiện được định nghĩa trong session feature part, vì Home và runtime cùng `part of` app barrel.

### Implementation Guardrails

- Không implement code trong bước create-story này; story chỉ expose context cho DEV.
- Khi DEV implement, ưu tiên giữ pattern hiện có: `EmotionChip` + local Home state + `_SessionStartArgs` + `_SessionRuntime.startSession`.
- Không tạo aggregate/store mới cho check-in trong Story 1.2. Timeline start event hiện là system-of-record đủ cho session context.
- Nếu cần event riêng `SessionTimelineEventType.checkIn`, chỉ thêm khi AC/test buộc cần; nếu không, tránh duplicate source-of-truth với `manual_checkin` trong start event.
- Mọi debug/QA control phải ở `DevSection`; release build dùng `--dart-define=ELARO_RELEASE=true`.
- Không dùng `AnimationController.repeat()`.
- Home body đã scrollable bằng `SingleChildScrollView`; mọi UI thêm vào phải giữ scrollability ở text scale lớn.
- String user-facing mới phải là tiếng Việt. Ba chuỗi contract-locked không liên quan story này: `Ritual Builder`, `Session start`, `Pack type: Core`.

### Files To Inspect Before Coding

- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/features/home/home.dart`
  - `_lastCheckin`, `_buildQuickCheckinRow`, `_buildQuickCheckin`, `_buildCtaButton`, `_buildRitualRow`.
  - Current behavior: chips set `_lastCheckin`; Home CTA and ritual replay pass manual check-in into `_SessionStartArgs`.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/features/session/session.dart`
  - `_CheckinState`, `_SessionStartArgs.manualCheckin`, `_SessionStartScreen`, `_SessionActiveArgs.manualContext`, session start button.
  - Current behavior: start button calls `_SessionRuntime.startSession(... manualCheckin: widget.args.manualCheckin ...)`.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/runtime/session.dart`
  - `_SessionRuntime.startSession`, `_SessionTimerState.fromStartEvent`, `noiseContextLabel`, `usingManualContext`.
  - Current behavior: start event stores `manual_checkin`; low-confidence/no-mic mode exposes `manual-${manualCheckin.name}`.
- `/Users/lee/code/projects/elaro-med/apps/mobile/lib/domain/timeline.dart`
  - Timeline validation, event ordering, source priority, and available `SessionTimelineEventType.checkIn`.
- `/Users/lee/code/projects/elaro-med/apps/mobile/test/widget_test.dart`
  - Frozen contract. Read before test changes; do not edit unless explicitly unfreezing.

### Testing Requirements

- Run from `/Users/lee/code/projects/elaro-med/apps/mobile` with `uv` only if invoking Python helpers; Flutter commands can run directly.
- Minimum DEV validation:
  - `flutter test`
  - If available, targeted widget test for Home check-in: chips render, 1-tap selection, Home CTA start carries manual check-in.
- Suggested assertions:
  - `find.byKey(Key('checkin-calm'))`, `checkin-low`, `checkin-overload`.
  - Tap `checkin-low`, tap `cta-short-breath`, then inspect session context/telemetry or runtime event details for `manual_checkin == 'low'`.
  - Start session without tapping a chip and confirm flow reaches start/active without blocking.
  - In no-mic/low-confidence path, label uses `manual-low` / `manual-calm` / `manual-overload`.

### Previous Story Intelligence

- Story 1.1 completed and committed as `2f092dc chore(bmad): close story 1.1`.
- Established Home rule: body CTAs remain capped with `_rankCtas(...).take(2)`; `SOS` stays as header capsule `cta-sos`.
- Story 1.2 must preserve Story 1.1's Home structure and should not convert check-in into a required pre-session screen.
- Story 1.1 implementation changed `/Users/lee/code/projects/elaro-med/apps/mobile/lib/features/home/home.dart`; read that file before modifying shared Home state.

### Architecture / Product Constraints

- Architecture stack target from `ARCHITECTURE-SPINE.md`: Flutter 3.41.0, Dart 3.10.x, Riverpod 3.3.2, go_router 17.3.0, Supabase 2.14.0, Drift 2.34.0, just_audio 0.10.5, health 13.3.1.
- No new dependency is needed for this story. Do not upgrade framework/package versions inside Story 1.2.
- AD-2: Session timeline is system-of-record. The selected check-in belongs in session start context/timeline, not in a parallel summary-only state.
- AD-3: Offline-first. Check-in must work entirely from local state and cannot depend on network/sensors.
- AD-4: Sensing fallback must be permission-gated; manual check-in can enrich fallback but must not require microphone permission.
- Tone invariant: no scoring, streak, guilt, diagnosis, or pressure copy.

### Latest Technical Note

- Current dependency versions should be treated as architecture pins for this story. If DEV discovers version drift in the actual `pubspec.yaml`, do not upgrade inside Story 1.2; raise a dependency maintenance follow-up.
- Official/package documentation may be newer than the architecture pins. That is not a blocker because this story uses existing Flutter widgets/runtime code and adds no package APIs.

## Project Structure Notes

- `apps/mobile/lib/main.dart` is barrel-only; anchor behavior to `lib/features/*`, `lib/runtime/*`, and `lib/domain/*`.
- Keep Home behavior in `features/home/home.dart`; keep session context plumbing in `features/session/session.dart` and `runtime/session.dart`.
- Do not add a new feature slice for check-in unless product scope expands beyond session-start context.

## References

- [Source: _bmad-output/planning-artifacts/epics.md#story-1-2]
- [Source: _bmad-output/planning-artifacts/prds/prd-meditation-community-2026-06-24/prd.md#fr-2-emotional--energy-check-in]
- [Source: _bmad-output/planning-artifacts/architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md#ad-2--session-timeline-is-the-system-of-record]
- [Source: _bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/EXPERIENCE.md#component-patterns]
- [Source: _bmad-output/planning-artifacts/ENGINEERING-RULES.md]

## Dev Agent Record

### Agent Model Used

Codex GPT-5

### Debug Log References

- `flutter test test/story_1_2_checkin_test.dart`
- `flutter test`
- `flutter analyze`

### Completion Notes List

- Xác nhận Home giữ đúng 3 `EmotionChip` inline với keys/copy `checkin-calm`, `checkin-low`, `checkin-overload`; không thêm route, sheet, dialog, hoặc CTA bắt buộc mới.
- Xác nhận plumbing hiện có truyền `_lastCheckin` qua `_SessionStartArgs.manualCheckin`, `_SessionRuntime.startSession`, timeline `manual_checkin`, rồi decode về runtime state.
- Thêm regression widget test riêng cho Story 1.2: chip render/selected state, manual check-in `low` ghi vào start event và hiện runtime `manual-low` khi confidence thấp, skip check-in vẫn vào `Session Active` với `manual_checkin == null`.
- Không sửa frozen contract `apps/mobile/test/widget_test.dart`; không thay đổi runtime/app production code vì implementation hiện tại đã đạt AC.

### File List

- /Users/lee/code/projects/elaro-med/apps/mobile/test/story_1_2_checkin_test.dart
- /Users/lee/code/projects/elaro-high/_bmad-output/implementation-artifacts/1-2-quick-emotional-energy-check-in-g-n-v-o-phi-n.md
- /Users/lee/code/projects/elaro-high/_bmad-output/implementation-artifacts/sprint-status.yaml

## Senior Developer Review (AI)

- Review outcome: PASS
- Date: 2026-06-27
- Blocker: None
- Reviewer recommendation: Story 1.2 đã pass review và được đóng.

### Action Items

- [x] [High] Stage/commit regression test file `apps/mobile/test/story_1_2_checkin_test.dart`.

## Status

- created: 2026-06-24
- create_story: done
- contexted: 2026-06-27
- dev_status: done
- code_review: done

### Change Log

- 2026-06-24: Initial backlog story created from Epic 1.
- 2026-06-26: Reconciled source behavior against `apps/mobile/`.
- 2026-06-27: Create-story workflow applied; status moved to ready-for-dev with full DEV context and guardrails.
- 2026-06-27: Implemented Story 1.2 validation coverage and moved story to review.
- 2026-06-27: Review PASS recorded; story closed as done.
