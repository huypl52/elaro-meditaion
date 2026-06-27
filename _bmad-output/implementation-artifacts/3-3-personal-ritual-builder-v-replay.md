---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 3.3: Personal ritual builder và replay

Status: done

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

`apps/mobile/lib/features/ritual/ritual.dart` — NEW expected feature file for builder (`ritual-name`, pool 5 bước `ritual-item-${slug}`, `ritual-save-btn`, `estimatedSeconds`), `_RitualDefinition`, replay (`/ritual/replay`, `ritual-replay-title`, `ritual-replay-btn`, `ritual-empty`). `apps/mobile/lib/runtime/runtimes.dart` — NEW expected runtime file for `_RitualRuntime.createRitual` (UUIDv7-style string, in-memory latest ritual map/list) unless implementation keeps runtime in the existing `apps/mobile/lib/runtime/session.dart` by explicit local convention. Home integration `home-ritual-builder`/`home-ritual-replay`/`home-ritual-meta` updates existing `apps/mobile/lib/features/home/home.dart`. Route table updates existing `apps/mobile/lib/main.dart`.

## Tasks/Subtasks

- [x] Add `/rituals/builder` and `/ritual/replay` route handling in `apps/mobile/lib/main.dart` without changing unrelated routes or tab behavior. (AC: 1, 4, 5)
- [x] Create ritual feature UI in `apps/mobile/lib/features/ritual/ritual.dart` with scrollable builder/replay bodies, exact keys/copy, fixed 5-step pool, save validation, and latest-ritual replay behavior. (AC: 1, 2, 4, 5)
- [x] Add `_RitualDefinition` and `_RitualRuntime.createRitual` in the agreed runtime location, in-memory only for this story, with `estimatedSeconds = (20 + (n-1)*15).clamp(20,90)`. (AC: 3)
- [x] Integrate Home ritual row in `apps/mobile/lib/features/home/home.dart` with `home-ritual-builder`, `home-ritual-replay`, disabled replay when no ritual exists, and `home-ritual-meta`. (AC: 6)
- [x] Add focused Flutter tests, expected as `apps/mobile/test/story_3_3_ritual_test.dart`, covering builder render, disabled validation, save duration, replay latest, empty replay CTA, and Home row state. (AC: 1-6)
- [x] Before close, run focused test plus `flutter analyze` and full `flutter test` from `/Users/lee/code/projects/elaro-high/apps/mobile`.
- [x] Close guardrail: commit app code, tests, and this story artifact together in one packet; do not close if code/test/artifact are split.

## Dev Notes

- **Pool cố định 5 bước:** không phải catalog động — ritual được ghép từ pool `['Thở sâu 10 nhịp','Thả lỏng vai','Nhắm mắt','Nghe âm thanh nền','Mở mắt từ tốn']`. Giữ đơn giản, calming.
- **Estimated duration derive:** `(20 + (n-1)*15).clamp(20,90)` — 1 bước → 20s; mỗi bước thêm +15s; cap [20,90]. Không yêu cầu người dùng nhập thời lượng.
- **Replay luôn mới nhất:** không có list chọn ritual — `/ritual/replay` luôn lấy ritual cuối cùng đã lưu; đơn giản hóa quyết định.
- **Validation:** `ritual-save-btn` disabled khi thiếu tên hoặc thiếu bước; copy `'Chọn tối thiểu 1 bước'` hướng dẫn.
- **Timeline/system-of-record:** Architecture AD-2 says ritual replay belongs in immutable session timeline. Current `SessionTimelineEventType` has no `ritual` value yet; implementation must either add a focused `ritual` event with tests or document why replay only navigates to `/session/start` for this story. Do not create a parallel analytics/read-model path.
- **Offline-first:** Ritual create/replay must work from local in-memory state without backend/network/sensors. Persistence beyond restart is out of scope and remains known debt.
- **Source ownership:** All delivery work must stay under `/Users/lee/code/projects/elaro-high/apps/mobile`; never use any wrong repo delivery root.
- **Existing source state:** As of create-story on 2026-06-27, `apps/mobile` exists, but `apps/mobile/lib/features/ritual/ritual.dart`, `apps/mobile/lib/runtime/runtimes.dart`, and `apps/mobile/test/widget_test.dart` are not present. Treat ritual feature/runtime/test files as new unless another worker adds them before implementation starts.
- **Frozen string risk:** `Ritual Builder` remains EN because AGENTS/ENGINEERING-RULES mark it as frozen contract text. The named frozen file `apps/mobile/test/widget_test.dart` is currently absent, so preserve the string and add the focused story test rather than localizing it.
- **Design/runtime guardrails:** Use existing calm components/tokens where available; keep bodies scrollable; no `AnimationController.repeat()`; no gamification/streak/score/leaderboard; user-facing new strings should be Vietnamese except frozen `Ritual Builder`.
- **Previous story intelligence:** Story 3.2 established the current pattern for focused widget tests, `const SessionRuntime().resetForTests()` in test setup, in-memory private runtime state, timeline append assertions, and closing only after artifact+code+test are validated together.
- **Known debt / follow-up:** (1) `Ritual Builder` still EN by frozen contract; (2) `_RitualReplayArgs` dead/dormant if introduced or encountered; (3) persistence **in-memory only** — does not survive restart.

### References

