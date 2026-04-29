import 'dart:convert';

/// Lớp định nghĩa cấu trúc một giao dịch (cuốc xe) trong hệ thống.
class Transaction {
  final String time;    // Giờ (Ví dụ: 21:21:59)
  final String date;    // Ngày (Ví dụ: 28/4/2026)
  final double amount;  // Số tiền nhận được
  final String content; // Nội dung chuyển khoản từ SePay
  final String ref;     // Mã giao dịch duy nhất để tránh báo trùng

  Transaction({
    required this.time,
    required this.date,
    required this.amount,
    required this.content,
    required this.ref,
  });

  /// Chuyển đổi đối tượng Transaction sang Map (JSON) để lưu vào máy.
  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'date': date,
      'amount': amount,
      'content': content,
      'ref': ref,
    };
  }

  /// Khởi tạo đối tượng Transaction từ dữ liệu Map (JSON) đọc từ máy lên.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      time: map['time'] ?? '',
      date: map['date'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      content: map['content'] ?? '',
      ref: map['ref'] ?? '',
    );
  }

  /// Chuyển danh sách các giao dịch thành chuỗi JSON để lưu vào Shared Preferences.
  static String encode(List<Transaction> transactions) {
    return json.encode(
      transactions.map<Map<String, dynamic>>((tx) => tx.toMap()).toList(),
    );
  }

  /// Chuyển chuỗi JSON từ Shared Preferences thành danh sách các đối tượng Transaction.
  static List<Transaction> decode(String transactionsJson) {
    if (transactionsJson.isEmpty) return [];
    return (json.decode(transactionsJson) as List<dynamic>)
        .map<Transaction>((item) => Transaction.fromMap(item))
        .toList();
  }
}