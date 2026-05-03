import 'dart:async';
import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/providers/nutrition_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealPlanViewModel extends AutoDisposeAsyncNotifier<List<MealPlan>> {
  @override
  Future<List<MealPlan>> build() async {
    final hiveService = ref.read(nutritionHiveServiceProvider);
    final cached = hiveService.getMealPlans();

    if (cached.isNotEmpty) {
      return cached;
    }

    // Seed initial data from image
    final initialData = [
      MealPlan(
        day: "Thứ 2",
        breakfast: "2 bát cơm + 2 trứng + 1 quýt",
        lunch: "2 bát cơm + 250g gà xào + Rau",
        snack: "1 xoài + 2 thìa bơ đậu phộng",
        dinner: "2 bát cơm + 250g gà + 100g lợn",
        lateNight: "1 lát bánh mì bơ đậu phộng",
      ),
      MealPlan(
        day: "Thứ 3",
        breakfast: "2 bát cơm + 100g lợn kho + 1 quýt",
        lunch: "2 bát cơm + 250g gà luộc + Rau",
        snack: "1/2 dứa + 2 thìa bơ đậu phộng",
        dinner: "2 bát cơm + 250g gà + 150g cá",
        lateNight: "1 thìa bơ đậu phộng + 1 quýt",
      ),
      MealPlan(
        day: "Thứ 4",
        breakfast: "2 bát cơm + 2 trứng xào + 1 quýt",
        lunch: "2 bát cơm + 250g gà áp chảo + Rau",
        snack: "Sinh tố xoài + bơ đậu phộng",
        dinner: "2 bát cơm + 250g gà + 100g lợn",
        lateNight: "1/2 quả dứa",
      ),
      MealPlan(
        day: "Thứ 5",
        breakfast: "2 bát cơm + 150g cá kho + 1 quýt",
        lunch: "2 bát cơm + 250g gà xé + Rau",
        snack: "1 xoài + 2 thìa bơ đậu phộng",
        dinner: "2 bát cơm + 250g gà + 2 trứng",
        lateNight: "1 nắm lạc rang (30g)",
      ),
      MealPlan(
        day: "Thứ 6",
        breakfast: "2 bát cơm + 100g lợn luộc + 1 quýt",
        lunch: "2 bát cơm + 250g gà nướng + Rau",
        snack: "1/2 dứa + 2 thìa bơ đậu phộng",
        dinner: "2 bát cơm + 250g gà + 150g cá",
        lateNight: "1 thìa bơ đậu phộng",
      ),
      MealPlan(
        day: "Thứ 7",
        breakfast: "2 bát cơm + 2 trứng + 1 xoài",
        lunch: "2 bát cơm + 250g gà xào dứa + Rau",
        snack: "1 quýt + 2 thìa bơ đậu phộng",
        dinner: "2 bát cơm + 250g gà + 100g lợn",
        lateNight: "1 nắm lạc hoặc bánh mì",
      ),
      MealPlan(
        day: "Chủ Nhật",
        breakfast: "2 bát cơm + 150g cá chiên + 1 quýt",
        lunch: "2 bát cơm + 250g gà luộc + Rau",
        snack: "Sinh tố xoài dứa + bơ đậu",
        dinner: "2 bát cơm + 250g gà + 100g lợn",
        lateNight: "Trái cây nhẹ",
      ),
    ];

    await hiveService.saveMealPlans(initialData);
    return initialData;
  }

  Future<void> updateMealPlan(MealPlan updatedPlan) async {
    final hiveService = ref.read(nutritionHiveServiceProvider);
    final currentState = state.value ?? [];

    final index = currentState.indexWhere((p) => p.day == updatedPlan.day);
    if (index != -1) {
      final newList = List<MealPlan>.from(currentState);
      newList[index] = updatedPlan;

      await hiveService.saveMealPlans(newList);
      state = AsyncData(newList);
    }
  }
}
