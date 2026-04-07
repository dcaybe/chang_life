import 'package:change_life/providers/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestAsync extends ConsumerWidget {
  const TestAsync({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testAsync = ref.watch(testProvider);

    return testAsync.when(
      data: (v) => Text(v.length.toString()),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text("Lỗi: $e"),
    );
  }
}
