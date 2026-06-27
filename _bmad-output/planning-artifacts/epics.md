---
stepsCompleted:
  - step-01-validate-prerequisites.md
  - step-02-design-epics.md
  - step-03-create-stories.md
  - step-04-final-validation.md
inputDocuments:
  - _bmad-output/planning-artifacts/prds/prd-meditation-community-2026-06-24/prd.md
  - _bmad-output/planning-artifacts/architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md
  - _bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/DESIGN.md
  - _bmad-output/planning-artifacts/ux-designs/ux-meditation-community-2026-06-24/EXPERIENCE.md
---

# meditation-community - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for meditation-community, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: Ứng dụng phải cung cấp Home có “single-path” hiển thị tối đa 1-2 CTA phù hợp theo thời điểm và bối cảnh người dùng.
FR2: Ứng dụng phải cho phép check-in cảm xúc/năng lượng nhanh trước phiên để ảnh hưởng gợi ý nội dung.
FR3: Thư viện nội dung phải hỗ trợ duyệt theo nhu cầu, thời lượng, bối cảnh, intensity và transition mode.
FR4: Ứng dụng phải hỗ trợ các phiên micro-meditation (ví dụ 20 giây, 45 giây, 90 giây, 3 phút).
FR5: Ứng dụng phải có SOS protocol vào nhanh trong khoảng 60 giây khi người dùng căng thẳng/overloaded.
FR6: Ứng dụng phải có minimal timer và mindfulness bell cho phiên thường.
FR7: Ứng dụng phải có gentle re-entry sau phiên để chuyển trạng thái nhẹ nhàng.
FR8: Ứng dụng phải hiển thị tăng trưởng cá nhân theo hướng không streak pressure.
FR9: Ứng dụng phải cho phép ghi voice journal ngắn sau phiên.
FR10: Người dùng phải tạo và replay personal ritual từ nhiều bước nội dung.
FR11: Hệ thống phải tạo phản hồi sau phiên theo trend theo pattern phiên/check-in/sensor.
FR12: Ứng dụng phải đánh giá mức tiếng ồn môi trường cơ bản để điều chỉnh gợi ý; khi thiếu quyền mic, fallback sang manual context dẫn xuất từ check-in (`manual-calm` / `manual-low` / `manual-overload`) — không dùng nhãn `yên/vừa/ồn`.
FR13: Ứng dụng phải xử lý thêm phản hồi phản chiếu khi có tín hiệu biofeedback được phép.
FR14: Ứng dụng phải hiển thị anonymous presence cho session/time block mà không lộ danh tính.
FR15: Người dùng phải gửi/nhận Mindful Nudge theo preset ngắn, ẩn danh.
FR16: Ứng dụng phải cung cấp curated content ecosystem gồm Core Pack, Contextual Pack, Sound Postcard và offline core packs.
FR17: Hệ thống phải cho phép điều hướng qua Home, Library, Growth, Settings với tab tối giản.
FR18: Ứng dụng phải có SOS xuất hiện từ Home như điểm vào nhanh, nhất quán.
FR19: Người dùng phải tham gia quiet presence block từ Home/Growth.
FR20: Ứng dụng phải có pre-permission sheet cho microphone/health trước khi gọi permission prompt.
FR21: Ứng dụng phải hoạt động ổn khi offline cho các core flows.
FR22: Hệ thống phải theo dõi timeline phiên immutable theo sự kiện (start/pause/complete/abort/SOS/timer bell/re-entry/check-in/journal/ritual replay).
FR23: Người dùng phải có quyền thoát/return trong 1-2 thao tác từ SOS, session, và reflection.

### NonFunctional Requirements

NFR1: Privacy-by-default cho tất cả dữ liệu nhạy cảm (microphone, health, biofeedback, voice journal).
NFR2: Tính rõ ràng của dữ liệu: sản phẩm phải nêu rõ dữ liệu dùng, mục đích dùng, và cách tắt quyền.
NFR3: Session playback, timer, SOS và completion logging phải ổn định trong điều kiện mobile bình thường.
NFR4: Quick-entry (home recommendation, SOS) phải vào được phiên với độ trễ thấp.
NFR5: Không hiển thị hoặc gợi ý hành vi tạo áp lực/gamification khi người dùng distress.
NFR6: UX cần hỗ trợ accessibility (Dynamic Type, tap target đủ lớn, nhãn VoiceOver rõ).
NFR7: Session core phải dùng được không nhìn màn hình nhiều (haptic/text pacing).
NFR8: Sản phẩm không claim chẩn đoán sức khỏe hoặc thay thế hỗ trợ chuyên môn.
NFR9: Không tạo social pressure; không bảng điểm/leaderboard thiền.
NFR10: Ranh giới rõ cho distress flow và hướng dẫn hỗ trợ phù hợp.
NFR11: Degrade gracefully khi thiếu permission/sensor/network.
NFR12: Tôn trọng iOS accessibility/interaction (tap target, reduce motion).
NFR13: Voice journal mặc định là private user content.

