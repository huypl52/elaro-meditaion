---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 5.2: Join quiet presence block

Status: backlog

## Story

As a người dùng muốn thiền cùng nhịp,
I want tham gia block có hiện diện dễ dàng,
So that tôi vẫn giữ không gian riêng tư.

## Acceptance Criteria

1. **Given** người dùng ở Presence screen (`/presence`) với `_joined == false`,
   **When** render `presence-join` button (`'Tham gia'`, icon `group_outlined`, fill `primaryContainer`),
   **Then** button enabled (`onPressed: _joinPresence`), hiển thị trạng thái `presence-current-state` (`'Chưa tham gia'`) + `presence-current-state-description` (`'Bạn chưa tham gia block hiện diện ẩn danh'`).

2. **Given** người dùng tap `presence-join` (`'Tham gia'`),
   **When** `_joinPresence()` fired,
   **Then** `_joined = true`, `_currentParticipants += 1`, button `presence-join` trở thành disabled (`onPressed: null`), button `presence-leave` trở thành enabled, sub `'Duy trì ẩn danh, không lưu danh tính.'` hiển thị.

3. **Given** người dùng đã join (`_joined == true`),
   **When** render `presence-leave` button (`'Rời block'`, icon `logout_rounded`),
   **Then** button enabled (`onPressed: _leavePresence`), trạng thái `presence-current-state` (`'Đang tham gia'`) + description (`'Bạn đang ở block hiện diện ẩn danh'`).

4. **Given** người dùng tap `presence-leave` (`'Rời block'`),
   **When** `_leavePresence()` fired,
   **Then** `_joined = false`, `_currentParticipants = _currentParticipants > 0 ? _currentParticipants - 1 : 0` (floor 0), button `presence-join` enabled lại, button `presence-leave` disabled.

5. **Given** Presence chỉ là aggregate join/leave,
   **When** join/leave fired,
   **Then** KHÔNG tạo social graph, KHÔNG follow, KHÔNG chat, KHÔNG profile — chỉ increment/decrement count aggregate. RoomCard (`'Phòng tĩnh lặng'`, subtitle `'Không gian ẩn danh — chỉ đếm số người đang tĩnh tại.'`) cập nhật `restingCount` theo `_currentParticipants` (hoặc 0 khi stale).

6. **Given** `_isStale == true`,
   **When** render RoomCard,
   **Then** `restingCount: 0` (không hiển thị count mới khi stale), RoomCard vẫn render nhưng count = 0.

## Code anchor

- `apps/mobile/lib/features/presence/presence.dart`:
  - `_PresenceScreenState`: `_joined`, `_joinPresence()`, `_leavePresence()`
  - `presence-join` (`'Tham gia'`), `presence-leave` (`'Rời block'`), `presence-current-state` (`'Đang tham gia'` / `'Chưa tham gia'`), `presence-current-state-description`
  - `RoomCard` (title `'Phòng tĩnh lặng'`, subtitle `'Không gian ẩn danh — chỉ đếm số người đang tĩnh tại.'`)
- `apps/mobile/lib/components/presence/presence.dart`: `RoomCard`

## Dev Notes

### Dev-gating note
Join/leave là **user-facing, luôn hiện** — không DevSection, không gate. State membership là core UX.

### Edge cases
- Join khi `_joined == true` là no-op (`if (!_joined)` guard) — không double-count.
- Leave khi `_joined == false` là no-op (`if (_joined)` guard) — không negative count.
- Count floor 0: `_currentParticipants > 0 ? - 1 : 0` — không bao giờ âm.
- RoomCard `onJoin: _joined ? null : _joinPresence` — join callback chỉ active khi chưa join.

### Calm/safety boundary
- **Non-social hard rule:** join/leave chỉ tác động count aggregate, KHÔNG tạo graph/follow/chat/profile.
- Membership ẩn danh — sub `'Duy trì ẩn danh, không lưu danh tính.'` nhấn mạnh khi đã join.
- RoomCard mô tả rõ `'Không gian ẩn danh — chỉ đếm số người đang tĩnh tại.'` — thiết lập kỳ vọng calm.

### Known code gaps (ghi chú, KHÔNG đổi code)
- `_joined` là local state trong `_PresenceScreenState` — KHÔNG persist (in-memory), reset khi rời screen.
- Join/leave KHÔNG append event vào `SessionTimeline` — không có audit trail membership.
- Không có "leave block" CTA riêng trong RoomCard — chỉ có nút `presence-leave` ở cuối screen.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
