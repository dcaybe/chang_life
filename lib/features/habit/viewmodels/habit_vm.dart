import 'package:change_life/features/habit/models/habit.dart';
import 'package:change_life/features/habit/models/todo.dart';
import 'package:change_life/features/habit/providers/habit_provider.dart';
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

