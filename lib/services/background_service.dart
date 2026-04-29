import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tiem_rua_xe/services/sheet_service.dart';

/// Lớp quản lý dịch vụ chạy ngầm của ứng dụng.
class BackgroundService {
  
  /// Khởi tạo cấu hình cho Background Service
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    // Cấu hình thông báo (Notification) cho Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tiem_rua_xe_service', // ID kênh
      'Dịch vụ Rửa Xe Hiền', // Tên hiển thị
      description: 'Giữ cho hệ thống báo tiền luôn hoạt động ngầm.',
      importance: Importance.low, // Độ ưu tiên thấp để không làm phiền nhưng đủ để không bị kill
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart, // Hàm sẽ chạy khi service bắt đầu
        autoStart: false, // Không tự chạy ngay, để người dùng bấm nút mới chạy
        isForegroundMode: true,
        notificationChannelId: 'tiem_rua_xe_service',
        initialNotificationTitle: 'Rửa Xe Hiền',
        initialNotificationContent: 'Hệ thống báo tiền đang sẵn sàng...',
        // Cực kỳ quan trọng cho Android 14: Phải khai báo loại dịch vụ
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  /// Hàm xử lý riêng cho nền của iOS
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }
}

/// ĐÂY LÀ "TRÁI TIM" CỦA VIỆC CHẠY NGẦM
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Đảm bảo các plugin Flutter được khởi tạo trong isolate này
  DartPluginRegistrant.ensureInitialized();

  final SheetService sheetService = SheetService();
  
  // Lắng nghe lệnh từ giao diện (UI) gửi xuống để dừng dịch vụ
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Vòng lặp quét tiền chính thức khi chạy ngầm
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    if (service is AndroidServiceInstance) {
      if (!(await service.isForegroundService())) {
        // Nếu lỡ bị hệ thống đẩy xuống nền quá sâu, nhắc lại thông báo trên thanh trạng thái
        service.setForegroundNotificationInfo(
          title: "Rửa Xe Hiền",
          content: "Đang canh tiền cho bạn...",
        );
      }
    }

    // GỌI LOGIC QUÉT TIỀN & PHÁT LOA
    // Vì SheetService đã được thiết kế độc lập, nó sẽ tự quét và tự kêu loa ở đây
    try {
      await sheetService.fetchAndProcess();
      
      // Gửi dữ liệu về UI (nếu UI đang mở) để cập nhật danh sách hiển thị
      service.invoke('update', {
        "last_check": DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print("Lỗi quét tiền trong nền: $e");
    }
  });
}