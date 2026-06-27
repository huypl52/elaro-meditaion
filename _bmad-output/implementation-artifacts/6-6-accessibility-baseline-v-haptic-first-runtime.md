---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 6.6: Accessibility baseline và haptic-first runtime

Status: backlog

## Story

As a người dùng có nhạy cảm ánh nhìn/âm thanh,
I want sản phẩm vẫn có thể dẫn dắt qua haptic/text,
So that tôi dùng được trong tình huống không muốn nhìn hoặc nghe nhiều.

## Acceptance Criteria

1. **Given** `_AccessibilityRuntime.hapticsEnabled` (static, default `true` = haptic-lite ON),
   **When** Settings render `settings-haptics-toggle` (`PreferenceRow`, title `'Phản hồi rung'`, subtitle `'Text fallback luôn sẵn có'`),
   **Then** toggle value = `_AccessibilityRuntime.hapticsEnabled`, onChanged set `_AccessibilityRuntime.hapticsEnabled = value` (global static).

2. **Given** Settings render `settings-accessibility-summary`,
   **When** build,
   **Then** hiển thị `'Accessibility: ${_hapticStateLabel(context)} • Reduce motion: ${_reduceMotionOf(context) ? 'on' : 'off'}'` — `_hapticStateLabel` trả `'Haptic: bật'` (enabled) hoặc `'Haptic: tắt'` (disabled); `_reduceMotionOf` đọc `MediaQuery.disableAnimations`.

3. **Given** Settings render runtime cue lines,
   **When** build `SectionCard(eyebrow: 'Runtime cues')`,
   **Then** 3 dòng: `settings-sos-cue` (`'SOS: ${_cueModeLabel(...)}'`, hapticRequired=true), `settings-bell-cue` (`'Timer bell: ${_cueModeLabel(...)}'`, hapticRequired=true), `settings-breathing-cue` (`'Breathing cue: ${_cueModeLabel(...)}'`, hapticRequired=false).

4. **Given** `_cueModeLabel(context, hapticRequired)` compute,
   **When** haptics disabled (`!_AccessibilityRuntime.hapticsEnabled`),
   **Then** trả `'Text only fallback'`. Khi reduce motion ON + hapticRequired=true → `'Text only fallback'`. Else hapticRequired=true → `'Haptic + text'`; hapticRequired=false → `'Text guidance'`.

5. **Given** `_hapticsEnabledFor(context)` compute,
   **When** decide fire haptic,
   **Then** trả `_AccessibilityRuntime.hapticsEnabled && !_reduceMotionOf(context)` — haptic chỉ fire khi enabled AND reduce motion OFF.

6. **Given** cần fire haptic cue (SOS start, bell, breathing, complete, pause, resume),
   **When** `_fireHapticCue(context, type)` gọi với `type` thuộc `enum HapticFeedbackType {light, medium, selection}`,
   **Then** nếu `!_hapticsEnabledFor(context)` → return (no-op); else switch: `light` → `HapticFeedback.lightImpact()`, `medium` → `HapticFeedback.mediumImpact()`, `selection` → `HapticFeedback.selectionClick()`.

7. **Given** Settings render `DistressBoundary` (key `settings-distress-boundary`),
   **When** build,
   **Then** boundary luôn hiện với message mặc định `'Đây là công cụ tự chăm sóc nhẹ nhàng, không thay thế hỗ trợ chuyên môn. Nếu bạn đang gặp khủng hoảng, hãy liên hệ đường hỗ trợ tại chỗ.'`, **And** action `'Tìm hỗ trợ'` mặc định mở `_SupportResourcesSheet`.

8. **Given** accessibility-summary hiển thị trên Home/Session/Growth/Settings,
   **When** render,
   **Then** key verbatim: `home-accessibility-summary`, `growth-accessibility-summary`, `session-accessibility-summary`, `session-start-accessibility-summary`, `session-reflection-accessibility-summary`, `session-reentry-accessibility-summary` — accessibility state visible across core surfaces.

9. **Given** Settings MVP scope,
   **When** render `/settings`,
   **Then** chỉ có: headline `'Nền tảng tiếp cận'`, haptics toggle `'Phản hồi rung'`, runtime cue lines, paragraph `'Audio is optional. Text guidance remains available if haptics are off or motion is reduced.'`, DistressBoundary — KHÔNG có language selector, theme toggle, notifications, privacy section, permissions/health-links, calm-exit control (planned, chưa wire).

