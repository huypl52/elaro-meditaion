# UI Dev Handoff — meditation-community

> Source-root audit note (2026-06-27): canonical project root is `/Users/lee/code/projects/elaro-high`.
> This repo currently has no `apps/mobile/` tree. All `apps/mobile/...` anchors in this handoff are intended
> in-repo target paths for when source is restored under `elaro-high`; they are not instructions to use
> `/Users/lee/code/projects/elaro-med`.

## Mục tiêu

Tài liệu này gói bộ UI review đã chốt để đội dev có thể build mà **không cần vào Stitch** tìm lại.

Bộ handoff này gồm:
- shortlist màn UI đã chốt
- artifact export local từ Stitch
- mapping UX surface → UI page
- route/tab đề xuất cho app Flutter
- state và behavior notes quan trọng cho implementation
- nguồn spec gốc để đối chiếu khi cần

> Lưu ý: các file HTML export từ Stitch là **design reference**, không phải production Flutter code.

---

## 1) Nơi lấy bộ UI đã chốt

### Stitch project gốc
- Project: `meditation-community UI review`
- Project ID: `projects/14950174467483376764`

### Local export trong repo
- Thư mục export: `design-artifacts/stitch/ui-review-export/`
- Index file: `design-artifacts/stitch/ui-review-export/README.md`

Mỗi màn đã export sẵn:
- `preview.png` — ảnh preview để review nhanh
- `screen.html` — HTML artifact để tham khảo bố cục/spacing/copy

---

## 2) Bộ màn đã chốt cho dev

| # | Screen title | Screen ID | Local folder |
|---|---|---|---|
| 1 | Home - Quiet Presence Refinement C | `e5d9356919b04837a1fcf9b564c6b846` | `design-artifacts/stitch/ui-review-export/01-home-quiet-presence-refinement-c/` |
| 2 | SOS Entry - Tactile Stabilization | `4bbfedf2d4e942e9a4a0a305c4ab65a4` | `design-artifacts/stitch/ui-review-export/02-sos-entry-tactile-stabilization/` |
| 3 | Active Calming - Tactile Stabilization Flow | `32d5af1c5b8c49f3bac293efd8a83aa5` | `design-artifacts/stitch/ui-review-export/03-active-calming-tactile-stabilization-flow/` |
| 4 | Session Player - Tactile Silence | `f1afff1cdc314fda8fc4323d5dc1e0ae` | `design-artifacts/stitch/ui-review-export/04-session-player-tactile-silence/` |
| 5 | Gentle Re-entry - Refined | `e0932d90e706408b802ba5734cd08a00` | `design-artifacts/stitch/ui-review-export/05-gentle-re-entry-refined/` |
| 6 | Reflection & Growth | `8849183714184edd9ee2e37bce9f817c` | `design-artifacts/stitch/ui-review-export/06-reflection-and-growth/` |
| 7 | Library by Need | `b6e84f06227d4be28639034a3200863c` | `design-artifacts/stitch/ui-review-export/07-library-by-need/` |
| 8 | Quiet Presence | `14750b19b6e7409bb28733d1ef8d00aa` | `design-artifacts/stitch/ui-review-export/08-quiet-presence/` |
| 9 | Privacy & Permissions - Trusted Foundation | `aaf641b8290d447fb311b084bb5b3b69` | `design-artifacts/stitch/ui-review-export/09-privacy-and-permissions-trusted-foundation/` |

---

## 3) UX surface → UI page mapping

