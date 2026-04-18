import 'package:change_life/features/nutrition/models/food.dart';
import 'package:change_life/features/habit/models/habit.dart';
import 'package:change_life/features/nutrition/viewmodels/food_vm.dart';
import 'package:change_life/features/habit/models/todo.dart';
import 'package:change_life/features/settings/models/setting_model.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/features/settings/viewmodels/settings_vm.dart';
import 'package:change_life/services/api_service.dart';
import 'package:change_life/services/habit_hive_service.dart';
import 'package:change_life/features/habit/viewmodels/habit_vm.dart';
import 'package:change_life/services/setting_hive.dart';
import 'package:change_life/services/food_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final habitVMProvider = NotifierProvider<HabitViewModel, List<Habit>>(
  HabitViewModel.new,
);
final countComplete = Provider<int>((ref) {
  return ref.watch(
    habitVMProvider.select((h) => h.where((h) => h.isDone).length),
  );
});
final habitProvider = Provider.family<Habit, String>((ref, id) {
  return ref.watch(
    habitVMProvider.select((list) => list.firstWhere((h) => h.id == id)),
  );
});

// toggle
final toggleHabitProvider = Provider((ref) {
  return (String id) {
    ref.read(habitVMProvider.notifier).toggle(id);
  };
});

// api
final todoApiProvider = Provider<ApiService>((ref) {
  return ApiService();
});


final testProvider = AsyncNotifierProvider.autoDispose<TestVM, List<Todo>>(
  TestVM.new,
);

final habitHiveServiceProvider = Provider<HabitHiveService>((ref) {
  // Chúng ta sẽ "ném" ra một lỗi nếu chưa được khởi tạo ở main
  throw UnimplementedError();
});

