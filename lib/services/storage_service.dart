import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiem_rua_xe/models/transaction_model.dart';

/// Dịch vụ quản lý lưu trữ dữ liệu cục bộ trên bộ nhớ điện thoại.
class StorageService {
  static const String _keySheetId = 'sheet_id';
  static const String _keyTransactions = 'transactions';

  // --- QUẢN LÝ ID GOOGLE SHEET ---

  /// Lưu ID Google Sheet vào bộ nhớ máy.
  static Future<void> saveSheetId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySheetId, id);
  }

  /// Lấy ID Google Sheet đã lưu từ bộ nhớ máy.
  static Future<String?> getSheetId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySheetId);
  }

  // --- QUẢN LÝ DANH SÁCH GIAO DỊCH ---

  /// Lưu toàn bộ danh sách giao dịch xuống bộ nhớ dưới dạng chuỗi JSON.
  static Future<void> saveTransactions(List<Transaction> list) async {
    final prefs = await SharedPreferences.getInstance();
    // Sử dụng hàm encode đã viết trong Model để chuyển danh sách thành chuỗi
    String encodedData = Transaction.encode(list);
    await prefs.setString(_keyTransactions, encodedData);
  }

  /// Đọc danh sách giao dịch từ bộ nhớ và chuyển ngược lại thành danh sách Object.
  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_keyTransactions);
    
    if (jsonString == null || jsonString.isEmpty) return [];
    
    // Sử dụng hàm decode đã viết trong Model để chuyển chuỗi thành danh sách
    return Transaction.decode(jsonString);
  }

  // --- QUẢN LÝ LỊCH SỬ & GIẢI PHÓNG DUNG LƯỢNG (TASK 3.3) ---

  /// Xóa lịch sử dựa trên danh sách các ngày được người dùng tích chọn.
  static Future<void> deleteHistoryByDates(List<String> datesToDelete) async {
    List<Transaction> currentList = await loadTransactions();
    
    // Thuật toán: Lọc bỏ các phần tử có ngày nằm trong danh sách cần xóa
    currentList.removeWhere((tx) => datesToDelete.contains(tx.date));
    
    // Lưu lại danh sách đã làm sạch vào bộ nhớ
    await saveTransactions(currentList);
  }

  /// Xóa sạch mọi dữ liệu (Dùng để Reset toàn bộ App).
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTransactions);
    await prefs.remove(_keySheetId);
  }
}