### Additional Requirements

- AD-1: Domain slice ownership: mỗi aggregate/session/ritual/progress/presence chỉ mutate qua use case của slice sở hữu.
- AD-2: Session timeline là system of record cho mọi summary/read model.
- AD-3: App phải có ích khi offline và khi không có sensors (offline-first).
- AD-4: Sensing phải đi qua permission-gated normalization adapters và không dùng raw audio upload.
- AD-5: Reflection phải là narrative trend, không score/leaderboard.
- AD-6: Community phải là ephemeral aggregate presence, không social graph/chat.
- AD-7: Backend V1 là managed core stack, tránh microservice mesh sớm.
- AD-8: Stack target hiện tại: Flutter 3.41, Dart 3.10, Riverpod 3.3.2, go_router 17.3.0, Supabase 2.14.0, Drift 2.34.0, just_audio 0.10.5, health 13.3.1.
- AD-9: Convention chuẩn hóa entity/use case/event và error envelope (`code`, `message`, `retryable`, `details`).
- AD-10: ID UUIDv7, timestamp UTC ISO-8601.
- AD-11: Conflict resolution theo append timeline trước rồi reconcile summary.
- AD-12: Health/wearable data chỉ lưu windows đã cho phép, không lưu raw audio.
- AD-13: Backend có jobs cho content sync, reflection enrichment, presence cleanup, notification orchestration.
- AD-14: iOS-first cho V1, Android không blocking cho core release.
- AD-15: Permission fallback cho noise/biofeedback nhưng không chặn core flow.

### UX Design Requirements

UX-DR1: Home/khung trải nghiệm phải ưu tiên dark, calm-first, typography lớn, spacing thoáng, và hiển thị tối đa 1-2 CTA chính.
UX-DR2: SOS CTA phải được hiện thị nhất quán, dễ chạm, không đi qua tab.
UX-DR3: Implement design system theo tokens trong DESIGN.md và semantic token style toàn app.
UX-DR4: Home, Session player, Reflection, permission flows phải ưu tiên tiếng Việt với posture dịu và không guilt; dev-only labels mới được phép EN. **Ngoại lệ contract-locked:** `Ritual Builder`, `Session start`, `Pack type: Core` chỉ được localize sau khi unfreeze `apps/mobile/test/widget_test.dart`.
UX-DR5: Implement component patterns cho home hero CTA, emotional chips, suggested card, presence block, session player, gentle re-entry card, reflection card, recorder, permission sheet.
UX-DR6: Home cold-open và returning state có copy chào nhẹ, không nhắc streak.
UX-DR7: Build state pattern cho offline/no permission/session interrupted/empty states.
UX-DR8: High-stress entry giảm thao tác; luôn có calm exit trong 1-2 bước.
UX-DR9: Quick check-in chips 1-tap, có thể skip.
UX-DR10: Haptic-first controls cho SOS, timer bell, breathing, completion; default haptic-lite.
UX-DR11: Permission education sheet trước system prompt cho mic/health.
UX-DR12: Accessibility floor: VoiceOver labels rõ, tap target chuẩn, Reduce Motion.
UX-DR13: Avoid glassmorphism và shadow cứng; prefer tone layering.
UX-DR14: Completion nhẹ nhàng, không confetti/celebration dã.
UX-DR15: Safety/recovery states: distress floor, stability floor, boundaries.
UX-DR16: Presence/Nudge là non-social aggregate/preset.
UX-DR17: Reflection chỉ narrative trend, no absolute score.
UX-DR18: Settings MVP là accessibility baseline (haptic toggle + cue modes + DistressBoundary). Privacy, permissions, health-links, calm-exit controls là planned (chưa wire trong code).

### FR Coverage Map

FR1: Epic 1 — Home mở nhanh với tối đa 2 CTA chính.
FR2: Epic 1 — quick check-in để gắn trạng thái vào gợi ý.
FR3: Epic 4 — Khám phá theo need/context/duration/intensity.
FR4: Epic 2 — Phiên micro (20s/45s/90s/3m) hoạt động ổn định.
FR5: Epic 1 — SOS protocol vào nhanh, nổi bật, có haptic/audio nhẹ.
FR6: Epic 2 — Timer/chuông cơ bản cho phiên thiền.
FR7: Epic 2 — Gentle re-entry sau hoàn tất phiên.
FR8: Epic 3 — Growth Map không streak pressure.
FR9: Epic 3 — Ghi voice journal ngắn sau phiên.
FR10: Epic 3 — Personal ritual builder và replay.
FR11: Epic 3 — Session reflection theo narrative trend.
FR12: Epic 2 — Noise context phục vụ điều chỉnh nội dung.
FR13: Epic 3 — Biofeedback-enhanced reflection khi có dữ liệu cho phép.
FR14: Epic 5 — Anonymous presence theo bucket/time block.
FR15: Epic 5 — Mindful nudges định trước, có thể bỏ qua.
FR16: Epic 4 — Curated content packs theo label và bối cảnh.
FR17: Epic 4 — Core packs offline-first và hiển thị trạng thái dùng được offline.
FR18: Epic 1 — SOS xuất hiện trong Home/entry như điểm vào nhanh.
FR19: Epic 5 — Tham gia presence block từ Home/Growth.
FR20: Epic 6 — Permission sheet trước khi gọi permission.
FR21: Epic 6 — Core flows vẫn chạy ổn khi offline.
FR22: Epic 6 — Session timeline là immutable timeline source-of-truth.
FR23: Epic 6 — Exit/return trong 1-2 thao tác.

