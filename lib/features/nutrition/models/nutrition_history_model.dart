import 'package:hive/hive.dart';
import 'package:change_life/features/nutrition/models/meal_plan_model.dart';

part 'nutrition_history_model.g.dart';

@HiveType(typeId: 9)
class NutritionHistory {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime startDate;
  @HiveField(2)
  final DateTime endDate;
  @HiveField(3)
  final int totalCalories;
  @HiveField(4)
  final int protein;
  @HiveField(5)
  final int carbs;
  @HiveField(6)
  final int fats;
  @HiveField(7)
  final List<MealPlan> mealPlans;

  NutritionHistory({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.totalCalories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.mealPlans,
  });
}
