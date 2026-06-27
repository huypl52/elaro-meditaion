---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 3.5: Reflection nâng cao với biofeedback khi có quyền

Status: backlog

## Story

As a người dùng có quyền health,
I want phản chiếu sâu hơn bằng tín hiệu sinh lý cho phép,
So that phản hồi sát bối cảnh hơn mà không ép buộc.

## Acceptance Criteria

1. **Given** người dùng có `healthPermissionGranted == true` AND `bio != null` (có `_BiofeedbackSnapshot`) AND `bio.highConfidence` (`confidence >= 0.6`), **When** reflection enriched, **Then** hiển thị `session-reflection-biofeedback-title` (`'Phản hồi nâng cao từ tín hiệu sinh trắc'`) + `session-reflection-biofeedback-body`.

2. **Given** biofeedback enriched, **When** render tone words, **Then** HR tone: `'ổn định'` / `'chưa cao'` / `'hơi dồn dập'`; movement tone: `'rất tĩnh'` / `'dịu dịu'` / `'có dao động nhẹ'`; HRV direction: `'ổn định hơn'` / `'đang hồi dần'`.

3. **Given** biofeedback enriched, **When** render body, **Then** luôn kèm dòng `'đây là chiều hướng, không phải chỉ số'`.

4. **Given** biofeedback enriched, **When** xem nội dung, **Then** **KHÔNG** hiện số tuyệt đối — không bpm, không giá trị HRV, không điểm. Ngưỡng nội bộ (VD HRV 28) chỉ chọn từ ngữ, không hiển thị.

5. **Given** dữ liệu low-confidence (`confidence < 0.6`), **When** reflection render, **Then** hiển thị `session-reflection-biofeedback-low`, **And** fallback sang cảm nhận của người dùng, **không shaming**.

6. **Given** thiếu dữ liệu biofeedback (permission chưa cấp / `bio == null`), **When** reflection render, **Then** hiển thị `session-reflection-biofeedback-fallback` (bản cơ bản, narrative trend thuần — Story 3.4).

## Code anchor

`apps/mobile/lib/features/session/session.dart` — `_SessionReflectionScreen`, `_BiofeedbackSnapshot` (`highConfidence` = confidence>=0.6), `session-reflection-biofeedback-title` (`'Phản hồi nâng cao từ tín hiệu sinh trắc'`), `-body` (tone words HR/movement + HRV direction + `'đây là chiều hướng, không phải chỉ số'`), `session-reflection-biofeedback-low`, `session-reflection-biofeedback-fallback`; enriched khi `healthPermissionGranted && bio!=null && bio.highConfidence`.

## Dev Notes

- **Tone words + direction, no numbers (UX-DR17, AD-5):** chỉ hiện từ ngữ mô tả (`'ổn định'`/`'chưa cao'`/`'hơi dồn dập'` cho HR; `'rất tĩnh'`/`'dịu dịu'`/`'có dao động nhẹ'` cho movement; `'ổn định hơn'`/`'đang hồi dần'` cho HRV direction). Ngưỡng nội bộ (HRV 28, v.v.) chỉ chọn từ ngữ — không bao giờ hiện số tuyệt đối.
- **Enrichment gate (3 điều kiện AND):** `healthPermissionGranted && bio != null && bio.highConfidence(confidence>=0.6)` — thiếu bất kỳ điều kiện → fallback. Không ép buộc người dùng cấp quyền (AD-15).
- **No shaming:** low-confidence / thiếu dữ liệu → `session-reflection-biofeedback-low` / `-fallback` chuyển sang cảm nhận người dùng, không phán xét chất lượng phiên.
- **Affirmation line:** `'đây là chiều hướng, không phải chỉ số'` luôn kèm biofeedback body — củng cố narrative posture.
- **Dev-gating:** bio permission toggles (`session-bio-permission-enable`/`-disable`) nằm sau `DevSection`; release ẩn sạch.
- **Known code gap (KHÔNG đổi code):** `_BiofeedbackSnapshot` chỉ export tone getters (no raw number leakage); tuy nhiên confidence threshold và logic enrich là runtime in-memory.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: not-started
- code_review: reconciled
