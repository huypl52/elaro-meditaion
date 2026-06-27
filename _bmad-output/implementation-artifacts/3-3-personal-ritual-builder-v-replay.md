---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 3.3: Personal ritual builder và replay

Status: backlog

## Story

As a người dùng muốn có routine cá nhân,
I want tạo và chạy lại ritual từ nhiều bước,
So that tôi có đường đi phù hợp nhanh hơn.

## Acceptance Criteria

1. **Given** người dùng mở `/rituals/builder`, **When** builder render, **Then** title `'Ritual Builder'`, ô `ritual-name` (`'Tên ritual'`), và pool 5 bước: `'Thở sâu 10 nhịp'`, `'Thả lỏng vai'`, `'Nhắm mắt'`, `'Nghe âm thanh nền'`, `'Mở mắt từ tốn'` (mỗi bước key `ritual-item-${slug}`).

2. **Given** người dùng chọn bước, **When** chọn, **Then** phải chọn **tối thiểu 1 bước** (copy `'Chọn tối thiểu 1 bước'` nếu thiếu); `ritual-save-btn` (`'Lưu ritual'`) **disabled** khi thiếu tên hoặc thiếu bước.

3. **Given** người dùng nhập đủ tên + ≥1 bước, **When** chạm `ritual-save-btn` (`'Lưu ritual'`), **Then** `estimatedSeconds = (20 + (n-1)*15).clamp(20,90)` được tính, **And** `_RitualRuntime.createRitual` (UUIDv7, in-memory) lưu `_RitualDefinition` rồi pop trả về.

4. **Given** người dùng có ritual đã lưu, **When** mở `/ritual/replay`, **Then** luôn replay ritual **mới nhất**; `ritual-replay-title` (`'Ritual: $name'`) và `ritual-replay-btn` (`'Bắt đầu'`) → `/session/start`.

5. **Given** không có ritual nào đã lưu, **When** mở replay, **Then** hiển thị `ritual-empty` (`'Không có ritual nào'`) **và** CTA `ritual-empty-create` (`'Tạo ritual đầu tiên'` → `/rituals/builder`).

6. **Given** người dùng ở Home, **When** xem ritual row, **Then** có `home-ritual-builder` (`'Tạo ritual mới'`) và `home-ritual-replay` (`'Phát lại ritual gần nhất'`, disabled khi trống), kèm `home-ritual-meta`.

## Code anchor

`apps/mobile/lib/features/ritual/ritual.dart` — builder (`ritual-name`, pool 5 bước `ritual-item-${slug}`, `ritual-save-btn`, `estimatedSeconds`), `_RitualDefinition`, replay (`/ritual/replay`, `ritual-replay-title`, `ritual-replay-btn`, `ritual-empty`); `apps/mobile/lib/runtime/runtimes.dart` — `_RitualRuntime.createRitual` (UUIDv7, in-memory map); Home integration `home-ritual-builder`/`home-ritual-replay`/`home-ritual-meta` tại `apps/mobile/lib/features/home/home.dart`.

## Dev Notes

- **Pool cố định 5 bước:** không phải catalog động — ritual được ghép từ pool `['Thở sâu 10 nhịp','Thả lỏng vai','Nhắm mắt','Nghe âm thanh nền','Mở mắt từ tốn']`. Giữ đơn giản, calming.
- **Estimated duration derive:** `(20 + (n-1)*15).clamp(20,90)` — 1 bước → 20s; mỗi bước thêm +15s; cap [20,90]. Không yêu cầu người dùng nhập thời lượng.
- **Replay luôn mới nhất:** không có list chọn ritual — `/ritual/replay` luôn lấy ritual cuối cùng đã lưu; đơn giản hóa quyết định.
- **Validation:** `ritual-save-btn` disabled khi thiếu tên hoặc thiếu bước; copy `'Chọn tối thiểu 1 bước'` hướng dẫn.
- **Known debt / follow-up:** (1) `Ritual Builder` vẫn giữ EN do `apps/mobile/test/widget_test.dart` khóa contract i18n; (2) `_RitualReplayArgs` dead (không dùng); (3) persistence **in-memory only** — không survive restart.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: not-started
- code_review: reconciled
