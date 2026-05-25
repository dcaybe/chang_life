import 'package:change_life/theme/app_theme.dart';

class SettingsState {
  final String username;
  final bool isDarkMode;
  final AppThemeMode currentTheme;

  SettingsState({
    required this.username, 
    required this.isDarkMode,
    this.currentTheme = AppThemeMode.kineticDiscipline,
  });

  // Hàm copyWith này CỰC KỲ QUAN TRỌNG trong Riverpod.
  // Nó giúp bạn tạo ra một bản sao mới của State khi chỉ muốn thay đổi 1 thuộc tính.
  SettingsState copyWith({
    String? username, 
    bool? isDarkMode,
    AppThemeMode? currentTheme,
  }) {
    return SettingsState(
      username: username ?? this.username,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentTheme: currentTheme ?? this.currentTheme,
    );
  }
}
