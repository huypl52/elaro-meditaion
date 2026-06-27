---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 5.1: Hiển thị anonymous presence bucket

Status: backlog

## Story

As a người dùng,
I want thấy có người cùng thiền theo khối thời gian mà không lộ thông tin cá nhân,
So that tôi cảm thấy có người đồng hành.

## Acceptance Criteria

1. **Given** người dùng vào `/presence` (`_PresenceScreen`),
   **When** render,
   **Then** title `'Hiện diện cộng đồng ẩn danh'` (key `presence-screen-title`) và privacy note `presence-privacy-note` (`'Tổng hợp dữ liệu không định danh trong không gian hiện tại; chỉ thống kê tổng, không có hồ sơ riêng lẻ.'`).

2. **Given** Presence screen hiển thị count aggregate,
   **When** render `presence-current-card` (eyebrow `'Ngay bây giờ'`),
   **Then** hiển thị `presence-current-count` (`'$_currentParticipants người'`, init `184`) kèm `PresenceDotCluster(dots: 4)` và sub `'Nguồn: tổng hợp theo thời gian thực'`.

3. **Given** Presence screen hiển thị history aggregate,
   **When** render `presence-history-card` (eyebrow `'7 ngày qua'`),
   **Then** hiển thị `presence-history-count` (`'$_weeklySessions điểm tương tác trong 7 ngày gần nhất'`, init `920`) kèm sub `'Không hiển thị người dùng riêng lẻ, chỉ số tổng.'`.

4. **Given** người dùng tap `presence-refresh` (`'Làm mới'`),
   **When** `_refreshPresence()` fired,
   **Then** `_currentParticipants = (_currentParticipants + 17) % 300` (mock refresh 0–299), `_weeklySessions += 1`, reset `_elapsedSinceSync = Duration.zero`, cập nhật `_lastSyncedAt = DateTime.now().

5. **Given** Presence chỉ là aggregate-only,
   **When** widget test kiểm tra,
   **Then** `find.textContaining('Username')` / `find.textContaining('Chat')` / `find.byKey` avatar widget → **findsNothing** — KHÔNG có tên, chat, profile, avatar cá nhân.

6. **Given** `_elapsedSinceSync >= _presenceTtl` (12 giây),
   **When** render (stale state),
   **Then** `presence-current-count` → **findsNothing** (ẩn count), `presence-stale-badge` (`'Stale'`) hiển thị, `presence-last-updated` (`'Cập nhật lần cuối: $_lastUpdatedLabel'`) hiển thị, `CommunityPresenceBand` hiển thị message `'Hiện diện cộng đồng sẽ cập nhật khi có kết nối.'`, RoomCard `restingCount: 0`.

7. **Given** `_currentParticipants == 0` và data còn fresh, **When** render, **Then** screen hiển thị `presence-empty-message` + CTA `presence-empty-refresh` (`'Làm mới hiện diện'`), **And** RoomCard/Presence vẫn aggregate-only (không chat/profile/feed).

## Code anchor

- `apps/mobile/lib/features/presence/presence.dart`:
  - `_PresenceScreen` / `_PresenceScreenState`
  - `_presenceTtl = Duration(seconds: 12)`, `_currentParticipants = 184`, `_weeklySessions = 920`
  - `_refreshPresence()` → `_currentParticipants = (_currentParticipants + 17) % 300` (range 0–299)
  - `presence-screen-title`, `presence-privacy-note`, `presence-current-count`, `presence-history-count`, `presence-stale-badge`, `presence-last-updated`, `presence-refresh`, `presence-empty-message`, `presence-empty-refresh`
- `apps/mobile/lib/components/presence/presence.dart`: `CommunityPresenceBand`, `RoomCard`, `PresenceDotCluster`

## Dev Notes

### Dev-gating note
Presence là **user-facing, luôn hiện** — không DevSection, không gate. Count, privacy note, refresh đều là core UX.

### Edge cases
- Count refresh là mock deterministic: `(count + 17) % 300` — range mới 0–299, không random thực, không sync backend.
- `_lastUpdatedLabel` format: `toLocal().toIso8601String().substring(0,19).replaceFirst('T', ' ')` — hiển thị local time.
- Ticker `Timer.periodic(1s)` increment `_elapsedSinceSync` mỗi giây — stale swap xảy ra chính xác sau 12s không refresh.
- `_isStale` check: `_elapsedSinceSync >= _presenceTtl` — once stale, cần `presence-refresh` để reset.

### Calm/safety boundary
- **Aggregate-only hard rule:** KHÔNG có tên/chat/profile/avatar/follow — chỉ count tổng + history tổng. Widget test assert confirms.
- Privacy note hiển thị rõ ngay đầu screen — người dùng biết dữ liệu là tổng hợp không định danh.
- Stale state ẩn count mới để tránh misinformation — không hiển thị số liệu cũ có thể sai.

### Known code gaps (ghi chú, KHÔNG đổi code)
- **Reconciled 2026-06-27:** empty-state aggregate-only đã có khi count = 0 (`presence-empty-message` + `presence-empty-refresh`).
- Count vẫn là mock deterministic, không sync thật — là placeholder cho backend presence cleanup job.
- `_weeklySessions` increment mỗi refresh — không decay theo thời gian thực.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
