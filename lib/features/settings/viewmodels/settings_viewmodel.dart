import 'package:change_life/features/settings/models/setting_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart'; // Để lấy storageServiceProvider

import 'package:change_life/theme/app_theme.dart';

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // 1. Lấy storageService từ ref.read
    final storageService = ref.read(storageServiceProvider);
    // 2. Lấy username và isDarkMode hiện tại từ storageService
    final username = storageService.getUsername();
    final isDarkMode = storageService.getDarkMode();

    // Parse theme from storage string
    final themeString = storageService.getThemeMode();
    final themeMode = AppThemeMode.values.firstWhere(
      (e) => e.toString().split('.').last == themeString,
      orElse: () => AppThemeMode.kineticDiscipline,
    );

    // 3. Trả về đối tượng SettingsState ban đầu
    return SettingsState(
      username: username,
      isDarkMode: isDarkMode,
      currentTheme: themeMode,
    );
  }

  // Hàm cập nhật tên
  void updateName(String newName) {
    final storageService = ref.read(storageServiceProvider);

    // 1. Lưu vào ổ cứng
    storageService.saveUsername(newName);

    // 2. Cập nhật RAM (state) để UI tự vẽ lại
    state = state.copyWith(username: newName);
  }

  // Hàm bật/tắt Dark Mode
  void toggleDarkMode() {
    final storageService = ref.read(storageServiceProvider);
    final newValue = !state.isDarkMode; // Đảo ngược giá trị hiện tại

    // 1. Lưu vào ổ cứng
    storageService.saveDarkMode(newValue);

    // 2. Cập nhật RAM (state)
    state = state.copyWith(isDarkMode: newValue);
  }

  // Hàm thay đổi Theme
  void changeTheme(AppThemeMode newTheme) {
    final storageService = ref.read(storageServiceProvider);

    // 1. Lưu vào ổ cứng
    storageService.saveThemeMode(newTheme.toString().split('.').last);

    // 2. Cập nhật RAM (state)
    state = state.copyWith(currentTheme: newTheme);
  }
}
