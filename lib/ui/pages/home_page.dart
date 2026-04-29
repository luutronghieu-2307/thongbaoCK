import 'dart:async';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:tiem_rua_xe/models/transaction_model.dart';
import 'package:tiem_rua_xe/services/sheet_service.dart';
import 'package:tiem_rua_xe/services/storage_service.dart';
import 'settings_page.dart';
import 'history_page.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/transaction_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SheetService _sheetService = SheetService();
  List<Transaction> _transactions = [];
  Timer? _timer;
  bool _isRunning = false;
  double _todayTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu từ máy lên UI
  void _loadData() async {
    var list = await StorageService.loadTransactions();
    String today = DateFormat('d/M/yyyy').format(DateTime.now());
    
    // Tính tổng tiền hôm nay
    double total = 0;
    for (var tx in list) {
      if (tx.date == today) total += tx.amount;
    }

    setState(() {
      _transactions = list.reversed.toList();
      _todayTotal = total;
    });
  }

  // Bật/Tắt chế độ báo tiền
  void _toggleService() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _timer = Timer.periodic(const Duration(seconds: 3), (t) async {
          await _sheetService.fetchAndProcess();
          _loadData();
        });
        _sheetService.speakTransaction(0, "Hệ thống báo tiền đã sẵn sàng");
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rửa Xe Hiền"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context, MaterialPageRoute(builder: (context) => const SettingsPage())
              );
              if (result == true) _loadData();
            },
          )
        ],
      ),
      drawer: const SidebarDrawer(),
      body: Column(
        children: [
          // Thẻ hiển thị tổng tiền hôm nay
          GFCard(
            boxFit: BoxFit.cover,
            title: const GFListTile(
              title: Text('TỔNG THU HÔM NAY', style: TextStyle(color: Colors.grey)),
            ),
            content: Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_todayTotal),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
          
          // Nút kích hoạt báo động
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GFButton(
              onPressed: _toggleService,
              text: _isRunning ? "DỪNG BÁO TIỀN" : "BẮT ĐẦU CA LÀM",
              color: _isRunning ? GFColors.DANGER : GFColors.SUCCESS,
              fullWidthButton: true,
              size: GFSize.LARGE,
              icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow, color: Colors.white),
            ),
          ),

          const Divider(),

          // Danh sách giao dịch
          Expanded(
            child: _transactions.isEmpty
                ? const Center(child: Text("Chưa có giao dịch nào"))
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      return TransactionItem(
                        transaction: _transactions[index],
                        isLatest: index == 0 && _isRunning, // Highlight dòng đầu nếu đang chạy
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}