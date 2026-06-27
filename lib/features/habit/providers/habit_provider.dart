import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:change_life/features/habit/models/todo_model.dart';
import 'package:change_life/services/api_service.dart';
import 'package:change_life/services/habit_hive_service.dart';
import 'package:change_life/features/habit/viewmodels/habit_viewmodel.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final habitVMProvider = NotifierProvider<HabitViewModel, List<Habit>>(
  HabitViewModel.new,
);
final countComplete = Provider<int>((ref) {
  final now = DateTime.now();
  return ref.watch(
    habitVMProvider.select((list) => list.where((h) => h.isCompletedOn(now)).length),
  );
});

final habitProgressProvider = Provider<double>((ref) {
  final habits = ref.watch(habitVMProvider);
  if (habits.isEmpty) return 0.0;
  final now = DateTime.now();
  final completed = habits.where((h) => h.isCompletedOn(now)).length;
  return completed / habits.length;
});

class HabitStats {
  final List<DateTime> last7Days;
  final List<double> dailyCompletionData;
  final int totalCompletions;
  final int currentStreak;

  HabitStats(this.last7Days, this.dailyCompletionData, this.totalCompletions, this.currentStreak);
}

final habitStatisticsProvider = Provider<HabitStats>((ref) {
  final habits = ref.watch(habitVMProvider);
  final now = DateTime.now();
  
  final last7Days = List.generate(7, (index) {
    return now.subtract(Duration(days: 6 - index));
  });

  final dailyCompletionData = last7Days.map((date) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final total = habits.length;
    if (total == 0) return 0.0;
    final completed = habits.where((h) => h.completedDays.contains(dateStr)).length;
    return (completed / total) * 100;
  }).toList();

  final totalCompletions = habits.fold<int>(0, (sum, h) => sum + h.completedDays.length);

  int currentStreak = 0;
  final storageService = ref.read(storageServiceProvider);
  final streakDays = storageService.getStreakDays();
  
  if (streakDays.isNotEmpty) {
    DateTime dateToCheck = DateTime.now();
    final dateStrToday = "${dateToCheck.year}-${dateToCheck.month.toString().padLeft(2, '0')}-${dateToCheck.day.toString().padLeft(2, '0')}";
    
    if (streakDays.contains(dateStrToday)) {
      currentStreak++;
      dateToCheck = dateToCheck.subtract(const Duration(days: 1));
    } else {
      dateToCheck = dateToCheck.subtract(const Duration(days: 1));
    }

    while (true) {
      final dateStr = "${dateToCheck.year}-${dateToCheck.month.toString().padLeft(2, '0')}-${dateToCheck.day.toString().padLeft(2, '0')}";
      if (streakDays.contains(dateStr)) {
        currentStreak++;
        dateToCheck = dateToCheck.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
  }

  return HabitStats(last7Days, dailyCompletionData, totalCompletions, currentStreak);
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
