import 'package:change_life/features/nutrition/models/food.dart';
import 'package:change_life/features/habit/models/habit.dart';
import 'package:change_life/features/nutrition/viewmodels/food_vm.dart';
import 'package:change_life/features/habit/models/todo.dart';
import 'package:change_life/services/api_service.dart';
import 'package:change_life/services/habit_service.dart';
import 'package:change_life/features/habit/viewmodels/habit_vm.dart';
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
// service
final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService();
});

// api
final todoApiProvider = Provider<ApiService>((ref) {
  return ApiService();
});
final foodApiProvider = Provider<FoodApi>((ref) {
  return FoodApi();
});

final testProvider = AsyncNotifierProvider.autoDispose<TestVM, List<Todo>>(
  TestVM.new,
);
final foodVMProvider = AsyncNotifierProvider.autoDispose<FoodVM, List<Food>>(
  FoodVM.new,
);
