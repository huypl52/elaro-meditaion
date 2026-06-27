# Sprint UI Map

> Mục tiêu: khóa chặt mapping giữa `epics.md` ↔ `docs/ui-dev-handoff.md` để dev sprint không drift UI.

## 0) Nguồn truth của map

- Yêu cầu & story: `_bmad-output/planning-artifacts/epics.md`
- UX surface + route/tokens + handoff implementation: `docs/ui-dev-handoff.md`
- Handoff dev cuối cùng (snapshot đã có): `docs/ui-dev-handoff.md`

## 1) Định nghĩa màn chuẩn (final screen set)

| UX surface | Màn Stitch/chốt | Local folder | Route đề xuất | Ghi chú |
|---|---|---|---|---|
| Home | Home - Quiet Presence Refinement C | `design-artifacts/stitch/ui-review-export/01-home-quiet-presence-refinement-c/` | `/home` | Single-path, ≤2 CTA above-the-fold |
| SOS Entry | SOS Entry - Tactile Stabilization | `design-artifacts/stitch/ui-review-export/02-sos-entry-tactile-stabilization/` | `/sos` | 1 tap enter, low cognitive load |
| SOS Active | Active Calming - Tactile Stabilization Flow | `design-artifacts/stitch/ui-review-export/03-active-calming-tactile-stabilization-flow/` | `/sos/active` | 60s low-latency flow |
| Session Player | Session Player - Tactile Silence | `design-artifacts/stitch/ui-review-export/04-session-player-tactile-silence/` | `/session/:sessionId` | Timer + bell + haptic theo timeline |
| Gentle Re-entry | Gentle Re-entry - Refined | `design-artifacts/stitch/ui-review-export/05-gentle-re-entry-refined/` | `/session/:sessionId/re-entry` | Kết thúc dịu nhẹ, không celebration |
| Reflection & Growth | Reflection & Growth | `design-artifacts/stitch/ui-review-export/06-reflection-and-growth/` | `/growth`, `/session/:sessionId/reflection` | Narrative trend, no score/streak |
| Library by Need | Library by Need | `design-artifacts/stitch/ui-review-export/07-library-by-need/` | `/library` | filter need/context/duration/intensity/transition |
| Quiet Presence | Quiet Presence | `design-artifacts/stitch/ui-review-export/08-quiet-presence/` | `/presence` | Aggregate-only, no social graph |
| Privacy/Permissions | Privacy & Permissions - Trusted Foundation | `design-artifacts/stitch/ui-review-export/09-privacy-and-permissions-trusted-foundation/` | `/permissions/:type/preflight` | Pre-permission explanation trước OS prompt |

## 2) UI màn được gài trực tiếp từ story (không tạo màn mới)

### Epics 1–2: Calm Entry + Core Session

1.1 Home hiển thị nhanh 1–2 CTA phù hợp
- UX surface: Home
- Screen/route: Home (`/home`)
- Chốt: CTA count ≤2, ranking context-aware, tap target chuẩn mobile

1.2 Quick emotional/energy check-in gắn vào phiên
- UX surface: Home (Quick check-in)
- Screen/route: Home (`/home`)
- Chốt: chọn trong 1 thao tác, có thể skip, vẫn start được session

1.3 SOS flow vào nhanh với fallback ổn định
- UX surface: SOS Entry + Active
- Screens/routes: `/sos`, `/sos/active`
- Chốt: thời gian vào ≤60s, có safe exit trong 1–2 thao tác

1.4 Home routing và tab tối giản
- UX surface: Shell navigation
- Screens/routes: `/home`, `/library`, `/growth`, `/settings`
- Chốt: chỉ 4 tabs; SOS không phải tab

2.1 Micro sessions có sẵn trong thư viện và startup nhanh
- UX surface: Library + Session player
- Screens/routes: `/library`, `/session/:sessionId`
- Chốt: các duration 20s/45s/90s/3m hiển thị/filter được và start nhanh

2.2 Minimal timer và mindfulness bell
- UX surface: Session runtime
- Screen/route: Session player (`/session/:sessionId`)
- Chốt: timer đúng độ dài, bell đúng mốc, resume safe

2.3 Gentle re-entry sau phiên
- UX surface: Post-session
- Screen/route: Gentle re-entry (`/session/:sessionId/re-entry`)
- Chốt: có >=2 hành động follow-up, không confetti, quay về ổn định

2.4 Session runtime hỗ trợ noise-aware baseline
- UX surface: Session runtime + Permission boundary
- Screens/routes: `/session/:sessionId`, `/permissions/:type/preflight`
- Chốt: thiếu permission/microphone vẫn chạy core flow, confidence labels rõ ràng

### Epic 3: Growth + Reflection

3.1 Growth map không dùng streak pressure
- UX surface: Growth
- Screen/route: `/growth`
- Chốt: total sessions/durations, không streak metric trung tâm

