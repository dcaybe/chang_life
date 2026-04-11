import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:change_life/features/habit/widgets/habit_tile.dart';
import 'package:change_life/features/habit/widgets/test_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  @override
  ConsumerState<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<int>(countComplete, (previous, next) {
      if (next > (previous ?? 0)) {
        // Chỉ hiện Snackbar nếu số task hoàn thành TĂNG lên
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Done task'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
    final storageService = ref.watch(storageServiceProvider);
    final name = storageService.getUsername();
    final habits = ref.watch(habitVMProvider);
    final completed = ref.watch(countComplete);
    final total = habits.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit, Xin chào $name'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(habitVMProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
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
          const SizedBox(height: 20),
          Text(widget.userName),
          // ElevatedButton(
          //   onPressed: () async {
          //     // Lưu tên mới
          //     await storageService.saveUsername('Hung Flutter');
          //     // Ép màn hình vẽ lại để hiển thị tên mới
          //     setState(() {});
          //   },
          //   child: const Text('Đổi tên thành Hung Flutter'),
          // ),
        ],
      ),
    );
  }
}
