import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:change_life/features/habit/models/todo_model.dart';
import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:change_life/services/habit_hive_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// List habit
class HabitViewModel extends Notifier<List<Habit>> {
  //get habits
  late final HabitHiveService service;
  @override
  List<Habit> build() {
    service = ref.read(habitHiveServiceProvider);
    return service.getHabits();
  }

  //done task
  void toggle(String id) {
    service.toggle(id);
    state = service.getHabits();
  }

  //add task
  void addHabit(Habit habit) {
    service.addHabit(habit);
    state = service.getHabits();
  }

  //remove task
  void removeHabit(int index) {
    service.removeHabit(index);
    state = service.getHabits();
  }

  void deleteHabit(String id) {
    service.deleteHabitById(id);
    state = service.getHabits();
  }

  void updateHabit(Habit habit) {
    service.updateHabit(habit);
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

// lib/viewmodels/habit_viewmodel.dart
 