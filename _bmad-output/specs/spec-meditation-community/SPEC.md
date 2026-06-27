---
id: SPEC-meditation-community
companions:
  - glossary.md
  - ../../planning-artifacts/architecture/architecture-meditation-community-2026-06-24/ARCHITECTURE-SPINE.md
sources:
  - ../planning-artifacts/prds/prd-meditation-community-2026-06-24/prd.md
---

> **Canonical contract.** This SPEC and the files in `companions:` are the complete, preservation-validated contract for what to build, test, and validate. Source documents listed in frontmatter are for traceability only — consult them only if you need narrative rationale or prose color this contract intentionally omits.

# meditation-community

## Why
Đây là một sản phẩm mobile thiền được tạo ra để giải quyết khoảng trống giữa thư viện meditation generic và nhu cầu điều hòa thần kinh trong các khoảnh khắc đời thực. Nó cần giúp người dùng vào đúng phiên nhanh, nhận hỗ trợ phù hợp với bối cảnh và tín hiệu cơ thể khi có thể, đồng thời cảm thấy có cộng đồng đồng hành mà không bị kéo vào một mạng xã hội wellness.

## Capabilities

- **CAP-1**
  - **intent:** Người dùng có thể vào một phiên thiền phù hợp với nhu cầu và trạng thái hiện tại với ma sát chọn lựa tối thiểu.
  - **success:** Từ home hoặc quick-entry flow, người dùng bắt đầu được một phiên phù hợp trong tối đa 2 thao tác, với nội dung được phân loại theo need hoặc transition context.

- **CAP-2**
  - **intent:** Người dùng có thể thực hiện cả phiên thiền cực ngắn, phiên thông thường, SOS flow, và timer tối giản theo cách ổn định trên mobile.
  - **success:** App hỗ trợ micro-session, SOS 60 giây, timer với bell, và gentle re-entry; mỗi loại flow hoàn thành được mà không làm đứt continuity của session tracking.

- **CAP-3**
  - **intent:** Người dùng có thể duy trì continuity cá nhân qua growth map, voice journal, personal ritual, và phản hồi sau phiên.
  - **success:** Sau mỗi phiên, app lưu được tiến trình, cho phép phản hồi hoặc journal riêng tư, và hỗ trợ người dùng tạo hoặc replay ritual cá nhân mà không dùng streak làm cơ chế trung tâm.

- **CAP-4**
  - **intent:** Hệ thống có thể nhận biết Noise Context cơ bản để gợi ý mode, content, hoặc soundscape phù hợp hơn với môi trường thực tế.
  - **success:** App phân loại được ít nhất một tập mức ồn cơ bản và dùng được kết quả đó để thay đổi gợi ý phiên hoặc mode mà không buộc người dùng thao tác chuyên biệt.

- **CAP-5**
  - **intent:** Hệ thống có thể dùng tín hiệu session và tín hiệu sinh lý được cấp quyền để phản chiếu xu hướng cơ thể đang ổn định hơn theo thời gian.
  - **success:** Ngay cả khi không có wearable, app vẫn sinh được reflection cơ bản; khi có tín hiệu như heart rate hoặc HRV, reflection được làm giàu mà không biến thành điểm số thiền tuyệt đối.

- **CAP-6**
  - **intent:** Người dùng có thể cảm nhận sự hiện diện cộng đồng ẩn danh và gửi preset nudge mà không tham gia cơ chế social pressure.
  - **success:** App cho phép tham gia quiet presence session, hiển thị presence ở mức aggregate hoặc bucket, và hỗ trợ mindful nudge preset mà không có chat tự do hay leaderboard.

- **CAP-7**
  - **intent:** Người dùng có thể truy cập một seeded content ecosystem đủ khác biệt gồm curated packs, sound postcards, labels rõ ràng, và lõi offline-ready.
  - **success:** App cung cấp core pack, contextual pack, hoặc sound postcard được gắn label ngữ cảnh rõ, trong đó có một tập nội dung cốt lõi dùng được offline.

## Constraints

- Giá trị cốt lõi của sản phẩm phải còn nguyên ngay cả khi người dùng không có smartwatch hoặc không cấp quyền health data.
- Reflection phải là phản chiếu xu hướng cá nhân, không là chấm điểm khả năng thiền, không là cạnh tranh giữa người dùng.
- Community trong MVP phải giữ mô hình calm-first: không feed, không chat mở, không social graph gây áp lực.
- Microphone, voice journal, và health signals phải theo cơ chế privacy-first và permission-based rõ ràng.
- MVP phải được xác thực bằng Flutter-first mobile scope; không phụ thuộc marketplace creator mở hay AI generation sâu để chứng minh value.
- V1 ưu tiên iOS-first cho go-to-market và advanced signal integrations; Android core experience có thể theo sau sau khi lớp differentiator chính đã được validate trên iOS.

## Non-goals

- Trở thành mạng xã hội wellness đầy đủ trong v1.
- Trở thành health dashboard hoặc công cụ chẩn đoán chất lượng thiền.
- Mở creator marketplace đại trà hoặc UGC ecosystem hoàn chỉnh trong MVP.
- Khóa trải nghiệm chính vào Apple Watch hoặc một nền tảng wearable cụ thể.

## Success signal

Một người dùng mới hoặc quay lại có thể mở app, vào được đúng flow thiền cho khoảnh khắc hiện tại, cảm thấy được hỗ trợ bởi context và continuity cá nhân, và nhận ra rằng tiến triển của họ được phản chiếu nhẹ nhàng mà không bị áp lực thành tích. Khi downstream triển khai xong, sản phẩm phải chứng minh được rằng các differentiator như quiet presence, noise-aware guidance, và reflective biofeedback làm cho v1 khác rõ ràng so với một app thiền generic.

## Assumptions

- V1 là một sản phẩm consumer mobile launch artifact, không phải clinical product hay internal tool.
- Chất lượng tín hiệu health/wearable sẽ khác nhau theo thiết bị và nền tảng, nên reflection phải degrade gracefully khi tín hiệu yếu hoặc không có.

## Open Questions

- Đường ranh monetization của v1 nằm ở đâu giữa core experience và premium differentiators?
