import 'package:change_life/features/settings/models/setting_model.dart';
import 'package:change_life/features/settings/viewmodels/settings_vm.dart';
import 'package:change_life/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  // Chúng ta sẽ "ném" ra một lỗi nếu chưa được khởi tạo ở main
  throw UnimplementedError();
});
final settingsProvider = NotifierProvider<SettingsVM, SettingsState>(() {
  return SettingsVM();
});
