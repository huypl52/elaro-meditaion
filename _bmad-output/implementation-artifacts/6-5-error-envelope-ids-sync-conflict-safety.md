---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 6.5: Error envelope, IDs, sync conflict safety

Status: backlog

## Story

As a developer,
I want dữ liệu dùng chuẩn format và xử lý xung đột rõ,
So that vận hành backend ổn định.

## Acceptance Criteria

1. **Given** service/adapter trả về lỗi,
   **When** wrap qua `AppErrorEnvelope(code, message, retryable, details)`,
   **Then** envelope có 4 field: `code` (String), `message` (String), `retryable` (bool), `details` (Map, default empty). `toJson()` serialize đủ 4 field (`'code'`, `'message'`, `'retryable'`, `'details'`).

2. **Given** API trả raw response (Map hoặc Object),
   **When** `AppErrorEnvelope.fromApi(raw, fallbackCode, fallbackMessage)` parse,
   **Then** nếu raw là `AppErrorEnvelope` → return as-is; nếu Map → extract `code`/`message`/`retryable`/`details` (fallback nếu empty/missing); else → fallback envelope với `details: {'raw': raw}`. `retryable` default `false` khi không phải bool.

3. **Given** cần generate ID cho event/entity,
   **When** `AppUuidV7.generate(atUtc, random)` chạy,
   **Then** trả UUID v7: 48-bit timestamp (ms) ở byte 0-5, version nibble `0x7` ở byte 6 (`bytes[6] = 0x70 | ...` → hex digit đầu của section thứ 3 startsWith `'7'`), variant `0x8` ở byte 6, random phần còn lại. Format `'xxxxxxxx-xxxx-7xxx-xxxx-xxxxxxxxxxxx'`.

4. **Given** cần format timestamp,
   **When** `formatUtcIso8601(value)` chạy,
   **Then** trả `value.toUtc().toIso8601String()` — UTC ISO-8601 kết thúc `'Z'` (vd `'2026-06-26T12:00:00.000Z'`).

5. **Given** API báo lỗi retriable (`retryable == true`),
   **When** `RetryBackoffPolicy.delayForAttempt(error, attempt, random, elapsed)` compute delay,
   **Then** exponential backoff: `exponentialMillis = baseDelay.inMilliseconds << attempt` (base 250ms), cap `maxDelay` (2s), jitter `±jitterWindow` (factor 0.25). Nếu `!retryable` → `null`. Nếu `attempt < 0 || attempt >= maxAttempts` (5) → `null`. Nếu `elapsed + candidate > stopLoss` (3s) → `null` (stop-loss).

6. **Given** sync conflict giữa local và remote events cho cùng `aggregateId`,
   **When** `SyncConflictReconciler.reconcile(aggregateId, localEvents, remoteEvents, trace)` chạy,
   **Then** append tất cả local events trước (`timeline.append(event)` cho mỗi), rồi append tất cả remote events, cuối cùng `timeline.summaryFor(aggregateId)` — trả `SyncConflictReconcileResult(appendedEvents, summary)`. Append đi qua idempotency index → **không double-count**, order-stable (sort sau mỗi append), **không mất dữ liệu**.

7. **Given** `SessionTimelineValidationException` throw khi event invalid,
   **When** `toEnvelope(code)` gọi,
   **Then** trả `AppErrorEnvelope(code: 'session_timeline_validation_failed'`, `message: 'Session timeline validation failed.'`, `retryable: false`, `details: {'problems': List.unmodifiable(problems)})`.

## Code anchor

- `apps/mobile/lib/domain/errors.dart`:
  - `AppErrorEnvelope` (4 field, `toJson`, `fromApi`)
  - `RetryBackoffPolicy` (base 250ms, max 2s, stopLoss 3s, maxAttempts 5, jitter 0.25, `delayForAttempt`)
  - `SyncConflictReconciler` (`reconcile` → append-then-summary), `SyncConflictReconcileResult`
- `apps/mobile/lib/domain/logging.dart`:
  - `AppUuidV7.generate(atUtc, random)` (UUIDv7, `_formatUuid`)
  - `formatUtcIso8601(value)` (UTC ISO-8601 `'…Z'`)
- `apps/mobile/lib/domain/timeline.dart`: `SessionTimelineValidationException.toEnvelope`

## Dev Notes

### Dev-gating note
Domain layer (errors, logging, timeline) là **pure Dart, không UI** — không DevSection, không gate. Toàn bộ logic testable, không phụ thuộc release flag.

### Edge cases
- `RetryBackoffPolicy.delayForAttempt`: jitter `rng.nextInt(jitterWindow * 2 + 1) - jitterWindow` — có thể âm, nhưng `candidateMillis < 0 ? 0 : candidateMillis` clamp về 0.
- `AppUuidV7.generate` với `atUtc` null → dùng `DateTime.now().toUtc()`; `random` null → `Random()` mới mỗi lần (non-deterministic).
- `SyncConflictReconciler.reconcile` trace list optional — nếu truyền vào, ghi `'append:${eventId}'` cho mỗi event + `'summary:$aggregateId'`.
- `fromApi` với Map thiếu `code`/`message` → fallback; `retryable` non-bool → `false`; `details` non-Map → `{'raw': raw}`.
- UUID v7: section thứ 3 (sau dấu `-` thứ 2) bắt đầu bằng `'7'` — verify qua `parts[2].startsWith('7')` khi split bởi `'-'`.

### Calm/safety boundary
- **Error envelope nhất quán:** mọi lỗi có `code`/`message`/`retryable` rõ — UI hiển thị message calm, không leak stack trace.
- **UUIDv7 + UTC ISO-8601:** ID và timestamp sortable, unique, timezone-safe — tránh ambiguity khi sync multi-device.
- **Sync conflict = append-then-reconcile:** KHÔNG overwrite, KHÔNG mất dữ liệu — append tất cả events (idempotent), rồi derive summary. An toàn cho dữ liệu phiên đã hoàn tất.
- **Stop-loss retry:** khi retry vượt 3s, trả `null` → UI core vẫn responsive, KHÔNG block người dùng chờ đợi.

### Known code gaps (ghi chú, KHÔNG đổi code)
- `RetryBackoffPolicy` default const — caller có thể override, nhưng library catalog (`session-catalog-retry`) dùng default. Không có policy per-error-type.
- `SyncConflictReconciler` không detect "true conflict" (cùng aggregateVersion từ 2 source) — chỉ append all, rely on idempotency + sort. Nếu 2 event cùng `idempotencyKey` → dedupe (return existing), nhưng nếu khác key mà "semantically conflict" → cả hai ghi, summary resolve theo type.
- `AppErrorEnvelope` không có `timestamp`/`correlationId` field — chỉ 4 field. Nếu cần audit trail, phải thêm ở layer trên.
- `formatUtcIso8601` không validate input — local DateTime được `.toUtc()` convert, nhưng nếu đã UTC thì giữ nguyên.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
