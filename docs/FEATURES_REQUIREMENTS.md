
## BẢN CHỐT TÍNH NĂNG CUỐI CÙNG

### 1. Định vị sản phẩm

Ứng dụng là một `mobile meditation companion` tập trung vào 4 nguyên tắc:

1. `Ít phải chọn`: giảm tải nhận thức, giúp người dùng vào bài phù hợp nhanh nhất.
2. `Can thiệp đúng lúc`: hỗ trợ theo trạng thái và bối cảnh thực tế trong ngày.
3. `Không tạo áp lực thành tích`: không đẩy streak, leaderboard hay cảm giác tội lỗi.
4. `Riêng tư và dịu`: ưu tiên trải nghiệm an toàn, nhẹ nhàng, tôn trọng dữ liệu cá nhân.

### 2. Phạm vi MVP

Toàn bộ các tính năng dưới đây đều thuộc MVP. Trong đó, MVP được chia thành 2 lớp: `MVP Core Experience` và `MVP Differentiators`.

#### 2.1. MVP Core Experience

Đây là lớp trải nghiệm cốt lõi cần có để ra phiên bản đầu tiên bằng Flutter.

1. **Single-Path Home**
   Màn hình chính chỉ hiển thị 1-2 hành động phù hợp nhất theo thời điểm và trạng thái hiện tại.

2. **Meditation Library by Need**
   Thư viện thiền phân loại theo nhu cầu thực tế như: ngủ, giảm lo âu, reset nhanh, tập trung, nghỉ giữa giờ, đau nhức nhẹ.

3. **Micro-meditation Library**
   Bộ phiên cực ngắn `20 giây`, `45 giây`, `90 giây`, `3 phút` để người dùng dễ quay lại nhiều lần trong ngày.

4. **SOS Protocol**
   Một nút cứu nguy luôn hiện hữu, cho phép vào ngay bài thở/hạ nhịp trong `60 giây`.

5. **Minimal Timer + Mindfulness Bell**
   Đồng hồ thiền tối giản cho người đã quen thiền, có chuông báo nhịp hoặc chuông nhắc quay về hiện tại.

6. **Growth Map**
   Theo dõi tổng số phiên, tổng thời gian và số lần quay lại, thay vì dùng streak.

7. **Emotional / Energy Check-in**
   Check-in nhanh trước phiên với các trạng thái như: `căng`, `mệt`, `đơ`, `buồn ngủ`, `khó tập trung`.

8. **Transition Modes**
   Các bài thiền theo tình huống đời thực như: `trước khi ngủ`, `sau cuộc họp`, `vừa thức dậy`, `sau khi cãi nhau`, `trước khi trả lời tin nhắn khó`.

9. **Gentle Re-entry**
   Kết thúc buổi thiền bằng một đoạn chuyển tiếp ngắn để người dùng quay lại trạng thái bình thường nhẹ nhàng hơn.

10. **Hands-free Voice Journal**
    Người dùng có thể nói nhanh cảm nhận sau buổi thiền thay vì phải gõ tay.

11. **Personal Ritual Builder**
    Cho phép người dùng tự tạo ritual cá nhân bằng cách ghép các bước ngắn như thở, body scan, journal.

12. **Offline-first Core Packs**
    Tải sẵn các gói nội dung cốt lõi để dùng được khi offline.

#### 2.2. MVP Differentiators

Đây là lớp tính năng giúp sản phẩm khác biệt rõ ràng so với các app thiền phổ biến trên thị trường, và vẫn thuộc MVP ngay từ bản đầu.

1. **Live Sangha Presence**
    Hiển thị sự hiện diện ẩn danh của những người đang cùng thiền theo khung giờ hoặc nhóm khu vực, giúp tạo cảm giác đồng hành mà không biến trải nghiệm thành mạng xã hội.

2. **Seeded Content Ecosystem**
    Trong MVP, hệ nội dung mở rộng ở mức curated gồm official packs, contextual packs, sound postcards và nhãn nội dung rõ ràng; chưa mở creator marketplace đại trà.

3. **Environmental Noise Assessment**
    Đánh giá mức độ ồn của môi trường trước hoặc trong phiên để gợi ý bài thiền, soundscape, hoặc chế độ phù hợp.

