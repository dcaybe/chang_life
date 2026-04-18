
class SettingsState {
  final String username;
  final bool isDarkMode;

  SettingsState({required this.username, required this.isDarkMode});

  // Hàm copyWith này CỰC KỲ QUAN TRỌNG trong Riverpod.
  // Nó giúp bạn tạo ra một bản sao mới của State khi chỉ muốn thay đổi 1 thuộc tính.
  SettingsState copyWith({String? username, bool? isDarkMode}) {
    return SettingsState(
      username: username ?? this.username,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
