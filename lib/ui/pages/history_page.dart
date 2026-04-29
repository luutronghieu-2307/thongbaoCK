import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:tiem_rua_xe/models/transaction_model.dart';
import 'package:tiem_rua_xe/services/storage_service.dart';
import '../widgets/transaction_item.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Transaction> _allTransactions = [];
  bool _isEditMode = false;
  final List<String> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Tải toàn bộ lịch sử từ máy
  void _loadHistory() async {
    var list = await StorageService.loadTransactions();
    setState(() {
      _allTransactions = list;
    });
  }

  // Xử lý chọn ngày để xóa
  void _toggleDateSelection(String date) {
    setState(() {
      if (_selectedDates.contains(date)) {
        _selectedDates.remove(date);
      } else {
        _selectedDates.add(date);
      }
    });
  }

  // Thực hiện xóa các ngày đã chọn
  void _deleteSelected() async {
    if (_selectedDates.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa?"),
        content: Text("Bạn có chắc muốn xóa lịch sử của ${_selectedDates.length} ngày đã chọn?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY")),
          TextButton(
            onPressed: () async {
              await StorageService.deleteHistoryByDates(_selectedDates);
              Navigator.pop(context);
              _selectedDates.clear();
              _isEditMode = false;
              _loadHistory();
              GFToast.showToast("Đã xóa lịch sử thành công", context);
            },
            child: const Text("XÓA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử giao dịch"),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          )
        ],
      ),
      body: _allTransactions.isEmpty
          ? const Center(child: Text("Không có dữ liệu lịch sử"))
          : GroupedListView<Transaction, String>(
              elements: _allTransactions,
              groupBy: (element) => element.date,
              groupSeparatorBuilder: (String date) => Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blueGrey[900],
                child: Row(
                  children: [
                    if (_isEditMode)
                      GFCheckbox(
                        size: GFSize.SMALL,
                        activeBgColor: GFColors.DANGER,
                        onChanged: (val) => _toggleDateSelection(date),
                        value: _selectedDates.contains(date),
                      ),
                    const SizedBox(width: 10),
                    Text(
                      "Ngày: $date",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context, Transaction tx) => TransactionItem(
                transaction: tx,
                isLatest: false, // Trong trang lịch sử thì không cần highlight dòng mới nhất
              ),
              order: GroupedListOrder.DESC, // Hiện ngày mới nhất lên đầu
            ),
      floatingActionButton: _isEditMode && _selectedDates.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.delete),
              label: Text("Xóa ${_selectedDates.length} ngày"),
            )
          : null,
    );
  }
}