## Epic List

### Epic 1: Khởi động nhanh và vào liệu nhanh (Calm Entry)
Người dùng có thể mở app và bắt đầu phiên phù hợp trong tối thiểu thao tác, kể cả trong tình huống căng thẳng cấp cao.
**FRs covered:** FR1, FR2, FR5, FR18

### Epic 2: Phiên thiền cốt lõi và khôi phục sau phiên
Người dùng có thể chạy phiên micro/thiền ngắn, bật timer/chuông, và kết thúc với gentle re-entry ổn định.
**FRs covered:** FR4, FR6, FR7, FR12

### Epic 3: Tiếp tục cá nhân và phản chiếu tiến triển
Người dùng duy trì thói quen nhẹ nhàng, tạo ritual, ghi voice journal, và nhận phản hồi progression theo trend.
**FRs covered:** FR8, FR9, FR10, FR11, FR13

### Epic 4: Khám phá nội dung và giá trị cốt lõi có kiểm soát
Người dùng có đường đi nội dung rõ ràng theo nhu cầu thực tế và luôn có trải nghiệm offline cho nội dung cốt lõi.
**FRs covered:** FR3, FR16, FR17

### Epic 5: Cộng đồng yên tĩnh, không social pressure
Người dùng thấy cảm giác hiện diện cộng đồng ẩn danh mà không phải tương tác kiểu mạng xã hội.
**FRs covered:** FR14, FR15, FR19

### Epic 6: Dữ liệu phiên, quyền riêng tư, và độ bền nền tảng
Ứng dụng vận hành ổn định trong điều kiện thiếu quyền/sensor/network; timeline phiên là nguồn dữ liệu chính cho mọi phản chiếu.
**FRs covered:** FR20, FR21, FR22, FR23

## Epic 1: Khởi động nhanh và vào liệu nhanh (Calm Entry)

Mục tiêu Epic: người dùng có thể mở app và bắt đầu hành động tốt đầu tiên trong bối cảnh căng thẳng trong tối thiểu thao tác.

### Story 1.1: Home hiển thị nhanh 1–2 CTA phù hợp

As a người dùng khi mở app,
I want thấy 1–2 nút hành động chính phù hợp nhất theo thời điểm và trạng thái gần nhất,
So that tôi có thể bắt đầu phiên ngay mà không lối phân tán.

**Acceptance Criteria:**

**Given** người dùng mở Home lần đầu hoặc mở lại sau ngắt quãng,
**When** hệ thống đánh giá context time-of-day, check-in gần nhất và continuity cục bộ,
**Then** UI hiển thị tối đa 2 body CTA chính (ví dụ `Thở ngắn 3 phút`, `Chuẩn bị ngủ`, `Tiếp tục hành trình`),
**And** `SOS` sống riêng ở một capsule yên tĩnh ở header (`cta-sos`), không nằm trong số 2 body CTA này,
**And** mỗi CTA có nhãn rõ ràng, tap target đáp ứng chuẩn mobile.

**Given** có nhiều tín hiệu context (`timeBucket`, `lastSessionType`/`lastSessionAt`, `lastCheckin`, `interruptionState`, `continuityHint`),
**When** `_rankCtas` chọn hành động ưu tiên,
**Then** ứng viên body CTA là `short-breath` (`'Thở ngắn 3 phút'`, score 3, luôn seed), `before-sleep` (`'Chuẩn bị ngủ'`, score 4, khi night/returning + sleep session), và `continue-ritual` (`'Tiếp tục hành trình'`, score 2, khi có `continuityHint`),
**And** sort theo `isCalmFirst` → score desc → recency desc, rồi `.take(2)`; mọi exception → swallow + render `[short-breath]` (offline-first, luôn có path vào session).

### Story 1.2: Quick emotional/energy check-in gắn vào phiên

As a người dùng,
I want chọn nhanh cảm xúc/năng lượng trước phiên,
So that app có thể cá nhân hóa gợi ý nhanh mà không tốn thời gian.

**Acceptance Criteria:**

**Given** user ở Home và đang vào flow khởi tạo phiên,
**When** hiển thị quick check-in,
**Then** người dùng chọn được một trong các lựa chọn ngắn trong 1 thao tác,
**And** trạng thái được gắn vào phiên hiện tại trong session context.

**Given** người dùng bỏ qua check-in,
**When** tiếp tục bắt đầu phiên,
**Then** flow vẫn bắt đầu bình thường,
**And** app dùng default context thay vì khóa.

