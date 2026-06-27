---
name: meditation-community
status: final
sources:
  - ../../prds/prd-meditation-community-2026-06-24/prd.md
  - ../../architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md
updated: 2026-06-27
---

# meditation-community — Experience Spine

> Mã nguồn `apps/mobile/` là nguồn xác thực (source of truth) cho mọi hành vi. Tài liệu này được sync lại 2026-06-27 sau code-gap fix + scroll pass: route handlers, support sheet, empty states, post-session mindful nudge, targeted i18n fixes, và các scrollability invariants đã được phản ánh. `DESIGN.md` là tham chiếu identity thị giác; guardrails bền vững cho dev sống tại `_bmad-output/planning-artifacts/ENGINEERING-RULES.md`. Mọi `ValueKey` / copy trong ngoặc vuông là **verbatim từ code** — dev có thể implement/kiểm tra trực tiếp từ spec.

## Foundation

iOS-first mobile product. Core experience phải dùng được offline và khi microphone, health permissions, hay wearable inputs không sẵn. Dark mode là posture mặc định (xem Known gaps: light mode chưa wire). Runtime copy ship ưu tiên tiếng Việt; debt i18n cần nhớ rõ là **3 chuỗi user-facing EN bị khóa bởi `apps/mobile/test/widget_test.dart`** — `Ritual Builder`, `Session start`, `Pack type: Core`. Những chuỗi này chỉ được localize sau khi unfreeze test contract; string mới hoặc string user-facing chưa bị khóa phải viết tiếng Việt. Haptic là một lớp dẫn đường quan trọng cho `SOS`, timer bell, gentle re-entry, và các micro-moments mà người dùng không muốn nhìn màn hình lâu.

Một thư viện Dart duy nhất được tách qua `part`/`part of`; `lib/main.dart` chỉ là **barrel** (giữ `ElaroMedApp`, routing `_buildRoute`, và `_TabScaffold` 4 tab). Mọi screen/runtime/domain symbol sống trong part file tương ứng (`lib/features/*`, `lib/runtime/*`, `lib/domain/*`).

## Information Architecture

Bảng dưới ánh xạ surface ↔ route thực tế trong `_buildRoute` (`apps/mobile/lib/main.dart`).

| Surface | Route | Reached from | Mục đích |
|---|---|---|---|
| Home | `/home` | App open (`initialRoute`) | 1-2 body CTA phù hợp nhất theo thời điểm/trạng thái/continuity; SOS capsule ở header |
| Quick check-in | (inline trên Home) | Home | Chọn nhanh cảm xúc/năng lượng `_CheckinState` để điều chỉnh gợi ý |
| SOS entry | `/sos` | Home — capsule header `cta-sos` | Quyết định mode (active / calm-safe) và vào flow |
| SOS active | `/sos/active` | SOS entry | Flow 60 giây hạ nhiệt + calm-safe exit |
| Session start | `/session/start`, `/session/short-breath-3m`, `/session/micro/{20s,45s,90s,3m}`, `/session/before-sleep-8m`, `/session/ritual-*` | Home CTA, Library, Ritual replay/continuity, Growth, Mindful nudge | Chọn/bắt đầu session; before-sleep prefill 480s, ritual continuity prefill ritual mới nhất |
| Session active | `/session/active` | Session start | Chạy phiên: SoftTimer + ProgressRing + BreathingCircle + haptic |
| Session reflection | `/session/{id}/reflection` | Gentle re-entry (follow-up) | Phản hồi narrative-trend, không điểm số |
| Gentle re-entry | `/session/{id}/re-entry` + inline card khi complete | Session completion | Hạ cánh sau phiên, 3 lựa chọn kế tiếp |
| Library | `/library` | Tab 2 | Duyệt theo need/context/duration/intensity/pack + sort |
| Session catalog | `/session/{id}` (không micro) | Library item, Home suggested card | Chi tiết pack + bắt đầu phiên cơ bản/basic flow |
| Growth | `/growth` | Tab 3 | Tổng phiên + tổng thời lượng (không streak) |
| Settings | `/settings` | Tab 4 | Accessibility baseline (haptic toggle + cue modes + DistressBoundary) |
| Presence | `/presence` | Home band / navigate | Hiện diện ẩn danh aggregate-only |
| Ritual builder | `/rituals/builder` | Home ritual row | Tạo ritual từ các bước |
| Ritual replay | `/ritual/replay` | Home ritual replay | Phát lại ritual mới nhất |
| Voice journal | `/voice-journal` | (re-entry follow-up path) | Ghi âm riêng tư gắn session |
| Permission preflight | `/permissions/{microphone|health}/preflight` | Home/Session dev deep-link | Giáo dục quyền trước system prompt |

**Tab bar tối giản** (Material `NavigationBar`, 4 đích): `Home`, `Library`, `Growth`, `Settings` (`Icons.home_outlined`/`menu_book_outlined`/`insights_outlined`/`settings_outlined`). `SOS` **không** nằm trong tab — nó là một **capsule yên tĩnh ở header Home** (`cta-sos`), luôn hiện diện, một chạm vào `/sos`, và **không nằm trong số tối đa 2 body CTA được xếp hạng**. `Rituals`, `Presence`, `Voice journal` không có tab riêng — chúng là entry surfaces dưới Home/Growth/re-entry để giữ kiến trúc yên.

