---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 2.4: Session runtime hỗ trợ noise-aware mode baseline

Status: done

## Story

As a người dùng ở môi trường ồn,
I want flow không ngắt vì noise context chưa sẵn,
So that tôi vẫn có trải nghiệm liên tục.

## Acceptance Criteria

1. **Given** người dùng chưa cấp quyền microphone khi vào flow noise-aware, **When** session khởi tạo, **Then** app fallback sang **manual context** dẫn xuất từ check-in `_CheckinState {calm, low, overload}` → `manual-calm`/`manual-low`/`manual-overload` (KHÔNG dùng nhãn `yên/vừa/ồn`), với copy `'Context thủ công: manual-${checkinName}'` và nhãn `'độ tin cậy thấp'`.

2. **Given** người dùng chưa cấp quyền mic, **When** app render context, **Then** **không** hiển thị claim dựa trên dữ liệu noise chưa có (không "phát hiện môi trường ồn" khi không có sensor).

3. **Given** quyền mic bị từ chối **giữa phiên**, **When** session đang chạy, **Then** runtime gọi `dropEnrichment()` (đặt mic=false, confidence=0.2), **And** hiển thị recovery card `session-recovery-card`, **And** **KHÔNG reset timer hay timeline**, **And** copy `'Enrichment: bỏ qua (thiếu quyền mic)'`.

4. **Given** `confidence < 0.6` (`isLowConfidence`), **When** hệ thống ước lượng noise, **Then** UI hiển thị nhãn `'độ tin cậy thấp'`, **And** chỉ dùng context thủ công đã chọn (`manual-calm`/`manual-low`/`manual-overload`).

5. **Given** session interrupted (app background / mic denied mid-session), **When** người dùng quay lại, **Then** `_RecoveryChoicesCard` (`session-recovery-card`) cho 3 lựa chọn: `session-recovery-resume` (`'resume'`), `session-recovery-close` (`'gentle-close'`), `session-recovery-new` (`'new session'`).

## Code anchor

`apps/mobile/lib/features/session/session.dart` — `_RecoveryChoicesCard` (`session-recovery-card`), manual context copy `'Context thủ công: manual-${checkinName}'`, `'độ tin cậy thấp'`, `'Enrichment: bỏ qua (thiếu quyền mic)'`; `apps/mobile/lib/runtime/session.dart` — `dropEnrichment()` (mic=false, confidence=0.2), `isLowConfidence` (conf<0.6). `_CheckinState {calm, low, overload}` tại `apps/mobile/lib/features/home/home.dart`. `apps/mobile/lib/runtime/microphone_permission_runtime.dart` — permission preflight + event/listenable stream for mid-session runtime drop.

## Dev Notes

- **Manual context dùng `_CheckinState`, không `yên/vừa/ồn`:** đây là reconciled gap quan trọng (Known gap #1) — code dùng `calm/low/overload` (từ Story 1.2 check-in), spec cũ `yên/vừa/ồn` đã bị loại. Bất kỳ spec nào nhắc `yên/vừa/ồn` là lỗi.
- **Không claim giả:** khi thiếu sensor, app KHÔNG hiển thị "đã phát hiện môi trường ồn" — chỉ manual context + nhãn `'độ tin cậy thấp'`. Đây là ranh giới NFR8 (không claim chẩn đoán) + AD-15 (permission fallback không chặn core flow).
- **Mid-session mic denied không phá phiên:** `dropEnrichment()` chỉ tắt enrichment (mic=false, conf=0.2) + recovery card; timer/timeline tiếp tục — người dùng không bị gián đoạn vì quyền.
- **Low-confidence threshold:** `isLowConfidence` = conf < 0.6; dưới ngưỡng → chỉ manual context, không auto-adjust.
- **Dev-gating:** noise confidence toggle (`session-noise-confidence-toggle`) nằm sau `DevSection`; release ẩn sạch.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: done
- code_review: PASS

## Change Log

- 2026-06-27: Session runtime low-confidence logic moved to `SessionTimerState.lowConfidenceThreshold = 0.6` and added `isLowConfidence` and `dropEnrichment()` in `apps/mobile/lib/runtime/session.dart`.
- 2026-06-27: Session active screen now uses mutable runtime timer state (`_timerState`) so `dropEnrichment` can be applied mid-session without rebuilding args.
- 2026-06-27: Implemented noise fallback UI on active screen:
  - `Context thủ công: manual-${checkin}` and `độ tin cậy thấp` rendering when using manual context.
  - `_RecoveryChoicesCard` with keys `session-recovery-card`, `session-recovery-resume`, `session-recovery-close`, `session-recovery-new`.
  - `Enrichment: bỏ qua (thiếu quyền mic)` copy when enrichment is dropped.
- 2026-06-27: Added recovery actions:
  - Resume (`_onRecoveryResume`), close (`_onRecoveryClose`), new session (`_onRecoveryNew`).
  - Dev-only `session-noise-confidence-toggle` added in `DevSection` to invoke `dropEnrichment` path in session flow.
- 2026-06-27: Added focused test coverage in `apps/mobile/test/story_2_4_noise_aware_test.dart` for:
  - low-confidence threshold behavior,
  - runtime drop enrichment behavior,
  - no-mic/manual context copy,
  - interruption recovery card keys,
  - mid-session enrichment drop copy/timeline baseline behavior.
- 2026-06-27: Updated sprint state for `2-4-session-runtime-h-tr-noise-aware-mode-baseline` to `review` in `apps/mobile/...`.
- 2026-06-27: Added production permission-preflight/runtime owner `apps/mobile/lib/runtime/microphone_permission_runtime.dart`, wired `/session/start` preflight into `SessionStartArgs`/`SessionActiveScreen`, and updated recovery/re-entry flows to consume runtime permission state.
- 2026-06-27: Reworked mid-session denied path to react to runtime permission stream so `dropEnrichment` fires automatically when mic permission becomes missing (no manual dev-only-only dependency).

## Dev Agent Record

- Implemented in:
- `/Users/lee/code/projects/elaro-high/apps/mobile/lib/runtime/session.dart`
- `/Users/lee/code/projects/elaro-high/apps/mobile/lib/features/session/session.dart`
- `/Users/lee/code/projects/elaro-high/apps/mobile/test/story_2_4_noise_aware_test.dart`
- `/Users/lee/code/projects/elaro-high/apps/mobile/lib/runtime/microphone_permission_runtime.dart`
- Updated artifacts:
  - `/Users/lee/code/projects/elaro-high/_bmad-output/implementation-artifacts/2-4-session-runtime-h-tr-noise-aware-mode-baseline.md`
  - `/Users/lee/code/projects/elaro-high/_bmad-output/implementation-artifacts/sprint-status.yaml`

## Validation

- `cd /Users/lee/code/projects/elaro-high/apps/mobile && flutter test test/story_2_4_noise_aware_test.dart`
- `cd /Users/lee/code/projects/elaro-high/apps/mobile && flutter analyze`
