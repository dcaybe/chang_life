import 'dart:async';

import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:change_life/features/nutrition/models/food.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodVM extends AutoDisposeAsyncNotifier<List<Food>> {
  @override
  Future<List<Food>> build() async {
    print('🍎 [FoodVM] build: Đang khởi tạo hoặc fetch dữ liệu mới...');

    // 1. Giữ state lại (Cache)
    final keepAliveHandle = ref.keepAlive();

    // 2. Để ý cái này: Khi không còn ai watch (người dùng thoát màn hình)
    ref.onCancel(() {
      print(
        '⏳ [FoodVM] onCancel: Không ai xem nữa, bắt đầu đếm ngược 10s để xóa cache...',
      );

      Timer(const Duration(seconds: 10), () {
        print(
          '🗑️ [FoodVM] Timer: Đã hết 10s, chính thức xóa cache (dispose)!',
        );
        keepAliveHandle.close();
      });
    });

    // 3. Log khi bị dispose thực sự
    ref.onDispose(() {
      print('💀 [FoodVM] onDispose: Provider đã bị hủy hoàn toàn!');
    });

    try {
      final api = ref.read(foodApiProvider);
      final res = await api.fetchFoods();
      print('✅ [FoodVM] Fetch thành công từ API!');
      return res;
    } catch (e) {
      print('❌ [FoodVM] Lỗi fetch: $e');
      rethrow;
    }
  }
}
