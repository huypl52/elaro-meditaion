---
name: meditation-community
description: Ứng dụng thiền mobile-first cho những khoảnh khắc cần bình ổn nhanh, nhẹ, và không phán xét.
status: final
sources:
  - ../../prds/prd-meditation-community-2026-06-24/prd.md
  - ../../architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md
updated: 2026-06-27
color_sources:
  dark_scheme: apps/mobile/lib/theme/elaro_color_scheme.dart
  surface_ramp: apps/mobile/lib/theme/elaro_surface_ramp.dart
  note: "Dark-only (Brightness.dark hardcode). Light theme chưa wire — light tokens dưới đây là planned, chưa có ColorScheme."
colors_dark:
  surface: "#0F1512"
  surfaceContainerLowest: "#0A0F0D"
  surfaceContainerLow: "#171D1A"
  surfaceContainer: "#1B211E"
  surfaceContainerHigh: "#252B28"
  surfaceContainerHighest: "#303633"
  surfaceBright: "#343B37"
  onSurface: "#F4F1EA"
  onSurfaceVariant: "#C7C1B5"
  inkMuted: "#978F82"
  outline: "#5E635D"
  outlineVariant: "#333B36"
  primary: "#B7D1B4"
  onPrimary: "#1A2620"
  primaryContainer: "#9CB59A"
  onPrimaryContainer: "#121C17"
  secondary: "#98D1CA"
  onSecondary: "#0E2D2A"
  secondaryContainer: "#15524C"
  onSecondaryContainer: "#BFEFE8"
  tertiary: "#E9C498"
  onTertiary: "#2A1F11"
  tertiaryContainer: "#CBA97F"
  warmAmber: "#D1AE84"
  warmAmberDeep: "#CBA97F"
  safeTeal: "#6FA7A0"
  trendCalm: "#9CB59A"
  trendSteady: "#6FA7A0"
  trendSettling: "#D1AE84"
  error: "#FFB4AB"
  onError: "#690005"
  errorContainer: "#93000A"
  onErrorContainer: "#FFDAD6"
  scrim: "#0E120F"
  shadow: "#000000"
  surfaceTint: "#B7D1B4"
  inversePrimary: "#4D644D"
  inverseSurface: "#DEE4DF"
  onInverseSurface: "#2C322E"
colors_light_planned:
  note: "Aspirational — chưa wire trong code (không có ColorScheme light). Giữ làm reference thiết kế."
  surface-base-light: "#F7F3EC"
  surface-raised-light: "#FFFFFF"
  ink-primary-light: "#222621"
  ink-secondary-light: "#5E635D"
  border-hairline-light: "#DDD7CC"
typography:
  families:
    newsreader: "Newsreader (serif) — display/headline/title/SoftTimer/statNumber; bundled asset, offline-first"
    inter: "Inter (sans) — body/label/CTA/micro-label; bundled asset"
    tabular_figures: "[FontFeature.tabularFigures()] cho chữ số timer/stat"
  roles:
    title: "titleLarge/Medium/Small (Newsreader w500 / Inter w600 cho titleMedium/Small)"
    headline: "headlineLarge/Medium/Small (Newsreader w500; 30/26/22px)"
    body: "bodyLarge/Medium/Small (Inter w400; 16/14/12px)"
    body_emphasis: "reassurance (Inter w600 16px) và/hoặc labelLarge"
    meta: "bodySmall / labelMedium"
    soft_timer: "softTimer (Newsreader w300 96px, letterSpacing -1, tabular) — 'time is felt, not counted'"
    stat_number: "statNumber (Newsreader w500 34px, tabular)"
    eyebrow: "eyebrow (Inter w600 11px, letterSpacing 1.4, uppercase tracked)"
  note: "Trọng số light/medium, hiếm khi bold. Dynamic Type honoured ở mọi cấp."
rounded:
  card: 28
  cta: 18
  tile: 20
  tile_small: 16
  pill: 9999
  sheet: 28
  icon_button: 9999
spacing:
  xs: 4
  sm: 8
  md: 12
  lg: 16
  xl: 24
  xxl: 32
  xxxl: 48
  safe_margin: 20
  ritual_gap: 28