- `_bmad-output/planning-artifacts/epics.md` — Epic 3 objective and Story 3.3 baseline.
- `_bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/EXPERIENCE.md` — Flow 7 Ritual builder/replay exact keys/copy and route behavior.
- `_bmad-output/planning-artifacts/architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md` — AD-1, AD-2, AD-3 and stack/version guardrails.
- `_bmad-output/planning-artifacts/ENGINEERING-RULES.md` — frozen test contract, dev-gating, scrollability, design-system, i18n, and tone/product invariants.
- `_bmad-output/implementation-artifacts/3-2-voice-journal-sau-phi-n.md` — previous Epic 3 implementation/testing/close pattern.

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

- RED: `uv --directory apps/mobile run flutter test test/story_3_3_ritual_test.dart` failed before implementation because `lib/features/ritual/ritual.dart` and `resetRitualRuntimeForTests` were missing.
- GREEN focused: `uv --directory apps/mobile run flutter test test/story_3_3_ritual_test.dart` passed: 5/5 tests.
- Static analysis: `uv --directory apps/mobile run flutter analyze` passed: No issues found.
- Regression: `uv --directory apps/mobile run flutter test` passed: 51/51 tests.
- Boundary check: `rg -n "wrong repo historical note" apps/mobile _bmad-output/implementation-artifacts/3-3-personal-ritual-builder-v-replay.md _bmad-output/implementation-artifacts/sprint-status.yaml || true` confirmed no wrong-repo delivery source path usage; historical wrong-repo wording was neutralized in active review notes.

- REVIEW REWORK focused: `uv --directory apps/mobile run flutter test test/story_3_3_ritual_test.dart` passed: 5/5 tests.
- REVIEW REWORK static analysis: `uv --directory apps/mobile run flutter analyze` passed: No issues found.
- REVIEW REWORK regression: `uv --directory apps/mobile run flutter test` passed: 51/51 tests.
- REVIEW REWORK source boundary: `rg -n "<wrong-repo-marker>" apps/mobile || true` returned no matches for the forbidden wrong-repo marker.
- REVIEW REWORK artifact boundary: `rg -n "<wrong-repo-marker>" _bmad-output/implementation-artifacts/3-3-personal-ritual-builder-v-replay.md apps/mobile || true` returned no matches for the forbidden wrong-repo marker.
- REVIEW REWORK design-system check: `rg -n "Scaffold\(|AppBar\(|FilledButton\(|OutlinedButton\(" apps/mobile/lib/features/ritual/ritual.dart || true` returned only `CalmFeatureScaffold` references, no raw feature-level screen/button constructors.

### Completion Notes List

- Implemented `/rituals/builder` and `/ritual/replay` routes in `apps/mobile/lib/main.dart` without changing tab routing.
- Added scrollable ritual builder/replay UI with exact required keys/copy, fixed 5-step pool, disabled save validation, and latest-ritual replay behavior.
- Added in-memory `_RitualRuntime.createRitual` and `_RitualDefinition` in `apps/mobile/lib/runtime/runtimes.dart` as a `part` of the ritual feature library so the story-required private names remain usable by the owner feature.
- Estimated duration uses `(20 + (n-1)*15).clamp(20,90)`; focused test verifies 2 steps produce 35s on `/session/start` timeline.
- Replay intentionally navigates to `/session/start` and relies on existing `SessionRuntime` `session_start` timeline event with `session_route: /ritual/replay`; no parallel analytics/read-model path was added.
- Integrated Home ritual row with create/replay actions, disabled empty replay state, and `home-ritual-meta`.
- Added focused Story 3.3 widget/runtime tests covering AC 1-6.
- Close packet is uncommitted per assignment, but app code + tests + story/sprint artifacts are present together in this working tree.

- Review rework: switched ritual builder/replay/Home ritual actions from raw feature-level `Scaffold`/`AppBar` and direct buttons to `CalmFeatureScaffold` plus tokenized CTA components while preserving keys, text, scroll bodies, routes, and disabled states.
- Review rework: neutralized active-looking wrong-repo full-path references in this story artifact; active delivery paths now point to `elaro-high` only.

### File List

- `_bmad-output/implementation-artifacts/3-3-personal-ritual-builder-v-replay.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `apps/mobile/lib/main.dart`
- `apps/mobile/lib/components/cta.dart`
- `apps/mobile/lib/features/home/home.dart`
- `apps/mobile/lib/features/ritual/ritual.dart`
- `apps/mobile/lib/runtime/runtimes.dart`
- `apps/mobile/test/story_3_3_ritual_test.dart`

### Completion Checklist

- [x] All tasks/subtasks are checked complete.
- [x] AC 1-6 covered by focused Story 3.3 tests.
- [x] New UI bodies are scrollable.
- [x] No `AnimationController.repeat()` added.
- [x] No debug/QA controls added outside `DevSection`.
- [x] New product strings are Vietnamese except frozen `Ritual Builder`.
- [x] No delivery work used a wrong repo historical path.
- [x] Validation passed: focused test, `flutter analyze`, full `flutter test`.

## Change Log

- 2026-06-27: Implemented Story 3.3 ritual builder/replay, Home integration, in-memory ritual runtime, focused tests, and moved story/sprint state to review.

- 2026-06-27: Review rework fixed design-system guardrail in ritual UI and neutralized wrong-repo artifact references.
- 2026-06-27: Dual review PASS recorded; story closed as done.