4. **Biofeedback Reflection**
    Nếu người dùng cho phép và có thiết bị hỗ trợ, ứng dụng sử dụng các tín hiệu như nhịp tim, HRV, nhịp thở hoặc mức độ cử động trong phiên để phản chiếu nhẹ nhàng mức độ cơ thể đang ổn định lại, giúp người dùng thấy tiến bộ của bản thân theo thời gian mà không biến trải nghiệm thành chấm điểm hay cạnh tranh.

### 3. Phạm vi V2

Đây là nhóm tính năng nên phát triển sau khi MVP đã có trải nghiệm ổn định.

1. **Adaptive Daily Path**
   Ứng dụng tự đề xuất bài phù hợp theo giờ trong ngày, trạng thái và lịch sử sử dụng.

2. **Silent-first Mode**
   Chế độ không cần voice, chỉ dùng rung, animation thở và chữ ngắn.

3. **Adaptive Environment Support**
   Mở rộng đánh giá môi trường từ MVP để tinh chỉnh đề xuất nội dung và chế độ thiền theo ngữ cảnh sử dụng thực tế.

4. **Companion Soundscapes**
   Các lớp âm thanh hỗ trợ như mưa, brown noise, white noise, quán cafe, rừng.

5. **Recovery Plans**
   Nếu người dùng hay dùng SOS hoặc bỏ giữa chừng, app gợi ý plan hồi phục ngắn hạn thay vì chỉ gợi ý từng bài lẻ.

6. **Post-session Integration**
   Sau buổi thiền, app gợi ý một hành động nhỏ tiếp theo như uống nước, đi bộ ngắn, hoặc viết một câu.

7. **Private Reflection Timeline**
   Dòng thời gian phản chiếu vài khoảnh khắc hoặc xu hướng cảm xúc đáng nhớ, không biến thành dashboard nặng.

8. **Lock-screen / Widget / Watch Entry**
   Bắt đầu nhanh các phiên ngắn từ màn hình khóa, widget hoặc smartwatch.

### 4. Phạm vi Premium / Differentiators

Đây là các tính năng tạo khác biệt mạnh và có thể dùng cho gói trả phí.

1. **AI Tailored Sessions**
   Người dùng nhập hoặc nói bối cảnh hiện tại, hệ thống tạo phiên thiền ngắn phù hợp ngữ cảnh đó.

2. **Private Distill Journal**
   Hệ thống tóm tắt các ý chính từ voice journal, ưu tiên xử lý trên thiết bị nếu khả thi.

3. **Advanced Biofeedback Integration**
   Tích hợp sâu hơn với Apple Health / Google Fit / smartwatch để phản chiếu tín hiệu cơ thể như nhịp tim, HRV, nhịp thở và xu hướng ổn định trong phiên.

4. **Settling Curve**
   Một chỉ số mềm phản ánh mức độ cơ thể ổn định lại sau buổi thiền, không gamify.

5. **AI Meditation Companion**
   Một lớp check-in ngắn trước phiên để cá nhân hóa nội dung, nhưng không biến app thành chatbot ồn ào.

### 5. Phạm vi Community

Các tính năng cộng đồng chỉ nên triển khai theo hướng hiện diện yên tĩnh, không tạo áp lực xã hội.

1. **Live Sangha Presence Expansion**
   Mở rộng trải nghiệm hiện diện cộng đồng từ MVP với nhiều khung giờ, ngữ cảnh và cách tham gia hơn, vẫn giữ nguyên tính ẩn danh.

2. **Mindful Nudges**
   Các tín hiệu động viên ngắn, định dạng sẵn, không mở thành chat tự do.

3. **Silent Garden**
   Mỗi phiên thiền đóng góp vào một không gian chung mang tính biểu tượng.

4. **Shared Quiet Hours**
   Các khung giờ thiền chung lặp lại theo múi giờ hoặc chủ đề.

5. **Family / Pair Mode**
   Cho phép cùng hiện diện với người thân hoặc bạn đồng hành mà không chia sẻ dữ liệu chi tiết.

### 6. Phạm vi Creator / Content Ecosystem

Nhóm tính năng này chỉ nên mở khi đã có nền tảng nội dung và kiểm duyệt đủ tốt.

1. **Creator Studio**
   Cho phép cộng đồng hoặc creator được mời upload audio thiền hoặc sound postcards.

2. **Community vs Official Separation**
   Tách rõ nội dung chính thức/premium và nội dung cộng đồng.

3. **AI Moderation + Transcript Scan**
   Tự động bóc băng và rà soát nội dung vi phạm.

