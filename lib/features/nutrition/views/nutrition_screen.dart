import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/providers/nutrition_provider.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/features/nutrition/views/nutrition_design_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final hasConfigured = storage.hasConfiguredNutrition();
    final mealPlansAsync = ref.watch(mealPlanVMProvider);

    if (!hasConfigured) {
      return Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'NUTRITION PLAN',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'CHƯA CÓ LỊCH TRÌNH',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bắt đầu thiết kế dinh dưỡng cho riêng bạn',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionDesignScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('BẮT ĐẦU', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'NUTRITION PLAN',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          centerTitle: true,
        ),
        body: mealPlansAsync.when(
          data: (plans) => DefaultTabController(
            length: plans.length,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: TabBar(
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    unselectedLabelColor: Colors.grey.shade600,
                    tabs: plans
                        .map((p) => Tab(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(p.day.toUpperCase()),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: plans
                        .map((plan) => _buildDayView(context, ref, plan, storage.getNutritionTotalCalories()))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
          error: (err, stack) => Center(child: Text('ERROR: $err', style: TextStyle(color: Theme.of(context).colorScheme.error))),
        ),
      ),
    );
  }

  Widget _buildDayView(BuildContext context, WidgetRef ref, MealPlan plan, int totalCalories) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMacroDashboard(context, totalCalories),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text('MEALS', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
        if (plan.breakfast.isNotEmpty) _buildMealCard(
          context,
          'Sáng',
          plan.breakfast,
          Icons.wb_sunny_rounded,
          Theme.of(context).colorScheme.primary,
          () => _showEditDialog(context, ref, plan, 'Sáng', plan.breakfast),
        ),
        if (plan.lunch.isNotEmpty) _buildMealCard(
          context,
          'Trưa',
          plan.lunch,
          Icons.light_mode_rounded,
          Theme.of(context).colorScheme.primary,
          () => _showEditDialog(context, ref, plan, 'Trưa', plan.lunch),
        ),
        if (plan.snack.isNotEmpty) _buildMealCard(
          context,
          'Phụ/Trước tập',
          plan.snack,
          Icons.fitness_center_rounded,
          Theme.of(context).colorScheme.primary,
          () => _showEditDialog(context, ref, plan, 'Phụ', plan.snack),
        ),
        if (plan.dinner.isNotEmpty) _buildMealCard(
          context,
          'Tối',
          plan.dinner,
          Icons.dark_mode_rounded,
          Theme.of(context).colorScheme.primary,
          () => _showEditDialog(context, ref, plan, 'Tối', plan.dinner),
        ),
        if (plan.lateNight.isNotEmpty) _buildMealCard(
          context,
          'Đêm',
          plan.lateNight,
          Icons.bedtime_rounded,
          Theme.of(context).colorScheme.primary,
          () => _showEditDialog(context, ref, plan, 'Đêm', plan.lateNight),
        ),
      ],
    );
  }

  Widget _buildMacroDashboard(BuildContext context, int totalCalories) {
    int currentCalories = (totalCalories * 0.7).round(); // Mock progress
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY MACROS',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currentCalories',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 40, fontWeight: FontWeight.w900, height: 1.0),
              ),
              Text(
                '/ $totalCalories KCAL',
                style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalCalories == 0 ? 0 : currentCalories / totalCalories,
            backgroundColor: Colors.grey.shade900,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            minHeight: 8,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMacroItem('PROTEIN', 120, 160, Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              _buildMacroItem('CARBS', 180, 250, Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              _buildMacroItem('FATS', 45, 70, Theme.of(context).colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, int current, int total, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text('$current/${total}g', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: current / total,
            backgroundColor: Colors.grey.shade900,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  color: color,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.rectangle,
                            border: Border.all(color: color),
                          ),
                          child: Icon(icon, color: color, size: 28),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    title.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: color,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    color: color,
                                    child: Text('ADD', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                content,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, MealPlan plan,
      String mealType, String currentContent) {
    final controller = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
        ),
        title: Text('EDIT $mealType - ${plan.day}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Enter meal details",
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
            filled: true,
            fillColor: Colors.transparent,
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              final updatedContent = controller.text;
              MealPlan updatedPlan;
              switch (mealType) {
                case 'Sáng':
                  updatedPlan = plan.copyWith(breakfast: updatedContent);
                  break;
                case 'Trưa':
                  updatedPlan = plan.copyWith(lunch: updatedContent);
                  break;
                case 'Phụ':
                  updatedPlan = plan.copyWith(snack: updatedContent);
                  break;
                case 'Tối':
                  updatedPlan = plan.copyWith(dinner: updatedContent);
                  break;
                case 'Đêm':
                  updatedPlan = plan.copyWith(lateNight: updatedContent);
                  break;
                default:
                  updatedPlan = plan;
              }
              ref.read(mealPlanVMProvider.notifier).updateMealPlan(updatedPlan);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }
}
