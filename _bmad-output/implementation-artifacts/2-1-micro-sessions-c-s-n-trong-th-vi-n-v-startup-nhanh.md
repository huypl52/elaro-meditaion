---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 2.1: Micro sessions có sẵn trong thư viện và startup nhanh

Status: done

## Story

As a người dùng,
I want có các phiên 20 giây, 45 giây, 90 giây, 3 phút,
So that tôi có thể bắt đầu nhanh với phiên phù hợp.

## Acceptance Criteria

1. **Given** người dùng vào `_SessionStartScreen`, **When** màn render, **Then** headline `'Chọn micro session'` và các EmotionChip duration có key `micro-20s`/`micro-45s`/`micro-90s`/`micro-3m` với label `20s`/`45s`/`90s`/`3m`, ứng với `_SessionStartArgs` durations `[20,45,90,180]`.

2. **Given** người dùng chọn 1 chip, **When** chạm `session-start-btn`, **Then** `_StartupMode` được **derive** từ duration: ≤90s → `microFast` (startup 250ms); else (`180s`/3m) → `standard` (startup 1100ms) — **không** chọn mode/type trên UI.

3. **Given** đang chờ startup, **When** loading, **Then** startup note `'Đang khởi động nhanh (micro fast/standard)'` hiển thị, **And** loading state `session-start-loading` áp dụng.

4. **Given** startup hoàn tất, **When** timer chờ kết thúc (250ms microFast / 1100ms standard), **Then** điều hướng tới `/session/active`.

5. **Given** phiên micro bắt đầu, **When** runtime ghi event, **Then** event `start` được append vào timeline (Growth Map `totalSessionCount` tăng) — mỗi phiên micro được ghi nhận như session event.

6. **Given** thiết bị trong điều kiện băng thông hạn chế/offline, **When** bắt đầu micro session, **Then** nội dung vẫn chạy ổn định trên local bundle/cache (offline-first).

## Code anchor

`apps/mobile/lib/features/session/session.dart` — `_SessionStartScreen`, `_SessionStartArgs` (durations `[20,45,90,180]`), chips `micro-20s`/`micro-45s`/`micro-90s`/`micro-3m`, `session-start-btn`, `_StartupMode` (derive microFast vs standard), startup note `'Đang khởi động nhanh (micro fast/standard)'`, `session-start-loading`; timeline `start` event → `_SessionRuntime.totalSessionCount` (xem `apps/mobile/lib/runtime/session.dart`).

## Dev Notes

- **Startup mode derive, không chọn:** mode/type không phải input UI — `_StartupMode` thuần tính toán từ duration. Đây là calming constraint: giảm quyết định người dùng phải đưa ra.
- **Startup note / loading:** `'Đang khởi động nhanh (micro fast/standard)'` + `session-start-loading` cho người dùng biết app đang phản hồi (không lag im lặng).
- **Timeline = system of record:** mỗi phiên (kể cả micro) ghi event `start`; Growth totals derive từ timeline, không phải biến riêng.
- **Offline-first:** micro session chạy local; không phụ thuộc fetch network để bắt đầu.
- **Known debt / follow-up:** `_SessionType{focus,sleep}` vẫn không chọn trên UI (dead/dormant), nhưng CTA `before-sleep` nay đã có route handler riêng trong `main.dart`. App bar `Session start` vẫn giữ EN do `apps/mobile/test/widget_test.dart` khóa contract i18n.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: done
- code_review: PASS

## Change Log

- 2026-06-27: Create-story workflow applied; status moved to ready-for-dev.
- 2026-06-27: Implemented Story 2.1: micro duration chips (`micro-20s`/`micro-45s`/`micro-90s`/`micro-3m`), startup mode derivation, `session-start-loading` note + delays, `/session/active` navigation, and timeline start event recording.
- 2026-06-27: Added focused Story 2.1 test coverage in `apps/mobile/test/story_2_1_micro_session_startup_test.dart`.
- 2026-06-27: Updated story/sprint state to review.
- 2026-06-27: Story 2.1 closed as PASS after review by worker-rustic-giang.

## Dev Agent Record

- Implemented in:
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/features/session/session.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/runtime/session.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/domain/timeline.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/test/story_2_1_micro_session_startup_test.dart`
- Evidence summary:
  - Added micro duration chips with required keys and labels on `_SessionStartScreen`.
  - Derived startup mode from duration and enforced startup timing rules: microFast 250ms, standard 1100ms.
  - Added startup loading copy and key `session-start-loading`.
  - Logged session start via timeline event type `sessionStart` with route/duration/startup mode payload for growth aggregation.
