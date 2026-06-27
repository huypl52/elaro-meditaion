---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 3.4: Session reflection narrative baseline

Status: backlog

## Story

As a người dùng,
I want nhận phản hồi sau phiên bằng câu chuyện ngắn,
So that tôi hiểu xu hướng ổn định của mình.

## Acceptance Criteria

1. **Given** session hoàn tất và người dùng mở `/session/{id}/reflection`, **When** `_SessionReflectionScreen` render, **Then** title `'Phản hồi phiên'`, eyebrow `'Sau phiên'`, headline `'Phản hồi cảm nhận nhẹ nhàng'`.

2. **Given** reflection render, **When** tính narrative trend, **Then** trend được derive theo **band thời lượng**: ≤45s / ≤90s / >90s / no-state — thành một câu trend kể chuyện (VD "bạn đã duy trì sự tĩnh tại ở một chu kỳ tương đối ổn định").

3. **Given** reflection render, **When** hiển thị nội dung, **Then** **KHÔNG** có điểm số tuyệt đối (no %), **KHÔNG** có rank, **KHÔNG** có so sánh người khác — chỉ narrative trend.

4. **Given** reflection render, **When** xem `session-reflection-no-pressure`, **Then** copy `'Tổng kết nhẹ: không đưa ra điểm số, không so sánh…'`.

5. **Given** reflection render, **When** màn hiển thị, **Then** `DistressBoundary` (`reflection-distress-boundary`) luôn hiện với message `'Đây là công cụ tự chăm sóc nhẹ nhàng, không thay thế hỗ trợ chuyên môn…'`, **And** action `'Tìm hỗ trợ'` mặc định mở `_SupportResourcesSheet`.

6. **Given** người dùng muốn thoát, **When** chạm `session-reflection-return` (`'Quay về Home'`), **Then** điều hướng về Home.

## Code anchor

`apps/mobile/lib/features/session/session.dart` — `_SessionReflectionScreen`, title `'Phản hồi phiên'`, eyebrow `'Sau phiên'`, headline `'Phản hồi cảm nhận nhẹ nhàng'`, narrative trend theo band thời lượng (≤45/≤90/>90/no-state), `session-reflection-no-pressure` (`'Tổng kết nhẹ: không đưa ra điểm số, không so sánh…'`), `session-reflection-return` (`'Quay về Home'`), `DistressBoundary` key `reflection-distress-boundary`.

## Dev Notes

- **Narrative trend, no score (AD-5, UX-DR17):** reflection là câu chuyện ngắn về xu hướng ổn định, không phải metric. Band thời lượng (≤45/≤90/>90/no-state) chọn từ ngữ narrative, không hiện số.
- **Banned:** %, rank, điểm, so sánh người khác — `session-reflection-no-pressure` (`'Tổng kết nhẹ: không đưa ra điểm số, không so sánh…'`) làm rõ ranh giới.
- **Distress boundary:** Reflection là 1 trong 4 surface có `DistressBoundary` (cùng SOS×2, Settings, Permissions). `reflection-distress-boundary` luôn hiện — không gate.
- **Calm escape:** `session-reflection-return` (`'Quay về Home'`) đảm bảo lối thoát trong ≤2 thao tác.
- **Biofeedback tách story:** phần biofeedback nâng cao (tone words HR/movement/HRV) là Story 3.5 riêng; baseline này là narrative thuần, không phụ thuộc health permission.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: not-started
- code_review: reconciled
