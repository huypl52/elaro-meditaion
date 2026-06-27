---
title: meditation-community
status: final
created: 2026-06-24
updated: 2026-06-24
---

# PRD: meditation-community

## 0. Document Purpose
Tài liệu này xác định phạm vi sản phẩm, yêu cầu chức năng, ranh giới MVP và các nguyên tắc chất lượng cho ứng dụng thiền trên mobile `meditation-community`. PRD này dùng cho PM, UX, kiến trúc, và các workflow BMAD downstream như `bmad-spec`, `bmad-ux`, `bmad-create-epics-and-stories`. Tài liệu được xây từ bản chốt tính năng trong `docs/FEATURES_REQUIREMENTS.md`; các quyết định triển khai kỹ thuật sâu hơn sẽ được tách sang tài liệu spec hoặc architecture thay vì nhồi vào PRD.

## 1. Vision
`meditation-community` là một ứng dụng thiền trên mobile giúp người dùng quay về trạng thái bình ổn trong những khoảnh khắc đời thực như trước khi ngủ, sau cuộc họp, khi đang quá tải, hoặc khi cần reset rất nhanh. Sản phẩm không cố trở thành một thư viện audio khổng lồ hay một mạng xã hội về wellness; nó được định vị như một `calm operating system` cho những giây phút thần kinh cần được hạ nhiệt.

Khác biệt cốt lõi của sản phẩm nằm ở 4 điểm: giảm tải chọn lựa, can thiệp đúng thời điểm, phản hồi theo tín hiệu ngữ cảnh và sinh lý khi có thể, và tạo cảm giác đồng hành mà không gây áp lực xã hội. Mục tiêu là giúp người dùng thấy việc thiền trở nên nhẹ hơn, gần hơn với nhịp sống thật, và có thể nhận ra tiến bộ của bản thân mà không bị biến trải nghiệm thành thành tích.

V1 cần đủ mạnh để không bị xem như một app thiền generic: ngoài lõi thư viện và timer, sản phẩm cần có `Live Sangha Presence`, `Environmental Noise Assessment`, `Biofeedback Reflection`, và `Seeded Content Ecosystem` ở mức MVP phù hợp.

## 2. Target User

### 2.1 Jobs To Be Done
- Khi tôi đang căng thẳng hoặc quá tải, tôi muốn vào ngay một phiên ngắn phù hợp mà không phải suy nghĩ nhiều.
- Khi tôi sắp ngủ hoặc vừa thức dậy, tôi muốn có một ritual nhẹ để chuyển trạng thái tâm trí.
- Khi tôi quay lại việc thiền sau thời gian đứt quãng, tôi muốn được đón lại nhẹ nhàng thay vì bị áp lực bởi streak hoặc thành tích.
- Khi tôi thiền thường xuyên, tôi muốn thấy những dấu hiệu cho thấy mình đang ổn định hơn theo thời gian.
- Khi tôi cảm thấy cô đơn trong hành trình này, tôi muốn biết vẫn có người khác đang cùng hiện diện mà không phải tham gia một mạng xã hội ồn ào.
- Khi tôi ở môi trường không lý tưởng như văn phòng, quán cafe, hoặc nhà đông người, tôi muốn app vẫn giúp tôi thiền được theo cách phù hợp.

### 2.2 Non-Users (v1)
- Người dùng muốn một mạng xã hội wellness đầy đủ với chat, feed, creator economy mở, và tương tác công khai.
- Người dùng cần công cụ trị liệu lâm sàng hoặc hỗ trợ khủng hoảng chuyên sâu thay cho chuyên gia.
- Người dùng chủ yếu tìm một health dashboard định lượng sâu, ưu tiên số liệu sinh học hơn trải nghiệm thiền.