> Route fallback: mọi route không khớp rơi về `_TabScaffold(Home)` (không crash); `/session/{id}` không-micro mở `_SessionCatalogScreen`. `/session/before-sleep-8m` và `/session/ritual-*` (`<continuityHint>`) đã có handler riêng → `_SessionStartScreen` với duration/intent phù hợp (before-sleep=480s, continue-ritual=dùng latest ritual duration, fallback 180s nếu chưa có ritual).

## Voice and Tone

Microcopy nói như một người đồng hành bình tĩnh, không như huấn luyện viên hay hệ thống chấm điểm.

| Do | Don't |
|---|---|
| "Mình bắt đầu nhẹ thôi." / "Let's begin gently." | "Boost your performance now." |
| "Bạn có thể dừng ở đây nếu đã đủ." / "You can stop here if this feels enough." | "Keep going to unlock more progress." |
| "Ứng dụng này không thay thế hỗ trợ chuyên môn." | "We'll help you fix your anxiety." |
| "Không cần hoàn hảo, chỉ cần quay lại." | "You broke your streak." |

Posture copy vẫn phải mềm, rõ, ngắn, không guilt-trip, không chẩn đoán, không overpromise. Reconcile 2026-06-27: các nhãn mục tiêu đã sang tiếng Việt ở surface chính — BreathingCircle `'Hít vào'`/`'Thở ra'`, Presence `'Làm mới'` / `'Đã tham gia'` / `'Tham gia'`, Settings headline `'Nền tảng tiếp cận'`, DataCommitmentBox `'Những gì chúng tôi dùng'` / `'Những gì chúng tôi không thu thập'`, Ritual replay `'Lặp lại nghi thức'`, re-entry title `'Vào lại phiên'`. **Known i18n debt do test contract khóa:** `Ritual Builder`, `Session start`, `Pack type: Core` vẫn phải giữ EN vì `apps/mobile/test/widget_test.dart` assert đúng text; muốn localize phải unfreeze contract trước. Label dev-only có thể còn EN, nhưng string user-facing mới phải viết tiếng Việt.

## Component Patterns

| Component | Use | Quy tắc hành vi (key/copy verbatim) |
|---|---|---|
| Home hero CTA | Home body | Tối đa **2 body CTA** qua `_rankCtas(...).take(2)`; key `cta-${id}` (`cta-short-breath`, `cta-before-sleep`, `cta-continue-ritual`). SOS không thuộc tập này. |
| SOS capsule | Home header (`CalmTopAppBar.trailing`) | `cta-sos`, label `'SOS'`, icon `favorite_rounded`, fill amber 22%; onTap → `/sos`. |
| Emotional check-in chips | Home | `EmotionChip`, key `checkin-${name}`: `checkin-calm` (`'Ấm/nhẹ'`), `checkin-low` (`'Mệt'`), `checkin-overload` (`'Quá tải'`). 1-tap, có thể bỏ qua (`'Bỏ qua check-in'`). |
| Suggested session card | Home, Library | `home-suggested-card` / `home-suggested-title` (`'Gợi ý chuyển tiếp'`); hiển thị `'Transition: … • Duration: … • Offline: …'`; nút `home-suggested-open` (`'Mở phiên đề xuất'`). |
| Quiet presence band | Home, Presence | `home-presence-band` (`CommunityPresenceBand`), copy `'Có người đang ngồi yên cùng bạn lúc này.'` (aggregate-only). |
| Session player | Session active | `SoftTimer` + `ProgressRing` + `BreathingCircle` + `SessionStateLabel`; telemetry sau `DevSection`. |
| Gentle re-entry card | Session completion | `session-reentry-card`: stop / repeat / follow-up. |
| Reflection card | Reflection | Narrative trend theo band thời lượng; `session-reflection-no-pressure` (`'…không đưa ra điểm số…'`). |
| Voice journal recorder | Voice journal | `voice-journal-record` (`'Ghi 1 lần'`/`'Dừng ghi'`); audio-only, `voice-journal-no-transcript`. |
| Pre-permission sheet | Permissions | `permission-preflight-title` + `PermissionCard` + `DataCommitmentBox` + defer/system-prompt. |
| DistressBoundary | SOS×2, Reflection, Settings, Permissions | Message mặc định + action `'Tìm hỗ trợ'` (luôn render, tappable). Mặc định mở `_SupportResourcesSheet` (calm bottom sheet: đường dây nóng khẩn cấp / hỗ trợ chuyên môn / người tin cậy + reassurance `'không thay thế hỗ trợ chuyên môn'`); per-screen có thể override qua `onAction`. |

## State Patterns

