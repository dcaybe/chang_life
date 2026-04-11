import 'package:change_life/features/habit/models/habit.dart';

class HabitService {
  final List<Habit> _habits = [
    Habit(id: '0', name: 'gym', isDone: false),
    Habit(id: '1', name: 'study', isDone: false),
    Habit(id: '2', name: 'eat clean', isDone: false),
  ];

  List<Habit> getHabits() {
    return List.unmodifiable(_habits);
  }

  void toggle(String id) {
    int index = _habits.indexWhere((h) => h.id == id);
    _habits[index] = _habits[index].copyWith(isDone: !_habits[index].isDone);
  }

  void addHabit(String name, String id) {
    _habits.add(Habit(id: id, name: name, isDone: false));
  }

  void removeHabit(int index) {
    _habits.removeAt(index);
  }                  
}
