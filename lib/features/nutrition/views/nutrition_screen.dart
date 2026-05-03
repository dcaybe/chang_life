import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/providers/nutrition_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealPlansAsync = ref.watch(mealPlanVMProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Lịch Dinh Dưỡng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
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
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  tabs: plans
                      .map((p) => Tab(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(p.day),
                            ),
                          ))
                      .toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: plans
                      .map((plan) => _buildDayView(context, ref, plan))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }

  Widget _buildDayView(BuildContext context, WidgetRef ref, MealPlan plan) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMealCard(
          context,
          'Sáng',
          plan.breakfast,
          Icons.wb_sunny_rounded,
          Colors.orange,
          () => _showEditDialog(context, ref, plan, 'Sáng', plan.breakfast),
        ),
        _buildMealCard(
          context,
          'Trưa',
          plan.lunch,
          Icons.light_mode_rounded,
          Colors.blue,
          () => _showEditDialog(context, ref, plan, 'Trưa', plan.lunch),
        ),
        _buildMealCard(
          context,
          'Phụ',
          plan.snack,
          Icons.apple_rounded,
          Colors.green,
          () => _showEditDialog(context, ref, plan, 'Phụ', plan.snack),
        ),
        _buildMealCard(
          context,
          'Tối',
          plan.dinner,
          Icons.dark_mode_rounded,
          Colors.indigo,
          () => _showEditDialog(context, ref, plan, 'Tối', plan.dinner),
        ),
        _buildMealCard(
          context,
          'Đêm',
          plan.lateNight,
          Icons.bedtime_rounded,
          Colors.purple,
          () => _showEditDialog(context, ref, plan, 'Đêm', plan.lateNight),
        ),
      ],
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
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
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
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
                                      title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Icon(Icons.edit_rounded,
                                        size: 16, color: color.withOpacity(0.5)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  content,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
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
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, MealPlan plan,
      String mealType, String currentContent) {
    final controller = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sửa $mealType - ${plan.day}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Nhập nội dung bữa ăn",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