### Story 1.3: SOS flow vào nhanh với fallback ổn định

As a người dùng đang quá tải,
I want nhấn SOS và vào breathing flow trong vài giây,
So that tôi hạ được mức kích hoạt cảm xúc ngay lập tức.

**Acceptance Criteria:**

**Given** người dùng nhấn SOS từ Home,
**When** hệ thống tạo phiên SOS,
**Then** flow bắt đầu trong ≤60 giây từ lúc người dùng chạm,
**And** có mode haptic/audio tối giản theo thiết lập thiết bị.

**Given** SOS liên tiếp nhiều lần trong cùng phiên thời gian mà chưa hoàn tất,
**When** stability floor kích hoạt,
**Then** copy hướng dẫn giảm tối thiểu, chuyển sang haptic-lite/text,
**And** luôn có nút Exit/Return trong 1–2 thao tác.

**Given** người dùng ở SOS entry hoặc SOS active,
**When** flow render,
**Then** một `DistressBoundary` ("không thay thế hỗ trợ chuyên môn" + link trợ giúp) luôn hiện diện, action `'Tìm hỗ trợ'` mặc định mở `_SupportResourcesSheet` (hotline / hỗ trợ chuyên môn / người tin cậy),
**And** khi phiên SOS hết 60s, flow chuyển calm-safe exit và ghi `sos_timeout_exit`.

### Story 1.4: Home routing và điều hướng tab tối giản

As a người dùng,
I want tab của app rõ ràng và ít nhiễu,
So that tôi không bị cuốn vào quá nhiều lựa chọn.

**Acceptance Criteria:**

**Given** user mở app,
**When** tab bar render,
**Then** chỉ có Home, Library, Growth, Settings (Material `NavigationBar` 4 đích),
**And** SOS không phải tab mà là capsule yên tĩnh ở header Home (`cta-sos`), luôn hiện diện.

## Epic 2: Phiên thiền cốt lõi và khôi phục sau phiên

Mục tiêu Epic: người dùng chạy được phiên micro hoặc phiên thường ổn định, và hoàn tất với kết thúc dịu nhẹ.

### Story 2.1: Micro sessions có sẵn trong thư viện và startup nhanh

As a người dùng,
I want có các phiên 20 giây, 45 giây, 90 giây, 3 phút,
So that tôi có thể bắt đầu nhanh với phiên phù hợp.

**Acceptance Criteria:**

**Given** catalog có đầy đủ duration micro,
**When** user lọc hoặc chọn Quick Start,
**Then** phiên micro có thể bắt đầu trong thời gian nhanh hơn phiên thường,
**And** mỗi phiên được ghi nhận trong growth timeline như session event.

**Given** thiết bị đang trong điều kiện băng thông hạn chế,
**When** start micro session,
**Then** nội dung vẫn chạy ổn định trên local bundle hoặc cache.

### Story 2.2: Minimal timer và mindfulness bell cơ bản

As a người dùng đã quen thiền,
I want chỉnh thời lượng và nghe bell theo mốc,
So that phiên chạy theo nhu cầu mà không phức tạp.

**Acceptance Criteria:**

**Given** người dùng ở session player,
**When** chọn duration và bắt đầu session,
**Then** timer chạy đúng thời lượng đã chọn,
**And** bell phát đúng mốc đã cấu hình hoặc presets.

**Given** session bị pause hoặc app bị interrupt,
**When** người dùng quay lại,
**Then** trạng thái timer tiếp tục theo timeline policy (resume/close safely),
**And** không bị mất dữ liệu completion.

**Given** người dùng ở session player,
**When** phiên chạy,
**Then** bề mặt user-facing là calm-first: `SoftTimer` (đồng hồ serif lớn, thấp độ nổi) + `ProgressRing` + `BreathingCircle` + `SessionStateLabel` ("Cùng nhau thở.", "Nghỉ một nhịp."),
**And** mọi runtime telemetry / debug-QA (elapsed, bell status, noise confidence, mic-permission toggle…) nằm sau `DevSection`, chỉ hiện ở debug/test, ẩn sạch ở release (`--dart-define=ELARO_RELEASE=true`).

### Story 2.3: Gentle re-entry sau phiên

As a người dùng sau khi hoàn tất phiên,
I want có màn hình kết thúc nhẹ nhàng,
So that tôi quay lại trạng thái bình ổn, không gián đoạn.

**Acceptance Criteria:**

**Given** phiên hoàn tất,
**When** session chuyển state kết thúc,
**Then** gentle re-entry card xuất hiện với nhạc/text/haptic dịu nhẹ,
**And** có ít nhất 2 lựa chọn hành động kế tiếp (dừng, lặp lại, follow-up ngắn).

**Given** người dùng muốn tạm dừng ngay,
**When** họ chọn dừng ở re-entry,
**Then** luồng đi về Home giữ nguyên context phiên hiện tại cho lần quay lại tiếp theo.

### Story 2.4: Session runtime hỗ trợ noise-aware mode baseline

