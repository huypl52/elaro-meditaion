---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 3.1: Growth Map không dùng streak pressure

Status: done

## Story

As a người dùng quay lại sau gián đoạn,
I want xem tổng kết tích lũy theo cách an toàn,
So that tôi thấy tiến triển mà không cảm giác áp lực.

## Acceptance Criteria

1. **Given** người dùng mở `/growth` (tab 3), **When** `_GrowthScreen` render, **Then** eyebrow `'Tiến trình nhẹ nhàng'` và headline `'Bản đồ phát triển'`.

2. **Given** người dùng có ≥1 phiên hoàn tất, **When** Growth hiển thị totals, **Then** `StatTile` `'Tổng phiên: N'` và `'Tổng thời lượng: N phút'` (N derive từ `_SessionRuntime.totalSessionCount` / `totalSessionDurationSeconds`).

3. **Given** Growth render, **When** xem metrics, **Then** **KHÔNG** có streak, **KHÔNG** có score, **KHÔNG** có leaderboard, **KHÔNG** có so sánh người khác — chỉ tổng phiên + tổng thời lượng.

4. **Given** Growth render, **When** xem `BentoTile`, **Then** hiển thị copy `'Bạn đang xây dựng nhịp đi đều — không chỉ số, không so sánh.'`.

5. **Given** người dùng ở Growth, **When** cần action, **Then** có `growth-quick-start` (`'Khởi tạo quick session 20s'`) và `growth-open-library` (`'Mở thư viện'`).

6. **Given** người dùng gián đoạn lâu rồi quay lại, **When** mở Growth, **Then** copy chào lại nhẹ, **không nhắc streak**, **không guilt** — continuity chỉ là tổng phiên + tổng thời lượng (không metric riêng).

## Code anchor

`apps/mobile/lib/features/growth/growth.dart` — `_GrowthScreen`, `StatTile` (`'Tổng phiên: N'`, `'Tổng thời lượng: N phút'`), `BentoTile` (`'Bạn đang xây dựng nhịp đi đều — không chỉ số, không so sánh.'`), `growth-quick-start`, `growth-open-library`; totals từ `apps/mobile/lib/runtime/session.dart` — `_SessionRuntime.totalSessionCount` / `totalSessionDurationSeconds` (derive từ timeline).

## Dev Notes

- **Non-scoring (AD-5, NFR9):** Growth là narrative totals, không phải gamification. Streak/score/leaderboard bị **banned** (Interaction Primitives). Bất kỳ UI nào nhắc "streak" hay "điểm" là lỗi ranh giới calm.
- **Continuity không metric riêng:** = tổng phiên + tổng thời lượng. Người dùng quay lại sau gián đoạn không bị phạt — copy chào nhẹ, không "you broke your streak".
- **Timeline = source:** totals derive từ `SessionTimeline` (immutable events), không phải biến riêng — đảm bảo nhất quán với mọi module.
- **Known code gap (KHÔNG đổi code):** không có replay-history list trong Growth.

## Dev Agent Checklist

- [x] `apps/mobile/lib/features/growth/growth.dart`: tạo mới `GrowthScreen`, `StatTile`, `BentoTile`.
- [x] `apps/mobile/lib/runtime/session.dart`: thêm `SessionRuntime.totalSessionCount` và `SessionRuntime.totalSessionDurationSeconds`.
- [x] `apps/mobile/lib/main.dart`: chuyển tab Growth sang `GrowthScreen` từ feature file.
- [x] `apps/mobile/test/story_3_1_growth_test.dart`: thêm test cho eyebrow/headline, totals, non-gamification, cta labels và CTA actions.
- [x] `apps/mobile/test/story_3_1_growth_test.dart`: xác nhận `SessionRuntime` totals dùng timeline sessionComplete.
- [x] `apps/mobile/lib/features/growth/growth.dart`: copy chào lại nhẹ + bento no-comparison.
- [x] `apps/mobile/lib/features/growth/growth.dart`: refactor presentation sang calm design-system owner:
  - `CalmTopAppBar`
  - owner `GrowthSectionCard`
  - owner `PrimaryCtaButton` / `SecondaryCtaButton`
  - token owner `_growthTheme` cho màu/chữ thay cho `Colors`/`Theme.colorScheme` trực tiếp trong Growth UI.
- [x] `apps/mobile/lib/components/calm_feature_scaffold.dart`: tạo shared calm shell và Growth đang dùng thay cho Scaffold trực tiếp.
- [x] `apps/mobile/lib/components/cta.dart`: tạo shared `PrimaryCTA`/`SecondaryCTA` và Growth đang dùng thay cho FilledButton/OutlinedButton trực tiếp.
- [x] `apps/mobile/lib/components/section_card.dart`: tạo shared `SectionCard` dùng cho StatTile/BentoTile.
- [x] `apps/mobile/lib/theme/elaro_colors.dart`, `apps/mobile/lib/theme/growth_tokens.dart`: tạo shared tokens cho growth colors/typography (tránh hardcoded color trực tiếp trong growth.dart).

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: done
- code_review: PASS

## Dev Agent Record

- Implemented in:
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/features/growth/growth.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/runtime/session.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/main.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/test/story_3_1_growth_test.dart`
- GrowthScreen now renders required Vietnamese anchor copy (`Tiến trình nhẹ nhàng`, `Bản đồ phát triển`) and keeps calm tone, including gentle welcome-back copy.
- Runtime totals now come from timeline `session_complete` events via `SessionRuntime.totalSessionCount` and `SessionRuntime.totalSessionDurationSeconds`.
- Growth presentation now uses shared calm owner components/tokens:
  - `CalmFeatureScaffold`
  - `SectionCard`
  - `PrimaryCTA` / `SecondaryCTA`
  - `ElaroColors` + `GrowthTokens` for palette/typography.
- Implemented shared design files:
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/components/calm_feature_scaffold.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/components/cta.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/components/section_card.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/theme/elaro_colors.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/theme/growth_tokens.dart`
- `StatTile` now renders exactly:
  - `Tổng phiên: N`
  - `Tổng thời lượng: N phút`
- `BentoTile` now includes exact copy:
  - `Bạn đang xây dựng nhịp đi đều — không chỉ số, không so sánh.`
- Action CTAs now exist with exact labels and keys:
  - `growth-quick-start` (`Khởi tạo quick session 20s` → `/session/start`)
  - `growth-open-library` (`Mở thư viện` → `/library`)
