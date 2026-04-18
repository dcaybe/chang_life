import 'dart:async';

import 'package:change_life/features/nutrition/models/food_model.dart';
import 'package:change_life/features/nutrition/providers/nutrition_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FoodViewModel extends AutoDisposeAsyncNotifier<List<Food>> {
  @override
  Future<List<Food>> build() async {
    print('🍎 [FoodVM] build: Đang khởi tạo hoặc fetch dữ liệu...');

    final keepAliveHandle = ref.keepAlive();

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

    ref.onDispose(() {
      print('💀 [FoodVM] onDispose: Provider đã bị hủy hoàn toàn!');
    });

    // 1. Lấy dữ liệu từ Hive Cache
    final foodHiveService = ref.read(foodHiveServiceProvider);
    final cachedFoods = foodHiveService.getFoods();

    if (cachedFoods != null && cachedFoods.isNotEmpty) {
      print(
        '📦 [FoodVM] Lấy thành công dữ liệu từ Hive Cache! Không gọi API nữa.',
      );
      return cachedFoods;
    }

    // 2. Không có cache thì gọi API
    try {
      final api = ref.read(foodApiProvider);
      final res = await api.fetchFoods();

      // 3. Lưu vào Hive cache
      foodHiveService.saveFoods(res);
      print('✅ [FoodVM] Fetch thành công từ API và đã lưu Cache vào Hive!');
      return res;
    } catch (e) {
      print('❌ [FoodVM] Lỗi fetch: $e');
      rethrow;
    }
  }

  // Hàm Refresh để ép buộc gọi lại API bỏ qua cache
  Future<void> refresh() async {
    print('🔄 [FoodVM] Bắt đầu refresh: Bỏ qua cache, gọi trực tiếp API...');
    state = const AsyncLoading();
    try {
      final api = ref.read(foodApiProvider);
      final res = await api.fetchFoods();

      final foodHiveService = ref.read(foodHiveServiceProvider);
      foodHiveService.saveFoods(res); // Update cache luôn

      state = AsyncData(res);
      print('✅ [FoodVM] Refresh thành công và cập nhật lại Cache!');
    } catch (e, stack) {
      print('❌ [FoodVM] Lỗi refresh: $e');
      state = AsyncError(e, stack);
    }
  }
}
