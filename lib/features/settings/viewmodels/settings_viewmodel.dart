import 'package:change_life/features/settings/models/setting_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart'; // Để lấy storageServiceProvider

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    // 1. Lấy storageService từ ref.read
    final storageService = ref.read(storageServiceProvider);
    // 2. Lấy username và isDarkMode hiện tại từ storageService
    final username = storageService.getUsername();
    final isDarkMode = storageService.getDarkMode();
    // 3. Trả về đối tượng SettingsState ban đầu
    return SettingsState(username: username, isDarkMode: isDarkMode);
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
}
