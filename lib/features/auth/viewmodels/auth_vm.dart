import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthVM extends AsyncNotifier<String?> {
  @override
  String? build() {
    // Đọc token khi ứng dụng vừa khởi động
    final storageService = ref.read(storageServiceProvider);
    return storageService.getToken();
  }

  Future<void> login(String username, String password) async {
    // Phát tín hiệu loading cho UI
    state = const AsyncLoading();

    // Giả lập network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Tạo token giả
    final fakeToken = 'token_for_$username';
    
    // Lưu token xuống thiết bị
    final storageService = ref.read(storageServiceProvider);
    await storageService.saveToken(fakeToken);
    
    // Lưu vào state bằng AsyncData (vừa giữ dữ liệu vừa bỏ cờ loading)
    state = AsyncData(fakeToken);
  }

  Future<void> logout() async {
    final storageService = ref.read(storageServiceProvider);
    await storageService.removeToken();
    state = const AsyncData(null);
  }
}