### 2.3 Key User Journeys
- **UJ-1. Lan reset trong 60 giây trước khi bùng nổ.**
  - **Persona + context:** Lan, 29 tuổi, làm công việc tri thức, vừa trải qua một chuỗi họp dày và thấy mình sắp mất kiểm soát cảm xúc.
  - **Entry state:** Đang mở điện thoại giữa ngày; không muốn chọn nhiều.
  - **Path:** Mở app, thấy CTA `SOS`, chạm vào, vào ngay flow thở 60 giây với haptic/audio tối giản, hoàn thành xong nhận một phản hồi ngắn và một lựa chọn tiếp theo.
  - **Climax:** Lan cảm thấy mình dịu lại đủ để quay lại công việc thay vì phản ứng bốc đồng.
  - **Resolution:** App ghi nhận phiên, gợi ý một ritual ngắn hoặc một bài follow-up nếu cần.

- **UJ-2. Minh thiền trước khi ngủ trong căn phòng không yên tĩnh.**
  - **Persona + context:** Minh, 34 tuổi, thường khó ngủ vì đầu óc căng và môi trường sống có tiếng ồn nền.
  - **Entry state:** Mở app vào buổi tối từ màn hình chính.
  - **Path:** App gợi ý `trước khi ngủ`, đo nhanh noise context, đề xuất bài phù hợp và soundscape hỗ trợ, Minh bắt đầu phiên 8 phút, kết thúc bằng gentle re-entry.
  - **Climax:** Minh cảm thấy dễ vào trạng thái nghỉ hơn thay vì bực bội vì môi trường.
  - **Resolution:** App lưu xu hướng, dùng cho lần gợi ý tối sau.

- **UJ-3. Huy muốn thấy mình đã cải thiện chứ không chỉ “đã ngồi đủ phút”.**
  - **Persona + context:** Huy, 31 tuổi, đã thiền vài tuần và dùng Apple Watch.
  - **Entry state:** Vừa hoàn thành một phiên thiền tập trung.
  - **Path:** App kết hợp session data, self check-in và wearable signals hiện có để phản chiếu nhẹ nhàng mức độ cơ thể đã ổn định hơn ở cuối phiên.
  - **Climax:** Huy nhìn thấy tiến bộ của chính mình theo trend cá nhân, không bị chấm điểm.
  - **Resolution:** Huy có động lực quay lại vì cảm thấy app giúp anh hiểu mình hơn.

- **UJ-4. Thảo muốn thiền cùng người khác nhưng không muốn social pressure.**
  - **Persona + context:** Thảo, 26 tuổi, muốn cảm giác có cộng đồng đồng hành nhưng ghét feed và tương tác xã hội nhiều.
  - **Entry state:** Mở app vào tối muộn.
  - **Path:** Thảo thấy một quiet session đang có người cùng tham gia, bấm join, thiền xong có thể gửi một preset nudge ẩn danh.
  - **Climax:** Thảo cảm thấy mình đang cùng hiện diện với người khác mà vẫn giữ không gian riêng tư.
  - **Resolution:** App ghi nhận sự tham gia cộng đồng như một lớp hiện diện, không phải thành tích xã hội.

## 3. Glossary
- **Core Pack** — Gói nội dung cốt lõi được ứng dụng phân phối chính thức và hỗ trợ offline trong MVP.
- **Contextual Pack** — Gói nội dung được nhóm theo tình huống cụ thể như trước khi ngủ, sau họp, khi quá tải, hoặc khi môi trường ồn.
- **Gentle Re-entry** — Giai đoạn chuyển tiếp ngắn sau khi phiên thiền kết thúc để người dùng quay lại trạng thái bình thường nhẹ nhàng.
- **Live Sangha Presence** — Lớp hiện diện cộng đồng ẩn danh cho biết đang có người khác cùng thiền theo time block hoặc region bucket.
- **Mindful Nudge** — Tín hiệu động viên định dạng sẵn, ngắn, ẩn danh, không mở thành chat tự do.
- **Noise Context** — Dữ liệu phân loại mức độ ồn môi trường dùng để gợi ý nội dung hoặc mode thiền phù hợp.
- **Personal Ritual** — Chuỗi bước nội dung ngắn do chính người dùng ghép lại cho một mục đích cụ thể.
- **Seeded Content Ecosystem** — Hệ nội dung curated trong MVP gồm official packs, contextual packs, sound postcards, và labeling rõ ràng, chưa mở marketplace đại trà.
- **Session Reflection** — Phản hồi sau phiên dựa trên session pattern, self check-in, noise context, và tín hiệu wearable nếu có.
- **Sound Postcard** — Đơn vị nội dung âm thanh ngắn theo ngữ cảnh cụ thể, thường dùng để thư giãn, tập trung, hoặc chuyển trạng thái.

