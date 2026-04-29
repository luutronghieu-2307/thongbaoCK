import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:tiem_rua_xe/models/transaction_model.dart';
import 'package:tiem_rua_xe/services/storage_service.dart';
import '../widgets/sidebar_drawer.dart';
import '../widgets/transaction_item.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> _transactions = [];
  bool _isRunning = false;
  double _todayTotal = 0;
  StreamSubscription? _updateSubscription;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
    _loadData();
    _listenToBackgroundService();
  }

  /// Kiểm tra xem dịch vụ có đang chạy hay không để cập nhật nút bấm
  void _checkServiceStatus() async {
    bool running = await FlutterBackgroundService().isRunning();
    setState(() {
      _isRunning = running;
    });
  }

  /// Lắng nghe tín hiệu "update" từ Background gửi về để load lại danh sách
  void _listenToBackgroundService() {
    _updateSubscription = FlutterBackgroundService().on('update').listen((event) {
      if (mounted) {
        _loadData();
      }
    });
  }

  /// Đọc dữ liệu từ bộ nhớ máy
  void _loadData() async {
    var list = await StorageService.loadTransactions();
    String today = DateFormat('d/M/yyyy').format(DateTime.now());
    
    double total = 0;
    for (var tx in list) {
      if (tx.date == today) total += tx.amount;
    }

    if (mounted) {
      setState(() {
        _transactions = list.reversed.toList();
        _todayTotal = total;
      });
    }
  }

  /// Điều khiển Bật/Tắt Dịch vụ chạy ngầm
  void _toggleService() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();

    if (isRunning) {
      // Gửi lệnh dừng cho Service
      service.invoke("stopService");
      WakelockPlus.disable();
      setState(() {
        _isRunning = false;
      });
    } else {
      // Bắt đầu khởi động Service chạy ngầm
      bool success = await service.startService();
      if (success) {
        WakelockPlus.enable();
        setState(() {
          _isRunning = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
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
          GFCard(
            title: const GFListTile(
              title: Text('TỔNG THU HÔM NAY', style: TextStyle(color: Colors.grey)),
            ),
            content: Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_todayTotal),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GFButton(
              onPressed: _toggleService,
              text: _isRunning ? "DỪNG BÁO TIỀN (ĐANG CHẠY NGẦM)" : "BẮT ĐẦU CA LÀM",
              color: _isRunning ? GFColors.DANGER : GFColors.SUCCESS,
              fullWidthButton: true,
              size: GFSize.LARGE,
              icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow, color: Colors.white),
            ),
          ),

          const Divider(),

          Expanded(
            child: _transactions.isEmpty
                ? const Center(child: Text("Đang chờ giao dịch mới..."))
                : RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        return TransactionItem(
                          transaction: _transactions[index],
                          isLatest: index == 0 && _isRunning,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}