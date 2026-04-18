import 'package:change_life/features/settings/models/setting_model.dart';
import 'package:change_life/features/settings/viewmodels/settings_viewmodel.dart';
import 'package:change_life/services/setting_hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  // Chúng ta sẽ "ném" ra một lỗi nếu chưa được khởi tạo ở main
  throw UnimplementedError();
});
final settingsProvider = NotifierProvider<SettingsViewModel, SettingsState>(() {
  return SettingsViewModel();
});
