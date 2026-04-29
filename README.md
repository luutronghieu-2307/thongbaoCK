# 🚗 App Báo Tiền Rửa Xe Hiền (Bản Chạy Ngầm)

Đây là dự án Flutter giúp tự động quét giao dịch từ Google Sheets và phát thông báo giọng nói tiếng Việt. Ứng dụng được tối ưu để chạy ngầm hoàn toàn trên Android 14, đặc biệt phù hợp cho thiết bị Vsmart Joy 4.

## 🚀 Quy trình khôi phục dự án

Các bước dưới đây cần thực hiện đúng thứ tự nếu bạn vừa `git pull` code về máy và muốn chạy lại dự án trong Dev Container.

### 1. Mở dự án trong môi trường Docker

Mở thư mục dự án bằng VS Code:

```bash
code .
```

Bước quan trọng: nhìn xuống góc dưới cùng bên trái, nếu thấy thông báo `Reopen in Container` thì hãy nhấn vào đó.

Nếu không thấy, nhấn `Ctrl + Shift + P` (hoặc `F1`), gõ `Dev Containers: Reopen in Container` rồi nhấn `Enter`.

Đợi VS Code khởi động môi trường Docker. Khi xong, Terminal của bạn sẽ hiển thị tên người dùng là `root` hoặc `node` thay vì tên máy tính của bạn.

### 2. Cài đặt thư viện

Trong Terminal của VS Code đã ở trong Container, chạy lệnh:

```bash
flutter pub get
```

### 3. Kết nối điện thoại Joy 4

Vì Flutter chạy trong Docker, bạn cần cấp quyền cho Docker sử dụng cổng USB của máy thật.

Trên máy thật (Host - Pop!_OS), chạy:

```bash
adb kill-server
```

Quay lại Terminal của VS Code trong Docker, chạy tiếp:

```bash
# Cấp quyền truy cập bus USB cho Docker
sudo chmod -R 777 /dev/bus/usb

# Khởi động lại ADB bên trong Docker
adb start-server

# Kiểm tra thiết bị
adb devices
```

Nếu kết quả hiển thị `BKB00297175 device` thì bạn đã kết nối thành công.

## 🛠 Cấu hình và chạy app

### Chạy debug

```bash
flutter run
```

### Build APK bản cài đặt chính thức

Thiết bị Joy 4 dùng chip 64-bit, nên build theo ABI sau:

```bash
flutter build apk --release --split-per-abi
```

File cài đặt sẽ nằm tại:

```text
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## 📝 Lưu ý về Google Sheets và ScriptHieu

- ID Sheets: copy đoạn mã giữa `/d/` và `/edit/` trên trình duyệt, sau đó dán vào phần Cài đặt trong app.
- Quyền chia sẻ: Sheet phải ở chế độ `Bất kỳ ai có liên kết đều có thể xem`.
- SePay Webhook: dùng file `sepay_webhook.gs` đã lược bỏ Discord, dán vào Apps Script của Sheet để nhận dữ liệu từ ngân hàng.

## ⚠️ Tối ưu cho Vsmart Joy 4

Để app chạy ngầm không bị tắt, hãy thiết lập:

1. Vào Cài đặt hệ thống -> Ứng dụng -> Tiệm Rửa Xe.
2. Chọn Pin -> đặt thành `Không hạn chế` (Unrestricted).
3. Đảm bảo Wi-Fi được đặt ở chế độ `Luôn bật khi màn hình tắt`.

## 👨‍💻 Tác giả

Dự án được thực hiện bởi Luu Trong Hieu
