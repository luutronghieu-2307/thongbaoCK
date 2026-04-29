import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tiem_rua_xe/services/storage_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentId();
  }

  void _loadCurrentId() async {
    String? id = await StorageService.getSheetId();
    if (id != null) _controller.text = id;
  }

  void _saveId() async {
    if (_controller.text.isEmpty) {
      GFToast.showToast("Vui lòng dán ID vào!", context);
      return;
    }
    await StorageService.saveSheetId(_controller.text.trim());
    GFToast.showToast("Đã lưu ID thành công!", context, 
        toastPosition: GFToastPosition.BOTTOM, 
        backgroundColor: Colors.green);
    
    // Quay lại trang chủ sau khi lưu
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt kết nối")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const GFTypography(
              text: 'Dán ID Google Sheet',
              type: GFTypographyType.typo4,
            ),
            const SizedBox(height: 10),
            // Sửa lỗi: Di chuyển nội dung placeholder vào hintText bên trong decoration
            GFTextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ví dụ: 1ABC-xyz...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            GFButton(
              onPressed: _saveId,
              text: "LƯU VÀ KẾT NỐI",
              fullWidthButton: true,
              shape: GFButtonShape.pills,
              color: GFColors.SUCCESS,
            ),
            const SizedBox(height: 40),
            const Text(
              "Hướng dẫn: ID là đoạn mã nằm giữa '/d/' và '/edit/' trên link Google Sheet của bạn.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}