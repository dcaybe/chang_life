import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Chúng ta tạo một biến để giữ "cuốn sổ" trong Class
  SharedPreferences? _prefs;

  // Hàm khởi tạo 'async' để mở sổ
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Hàm lưu String: Phải có 'async' vì setString tốn thời gian
  Future<void> saveUsername(String name) async {
    await _prefs!.setString('user_name', name);
  }

  // Hàm đọc String: Không cần async vì đọc từ bộ nhớ RAM trong prefs rất nhanh
  String getUsername() {
    return _prefs?.getString('user_name') ?? 'Guest';
  }

  Future<void> saveDarkMode(bool isDark) async {
    await _prefs!.setBool('dark_mode', isDark);
  }

  bool getDarkMode() {
    return _prefs?.getBool('dark_mode') ?? false;
  }

  Future<void> saveClickCount(int count) async {
    await _prefs?.setInt('click_count', count);
  }

  int getClickCount() {
    return _prefs?.getInt('click_count') ?? 0;
  }
}