| State | Surface | Xử lý |
|---|---|---|
| Cold open | Home | `_greeting(timeBucket)` (`'Chào buổi sáng/chiều/tối.'`), headline `'Bắt đầu phiên phù hợp ngay lúc này'`; CTA chính từ local continuity. |
| Returning after gap | Home | Copy chào lại nhẹ, không nhắc streak; ưu tiên CTA "quay lại nhẹ nhàng" / ritual gần đây. |
| High-stress entry | Home | `cta-sos` nổi bật ở header; body vẫn giữ 1-2 CTA calm-first. |
| Offline available | Home, Library | Badge `home-offline-badge` (`'OFFLINE READY'`) trên suggested card khi `offlineReady`; Library badge `library-offline-badge-${id}` (`'offline-ready'`). |
| No microphone permission | Session | Fallback manual context (`manual-${checkinName}`), nhãn `'độ tin cậy thấp'`; pre-permission sheet giải thích nếu muốn bật. |
| No health permission / no wearable | Reflection | Reflection bản cơ bản (fallback `'Lúc này dữ liệu sinh trắc chưa sẵn sàng…'`); không shaming. |
| Session interrupted | Session active | `_RecoveryChoicesCard` (`session-recovery-card`): resume / gentle-close / new session. |
| Distress-sensitive boundary | SOS (entry+active), Reflection, Settings, Permissions | `DistressBoundary` luôn hiện; message `'Đây là công cụ tự chăm sóc nhẹ nhàng, không thay thế hỗ trợ chuyên môn. Nếu bạn đang gặp khủng hoảng, hãy liên hệ đường hỗ trợ tại chỗ.'` |
| Empty rituals | Ritual replay | `'Không có ritual nào'` (`ritual-empty`) + CTA `ritual-empty-create` (`'Tạo ritual đầu tiên'` → `/rituals/builder`). |
| Presence stale / empty | Presence | Sau TTL 12s → `presence-stale-badge` (`'Stale'`) + `presence-last-updated`, ẩn count mới. Empty-state riêng khi `_currentParticipants == 0`: `presence-empty-message` + `presence-empty-refresh` (`'Làm mới hiện diện'`), aggregate-only. |

## Interaction Primitives

- Một tay, ít chạm, ưu tiên thao tác trực tiếp.
- Haptic cues dẫn nhịp cho SOS, timer bell, breathing beats, completion, confirmation vi mô (xem `HapticFeedbackType {light, medium, selection}`).
- Audio controls rõ: pause (`session-pause-btn` `'Tạm dừng'`), end-early (`'Kết thúc sớm'`), return-home (`session-return-home`). (Lưu ý: không có "switch-to-silence" control riêng trên active screen.)
- Long-press không là cử chỉ cốt lõi.
- System permission chỉ xuất hiện sau pre-permission sheet.
- **Banned:** streak prompts, infinite feed, notification guilt, public comment, chat composer, heatmap áp lực, meditation score, celebration quá đà.

## Accessibility Floor

- Dynamic Type hỗ trợ xuyên suốt; có accessibility-summary line trên Home/Session/Growth/Settings (ví dụ `home-accessibility-summary`, `growth-accessibility-summary`).
- Haptic-first alternatives: `_AccessibilityRuntime.hapticsEnabled` (mặc định ON = haptic-lite), `_hapticsEnabledFor` tôn trọng Reduce Motion; text fallback luôn sẵn (`'Text fallback luôn sẵn có'`).
- VoiceOver labels mô tả CTA, duration, mode, state, check-in chips.
- Tap target tối thiểu chuẩn iOS; chips/time blocks không nhỏ kiểu filter pills trang trí.
- Reduce Motion: `MediaQuery.disableAnimations` tắt animation không cần thiết; breathing có thể chuyển sang haptic/text pacing.
- Scrollability invariant: mọi `Scaffold` body / `CalmBottomSheet` body có thể tràn phải nằm trong `SingleChildScrollView` / `ListView` / `CustomScrollView`; CTA sticky phải nằm ngoài vùng scroll; test ở default text scale và text scale lớn.

## Dev-gating Contract

Telemetry/QA scaffolding **chỉ hiện ở debug/test**, ẩn sạch ở release (`--dart-define=ELARO_RELEASE=true`).

- `ELARO_RELEASE` dart-define → `kElaroRelease` → `kDevMode = !kElaroRelease`. `DevGate.enabled` = `kElaroRelease ? false : (override ?? kDevMode)`. Missed dart-define → fail-safe giữ dev ON (không rò rỉ debug vào production).
- `DevSection` trả `SizedBox.shrink()` khi `!DevGate.enabled`; luôn expanded (không collapse) để widget test định vị inner control.
- **Ẩn trong release (ví dụ):** prompt-count (`permission-prompt-count`), sensor/confidence/biofeedback toggles (`session-noise-confidence-toggle`, `session-bio-permission-enable/disable`, …), preflight deep-links từ Home/Session, runtime-event label (`session-runtime-event`), bell/breathing cue labels, accessibility-summary runtime, SOS reason, network online/offline, mọi `DEV • …` chrome.
- **Luôn hiện (không gate):** EmotionChip durations, start/pause/resume/end-early/return-home, SoftTimer/ProgressRing/BreathingCircle, SessionStateLabel, re-entry TertiaryStackCTA, recovery card, reflection content, DistressBoundary.

## Key Flows

Mỗi flow: **Entry → States/Transitions → Exits → Edge cases → Calm/safety boundary.**