| UX surface | Final UI page | Notes |
|---|---|---|
| Home | Home - Quiet Presence Refinement C | Single-path home. Tối đa 2 CTA mạnh above the fold. Không biến thành dashboard. |
| Quick check-in | Home - Quiet Presence Refinement C | Thể hiện bằng optional emotional check-in chips. Có thể bỏ qua. |
| SOS entry | SOS Entry - Tactile Stabilization | Entry screen 60 giây, vào nhanh, ít lựa chọn. |
| SOS active flow | Active Calming - Tactile Stabilization Flow | Flow ổn định 60 giây, haptic-first, audio optional. |
| Session player | Session Player - Tactile Silence | Player cho session thường: audio/haptic/timer/bell/pause/end early. |
| Gentle re-entry | Gentle Re-entry - Refined | Soft landing ngay sau khi kết thúc phiên. |
| Reflection | Reflection & Growth | Narrative reflection, không score. |
| Growth | Reflection & Growth | Continuity/tổng phiên/tổng thời gian, không streak pressure. |
| Library | Library by Need | Duyệt theo need/context/duration/intensity/transition mode. |
| Presence | Quiet Presence | Aggregate anonymous presence only. Không profile/chat/feed. |
| Permissions & trust | Privacy & Permissions - Trusted Foundation | Pre-permission education trước system prompt. |

### UX surfaces chưa có màn riêng trong shortlist

| UX surface | Hướng xử lý trong MVP |
|---|---|
| Rituals | Treat như entry/module trong Home hoặc Library trước khi tách page riêng. |
| Voice journal | Treat như action xuất hiện sau session / trong Growth flow; chưa cần screen standalone trong shortlist hiện tại. |
| Settings | Chưa phải màn Stitch chốt trong batch này; dev có thể build nhẹ theo IA và token từ DESIGN.md. |

---

## 4) Route / navigation map đề xuất cho Flutter

### Bottom tabs
Theo UX spine, tab bar tối giản chỉ gồm:
- `Home`
- `Library`
- `Growth`
- `Settings`

### SOS
- `SOS` **không phải tab**
- là CTA persistent/calm từ Home và các high-stress entry states

### Route map đề xuất

| Route | Screen |
|---|---|
| `/home` | Home - Quiet Presence Refinement C |
| `/library` | Library by Need |
| `/growth` | Reflection & Growth (Growth entry) |
| `/settings` | Settings (build theo spec, chưa có Stitch screen chốt) |
| `/sos` | SOS Entry - Tactile Stabilization |
| `/sos/active` | Active Calming - Tactile Stabilization Flow |
| `/session/:sessionId` | Session Player - Tactile Silence |
| `/session/:sessionId/re-entry` | Gentle Re-entry - Refined |
| `/session/:sessionId/reflection` | Reflection & Growth (Reflection entry) |
| `/presence` | Quiet Presence |
| `/permissions/:type/preflight` | Privacy & Permissions - Trusted Foundation |

---

## 5) Page-by-page implementation notes

### 5.1 Home — `Home - Quiet Presence Refinement C`
**Mục tiêu UX**
- Mở app là thấy con đường tiếp theo rõ ngay trong 1-2 giây
- chỉ 1 primary CTA + tối đa 1 secondary CTA above the fold
- vẫn giữ cảm giác có cộng đồng nhưng không social pressure

**Core sections**
- header + calm SOS capsule
- 1 primary CTA
- 1 secondary CTA
- optional emotional check-in chips
- 1 suggested session card
- 1 quiet presence block
- 1 ritual continuity row
- bottom tabs

**Behavior notes**
- home phải hữu ích offline
- CTA chính nên derive từ continuity/time-of-day/recent usage/local state
- quiet presence block degrade gracefully nếu offline hoặc không có live data
- không hiển thị dashboard metrics ở home

**Data dependencies**
- recent continuity / last ritual
- suggested session recommendation
- quick check-in state
- aggregate presence summary
- offline-ready content flags

---

### 5.2 SOS Entry — `SOS Entry - Tactile Stabilization`
**Mục tiêu UX**
- vào flow 60 giây thật nhanh
- haptic-first, low-cognitive-load
- tạo cảm giác safe chứ không alarm

**Core sections**
- headline nhấn mạnh 60 giây
- main CTA vào ngay flow
- haptic recommended / audio optional
- clear safe exit back home

**Behavior notes**
- 1 tap để bắt đầu là lý tưởng
- không ép người dùng cấu hình nhiều trước khi bắt đầu
- copy phải stabilize, không dramatic
- nếu audio unavailable vẫn phải vào flow bình thường

