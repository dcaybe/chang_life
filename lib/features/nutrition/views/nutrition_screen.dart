import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(foodVMProvider, (previous, next) {
      // Nếu có lỗi, VÀ không ở trạng thái Loading
      if (next.hasError && !next.isLoading) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Có lỗi xảy ra'),
              content: Text(next.error.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      }
    });
    final foods = ref.watch(foodVMProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(foodVMProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: foods.when(
          data: (data) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final food = data[index];
                return ListTile(
                  title: Text(food.name),
                  subtitle: Text('${food.calories} calories'),
                  onTap: () {
                    context.push('/nutrition/detail', extra: food);
                  },
                );
              },
            );
          },
          error: (error, stack) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text('Đã có lỗi xảy ra: $error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(foodVMProvider),
                  child: const Text('Thử lại'),
                ),
              ],
            );
          },
          loading: () {
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