### Flow 1 — Home (CTA ranking + entry surfaces)

**Entry:** mở app → `/home` (`initialRoute`).
**Cấu trúc body (top→bottom):** greeting → headline `'Bắt đầu phiên phù hợp ngay lúc này'` → accessibility-summary → ranked CTAs → suggested card → presence band → mindful-nudge slot → check-in row → ritual row → `DevSection('Home context')`.
**CTA ranking (`_rankCtas`):**
- Candidates (body only, SOS loại trừ):
  - `short-breath` → `'Thở ngắn 3 phút'`, `/session/short-breath-3m`, score 3 (luôn seed).
  - `before-sleep` → `'Chuẩn bị ngủ'`, `/session/before-sleep-8m`, score 4 (khi `interruptionState==returning || timeBucket==night`) AND `lastSessionType==sleep` AND `lastSessionAt!=null`).
  - `continue-ritual` → `'Tiếp tục hành trình'`, `/session/${continuityHint}`, score 2 (khi `continuityHint!=null`).
- Boosts: `lastCheckin==low && afternoon` → short-breath +1; `lastSessionType==focus` → short-breath +1.
- Sort: `isCalmFirst` → score desc → recencyRank desc; **`take(2)`**; fallback (catch) → `[short-breath]`.
**SOS capsule:** `cta-sos` ở `CalmTopAppBar.trailing` → `/sos` với `_SosEntryArgs(contextAvailable, sensorAvailable)`.
**Presence band:** `home-presence-band`, `'Có người đang ngồi yên cùng bạn lúc này.'` (static, không count trên Home).
**Exits:** CTA → `/session/...`; suggested open → `/session/{id}`; ritual builder/replay → `/rituals/builder`|`/ritual/replay`.
**Edge cases:** mọi ranking exception → swallow + render `[short-breath]` (offline-first, luôn có path vào session).
**Calm boundary:** tối đa 2 body CTA; SOS riêng header; secondary info (band/card/check-in/ritual) không mất trọng tâm calm.

### Flow 2 — SOS (entry → active → calm-safe exit)

**Entry:** `cta-sos` → `/sos`. `_SosEntryScreen.initState` gọi `_SosRuntime.evaluateMode`.
**Mode decision (`evaluateMode`):** trả `calmSafe` khi `!contextAvailable || context==null || !sensorAvailable || repeated (lastStart <60s) || (lastCheckin==overload && night)`; ngược lại `active`.
**States:**
- **active (entry):** headline `'Chúng tôi ở đây với bạn.'`; `sos-start-btn` (`EmergencySOSButton`, `'60 giây'`/`'bình ổn'`, icon `air`) → `/sos/active` mode=active + `registerEntry(now)` + haptic medium.
- **calmSafe fallback (entry):** copy `'Không đủ điều kiện SOS nhanh, chuyển sang calm-safe.'`; `sos-safe-btn` (`'Yên vị'`/`'nhẹ nhàng'`, icon `self_improvement`) → `/sos/active` mode=calmSafe.
- **active (`/sos/active`):** `_timeoutSeconds=60`, `Timer.periodic(1s)`; headline `'Cùng nhịp thở, giữ chậm lại.'`; ProgressRing(progress=elapsed/60) + BreathingCircle(4s phase); sub `'Không cần hoàn hảo, chỉ cần quay về.'`.
- **calmSafe (`/sos/active` khi mode=calmSafe HOẶC timeout):** app bar `'SOS Safe'`; headline `'Calm-safe exit: hạ cường độ, quay ra an toàn.'`.
**Transitions:** active → (elapsed≥60) → `_isTimedOut` → `_calmSafeExitTriggered=true` + `recordSosTimeoutExit()` (event `sos_timeout_exit`).
**Exits:** `sos-exit-btn`/`sos-return-btn` (entry) và `sos-active-exit`/`sos-calm-safe-return` (`'Trở về Home an toàn'`) → `recordSosInterrupt('sos_interrupt')` + `popUntil(isFirst)` (Home). Tất cả ≤2 thao tác.
**Edge cases:** audio-off/haptic-disabled → `'SOS haptic fallback: text pacing remains available.'` (`sos-haptic-text-fallback`) + `'Text only fallback'`; pacing visual+haptic (không có audio path trong SOS). Repeated SOS (<60s) → ép calm-safe (`reason='repeated-sos'`).
**Calm boundary:** `DistressBoundary` trên cả entry (`sos-distress-boundary`) và active (`sos-active-distress-boundary`); always-on Exit/Return. Action `'Tìm hỗ trợ'` mặc định mở `_SupportResourcesSheet` (CalmBottomSheet, scrollable) với hotline / hỗ trợ chuyên môn / người tin cậy + reassurance `'không thay thế hỗ trợ chuyên môn'`.

### Flow 3 — Session (start → active → reflection → re-entry)

