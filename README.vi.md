# AI Note

[![English](https://img.shields.io/badge/Language-English-blue)](README.md) [![Tiếng Việt](https://img.shields.io/badge/Language-Tiếng%20Việt-green)](#)

Ứng dụng ghi chú hiện đại với tính năng tóm tắt sử dụng trí tuệ nhân tạo từ Google Gemini.


## Tính năng

- ✏️ Tạo, chỉnh sửa và tổ chức ghi chú với hỗ trợ Markdown
- 🔍 Tìm kiếm toàn văn trên tất cả ghi chú
- 🏷️ Gắn thẻ cho ghi chú để phân loại tốt hơn
- 🌓 Hỗ trợ chế độ sáng và tối
- 🤖 Tạo tóm tắt tự động bằng AI sử dụng Google Gemini
- 🔑 Trích xuất từ khóa từ nội dung ghi chú
- 💻 Hỗ trợ đa nền tảng (Windows, Android, iOS)

## Bắt đầu

### Yêu cầu

- Flutter 3.0 trở lên
- Khóa API Google Gemini

### Cài đặt

1. Clone repository:

```bash
git clone https://github.com/yourusername/ai-note.git
cd ai-note
```

2. Cài đặt các dependencies:

```bash
flutter pub get
```

3. Chạy ứng dụng:

```bash
flutter run
```

### Thiết lập API Key

Để sử dụng tính năng tóm tắt AI, bạn cần một khóa API Google Gemini:

1. Truy cập [Google AI Studio](https://ai.google.dev/)
2. Tạo tài khoản nếu bạn chưa có
3. Điều hướng đến phần "API keys"
4. Tạo một khóa API mới
5. Nhập khóa vào phần cài đặt của ứng dụng

## Sử dụng AI Note

### Tạo ghi chú

- Nhấn nút '+' để tạo ghi chú mới
- Thêm tiêu đề và nội dung
- Sử dụng thanh công cụ markdown để định dạng
- Lưu bằng cách nhấn biểu tượng kiểm

### Tạo tóm tắt

- Mở một ghi chú
- Nhấn vào biểu tượng đũa phép
- AI sẽ tạo tóm tắt dựa trên nội dung ghi chú của bạn
- Xem tóm tắt trong tab Tóm tắt

### Quản lý thẻ

- Sử dụng tùy chọn 'Quản lý thẻ' trong menu ghi chú
- Thêm thẻ mới để tổ chức ghi chú của bạn
- Lọc ghi chú theo thẻ từ màn hình chính

## Chi tiết kỹ thuật

Ứng dụng được xây dựng sử dụng các công nghệ sau:

- **Flutter**: Framework UI
- **Provider**: Quản lý trạng thái
- **SQLite**: Lưu trữ cơ sở dữ liệu cục bộ
- **Google Gemini API**: Tóm tắt văn bản bằng AI
- **Flutter Markdown**: Hiển thị Markdown

## Giấy phép

Dự án này được cấp phép theo Giấy phép MIT - xem file LICENSE để biết chi tiết.

## Lời cảm ơn

- Google Gemini cho khả năng AI
- Đội ngũ Flutter cho framework tuyệt vời
- Tất cả những người đóng góp cho các gói mã nguồn mở được sử dụng trong dự án này

---

*Bạn đang tìm tài liệu này bằng ngôn ngữ khác? Xem [English](README.md)*
