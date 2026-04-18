import 'package:change_life/features/habit/models/habit.dart';
import 'package:hive/hive.dart';

class HabitHiveService {
  late Box<Habit> habitBox;

  Future<void> init() async {
    habitBox = await Hive.openBox<Habit>('habitBox');
  }

  void addHabit(Habit habit) {
    habitBox.add(habit);
  }

  List<Habit> getHabits() {
    if (habitBox.isEmpty) {
      final defaultHabits = [
        Habit(id: '1', name: 'Đọc sách', isDone: false),
        Habit(id: '2', name: 'Tập thể dục', isDone: false),
        Habit(id: '3', name: 'Ăn uống lành mạnh', isDone: false),
      ];
      habitBox.addAll(defaultHabits);
      return defaultHabits;
    }
    return habitBox.values.toList();
  }

  void toggle(String id) {
    final habits = habitBox.values.toList();
    int index = habits.indexWhere((h) => h.id == id);
    if (index != -1) {
      final habit = habits[index];
      habitBox.putAt(
        index,
        habit.copyWith(isDone: !habit.isDone),
      );
    }
  }


  void removeHabit(int index) {
    habitBox.deleteAt(index);
  }

  Box<Habit> getBox() {
    return habitBox;
  }
}
