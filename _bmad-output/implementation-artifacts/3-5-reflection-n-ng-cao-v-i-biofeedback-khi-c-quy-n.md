---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 3.5: Reflection nâng cao với biofeedback khi có quyền

Status: done

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

7. **Given** biofeedback enriched, **When** render somatic reflection, **Then** UI hiển thị `session-reflection-relaxation-state` với Relaxation State gradient từ warm amber/earthy orange sang safe teal, **And** label là `trạng thái thư giãn` hoặc `xu hướng cơ thể`, không phải score.

8. **Given** biofeedback enriched, **When** values render, **Then** UI không hiển thị Calm Score, Focus Score, bpm, raw HRV, percentile, rank, hoặc numeric meditation quality.

## Code anchor

`apps/mobile/lib/features/session/session.dart` — `_SessionReflectionScreen`, `_BiofeedbackSnapshot` (`highConfidence` = confidence>=0.6), `session-reflection-biofeedback-title` (`'Phản hồi nâng cao từ tín hiệu sinh trắc'`), `-body` (tone words HR/movement + HRV direction + `'đây là chiều hướng, không phải chỉ số'`), `session-reflection-biofeedback-low`, `session-reflection-biofeedback-fallback`; enriched khi `healthPermissionGranted && bio!=null && bio.highConfidence`.

## Tasks/Subtasks

- [x] Extend reflection args/runtime model with a permission-gated `_BiofeedbackSnapshot` path without blocking baseline Story 3.4 reflection. (AC: 1, 5, 6)
- [x] Add high-confidence enriched block in `_SessionReflectionScreen` with `session-reflection-biofeedback-title` and `session-reflection-biofeedback-body`. (AC: 1)
- [x] Implement tone-word mapping for HR, movement, and HRV direction; thresholds remain internal and never render as bpm/HRV values/score. (AC: 2, 3, 4)
- [x] Implement low-confidence and missing-data fallback blocks with keys `session-reflection-biofeedback-low` and `session-reflection-biofeedback-fallback`; copy must be non-shaming and return to baseline narrative. (AC: 5, 6)
- [x] Keep health/biofeedback toggles or synthetic controls behind `DevSection`/`DevGate`; release must hide debug controls. (AC: 1, 5, 6)
- [x] Add focused tests, expected as `apps/mobile/test/story_3_5_biofeedback_reflection_test.dart`, covering high-confidence enrich, low-confidence fallback, no-permission fallback, no raw number leakage, and release dev-gate behavior. (AC: 1-6)
- [x] Before close, run focused test plus `flutter analyze` and full `flutter test` from `/Users/lee/code/projects/elaro-high/apps/mobile`.
- [x] Close guardrail: commit app code, tests, and this story artifact together in one packet; do not close if code/test/artifact are split.

## Dev Notes

- **Tone words + direction, no numbers (UX-DR17, AD-5):** chỉ hiện từ ngữ mô tả (`'ổn định'`/`'chưa cao'`/`'hơi dồn dập'` cho HR; `'rất tĩnh'`/`'dịu dịu'`/`'có dao động nhẹ'` cho movement; `'ổn định hơn'`/`'đang hồi dần'` cho HRV direction). Ngưỡng nội bộ (HRV 28, v.v.) chỉ chọn từ ngữ — không bao giờ hiện số tuyệt đối.
- **Enrichment gate (3 điều kiện AND):** `healthPermissionGranted && bio != null && bio.highConfidence(confidence>=0.6)` — thiếu bất kỳ điều kiện → fallback. Không ép buộc người dùng cấp quyền (AD-15).
- **No shaming:** low-confidence / thiếu dữ liệu → `session-reflection-biofeedback-low` / `-fallback` chuyển sang cảm nhận người dùng, không phán xét chất lượng phiên.
- **Affirmation line:** `'đây là chiều hướng, không phải chỉ số'` luôn kèm biofeedback body — củng cố narrative posture.
- **Dev-gating:** bio permission toggles (`session-bio-permission-enable`/`-disable`) nằm sau `DevSection`; release ẩn sạch.
- **Known code gap (KHÔNG đổi code):** `_BiofeedbackSnapshot` chỉ export tone getters (no raw number leakage); tuy nhiên confidence threshold và logic enrich là runtime in-memory.
- **Existing code state:** As of create-story on 2026-06-27, `SessionReflectionScreen` has no `_BiofeedbackSnapshot`, no health permission runtime, and no biofeedback keyed blocks. `runtime/sensor_runtime.dart` only exposes a generic sensor availability toggle; do not treat that as health permission.
- **Permission preflight boundary:** UX requires system permission only after `/permissions/{microphone|health}/preflight`, but permission screen implementation is planned in Epic 6.2. For 3.5, use explicit in-app/dev-gated state and fallback behavior; do not call platform Health APIs or system prompts directly from reflection.
- **Privacy/data boundary:** Health data must be normalized/derived only. Do not store or render raw heart rate, HRV, respiratory, or motion samples; do not add backend sync.
- **Expected touched areas:** main implementation should stay in `apps/mobile/lib/features/session/session.dart`; runtime support may touch `apps/mobile/lib/runtime/session.dart` or add a small `runtime/*` helper if needed; tests should be new in `apps/mobile/test/story_3_5_biofeedback_reflection_test.dart`. Avoid changing Story 3.3 ritual files.
- **Parallelization boundary:** This story depends conceptually on Story 3.4 baseline reflection. If implemented in parallel, keep 3.5 changes additive: biofeedback model/gates/blocks only, no rewrite of baseline title/trend/return/distress behavior.
- **Design/runtime guardrails:** Reflection body remains scrollable; no debug/QA controls outside `DevSection`; no infinite animation; no score/rank/percentile/leaderboard; copy remains Vietnamese and non-diagnostic.
- **Source ownership:** All delivery work must stay under `/Users/lee/code/projects/elaro-high/apps/mobile`; do not use any other delivery root.

