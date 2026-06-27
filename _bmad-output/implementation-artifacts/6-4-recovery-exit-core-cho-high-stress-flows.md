---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 6.4: Recovery & Exit Core cho high-stress flows

Status: backlog

## Story

As a người dùng,
I want luôn có lối thoát nhanh và khôi phục rõ ràng từ SOS, session, reflection,
So that app không kéo dài trạng thái căng thẳng.

## Acceptance Criteria

1. **Given** người dùng ở SOS entry (`/sos`) hoặc SOS active (`/sos/active`),
   **When** cần dừng ngay,
   **Then** có nút exit trong ≤2 thao tác: `sos-exit-btn` (entry), `sos-return-btn` (entry), `sos-active-exit` (active), `sos-calm-safe-return` (active, label `'Trở về Home an toàn'`). Tap → `_SessionRuntime.recordSosInterrupt(reason: 'sos_interrupt')` + `Navigator.of(context).popUntil((route) => route.isFirst)` (về Home).

2. **Given** SOS active chạy đến hết timeout (`_timeoutSeconds == 60`, `_isTimedOut`),
   **When** `_calmSafeExitTriggered` chưa set,
   **Then** trigger calm-safe exit: `_calmSafeExitTriggered = true` + `_SessionRuntime.recordSosTimeoutExit()` (event `sos_timeout_exit`) → render calm-safe state (app bar `'SOS Safe'`, headline `'Calm-safe exit: hạ cường độ, quay ra an toàn.'`) + nút `sos-calm-safe-return` (`'Trở về Home an toàn'`).

3. **Given** session bị interrupt (app background qua `didChangeAppLifecycleState(paused|inactive)` hoặc mic-change/permission-change đột ngột),
   **When** `_triggerRecovery('app-background')` hoặc tương tự fired,
   **Then** `_SessionRuntime.recordSessionInterrupted(sessionId, reason)` (event `session_interrupted`), `_recoveryReason` set, `_RecoveryChoicesCard` render.

4. **Given** `_RecoveryChoicesCard` (`session-recovery-card`) hiển thị với `reason` (vd `'app-background'`),
   **When** render,
   **Then** title `'Phiên tạm ngắt: $reason'`, sub `'Chọn một lối ra: resume, gentle-close, hoặc new session.'`, 3 nút: `session-recovery-resume` (`'resume'`), `session-recovery-close` (`'gentle-close'`), `session-recovery-new` (`'new session'`).

5. **Given** người dùng tap `session-recovery-resume` (`'resume'`),
   **When** onPressed fired,
   **Then** resume session tại state hiện tại (KHÔNG reset timer/timeline), `_recoveryReason` clear.

6. **Given** người dùng tap `session-recovery-close` (`'gentle-close'`) hoặc `session-recovery-new` (`'new session'`),
   **When** onPressed fired,
   **Then** `_leaveSession(context, reason: ...)` — close session (về Home) hoặc start new session, trong 1 thao tác từ recovery card.

7. **Given** người dùng ở session active và tap exit (X) hoặc `'Kết thúc sớm'`,
   **When** `_leaveSession(context, reason: 'manual-exit')` fired,
   **Then** session exit trong 1 thao tác, KHÔNG kéo dài trạng thái căng thẳng.

8. **Given** mọi exit path (SOS, session, recovery),
   **When** hoàn tất,
   **Then** `popUntil((route) => route.isFirst)` → về Home (`/home`) — KHÔNG để người dùng kẹt ở màn sâu.

## Code anchor

- `apps/mobile/lib/features/sos/sos.dart`:
  - `_SosEntryScreen`: `sos-exit-btn`, `sos-return-btn` → `recordSosInterrupt('sos_interrupt')` + `popUntil(isFirst)`
  - `_SosActiveScreen`: `sos-active-exit`, `sos-calm-safe-return` (`'Trở về Home an toàn'`), `_calmSafeExitTriggered`, `_isTimedOut`, `recordSosTimeoutExit()`
- `apps/mobile/lib/features/session/session.dart`:
  - `_RecoveryChoicesCard` (`session-recovery-card`, `session-recovery-resume`, `-close`, `-new`)
  - `_triggerRecovery(reason)`, `didChangeAppLifecycleState`, `_leaveSession(context, reason: 'manual-exit')`
- `apps/mobile/lib/runtime/session.dart`:
  - `_SessionRuntime.recordSosInterrupt(reason)`, `recordSosTimeoutExit()`, `recordSessionInterrupted(sessionId, reason)`

## Dev Notes

### Dev-gating note
- **Luôn hiện (không gate):** SOS exit/return buttons, calm-safe exit, recovery card, session exit (X/end-early/return-home). Đây là safety-critical UX, KHÔNG bao giờ gate.
- `DistressBoundary` trên SOS (entry `sos-distress-boundary` + active `sos-active-distress-boundary`) và Reflection (`reflection-distress-boundary`) cũng luôn hiện.

### Edge cases
- SOS repeated (<60s từ `lastStartTime`) → `_SosRuntime.evaluateMode` ép calmSafe (`reason='repeated-sos'`) — guardrail chống distress loop.
- `_calmSafeExitTriggered` guard: một khi calm-safe đã trigger, không re-trigger (`if (!mounted || _calmSafeExitTriggered || !_isTimedOut) return`).
- `_RecoveryChoicesCard` render khi `_recoveryReason != null` — nếu session bình thường (không interrupt), card KHÔNG render.
- `popUntil((route) => route.isFirst)` — về Home bất kể stack depth, đảm bảo exit path ngắn nhất.
- Back-exit (system back button) từ session active → `recordSessionInterrupted` (xem `_triggerRecovery` call sites).

### Calm/safety boundary
- **Calm escape rule (hard):** SOS, session, reflection luôn có Exit/Return trong ≤2 thao tác — KHÔNG kẹt ở màn sâu khi distress.
- **Distress loop guardrail:** SOS liên tiếp <60s → ép calm-safe, không để người dùng loop vào active mode khi đang overload.
- Recovery card cho phép resume (không mất progress) hoặc exit nhẹ — KHÔNG ép người dùng tiếp tục nếu muốn dừng.
- `popUntil(isFirst)` đảm bảo về Home — điểm an toàn, không phải màn rác.

### Known code gaps (ghi chú, KHÔNG đổi code)
- **Reconciled 2026-06-27:** `DistressBoundary` action `'Tìm hỗ trợ'` mặc định mở `_SupportResourcesSheet` trên các surface có boundary (SOS, Reflection, Settings, Permissions).
- Start/Active/Re-entry chưa có `DistressBoundary` — chỉ SOS (entry+active) + Reflection + Settings + Permissions có (xem EXPERIENCE.md Flow 3 calm boundary).
- Recovery card label vẫn EN (`'resume'`/`'gentle-close'`/`'new session'`) — chưa localize tiếng Việt.
- `_recoveryReason` là một string duy nhất — không track multiple interrupt reasons.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
