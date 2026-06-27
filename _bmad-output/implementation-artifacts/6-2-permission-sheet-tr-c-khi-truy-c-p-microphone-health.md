---
baseline_commit: 7c2f802a5df9ca44cf74ada1b077dcd3f13dff0b
---
# Story 6.2: Permission sheet trước khi truy cập microphone/health

Status: backlog

## Story

As a người dùng,
I want được giải thích trước khi cấp quyền mic/health,
So that tôi tự chủ và yên tâm về dữ liệu.

## Acceptance Criteria

1. **Given** route `/permissions/{microphone|health}/preflight`,
   **When** `_buildRoute` parse qua `_permissionTypeFromRoute(name)`,
   **Then** route với `parts[2] == 'health'` → `permissionType = 'health'`; `parts[2] == 'microphone'` → `'microphone'`; **unknown/garbage** → fallback `'microphone'` (coerce).

2. **Given** `_PermissionPreflightScreen` render với `permissionType`,
   **When** build,
   **Then** title `permission-preflight-title`: `'Preflight quyền microphone'` (mic) hoặc `'Preflight quyền sức khỏe'` (health).

3. **Given** sheet render `PermissionCard` (key `permission-purpose`),
   **When** build,
   **Then** mic: icon `mic_rounded`, title `'Quyền microphone'`, body `'Mục đích: đo bối cảnh âm thanh môi trường ở mức tổng hợp để gợi ý flow phù hợp, không ghi raw audio trước consent.'`, reassurance `'Raw audio không bao giờ rời thiết bị.'`. Health: icon `monitor_heart_rounded`, title `'Quyền sức khỏe'`, body `'Mục đích: đọc dữ liệu sức khỏe đã được cho phép để bổ sung phản chiếu sau phiên, không chặn core flow.'`, reassurance `'Chỉ chỉ số tổng hợp, không lưu hồ sơ y tế.'`.

4. **Given** sheet render `DataCommitmentBox` với `permission-data-used` / `permission-data-not-used`,
   **When** build,
   **Then** mic `_unusedData` chứa verbatim `'raw audio'`, `'transcript nền'`, `'danh bạ'`, `'nhận diện giọng nói'`, `'file ghi âm'` dưới label `'Những gì chúng tôi không thu thập'`. `_usedData` mic: `'tín hiệu mức ồn tổng hợp, độ tin cậy context, và metadata phiên tối thiểu.'` dưới label `'Những gì chúng tôi dùng'`.

5. **Given** người dùng tap `permission-defer-btn` (`'Để sau'`),
   **When** onPressed fired,
   **Then** `Navigator.of(context).pop()` — quay lại, KHÔNG gọi system prompt, KHÔNG increment prompt count.

6. **Given** người dùng tap `permission-system-prompt-btn` (`'Tiếp tục tới prompt hệ thống'`),
   **When** onPressed fired,
   **Then** `_PermissionPromptRuntime.request(permissionType)` (increment count per-type) + snackbar `'Đã mở prompt hệ thống cho $permissionType'`.

7. **Given** sheet render `DistressBoundary` (key `permission-distress-boundary`),
   **When** build,
   **Then** boundary luôn hiện với message mặc định `'Đây là công cụ tự chăm sóc nhẹ nhàng, không thay thế hỗ trợ chuyên môn. Nếu bạn đang gặp khủng hoảng, hãy liên hệ đường hỗ trợ tại chỗ.'`, **And** action `'Tìm hỗ trợ'` mặc định mở `_SupportResourcesSheet`.

8. **Given** `_PermissionPromptRuntime` track prompt count per-type (in-memory map),
   **When** render `DevSection('Permission prompt counter')`,
   **Then** `permission-prompt-count` hiển thị `'Prompt count: $promptCount'` — **dev-gated**, ẩn sạch release (`DevGate.enabled == false`).