components:
  primary_cta:
    background: "{colors_dark.primaryContainer}"
    foreground: "{colors_dark.onPrimaryContainer}"
    radius: "{rounded.cta}"
  sos_cta:
    background: "{colors_dark.warmAmberDeep} @ 22% alpha (translucent capsule fill)"
    foreground: "{colors_dark.warmAmber}"
    radius: "{rounded.pill}"
    note: "Header capsule (`cta-sos`), luôn ở app bar Home — không phải body button."
  quiet_card:
    background: "{colors_dark.surfaceContainer}"
    foreground: "{colors_dark.onSurface}"
    border: "1px solid {colors_dark.outlineVariant}"
    radius: "{rounded.card}"
  haptic_chip:
    background: "{colors_dark.surfaceContainerHigh}"
    foreground: "{colors_dark.onSurface}"
    radius: "{rounded.pill}"
  permission_sheet:
    background: "{colors_dark.surfaceContainer}"
    foreground: "{colors_dark.onSurface}"
    radius: "{rounded.card}"
---

## Brand & Style

`meditation-community` phải giống một nơi người dùng được đón vào khi hệ thần kinh đang mệt, không phải một app đòi tương tác thêm. Cảm giác cốt lõi là ấm áp, an toàn, không phán xét, và đủ vững để quay lại mỗi ngày dù hôm đó chỉ có 60 giây.

Visual language ưu tiên "night calm" làm posture mặc định: nền tối dịu, chữ sáng mềm, điểm nhấn vừa đủ ấm để mời gọi chứ không kích thích. Không mang aesthetic clinical, performance, hay spiritual theatrics. Đây là công cụ tự điều hòa gần gũi, không lên lớp, không trình diễn.

An toàn là một lớp thẩm mỹ: không để người dùng kẹt hay bị đẩy vào lựa chọn phức tạp khi đang căng thẳng. Mọi luồng đều có đường thoát an toàn trong tối đa 1-2 thao tác.

## Colors

> Token triển khai thực tế (source of truth): `apps/mobile/lib/theme/elaro_color_scheme.dart` (`elaroColorScheme`, `Brightness.dark`, hand-tuned — không `fromSeed`) + `elaro_surface_ramp.dart` (`ElaroSurfaceRamp.defaults`). Tổng **34 token** (26 ColorScheme + 8 ramp). Truy cập qua `ElaroColors.of(context)`.

### Surface ramp (tối → sáng, dark)
| Token | Hex | Vai trò |
|---|---|---|
| `surface` | `#0F1512` | Deep Moss — canvas/scaffold bg mặc định |
| `surfaceContainerLowest` | `#0A0F0D` | mức sâu nhất |
| `surfaceContainerLow` | `#171D1A` | nav bar / tonal step |
| `surfaceContainer` | `#1B211E` | card / list row / catalog |
| `surfaceContainerHigh` | `#252B28` | chip / input / snackbar |
| `surfaceContainerHighest` | `#303633` | switch track / progress track |
| `surfaceBright` | `#343B37` | active surface / haptic chip highlight |

### Ink ramp + outline
| Token | Hex | Vai trò |
|---|---|---|
| `onSurface` | `#F4F1EA` | Warm Linen — ink chính |
| `onSurfaceVariant` | `#C7C1B5` | Quiet Linen — ink phụ |
| `inkMuted` | `#978F82` | caption/meta/timestamp |
| `outline` | `#5E635D` | divider primary |
| `outlineVariant` | `#333B36` | border hairline |

### Accents
| Token | Hex | Vai trò |
|---|---|---|
| `primary` / `primaryContainer` | `#B7D1B4` / `#9CB59A` | Calm Sage — hành động tích cực, primary CTA |
| `secondary` / `secondaryContainer` | `#98D1CA` / `#15524C` | muted teal — community/presence/focus |
| `tertiary` / `tertiaryContainer` | `#E9C498` / `#CBA97F` | warm sand/amber — SOS/breathing/reassurance |
| `warmAmber` / `warmAmberDeep` | `#D1AE84` / `#CBA97F` | SOS capsule fill / ProgressRing stroke |
| `safeTeal` | `#6FA7A0` | Harbor Teal — completion/stability/DistressBoundary icon |
| `error` / `errorContainer` | `#FFB4AB` / `#93000A` | soft error (không bao giờ pure red) |