## 4. Features

### 4.1 Calm Entry and Adaptive Session Selection
**Description:** Ứng dụng phải giúp người dùng bắt đầu phiên thiền với ít ma sát nhất có thể. Home ưu tiên `Single-Path Home`, emotional/energy check-in, `Transition Modes`, và gợi ý nhanh theo nhu cầu. Mục tiêu là giảm tải quyết định thay vì khiến người dùng lạc trong thư viện. Realizes UJ-1, UJ-2.

**Functional Requirements:**

#### FR-1: Single-Path Home
Người dùng có thể mở app và nhìn thấy 1-2 hành động phù hợp nhất theo thời điểm và trạng thái gần nhất. Realizes UJ-1, UJ-2.

**Consequences (testable):**
- Home hiển thị tối đa 2 CTA chính trong trạng thái mặc định.
- CTA có thể thay đổi theo time-of-day, recent session type, hoặc trạng thái check-in gần nhất.
- Người dùng có thể bắt đầu một phiên từ home trong tối đa 2 thao tác.

#### FR-2: Emotional / Energy Check-in
Người dùng có thể chọn nhanh trạng thái cảm xúc hoặc năng lượng trước phiên để app dùng cho gợi ý nội dung. Realizes UJ-1, UJ-2.

**Consequences (testable):**
- Check-in hỗ trợ một tập trạng thái ngắn, dễ chọn nhanh.
- Trạng thái đã chọn được gắn với session hiện tại.
- App có thể dùng trạng thái đã chọn để điều chỉnh gợi ý ngay trong lần dùng hiện tại.

#### FR-3: Need-based and Transition-based Library
Người dùng có thể duyệt nội dung theo nhu cầu và theo ngữ cảnh chuyển trạng thái đời thực. Realizes UJ-2.

**Consequences (testable):**
- Nội dung có taxonomy tối thiểu theo `need`, `duration`, `context`, và `intensity`.
- `Transition Modes` tồn tại như một cách vào nội dung riêng, không chỉ là tag ẩn.
- Người dùng có thể tìm ít nhất một bài phù hợp cho các bối cảnh trọng tâm của MVP như ngủ, reset nhanh, tập trung, và nghỉ giữa giờ.

### 4.2 Session Execution and Recovery Support
**Description:** App cần thực thi phiên thiền ngắn, phiên thường, SOS flow, và timer theo cách đáng tin cậy. Các phiên phải hỗ trợ micro-meditation, timer, chuông, transition, và recovery nhẹ sau khi kết thúc. Realizes UJ-1, UJ-2.

**Functional Requirements:**

#### FR-4: Micro-meditation Sessions
Người dùng có thể bắt đầu các phiên thiền cực ngắn như 20 giây, 45 giây, 90 giây, và 3 phút. Realizes UJ-1.

**Consequences (testable):**
- Thư viện có các session cực ngắn trong MVP.
- Session cực ngắn tải và bắt đầu nhanh hơn session dài thông thường.
- Session cực ngắn vẫn được ghi nhận vào Growth Map.

#### FR-5: SOS Protocol
Người dùng có thể vào ngay một flow cứu nguy trong khoảng 60 giây khi đang căng thẳng hoặc quá tải. Realizes UJ-1.

**Consequences (testable):**
- SOS có điểm vào nổi bật và nhất quán.
- SOS flow hỗ trợ nhịp thở/haptic/audio tối giản ngay trong MVP.
- Sau SOS, app đưa ít nhất một lựa chọn tiếp theo phù hợp như kết thúc, lặp lại, hoặc mở bài follow-up ngắn.

#### FR-6: Minimal Timer and Mindfulness Bell
Người dùng đã quen thiền có thể dùng timer tối giản và chuông chánh niệm. Realizes UJ-2.