**Entry (start):** `/session/start`|`/session/short-breath-3m`|`/session/micro/{20s,45s,90s,3m}`|`/session/before-sleep-8m`|`/session/ritual-*` → `_SessionStartScreen`. Route handler riêng prefill before-sleep = 480s + source `before-sleep`; ritual continuity = latest ritual duration (fallback 180s) + source `continue-ritual`. Headline `'Chọn micro session'`; EmotionChip durations `micro-20s/45s/90s/3m` (`_durations=[20,45,90,180]`); nút `session-start-btn`. `_StartupMode` được **derive** (≤90s → `microFast`, else `standard`) — không chọn mode/type trên UI. Startup note `'Đang khởi động nhanh (micro fast/standard)'`, loading `session-start-loading`; chờ 250ms (microFast) / 1100ms (standard) → `/session/active`.
**Bell presets (`_resolveBellCues`):** ≤20s→[5,10,15] · ≤45s→[5,15,35] · ≤90s→[15,45,75] · else→[45,90,135,175].
**Active (`/session/active`):**
- Visual: `SoftTimer` (clock `MM:SS`, serif lớn thấp độ nổi) + `ProgressRing(size:220)` + `BreathingCircle(maxSize:120, 4s phase)`.
- State labels (`SessionStateLabel`): running `'Cùng nhau thở.'`/`'Giữ nhịp chậm — không cần hoàn hảo.'`; paused `'Nghỉ một nhịp.'`; complete `'Phiên đã hoàn tất.'`/`'Bạn có thể dừng ở đây.'`.
- Controls: `session-active-exit` (X), `session-pause-btn` (`'Tạm dừng'`), `session-resume-btn` (`'Tiếp tục'`), `'Kết thúc sớm'` (GhostTextButton, reason `manual-exit`), `session-return-home` (`'Kết thúc và về Home'`).
- Haptics: start `medium`, complete `medium`, bell `selection`, pause `selection`, resume `light`.
- Telemetry: toàn bộ sau `DevSection('Session telemetry')` (mode, offline, source, elapsed, bell status, noise confidence, mic toggle…).
**Reflection (`/session/{id}/reflection`):** title `'Phản hồi phiên'`; eyebrow `'Sau phiên'`, headline `'Phản hồi cảm nhận nhẹ nhàng'`. Trend theo **band thời lượng** (≤45/≤90/>90/no-state) — KHÔNG điểm số. `session-reflection-no-pressure` (`'Tổng kết nhẹ: không đưa ra điểm số, không so sánh…'`). Biofeedback (khi health + highConfidence≥0.6): tone words HR/movement + HRV direction `'ổn định hơn'`/`'đang hồi dần'` + `'%một là chiều hướng, không phải chỉ số'`. Fallback khi thiếu: `session-reflection-biofeedback-fallback`. Return `session-reflection-return` (`'Quay về Home'`).
**Re-entry (`/session/{id}/re-entry` + inline card):** headline `'Re-entry sau phiên'`, reassurance `'Lời nhắc nhẹ: thở chậm 1 nhịp rồi chọn bước kế tiếp.'`. `TertiaryStackCTA`: `session-reentry-stop` (`'Dừng & về Home'`), `session-reentry-repeat` (`'Lặp lại'`), `session-reentry-followup` (`'Phản chiếu phiên'` → reflection).
**Edge cases:**
- Interrupted (app background): `_RecoveryChoicesCard` (`session-recovery-card`): `session-recovery-resume` (`'resume'`), `session-recovery-close` (`'gentle-close'`), `session-recovery-new` (`'new session'`).
- Offline: `'Offline: yes (local runtime)'`; catalog basic flow `'Phiên này mở theo flow cơ bản (chạy local…)'` + retry `'Thử lại nhẹ nhàng'` với stop-loss backoff.
- Sensor unavailable / low confidence: `'Tín hiệu sensor bị giới hạn…'`; manual context `'Context thủ công: manual-${checkinName}'` (calm/low/overload); `'độ tin cậy thấp'`.
- Mid-session mic denied: `dropEnrichment()` (mic=false, confidence=0.2) → recovery card; không reset timer/timeline; `'Enrichment: bỏ qua (thiếu quyền mic)'`.
**Calm boundary:** `DistressBoundary` trên Reflection (`reflection-distress-boundary`) và action `'Tìm hỗ trợ'` mặc định mở support sheet. Mọi exit → `popUntil(isFirst)` (Home). Start/Active/Re-entry vẫn giữ calm-first bằng escape rõ ràng + completion/re-entry copy, nhưng chưa thêm DistressBoundary riêng.

### Flow 4 — Permission preflight

**Entry:** `/permissions/{microphone|health}/preflight` (deep-link từ Home/Session DevSection). `_permissionTypeFromRoute` coerce unknown → `'microphone'`.
**Sheet (`_PermissionPreflightScreen`):** title `'Preflight quyền microphone'`/`'Preflight quyền sức khỏe'`; `PermissionCard` (`permission-purpose`), `DataCommitmentBox` (`permission-data-used`, `permission-data-not-used` — mic chứa `'raw audio'`), explainer `'Bạn có thể tiếp tục sau…'`, `permission-defer-btn` (`'Để sau'` → pop), `permission-system-prompt-btn` (`'Tiếp tục tới prompt hệ thống'` → `_PermissionPromptRuntime.request` + snackbar).
**Denied → manual fallback:** KHÔNG ở layer preflight (sheet chỉ defer/system-prompt). Denial xử lý downstream trong session qua `dropEnrichment()` (xem Flow 3).
**prompt-count:** `_PermissionPromptRuntime` (in-memory, per-type), hiển thị `'Prompt count: N'` trong `DevSection('Permission prompt counter')` — **dev-gated**.
**Exits:** defer (pop) hoặc system-prompt (counter++ + snackbar).
**Calm boundary:** `DistressBoundary` (`permission-distress-boundary`) với action `'Tìm hỗ trợ'` mặc định mở support sheet.
**Redaction:** `redactSensitiveLogData` masks `microphone_raw_audio`, `voice_transcript`, `user_email`, `device_serial`, `location_*` (≥5 field); bio_feedback details redact HR/HRV/movement (giữ confidence).

