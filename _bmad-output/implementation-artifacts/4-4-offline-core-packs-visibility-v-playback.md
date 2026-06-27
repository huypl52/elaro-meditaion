---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 4.4: Offline core packs visibility và playback

Status: backlog

## Story

As a người dùng ở môi trường offline,
I want biết ngay nội dung nào đã sẵn trên máy,
So that tôi vẫn có thể thiền ngay.

## Acceptance Criteria

1. **Given** mỗi session có flag `offlineReady` (`_LibrarySession.offlineReady`),
   **When** `offlineReady == true`,
   **Then** Library row hiển thị `_offlineBadge(session)` với key `library-offline-badge-${session.id}` và label verbatim `'offline-ready'` (color `primaryContainer`, 18% fill + 60% border). Nếu `false`, badge KHÔNG render.

2. **Given** suggested session card trên Home có `offlineReady == true`,
   **When** card render,
   **Then** badge `home-offline-badge` (`'OFFLINE READY'`) hiển thị (color `primaryContainer`, letterSpacing 1.2, fontSize 11). Nếu `false`, badge KHÔNG render.

3. **Given** người dùng mở catalog detail (`_SessionCatalogScreen`) cho session KHÔNG offline-ready (`!session.offlineReady`),
   **When** compute `isBasicFlow = !session.offlineReady`,
   **Then** hiển thị message `session-offline-fallback-message` (`'Phiên này mở theo flow cơ bản (chạy local, không phụ thuộc gói offline full).'`) và nút `session-catalog-retry` (`'Thử lại nhẹ nhàng'`) trở nên enabled.

4. **Given** người dùng tap `session-catalog-retry` (`'Thử lại nhẹ nhàng'`),
   **When** `isBasicFlow == true`,
   **Then** tạo `AppErrorEnvelope(code: 'core_pack_cache_miss', message: 'Core pack cache miss.', retryable: true)`, gọi `_retryPolicy.delayForAttempt(error, attempt, random, elapsed)` (`RetryBackoffPolicy` default: base 250ms, max 2s, stopLoss 3s, maxAttempts 5, jitter 0.25), increment `_retryCount`, hiển thị `session-catalog-retry-note` (`'Đã thử lại core pack $_retryCount lần, vẫn giữ fallback an toàn.'`) và `session-catalog-retry-delay` nếu delay non-null.

5. **Given** retry vượt stop-loss (`delayForAttempt` trả `null`),
   **When** retry fired,
   **Then** snackbar hiển thị `'Stop-loss reached, giữ UI core phản hồi.'` — KHÔNG crash, KHÔNG block UI, KHÔNG infinite retry.

6. **Given** core packs (`offlineReady == true`, vd `n1`, `n4`) hoặc offline mode (`!_MockDeviceRuntime.networkAvailable`),
   **When** người dùng tap `session-catalog-start`,
   **Then** navigate `/session/start` với `args.offline = shouldRunOffline` (`isBasicFlow || !networkAvailable`), source kèm suffix `-fallback` khi basic flow. Core packs luôn chạy local.

## Code anchor

- `apps/mobile/lib/features/library/library.dart`:
  - `_LibrarySession.offlineReady`, `offlineStateLabel` (`'offline-ready'` / `'online-only'`)
  - `_offlineBadge(session)` → `Key('library-offline-badge-${session.id}')`, text `'offline-ready'`
  - `_SessionCatalogScreen` / `_SessionCatalogScreenState`: `isBasicFlow`, `shouldRunOffline`, `session-offline-fallback-message`, `session-catalog-retry` (`'Thử lại nhẹ nhàng'`), `session-catalog-retry-note`, `session-catalog-retry-delay`
- `apps/mobile/lib/features/home/home.dart`: `home-offline-badge` (`'OFFLINE READY'`)
- `apps/mobile/lib/domain/errors.dart`: `RetryBackoffPolicy`, `AppErrorEnvelope`
- `apps/mobile/lib/runtime/runtimes.dart`: `_MockDeviceRuntime.networkAvailable`

## Dev Notes

### Dev-gating note
Offline badge, fallback message, retry note/delay là **user-facing, luôn hiện** — không DevSection. `session-catalog-retry` và stop-loss behavior là core UX, không gate.

### Edge cases
- `isBasicFlow = !session.offlineReady` — phiên KHÔNG offline-ready luôn mở basic flow (chạy local, không phụ thuộc gói offline full).
- `shouldRunOffline = isBasicFlow || !_MockDeviceRuntime.networkAvailable` — offline network ép basic flow kể cả khi pack offline-ready.
- `_MockDeviceRuntime.networkAvailable` là static field (default `true`) — test có thể flip để simulate offline.
- Retry chỉ enabled khi `isBasicFlow == true`; khi `false`, `session-catalog-retry.onPressed = null` (disabled).

### Calm/safety boundary
- Retry label `'Thử lại nhẹ nhàng'` — posture dịu, không áp lực.
- Stop-loss bảo vệ UI core: khi retry vượt ngưỡng, snackbar thông báo rõ, KHÔNG loop vô tận, KHÔNG block người dùng.
- Core packs (`offlineReady`) luôn sẵn local → người dùng luôn có path vào session kể cả offline.

### Known code gaps (ghi chú, KHÔNG đổi code)
- Core packs `n1` và `n4` có `offlineReady: true` nhưng `n4` (`packType: core`) thực ra `offlineReady: false` — phân bổ không hoàn toàn "core pack = offline". Check `_allSessions` để xác nhận: `n1` (core, offline), `n4` (core, online-only). Đây là data inconsistency nhỏ trong catalog seed.
- `_MockDeviceRuntime.networkAvailable` là mock static — chưa wire network detection thật.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
