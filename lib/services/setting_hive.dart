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

  Future<void> saveHeight(double height) async {
    await _settingsBox.put('height', height);
  }

  double getHeight() {
    return _settingsBox.get('height', defaultValue: 170.0);
  }

  Future<void> saveWeight(double weight) async {
    await _settingsBox.put('weight', weight);
  }

  double getWeight() {
    return _settingsBox.get('weight', defaultValue: 65.0);
  }

  Future<void> saveAge(int age) async {
    await _settingsBox.put('age', age);
  }

  int getAge() {
    return _settingsBox.get('age', defaultValue: 25);
  }

  Future<void> saveGender(String gender) async {
    await _settingsBox.put('gender', gender);
  }

  String getGender() {
    return _settingsBox.get('gender', defaultValue: 'Male');
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

  Future<void> saveThemeMode(String themeName) async {
    await _settingsBox.put('theme_mode', themeName);
  }

  String getThemeMode() {
    return _settingsBox.get('theme_mode', defaultValue: 'kineticDiscipline');
  }

  Future<void> saveClickCount(int count) async {
    await _settingsBox.put('click_count', count);
  }

  int getClickCount() {
    return _settingsBox.get('click_count', defaultValue: 0);
  }

  // --- ONBOARDING ---
  bool hasSeenOnboarding() {
    return _settingsBox.get('has_seen_onboarding', defaultValue: false);
  }

  Future<void> markOnboardingSeen() async {
    await _settingsBox.put('has_seen_onboarding', true);
  }

  // --- NUTRITION ---
  bool hasConfiguredNutrition() {
    return _settingsBox.get('has_configured_nutrition', defaultValue: false);
  }

  Future<void> setHasConfiguredNutrition(bool value) async {
    await _settingsBox.put('has_configured_nutrition', value);
  }

  int getNutritionTotalCalories() {
    return _settingsBox.get('nutrition_total_calories', defaultValue: 0);
  }

  Future<void> setNutritionTotalCalories(int calories) async {
    await _settingsBox.put('nutrition_total_calories', calories);
  }

  int getNutritionProtein() {
    return _settingsBox.get('nutrition_protein', defaultValue: 0);
  }

  Future<void> setNutritionProtein(int value) async {
    await _settingsBox.put('nutrition_protein', value);
  }

  int getNutritionCarbs() {
    return _settingsBox.get('nutrition_carbs', defaultValue: 0);
  }

  Future<void> setNutritionCarbs(int value) async {
    await _settingsBox.put('nutrition_carbs', value);
  }

  int getNutritionFats() {
    return _settingsBox.get('nutrition_fats', defaultValue: 0);
  }

  Future<void> setNutritionFats(int value) async {
    await _settingsBox.put('nutrition_fats', value);
  }

  DateTime? getNutritionStartDate() {
    final timestamp = _settingsBox.get('nutrition_start_date');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  Future<void> setNutritionStartDate(DateTime date) async {
    await _settingsBox.put('nutrition_start_date', date.millisecondsSinceEpoch);
  }

  // --- HABIT STREAK ---
  List<String> getStreakDays() {
    final list = _settingsBox.get('streak_days', defaultValue: <String>[]);
    if (list is List) {
      return list.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  Future<void> saveStreakDays(List<String> days) async {
    await _settingsBox.put('streak_days', days);
  }
}
