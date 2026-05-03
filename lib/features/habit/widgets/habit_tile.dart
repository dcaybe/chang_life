import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HabitTile extends ConsumerWidget {
  final String id;

  const HabitTile({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitProvider(id));
    final isDoneToday = habit.isCompletedOn(DateTime.now());
    final color = habit.colorValue != null ? Color(habit.colorValue!) : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Dải màu bên trái
              Container(
                width: 6,
                color: isDoneToday ? Colors.grey : color,
              ),
              const SizedBox(width: 12),
              // Checkbox custom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  onTap: isDoneToday 
                    ? null // Khóa không cho sửa nếu đã hoàn thành
                    : () => ref.read(toggleHabitProvider)(id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isDoneToday ? color : Colors.transparent,
                      border: Border.all(
                        color: isDoneToday ? color : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isDoneToday
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nội dung
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: isDoneToday ? TextDecoration.lineThrough : null,
                        color: isDoneToday ? Colors.grey : null,
                      ),
                    ),
                    if (isDoneToday)
                      const Text(
                        'Đã hoàn thành hôm nay',
                        style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                  ],
                ),
              ),
              // Menu nút bấm
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditHabitDialog(context, ref, habit);
                  } else if (value == 'delete') {
                    ref.read(habitVMProvider.notifier).deleteHabit(id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditHabitDialog(BuildContext context, WidgetRef ref, Habit habit) {
    final controller = TextEditingController(text: habit.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa thói quen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tên thói quen...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(habitVMProvider.notifier)
                    .updateHabit(habit.copyWith(name: controller.text));
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