3.2 Voice journal sau phiên
- UX surface: Reflection & Growth (deferred surface embedded)
- Screen/route: `/session/:sessionId/reflection` / `Home` post-session shortcut
- Chốt: action 1-tap, file tie vào latest session, private scope

3.3 Personal ritual builder và replay
- UX surface: Home + Library (folded)
- Screen/route: `/home`, `/library`
- Chốt: ritual được build/replay trong flow home/library trước khi có màn riêng

3.4 Session reflection narrative baseline
- UX surface: Reflection
- Screen/route: `/session/:sessionId/reflection`
- Chốt: narrative trend, không score/rank

3.5 Reflection nâng cao với biofeedback khi có quyền
- UX surface: Reflection + Permissions
- Screen/route: `/session/:sessionId/reflection`, `/permissions/:type/preflight`
- Chốt: chỉ enrich khi có consent/permission, không chặn core flow

### Epic 4: Library + Discovery

4.1 Taxonomy content theo need/context/duration/intensity
- UX surface: Library
- Screen/route: `/library`
- Chốt: filter đúng metadata, thao tác nhanh, không deep-link overkill

4.2 Transition modes + suggested session card
- UX surface: Home + Library
- Screen/route: `/home`, `/library`, `/session/:sessionId`
- Chốt: suggested card có transition mode + duration + state offline

4.3 Curated packs và labeling
- UX surface: Library
- Screen/route: `/library`
- Chốt: pack type rõ: core/contextual/sound postcard

4.4 Offline core packs visibility + playback
- UX surface: Home + Library
- Screen/route: `/home`, `/library`, `/session/:sessionId`
- Chốt: badge offline-ready, playback từ cache ổn

### Epic 5: Quiet Presence

5.1 Anonymous presence bucket
- UX surface: Presence
- Screen/route: `/presence`
- Chốt: chỉ aggregate (ẩn danh), không profile/chat/feed

5.2 Join quiet presence block
- UX surface: Presence
- Screen/route: `/presence`
- Chốt: join/leave rõ ràng, không tạo social graph

5.3 Mindful nudge preset
- UX surface: Presence + Growth + Home
- Screen/route: `/home`, `/growth` (inline nudge slots)
- Chốt: optional, có skip/tắt

5.4 Community an toàn trong phiên và sau phiên
- UX surface: Home + Growth + Presence
- Screen/route: `/home`, `/growth`, `/presence`
- Chốt: chỉ 1–2 nudge nhẹ, no feed/chat

### Epic 6: Platform + compliance

6.1 Session timeline immutable model
- UX surface: toàn bộ core flows
- Screen/route: không có màn riêng; ảnh hưởng mọi màn `Home`, `SOS`, `Session`, `Growth`
- Chốt: sự kiện UI phải khớp state từ timeline

6.2 Permission sheet trước mic/health
- UX surface: Permission
- Screen/route: `/permissions/:type/preflight`
- Chốt: never call OS permission prompt trước sheet

6.3 Offline-first core và fallback sensor
- UX surface: Home/Library/Session/Growth + Presence
- Screen/route: `/home`, `/library`, `/session/:sessionId`, `/growth`
- Chốt: no hard-block khi offline/deny sensor

6.4 Recovery & exit cho high-stress flows
- UX surface: SOS + Session + Reflection
- Screen/route: `/sos`, `/session/:sessionId`, `/session/:sessionId/reflection`
- Chốt: exit/return trong 1–2 thao tác; có 3-ways recovery

6.5 Error envelope + IDs + sync conflict
- UX surface: toàn app
- Screen/route: không map riêng
- Chốt: lỗi hiển thị hành vi nhất quán, không làm khóa core flow

6.6 Accessibility baseline + haptic-first runtime
- UX surface: Home + Session + Post-session + Settings
- Screen/route: `/home`, `/session/:sessionId`, `/session/:sessionId/re-entry`, `/growth`, `/settings`
- Chốt: tap target/VoiceOver/readability, reduce motion, haptic/text fallback

## 3) Mở rộng khi dev sprint bắt đầu

### Quy tắc apply cho từng story
1. Trước khi bắt đầu story, phải chọn đúng row trong map và khóa route/surface.
2. Đánh dấu `done` chỉ khi cả:
   - AC UI của story đạt
   - screen mapping đúng
   - route và navigation đúng
   - behavior rule của màn được giữ (offline/perf/permission/recovery)

### Checklist nhanh cho Reviewer trước khi move sang story tiếp theo
- Home route + tab + SOS CTA đúng như map không?
- Các màn có liên quan story có file export đủ `preview.png` + `screen.html`?
- Trường hợp mặt chưa có màn riêng phải rõ `covered` hoặc `deferred`, không để state mơ hồ.

