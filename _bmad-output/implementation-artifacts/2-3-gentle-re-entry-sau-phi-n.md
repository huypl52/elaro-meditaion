---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 2.3: Gentle re-entry sau phiên

Status: done

## Story

As a người dùng sau khi hoàn tất phiên,
I want có màn hình kết thúc nhẹ nhàng,
So that tôi quay lại trạng thái bình ổn, không gián đoạn.

## Acceptance Criteria

1. **Given** phiên hoàn tất (`/session/{id}/re-entry` + inline card khi complete), **When** `_SessionReEntryScreen` render, **Then** eyebrow `'Kết thúc nhẹ nhàng'`, headline `'Re-entry sau phiên'`, và reassurance `'Lời nhắc nhẹ: thở chậm 1 nhịp rồi chọn bước kế tiếp.'`.

2. **Given** re-entry render, **When** hiển thị `TertiaryStackCTA`, **Then** có đúng 3 lựa chọn kế tiếp: `session-reentry-stop` (`'Dừng & về Home'`), `session-reentry-repeat` (`'Lặp lại'` → `/session/start`), `session-reentry-followup` (`'Phản chiếu phiên'` → reflection).

3. **Given** người dùng muốn dừng ngay, **When** chạm `session-reentry-stop` (`'Dừng & về Home'`), **Then** luồng về Home giữ nguyên context phiên hiện tại cho lần quay lại tiếp theo.

4. **Given** người dùng muốn lặp, **When** chạm `session-reentry-repeat` (`'Lặp lại'`), **Then** điều hướng tới `/session/start` để bắt đầu phiên mới.

5. **Given** người dùng muốn phản chiếu, **When** chạm `session-reentry-followup` (`'Phản chiếu phiên'`), **Then** điều hướng tới reflection (`/session/{id}/reflection`).

6. **Given** re-entry render, **When** màn hiển thị, **Then** không có confetti/celebration quá đà — chỉ copy dịu nhẹ + 3 lựa chọn kế tiếp (calm-first, không pressure), **And** nội dung re-entry/completion vẫn scroll được khi text scale lớn.

7. **Given** session complete render trên `_SessionActiveScreen`, **When** completion surface hiện, **Then** `session-reentry-card` vẫn là khối đầu tiên và slot mindful nudge `session-active-*` render ngay sau card, gentle/dismissible.

## Code anchor

`apps/mobile/lib/features/session/session.dart` — `_SessionReEntryScreen`, `_buildReentryCard`, `TertiaryStackCTA` với các key `session-reentry-stop`/`session-reentry-repeat`/`session-reentry-followup`; routes `/session/{id}/re-entry` và `/session/start`; reflection route `/session/{id}/reflection`.

## Dev Notes

- **Hạ cánh nhẹ:** re-entry là điểm chuyển trạng thái quan trọng — eyebrow + headline + reassurance (`'Lời nhắc nhẹ: thở chậm 1 nhịp rồi chọn bước kế tiếp.'`) giữ người dùng không bị giật ra khỏi trạng thái thiền.
- **3 lựa chọn tối giản:** stop / repeat / follow-up — đủ để người dùng chọn hướng đi mà không quá tải. Đây là `TertiaryStackCTA` (luôn hiện, không dev-gated).
- **UX-DR14:** completion nhẹ nhàng, không confetti/celebration dã. Re-entry là text/haptic dịu nhẹ, không animation quá đà.
- **Calm escape:** `session-reentry-stop` (`'Dừng & về Home'`) đảm bảo lối thoát trong ≤2 thao tác về Home; context phiên được giữ cho continuity.
- **Known code gap (KHÔNG đổi code):** Start/Active/Re-entry chưa có `DistressBoundary` (chỉ Reflection có `reflection-distress-boundary`). Re-entry route cũng là inline card khi complete, không chỉ màn riêng.

## Dev Agent Record

- Implemented in:
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/features/session/session.dart`:
    - Added `_SessionReEntryScreen`, `SessionReEntryArgs`, `SessionReflectionArgs`, `_SessionReEntry` flow behavior.
    - Added `_buildReentryCard` and `TertiaryStackCTA` with exact copy and route actions:
      - `session-reentry-stop` -> `/home`
      - `session-reentry-repeat` -> `/session/start`
      - `session-reentry-followup` -> `/session/{id}/reflection`
    - Added scrollable post-session gentle nudge slot `session-active-mindful-nudge-card` rendered after re-entry card.
    - Preserved existing complete behavior by switching to inline re-entry surface in active flow.
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/main.dart`:
    - Added dynamic route handlers for `/session/{id}/re-entry` and `/session/{id}/reflection`.
  - `/Users/lee/code/projects/elaro-high/apps/mobile/test/story_2_3_reentry_test.dart` (new):
    - Added focused coverage cho re-entry copy/CTAs/actions and direct route deep-link.
- Validation commands run:
  - `cd /Users/lee/code/projects/elaro-high/apps/mobile && flutter test test/story_2_2_minimal_timer_test.dart test/story_2_3_reentry_test.dart`
  - `cd /Users/lee/code/projects/elaro-high/apps/mobile && flutter test test/story_2_3_reentry_test.dart`
  - `cd /Users/lee/code/projects/elaro-high/apps/mobile && flutter analyze`
- Notes:
  - `flutter analyze` returns clean after updating text scale test setup to `textScaler`.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: done
- code_review: PASS
