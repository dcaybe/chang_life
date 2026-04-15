import 'package:change_life/features/habit/models/habit.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HabitService {
  final SharedPreferences _prefs;
  final List<Habit> _habits = [];
  HabitService(this._prefs) {
    _loadFromStorage();
  }
  void _loadFromStorage() {
    // 1. Đọc String từ key 'habits'.
    final String? jsonString = _prefs.getString('habits');
    // 2. Nếu String != null => jsonDecode => ép kiểu List => map Habit.fromJson => gán vô _habits.
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      _habits.addAll(decodedList.map((e) => Habit.fromJson(e)));
    }
    // 3. Nếu null => gán 3 cái mẫu cho _habits.
    else {
      _habits.addAll([
        Habit(id: '1', name: 'Đọc sách', isDone: false),
        Habit(id: '2', name: 'Tập thể dục', isDone: false),
        Habit(id: '3', name: 'Ăn uống lành mạnh', isDone: false),
      ]);
    }
  }

  List<Habit> getHabits() {
    return List.unmodifiable(_habits);
  }

  void toggle(String id) {
    int index = _habits.indexWhere((h) => h.id == id);
    _habits[index] = _habits[index].copyWith(isDone: !_habits[index].isDone);
    _saveToStorage();
  }

  void addHabit(String name, String id) {
    _habits.add(Habit(id: id, name: name, isDone: false));
    _saveToStorage();
  }

  void removeHabit(int index) {
    _habits.removeAt(index);
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    // 1. Map danh sách _habits thành danh sách JSON Map (dùng toJson)
    final List<Map<String, dynamic>> jsonList = _habits
        .map((h) => h.toJson())
        .toList();
    // 2. Dùng jsonEncode biến danh sách trên thành chuỗi String.
    final String jsonString = jsonEncode(jsonList);
    // 3. Cất chuỗi String vào ổ cứng với key 'habits'.
    await _prefs.setString('habits', jsonString);
  }

  // Các hàm cũ: getHabits, toggle, addHabit, removeHabit...
  // CHÚ Ý: Bên trong hàm add, remove, toggle, sau khi làm xong phải gọi _saveToStorage() !
}
