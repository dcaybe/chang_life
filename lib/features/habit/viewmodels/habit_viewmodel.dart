import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:change_life/features/habit/models/todo_model.dart';
import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:change_life/services/habit_hive_service.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
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

  void _checkAndUpdateStreak() {
    final habits = state;
    if (habits.isEmpty) return;
    
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    final completedToday = habits.where((h) => h.completedDays.contains(dateStr)).length;
    
    final storageService = ref.read(storageServiceProvider);
    List<String> streakDays = storageService.getStreakDays();
    
    if (completedToday == habits.length) {
      if (!streakDays.contains(dateStr)) {
        streakDays.add(dateStr);
        storageService.saveStreakDays(streakDays);
      }
    } else {
      if (streakDays.contains(dateStr)) {
        streakDays.remove(dateStr);
        storageService.saveStreakDays(streakDays);
      }
    }
  }

  //done task
  void toggle(String id) {
    service.toggle(id);
    state = service.getHabits();
    _checkAndUpdateStreak();
  }

  //add task
  void addHabit(Habit habit) {
    service.addHabit(habit);
    state = service.getHabits();
    _checkAndUpdateStreak();
  }

  /// MVVM: ViewModel tạo Model, View chỉ truyền raw data
  void createHabit(String name) {
    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    addHabit(habit);
  }

  //remove task
  void removeHabit(int index) {
    service.removeHabit(index);
    state = service.getHabits();
    _checkAndUpdateStreak();
  }

  void deleteHabit(String id) {
    service.deleteHabitById(id);
    state = service.getHabits();
    _checkAndUpdateStreak();
  }

  void updateHabit(Habit habit) {
    service.updateHabit(habit);
    state = service.getHabits();
    _checkAndUpdateStreak();
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
 