9. **Given** log pipeline serialize event/audit với sensitive fields,
   **When** `redactSensitiveLogData(details)` chạy,
   **Then** field match exact whitelist (`microphone_raw_audio`, `voice_transcript`, `user_email`, `device_serial`, `location_latitude`, `location_longitude`, `health_heart_rate`, `health_hrv`, `health_movement`, `session_token`, `voice_sample_uri`, `audio_sample`) → value `'[REDACTED]'`. Match substring (`'transcript'`, `'audio'`, `'serial'`, `'email'`, `'phone'`, `'heart_rate'`, `'hrv'`, `'movement'`, `'location'`, `'token'`, `'identifier'`, `'sample'`) cũng redact. Test verify ≥5 field masked.

## Code anchor

- `apps/mobile/lib/features/permissions/permissions.dart`: `_PermissionPreflightScreen` / `_PermissionPreflightScreenState` (`_title`, `_purpose`, `_usedData`, `_unusedData`)
- `apps/mobile/lib/main.dart`: `_permissionTypeFromRoute(route)` (coerce unknown → `'microphone'`)
- `apps/mobile/lib/components/trust/trust.dart`: `PermissionCard`, `DataCommitmentBox` (`'Những gì chúng tôi dùng'` / `'Những gì chúng tôi không thu thập'`), `DistressBoundary` + `_SupportResourcesSheet`
- `apps/mobile/lib/domain/logging.dart`: `redactSensitiveLogData`, `_shouldRedactLogKey` (exact + substring whitelist)
- `apps/mobile/lib/runtime/runtimes.dart`: `_PermissionPromptRuntime` (`request`, `requestCount`, `reset`)

## Dev Notes

### Dev-gating note
- **Luôn hiện (không gate):** title, PermissionCard, DataCommitmentBox, defer/system-prompt buttons, DistressBoundary.
- **Dev-gated (ẩn release):** `permission-prompt-count` trong `DevSection('Permission prompt counter')` — chỉ hiện debug/test, ẩn sạch release (`--dart-define=ELARO_RELEASE=true`). Missed dart-define → fail-safe dev ON.

### Edge cases
- `_permissionTypeFromRoute` parse `route.split('/')` — route phải có ≥4 parts (`/permissions/{type}/preflight` = 4 parts) và `parts[1] == 'permissions'`. Route sai format → fallback `'microphone'`.
- `_PermissionPromptRuntime._requests` là in-memory Map — count reset khi restart app, không persist.
- `redactSensitiveLogData` recursive: value là Map → redact nested; value là List → redact từng element.
- `_shouldRedactLogKey` check exact match trước (set lookup), rồi substring match — `'microphone_raw_audio'` match exact, `'audio_sample'` match exact, `'audio_clip'` match substring `'audio'`.

### Calm/safety boundary
- **System prompt chỉ sau sheet:** KHÔNG gọi microphone/health API trước khi user thấy preflight + consent. Defer `'Để sau'` luôn available.
- **No raw audio before consent:** mic purpose nói rõ `'không ghi raw audio trước consent'`, reassurance `'Raw audio không bao giờ rời thiết bị.'`.
- **Redaction whitelist:** log không bao giờ chứa raw signal (audio/voice/health raw) — masked `'[REDACTED]'` trước khi serialize.
- `DistressBoundary` luôn hiện — người dùng biết công cụ không thay thế hỗ trợ chuyên môn.

### Known code gaps (ghi chú, KHÔNG đổi code)
- `_PermissionPromptRuntime` in-memory — count không persist, không sync backend.
- Preflight deep-link chỉ reachable từ Home/Session DevSection (dev-gated) — KHÔNG có user-facing entry point ngoài deep-link trong MVP.
- Denial KHÔNG xử lý ở layer preflight — sheet chỉ defer/system-prompt. Denial xử lý downstream trong session qua `dropEnrichment()` (xem Story 6.3).

## Status

- created: 2026-06-24
- reconciled: 2026-06-26
- dev_status: not-started
- code_review: reconciled