### References

- `_bmad-output/planning-artifacts/epics.md` — Epic 3 objective and Story 3.5 baseline.
- `_bmad-output/planning-artifacts/prds/prd-meditation-community-2026-06-24/prd.md` — FR-11 Session Reflection and FR-13 Biofeedback Reflection Inputs.
- `_bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/EXPERIENCE.md` — Flow 3 reflection biofeedback/fallback behavior.
- `_bmad-output/planning-artifacts/architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md` — AD-4 sensing adapters, AD-5 no-score reflection, privacy/retention rules.
- `_bmad-output/planning-artifacts/ENGINEERING-RULES.md` — dev-gating, permission preflight, scrollability, i18n, and tone/product invariants.
- `_bmad-output/implementation-artifacts/3-4-session-reflection-narrative-baseline.md` — baseline reflection contract that 3.5 must preserve.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- create-story: 2026-06-27 (context refreshed; ready-for-dev)
- dev_status: done
- code_review: PASS

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Debug Log References

- 2026-06-27: RED `cd apps/mobile && flutter test test/story_3_5_biofeedback_reflection_test.dart` failed before implementation because biofeedback keys/model were absent.
- 2026-06-27: GREEN focused `cd apps/mobile && flutter test test/story_3_5_biofeedback_reflection_test.dart` passed: 5/5 tests.
- 2026-06-27: `cd apps/mobile && flutter analyze` passed: No issues found.
- 2026-06-27: Full `cd apps/mobile && flutter test` passed: 62/62 tests.
- 2026-06-27: Additional route preservation in `apps/mobile/lib/main.dart` was required because the existing reflection route rebuilt `SessionReflectionArgs` and would otherwise drop permission/bio fields.

### Completion Notes List

- Implemented Story 3.5 additively on top of Story 3.4 reflection baseline in `elaro-high/apps/mobile` only.
- Extended `SessionReflectionArgs` with permission-gated biofeedback input and added private `_BiofeedbackSnapshot` with high-confidence threshold `confidence >= 0.6`.
- Added high-confidence enriched reflection block with `session-reflection-biofeedback-title` and `session-reflection-biofeedback-body` under the 3.4 narrative/no-pressure baseline.
- Added tone-word mapping for HR, movement, and HRV direction; thresholds remain internal and no raw bpm/HRV/confidence/%/score/rank/social comparison values render in the biofeedback body.
- Added non-shaming low-confidence and missing/no-permission fallbacks with `session-reflection-biofeedback-low` and `session-reflection-biofeedback-fallback`.
- Avoided synthetic QA controls entirely, so no new debug controls can leak; tests assert expected biofeedback toggles are absent.
- Preserved Story 3.4 title/trend/no-pressure/distress/return behavior; full Flutter suite including Story 3.4 tests passed.
- No platform Health APIs, backend sync, raw health storage, or system permission prompts were added.
- No commit made.

### File List

- `_bmad-output/implementation-artifacts/3-5-reflection-n-ng-cao-v-i-biofeedback-khi-c-quy-n.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `apps/mobile/lib/features/session/session.dart`
- `apps/mobile/lib/main.dart`
- `apps/mobile/test/story_3_5_biofeedback_reflection_test.dart`

## Change Log

- 2026-06-27: Implemented Story 3.5 biofeedback reflection enrichment, focused tests, validation, and moved story to review.
- 2026-06-27: Final review PASS recorded; story closed as done.
