import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:tiem_rua_xe/models/transaction_model.dart';
import 'package:tiem_rua_xe/services/storage_service.dart';
import 'package:tiem_rua_xe/services/voice_service.dart';

/// Dịch vụ kết nối Google Sheets.
/// Đã được tối ưu để có thể chạy độc lập trong Background Service.
class SheetService {
  final VoiceService _voice = VoiceService();
  bool _isProcessing = false;

  SheetService() {
    // Khởi tạo giọng nói ngay khi service được tạo
    _voice.initialize();
  }

  /// Hàm phát loa thông báo. 
  /// Không chứa bất kỳ mã lệnh nào liên quan đến giao diện (UI).
  Future<void> speakTransaction(double amount, String content) async {
    String amountText = amount.toInt().toString();
    String message = "Vừa nhận $amountText đồng vào tài khoản";
    
    // VoiceService đã được cấu hình vi-VN nên sẽ đọc chuẩn tiếng Việt
    await _voice.speak(message);
  }

  /// Hàm lõi: Tải và xử lý dữ liệu.
  /// Được gọi liên tục mỗi 3 giây từ Background Service.
  Future<void> fetchAndProcess() async {
    // Ngăn chặn việc quét chồng chéo nếu mạng chậm
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final String? sheetId = await StorageService.getSheetId();
      if (sheetId == null || sheetId.isEmpty) {
        _isProcessing = false;
        return;
      }

      // Sử dụng ID gốc và link export để đạt tốc độ Real-time
      // Thêm t=... để phá cache của Google
      final url = "https://docs.google.com/spreadsheets/d/$sheetId/export?format=csv&gid=0&t=${DateTime.now().millisecondsSinceEpoch}";
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Chuyển đổi dữ liệu CSV
        List<List<dynamic>> rows = const CsvToListConverter().convert(response.body);
        
        // Nếu chỉ có header thì bỏ qua
        if (rows.length <= 1) {
          _isProcessing = false;
          return;
        }

        // Lấy dữ liệu (bỏ qua dòng tiêu đề)
        var dataRows = rows.sublist(1);
        
        // Chuyển sang danh sách Object Transaction
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

        // Lấy danh sách cũ đã lưu trong máy
        List<Transaction> localList = await StorageService.loadTransactions();
        
        if (fetchedList.isNotEmpty) {
          Transaction latestFetched = fetchedList.last;

          // Kiểm tra xem giao dịch này đã được báo chưa (dựa trên mã ref)
          bool isAlreadyExists = localList.any((tx) => tx.ref == latestFetched.ref);

          if (!isAlreadyExists && localList.isNotEmpty) {
            // ĐÂY LÀ GIAO DỊCH MỚI -> PHÁT LOA NGAY
            await speakTransaction(latestFetched.amount, latestFetched.content);
            
            // Lưu vào bộ nhớ máy để lần sau không báo lại nữa
            localList.add(latestFetched);
            await StorageService.saveTransactions(localList);
          } else if (localList.isEmpty) {
            // Nếu lần đầu mở app, lưu toàn bộ dữ liệu hiện tại làm gốc
            await StorageService.saveTransactions(fetchedList);
          }
        }
      }
    } catch (e) {
      // Trong môi trường chạy ngầm, dùng print để debug trong console terminal
      print("[Background Sheet Error]: $e");
    } finally {
      _isProcessing = false;
    }
  }
}