### Trend palette (AD-5 — narrative, không bao giờ là điểm số)
| Token | Hex | Nghĩa |
|---|---|---|
| `trendCalm` | `#9CB59A` | "settling" (sage) — == `primaryContainer` |
| `trendSteady` | `#6FA7A0` | "steady" (teal) — == `safeTeal` |
| `trendSettling` | `#D1AE84` | "still gathering / low-confidence" (amber) — == `warmAmber` |

> **Reconcile 2026-06-26:** bản DESIGN cũ gán sai `surface-base: #171D1A` ở frontmatter — giá trị đó thực ra là `surfaceContainerLow`. Scaffold bg thật là `surface = #0F1512` (Deep Moss). Đã sửa. Bản cũ cũng khai light variants như đã wire — thực tế **dark-only**; light tokens nay đánh dấu `planned`.

Không dùng đỏ bão hòa cho căng thẳng (error soft `#FFB4AB`), không gradient "wellness fantasy", không màu để chấm điểm chất lượng thiền.

## Typography

Chữ là công cụ điều tiết chính. App ưu tiên type lớn, nhịp thở rộng, độ nén thấp.

**Font families** (`apps/mobile/lib/theme/elaro_fonts.dart`): **Newsreader** (serif) cho display/headline/title, `SoftTimer`, `statNumber`; **Inter** (sans) cho body/label/CTA. Cả hai là bundled asset (offline-first, không runtime font fetch). `tabularFigures` cho chữ số timer/stat. Trọng số light/medium, hiếm khi bold.

### Type roles → code (`elaro_typography.dart` + `ElaroTypography.defaults`)
| Spec role | Code role | Family / weight / size |
|---|---|---|
| display | `displayLarge/Medium/Small` | Newsreader w300/w300/w400 — 48/40/32 |
| headline | `headlineLarge/Medium/Small` | Newsreader w500 — 30/26/22 |
| title | `titleLarge` (Newsreader w500 20) / `titleMedium`+`titleSmall` (Inter w600 16/14) | — |
| body | `bodyLarge/Medium/Small` | Inter w400 — 16/14/12 |
| label | `labelLarge/Medium/Small` | Inter w600 — 14/12/11 |
| **body-emphasis (reassurance)** | `reassurance` | Inter w600 16, height 1.45 — "Bạn có thể dừng ở đây." |
| meta | `bodySmall` / `labelMedium` | — |
| **SoftTimer** | `softTimer` | Newsreader w300 **96px**, letterSpacing -1, tabular — "time is felt, not counted" |
| **statNumber** | `statNumber` | Newsreader w500 34px, tabular — Growth totals |
| **eyebrow** | `eyebrow` | Inter w600 11px, letterSpacing 1.4, uppercase tracked — "RIGHT NOW"/section micro-label |

Dynamic Type mặc định ở mọi cấp. Runtime copy ship ưu tiên tiếng Việt; hiện chỉ có 3 chuỗi user-facing EN còn giữ nguyên do `apps/mobile/test/widget_test.dart` khóa contract (`Ritual Builder`, `Session start`, `Pack type: Core`). Mọi string mới phải chịu text expansion mà không vỡ hierarchy.

## Layout & Spacing

Mobile-first, single-column, thumb-friendly (`apps/mobile/lib/theme/elaro_shapes.dart`: `ElaroSpacing`).

| Token | px | Vai trò |
|---|---|---|
| `xs/sm/md/lg` | 4/8/12/16 | grid cơ bản |
| `xl/xxl/xxxl` | 24/32/48 | khoảng thở lớn |
| `safeMargin` | 20 | biên an toàn đa số màn |
| `ritualGap` | 28 | khoảng giữa các khối cần thở (CTA, check-in, presence, reflection) |

Home chỉ 1-2 body CTA mạnh above-the-fold (cùng `cta-sos` header capsule + presence band). Người dùng không "quản lý dashboard" — chỉ thấy con đường tiếp theo rõ ràng.

## Elevation & Depth

Độ sâu đến từ tonal layering (surface ramp 7 bước) + blur mềm, không từ shadow sắc. Sheet xin quyền, picker, modal hậu tuần có thể nổi hơn mặt nền nhưng đọc như "lớp bảo bọc", không phải cảnh báo bật lên.