**Consequences (testable):**
- Timer cho phép chọn thời lượng cơ bản.
- Chuông có thể phát theo mốc hoặc nhịp định sẵn.
- Timer hoạt động ổn định xuyên suốt một phiên thiền thông thường.

#### FR-7: Gentle Re-entry
Người dùng nhận một pha kết thúc mềm thay vì bị cắt đột ngột sau phiên. Realizes UJ-2.

**Consequences (testable):**
- Ứng dụng có trạng thái kết thúc phiên riêng.
- Hệ thống có thể phát fade audio, prompt ngắn, hoặc haptic chuyển tiếp.
- Người dùng có thể bỏ qua gentle re-entry nếu muốn.

### 4.3 Personal Continuity and Reflection
**Description:** App cần giúp người dùng quay lại đều đặn bằng continuity nhẹ nhàng thay vì áp lực, thông qua Growth Map, voice journal, ritual cá nhân, và Session Reflection. Realizes UJ-2, UJ-3.

**Functional Requirements:**

#### FR-8: Growth Map Without Streak Pressure
Người dùng có thể thấy tiến trình tích lũy của bản thân mà không bị gò bởi streak. Realizes UJ-3.

**Consequences (testable):**
- App hiển thị tổng số phiên và tổng thời lượng tích lũy.
- App không dùng streak làm chỉ số trung tâm của tiến bộ.
- Nội dung phản hồi không guilt-trip người dùng khi họ quay lại sau gián đoạn.

#### FR-9: Hands-free Voice Journal
Người dùng có thể lưu lại cảm nhận sau phiên bằng giọng nói. Realizes UJ-3.

**Consequences (testable):**
- Người dùng có thể bắt đầu ghi một voice journal ngắn sau khi session kết thúc.
- Voice journal được gắn với session tương ứng.
- Voice journal được xem là dữ liệu riêng tư của người dùng.

#### FR-10: Personal Ritual Builder
Người dùng có thể tạo và replay các Personal Ritual của riêng mình. Realizes UJ-2, UJ-3.

**Consequences (testable):**
- Người dùng có thể ghép nhiều bước nội dung thành một ritual.
- Ritual có thể được lưu với tên riêng và gọi lại nhanh.
- Ít nhất một ritual có thể bắt đầu từ home hoặc vùng truy cập nhanh.

#### FR-11: Session Reflection
Người dùng nhận phản hồi sau phiên dựa trên session pattern và tín hiệu hiện có để hiểu tiến triển của bản thân. Realizes UJ-3.

**Consequences (testable):**
- App có thể sinh phản hồi sau phiên ngay cả khi không có wearable.
- Nếu có wearable, app có thể tăng chất lượng phản hồi bằng heart rate, HRV, hoặc tín hiệu tương đương đang được hỗ trợ.
- Phản hồi phải theo dạng reflective trend, không dùng điểm số thiền tuyệt đối.

### 4.4 Environmental and Biofeedback Awareness
**Description:** App cần biết bối cảnh môi trường và phản ánh tín hiệu sinh lý ở mức đủ hữu ích mà không biến sản phẩm thành dashboard y tế. Đây là phần khác biệt quan trọng của MVP. Realizes UJ-2, UJ-3.

**Functional Requirements:**

#### FR-12: Environmental Noise Assessment
Ứng dụng có thể đánh giá mức độ ồn của môi trường trước hoặc trong phiên để điều chỉnh gợi ý nội dung hoặc mode. Realizes UJ-2.

**Consequences (testable):**
- Hệ thống phân loại được ít nhất một tập mức cảm nhận/ồn cơ bản (ví dụ yên tĩnh, vừa, ồn). **Mapping code:** `_CheckinState {calm, low, overload}` hiển thị thành `manual-calm` / `manual-low` / `manual-overload` (≈ yên tĩnh / vừa–mệt / quá tải–ồn) — đây là vocab thực tế trong code thay cho `yên tĩnh / vừa / ồn` ở spec cũ.
- Noise Context có thể ảnh hưởng đến gợi ý bài, soundscape, hoặc mode thiền.
- App không yêu cầu người dùng phải vào một màn hình chuyên biệt để hưởng lợi từ Noise Context.