### Flow 5 — Voice journal

**Entry:** `/voice-journal` (`_VoiceJournalScreen`); `sessionId` mặc định `_SessionRuntime.lastSessionId` (`'none'` nếu chưa có session).
**States:** title `'Nhật ký giọng nói sau phiên'`; `voice-journal-session` (`'Gán cho phiên: $id'`); `voice-journal-private` (`'Private scope'`/`'Mặc định true'`, `_isPrivate=true`); `voice-journal-no-transcript` (`'Bản ghi riêng tư: không tự động chuyển văn bản — chỉ lưu âm thanh gắn với phiên.'`); `voice-journal-record` (`'Ghi 1 lần'`/`'Dừng ghi'`).
**AUDIO-ONLY:** `saveVoiceJournal(..., transcribeAllowed: false)` hard-coded → KHÔNG transcript trong MVP. (Runtime forward-capable nhưng screen luôn false.)
**Attach:** stop → append `journal` event (aggregateId=sessionId) vào `SessionTimeline` + lưu `_VoiceJournalEntry`.
**Exits:** record toggle; result `voice-journal-saved`/`voice-journal-result`.
**Edge cases:** `hasSession = sessionId != 'none'` gate record button (disabled khi chưa có session). (Code gap: 3 widget test đang `skip: true`; arg `voicePrivacyAllowed` dead.)
**Calm boundary:** private-by-default; không gửi third-party.

### Flow 6 — Presence (aggregate-only)

**Entry:** `/presence`. Title `'Hiện diện cộng đồng ẩn danh'`; `presence-privacy-note` (`'Tổng hợp dữ liệu không định danh… chỉ thống kê tổng, không có hồ sơ riêng lẻ.'`).
**Aggregate-only:** count mock (`184` init), refresh `80 + (count+17)%300`; band `'Cùng $_currentParticipants người đang tĩnh tại khoảnh khắc này.'`; `presence-current-count`, `presence-history-count` (7 ngày). KHÔNG profile/chat/feed/thread (widget test assert `'Username'/'Chat'/'avatar'` findsNothing).
**Join/leave:** `presence-join` (`'Tham gia'`) / `presence-leave` (`'Rời block'`); `presence-current-state` (`'Đang tham gia'`/`'Chưa tham gia'`); RoomCard `'Phòng tĩnh lặng'`.
**Stale-swap:** TTL 12s (`_presenceTtl`); sau TTL → `presence-stale-badge` (`'Stale'`) + `presence-last-updated`, ẩn count (`presence-current-count` → findsNothing), RoomCard restingCount=0.
**Exits:** `presence-refresh` (`'Làm mới'`) reset clock; RoomCard CTA đổi theo state `'Tham gia'` / `'Đã tham gia'`.
**Edge cases:** Empty-state khi `_currentParticipants == 0` (refresh range 0–299 cho phép rơi về 0): `presence-empty-message` (`'Hiện chưa có ai đang tĩnh tại cùng lúc.'`) + `presence-empty-refresh` (`'Làm mới hiện diện'`); band cũng đổi message khi count 0. Aggregate-only, không chat/profile.

### Flow 7 — Ritual (builder → save → replay)

**Builder (`/rituals/builder`):** title `'Ritual Builder'`; `ritual-name` (`'Tên ritual'`); pool 5 bước: `'Thở sâu 10 nhịp'`, `'Thả lỏng vai'`, `'Nhắm mắt'`, `'Nghe âm thanh nền'`, `'Mở mắt từ tốn'` (key `ritual-item-${slug}`); `'Chọn tối thiểu 1 bước'`; `ritual-save-btn` (`'Lưu ritual'`, disabled khi thiếu tên/bước). `estimatedSeconds = (20 + (n-1)*15).clamp(20,90)`.
**Save:** `_RitualRuntime.createRitual` (UUIDv7, in-memory map) → pop trả `_RitualDefinition`.
**Replay (`/ritual/replay`):** luôn replay ritual **mới nhất**; `ritual-replay-title` (`'Ritual: $name'`), `ritual-replay-btn` (`'Bắt đầu'`) → `/session/start`. Empty → `ritual-empty` (`'Không có ritual nào'`).
**Home integration:** `home-ritual-builder` (`'Tạo ritual mới'`), `home-ritual-replay` (`'Phát lại ritual gần nhất'`, disabled khi trống), `home-ritual-meta`.
**Edge cases:** Empty state có CTA `ritual-empty-create` (`'Tạo ritual đầu tiên'` → `/rituals/builder`); `_RitualReplayArgs` dead; persistence in-memory only.

