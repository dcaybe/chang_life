import 'package:change_life/features/nutrition/models/food_model.dart';
import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/models/nutrition_history_model.dart';
import 'package:change_life/features/nutrition/viewmodels/food_viewmodel.dart';
import 'package:change_life/features/nutrition/viewmodels/meal_plan_viewmodel.dart';
import 'package:change_life/features/nutrition/providers/nutrition_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final foodVMProvider =
    AsyncNotifierProvider.autoDispose<FoodViewModel, List<Food>>(
      FoodViewModel.new,
    );

final mealPlanVMProvider =
    AsyncNotifierProvider.autoDispose<MealPlanViewModel, List<MealPlan>>(
      MealPlanViewModel.new,
    );

final nutritionHistoryProvider = Provider.autoDispose<List<NutritionHistory>>((ref) {
  final hiveService = ref.watch(nutritionHiveServiceProvider);
  return hiveService.getHistory();
});