**Motion / static-decoration rule:** mặc định tôn trọng `Reduce Motion` (`MediaQuery.disableAnimations`); các component calm đọc flag và đặt `duration: reduceMotion ? Duration.zero : …` (ví dụ `CalmBottomNavBar` 200ms). Breathing guidance có thể chuyển sang haptic/text pacing. Tránh motion không cần thiết trong mọi luồng calm. **Không** glassmorphism bóng bẩy, **không** shadow cứng kiểu productivity, **không** tonal-layer trên image thật (image được color-blend `BlendMode.dstATop` với `onSurfaceVariant` — luôn tonal recolor, không true-color).

## Shapes

Bo góc mềm và rộng (`apps/mobile/lib/theme/elaro_shapes.dart`: `ElaroShapes`).

| Token | radius | Dùng cho |
|---|---|---|
| `card` | 28 | card chính, session player, permission sheets, reflection |
| `cta` | 18 | primary CTA buttons |
| `tile` | 20 | bento/stat/list row/narrative |
| `tileSmall` | 16 | commitment box, DistressBoundary, small cards |
| `pill` | 9999 (full) | chips, time blocks, presence dots, SOS capsule |
| `sheet` | 28 | bottom sheet / bottom nav |
| `iconButton` | 9999 (full) | circular icon buttons |

Hình tròn hoàn hảo chỉ xuất hiện ở `ProgressRing`/`BreathingCircle` hoặc presence pulses khi thật sự cần. Còn lại ưu tiên capsule và card mềm.

## Components

- **Primary CTA** — hành động chính trên Home, Library quick-start, Ritual entry. `{components.primary_cta}` (`ElevatedButton` → `primaryContainer`/`onPrimaryContainer`, radius `cta` 18). Một màn chỉ nên có một primary CTA thống trị.
- **SOS capsule** — capsule yên tĩnh ở header Home (`cta-sos`), không phải nút body lớn. Fill amber nhạt (translucent 22%), chữ/icon `warmAmber`, bo `pill`. Copy `'SOS'`, trực diện, không giật gân; luôn nhất quán vị trí, một chạm vào `/sos`.
- **SoftTimer + ProgressRing + BreathingCircle** — bộ primitive cho Session player và SOS active: đồng hồ serif lớn thấp độ nổi (`SoftTimer`/`softTimer` 96px), vòng tiến trình `warmAmberDeep` trên track tonal (`ProgressRing` 220px session / 240px SOS), vòng thở mở/thu theo pha 4s (`BreathingCircle`). Low-cognitive-load, không trông như media player; **mọi telemetry runtime nằm sau `DevSection`** (chỉ debug/test, ẩn release).
- **CommunityPresenceBand** — dải presence yên tĩnh trên Home (một `PresenceDot` + câu aggregate), dẫn vào Presence surface. Aggregate-only, không profile/chat.
- **DistressBoundary** — khối ranh giới ("không thay thế hỗ trợ chuyên môn" + link hỗ trợ) trên SOS (entry+active), Reflection, Settings, Permissions. Icon `shield_outlined` teal an toàn (`safeTeal`). Action `'Tìm hỗ trợ'` mặc định mở `_SupportResourcesSheet` (CalmBottomSheet, scrollable) với hotline / hỗ trợ chuyên môn / người tin cậy.
- **Quiet card / ListRowCard / SectionCard / StatTile / BentoTile** — card cho suggested session, gentle re-entry, growth summary, presence, catalog row. Tái sử dụng chung qua Home + Library.
- **Haptic chip (`EmotionChip`)** — chips cho check-in, noise context, time block, need taxonomy. Đủ lớn để chọn nhanh, đủ yên để không thành filter cloud ồn.
- **Permission sheet** — pre-permission education (`{components.permission_sheet}`): `PermissionCard` (purpose) + `DataCommitmentBox` ('What we use' / "What we don't collect") + defer/system-prompt.
- **EmergencySOSButton** — nút lớn hai-line (topLabel/bottomLabel + icon) cho SOS start/safe.
- **TertiaryStackCTA** — stack 3 lựa chọn cho re-entry (stop/repeat/follow-up).
- **RecoveryChoicesCard** — 3 lựa chọn khi session interrupted (resume/gentle-close/new session).

