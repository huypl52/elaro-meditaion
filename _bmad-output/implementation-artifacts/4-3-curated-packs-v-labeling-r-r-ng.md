---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 4.3: Curated packs và labeling rõ ràng

Status: backlog

## Story

As a người dùng,
I want thấy rõ pack nào là core/contextual/sound postcard,
So that tôi biết mức phù hợp và độ tin cậy nội dung.

## Acceptance Criteria

1. **Given** mỗi session trong catalog có `packType` thuộc `enum _LibraryPackType {core, contextual, soundPostcard}`,
   **When** render session row trong Library (`ListRowCard`) hoặc filter chip,
   **Then** pack type được hiển thị qua `_packTypeLabel(packType)` với label verbatim: `'Core'`, `'Contextual'`, `'Sound Postcard`.

2. **Given** mỗi pack type có accent color riêng qua `_packTypeColor(packType)`,
   **When** render pack badge (`_packBadge`) hoặc accent card,
   **Then** color verbatim: `core` → `Color(0xFF9CB59A)`, `contextual` → `Color(0xFF78B4C8)`, `soundPostcard` → `Color(0xFFB589C6)` (dùng cho badge fill 18% + border 60% + text color).

3. **Given** session row render trong Library,
   **When** build `ListRowCard`,
   **Then** có key `library-item-${session.id}` (`n1`–`n6`), trailing chứa `_packBadge(session)` với key `library-pack-badge-${session.id}` hiển thị `_packTypeLabel`, accent card = `_packTypeColor(packType)`.

4. **Given** người dùng tap session row (`library-item-${id}`),
   **When** onTap fired,
   **Then** navigate `/session/${session.id}` → `_SessionCatalogScreen` chi tiết.

5. **Given** người dùng mở catalog detail (`_SessionCatalogScreen`),
   **When** render,
   **Then** hiển thị `'Pack type: ${_packTypeLabel(session.packType)}'` cùng các metadata dòng khác (`Session ID`, `Transition mode`, `Duration`, `Offline state`), và nút `session-catalog-start` (`'Bắt đầu phiên'` hoặc `'Bắt đầu phiên cơ bản'` khi offline basic flow).

6. **Given** catalog 6 session `n1`–`n6` có phân bổ pack type,
   **When** duyệt,
   **Then** `n1` (Core), `n2` (Contextual), `n3` (Sound Postcard), `n4` (Core), `n5` (Contextual), `n6` (Sound Postcard) — 3 pack type đều có đại diện, người dùng có thể phân biệt trực quan qua color + label.

## Code anchor

- `apps/mobile/lib/features/library/library.dart`:
  - `enum _LibraryPackType {core, contextual, soundPostcard}`
  - `_packTypeLabel(_LibraryPackType)` → `'Core'` / `'Contextual'` / `'Sound Postcard'`
  - `_packTypeColor(_LibraryPackType)` → `0xFF9CB59A` / `0xFF78B4C8` / `0xFFB589C6`
  - `_packBadge(session)` → `Key('library-pack-badge-${session.id}')`
  - `_SessionCatalogScreen` (detail with `'Pack type:'` metadata)
  - `ListRowCard` with `Key('library-item-${session.id}')`, accent: `_packTypeColor(...)`

## Dev Notes

### Dev-gating note
Pack badge, pack label, catalog detail metadata là **user-facing, luôn hiện** — không DevSection, không gate.

### Edge cases
- Badge pack render trong `ListRowCard.trailing` cùng với offline badge (nếu `offlineReady`) và play icon — thứ tự: packBadge → offlineBadge → play icon.
- Accent color của card = `_packTypeColor(packType)` — dùng cho viền/trọng tâm card, phân biệt trực quan 3 pack type.
- `_packTypeLabel` dùng cho cả chip filter (`library-filter-pack-type-${name}`) và badge hiển thị — nhất quán label.

### Calm/safety boundary
- Labeling rõ ràng giúp người dùng phân biệt curated (Core) vs contextual vs sound postcard — không có nội dung "lạ" không rõ nguồn.
- Color tone nhẹ (18% fill, 60% border) — không chói, giữ posture calm.

### Known code gaps (ghi chú, KHÔNG đổi code)
- Không có mô tả dài ("tone/use case") cho mỗi pack type trong UI — chỉ label ngắn + color. AC intent epics nói "pack hiển thị type, context, duration, tone/use case" — "tone/use case" chưa có trường riêng, chỉ suy ra từ subtitle metadata.
- `Pack type: Core` là một trong 3 chuỗi user-facing EN còn bị `apps/mobile/test/widget_test.dart` khóa contract.
- Pack accent color hardcoded (không qua design token) — `_packTypeColor` trả `Color` literal; rule mới là không thêm hardcoded hex/literal mới ngoài debt đã tồn tại.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
