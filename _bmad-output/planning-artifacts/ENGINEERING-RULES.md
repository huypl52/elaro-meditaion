# meditation-community — Durable UX/UI engineering rules

Updated: 2026-06-27

Mục tiêu: giữ cho docs/spec/code không lại lệch sau các pass fix phản ứng. Đây là guardrail bền vững cho mọi thay đổi tiếp theo trong `apps/mobile/`.

## Source of truth
- Behavior: `apps/mobile/lib/features/*`, `apps/mobile/lib/runtime/*`, `apps/mobile/lib/domain/*`
- Shell/barrel only: `apps/mobile/lib/main.dart`
- Design system: `apps/mobile/lib/theme/*`, `apps/mobile/lib/components/*`
- Frozen behavioral contract: `apps/mobile/test/widget_test.dart`
- Supporting docs: `EXPERIENCE.md`, `DESIGN.md`, `epics.md`, `docs/ui-dev-handoff.md`

## 1) Scrollability invariant
- Mọi `Scaffold` body và `CalmBottomSheet` body **có thể tràn** phải dùng `SingleChildScrollView`, `ListView`, hoặc `CustomScrollView`.
- CTA sticky / footer action nằm **ngoài** vùng scroll khi pattern cần cả sticky lẫn content dài.
- Kiểm ở text scale mặc định và text scale lớn; không assume thiết bị cao hoặc copy ngắn.
- Không merge screen/sheet mới nếu body có khả năng tràn mà chưa có scroll container rõ ràng.

## 2) Dev-gating
- Mọi debug/QA/telemetry/control phục vụ test phải nằm trong `DevSection`.
- Release build chuẩn: `--dart-define=ELARO_RELEASE=true`.
- Không để `DEV • ...`, prompt count, sensor toggles, QA knobs, runtime reason labels, hay telemetry text lọt production.
- Nếu thiếu dart-define, hệ thống đang fail-safe về dev ON; vì vậy release checklist phải explicit.

## 3) No infinite animations
- Không dùng `AnimationController.repeat()` trong core UX calm-first.
- Motion chỉ được dùng khi có mục đích định hướng rõ; khi `Reduce Motion` bật phải degrade sang static / haptic / text.
- Mọi animation mới phải `pumpAndSettle` được trong test hoặc có đường degrade deterministically.

## 4) Frozen test contract
- Không tự ý sửa `apps/mobile/test/widget_test.dart`.
- Giữ nguyên key string và frozen text trên cùng widget / pump-path tương đương trừ khi có task riêng để unfreeze contract.
- Ba chuỗi user-facing hiện đang bị contract khóa: `Ritual Builder`, `Session start`, `Pack type: Core`. Muốn localize phải cập nhật test trước.

## 5) Design-system usage
- Ưu tiên component `Calm*`, `SectionCard`, `PrimaryCTA`, `PreferenceRow`, `TertiaryStackCTA`, `DistressBoundary`, `CommunityPresenceBand`.
- Dùng `ElaroColors.of(context)` / typography / shapes / spacing tokens; không thêm hex/literal màu mới cho UI product nếu không có design-system decision đi kèm.
- Không fallback sang Material stock component khi đã có equivalent calm component trong `lib/components/*`.

## 6) i18n
- Mọi string user-facing mới phải viết bằng tiếng Việt.
- Label dev-only / QA-only có thể là EN nếu nằm sau `DevSection`.
- Trước khi đổi string user-facing đang tồn tại, kiểm `apps/mobile/test/widget_test.dart` xem có bị assert trực tiếp không.
- Known debt hiện tại phải document nhất quán trong docs: `Ritual Builder`, `Session start`, `Pack type: Core`.

## 7) Tone & product invariants
- Night-calm, không gamification, không streak/score/leaderboard.
- Presence/community là aggregate-only: không chat, không profile, không social graph.
- Offline-first cho core flow; timeline là system-of-record.
- Permission preflight trước system prompt.
- Haptic-first nhưng luôn có text fallback.
- `DistressBoundary` phải hiện trên SOS, Reflection, Settings, Permissions; action mặc định mở support sheet.

## 8) Phase-7 structure
- `apps/mobile/lib/main.dart` là **barrel only**: app shell, route table, tab scaffold.
- Symbol thật sống ở `lib/domain/*`, `lib/runtime/*`, `lib/features/*` qua `part`/`part of`.
- Khi viết docs/code anchors, trỏ vào file sở hữu logic thực tế; không trỏ `main.dart` cho behavior nằm ở part file khác.

## Review checklist trước khi ship UI/runtime change
- [ ] Screen/sheet mới scroll được khi content dài hoặc text scale lớn
- [ ] Không có debug/QA control lọt khỏi `DevSection`
- [ ] Không thêm infinite animation; Reduce Motion có degrade path
- [ ] Không phá `widget_test.dart` frozen contract
- [ ] Dùng calm components + tokens, không hardcoded hex mới
- [ ] String user-facing mới là tiếng Việt, hoặc đã document lý do contract-locked
- [ ] Vẫn giữ night-calm / aggregate-only / offline-first / permission-preflight / timeline rules
- [ ] Docs anchors trỏ đúng `lib/domain|runtime|features` owner file
