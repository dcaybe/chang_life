import 'package:change_life/models/habit.dart';
import 'package:change_life/models/todo.dart';
import 'package:change_life/services/api_service.dart';
import 'package:change_life/services/habit_service.dart';
import 'package:change_life/viewmodels/habit_vm.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final habitVMProvider = NotifierProvider<HabitViewModel, List<Habit>>(
  HabitViewModel.new,
);
final countComplete = Provider<int>((ref) {
  final habits = ref.watch(habitVMProvider);
  return habits.where((h) => h.isDone).length;
});
final habitProvider = Provider.family<Habit, String>((ref, id) {
  final list = ref.watch(habitVMProvider);

  return list.firstWhere((h) => h.id == id);
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

final testProvider = AsyncNotifierProvider<TestVM, List<Todo>>(TestVM.new);
