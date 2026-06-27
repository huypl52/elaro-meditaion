# Quick Start

> Source-root note: canonical project root is `/Users/lee/code/projects/elaro-high`.
> As of the 2026-06-27 wrong-repo audit, this repo has no `apps/mobile/` tree.
> The developer commands below are blocked until app source is restored under `elaro-high/apps/mobile`.

## For users

1. Open the app
2. Start from `Home`
3. Tap the main suggestion or `SOS` if you need a quick reset
4. Use `Library` to choose a session by need or duration
5. After a session, use the re-entry or reflection actions

## For developers

1. Restore or add the app source under `/Users/lee/code/projects/elaro-high/apps/mobile`.
2. `cd /Users/lee/code/projects/elaro-high/apps/mobile`
3. `flutter pub get`
4. `flutter run`
5. `flutter analyze`
6. `flutter test`

## Core routes

- `/home`
- `/library`
- `/growth`
- `/settings`
- `/sos`
- `/sos/active`
- `/session/:sessionId`
- `/session/:sessionId/re-entry`
- `/session/:sessionId/reflection`
- `/presence`
- `/permissions/:type/preflight`
