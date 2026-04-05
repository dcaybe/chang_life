import 'package:change_life/models/food.dart';
import 'package:change_life/models/habit.dart';
import 'package:change_life/models/todo.dart';
import 'package:change_life/providers/habit_provider.dart';
import 'package:change_life/services/api_service.dart';
import 'package:change_life/services/habit_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// List habit
class HabitViewModel extends Notifier<List<Habit>> {
  //get habits
  late final HabitService service;
  @override
  List<Habit> build() {
    service = ref.read(habitServiceProvider);
    return service.getHabits();
  }

  //done task
  void toggle(String id) {
    service.toggle(id);
    state = service.getHabits();
  }

  //add task
  void addHabit(String name, String id) {
    service.addHabit(name, id);
    state = service.getHabits();
    ;
  }

  //remove task
  void removeHabit(int index) {
    service.removeHabit(index);
    state = service.getHabits();
  }
}

//api habit
class TestVM extends AutoDisposeAsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    print('TestVM: Initializing...');

    ref.onDispose(() {
      print('TestVM: Disposed! (Dọn dẹp bộ nhớ)');
    });
    try {
      final api = ref.read(todoApiProvider);
      final res = await api.fetchTodos();
      return res;
    } catch (e) {
      rethrow;
    }
  }
}

// lib/viewmodels/habit_vm.dart

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
