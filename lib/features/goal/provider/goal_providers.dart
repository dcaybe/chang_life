import 'package:change_life/services/habit_service.dart';
import 'package:change_life/services/hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  // Chúng ta sẽ "ném" ra một lỗi nếu chưa được khởi tạo ở main
  throw UnimplementedError();
});