As a người dùng ở môi trường ồn,
I want flow không ngắt vì noise context chưa sẵn,
So that tôi vẫn có trải nghiệm liên tục.

**Acceptance Criteria:**

**Given** người dùng chưa cấp quyền microphone,
**When** vào flow noise-aware,
**Then** app fallback sang manual context dẫn xuất từ check-in (`manual-calm` / `manual-low` / `manual-overload`),
**And** không hiển thị claim dựa trên dữ liệu chưa có.

**Given** micro permissions bị từ chối giữa phiên,
**When** session đang chạy,
**Then** flow giữ nguyên nội dung đang phát,
**And** bỏ qua enrichment noise context mà không reset timer hay timeline.

**Given** `confidence < ngưỡng` cho ước lượng noise,
**When** hệ thống gợi ý nội dung theo context,
**Then** UI hiển thị nhãn "độ tin cậy thấp",
**And** chỉ dùng context thủ công đã chọn.

## Epic 3: Tiếp tục cá nhân và phản chiếu tiến triển

Mục tiêu Epic: giúp người dùng giữ nhịp quay lại dễ chịu với growth, phản chiếu và ritual.

### Story 3.1: Growth Map không dùng streak pressure

As a người dùng quay lại sau gián đoạn,
I want xem tổng kết tích lũy theo cách an toàn,
So that tôi thấy tiến triển mà không cảm giác áp lực.

**Acceptance Criteria:**

**Given** user có >=1 phiên hoàn tất,
**When** mở Growth,
**Then** hiển thị tổng phiên và tổng thời lượng,
**And** không hiển thị streak là metric trung tâm.

### Story 3.2: Voice journal sau phiên

As a người dùng sau phiên,
I want ghi âm cảm nhận nhanh,
So that tôi lưu lại phản ánh của mình một cách riêng tư.

**Acceptance Criteria:**

**Given** người dùng ở post-session/re-entry,
**When** chọn voice journal,
**Then** recorder bắt đầu trong 1 thao tác,
**And** file gắn với session ID gần nhất.

**Given** ghi âm hoàn tất,
**When** lưu,
**Then** bản ghi chỉ hiển thị trong private scope của người dùng.

**Given** thiết lập privacy chưa đồng ý share,
**When** hệ thống sync post-processing,
**Then** voice journal không auto-transcribe, không gửi cho dịch vụ bên thứ ba, và không được đính kèm transcript tự động.

### Story 3.3: Personal ritual builder và replay

As a người dùng muốn có routine cá nhân,
I want tạo và chạy lại ritual từ nhiều bước,
So that tôi có đường đi phù hợp nhanh hơn.

**Acceptance Criteria:**

**Given** user xem nội dung trong Home/Library,
**When** chọn ghép các session vào một ritual,
**Then** ritual được lưu kèm tên/metadata,
**And** có thể replay từ Home nhanh.

### Story 3.4: Session reflection narrative baseline

As a người dùng,
I want nhận phản hồi sau phiên bằng câu chuyện ngắn,
So that tôi hiểu xu hướng ổn định của mình.

**Acceptance Criteria:**

**Given** session hoàn tất,
**When** mở reflection,
**Then** hệ thống hiển thị narrative trend thay vì điểm số tuyệt đối,
**And** nội dung không có thứ hạng hay phần so sánh người khác.

### Story 3.5: Reflection nâng cao với biofeedback khi có quyền

As a người dùng có quyền health,
I want phản chiếu sâu hơn bằng tín hiệu sinh lý cho phép,
So that phản hồi sát bối cảnh hơn mà không ép buộc.

**Acceptance Criteria:**

**Given** permission/badge health được cấp và data adapter có sẵn,
**When** tạo reflection,
**Then** phản hồi dùng **tone words + direction** (ví dụ nhịp "ổn định", cơ thể "rất tĩnh", HRV "ổn định hơn / đang hồi dần về cuối phiên") — không hiện số tuyệt đối (không bpm, không giá trị HRV, không điểm),
**And** kèm dòng khẳng định "đây là chiều hướng, không phải chỉ số" và "không đưa ra điểm số, không so sánh",
**And** khi dữ liệu low-confidence hoặc thiếu, reflection fallback sang cảm nhận của người dùng mà không shaming.

## Epic 4: Khám phá nội dung và giá trị cốt lõi có kiểm soát

Mục tiêu Epic: người dùng tìm đúng nội dung theo nhu cầu, context và dùng được offline core packs.

### Story 4.1: Taxonomy content theo need/context/duration/intensity

As a người dùng,
I want duyệt nội dung theo nhu cầu và bối cảnh,
So that tôi nhanh thấy lựa chọn phù hợp.

**Acceptance Criteria:**

**Given** content catalog có metadata đầy đủ,
**When** user chọn filter need/context/duration/intensity/transition mode,
**Then** danh sách lọc đúng criteria theo nội dung,
**And** không đòi nhiều thao tác trung gian.

### Story 4.2: Transition modes và suggested session card

