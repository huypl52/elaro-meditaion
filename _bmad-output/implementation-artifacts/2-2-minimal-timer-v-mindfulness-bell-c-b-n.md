---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 2.2: Minimal timer và mindfulness bell cơ bản

Status: done

## Story

As a người dùng đã quen thiền,
I want chỉnh thời lượng và nghe bell theo mốc,
So that phiên chạy theo nhu cầu mà không phức tạp.

## Acceptance Criteria

1. **Given** người dùng ở session player (`/session/active`), **When** phiên chạy, **Then** bề mặt user-facing là calm-first gồm `SoftTimer` (clock `MM:SS`, serif lớn thấp độ nổi) + `ProgressRing(size:220)` + `BreathingCircle(maxSize:120, 4s phase)` + `SessionStateLabel`.

2. **Given** phiên running, **When** `SessionStateLabel` render, **Then** hiển thị `'Cùng nhau thở.'` / `'Giữ nhịp chậm — không cần hoàn hảo.'`; paused → `'Nghỉ một nhịp.'`; complete → `'Phiên đã hoàn tất.'` / `'Bạn có thể dừng ở đây.'`.

3. **Given** người dùng chọn duration từ `_durations=[20,45,90,180]`, **When** `_resolveBellCues` tính bell presets, **Then** bell mốc: ≤20s → `[5,10,15]`; ≤45s → `[5,15,35]`; ≤90s → `[15,45,75]`; else → `[45,90,135,175]`.

4. **Given** phiên bị pause hoặc app bị interrupt, **When** người dùng quay lại, **Then** trạng thái timer tiếp tục theo timeline policy (resume/close safely qua `session-recovery-card`), **And** không bị mất dữ liệu completion.

5. **Given** phiên chạy, **When** điểm bell tới, **Then** haptic `selection` kích; start → `medium`; complete → `medium`; pause → `selection`; resume → `light`.

6. **Given** phiên chạy, **When** xem session player, **Then** mọi runtime telemetry / debug-QA (mode, offline, source, elapsed, bell status, noise confidence, mic toggle, runtime-event label) nằm **sau `DevSection('Session telemetry')`** — chỉ hiện debug/test, **ẩn sạch ở release** (`--dart-define=ELARO_RELEASE=true`).

7. **Given** người dùng cần kết thúc, **When** thao tác, **Then** có `'Kết thúc sớm'` (GhostTextButton, reason `manual-exit`) và `session-return-home` (`'Kết thúc và về Home'`), **And** `session-pause-btn` (`'Tạm dừng'`) / `session-resume-btn` (`'Tiếp tục'`).

## Code anchor

`apps/mobile/lib/features/session/session.dart` — `_SessionActiveScreen`, `SoftTimer`, `ProgressRing` (size 220), `BreathingCircle` (maxSize 120, 4s phase), `SessionStateLabel`, `_resolveBellCues`, controls `session-pause-btn`/`session-resume-btn`/`'Kết thúc sớm'`/`session-return-home`; `apps/mobile/lib/components/breathing/breathing.dart` — `BreathingCircle`; `DevSection('Session telemetry')` (`apps/mobile/lib/dev/dev_section.dart`); haptic types trong `HapticFeedbackType {light, medium, selection}`.

## Dev Notes

- **Calm-player pattern:** `SoftTimer` + `ProgressRing` + `BreathingCircle` + `SessionStateLabel` là giao diện luôn hiện (không gate). Người dùng nhìn vào thấy nhịp thở + thời gian, không thấy metric kỹ thuật.
- **Haptic-first:** haptic dẫn nhịp (start/complete `medium`, bell `selection`, pause `selection`, resume `light`); Reduce Motion → text/haptic pacing thay thế (xem `_AccessibilityRuntime.hapticsEnabled`).
- **Bell presets theo duration:** không cấu hình tay — `_resolveBellCues` derive từ band thời lượng, giữ UI tối giản.
- **Dev-gating (AC 6 — cross-cutting):** mọi telemetry phải sau `DevSection`; `DevGate.enabled` = `kElaroRelease ? false : (override ?? kDevMode)`. Missed dart-define → fail-safe dev ON (không rò rỉ debug vào production). Áp dụng cho mọi story chạm telemetry (2.1, 2.4, 3.5, 6.2, 6.6).
- **Known code gap (KHÔNG đổi code):** `BreathingCircle.onPhaseChange` dead; labels `Inhale`/`Exhale` vẫn EN trong UI tiếng Việt (cần localize sau).

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: done
- code_review: PASS

### Change Log

- 2026-06-27: Implemented Story 2.2 active session calm-player flow, including `_SessionActiveScreen`, `SoftTimer`, `ProgressRing(size: 220)`, `BreathingCircle(maxSize: 120, 4s phase)`, and `SessionStateLabel` in calm-first layout.
- 2026-06-27: Implemented `resolveBellCues` duration bands and bell/runtime event timeline for pause/resume/recovery/complete/manual-exit, including completion-safe `session-recovery-card` path.
- 2026-06-27: Added ghost close + return controls (`Kết thúc sớm`, `session-return-home`) plus pause/resume controls with timeline events and haptic routing (`medium`/`selection`/`light`).
- 2026-06-27: Added runtime-dev telemetry panel behind `DevSection('Session telemetry')` with mode/offline/source/elapsed/bell status/noise confidence/mic toggle/runtime-event label; added Vietnamese session status copy.
- 2026-06-27: Added focused Story 2.2 test coverage in `apps/mobile/test/story_2_2_minimal_timer_test.dart`.
- 2026-06-27: Updated sprint state to review.

## Dev Agent Record

- Implemented in:
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/components/breathing/breathing.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/domain/timeline.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/runtime/session.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/features/session/session.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/test/story_2_2_minimal_timer_test.dart`
  - `/Users/lee/code/projects/elaro-high/_bmad-output/implementation-artifacts/sprint-status.yaml`
