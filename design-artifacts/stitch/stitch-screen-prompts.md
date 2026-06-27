# Stitch Screen Prompts

Project: `meditation-community`

## Global Direction

Use this direction for every screen:

- Mobile-first iOS app for meditation and emotional regulation.
- Default posture is calm dark mode with warm, soft contrast.
- Visual tone: safe, quiet, non-clinical, non-performative, non-gamified.
- Keep one primary action per screen. Avoid dashboard density.
- Large typography, generous breathing room, rounded soft cards, subtle depth.
- No streaks, no scores, no achievement language, no social feed, no chat UI.
- Bilingual-ready layout for Vietnamese and English text expansion.
- Use tabs only for `Home`, `Library`, `Growth`, `Settings`.
- `SOS` is not a tab. It is a persistent prominent but calm CTA.

Core colors:

- Background dark moss: `#171D1A`
- Raised surface: `#202723`
- Soft surface: `#28302B`
- Primary text: `#F4F1EA`
- Secondary text: `#C7C1B5`
- Muted text: `#978F82`
- Primary accent: `#9CB59A`
- Warm SOS accent: `#D1AE84`
- Safe accent: `#6FA7A0`
- Border: `#333B36`

Shape and spacing:

- Large soft cards with 28px radius.
- Medium CTA radius 18px.
- Full pill chips and SOS capsule.
- Comfortable side padding around 20px.
- Wide vertical spacing between major sections.

## Screen 1: Home

Create the mobile home screen for `meditation-community`.

Requirements:

- Single-path home with at most 2 strong actions above the fold.
- Primary CTA based on current moment, for example `Bắt đầu nhẹ nhàng` or `Chuẩn bị ngủ`.
- Persistent `SOS` CTA that is very easy to reach but still visually calm.
- Quick emotional or energy check-in chips with 1-tap interaction.
- One suggested session card with duration, context fit, and offline availability.
- One quiet community presence block showing aggregate presence only, no identities.
- One small entry into ritual continuity or recent replay.
- Bottom tab bar: Home, Library, Growth, Settings.
- Avoid dashboard clutter.

Mood:

- Feels like being welcomed into a quiet room at night.
- Make the hierarchy obvious in under 2 seconds.

## Screen 2: SOS Flow

Create the `SOS` emergency calm entry screen and active flow screen.

Requirements:

- This is a 60-second calming flow for moments of overload.
- Show breathing guidance with haptic-first posture and optional minimal audio.
- Keep choices minimal. The user should not need to decide much.
- Warm amber accent is allowed here, but do not make it look like alarm UI.
- Include a way to pause or end early.
- Copy should feel stabilizing, not dramatic.
- Show clear progression through the 60 seconds.

Mood:

- Urgent but emotionally safe.
- Quiet, grounded, and simple.

## Screen 3: Session Player

Create the standard session player screen for a meditation session.

Requirements:

- Supports audio guidance, timer, mindfulness bell, haptic guidance, pause, and end early.
- Large legible time and state labels for low-vision-safe use.
- Show current session title, duration, and context.
- Keep the surface minimal and immersive.
- Include a secondary option to switch to silence-compatible mode.
- Avoid decorative controls or media-player clutter.

Mood:

- Immersive, steady, and low cognitive load.

## Screen 4: Gentle Re-entry

Create the post-session `Gentle Re-entry` screen.

Requirements:

- This appears right after a session ends.
- It should feel like a soft landing, not a success celebration.
- Show one short reassuring line.
- Offer exactly 3 next actions:
  - stop here
  - repeat
  - open a short follow-up
- Make it visually quiet and spacious.
- No confetti, no gamification, no score, no achievement framing.

Mood:

- Soft, warm, relieved.

## Screen 5: Reflection and Growth

Create a combined `Reflection` and `Growth` screen concept.

Requirements:

- Show narrative trend, not a meditation score.
- Reflection should mention signals like session pattern, self check-in, noise context, and optional biofeedback without looking clinical.
- Growth view shows total sessions and total accumulated time without streak pressure.
- Include a quick entry to record a private voice journal.
- Use a reassuring tone like personal continuity, not performance tracking.
- Make offline usefulness clear even if no wearable data exists.

Mood:

- Intimate, reflective, and quietly encouraging.

## Screen 6: Library by Need

Create the `Library` screen organized by need and transition mode.

Requirements:

- Browsing should prioritize needs like sleep, quick reset, focus, break, overload recovery.
- Show categories by need, duration, context, and intensity.
- Include `Transition Modes` as a first-class entry, not a hidden tag.
- Highlight offline-ready content clearly.
- Avoid giant grids or content-marketplace feeling.
- Include one clear quick-start path.

Mood:

- Curated, calm, and easy to scan.

## Screen 7: Quiet Presence

Create the `Quiet Presence` community screen.

Requirements:

- Show aggregate anonymous presence in time blocks or quiet rooms.
- No avatars, no comments, no chat composer, no feed.
- Allow joining a current quiet session.
- After-session nudge should be preset-based only, not free text.
- The screen must communicate companionship without social pressure.

Mood:

- Shared stillness, not social engagement.

## Screen 8: Permission Sheet

Create a pre-permission education sheet for microphone and health access.

Requirements:

- This is shown before the native system permission dialog.
- Explain why the permission is being asked.
- Explain what is used and what is not collected.
- Include a respectful `Not now` option.
- Make privacy feel explicit and trustworthy.
- Use card or sheet styling with large rounded corners.

Mood:

- Transparent, respectful, and calm.

## Suggested Stitch Generation Order

1. Home
2. SOS Flow
3. Session Player
4. Gentle Re-entry
5. Reflection and Growth
6. Library by Need
7. Quiet Presence
8. Permission Sheet