As a người dùng,
I want vào các transition mode như trước khi ngủ, reset nhanh,
So that nội dung phục vụ trạng thái của tôi ngay.

**Acceptance Criteria:**

**Given** home hoặc library render suggested cards,
**When** gợi ý transition mode hợp context,
**Then** card có thời lượng, context fit, offline state,
**And** nhấn card đi tới preview/playback nhanh.

### Story 4.3: Curated packs và labeling rõ ràng

As a người dùng,
I want thấy rõ pack nào là core/contextual/sound postcard,
So that tôi biết mức phù hợp và độ tin cậy nội dung.

**Acceptance Criteria:**

**Given** catalog hiển thị pack,
**When** user mở chi tiết pack,
**Then** pack hiển thị type, context, duration, tone/use case,
**And** phân biệt rõ nội dung curated và các lớp khác.

### Story 4.4: Offline core packs visibility và playback

As a người dùng ở môi trường offline,
I want biết ngay nội dung nào đã sẵn trên máy,
So that tôi vẫn có thể thiền ngay.

**Acceptance Criteria:**

**Given** thiết bị offline,
**When** mở Home/Library,
**Then** core packs offline hiển thị rõ là sẵn sàng,
**And** phiên từ core packs chạy được từ cache.

## Epic 5: Cộng đồng yên tĩnh, không social pressure

Mục tiêu Epic: tạo cảm giác cùng hiện diện nhưng không đổi thành social platform.

### Story 5.1: Hiển thị anonymous presence bucket

As a người dùng,
I want thấy có người cùng thiền theo khối thời gian mà không lộ thông tin cá nhân,
So that tôi cảm thấy có người đồng hành.

**Acceptance Criteria:**

**Given** hệ thống có presence data,
**When** mở Home hoặc Presence surface,
**Then** hiển thị số lượng aggregate trong time bucket, **hoặc** empty-state aggregate-only khi count mới nhất = 0 (`presence-empty-message` + `presence-empty-refresh`),
**And** không hiển thị tên hay hồ sơ cá nhân.

### Story 5.2: Join quiet presence block

As a người dùng muốn thiền cùng nhịp,
I want tham gia block có hiện diện dễ dàng,
So that tôi vẫn giữ không gian riêng tư.

**Acceptance Criteria:**

**Given** block có người hoặc trống,
**When** user chọn join,
**Then** membership vào block được tạo trong phiên local/aggregate,
**And** không tạo graph follow/chat.

### Story 5.3: Mindful nudge preset

As a người dùng,
I want gửi/nhận nudge ngắn theo preset,
So that tôi có thể hỗ trợ nhắc nhở nhẹ không gây áp lực.

**Acceptance Criteria:**

**Given** preset nudge có sẵn,
**When** user gửi hoặc nhận nudge,
**Then** nudge không phá gián đoạn flow thiền,
**And** user có thể tắt/bỏ qua dễ dàng.

**Given** một phiên vừa hoàn tất,
**When** Session active render completion state,
**Then** slot post-session `session-active-*` xuất hiện sau `session-reentry-card`,
**And** giữ posture gentle/dismissible thay vì ép người dùng sang flow xã hội.

### Story 5.4: Trải nghiệm community an toàn trong phiên và sau phiên

As a người dùng,
I want thấy community ở mức có chọn lọc,
So that trải nghiệm vẫn calm-first.

**Acceptance Criteria:**

**Given** user hoàn tất phiên có presence,
**When** hiển thị post-session suggestions,
**Then** chỉ đề xuất 1–2 nudge/option nhẹ,
**And** không xuất hiện feed, chat, bình luận hay feed activity.

## Epic 6: Dữ liệu phiên, quyền riêng tư, và độ bền nền tảng

Mục tiêu Epic: tạo nền tảng vận hành tin cậy với timeline nguồn sự kiện, permission-safe, và hành vi recover an toàn.

### Story 6.1: Session timeline immutable event model

As a developer,
I want ghi lại các events phiên theo immutable timeline,
So that mọi module đọc từ một nguồn chính xác.

**Acceptance Criteria:**

**Given** mỗi event session (start/pause/complete/abort/SOS/re-entry/check-in/journal/ritual),
**When** append mới được ghi,
**Then** hệ thống validate timeline contract gồm `event_id`, `aggregate_id`, `aggregate_version`, `occurred_at_utc`, `source`, `idempotency_key`, `schema_version`,
**And** reject event không hợp lệ trước khi ghi vào timeline.

**Given** 2 event có cùng `occurred_at_utc`,
**When** sắp xếp event stream,
**Then** hệ thống sort theo `occurred_at_utc` cộng `source_priority` để đảm bảo causality,
**And** duplicate theo `idempotency_key` là idempotent và không double-count.

**Given** summary/read models cần truy vấn,
**When** timeline cập nhật,
**Then** summary/read models được derive từ timeline đã qua validation,
**And** không có mutation direct ngoài cơ chế append-only.

### Story 6.2: Permission sheet trước khi truy cập microphone/health