4. **Context Labels**
   Gắn nhãn rõ cho nội dung: có nhạc, không nhạc, dài/ngắn, phù hợp người mới, phù hợp trước khi ngủ, v.v.

### 7. Safety, Trust, Privacy

Đây là lớp nguyên tắc bắt buộc, áp dụng xuyên suốt toàn bộ sản phẩm.

1. **Crisis Boundary Design**
   Nêu rõ ứng dụng không thay thế hỗ trợ y tế/tâm lý chuyên môn, và có hướng dẫn khi người dùng ở trạng thái khẩn cấp.

2. **Anti-perfection Design**
   Trải nghiệm và câu chữ phải giảm cảm giác áp lực, nhấn mạnh việc quay lại là đủ.

3. **Privacy-first Controls**
   Người dùng phải kiểm soát rõ các quyền liên quan đến microphone, health data, voice journal, AI personalization.

### 8. Kết luận chốt scope

Sản phẩm nên triển khai theo thứ tự:

1. `MVP`: giải quyết nhu cầu thiền hằng ngày với UX cực đơn giản, dễ quay lại.
2. `V2`: tăng cá nhân hóa theo bối cảnh và thói quen.
3. `Premium`: mở rộng AI, biofeedback và wearable integration để tạo khác biệt.
4. `Community`: chỉ triển khai theo hướng yên tĩnh, ẩn danh, không mang tính mạng xã hội.

### 9. Flutter Implementation Scope cho MVP

Phần này dùng để chốt phạm vi triển khai kỹ thuật cho bản đầu bằng Flutter.

#### 9.1. MVP Core Experience

1. **Single-Path Home**
   Flutter app cần một màn hình home tối giản, render nhanh, ưu tiên 1-2 CTA chính theo thời điểm trong ngày và trạng thái gần nhất của người dùng.

2. **Meditation Library by Need**
   Cần hệ thống phân loại nội dung theo `need`, `duration`, `intensity`, `context label`. Dữ liệu có thể đi từ JSON/local seed hoặc CMS đơn giản ở giai đoạn đầu.

3. **Micro-meditation Library**
   Cần hỗ trợ playback ổn định cho các phiên cực ngắn, chuyển đổi nhanh giữa các phiên, resume tốt và latency thấp khi bắt đầu.

4. **SOS Protocol**
   Cần một luồng vào nhanh trong 1-2 thao tác, ưu tiên preload audio/haptic pattern để giảm delay khi người dùng đang căng thẳng.

5. **Minimal Timer + Mindfulness Bell**
   Cần timer engine ổn định ở foreground/background, hỗ trợ chuông theo mốc thời gian và rung nhịp cơ bản.

6. **Growth Map**
   Chỉ cần event tracking nội bộ ở mức nhẹ: số phiên, tổng thời gian, số lần quay lại, phân bố theo loại phiên. Không cần dashboard nặng.

7. **Emotional / Energy Check-in**
   Cần UI chọn trạng thái thật nhanh trước phiên và lưu được để dùng cho recommendation nội bộ ở mức cơ bản.

8. **Transition Modes**
   Cần taxonomy nội dung theo ngữ cảnh đời thực, đồng thời home logic phải biết map thời điểm hoặc trạng thái sang các mode này.

9. **Gentle Re-entry**
   Cần state kết thúc phiên riêng, hỗ trợ fade audio, haptic nhẹ, visual transition hoặc prompt ngắn sau buổi thiền.

10. **Hands-free Voice Journal**
    Cần ghi âm ngắn sau phiên, lưu private, và có thể giữ bản audio raw trước khi thêm lớp AI ở giai đoạn sau.

11. **Personal Ritual Builder**
    Cần cho phép user ghép vài block nội dung thành ritual cá nhân, lưu local/cloud và replay nhanh.

12. **Offline-first Core Packs**
    Cần download manager cơ bản, cache nội dung audio/metadata và xác định rõ gói nào luôn sẵn offline.

#### 9.2. MVP Differentiators

1. **Live Sangha Presence**
   MVP chỉ cần bản `lite`: hiện diện ẩn danh theo time block hoặc region bucket, join một quiet session, và gửi preset nudges. Không cần chat, profile xã hội, comment hay leaderboard.

2. **Seeded Content Ecosystem**
   MVP chỉ cần curated ecosystem: official packs, contextual packs, sound postcards, content labels, phân tách rõ nội dung chính thức và nội dung mở rộng. Chưa cần user-generated upload đại trà.

