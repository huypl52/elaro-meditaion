---
baseline_commit: 3b889ca43c984a5349594b669ec93245dc6ce929
---
# Story 1.4: Home routing và điều hướng tab tối giản

Status: review

## Story

As a người dùng,
I want tab của app rõ ràng và ít nhiễu,
So that tôi không bị cuốn vào quá nhiều lựa chọn.

## Acceptance Criteria

1. **Given** người dùng mở app, **When** `_TabScaffold` render, **Then** tab bar là Material `NavigationBar` đúng **4 đích**: `Home`, `Library`, `Growth`, `Settings`, với icon `Icons.home_outlined` / `menu_book_outlined` / `insights_outlined` / `settings_outlined`.

2. **Given** người dùng ở Home, **When** nhìn header, **Then** `cta-sos` là một **capsule yên tĩnh ở `CalmTopAppBar.trailing`** (icon `favorite_rounded`, fill amber 22%, onTap → `/sos`), **And** `cta-sos` **không** nằm trong tab bar và **không** được tính vào số 2 body CTA tối đa.

3. **Given** người dùng chạm 1 trong 4 tab, **When** điều hướng, **Then** app chuyển đúng route tương ứng: `/home` (Home), `/library` (Library), `/growth` (Growth), `/settings` (Settings).

4. **Given** một route không khớp `_buildRoute` (unknown route), **When** app cố điều hướng, **Then** fallback về `_TabScaffold(Home)` mà **không crash**.

5. **Given** người dùng mở app lần đầu, **When** app khởi động, **Then** `initialRoute` = `/home`.

6. **Given** app render, **When** xem kiến trúc tab, **Then** `Rituals`, `Presence`, `Voice journal` **không có tab riêng** — chúng là entry surfaces dưới Home/Growth/re-entry để giữ kiến trúc yên.

## Code anchor

`apps/mobile/lib/main.dart` — `_TabScaffold` (Material `NavigationBar` 4 đích + icons), `_buildRoute` (routing + unknown-route fallback → Home), `ElaroMedApp` (`initialRoute: /home`); Home capsule `cta-sos` tại `apps/mobile/lib/features/home/home.dart` (`CalmTopAppBar.trailing`).

## Dev Notes

- **SOS không phải tab:** `cta-sos` là capsule header luôn hiện diện, 1 chạm vào `/sos`; đây là điểm vào nhanh nhất (UX-DR2) và tách biệt khỏi body CTA ranking (Story 1.1).
- **Fallback không crash:** mọi route không khớp → `_TabScaffold(Home)`; đảm bảo offline-first và deep-link lạ không phá app.
- **Kiến trúc yên:** các surface phụ (Rituals/Presence/Voice journal) chỉ tiếp cận qua Home/Growth/re-entry — không có tab 5+ để giữ tối giản.
- **Reconciled 2026-06-27:** route `/session/before-sleep-8m` và `/session/ritual-*` giờ có handler riêng → `_SessionStartScreen` với before-sleep=480s, continue-ritual=latest ritual duration (fallback 180s).

## Status

- created: 2026-06-24
- create_story: done
- contexted: 2026-06-27T13:36:54+0700
- reconciled: 2026-06-26 (source at apps/mobile/; ACs match shipped behavior)
- dev_status: done
- code_review: PASS

### Change Log

- 2026-06-27: Create-story workflow applied; status moved to ready-for-dev.
- 2026-06-27: Implemented Story 1.4: tab scaffold + tab routing + unknown-route fallback + focused Story 1.4 tests.
- 2026-06-27: Rework completed for review blockers:
  - Switched Home header CTA SOS to `CalmTopAppBar.trailing` via new component `apps/mobile/lib/components/calm_top_app_bar.dart`.
  - Updated SOS capsule styling to amber ~22% fill and `Icons.favorite_rounded` in capsule header.
  - Updated story/sprint state to review.

## Dev Agent Record

- Implemented in:
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/components/calm_top_app_bar.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/lib/features/home/home.dart`
  - `/Users/lee/code/projects/elaro-high/apps/mobile/test/story_1_4_home_routing_test.dart`
- Change summary:
  - Added `_TabScaffold` (`NavigationBar`) với đúng 4 đích: Home/Library/Growth/Settings + icons theo AC.
  - Đảm bảo `cta-sos` vẫn ở header Home (`Key('cta-sos')`) và không nằm trong tab bar.
  - Introduced `CalmTopAppBar` owner component and used it in Home, with `cta-sos` placed on `trailing` slot.
  - SOS capsule uses icon `favorite_rounded` and amber fill around 22%.
  - `initialRoute: /home` + fallback không khớp route về `_TabScaffold(Home)` qua `_buildRoute`.