### Flow 8 — Library / catalog

**Entry:** `/library` (tab 2). Headline `'Khám phá phiên phù hợp'`, eyebrow `'Thư viện phiên'`.
**Filters (single-select/facet + `'Tất cả'` all chip):**
- Need (`'Nhu cầu'`): Focus/Sleep/Recovery (`need-*`).
- Context (`'Bối cảnh'`): Morning/Afternoon/Night (`context-*`; `any` bị ẩn).
- Duration (`'Thời lượng'`): 20s/45s/90s/3m (`duration-*`).
- Intensity (`'Cường độ'`): Low/Medium/High (`intensity-*`).
- Pack (`'Pack'`): Core/Contextual/Sound Postcard (`pack-type-*`).
- (KHÔNG có transition filter facet — transition chỉ là display attribute.)
**Sort (`library-sort`):** Recommended / Short→Long / Long→Short / Need.
**Catalog:** 6 entry `n1`–`n6`; `library-item-${id}` + `library-pack-badge-${id}` + `library-offline-badge-${id}` (`'offline-ready'`); `library-result-count`.
**Detail (`/session/{id}` `_SessionCatalogScreen`):** `session-catalog-start`, `session-catalog-retry` (`'Thử lại nhẹ nhàng'`), offline-fallback message + retry note/delay (backoff stop-loss).
**Edge cases:** offline + cache miss → basic flow (local) + retry nhẹ; không crash.
**Calm boundary:** "de-densified" = single-select + `any` suppressed (KHÔNG phải cap chip-count — code gap so với kỳ vọng spec).

### Flow 9 — Growth (non-scoring)

**Entry:** `/growth` (tab 3). Eyebrow `'Tiến trình nhẹ nhàng'`, headline `'Bản đồ phát triển'`.
**Totals (KHÔNG streak/score/leaderboard):** `StatTile` `'Tổng phiên: N'`, `'Tổng thời lượng: N phút'` (+ detail giây); `BentoTile` `'Bạn đang xây dựng nhịp đi đều — không chỉ số, không so sánh.'`.
**Continuity:** = tổng phiên + tổng thời lượng (không metric riêng).
**Actions:** `growth-quick-start` (`'Khởi tạo quick session 20s'`), `growth-open-library` (`'Mở thư viện'`); mindful-nudge slot prefix `growth`.
**Edge cases:** (Code gap: không có replay-history list.)

### Flow 10 — Mindful nudge (preset)

**Slots:** Home (`home-*`), Growth (`growth-*`), Presence (`presence-*`), và **post-session** (`session-active-*`).
**Post-session slot (added 2026-06-27):** `_MindfulNudgeSlot(slotKeyPrefix: 'session-active', slotLabel: 'Sau phiên')` render tại session completion (cùng lúc `session-reentry-card`) trên Session active. Gentle, dismissible (skip/disable), dev-gated qua `_MindfulNudgeRuntime.enabled`; completion đã fire haptic medium nên haptic-first.
**Presets:** `'Thở 20s'` (`*-mindful-nudge-20s`, `/session/micro/20s`), `'Thả lỏng 45s'` (`*-mindful-nudge-45s`, `/session/micro/45s`).
**States:** card → skip (`*-mindful-nudge-skip` `'Bỏ qua hôm nay'`) → skipped (`*-mindful-nudge-skipped` + restore `*-mindful-nudge-restore` `'Hiện lại'`); disable (`*-mindful-nudge-disable` `'Tắt gợi ý'` → global `_MindfulNudgeRuntime.enabled=false`) → disabled (`*-mindful-nudge-disabled` + enable `*-mindful-nudge-enable` `'Bật lại'`).
**Calm boundary:** `'Preset yên tĩnh, aggregate-only, không tạo social graph. Có thể bỏ qua bất cứ lúc nào.'`.

### Flow 11 — Settings (accessibility baseline)

**Entry:** `/settings` (tab 4). Headline `'Nền tảng tiếp cận'`.
**MVP scope (match code):** `settings-haptics-toggle` (`'Phản hồi rung'`, `'Text fallback luôn sẵn có'`); cue lines `settings-sos-cue`, `settings-bell-cue`, `settings-breathing-cue` (`_cueModeLabel`); paragraph `'Audio is optional. Text guidance remains available…'` vẫn là mixed-language baseline trong code hiện tại.
**Calm boundary:** `DistressBoundary` (`settings-distress-boundary`).
**Edge cases / future:** language selector, theme toggle, notifications, privacy section, permissions/health-links, calm-exit control **chưa implement** trong MVP (doc cũ over-specify — đã reconcile; các mục này là planned, không phải shipped behavior).

## Cross-cutting Invariants