## Calm-player pattern (canonical)

Session active + SOS active dùng cùng một tổ hợp primitive:
`SoftTimer` (clock) + `ProgressRing` (tiến trình tonal) + `BreathingCircle` (pha thở 4s, host-driven `(elapsed~/4)%2`) + `SessionStateLabel` (headline/sublabel calm). Haptic fires tại: start (`medium`), complete (`medium`), bell (`selection`), pause (`selection`), resume (`light`). **Mọi giá trị runtime** (elapsed, bell status, noise confidence, mic toggle, accessibility summary chi tiết) nằm trong `DevSection` — production clean.

## Dev-gating

(tóm tắt; chi tiết trong `EXPERIENCE.md` → "Dev-gating Contract".) `--dart-define=ELARO_RELEASE=true` → `kElaroRelease` → `DevGate.enabled=false` → `DevSection` trả `SizedBox.shrink()`. Missed define → fail-safe dev ON. Production sạch mọi `DEV • …` chrome, prompt-count, sensor/QA toggles, telemetry panels.

## Do's and Don'ts

| Do | Don't |
|---|---|
| Để dark mode làm posture mặc định (light là planned, chưa wire) | Dùng đen tuyệt đối, neon accent, contrast gắt alarm |
| Cho chữ lớn, khoảng thở rộng, CTA ít nhưng rõ | Nhồi nhiều lựa chọn ngang hàng trên Home |
| Dùng màu ấm để mời gọi và trấn an | Dùng đỏ/cam chói thúc ép hành vi |
| Thiết kế completion như reassurance nhẹ | Dùng confetti, streak flare, celebration quá đà |
| Giải thích quyền bằng copy rõ và tôn trọng | Bật system permission đột ngột không ngữ cảnh |
| Tonal layering + blur mềm cho độ sâu | Glassmorphism bóng bẩy / shadow cứng productivity |

## Durable UX/UI engineering rules

Nguồn guardrail bền vững cho dev: `_bmad-output/planning-artifacts/ENGINEERING-RULES.md`. Tóm tắt 8 rules phải giữ: (1) mọi body/sheet có thể tràn đều scrollable, CTA sticky ở ngoài vùng scroll; (2) mọi debug/QA/telemetry nằm trong `DevSection` và release build dùng `--dart-define=ELARO_RELEASE=true`; (3) không `AnimationController.repeat()` — motion phải degrade sang static/haptic khi Reduce Motion; (4) không sửa `apps/mobile/test/widget_test.dart`, giữ nguyên frozen text/key contract cho tới khi có task unfreeze riêng; (5) dùng component `Calm*`/`SectionCard`/`PrimaryCTA`/`PreferenceRow` + tokens `ElaroColors.of(context)`, không thêm Material stock/hardcoded hex mới; (6) string user-facing mới phải là tiếng Việt, trừ 3 ngoại lệ đang bị test khóa; (7) giữ night-calm / no-gamification / aggregate-only / offline-first / timeline-as-record / permission-preflight / haptic-first / distress-boundary surface set; (8) Phase-7 structure: `main.dart` là barrel, symbol thật sống ở `lib/domain|runtime|features` part files.

## Known code/spec gaps (re-baseline 2026-06-26)

1. **Light theme chưa wire** — `elaroColorScheme` hardcode `Brightness.dark`; light tokens chỉ planned.
2. **`ElaroColors` getter names lệch M3** — `surfaceHigh`→`surfaceContainerHigh`, `surfaceHighest`→`surfaceContainerHighest` (caller dùng tên Elaro, không phải tên M3).
3. **`fullBleedImageCard` luôn color-blend image** (`BlendMode.dstATop`) — không bao giờ true-color.
4. **Known i18n debt do frozen test contract:** targeted labels đã sang Vi, nhưng `Ritual Builder`, `Session start`, `Pack type: Core` vẫn phải giữ EN cho tới khi unfreeze `apps/mobile/test/widget_test.dart`.
5. **`trendSteady`==`safeTeal`==`#6FA7A0`**, `trendCalm`==`primaryContainer`, `trendSettling`==`warmAmber` — alias có chủ ý (triangulation sage/amber/teal).
