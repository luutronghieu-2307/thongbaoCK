import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:tiem_rua_xe/ui/pages/history_page.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return GFDrawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const GFDrawerHeader(
            centerAlign: true,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GFAvatar(
                  size: GFSize.LARGE,
                  backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/2933/2933921.png'),
                ),
                SizedBox(height: 10),
                Text(
                  "TIỆM RỬA XE HIỀN",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Bảng điều khiển"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Lịch sử & Xóa dữ liệu"),
            onTap: () {
              Navigator.pop(context); // Đóng drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("Thông tin ứng dụng"),
            onTap: () {
              // Hiển thị thông tin phiên bản
            },
          ),
        ],
      ),
    );
  }
}