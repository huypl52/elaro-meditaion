---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 6.1: Session timeline immutable event model

Status: backlog

## Story

As a developer,
I want ghi lại các events phiên theo immutable timeline,
So that mọi module đọc từ một nguồn chính xác.

## Acceptance Criteria

1. **Given** mỗi `SessionTimelineEvent` có các field `eventId`, `aggregateId`, `aggregateVersion`, `occurredAtUtc`, `source`, `idempotencyKey`, `schemaVersion`, `type`, `details`,
   **When** `SessionTimeline.append(event)` được gọi,
   **Then** `_validate(event)` kiểm tra: `eventId`/`aggregateId`/`source`/`idempotencyKey` non-empty, `aggregateVersion > 0`, `occurredAtUtc.isUtc == true`, `schemaVersion > 0` — nếu bất kỳ field nào invalid, throw `SessionTimelineValidationException(problems)` với list field vi phạm (vd `['event_id', 'occurred_at_utc']`).

2. **Given** event invalid (vd thiếu `eventId` hoặc `aggregateVersion <= 0`),
   **When** `_validate` phát hiện,
   **Then** throw `SessionTimelineValidationException` **trước khi append** — event KHÔNG được ghi vào `_events`, timeline giữ nguyên trạng thái. `SessionTimelineValidationException.toEnvelope()` trả `AppErrorEnvelope(code: 'session_timeline_validation_failed', retryable: false, details: {'problems': [...]})`.

3. **Given** 2 event có cùng `occurredAtUtc`,
   **When** `append` sắp xếp (`_events.sort(SessionTimelineEvent.compareByTimeline)`),
   **Then** sort theo `compareByTimeline`: `(occurredAtUtc asc)` → `(sourcePriority asc)` → `(timelineOrder asc)` — đảm bảo causality stable. `sourcePriority` lấy từ `SessionTimeline.sourcePriorityFor(source)`.

4. **Given** `sourcePriorityFor(source)` nhận source string,
   **When** compute priority,
   **Then** priority theo substring match (lowercase): chứa `'user'`/`'ui'`/`'manual'` → 0; `'checkin'`/`'check-in'` → 5; `'session'`/`'device'`/`'sensor'` → 10; `'journal'`/`'ritual'` → 12; `'system'`/`'sync'`/`'replay'`/`'automation'` → 20; else → 50.

5. **Given** 2 event có cùng `idempotencyKey`,
   **When** `append` kiểm tra `_idempotencyIndex[event.idempotencyKey]`,
   **Then** event đã tồn tại → return event cũ (idempotent, **không double-count**), KHÔNG append duplicate. Event mới → gán `timelineOrder` increment, thêm vào index + list, re-sort.

6. **Given** `SessionTimelineEventType` enum gồm `start`, `pause`, `complete`, `abort`, `sessionInterrupted`, `sos`, `sosInterrupt`, `sosTimeoutExit`, `reEntry`, `checkIn`, `journal`, `ritual`,
   **When** `_sessionTimelineEventTypeName(type)` serialize,
   **Then** trả tên verbatim: `'start'`, `'pause'`, `'complete'`, `'abort'`, `'session_interrupted'`, `'sos'`, `'sos_interrupt'`, `'sos_timeout_exit'`, `'re_entry'`, `'check_in'`, `'journal'`, `'ritual'`.

7. **Given** cần truy vấn summary/read model cho một `aggregateId`,
   **When** gọi `summaryFor(aggregateId)`,
   **Then** trả `SessionTimelineSummary` **derive** từ `eventsFor(aggregateId)` ( KHÔNG mutate trực tiếp) — compute `aggregateVersion`, `eventCount`, `isRunning`, `isPaused`, `isCompleted`, `isAborted`, `durationSeconds`, `startedAtUtc`, `lastOccurredAtUtc`, `lastEventType`. Summary KHÔNG có setter, KHÔNG mutate timeline.

8. **Given** `SessionTimelineEvent` là immutable,
   **When** construct,
   **Then** `details` được wrap `Map.unmodifiable(details)`, field `timelineOrder = 0` (chỉ set khi append qua `_withTimelineOrder`). `_withTimelineOrder` trả instance mới (`SessionTimelineEvent._`) — KHÔNG mutate event gốc.

## Code anchor

- `apps/mobile/lib/domain/timeline.dart`:
  - `SessionTimeline` (append, `_validate`, `_idempotencyIndex`, `_events`, `summaryFor`, `eventsFor`, `lastEvent`, `lastEventFor`, `sourcePriorityFor`, `clear`)
  - `SessionTimelineEvent` (immutable, `compareByTimeline`, `sourcePriority`, `_withTimelineOrder`)
  - `SessionTimelineSummary` (immutable, derive-only)
  - `SessionTimelineValidationException` (→ `toEnvelope`)
  - `SessionTimelineEventType` enum + `_sessionTimelineEventTypeName`
- `apps/mobile/lib/domain/errors.dart`: `AppErrorEnvelope` (cho `toEnvelope`)

## Dev Notes

### Dev-gating note
Timeline là **domain layer, không UI** — không DevSection, không gate. Toàn bộ logic là pure Dart, testable.

### Edge cases
- `_validate` check `occurredAtUtc.isUtc` — event với local DateTime sẽ bị reject (phải `.toUtc()` trước khi construct).
- `idempotencyKey` dedupe: cùng key → return existing, KHÔNG throw — caller không biết event đã tồn tại trừ khi check reference equality.
- Sort chạy sau mỗi append (`_events.sort(...)`) — O(n log n) mỗi append, acceptable cho MVP volume.
- `summaryFor` re-compute mỗi lần gọi (không cache) — iterate toàn bộ events của aggregate.
- `lastSessionId = _timeline.lastEvent?.aggregateId ?? 'none'` — read model derive từ timeline (xem `_SessionRuntime`).

### Calm/safety boundary
- Timeline là system-of-record — mọi summary/reflection/progress đọc từ đây, KHÔNG có mutation direct ngoài append.
- Validation reject event invalid trước khi ghi — bảo vệ integrity dữ liệu phiên.
- Idempotency chống double-count — session không bị tính 2 lần khi retry/sync.

### Known code gaps (ghi chú, KHÔNG đổi code)
- `clear()` xóa toàn bộ timeline (dùng cho test) — KHÔNG có selective delete (không xóa theo aggregateId).
- `summaryFor` không cache — mỗi query re-iterate. Hiệu suất phụ thuộc số event/aggregate.
- `sourcePriorityFor` dùng substring match — source `'user-session'` match cả `'user'` (priority 0) và `'session'` (priority 10), nhưng return priority đầu tiên match (0). Cần chú ý naming convention.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