**Data dependencies**
- saved haptic preference
- saved audio preference
- minimal SOS analytics / session timeline event

---

### 5.3 SOS Active Flow — `Active Calming - Tactile Stabilization Flow`
**Mục tiêu UX**
- ổn định trong 60 giây bằng nhịp haptic + visual pacing
- không trông như media player

**Core sections**
- minimal progress indicator xuyên 60s
- large inhale/exhale text cues
- haptic active state
- optional quiet audio toggle
- pause / end controls dễ chạm

**Behavior notes**
- haptic là primary guidance
- audio là secondary
- pause/end phải luôn reach được trong 1-2 thao tác
- support reduce motion bằng text/haptic pacing

**Data dependencies**
- SOS active state
- elapsed progress
- haptic mode
- optional audio mode
- session timeline events

---

### 5.4 Session Player — `Session Player - Tactile Silence`
**Mục tiêu UX**
- player tối giản, immersive, low-cognitive-load

**Core sections**
- session title
- duration / state label
- timer / progress
- audio guidance
- bell / haptic guidance state
- pause / end early
- silence-compatible mode

**Behavior notes**
- không clutter kiểu music player
- phải low-vision-safe
- offline playback là first-class
- session timeline là source of truth cho pause/complete/abort/resume

**Data dependencies**
- session metadata
- playback state
- timer state
- haptic/bell settings
- offline asset availability

---

### 5.5 Gentle Re-entry — `Gentle Re-entry - Refined`
**Mục tiêu UX**
- soft landing, không celebration

**Core sections**
- 1 reassurance line
- 3 actions: stop here / repeat / short follow-up

**Behavior notes**
- phải xuất hiện ngay sau session completion
- không confetti, không reward framing
- should bridge into reflection or voice journal gently

**Data dependencies**
- completed session context
- next recommended follow-up
- repeat action seed

---

### 5.6 Reflection & Growth — `Reflection & Growth`
**Mục tiêu UX**
- phản chiếu xu hướng, không chấm điểm
- cho người dùng thấy continuity mà không áp lực

**Core sections**
- short narrative reflection
- growth summary
- continuity history / total sessions / total time
- voice journal entry point

**Behavior notes**
- không meditation score
- không leaderboard/rank/streak guilt
- nếu không có health data vẫn phải có reflection cơ bản
- nếu có health/noise context thì chỉ làm enrich narrative

**Data dependencies**
- session timeline derived summaries
- check-in data
- noise context
- optional sensor-derived reflection inputs
- voice journal attachment state

---

### 5.7 Library — `Library by Need`
**Mục tiêu UX**
- curated browsing, không marketplace feeling

**Core sections**
- need buckets
- duration / intensity / context filters
- transition modes
- offline-ready marking
- quick-start path

**Behavior notes**
- taxonomy phải match spec: sleep, quick reset, focus, break, overload recovery...
- transition modes là first-class, không ẩn như tag phụ
- offline availability phải rõ

**Data dependencies**
- catalog taxonomy
- content metadata
- local download/cache state
- curated recommendations

---

### 5.8 Quiet Presence — `Quiet Presence`
**Mục tiêu UX**
- companionship without social engagement

**Core sections**
- aggregate time blocks / quiet rooms
- join current quiet session
- no avatars / no chat / no comments

**Behavior notes**
- chỉ aggregate anonymous presence
- nudge chỉ preset-based nếu có hậu phiên
- empty state phải nhẹ nhàng, không làm user thấy trống trải/thất bại

**Data dependencies**
- aggregate presence buckets
- joinable quiet session blocks
- ephemeral membership state

---

### 5.9 Permissions — `Privacy & Permissions - Trusted Foundation`
**Mục tiêu UX**
- giải thích trước khi system permission bật lên
- tạo trust rõ ràng

**Core sections**
- vì sao cần quyền
- dùng dữ liệu gì
- không thu gì
- not now option

**Behavior notes**
- luôn preflight trước system permission cho microphone/health
- không được fail core flow nếu user từ chối quyền
- copy phải explicit về privacy boundary