As a người dùng,
I want được giải thích trước khi cấp quyền mic/health,
So that tôi tự chủ và yên tâm về dữ liệu.

**Acceptance Criteria:**

**Given** feature cần microphone hoặc health,
**When** user chưa cấp quyền,
**Then** app hiện pre-permission sheet trước khi gọi hệ thống,
**And** sheet nêu rõ mục đích, dữ liệu dùng/không dùng, và lựa chọn để sau.

**Given** feature cần microphone/health,
**When** quyền chưa được cấp,
**Then** ứng dụng không gọi API microphone/health trước khi có quyền,
**And** không ghi raw audio/event không cần thiết vào timeline trước consent.

**Given** người dùng ở pre-permission sheet,
**When** sheet render,
**Then** một `DistressBoundary` ("không thay thế hỗ trợ chuyên môn" + link trợ giúp) hiện diện cùng sheet, action `'Tìm hỗ trợ'` mặc định mở `_SupportResourcesSheet`,
**And** người dùng có lựa chọn "Để sau" trước khi mở system prompt.

**Given** app có logging lỗi,
**When** ghi log sensor/event,
**Then** dữ liệu nhạy cảm được redaction theo policy,
**And** log không chứa raw signal của microphone/voice không cần thiết.

**Given** log pipeline serializing event hoặc audit,
**When** phát hiện field nhạy cảm,
**Then** áp dụng redaction whitelist/blacklist cho token, raw health sample, raw audio path, device identifiers,
**And** có test xác minh ít nhất 5 trường riêng tư bị mask.

### Story 6.3: Offline-first core và fallback cho sensor

As a người dùng,
I want app vẫn vận hành khi mất mạng hoặc mất sensor,
So that core experience không bị khóa.

**Acceptance Criteria:**

**Given** không có mạng hoặc permission bị từ chối,
**When** mở core flows (home/library/ session player/growth/journal),
**Then** các luồng chính vẫn chạy được,
**And** các tính năng cần enrichment sensor hiển thị rõ giới hạn độ tin cậy.

**Given** offline + presence block đang hiển thị,
**When** không sync được presence mới,
**Then** giao diện vẫn cho phép tiếp tục phiên/học liệu offline,
**And** presence mới chỉ hiển thị dưới dạng trạng thái stale/đang tải.

**Given** cache miss nội dung core packs,
**When** người dùng cố phát,
**Then** app gợi ý cách làm sẵn hoặc retry nhẹ nhàng,
**And** không crash hay khóa toàn bộ session.

**Given** stale presence state tồn tại quá TTL,
**When** render presence,
**Then** hiển thị nhãn stale + thời điểm làm mới cuối,
**And** sau TTL ẩn luôn presence mới để tránh misinformation.

### Story 6.4: Recovery & Exit Core cho high-stress flows

As a người dùng,
I want luôn có lối thoát nhanh và khôi phục rõ ràng từ SOS, session, reflection,
So that app không kéo dài trạng thái căng thẳng.

**Acceptance Criteria:**

**Given** người dùng ở SOS,
**When** cần dừng ngay,
**Then** Exit/Return trong ≤2 thao tác,
**And** timeline ghi event `sos_interrupt` hoặc `session_interrupted` theo đúng source.

**Given** người dùng ở session player hay reflection,
**When** mất kết nối/app background/permission thay đổi đột ngột,
**Then** hiển thị một trong ba lựa chọn: resume, gentle-close, hoặc new session,
**And** thời gian mở cửa quay lại ở cùng flow không quá 1 thao tác.

**Given** session timeout hoặc user không phản hồi liên tục trong SOS,
**When** chạm đến policy timeout,
**Then** flow chuyển calm-safe exit,
**And** timeline ghi event `sos_timeout_exit`.

### Story 6.5: Error envelope, IDs, sync conflict safety

As a developer,
I want dữ liệu dùng chuẩn format và xử lý xung đột rõ,
So that vận hành backend ổn định.

**Acceptance Criteria:**

**Given** service/adapter trả về lỗi hoặc conflict,
**When** xử lý API hoặc sync,
**Then** response dùng envelope (`code`, `message`, `retryable`, `details`),
**And** ID sử dụng UUIDv7, timestamp UTC ISO-8601.

**Given** API báo lỗi retriable,
**When** retry,
**Then** áp dụng exponential backoff + jitter,
**And** stop retry theo stop-loss để UI core vẫn responsive.

**Given** sync conflict giữa local và remote,
**When** reconcile,
**Then** ưu tiên append timeline trước khi tái tổng hợp summary,
**And** không mất dữ liệu session đã hoàn tất.

### Story 6.6: Accessibility baseline và haptic-first runtime

As a người dùng có nhạy cảm ánh nhìn/âm thanh,
I want sản phẩm vẫn có thể dẫn dắt qua haptic/text,
So that tôi dùng được trong tình huống không muốn nhìn hoặc nghe nhiều.

**Acceptance Criteria:**

