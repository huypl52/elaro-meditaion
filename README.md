# Elaro

**A calm operating system for real-life meditation.**

Elaro giúp người dùng quay về trạng thái bình ổn trong những khoảnh khắc đời thực: trước khi ngủ, sau một cuộc họp nặng, khi đang quá tải, hoặc khi chỉ có 60 giây để hạ nhiệt. Ứng dụng được thiết kế để giảm lựa chọn, bắt đầu nhanh, hoạt động tốt khi offline và tạo cảm giác có người đồng hành mà không biến thiền thành mạng xã hội.

## Vì Sao Elaro Khác

Phần lớn app thiền bắt đầu bằng thư viện lớn, chuỗi ngày, chỉ số và nhiều quyết định. Elaro đi theo hướng ngược lại: mở app là thấy hành động tốt tiếp theo.

- **Single-path home**: tối đa 1-2 hành động chính theo bối cảnh, không dashboard ồn.
- **SOS 60 giây**: flow ổn định nhanh cho lúc căng thẳng, haptic-first, ít chữ, ít thao tác.
- **Reflection không chấm điểm**: phản chiếu tiến triển bằng narrative trend, không score, rank hay leaderboard.
- **Quiet presence**: cảm giác có cộng đồng ở mức aggregate ẩn danh, không chat, không profile, không social graph.
- **Offline-first**: core sessions, timer, growth và nội dung cốt lõi vẫn hữu ích khi không có mạng.
- **Permission-respectful**: luôn có preflight trước system prompt; thiếu sensor hay permission không làm hỏng core flow.

## Trải Nghiệm Cốt Lõi

| Khoảnh khắc | Elaro làm gì |
| --- | --- |
| Tôi đang quá tải | Vào SOS, theo nhịp thở/haptic 60 giây, có lối thoát rõ ràng |
| Tôi muốn ngủ | Gợi ý session tối giản theo bối cảnh, hỗ trợ soundscape và re-entry mềm |
| Tôi quay lại sau gián đoạn | Đón lại nhẹ, không guilt-trip, không streak pressure |
| Tôi muốn thấy mình tiến triển | Hiển thị continuity và reflection theo xu hướng cá nhân |
| Tôi muốn thiền cùng người khác | Cho thấy presence ẩn danh, không tạo áp lực xã hội |

## Nguyên Tắc Sản Phẩm

- Night-calm, low-friction, haptic-first.
- Không gamification, không streak, không score, không leaderboard.
- Presence chỉ aggregate/ẩn danh; không feed, chat, public profile hay follower graph.
- Session timeline là nguồn sự thật cho growth, reflection và recovery state.
- Privacy-by-default cho microphone, health signal, biofeedback và voice journal.
- Elaro không claim chẩn đoán sức khỏe và không thay thế hỗ trợ chuyên môn.

## Trong Repo Này

Repo này chứa tài liệu giới thiệu, artifact thiết kế và source delivery cho Elaro.

| Khu vực | Nội dung |
| --- | --- |
| [`docs/`](docs/) | Quick start, handoff, sprint UI map và tài liệu người dùng |
| [`design-artifacts/`](design-artifacts/) | Artifact thiết kế và UI review export |
| [`apps/mobile/`](apps/mobile/) | Source Flutter mobile khi được restore/duy trì trong repo này |

## Tài Liệu Nên Đọc

- [`docs/quick-start.md`](docs/quick-start.md): lối vào nhanh cho người dùng và developer.
- [`docs/app-user-guide.md`](docs/app-user-guide.md): flow sử dụng chính của app.
- [`docs/ui-dev-handoff.md`](docs/ui-dev-handoff.md): mapping màn hình, route và implementation notes.

## Development Notes

Nếu làm mobile source, chỉ dùng `apps/mobile/` trong repo này làm delivery root. Không lấy một repo local khác làm nguồn delivery.

Khi `apps/mobile` có source Flutter đầy đủ:

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
```

Release build phải bật production define:

```bash
flutter build ios --dart-define=ELARO_RELEASE=true
```

Các guardrail quan trọng:

- Không sửa frozen contract test nếu không có task unfreeze riêng.
- Debug/QA controls phải nằm sau `DevSection`/`DevGate`.
- Không dùng infinite animation.
- Screen/sheet có thể tràn phải scroll được.
- User-facing string mới viết bằng tiếng Việt, trừ các chuỗi đang bị contract khóa.
- Nếu dùng Python scripts, chạy bằng `uv`.

## Current Build Shape

Source Flutter hướng tới Phase-7 structure:

```text
apps/mobile/lib/
  main.dart      # app shell, route table, tab scaffold
  domain/        # domain models and rules
  runtime/       # runtime state, gates, adapters
  features/      # feature-owned UI and behavior
  theme/         # tokens, colors, typography
  components/    # calm UI primitives
```

## License

Proprietary. All rights reserved unless a separate license file is added.
