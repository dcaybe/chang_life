import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/providers/nutrition_provider.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/features/nutrition/views/nutrition_design_screen.dart';
import 'package:change_life/features/nutrition/views/meal_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            centerTitle: false,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'CHƯA CÓ LỊCH TRÌNH',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bắt đầu thiết kế dinh dưỡng cho riêng bạn',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.push('/nutrition/design');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    'BẮT ĐẦU',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Theme(
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
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () {
                  context.push('/nutrition/design');
                },
              ),
            ],
            bottom: TabBar(
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
              tabs: const [
                Tab(text: 'HIỆN TẠI'),
                Tab(text: 'LỊCH SỬ'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildCurrentPlanTab(context, ref, mealPlansAsync, storage),
              _buildHistoryTab(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanTab(BuildContext context, WidgetRef ref, AsyncValue<List<MealPlan>> mealPlansAsync, dynamic storage) {
    return mealPlansAsync.when(
      data: (plans) {
        final totalCalories = storage.getNutritionTotalCalories();
        final protein = storage.getNutritionProtein();
        final carbs = storage.getNutritionCarbs();
        final fats = storage.getNutritionFats();

        return DefaultTabController(
          length: plans.length,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildMacroDashboard(
                  context,
                  totalCalories,
                  protein,
                  carbs,
                  fats,
                ),
              ),
              if (plans.length > 1)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: TabBar(
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                    unselectedLabelColor: Colors.grey.shade600,
                    tabs: plans
                        .map(
                          (p) => Tab(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(p.day.toUpperCase()),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              Expanded(
                child: TabBarView(
                  children: plans
                      .map(
                        (plan) => _buildDayView(
                          context,
                          ref,
                          plan,
                          totalCalories,
                          protein,
                          carbs,
                          fats,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      error: (err, stack) => Center(
        child: Text(
          'ERROR: $err',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, WidgetRef ref) {
    final history = ref.watch(nutritionHistoryProvider);
    if (history.isEmpty) {
      return Center(
        child: Text(
          'Chưa có lịch sử lộ trình nào',
          style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final start = '${item.startDate.day}/${item.startDate.month}/${item.startDate.year}';
        final end = '${item.endDate.day}/${item.endDate.month}/${item.endDate.year}';
        final duration = item.endDate.difference(item.startDate).inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade800),
            borderRadius: BorderRadius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TỪ $start - $end',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$duration ngày',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CALORIES', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('${item.totalCalories} kcal', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PROTEIN', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('${item.protein}g', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CARBS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('${item.carbs}g', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FATS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text('${item.fats}g', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayView(
    BuildContext context,
    WidgetRef ref,
    MealPlan plan,
    int totalCalories,
    int protein,
    int carbs,
    int fats,
  ) {
    bool isProteinTooHigh =
        totalCalories > 0 && ((protein * 4) / totalCalories) > 0.3;

    int mealCount = 0;
    if (plan.breakfast.isNotEmpty) mealCount++;
    if (plan.lunch.isNotEmpty) mealCount++;
    if (plan.snack.isNotEmpty) mealCount++;
    if (plan.dinner.isNotEmpty) mealCount++;
    if (plan.lateNight.isNotEmpty) mealCount++;

    int mealCal = mealCount > 0 ? totalCalories ~/ mealCount : 0;
    int mealPro = mealCount > 0 ? protein ~/ mealCount : 0;
    int mealCarb = mealCount > 0 ? carbs ~/ mealCount : 0;
    int mealFat = mealCount > 0 ? fats ~/ mealCount : 0;

    String getShort(String s) => s.split('|SPLIT|').first;
    String getLong(String s) =>
        s.contains('|SPLIT|') ? s.split('|SPLIT|').last : s;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isProteinTooHigh)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lượng protein hiện tại vượt 30% tổng calo. Hãy chú ý uống nhiều nước và bổ sung chất xơ để tránh táo bón và gánh nặng cho thận!',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'MEALS',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        if (plan.breakfast.isNotEmpty)
          _buildMealCard(
            context,
            'Sáng',
            getShort(plan.breakfast),
            Icons.wb_sunny_rounded,
            Theme.of(context).colorScheme.primary,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(
                  title: 'Sáng',
                  content: getLong(plan.breakfast),
                  calories: mealCal,
                  protein: mealPro,
                  carbs: mealCarb,
                  fats: mealFat,
                ),
              ),
            ),
          ),
        if (plan.lunch.isNotEmpty)
          _buildMealCard(
            context,
            'Trưa',
            getShort(plan.lunch),
            Icons.light_mode_rounded,
            Theme.of(context).colorScheme.primary,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(
                  title: 'Trưa',
                  content: getLong(plan.lunch),
                  calories: mealCal,
                  protein: mealPro,
                  carbs: mealCarb,
                  fats: mealFat,
                ),
              ),
            ),
          ),
        if (plan.snack.isNotEmpty)
          _buildMealCard(
            context,
            'Phụ',
            getShort(plan.snack),
            Icons.apple_rounded,
            Theme.of(context).colorScheme.primary,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(
                  title: 'Phụ',
                  content: getLong(plan.snack),
                  calories: mealCal,
                  protein: mealPro,
                  carbs: mealCarb,
                  fats: mealFat,
                ),
              ),
            ),
          ),
        if (plan.dinner.isNotEmpty)
          _buildMealCard(
            context,
            'Tối',
            getShort(plan.dinner),
            Icons.nights_stay_rounded,
            Theme.of(context).colorScheme.primary,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(
                  title: 'Tối',
                  content: getLong(plan.dinner),
                  calories: mealCal,
                  protein: mealPro,
                  carbs: mealCarb,
                  fats: mealFat,
                ),
              ),
            ),
          ),
        if (plan.lateNight.isNotEmpty)
          _buildMealCard(
            context,
            'Đêm',
            getShort(plan.lateNight),
            Icons.bedtime_rounded,
            Theme.of(context).colorScheme.primary,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealDetailScreen(
                  title: 'Đêm',
                  content: getLong(plan.lateNight),
                  calories: mealCal,
                  protein: mealPro,
                  carbs: mealCarb,
                  fats: mealFat,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMacroDashboard(
    BuildContext context,
    int totalCalories,
    int protein,
    int carbs,
    int fats,
  ) {
    int currentCalories = 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY MACROS',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalCalories',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'KCAL',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMacroItem(
                'PROTEIN',
                protein,
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              _buildMacroItem(
                'CARBS',
                carbs,
                Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              _buildMacroItem(
                'FATS',
                fats,
                Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, int total, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${total}g',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
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
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 6, color: color),
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
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                content,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
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
}
