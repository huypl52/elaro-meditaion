---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 5.3: Mindful nudge preset

Status: backlog

## Story

As a người dùng,
I want gửi/nhận nudge ngắn theo preset,
So that tôi có thể hỗ trợ nhắc nhở nhẹ không gây áp lực.

## Acceptance Criteria

1. **Given** mindful nudge slot render tại Home (`slotKeyPrefix: 'home'`), Growth (`'growth'`), hoặc Presence (`'presence'`),
   **When** `_MindfulNudgeRuntime.enabled == true` và `_skipped == false`,
   **Then** hiển thị card với key `${prefix}-mindful-nudge-card`, title `${prefix}-mindful-nudge-title` (`'Nhắc nhẹ preset • ${slotLabel}'`), body verbatim `'Preset yên tĩnh, aggregate-only, không tạo social graph. Có thể bỏ qua bất cứ lúc nào.'`.

2. **Given** card hiển thị 2 preset,
   **When** render preset buttons,
   **Then** có `'Thở 20s'` (key `${prefix}-mindful-nudge-20s`, detail `'Một nhịp ngắn để hạ tốc độ.'`, route `/session/micro/20s`) và `'Thả lỏng 45s'` (key `${prefix}-mindful-nudge-45s`, detail `'Preset nhẹ, không theo dõi xã hội.'`, route `/session/micro/45s`).

3. **Given** người dùng tap preset button (vd `${prefix}-mindful-nudge-20s`),
   **When** onPressed fired,
   **Then** navigate `Navigator.of(context).pushNamed(preset.route)` → `/session/micro/20s` (hoặc `/session/micro/45s`).

4. **Given** người dùng tap `${prefix}-mindful-nudge-skip` (`'Bỏ qua hôm nay'`),
   **When** onPressed fired,
   **Then** `_skipped = true`, card chuyển sang skipped state với key `${prefix}-mindful-nudge-skipped` (text `'Nhắc nhẹ đã được ẩn cho phần này.'`) + nút `${prefix}-mindful-nudge-restore` (`'Hiện lại'`).

5. **Given** người dùng tap `${prefix}-mindful-nudge-restore` (`'Hiện lại'`),
   **When** onPressed fired,
   **Then** `_skipped = false`, card quay lại hiển thị preset đầy đủ.

6. **Given** người dùng tap `${prefix}-mindful-nudge-disable` (`'Tắt gợi ý'`),
   **When** onPressed fired,
   **Then** `_MindfulNudgeRuntime.enabled = false` (global static), slot chuyển sang disabled state với key `${prefix}-mindful-nudge-disabled` (text `'Nhắc nhẹ đang tắt.'`) + nút `${prefix}-mindful-nudge-enable` (`'Bật lại'`).

7. **Given** người dùng tap `${prefix}-mindful-nudge-enable` (`'Bật lại'`),
   **When** onPressed fired,
   **Then** `_MindfulNudgeRuntime.enabled = true`, slot quay lại hiển thị preset.

8. **Given** một phiên hoàn tất (`_isComplete == true` trên `_SessionActiveScreen`),
   **When** session completion render,
   **Then** hiển thị post-session mindful nudge `_MindfulNudgeSlot(slotKeyPrefix: 'session-active', slotLabel: 'Sau phiên')` với key `session-active-mindful-nudge-card` (cùng preset/states như các slot khác — `*-mindful-nudge-20s/45s/skip/disable/...`), đặt sau `session-reentry-card`. Gentle, dismissible, dev-gated qua `_MindfulNudgeRuntime.enabled`; completion đã fire haptic medium nên haptic-first.

## Code anchor

- `apps/mobile/lib/features/mindful_nudge/mindful_nudge.dart`:
  - `_MindfulNudgePreset` (`keySuffix`, `label`, `detail`, `route`)
  - `_MindfulNudgeSlot` / `_MindfulNudgeSlotState`: `_presets` (2 preset), `_skipped`
  - `_MindfulNudgeRuntime.enabled` (global static, default `true`)
  - keys: `${prefix}-mindful-nudge-card`, `-title`, `-20s`, `-45s`, `-skip`, `-skipped`, `-restore`, `-disable`, `-disabled`, `-enable`
- `apps/mobile/lib/runtime/runtimes.dart`: `_MindfulNudgeRuntime.enabled`

## Dev Notes

### Dev-gating note
Mindful nudge là **user-facing, luôn hiện** khi enabled — không DevSection, không gate. Skip/disable/restore/enable đều là core UX.

### Edge cases
- `_MindfulNudgeRuntime.enabled` là **global static** — disable ở một slot tắt tất cả slot (Home + Growth + Presence). Restore chỉ affect slot hiện tại (`_skipped` local).
- Thứ tự check trong `build()`: `if (!enabled) → disabled state` → `if (_skipped) → skipped state` → else full card. Disabled ưu tiên cao hơn skipped.
- `slotLabel` hiển thị trong title: `'Nhắc nhẹ preset • ${slotLabel}'` (vd `Home`, `Growth`, `Presence`).

### Calm/safety boundary
- Body text nhấn mạnh: `'Preset yên tĩnh, aggregate-only, không tạo social graph. Có thể bỏ qua bất cứ lúc nào.'` — thiết lập kỳ vọng non-social, opt-out easy.
- Skip `'Bỏ qua hôm nay'` — nhẹ nhàng, không guilt, không nhắc lại.
- Disable `'Tắt gợi ý'` — global off, người dùng kiểm soát hoàn toàn.

### Known code gaps (ghi chú)
- **(đã fix 2026-06-27) Slots post-session:** giờ có slot `session-active-*` render tại session completion trên `_SessionActiveScreen` (AC 8), khớp intent "sau phiên" của epics.
- `_MindfulNudgeRuntime.enabled` và `_skipped` là in-memory — KHÔNG persist qua restart.
- Disable là global, KHÔNG per-slot — người dùng không thể tắt chỉ Presence mà giữ Home.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- post-session-slot: 2026-06-27
- dev_status: not-started
- code_review: reconciled
