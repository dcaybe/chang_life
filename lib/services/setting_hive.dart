import 'package:hive/hive.dart';

class StorageService {
  late Box _settingsBox;

  // Hàm khởi tạo 'async' để mở sổ
  Future<void> init() async {
    _settingsBox = await Hive.openBox('settingsBox');
  }

  // Hàm lưu String: Phải có 'async' vì Hive ghi file cũng tốn thời gian
  Future<void> saveUsername(String name) async {
    await _settingsBox.put('user_name', name);
  }

  // Hàm đọc String: Đồng bộ (sync) - do dữ liệu đã vào RAM sau khi openBox
  String getUsername() {
    return _settingsBox.get('user_name', defaultValue: 'Guest');
  }

  // --- TOKEN MOCK ---
  Future<void> saveToken(String token) async {
    await _settingsBox.put('token', token);
  }

  String? getToken() {
    return _settingsBox.get('token');
  }

  Future<void> removeToken() async {
    await _settingsBox.delete('token');
  }

  Future<void> saveDarkMode(bool isDark) async {
    await _settingsBox.put('dark_mode', isDark);
  }

  bool getDarkMode() {
    return _settingsBox.get('dark_mode', defaultValue: false);
  }

  Future<void> saveClickCount(int count) async {
    await _settingsBox.put('click_count', count);
  }

  int getClickCount() {
    return _settingsBox.get('click_count', defaultValue: 0);
  }
}