3. **Environmental Noise Assessment**
   MVP chỉ cần đo mức ồn cơ bản trước hoặc trong phiên, phân loại ít mức như `yên tĩnh`, `vừa`, `ồn`, rồi dùng để gợi ý content hoặc soundscape phù hợp.

4. **Biofeedback Reflection**
   MVP chỉ cần reflection nhẹ dựa trên tín hiệu hiện có. Nếu không có wearable, app vẫn phải hoạt động bình thường với self check-in, thời lượng phiên, completion pattern và noise context. Nếu có wearable, app có thể dùng thêm heart rate, HRV, respiratory rate hoặc motion signals tùy thiết bị hỗ trợ.

#### 9.3. Native / Platform Integrations dự kiến

1. **Flutter-only đủ cho**
   UI, navigation, local state, content library, ritual builder, growth map, playback orchestration cơ bản.

2. **Cần native bridge hoặc platform API cho**
   audio session handling, microphone noise sampling, advanced background playback, health data access, wearable signals, haptics nâng cao.

3. **iOS / Apple stack**
   Apple Health, Apple Watch / watchOS, heart rate, HRV, respiratory metrics nếu nền tảng cho phép và người dùng cấp quyền.

4. **Android stack**
   Android Health Connect và wearable integrations tương đương nên được xem là hướng mở rộng tương thích, tránh để trải nghiệm lõi bị khóa vào riêng Apple ecosystem.

### 10. Spec chi tiết cho Biofeedback Reflection

Đây là tính năng nhạy cảm và dễ bị hiểu sai, nên cần chốt rất rõ ngay từ tài liệu.

#### 10.1. Mục tiêu

Mục tiêu của tính năng này là `phản chiếu nhẹ nhàng` các dấu hiệu cho thấy cơ thể đang dần ổn định hơn trong quá trình thiền, giúp người dùng nhận ra tiến bộ của bản thân theo thời gian.

Tính năng này không nhằm:

1. chấm điểm chất lượng thiền một cách tuyệt đối
2. khẳng định khoa học rằng người dùng đã đạt trạng thái tĩnh tâm
3. tạo cạnh tranh, xếp hạng hoặc áp lực thành tích

#### 10.2. Tín hiệu đầu vào

Ứng dụng có thể sử dụng các nguồn tín hiệu sau:

1. **Always available**
   self check-in trước và sau phiên, thời lượng phiên, completion pattern, số lần bỏ giữa chừng, loại nội dung đã chọn, noise context.

2. **Nếu có wearable / health integration**
   heart rate, HRV, respiratory rate, motion/stillness, sleep/activity context từ Apple Health hoặc nền tảng tương đương.

#### 10.3. Cách phản hồi cho người dùng

Phản hồi phải theo kiểu mềm, cá nhân hóa theo chính người đó, ví dụ:

1. `Cơ thể bạn dịu lại nhanh hơn so với vài phiên gần đây`
2. `Hôm nay dù môi trường khá ồn, nhịp của bạn vẫn ổn định hơn về cuối phiên`
3. `Phiên ngắn nhưng vẫn cho thấy dấu hiệu phục hồi tích cực`

Không dùng:

1. điểm số 100
2. xếp hạng
3. huy hiệu thành tích sinh học
4. câu khẳng định tuyệt đối như `bạn tập trung 82%`

#### 10.4. Nguyên tắc UX

1. `Reflect, not judge`
   Chỉ phản chiếu xu hướng, không phán xét.

2. `Trend, not score`
   Ưu tiên xu hướng theo thời gian, không ưu tiên điểm số đơn lẻ.

3. `Personal baseline, not comparison`
   Chỉ so với baseline của chính người dùng, không so với cộng đồng.

4. `Calm progress, not performance`
   Mục tiêu là giúp người dùng thấy mình đang ổn định hơn, không phải thi đua thành tích sức khỏe.

#### 10.5. Scope MVP cho Biofeedback Reflection

1. nếu không có wearable: vẫn có reflection cơ bản từ check-in, thời lượng phiên, pattern hoàn thành và noise context
2. nếu có wearable: ưu tiên heart rate và HRV trước, các tín hiệu khác là mở rộng
3. không yêu cầu dashboard y khoa phức tạp trong MVP
4. không yêu cầu realtime coaching quá sâu trong MVP
5. không để tính năng này làm cho app mất giá trị nếu người dùng không có smartwatch
