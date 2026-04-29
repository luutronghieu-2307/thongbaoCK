import 'package:flutter/material.dart';
import 'package:tiem_rua_xe/services/background_service.dart'; // Import dịch vụ chạy ngầm
import 'package:tiem_rua_xe/ui/pages/home_page.dart';

Future<void> main() async {
  // Đảm bảo Flutter đã sẵn sàng trước khi khởi tạo dịch vụ
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo cấu hình cho dịch vụ chạy ngầm (nhưng chưa cho chạy ngay)
  await BackgroundService.initializeService();

  runApp(const TiemRuaXeApp());
}

class TiemRuaXeApp extends StatelessWidget {
  const TiemRuaXeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tiệm Rửa Xe',
      theme: ThemeData(
        // Sử dụng tông màu xanh đặc trưng của tiệm rửa xe
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}