**Data dependencies**
- permission type
- localized explanation content
- user decision state

---

## 6) Component / design rules dev phải giữ

Nguồn chính: `_bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/DESIGN.md`

### Token highlights
> Nguồn xác thực là `apps/mobile/lib/theme/elaro_color_scheme.dart` + `elaro_surface_ramp.dart`. Các hex dưới đây là giá trị đang ship (night-calm dark scheme); ramp bề mặt có 5 bước (`surfaceContainerLowest` → `surfaceContainerHighest` + `surfaceBright`).
- background dark moss (scaffold surface): `#0F1512`
- surface ramp: lowest `#0A0F0D` · low `#171D1A` · container `#1B211E` · high `#252B28` · highest `#303633` · bright `#343B37`
- primary text (warm linen): `#F4F1EA`
- secondary text (quiet linen): `#C7C1B5`
- muted text: `#978F82`
- primary accent (calm sage): primary `#B7D1B4` / container `#9CB59A`
- secondary accent (muted teal, presence/focus): `#98D1CA`
- warm SOS accent: `#D1AE84` (deep `#CBA97F`) — capsule fill dùng alpha 22%
- safe accent (harbor teal): `#6FA7A0`
- trend palette (AD-5, never a score): calm `#9CB59A` · steady `#6FA7A0` · settling `#D1AE84`
- border hairline: `#333B36`
- error (soft, never pure red): `#FFB4AB`

### Typography / shape
- **Newsreader** (serif) cho display/headline/title + `SoftTimer`; **Inter** (sans) cho body/label. Trọng số light/medium.
- rounded cards mạnh (`lg ~ 28px`); CTA `md ~ 18px`; tile 20px / tile-small 16px; pill/full cho chips, presence dots, SOS capsule
- spacing rộng, không grid dày đặc

### Behavioral design rules
- dark mode default posture
- no clinical aesthetic
- no gamification
- no streak prompts
- no chat/feed/profile/community pressure
- safe exits in 1-2 taps
- haptic-lite defaults cho nhạy cảm

### Durable UX/UI rules (phải giữ sau 2026-06-27 sync)
Nguồn canonical: `_bmad-output/planning-artifacts/ENGINEERING-RULES.md`
1. **Scrollability invariant** — mọi `Scaffold` body + `CalmBottomSheet` body có thể tràn phải scrollable (`SingleChildScrollView` / `ListView` / `CustomScrollView`); sticky CTA nằm ngoài vùng scroll; test ở default + text-scale lớn.
2. **Dev-gating** — mọi debug/QA/telemetry nằm trong `DevSection`; build production bằng `--dart-define=ELARO_RELEASE=true`; không để `DEV • ...` chrome lọt production.
3. **No infinite animations** — không `AnimationController.repeat()`; motion phải degrade sang static/haptic/text khi `Reduce Motion` bật.
4. **Frozen test contract** — không tự ý sửa `apps/mobile/test/widget_test.dart`; giữ nguyên key/text đang bị contract khóa cho đến khi có task unfreeze riêng.
5. **Design-system usage** — ưu tiên `Calm*`, `SectionCard`, `PrimaryCTA`, `PreferenceRow`; dùng `ElaroColors.of(context)` và semantic tokens, không thêm Material stock/hardcoded hex mới.
6. **i18n** — string user-facing mới phải là tiếng Việt; trước khi đổi string cũ, kiểm `widget_test.dart`. Ngoại lệ hiện tại: `Ritual Builder`, `Session start`, `Pack type: Core` còn EN vì test contract khóa.
7. **Tone & product invariants** — night-calm, no gamification/streak/score/leaderboard, presence aggregate-only, offline-first, timeline là system-of-record, permission preflight, haptic-first, distress boundary trên SOS/Reflection/Settings/Permissions.
8. **Phase-7 structure** — `apps/mobile/lib/main.dart` là barrel; symbol thật sống trong `lib/domain|runtime|features` part files; anchor docs phải trỏ vào các file đó, không trỏ `main.dart` cho logic cụ thể.

