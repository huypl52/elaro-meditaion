---
baseline_commit: e7b1d5043ba9c85ea04ddb61b4386a404086e138
---
# Story 6.3: Offline-first core và fallback cho sensor

Status: backlog

## Story

As a người dùng,
I want app vẫn vận hành khi mất mạng hoặc mất sensor,
So that core experience không bị khóa.

## Acceptance Criteria

1. **Given** `_MockDeviceRuntime.networkAvailable == false` (offline),
   **When** mở Library catalog detail (`_SessionCatalogScreen`),
   **Then** `shouldRunOffline = isBasicFlow || !networkAvailable` → `true`, session start với `args.offline = true`, source kèm suffix `-fallback` khi basic flow.

2. **Given** session active với `args.offline == true`,
   **When** render trong `DevSection('Session telemetry')`,
   **Then** hiển thị `'Offline: yes (local runtime)'` (text verbatim, key nằm trong DevSection — dev-gated).

3. **Given** session KHÔNG offline-ready (`!session.offlineReady`) hoặc offline (`!networkAvailable`),
   **When** mở catalog detail,
   **Then** `isBasicFlow = !session.offlineReady` → hiển thị `session-offline-fallback-message` (`'Phiên này mở theo flow cơ bản (chạy local, không phụ thuộc gói offline full).'`) + `session-catalog-retry` (`'Thử lại nhẹ nhàng'`) enabled.

4. **Given** presence block đang hiển thị và `_elapsedSinceSync >= _presenceTtl` (12s, `_presenceTtl = Duration(seconds: 12)`),
   **When** render stale state,
   **Then** `presence-stale-badge` (`'Stale'`) hiển thị, `presence-last-updated` (`'Cập nhật lần cuối: $_lastUpdatedLabel'`) hiển thị, `presence-current-count` → **findsNothing** (ẩn count mới), `CommunityPresenceBand` message `'Hiện diện cộng đồng sẽ cập nhật khi có kết nối.'`, RoomCard `restingCount: 0`.

5. **Given** sensor microphone KHÔNG available (`!_microphonePermissionGranted`) hoặc `_noiseConfidence < 0.6`,
   **When** session compute `noiseContextLabel` / confidence,
   **Then** `confidenceLabel` trả `'độ tin cậy thấp'` (khi `!mic` hoặc `confidence < 0.6`), sub `'Tín hiệu sensor bị giới hạn, chỉ dùng flow cơ bản để giữ core experience.'` hiển thị.

6. **Given** microphone permission bị từ chối giữa phiên,
   **When** `_sessionState.dropEnrichment()` được gọi,
   **Then** `_microphonePermissionGranted = false`, `_noiseConfidence = 0.2`, `_healthPermissionGranted = false`, `_bioFeedback = null` — KHÔNG reset timer/timeline, session tiếp tục chạy, `noiseContextLabel` chuyển sang `'Context thủ công: manual-${checkinName}'` (calm/low/overload), enrichment label `'Enrichment: bỏ qua (thiếu quyền mic)'`.

7. **Given** core flows (home/library/session/growth/journal),
   **When** offline hoặc permission denied,
   **Then** các flow chính vẫn chạy — Home render CTA + suggested card, Library filter/sort hoạt động, session chạy local, KHÔNG crash, KHÔNG block toàn bộ.

## Code anchor

- `apps/mobile/lib/runtime/runtimes.dart`: `_MockDeviceRuntime.networkAvailable` (static, default `true`)
- `apps/mobile/lib/features/library/library.dart`: `_SessionCatalogScreen` (`isBasicFlow`, `shouldRunOffline`, `session-offline-fallback-message`, `session-catalog-retry`)
- `apps/mobile/lib/features/presence/presence.dart`: `_presenceTtl`, `_isStale`, `presence-stale-badge`, `presence-last-updated`
- `apps/mobile/lib/runtime/session.dart`: `_SessionState.dropEnrichment()` (mic=false, confidence=0.2, health=false, bio=null), `noiseContextLabel`, `confidenceLabel`
- `apps/mobile/lib/features/session/session.dart`: `'Offline: yes (local runtime)'`, `'độ tin cậy thấp'`, `'Tín hiệu sensor bị giới hạn…'`, `'Context thủ công: manual-…'`

## Dev Notes

### Dev-gating note
- **Luôn hiện (không gate):** offline badge (Home/Library), presence stale badge, sensor limitation message, manual context label, fallback message, retry button.
- **Dev-gated (ẩn release):** `'Offline: yes (local runtime)'` trong DevSection, `'Mode hiện tại: online/offline mode'` trong catalog detail, noise confidence toggle (`session-noise-confidence-toggle`), bio permission toggle (`session-bio-permission-enable/disable`).

### Edge cases
- `_MockDeviceRuntime.networkAvailable` là static field — test flip trực tiếp để simulate offline. Default `true`.
- `shouldRunOffline = isBasicFlow || !networkAvailable` — offline network ép offline mode kể cả khi pack offline-ready.
- Presence stale swap cần `presence-refresh` để reset (`_elapsedSinceSync = Duration.zero`). Stale KHÔNG auto-recover.
- `dropEnrichment` set `_noiseConfidence = 0.2` (không 0) — vẫn có confidence value, nhưng < 0.6 → label `'độ tin cậy thấp'`.
- `manual-${checkinName}` — `checkinName` từ `_CheckinState.name` (`calm`/`low`/`overload`), KHÔNG dùng nhãn `yên/vừa/ồn` (reconciled).

### Calm/safety boundary
- **Offline-first hard rule:** core experience KHÔNG bị khóa khi offline — session chạy local, Home vẫn có CTA, Library vẫn duyệt được.
- **Sensor fallback không shaming:** label `'độ tin cậy thấp'` rõ ràng, KHÔNG phán xét chất lượng phiên, KHÔNG claim dựa sensor thiếu.
- Presence stale ẩn count mới để tránh misinformation — không hiển thị số liệu cũ có thể sai.

### Known code gaps (ghi chú, KHÔNG đổi code)
- **Presence không empty-state** — khi stale hoặc count = 0, vẫn hiển thị structure (badge + last-updated) nhưng KHÔNG có "không có người hiện diện" message hay "start new block" CTA (xem EXPERIENCE.md Known gaps #5).
- `_MockDeviceRuntime.networkAvailable` là mock static — chưa wire network detection thật.
- `dropEnrichment` không append event vào timeline — không có audit trail khi enrichment bị drop.

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