## Code anchor

- `apps/mobile/lib/runtime/accessibility.dart`:
  - `_AccessibilityRuntime.hapticsEnabled` (static, default `true`), `resetForTests()`
  - `_reduceMotionOf(context)` → `MediaQuery.disableAnimations`
  - `_hapticsEnabledFor(context)` → `hapticsEnabled && !reduceMotion`
  - `_hapticStateLabel(context)` → `'Haptic: bật'` / `'Haptic: tắt'`
  - `_cueModeLabel(context, hapticRequired)` → `'Text only fallback'` / `'Haptic + text'` / `'Text guidance'`
  - `_fireHapticCue(context, type)`, `enum HapticFeedbackType {light, medium, selection}`
- `apps/mobile/lib/features/settings/settings.dart`:
  - `_SettingsScreen` / `_SettingsScreenState`
  - `settings-haptics-toggle` (`'Phản hồi rung'`, `'Text fallback luôn sẵn có'`), `settings-accessibility-summary`, `settings-sos-cue`, `settings-bell-cue`, `settings-breathing-cue`, `settings-distress-boundary`
- `apps/mobile/lib/components/trust/trust.dart`: `DistressBoundary`

## Dev Notes

### Dev-gating note
- **Luôn hiện (không gate):** haptics toggle, accessibility-summary trên Home/Growth/Session, runtime cue lines, DistressBoundary. Đây là accessibility floor, KHÔNG bao giờ gate.
- Settings headline `'Nền tảng tiếp cận'` và toggle `'Phản hồi rung'` là user-facing. Một số cue/runtime summary vẫn mixed-language (`'Text only fallback'`, `'Haptic + text'`, `'Text guidance'`, `'Accessibility: ...'`) — theo code hiện tại.

### Edge cases
- `_AccessibilityRuntime.hapticsEnabled` là **global static** — toggle ở Settings affect toàn app (Home/Session/SOS haptic cue).
- `resetMindfulNudgeRuntimeForTests()` cũng reset `_AccessibilityRuntime.hapticsEnabled = true` (default) — test isolation.
- `_reduceMotionOf` dùng `MediaQuery.maybeOf(context)?.disableAnimations ?? false` — null-safe, default false nếu không có MediaQuery.
- `_cueModeLabel` logic: disabled → `'Text only fallback'` (ưu tiên cao nhất); reduce motion + hapticRequired → `'Text only fallback'`; else phân nhánh theo hapticRequired.
- `_fireHapticCue` dùng `unawaited(...)` — fire-and-forget, không block UI.

### Calm/safety boundary
- **Haptic-first default:** `_AccessibilityRuntime.hapticsEnabled = true` mặc định = haptic-lite ON — người dùng có thể tắt, nhưng default ưu tiên dẫn đường không cần nhìn.
- **Text fallback luôn sẵn:** subtitle `'Text fallback luôn sẵn có'` + paragraph `'Audio is optional. Text guidance remains available…'` — khẳng định KHÔNG phụ thuộc animation/audio bắt buộc.
- **Reduce Motion aware:** `_reduceMotionOf` tôn trọng iOS Reduce Motion setting — khi ON, haptic-required cue chuyển text-only, animation không cần thiết tắt.
- `DistressBoundary` luôn hiện trên Settings — người dùng biết công cụ không thay thế hỗ trợ chuyên môn.

### Known code gaps (ghi chú, KHÔNG đổi code)
- **Settings scope hẹp hơn spec cũ (UX-DR18):** chỉ accessibility baseline (haptic + cues + DistressBoundary); KHÔNG có language selector, theme toggle, notifications, privacy section, permissions/health-links, calm-exit control — các mục này là planned, chưa wire trong MVP.
- Một số cue/runtime summary vẫn mixed-language (`'Text only fallback'`, `'Haptic + text'`, `'Text guidance'`, `'Accessibility: ...'`, `'Haptic: bật/tắt'`) — chưa localize tiếng Việt hoàn toàn.
- Light mode chưa wire — dark-only (`Brightness.dark` hardcode); accessibility floor hiện tại chỉ test trên dark mode.
- `_AccessibilityRuntime` in-memory — `hapticsEnabled` KHÔNG persist qua restart (reset về default `true`).

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
