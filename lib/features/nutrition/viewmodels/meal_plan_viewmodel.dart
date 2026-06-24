import 'dart:async';
import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/models/nutrition_history_model.dart';
import 'package:change_life/features/nutrition/models/supabase_food_model.dart';
import 'package:change_life/features/nutrition/providers/nutrition_services.dart';
import 'package:change_life/features/nutrition/providers/nutrition_provider.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
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

  Future<void> generateAndSaveMealPlan({
    required int age,
    required double height,
    required double weight,
    required String gender,
    required String goal,
    required String activityLevel,
    required List<SupabaseFood> selectedFoods,
    required int mealsPerDay,
    required int planDays,
  }) async {
    double bmr;
    if (gender == 'Nam') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    double activityMultiplier = 1.55;
    if (activityLevel.contains('Ít')) activityMultiplier = 1.2;
    else if (activityLevel.contains('nhẹ')) activityMultiplier = 1.375;
    else if (activityLevel.contains('vừa')) activityMultiplier = 1.55;
    else if (activityLevel.contains('nhiều')) activityMultiplier = 1.725;
    else if (activityLevel.contains('Rất nhiều')) activityMultiplier = 1.9;

    double tdee = bmr * activityMultiplier;
    int calories = tdee.round();

    if (goal == 'Giảm cân') calories -= 500;
    if (goal == 'Tăng cơ, tăng cân') calories += 500;

    int fat = ((calories * 0.25) / 9).round();
    int protein = (2.2 * weight).round();
    int carb = ((calories - (fat * 9) - (protein * 4)) / 4).round();

    final storage = ref.read(storageServiceProvider);
    final hiveService = ref.read(nutritionHiveServiceProvider);

    // Save previous to history if exists
    if (storage.hasConfiguredNutrition()) {
      final prevPlans = hiveService.getMealPlans();
      if (prevPlans.isNotEmpty) {
        final startDate = storage.getNutritionStartDate() ?? DateTime.now().subtract(const Duration(days: 1));
        final history = NutritionHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          startDate: startDate,
          endDate: DateTime.now(),
          totalCalories: storage.getNutritionTotalCalories(),
          protein: storage.getNutritionProtein(),
          carbs: storage.getNutritionCarbs(),
          fats: storage.getNutritionFats(),
          mealPlans: List.from(prevPlans),
        );
        await hiveService.addHistory(history);
        ref.invalidate(nutritionHistoryProvider);
      }
    }

    await storage.setNutritionTotalCalories(calories);
    await storage.setNutritionFats(fat);
    await storage.setNutritionProtein(protein);
    await storage.setNutritionCarbs(carb);
    await storage.setHasConfiguredNutrition(true);
    await storage.setNutritionStartDate(DateTime.now());

    final days = List.generate(planDays, (i) => 'Ngày ${i + 1}');
    final List<MealPlan> newPlans = [];

    final carbs = selectedFoods.where((f) => f.category.contains('Ngũ cốc') || f.category.contains('Khoai')).toList();
    if (carbs.isEmpty) {
      carbs.add(SupabaseFood(id: 'default_carb', code: '', nameVi: 'Cơm trắng', nameEn: '', category: 'Ngũ cốc', energy: 130, protein: 2.7, carb: 28.0, fat: 0.3));
    }

    final proteins = selectedFoods.where((f) => f.category.contains('Thịt') || f.category.contains('Thủy sản') || f.category.contains('Trứng')).toList();
    if (proteins.isEmpty) {
      proteins.add(SupabaseFood(id: 'default_pro', code: '', nameVi: 'Ức gà', nameEn: '', category: 'Thịt', energy: 120, protein: 22.5, carb: 0, fat: 2.6));
    }

    final others = selectedFoods.where((f) => !carbs.contains(f) && !proteins.contains(f)).toList();
    if (others.isEmpty) {
      others.add(SupabaseFood(id: 'default_other', code: '', nameVi: 'Rau xanh (các loại)', nameEn: '', category: 'Rau', energy: 20, protein: 2.0, carb: 4.0, fat: 0.0));
    }

    double remainingPro = protein.toDouble();
    double remainingCarb = carb.toDouble();

    if (mealsPerDay >= 4) {
      remainingPro -= protein * 0.1;
      remainingCarb -= carb * 0.1;
    }
    if (mealsPerDay == 5) {
      remainingPro -= protein * 0.1;
      remainingCarb -= carb * 0.1;
    }

    double mealPro = remainingPro / 3;
    double mealCarb = remainingCarb / 3;

    String formatFood(SupabaseFood food, double weight) {
      final cal = ((food.energy ?? 0) * weight / 100).round();
      final pro = ((food.protein ?? 0) * weight / 100).toStringAsFixed(1);
      final c = ((food.carb ?? 0) * weight / 100).toStringAsFixed(1);
      final f = ((food.fat ?? 0) * weight / 100).toStringAsFixed(1);
      return '• ${food.nameVi} (${weight.round()}g)\n   $cal kcal | P: ${pro}g | C: ${c}g | F: ${f}g';
    }

    String generateMainMeal(SupabaseFood carbFood, SupabaseFood proFood, SupabaseFood otherFood) {
      double carbWeight = 0;
      if (carbFood.carb != null && carbFood.carb! > 0) {
        carbWeight = (mealCarb / carbFood.carb!) * 100;
      }
      if (carbWeight.isNaN || carbWeight.isInfinite || carbWeight == 0) carbWeight = 150;
      
      double proWeight = 0;
      if (proFood.protein != null && proFood.protein! > 0) {
        proWeight = (mealPro / proFood.protein!) * 100;
      }
      if (proWeight.isNaN || proWeight.isInfinite || proWeight == 0) proWeight = 150;
      double otherWeight = 100; // Standard 100g veggies

      String shortDesc = '1 phần ${carbFood.nameVi} + 1 phần ${proFood.nameVi} + ${otherFood.nameVi}';
      String detailedDesc = '${formatFood(carbFood, carbWeight)}\n${formatFood(proFood, proWeight)}\n${formatFood(otherFood, otherWeight)}';

      return '$shortDesc|SPLIT|$detailedDesc';
    }

    final defaultSnack1 = SupabaseFood(id: 's1', code: '', nameVi: 'Chuối', nameEn: '', category: '', energy: 89, protein: 1.1, carb: 23, fat: 0.3);
    final defaultSnack2 = SupabaseFood(id: 's2', code: '', nameVi: 'Lạc rang', nameEn: '', category: '', energy: 567, protein: 26, carb: 16, fat: 49);

    for (int i = 0; i < days.length; i++) {
      String day = days[i];
      String breakfast = '';
      String lunch = '';
      String snack = '';
      String dinner = '';
      String lateNight = '';
      
      SupabaseFood selectedCarb1 = carbs[i % carbs.length];
      SupabaseFood selectedCarb2 = carbs[(i + 1) % carbs.length];
      SupabaseFood selectedProtein1 = proteins[i % proteins.length];
      SupabaseFood selectedProtein2 = proteins[(i + 1) % proteins.length];
      SupabaseFood selectedOther = others[i % others.length];

      breakfast = generateMainMeal(selectedCarb1, selectedProtein1, selectedOther);
      lunch = generateMainMeal(selectedCarb2, selectedProtein2, selectedOther);
      dinner = generateMainMeal(selectedCarb1, selectedProtein1, selectedOther);

      if (mealsPerDay >= 4) {
        snack = '1 phần Trái cây/Đồ ăn nhẹ|SPLIT|${formatFood(defaultSnack1, 150)}\n${formatFood(defaultSnack2, 30)}';
      }
      if (mealsPerDay == 5) {
        lateNight = '1 phần ăn nhẹ trước khi ngủ|SPLIT|${formatFood(defaultSnack1, 100)}\n${formatFood(defaultSnack2, 20)}';
      }

      newPlans.add(MealPlan(
        day: day,
        breakfast: breakfast,
        lunch: lunch,
        snack: snack,
        dinner: dinner,
        lateNight: lateNight,
      ));
    }

    await hiveService.saveMealPlans(newPlans);
    state = AsyncData(newPlans);
  }
}