---

## 7) Architecture / behavior constraints không được lệch

Nguồn chính: `_bmad-output/planning-artifacts/architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md`

### Invariants cần giữ trong build
1. **Session timeline is the system of record**
   - start / pause / complete / abort / SOS / re-entry / journal attach đều nên đi vào timeline events

2. **Offline-first core**
   - Home, Library core packs, playback, growth cơ bản phải chạy được từ local state

3. **Reflection is narrative trend, never a score**
   - không score / rank / percentile / badge

4. **Community is ephemeral aggregate presence only**
   - không social graph, không chat, không profile pressure

5. **Sensing is permission-gated and normalized**
   - không upload raw microphone audio
   - health/noise data chỉ enrich, không block core flow

6. **Dev/QA scaffolding is dev-gated** (reconciled 2026-06-27)
   - runtime telemetry + debug toggles (offline/sensor/permission/biofeedback, elapsed/bell/noise confidence…) chỉ render trong `DevSection`
   - ẩn sạch ở release: build với `--dart-define=ELARO_RELEASE=true` (`kDevMode`/`DevGate.enabled` trong `core/dev_mode.dart`)
   - mặc định debug/test vẫn thấy các control này để widget-test suite đi qua — xem `apps/mobile/test/dev_mode_gating_test.dart`

7. **Distress boundary trên các bề mặt nhạy cảm**
   - `DistressBoundary` ("không thay thế hỗ trợ chuyên môn" + link trợ giúp) hiện trên SOS (entry + active), Reflection, Settings, Permissions
   - action `'Tìm hỗ trợ'` mặc định mở support sheet (hotline / hỗ trợ chuyên môn / người tin cậy)

## 8) Nguồn tài liệu gốc để đối chiếu

### UX spine
- `_bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/EXPERIENCE.md`

### Visual/design system reference
- `_bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/DESIGN.md`

### Architecture spine
- `_bmad-output/planning-artifacts/architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md`

### Product scope / requirements
- `docs/FEATURES_REQUIREMENTS.md`

### Stitch prompt source
- `design-artifacts/stitch/stitch-screen-prompts.md`

### Local UI export package
- `design-artifacts/stitch/ui-review-export/README.md`

---

## 9) Dev handoff recommendation

Thứ tự đội dev nên xử lý:
1. Shell/navigation + bottom tabs
2. Home + SOS flow
3. Session player + gentle re-entry
4. Reflection/Growth
5. Library
6. Quiet Presence
7. Permissions preflight
8. Settings lightweight implementation

### Suggested implementation posture
- Build theo Flutter screen/widget structure và domain contracts từ architecture spine
- Dùng HTML export để tham khảo:
  - spacing
  - hierarchy
  - copy structure
  - card composition
- Không convert HTML 1:1 sang app code

---

## 10) Open items còn lại

> **Implementation status (reconciled 2026-06-25):** các màn trong shortlist đã được build trong Flutter app — code nằm trong các `lib/features/<feature>/<feature>.dart` part file (single library qua `part`/`part of`; `apps/mobile/lib/main.dart` giờ chỉ là barrel chứa `ElaroMedApp`/routing/`_TabScaffold`), dùng design system thật ở `apps/mobile/lib/theme/` + `lib/components/`. Handoff này giờ là tham chiếu ngược; CODE là nguồn xác thực.

Các mục này chưa phải blocker cho dev kickoff nhưng nên thống nhất sớm:
- route và scope chi tiết cho `Settings`
- mức tách page riêng cho `Rituals`
- ~~`Voice journal` là modal, bottom sheet, hay page riêng~~ → **đã chốt:** voice journal là dedicated screen (`_VoiceJournalScreen`, audio-only, private mặc định, không transcript trong MVP)
- live presence backend contract chi tiết cho bucket/time block
- known i18n debt do frozen test contract: `Ritual Builder`, `Session start`, `Pack type: Core` (muốn localize phải unfreeze `apps/mobile/test/widget_test.dart`)
