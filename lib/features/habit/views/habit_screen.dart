import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:change_life/features/habit/widgets/habit_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitVMProvider);
    final now = DateTime.now();
    
    // Tính toán tỉ lệ hoàn thành hôm nay
    final completedToday = habits.where((h) => h.isCompletedOn(now)).length;
    final total = habits.length;
    final progress = total > 0 ? completedToday / total : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header với Tiến độ ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Tiến độ hôm nay',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đã hoàn thành $completedToday/$total thói quen',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                onPressed: () {
                  context.push('/habit/statistics');
                },
              ),
            ],
          ),

          // ── Danh sách thói quen ──
          SliverPadding(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            sliver: habits.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.spa_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('Bắt đầu một thói quen mới ngay!', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => HabitTile(id: habits[index].id),
                      childCount: habits.length,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context, ref),
        label: const Text('Thêm thói quen'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thói quen mới'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'VD: Chạy bộ 30 phút...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Habit newHabit = Habit(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: controller.text,
                  colorValue: Colors.primaries[DateTime.now().millisecond % Colors.primaries.length].value,
                );
                ref.read(habitVMProvider.notifier).addHabit(newHabit);
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}