- **Offline-first:** `_MockDeviceRuntime.networkAvailable`; core packs (`offlineReady=true`) luôn chạy local; offline→basic flow + retry stop-loss.
- **Timeline as system-of-record:** `SessionTimeline` (immutable events, `idempotencyKey` dedupe, sort `(occurredAtUtc, sourcePriority, timelineOrder)`). Event types: start/pause/complete/abort/sessionInterrupted/sos/sosInterrupt/sosTimeoutExit/reEntry/checkIn/journal/ritual. `lastSessionId = _timeline.lastEvent?.aggregateId ?? 'none'`.
- **Permission preflight:** system prompt chỉ sau sheet; redaction whitelist.
- **Haptic-first runtime:** default ON (haptic-lite), Reduce Motion aware, text fallback luôn sẵn.
- **Distress boundary surface set:** SOS (entry+active), Reflection, Settings, Permissions; action mặc định mở `_SupportResourcesSheet`.
- **Durable build rules:** mọi thay đổi UI/runtime sau sync này phải giữ theo `_bmad-output/planning-artifacts/ENGINEERING-RULES.md` (scrollability, dev-gating, no infinite animations, frozen test contract, design-system usage, i18n, tone/invariants, Phase-7 structure).
- **Error envelope:** `AppErrorEnvelope(code, message, retryable, details)`; UUIDv7; UTC ISO-8601; sync conflict = append-then-reconcile; retry exponential backoff + jitter + stop-loss.

## Safety & Recovery Hardening

- **Calm escape rule:** SOS, session, reflection luôn có Exit/Return trong 1-2 thao tác.
- **Permission fallback:** mic/health denied → flow không dừng; session chạy manual context; không claim dựa sensor thiếu.
- **Distress loop guardrail:** SOS liên tiếp <60s → ép calm-safe (`reason='repeated-sos'`); overload+night → calm-safe.
- **Haptic sensitivity:** haptic-lite mặc định; haptics nâng cao chỉ khi user bật (toggle trong Settings).
- **State recovery:** thiếu sensor → nhãn độ tin cậy rõ, không phán xét chất lượng phiên.
- **Home pressure control:** tối đa 2 body CTA; `cta-sos` riêng header, không tính vào số 2.

## Known code/spec gaps (re-baseline 2026-06-26; code-gap fix pass 2026-06-27)

Những chỗ code **thực tế** khác/kém hơn spec cũ — đã reconcile spec cho khớp, leader có thể quyết định đây là spec gap (đã khắc phục trong doc) hay code gap (cần code work sau). Mục **(đã fix 2026-06-27)** = đã đóng trong code-gap fix pass này.

1. **Manual noise context:** spec cũ dùng `yên/vừa/ồn`; code dùng `_CheckinState {calm, low, overload}` → `manual-calm/manual-low/manual-overload`. Spec đã sửa theo code (xem PRD FR-12 mapping note).
2. **Settings scope hẹp hơn spec cũ:** chỉ accessibility baseline (haptic + cues + DistressBoundary); không có language/theme/notifications/privacy/permissions/health-links/calm-exit.
3. **Light mode chưa wire:** dark-only (`Brightness.dark` hardcode); light tokens chỉ là planned.
4. **(đã fix 2026-06-27) Mindful nudge post-session:** giờ có slot `session-active-*` render tại session completion (Flow 10).
5. **(đã fix 2026-06-27) Presence empty-state:** empty-state khi count 0 (`presence-empty-message` + `presence-empty-refresh`), aggregate-only; refresh range mock nay là 0–299.
6. **(đã fix 2026-06-27) Ritual empty CTA:** `ritual-empty-create` (`'Tạo ritual đầu tiên'` → `/rituals/builder`).
7. **(đã fix 2026-06-27) Route handler** `/session/before-sleep-8m` (480s before-sleep) và `/session/ritual-*` (continue-ritual, latest ritual duration hoặc fallback 180s) — CTA không còn rơi về fallback.
8. **(đã fix 2026-06-27) `DistressBoundary` action `'Tìm hỗ trợ'`** mặc định mở `_SupportResourcesSheet` trên mọi surface (SOS×2, Reflection, Settings, Permissions).
9. **(đã fix 2026-06-27) Scrollability invariant:** mọi screen/sheet có nguy cơ tràn trong core flows hiện dùng scroll container; support sheet cũng scrollable.
10. **Known i18n debt (sau targeted Vi sweep 2026-06-27):** các surface mục tiêu đã sang Vi (`Hít vào`/`Thở ra`, `Làm mới`, `Đã tham gia`/`Tham gia`, `Nền tảng tiếp cận`, `Những gì chúng tôi dùng` / `Những gì chúng tôi không thu thập`, `Lặp lại nghi thức`, `Vào lại phiên`). **Ba chuỗi user-facing vẫn phải giữ EN do `widget_test.dart` khóa contract:** `Ritual Builder`, `Session start`, `Pack type: Core`.
11. **Dead/dormant code:** `_SessionType{focus,sleep}` không chọn trên UI; `BreathingCircle.onPhaseChange`, `abortSession`, `_RitualReplayArgs`, `_VoiceJournalArgs.voicePrivacyAllowed` không dùng; duplicate key `sos-haptic-text-fallback` trên 2 screen SOS.
12. **Voice journal:** 3 widget test `skip: true`; runtime forward-capable transcript nhưng screen luôn `false`.
13. **Persistence in-memory** (ritual/voice-journal/nudge flag) — không survive restart.
