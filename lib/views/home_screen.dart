import 'package:change_life/providers/habit_provider.dart';
import 'package:change_life/widgets/habit_tile.dart';
import 'package:change_life/widgets/test_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitVMProvider);
    final completed = ref.watch(countComplete);
    final total = habits.length;
    return Column(
      children: [
        const SizedBox(height: 20),
        Text('$completed/$total'),
        Expanded(
          child: ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitTile(id: habit.id);
            },
          ),
        ),
        const SizedBox(height: 20),
        Text('Test Async'),
        TestAsync(),
      ],
    );
  }
}
