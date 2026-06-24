import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/models/nutrition_history_model.dart';
import 'package:hive/hive.dart';

class NutritionHiveService {
  static const String boxName = 'nutrition_box';
  static const String historyBoxName = 'nutrition_history_box';

  Future<void> init() async {
    await Hive.openBox<MealPlan>(boxName);
    await Hive.openBox<NutritionHistory>(historyBoxName);
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

  List<NutritionHistory> getHistory() {
    final box = Hive.box<NutritionHistory>(historyBoxName);
    final history = box.values.toList();
    history.sort((a, b) => b.startDate.compareTo(a.startDate)); // descending
    return history;
  }

  Future<void> addHistory(NutritionHistory history) async {
    final box = Hive.box<NutritionHistory>(historyBoxName);
    await box.put(history.id, history);
  }
}
