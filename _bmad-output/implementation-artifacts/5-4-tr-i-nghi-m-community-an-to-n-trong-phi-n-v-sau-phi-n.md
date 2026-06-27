---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 5.4: Trải nghiệm community an toàn trong phiên và sau phiên

Status: backlog

## Story

As a người dùng,
I want thấy community ở mức có chọn lọc,
So that trải nghiệm vẫn calm-first.

## Acceptance Criteria

1. **Given** Presence screen (`/presence`) render mindful nudge slot (`slotKeyPrefix: 'presence'`),
   **When** nudge render,
   **Then** các key `presence-mindful-nudge-card`, `presence-mindful-nudge-skip` (`'Bỏ qua hôm nay'`), `presence-mindful-nudge-disable` (`'Tắt gợi ý'`), `presence-mindful-nudge-restore` (`'Hiện lại'`), `presence-mindful-nudge-enable` (`'Bật lại'`) hiển thị đúng — community touch duy nhất trong presence là nudge aggregate-only.

2. **Given** Presence chỉ hiển thị aggregate count + nudge,
   **When** widget test kiểm tra social elements,
   **Then** `find.textContaining('feed')`, `find.textContaining('chat')`, `find.textContaining('profile')`, `find.textContaining('avatar')` → **findsNothing** — KHÔNG có feed, chat, comment, profile, avatar ở bất kỳ đâu trong presence.

3. **Given** người dùng hoàn tất session và vào re-entry/reflection flow,
   **When** render post-session suggestions,
   **Then** **KHÔNG có mindful nudge post-session** — nudge chỉ tồn tại ở slots Home / Growth / Presence, KHÔNG đặt sau phiên (code gap đã reconcile so với AC intent epics).

4. **Given** community surface chỉ là presence (aggregate) + nudge (preset),
   **When** trải nghiệm overall,
   **Then**维持在 calm-first: tối đa 1–2 community touch nhẹ (presence band trên Home là static `'Có người đang ngồi yên cùng bạn lúc này.'`, nudge là preset opt-out) — KHÔNG infinite feed, KHÔNG notification guilt, KHÔNG public comment, KHÔNG chat composer.

5. **Given** nudge body text hiển thị trong mọi slot,
   **When** render,
   **Then** body verbatim `'Preset yên tĩnh, aggregate-only, không tạo social graph. Có thể bỏ qua bất cứ lúc nào.'` — khẳng định ranh giới non-social trên mọi community touch.

## Code anchor

- `apps/mobile/lib/features/presence/presence.dart`: `_MindfulNudgeSlot(slotKeyPrefix: 'presence', slotLabel: 'Presence')`, presence aggregate-only (`presence-current-count`, `presence-history-count`)
- `apps/mobile/lib/features/mindful_nudge/mindful_nudge.dart`: `_MindfulNudgeSlot` / `_MindfulNudgePreset`, `_MindfulNudgeRuntime`
- `apps/mobile/lib/components/presence/presence.dart`: `CommunityPresenceBand` (Home band static message)
- `apps/mobile/lib/features/home/home.dart`: `home-presence-band` (`'Có người đang ngồi yên cùng bạn lúc này.'`)

## Dev Notes

### Dev-gating note
Community surfaces (presence, nudge) là **user-facing, luôn hiện** — không DevSection, không gate.

### Edge cases
- Nudge disable là global (`_MindfulNudgeRuntime.enabled`) — tắt ở Presence tắt luôn Home + Growth (xem Story 5.3).
- Presence band trên Home là static message, KHÔNG hiển thị count (count chỉ ở `/presence` screen).
- Presence stale (TTL 12s) ẩn count nhưng nudge slot vẫn render bình thường (nudge không phụ thuộc presence sync).

### Calm/safety boundary
- **Banned elements hard rule (xem EXPERIENCE.md Interaction Primitives):** streak prompts, infinite feed, notification guilt, public comment, chat composer, heatmap áp lực, meditation score, celebration quá đà — tất cả KHÔNG tồn tại trong code.
- Community chỉ là "cảm giác đồng hành" qua count aggregate + nudge preset — không biến thành social platform.
- Nudge body text lặp lại cam kết non-social trên mọi slot.

### Known code gaps (ghi chú, KHÔNG đổi code)
- **Nudge KHÔNG post-session** — AC intent epics Story 5.4 nói "sau phiên" nhưng code chỉ đặt nudge ở Home/Growth/Presence. Đây là code gap đã reconcile (xem EXPERIENCE.md Flow 10, Known gaps #4).
- Presence không empty-state — khi chưa có data, vẫn hiển thị mock count.
- KHÔNG có "post-session suggestions" với nudge — re-entry chỉ có stop/repeat/follow-up (reflection), không có community element.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
