---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 4.1: Taxonomy content theo need/context/duration/intensity

Status: backlog

## Story

As a người dùng,
I want duyệt nội dung theo nhu cầu và bối cảnh,
So that tôi nhanh thấy lựa chọn phù hợp.

## Acceptance Criteria

1. **Given** người dùng mở tab Library (`/library`, `_LibraryScreen`) với catalog 6 phiên `n1`–`n6` (`_LibraryScreenState._allSessions`),
   **When** render khu vực bộ lọc trong `SectionCard(eyebrow: 'Bộ lọc')`,
   **Then** có đúng 5 facet group, mỗi facet là **single-select** (chỉ 1 giá trị/facet tại một thời điểm) + một chip `'Tất cả'` để clear facet đó:
   - Need (`'Nhu cầu'`): `Focus` / `Sleep` / `Recovery` (enum `_LibraryNeed {focus, sleep, recovery}`; key `library-filter-need-${name}`).
   - Context (`'Bối cảnh'`): `Morning` / `Afternoon` / `Night` (enum `_LibraryContext {morning, afternoon, night, any}`; giá trị `any` **bị ẩn** — `if (context != _LibraryContext.any)`; key `library-filter-context-${name}`).
   - Duration (`'Thời lượng'`): `20s` / `45s` / `90s` / `3m` (enum `_LibraryDuration {s20, s45, s90, m3}`; key `library-filter-duration-${seconds}`).
   - Intensity (`'Cường độ'`): `Low` / `Medium` / `High` (enum `_LibraryIntensity {low, medium, high}`; key `library-filter-intensity-${name}`).
   - Pack (`'Pack'`): `Core` / `Contextual` / `Sound Postcard` (enum `_LibraryPackType {core, contextual, soundPostcard}`; key `library-filter-pack-type-${name}`).

2. **Given** người dùng chọn một chip giá trị trong bất kỳ facet nào (vd `library-filter-need-focus`),
   **When** `_filteredSessions` chạy `.where(...)` lọc theo state filter (`_needFilter`, `_contextFilter`, `_durationFilter`, `_intensityFilter`, `_packTypeFilter`),
   **Then** chỉ các session match tất cả facet đang active mới được giữ lại, chip `'Tất cả'` của facet đó trở thành **un-selected**, và đếm kết quả cập nhật ở `library-result-count` (`'Kết quả: N'`).

3. **Given** người dùng chọn chip `'Tất cả'` của một facet (key `library-filter-{facet}-all`, vd `library-filter-need-all`),
   **When** onTap fired,
   **Then** state filter tương ứng được set về `null` (`setState(() => _needFilter = null)`), facet đó không còn lọc, và danh sách mở rộng lại.

4. **Given** catalog có 6 session với `transitionMode` lần lượt `calmToFocus`/`focus`/`beforeSleep`/`reset`/`deepFocus`/`calmReset`,
   **When** người dùng tìm facet "transition",
   **Then** **KHÔNG có transition filter facet** — transition chỉ là **display attribute** trong subtitle (`'transition=${_transitionLabel(...)}'`); FR3/AC intent "filter theo transition mode" được đánh dấu là **spec gap** so với code.

5. **Given** người dùng thay đổi sort qua dropdown `library-sort`,
   **When** chọn một trong `_LibrarySortMode {recommended, shortest, longest, needFirst}` (label `Recommended` / `Short→Long` / `Long→Short` / `Need`),
   **Then** `_filteredSessions` re-sort theo mode: `recommended` (title asc), `shortest` (durationSeconds asc), `longest` (durationSeconds desc), `needFirst` (need.name asc, tie-break durationSeconds asc), và `library-result-count` giữ nguyên count.

6. **Given** tất cả filter trả về 0 session,
   **When** render danh sách,
   **Then** `library-empty-hint` hiển thị `'Kết quả: 0 phiên'` (fontSize 12, visible) — KHÔNG crash, KHÔNG chặn flow.

> **De-densified = single-select + `any` ẩn (KHÔNG phải chip-count cap):** mỗi facet cho phép chọn đúng 1 giá trị hoặc `'Tất cả'`; giá trị `_LibraryContext.any` bị ẩn khỏi chip list để tránh nhiễu. Đây là cách code thực hiện "taxonomy có kiểm soát" — không phải giới hạn số chip hiển thị.

## Code anchor

- `apps/mobile/lib/features/library/library.dart`:
  - `_LibraryScreen` / `_LibraryScreenState` (state holder: `_needFilter`, `_contextFilter`, `_durationFilter`, `_intensityFilter`, `_packTypeFilter`, `_sortMode`)
  - `_filteredSessions` getter (filter + sort logic)
  - `_filterChip(...)` → `EmotionChip(key: Key('library-filter-$value'))`
  - `_filterGroup(title, chips)` (render facet group)
  - enums `_LibraryNeed`, `_LibraryContext`, `_LibraryDuration`, `_LibraryIntensity`, `_LibraryPackType`, `_LibrarySortMode`

## Dev Notes

### Dev-gating note
Không có DevSection trong Library — toàn bộ filter/sort/result-count là **user-facing, luôn hiện** (không gate). Telemetry/QA scaffolding không nằm trong story này.

### Edge cases
- `_LibraryContext.any` bị ẩn trong chip list nhưng vẫn là giá trị hợp lệ của session (vd `n4` có `context: any`) → khi filter theo `morning`/`afternoon`/`night`, session `any` KHÔNG match (filter là `==`, không phải "any-or-match"). Đây là một **code gap** tiềm năng: session có context `any` sẽ bị loại khi filter theo context cụ thể.
- Filter là AND giữa các facet (match tất cả active facet), single-select trong facet (chọn giá trị mới thay thế giá trị cũ).
- Sort dropdown nằm cùng dòng với `library-result-count` trong cùng `Row`.

### Calm/safety boundary
- Library là taxonomy-first, không có social/feed/score element — chỉ filter + sort + result count.
- Empty state hiển thị `library-empty-hint` nhẹ nhàng, không shaming, không ép chọn lại filter.

### Known code gaps (ghi chú, KHÔNG đổi code)
- **Không có transition filter facet** (AC intent FR3/epics nói "filter theo transition mode" — code chỉ hiển thị transition trong subtitle, không cho filter). Đây là spec gap đã reconcile.
- **"De-densified" ≠ chip-count cap** — là single-select + `any` ẩn. Nếu spec kỳ vọng cap số chip hiển thị, đó là code gap.
- Empty state (`library-empty-hint`) chỉ là text nhỏ, KHÔNG có CTA "xóa filter" hay gợi ý thay đổi chọn (code gap nhỏ).

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
