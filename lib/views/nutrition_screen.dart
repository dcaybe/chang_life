import 'package:change_life/providers/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
