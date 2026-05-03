import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:hive/hive.dart';

class NutritionHiveService {
  static const String boxName = 'nutrition_box';

  Future<void> init() async {
    await Hive.openBox<MealPlan>(boxName);
  }

  List<MealPlan> getMealPlans() {
    final box = Hive.box<MealPlan>(boxName);
    return box.values.toList();
  }

  Future<void> saveMealPlans(List<MealPlan> plans) async {
    final box = Hive.box<MealPlan>(boxName);
    await box.clear();
    await box.addAll(plans);
  }
}