**Given** user bật Dynamic Type, reduce motion, hoặc không muốn âm thanh,
**When** truy cập Home, Session player, post-session flow, hoặc bất kỳ sheet body có thể tràn,
**Then** typography/spacing vẫn readable, nội dung vẫn scroll được ở text-scale lớn,
**And** nội dung không phụ thuộc animation/bắt buộc âm thanh.

**Given** haptic-only fallback cần thiết,
**When** vào SOS, timer bell, breathing cue,
**Then** cue có haptic/text thay thế phù hợp,
**And** user có thể bật/tắt haptic trong settings.

## Implementation & Reconciliation Notes (re-baseline 2026-06-26)

Code tại `apps/mobile/` là nguồn xác thực. ACs trên đã được rà soát full-sweep để khớp behavior đang ship. Các điểm reconciled/giữ nguyên:

- **Dev-gating (cross-cutting AC):** mọi runtime telemetry, sensor/QA toggles, prompt-count, preflight deep-links, runtime-event label, bell/breathing cue labels, accessibility-summary runtime, SOS reason, network state **phải nằm sau `DevSection`** — chỉ hiện debug/test, ẩn sạch release qua `--dart-define=ELARO_RELEASE=true` (`core/dev_mode.dart` → `DevGate.enabled`; `dev/dev_section.dart`). Missed dart-define → fail-safe dev ON. Áp dụng cho Story 2.2 (đã có AC), và mọi story chạm telemetry (2.1, 2.4, 3.5, 6.2, 6.6).
- **Calm-player pattern (Story 2.2):** `SoftTimer` + `ProgressRing` + `BreathingCircle` + `SessionStateLabel`; haptic tại start/complete/bell/pause/resume.
- **Distress boundary surface set (Story 6.2 / cross-cutting):** `DistressBoundary` trên SOS (entry+active), Reflection, Settings, Permissions; action mặc định mở `_SupportResourcesSheet`.
- **Manual noise context (Story 2.4):** dẫn xuất từ `_CheckinState {calm, low, overload}` → `manual-calm/manual-low/manual-overload`; KHÔNG dùng `yên/vừa/ồn`.
- **Settings scope (UX-DR18):** MVP = accessibility baseline; privacy/permissions/health-links/calm-exit planned.
- **Dark-only posture:** `Brightness.dark` hardcode; light theme chưa wire.
- **Scrollability invariant (Story 6.6 / cross-cutting):** mọi `Scaffold` body + `CalmBottomSheet` body có thể tràn đều phải scrollable; completion/re-entry/support surfaces đã reconcile theo pattern này.
- **Durable guardrails:** xem `_bmad-output/planning-artifacts/ENGINEERING-RULES.md` cho 8 rules bền (scroll, dev-gating, no infinite animations, frozen tests, design-system usage, i18n, tone/invariants, Phase-7 structure).

### Code anchors per Epic (apps/mobile/lib/…)

- Epic 1: `features/home/home.dart`, `features/sos/sos.dart`
- Epic 2: `features/session/session.dart`, `runtime/session.dart`, `components/breathing/breathing.dart`
- Epic 3: `features/growth/growth.dart`, `features/voice_journal/voice_journal.dart`, `features/ritual/ritual.dart` (+`runtime/runtimes.dart`)
- Epic 4: `features/library/library.dart`
- Epic 5: `features/presence/presence.dart` (+`components/presence/presence.dart`), `features/mindful_nudge/mindful_nudge.dart`
- Epic 6: `domain/timeline.dart`, `domain/errors.dart`, `domain/logging.dart`, `features/permissions/permissions.dart`, `runtime/accessibility.dart`, `runtime/runtimes.dart`

### Known code/spec gaps (không đổi code — leader quyết định spec-gap vs code-work)

1. **(đã fix 2026-06-27)** `/session/before-sleep-8m` và `/session/ritual-*` đã có route handler → CTA `before-sleep`/`continue-ritual` vào `_SessionStartScreen` thật.
2. **(đã fix 2026-06-27)** mindful nudge đã có slot post-session `session-active-*`.
3. **(đã fix 2026-06-27)** Presence có empty-state aggregate-only khi count = 0; Ritual replay empty có CTA `ritual-empty-create`.
4. **(đã fix 2026-06-27)** `DistressBoundary` action mặc định mở support sheet.
5. **(đã fix 2026-06-27)** targeted i18n sweep đã sang Vi cho BreathingCircle / Presence labels / Settings headline / DataCommitmentBox; **known debt do frozen test contract:** `Ritual Builder`, `Session start`, `Pack type: Core`.
6. **(đã fix 2026-06-27)** scrollability invariant đã land trên core screens + support sheet.
7. Dead/dormant: `_SessionType{focus,sleep}` không chọn trên UI, `BreathingCircle.onPhaseChange`, `abortSession`, `_RitualReplayArgs`, `_VoiceJournalArgs.voicePrivacyAllowed`; duplicate key `sos-haptic-text-fallback`.
8. Voice journal: 3 widget test `skip: true`; persistence in-memory (ritual/voice-journal/nudge).
