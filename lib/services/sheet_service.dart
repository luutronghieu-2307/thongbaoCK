import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:tiem_rua_xe/models/transaction_model.dart';
import 'package:tiem_rua_xe/services/storage_service.dart';
import 'package:tiem_rua_xe/services/voice_service.dart';

/// Dịch vụ kết nối Google Sheets và xử lý logic nhận diện tiền mới.
class SheetService {
  final VoiceService _voice = VoiceService();
  bool _isProcessing = false;

  SheetService() {
    _voice.initialize();
  }

  /// Hàm phát loa thông báo rút gọn.
  Future<void> speakTransaction(double amount, String content) async {
    String amountText = amount.toInt().toString();
    String message = "Vừa nhận $amountText đồng vào tài khoản";
    await _voice.speak(message);
  }

  /// Tải dữ liệu từ Google Sheets và xử lý logic nhận diện tiền mới.
  Future<void> fetchAndProcess() async {
    if (_isProcessing) return;
    _isProcessing = true;

    final String? sheetId = await StorageService.getSheetId();
    if (sheetId == null || sheetId.isEmpty) {
      _isProcessing = false;
      return;
    }

    try {
      // TỐI ƯU REAL-TIME: 
      // 1. Sử dụng link /export (ID GỐC) thay vì /pub (ID 2PACX) để tránh bị trễ 5 phút.
      // 2. Thêm t=... để phá bộ nhớ đệm của Google, lấy dữ liệu mới nhất ngay lập tức.
      final url = "https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv&gid=0&t=${DateTime.now().millisecondsSinceEpoch}";
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<List<dynamic>> rows = const CsvToListConverter().convert(response.body);
        if (rows.length <= 1) {
          _isProcessing = false;
          return;
        }

        var dataRows = rows.sublist(1);
        
        List<Transaction> fetchedList = dataRows.map((row) {
          String rawDateTime = row.isNotEmpty ? row[0].toString() : '';
          List<String> dateTimeParts = rawDateTime.split(' ');
          
          String time = dateTimeParts.isNotEmpty ? dateTimeParts[0] : '';
          String date = dateTimeParts.length > 1 ? dateTimeParts[1] : '';

          return Transaction(
            time: time,
            date: date,
            amount: double.tryParse(row.length > 1 ? row[1].toString().replaceAll(RegExp(r'[^0-9]'), '') : '0') ?? 0,
            content: row.length > 2 ? row[2].toString() : '',
            ref: row.length > 3 ? row[3].toString() : '',
          );
        }).toList();

        List<Transaction> localList = await StorageService.loadTransactions();
        
        if (fetchedList.isNotEmpty) {
          Transaction latestFetched = fetchedList.last;
          bool isNew = !localList.any((tx) => tx.ref == latestFetched.ref);

          if (isNew && localList.isNotEmpty) {
            await speakTransaction(latestFetched.amount, latestFetched.content);
            localList.add(latestFetched);
            await StorageService.saveTransactions(localList);
          } else if (localList.isEmpty) {
            await StorageService.saveTransactions(fetchedList);
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi kết nối: $e");
    } finally {
      _isProcessing = false;
    }
  }
}

void debugPrint(String message) {
  if (kDebugMode) {
    print("[SheetService] $message");
  }
}