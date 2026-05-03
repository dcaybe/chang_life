import 'package:hive/hive.dart';

part 'meal_plan_model.g.dart';

@HiveType(typeId: 7)
class MealPlan {
  @HiveField(0)
  final String day;
  @HiveField(1)
  final String breakfast;
  @HiveField(2)
  final String lunch;
  @HiveField(3)
  final String snack;
  @HiveField(4)
  final String dinner;
  @HiveField(5)
  final String lateNight;

  MealPlan({
    required this.day,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.dinner,
    required this.lateNight,
  });

  MealPlan copyWith({
    String? day,
    String? breakfast,
    String? lunch,
    String? snack,
    String? dinner,
    String? lateNight,
  }) {
    return MealPlan(
      day: day ?? this.day,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      snack: snack ?? this.snack,
      dinner: dinner ?? this.dinner,
      lateNight: lateNight ?? this.lateNight,
    );
  }
}
