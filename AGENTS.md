# AGENTS.md — elaro-high

BMAD/planning repo for the meditation app. **Current canonical project root: `/Users/lee/code/projects/elaro-high`.**

As of the wrong-repo audit on 2026-06-27, this repo does **not** contain `apps/mobile/`.
Any source/delivery work must target `{project-root}/apps/mobile` only after that source tree exists in
`elaro-high`; do not use `/Users/lee/code/projects/elaro-med` as a delivery root.

The Flutter app shape below describes the intended in-repo source layout once source is restored under
`elaro-high/apps/mobile`.

## Binding rules — read first

Canonical source: [`_bmad-output/planning-artifacts/ENGINEERING-RULES.md`](_bmad-output/planning-artifacts/ENGINEERING-RULES.md). These are non-negotiable guardrails (each has full detail + how-to-check in that file):

1. **Frozen test contract** — never edit `apps/mobile/test/widget_test.dart`. Preserve every `Key('...')` string and frozen text on the equivalent widget/pump-path. Three user-facing strings (`Ritual Builder`, `Session start`, `Pack type: Core`) are locked EN by this contract — localizing them requires unfreezing the test first.
2. **Dev-gating** — all debug/QA/telemetry/test controls behind `DevSection`/`DevGate`. Release build: `flutter build ... --dart-define=ELARO_RELEASE=true`. No debug leaks to production.
3. **No infinite animations** — no `AnimationController.repeat()`. Tests `pumpAndSettle`; reduce-motion must degrade to static/haptic/text.
4. **Scrollability** — every `Scaffold`/`CalmBottomSheet` body that can overflow MUST be scrollable (`SingleChildScrollView`/`ListView`/`CustomScrollView`); sticky CTA stays outside the scroll region. Verify at large text scale.
5. **Design-system usage** — use `Calm*` components + `SectionCard`/`PrimaryCTA`/`PreferenceRow`; colors via `ElaroColors.of(context)` tokens; no hardcoded hex; no stock Material where a calm component exists.
6. **i18n** — new user-facing strings in Vietnamese. Dev-only/QA labels may be EN behind `DevSection`.
7. **Tone & product invariants** — night-calm; NO gamification/streak/score/leaderboard; presence is aggregate-only (no chat/profile/social graph); offline-first; timeline is system-of-record; permission preflight before system prompt; haptic-first with text fallback; `DistressBoundary` on SOS/Reflection/Settings/Permissions (action opens the support sheet).
8. **Structure (Phase-7)** — once app source exists in this repo, `apps/mobile/lib/main.dart` is **barrel-only** (app shell + route table + tab scaffold). Real symbols live in `lib/domain/*`, `lib/runtime/*`, `lib/features/*` via `part`/`part of`. Anchor docs/code to the owning file, not `main.dart`.

## Where things live

- **Behavior target path**: `{project-root}/apps/mobile/lib/features/*`, `{project-root}/apps/mobile/lib/runtime/*`, `{project-root}/apps/mobile/lib/domain/*` (**missing until source is restored in `elaro-high`**)
- **Design system target path** (tokens, typography, shapes, components): `{project-root}/apps/mobile/lib/theme/*`, `{project-root}/apps/mobile/lib/components/*` (**missing until source is restored in `elaro-high`**)
- **UX logic flows**: [`_bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/EXPERIENCE.md`](_bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/EXPERIENCE.md)
- **Design spec** (ColorScheme, Newsreader/Inter, calm-player pattern, motion rule): [`.../DESIGN.md`](_bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/DESIGN.md)
- **Dev handoff** (UX surface → route → component): [`docs/ui-dev-handoff.md`](docs/ui-dev-handoff.md)
- **BMad specs/stories/PRD**: `_bmad-output/`
- **Frozen behavioral contract target path**: `{project-root}/apps/mobile/test/widget_test.dart` (~120 `Key` strings + frozen texts define the real flows once source exists — do not edit without unfreeze task)

## Before shipping a UI/runtime change

Run the checklist in [ENGINEERING-RULES.md](_bmad-output/planning-artifacts/ENGINEERING-RULES.md) (scrollable? no debug leak? no infinite anim? contract intact? calm components + tokens? Vi strings? invariants held? anchors correct?). Then, only after `elaro-high/apps/mobile` exists, run mobile checks from `{project-root}/apps/mobile`.
