---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 4.2: Transition modes và suggested session card

Status: backlog

## Story

As a người dùng,
I want vào các transition mode như trước khi ngủ, reset nhanh,
So that nội dung phục vụ trạng thái của tôi ngay.

## Acceptance Criteria

1. **Given** mỗi session trong catalog (`_LibrarySession`) có `transitionMode` thuộc `enum _TransitionMode {calmToFocus, deepFocus, reEntry, reset, focus, calmReset, beforeSleep}`,
   **When** render session row trong Library (`ListRowCard`) hoặc chi tiết catalog (`_SessionCatalogScreen`),
   **Then** transition mode được hiển thị qua `_transitionModeLabel(mode)` với label verbatim: `'calm → focus'`, `'deep focus'`, `'re-entry'`, `'reset'`, `'focus'`, `'calm reset'`, `'before sleep'`.

2. **Given** Home render suggested session card qua `_buildSuggestedSessionCard` (dùng `_suggestedSessionCatalog` picked theo `_resolveSuggestedSession` dựa `timeBucket`/`lastSessionType`),
   **When** card hiển thị,
   **Then** card có key `home-suggested-card`, title `home-suggested-title` (`'Gợi ý chuyển tiếp'`), tên session, và dòng mô tả dạng verbatim `'Transition: ${_transitionModeLabel(...)} • Duration: ${session.durationLabel} • Offline: ${session.offlineStateLabel}'`.

3. **Given** suggested session có `offlineReady == true`,
   **When** card render,
   **Then** badge `home-offline-badge` (`'OFFLINE READY'`) xuất hiện (color `primaryContainer`, letterSpacing 1.2, fontSize 11). Nếu `offlineReady == false`, badge KHÔNG render.

4. **Given** người dùng tap card `home-suggested-card` (toàn card) hoặc nút `home-suggested-open` (`'Mở phiên đề xuất'`),
   **When** onTap fired,
   **Then** navigate `Navigator.of(context).pushNamed('/session/${session.id}')` → mở `_SessionCatalogScreen` chi tiết phiên.

5. **Given** người dùng mở chi tiết catalog (`/session/{id}` `_SessionCatalogScreen`),
   **When** render,
   **Then** hiển thị các dòng metadata verbatim: `'Session ID: ${sessionId}'`, `'Pack type: ${_packTypeLabel(...)}'`, `'Transition mode: ${_transitionModeLabel(...)}'`, `'Duration: ${session.durationLabel}'`, `'Offline state: ${session.offlineStateLabel}'`.

6. **Given** transition mode là thuộc tính display-only,
   **When** người dùng muốn "filter theo transition",
   **Then** **KHÔNG có transition filter facet** trong Library — transition chỉ hiển thị trong subtitle/metadata, không thể lọc (xem Story 4.1, spec gap đã reconcile).

## Code anchor

- `apps/mobile/lib/features/library/library.dart`: `_SessionCatalogScreen` (detail metadata), `_transitionLabel` → `_transitionModeLabel`
- `apps/mobile/lib/features/home/home.dart`: `_buildSuggestedSessionCard`, `_resolveSuggestedSession`, `_suggestedSessionCatalog`
- `apps/mobile/lib/domain/timeline.dart`: `enum _TransitionMode`, `_transitionModeLabel(mode)`

## Dev Notes

### Dev-gating note
Suggested card và catalog detail là **user-facing, luôn hiện** — không DevSection, không gate. Transition label là display attribute, không phải filter control.

### Edge cases
- `_resolveSuggestedSession` logic: `timeBucket == 'night'` → `catalog[0]`; `lastCheckin == overload` → `catalog[1]`; `lastSessionType == focus && lastSessionAt != null` → `catalog[1]`; else → `catalog[0]`. Card pick theo context, KHÔNG random.
- `session.offlineStateLabel` trả `'offline-ready'` khi `offlineReady` true, `'online-only'` khi false — dùng trong dòng `'Offline: …'` của card.
- Duration label: `durationLabel` = `'${seconds}s'` (< 60s) hoặc `'${minutes}m'` (≥ 60s).

### Calm/safety boundary
- Suggested card là **gợi ý nhẹ**, một card duy nhất trên Home, có nút mở rõ ràng — không infinite feed, không carousel ép chọn.
- Metadata trong catalog detail hiển thị minh bạch pack type, transition, duration, offline state để người dùng tự quyết.

### Known code gaps (ghi chú, KHÔNG đổi code)
- **Transition không filter được** — chỉ display. Nếu spec kỳ vọng "duyệt theo transition mode", đây là code gap (xem Story 4.1).
- Suggested card pick dựa `_suggestedSessionCatalog` cục bộ trong Home, không phải query động từ Library filter state.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
