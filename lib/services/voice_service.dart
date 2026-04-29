import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

/// Dịch vụ quản lý giọng nói thông báo tiền về (TTS).
class VoiceService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  /// Khởi tạo cấu hình ban đầu
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Kiểm tra xem máy có hỗ trợ tiếng Việt không
      bool isInstalled = await _tts.isLanguageInstalled("vi-VN");
      
      // 2. Thiết lập cấu hình mặc định
      await _tts.setLanguage("vi-VN");
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5); // Tốc độ đọc chậm cho tiệm rửa xe
      
      if (Platform.isIOS) {
        await _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, 
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.duckOthers
            ]);
      }

      _isInitialized = true;
      print("TTS: Đã khởi tạo tiếng Việt thành công");
    } catch (e) {
      print("Lỗi khởi tạo giọng nói: $e");
    }
  }

  /// Hàm đọc nội dung văn bản
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    
    try {
      // MẸO: Ép buộc đặt lại ngôn ngữ vi-VN ngay trước khi nói 
      // để tránh việc hệ thống tự động nhảy về tiếng Anh (English).
      await _tts.setLanguage("vi-VN");
      
      // Hủy bỏ câu đọc cũ nếu có để đọc ngay câu mới
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      print("Lỗi khi phát giọng nói: $e");
    }
  }

  /// Dừng đọc lập tức
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Tùy chỉnh tốc độ đọc
  Future<void> setSpeed(double rate) async {
    await _tts.setSpeechRate(rate);
  }
}