#### FR-13: Biofeedback Reflection Inputs
Ứng dụng có thể dùng tín hiệu sinh lý được người dùng cho phép để làm giàu Session Reflection. Realizes UJ-3.

**Consequences (testable):**
- Hệ thống hoạt động bình thường nếu người dùng không cấp quyền health/wearable.
- Khi người dùng cấp quyền và có thiết bị hỗ trợ, app có thể đọc được tập tín hiệu khả dụng như heart rate, HRV, respiratory rate, hoặc motion/stillness tùy nền tảng.
- Biofeedback được dùng để phản chiếu xu hướng ổn định cá nhân, không dùng để xếp hạng người dùng.

**Feature-specific NFRs:**
- Privacy by default cho toàn bộ tín hiệu môi trường và biofeedback.
- Phải giải thích rõ dữ liệu nào được dùng, dùng để làm gì, và người dùng có thể tắt ở đâu.

### 4.5 Quiet Community Presence
**Description:** Sản phẩm cần tạo cảm giác hiện diện cộng đồng mà vẫn giữ không gian yên tĩnh. `Live Sangha Presence` trong MVP phải là community nhẹ, ẩn danh, không feed, không chat mở, không social pressure. Realizes UJ-4.

**Functional Requirements:**

#### FR-14: Anonymous Presence
Người dùng có thể thấy có người khác đang cùng thiền theo một quiet session hoặc time block mà không lộ danh tính cá nhân. Realizes UJ-4.

**Consequences (testable):**
- Presence được biểu diễn ở mức aggregate hoặc bucket, không yêu cầu profile cá nhân công khai.
- Người dùng có thể tham gia một quiet session đang hiện hữu.
- Presence không phụ thuộc vào việc follow người khác.

#### FR-15: Mindful Nudges
Người dùng có thể gửi hoặc nhận Mindful Nudge ở dạng preset ngắn và ẩn danh. Realizes UJ-4.

**Consequences (testable):**
- Nudge là preset hữu hạn, không phải chat tự do.
- Người dùng có thể tắt hoặc bỏ qua nudge.
- Nudge không phá flow thiền của người dùng đang ở trong session.

### 4.6 Seeded Content Ecosystem
**Description:** MVP cần có một hệ nội dung mở rộng đủ khác biệt nhưng vẫn được kiểm soát chất lượng. V1 ưu tiên content curated hơn là marketplace mở. Realizes UJ-2, UJ-4.

**Functional Requirements:**

#### FR-16: Curated Content Packs
Người dùng có thể truy cập các Core Pack, Contextual Pack, và Sound Postcard được app curated. Realizes UJ-2.

**Consequences (testable):**
- Mỗi đơn vị nội dung có label tối thiểu về type, context, duration, và tone/use case.
- Nội dung curated được tách biệt rõ khỏi các lớp mở rộng khác.
- Người dùng có thể duyệt hoặc được gợi ý pack phù hợp từ home hoặc thư viện.

#### FR-17: Offline-first Core Packs
Người dùng có thể dùng các gói nội dung cốt lõi ngay cả khi không có mạng. Realizes UJ-2.

**Consequences (testable):**
- Có tập nội dung được đánh dấu sẵn cho offline use.
- App thể hiện rõ nội dung nào đã sẵn trên máy và nội dung nào cần mạng.
- Trải nghiệm phát nội dung offline không phụ thuộc vào presence/community features.

## 5. Non-Goals (Explicit)
- Không xây dựng mạng xã hội wellness đầy đủ trong v1.
- Không mở creator marketplace đại trà trong MVP.
- Không thay thế trị liệu lâm sàng, tư vấn tâm lý, hoặc hỗ trợ khủng hoảng chuyên nghiệp.
- Không biến trải nghiệm thiền thành health dashboard nặng hoặc bảng điểm hiệu suất.
- Không khóa giá trị cốt lõi của app vào việc người dùng phải có Apple Watch hoặc smartwatch.
- Không cố cá nhân hóa bằng AI tạo sinh sâu trong MVP nếu chưa chứng minh được nhu cầu và độ tin cậy.

