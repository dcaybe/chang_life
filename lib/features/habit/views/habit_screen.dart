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
    // Lấy tỉ lệ hoàn thành hôm nay từ Provider (MVVM)
    final progress = ref.watch(habitProgressProvider);
    final completedToday = ref.watch(countComplete);
    final total = habits.length;
    final stats = ref.watch(habitStatisticsProvider);

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
          title: Text(
            'HABITS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: false,
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.bar_chart_sharp, color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                context.push('/habit/statistics');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Header với Tiến độ ──
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TODAY\'S DISCIPLINE',
                      style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade900,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      minHeight: 12,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'COMPLETED $completedToday/$total HABITS',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.currentStreak} DAY STREAK',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Danh sách thói quen ──
            Expanded(
              child: habits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, size: 64, color: Colors.grey.shade800),
                          const SizedBox(height: 16),
                          Text('START BUILDING DISCIPLINE', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 80, left: 16, right: 16),
                      itemCount: habits.length,
                      itemBuilder: (context, index) => HabitTile(id: habits[index].id),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddHabitDialog(context, ref),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          label: const Text('NEW HABIT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          icon: const Icon(Icons.add, size: 24),
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
        ),
        title: Text('NEW HABIT', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 50,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'e.g. Run 5km...',
            hintStyle: const TextStyle(color: Colors.grey),
            counterStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    content: Text(
                      'HABIT NAME CANNOT BE EMPTY',
                      style: TextStyle(color: Theme.of(context).colorScheme.onError, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                  ),
                );
                return;
              }
              ref.read(habitVMProvider.notifier).createHabit(name);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }
}

