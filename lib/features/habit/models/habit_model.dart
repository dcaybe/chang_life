import 'package:hive/hive.dart';
part 'habit_model.g.dart';

@HiveType(typeId: 1)
class Habit {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final bool isDone; // Trạng thái hoàn thành chung hoặc cho ngày hiện tại
  @HiveField(3)
  final List<String> completedDays; // Lưu danh sách ngày dạng "2024-05-01"
  @HiveField(4)
  final int? colorValue;

  Habit({
    required this.id,
    required this.name,
    this.isDone = false,
    List<String>? completedDays,
    this.colorValue,
  }) : completedDays = completedDays ?? [];

  bool isCompletedOn(DateTime date) {
    final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return completedDays.contains(dateStr);
  }

  Habit copyWith({
    String? name,
    bool? isDone,
    List<String>? completedDays,
    int? colorValue,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
      completedDays: completedDays ?? this.completedDays,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