## 6. MVP Scope

### 6.1 In Scope
- Single-Path Home
- Meditation Library by Need
- Micro-meditation sessions
- SOS Protocol
- Minimal Timer + Mindfulness Bell
- Growth Map
- Emotional / Energy Check-in
- Transition Modes
- Gentle Re-entry
- Hands-free Voice Journal
- Personal Ritual Builder
- Session Reflection cơ bản
- Environmental Noise Assessment cơ bản
- Biofeedback Reflection ở mức reflective trend
- Live Sangha Presence ở mức anonymous quiet presence
- Mindful Nudges dạng preset
- Seeded Content Ecosystem ở mức curated packs + labels
- Offline-first Core Packs

### 6.2 Out of Scope for MVP
- Creator upload công khai và marketplace mở. Lý do: chi phí moderation và nguy cơ loãng định vị.
- Feed xã hội, comment, group chat, follow graph đầy đủ. Lý do: đi ngược định vị calm-first.
- Chấm điểm khả năng thiền hoặc xếp hạng sinh học giữa người dùng. Lý do: tạo áp lực và overclaim.
- AI tailored session sinh tự động sâu theo prompt mở. Deferred sang giai đoạn Premium sau khi lõi đã vững.
- Realtime coaching phức tạp dựa trên wearable trong từng giây của phiên. Deferred do rủi ro kỹ thuật và trải nghiệm.
- Watch standalone experience đầy đủ. `[NOTE FOR PM]` Có thể cân nhắc sau khi validated được nhu cầu từ nhóm iOS power users.

## 7. Success Metrics

**Primary**
- **SM-1**: Trong 30 ngày đầu sau phát hành beta, ít nhất 35% người dùng kích hoạt hoàn thành từ 3 phiên trở lên trong tuần đầu. Validates FR-1, FR-3, FR-4, FR-5.
- **SM-2**: Ít nhất 40% số phiên được khởi chạy từ home hoặc quick-entry flows thay vì duyệt sâu trong thư viện. Validates FR-1, FR-5.
- **SM-3**: Ít nhất 25% người dùng hoạt động tuần dùng tối thiểu một trong các differentiators của MVP: Live Sangha Presence, Noise Context, hoặc Session Reflection có biofeedback/context signal. Validates FR-11, FR-12, FR-13, FR-14.

**Secondary**
- **SM-4**: Tối thiểu 20% người dùng hoạt động tuần tạo hoặc lưu ít nhất một Personal Ritual trong 30 ngày đầu. Validates FR-10.
- **SM-5**: Tối thiểu 30% người dùng hoàn thành một session tiếp theo trong vòng 7 ngày sau lần dùng SOS đầu tiên. Validates FR-5.
- **SM-6**: Tối thiểu 25% người dùng hoạt động tuần sử dụng nội dung offline hoặc curated pack được gợi ý theo context. Validates FR-16, FR-17.

**Counter-metrics (do not optimize)**
- **SM-C1**: Không tối ưu số phút ngồi thiền trung bình bằng cách đẩy session dài nếu completion rate và tuần quay lại giảm. Counterbalances SM-1.
- **SM-C2**: Không tối ưu engagement community bằng cách tăng notification hoặc social prompts gây áp lực. Counterbalances SM-3.
- **SM-C3**: Không tối ưu Session Reflection theo hướng làm người dùng hiểu nhầm rằng app đang chẩn đoán sức khỏe tâm thần hoặc chấm điểm khả năng thiền. Counterbalances SM-3.

## 8. Open Questions
1. Tập wearable/health integrations chính thức cho v1 là Apple Health + Apple Watch trước, hay sẽ có Android Health Connect ngay trong cùng phase đầu tiên?
2. Quiet presence sẽ được biểu diễn chủ yếu theo region bucket, time block, hay themed rooms?
3. Seeded Content Ecosystem trong v1 sẽ do team tự sản xuất hoàn toàn, hay có thêm curated partner content ngay từ đầu?
4. Mức độ local processing nào là bắt buộc cho voice journal, noise assessment, và biofeedback-derived reflection?
5. Mô hình monetization của v1 là freemium, trial-to-subscription, hay premium-only? [ASSUMPTION: freemium with premium upsell is likely, but not yet confirmed.]

