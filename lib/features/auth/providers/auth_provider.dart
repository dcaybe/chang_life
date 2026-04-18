import 'package:change_life/features/auth/viewmodels/auth_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authVMProvider = AsyncNotifierProvider<AuthVM, String?>(() {
  return AuthVM();
});

final usernameControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final passwordControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

// 📌 DERIVED PROVIDER: Tự động trích xuất Tên User từ Fake Token
final currentUserProvider = Provider<String>((ref) {
  // Lắng nghe trạng thái của Auth
  final authState = ref.watch(authVMProvider);
  final token = authState.value;
  
  // Logic siêu đơn giản: nếu có token "token_for_Hung" thì lấy chữ "Hung" ra
  if (token != null && token.startsWith('token_for_')) {
    return token.substring(10); // Bỏ đi 10 ký tự 'token_for_'
  }
  
  return 'Guest';
});