## 9. Assumptions Index
- §1 Vision — `[ASSUMPTION: V1 needs differentiators in MVP rather than post-MVP to avoid becoming a generic meditation app.]`
- §4.4 Environmental and Biofeedback Awareness — `[ASSUMPTION: biofeedback access quality will vary by device and permissions; reflection quality degrades gracefully.]`
- §6.2 Out of Scope for MVP — `[ASSUMPTION: full watch standalone experience is not required to validate core product value.]`
- §12 Platform — `[DECISION: V1 is iOS-first; Android remains in scope for the core experience after iOS validation or in a later delivery phase.]`
- §8 Open Questions #5 — `[ASSUMPTION: v1 monetization will likely follow a freemium-to-premium model.]`

## 10. Cross-Cutting NFRs
- **Privacy:** Người dùng phải kiểm soát rõ microphone, health data, voice journal, và mọi nguồn dữ liệu nhạy cảm; dữ liệu nào dùng để reflection phải được giải thích minh bạch.
- **Reliability:** Session playback, timer, SOS, và completion logging phải ổn định trong điều kiện mobile thông thường.
- **Performance:** Các quick-entry flow như home recommendation và SOS phải vào được phiên với độ trễ thấp đủ để không làm mất tác dụng calm-first.
- **Accessibility:** Session cốt lõi phải dùng được trong bối cảnh người dùng không tiện nhìn màn hình lâu hoặc không muốn nghe audio liên tục.
- **Safety:** App phải có ranh giới rõ rằng đây không phải công cụ điều trị hoặc hỗ trợ khủng hoảng chuyên nghiệp.

## 11. Constraints and Guardrails

### 11.1 Safety
- Không viết copy khiến người dùng tin rằng ứng dụng có thể xác nhận chính xác chất lượng thiền của họ.
- Không dùng gamification gây áp lực cho user đang ở trạng thái nhạy cảm.
- Các flow liên quan khủng hoảng hoặc distress cao phải có boundary rõ và hướng dẫn tìm hỗ trợ phù hợp nếu cần.

### 11.2 Privacy
- Noise Context và wearable signals chỉ được dùng khi người dùng cấp quyền rõ ràng.
- Voice journal mặc định được coi là dữ liệu riêng tư.
- Session Reflection phải ưu tiên cách diễn đạt tổng hợp, tránh phơi bày quá chi tiết dữ liệu sinh học nếu không thật sự cần.

### 11.3 Cost
- MVP ưu tiên curated ecosystem thay vì UGC full để kiểm soát moderation cost.
- Advanced AI generation và realtime coaching sâu không thuộc chi phí bắt buộc của MVP.

## 12. Platform
- V1 là ứng dụng mobile build bằng Flutter.
- Go-to-market của v1 ưu tiên iOS-first để tập trung chất lượng trải nghiệm, wearable integrations, và validation của lớp biofeedback/noise-aware differentiators trên Apple stack trước.
- Core experience phải hoạt động tốt mà không phụ thuộc bắt buộc vào wearable.
- Android là hướng mở rộng kế tiếp cho core experience, nhưng không là điều kiện blocking để phát hành và học từ v1.
- Health/wearable-enhanced reflection là lớp tăng cường khi nền tảng và quyền truy cập cho phép.

## 13. Monetization
- PRD này giả định v1 sẽ cần một lớp giá trị đủ mạnh để hỗ trợ subscription hoặc premium upsell.
- Các differentiators có tiềm năng monetization cao gồm curated content ecosystem chất lượng, reflection nâng cao, biofeedback-enhanced experience, và các lớp cộng đồng yên tĩnh có chọn lọc.
- Mô hình giá và paywall cụ thể cần được chốt ở tài liệu business/monetization riêng hoặc bản update PRD tiếp theo.
