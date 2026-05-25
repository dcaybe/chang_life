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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isDoneToday ? Theme.of(context).dividerColor : color,
          width: 1,
        ),
      ),
      child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dải màu bên trái
              Container(
                width: 6,
                color: isDoneToday ? Colors.grey : color,
              ),
              // Nội dung chính
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 16, bottom: 16, right: 4),
                  child: Row(
                    children: [
                      // Checkbox custom
                      GestureDetector(
                        onTap: isDoneToday 
                          ? null // Khóa không cho sửa nếu đã hoàn thành
                          : () => ref.read(toggleHabitProvider)(id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDoneToday ? Theme.of(context).dividerColor : Colors.transparent,
                            border: Border.all(
                              color: isDoneToday ? Theme.of(context).dividerColor : color,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: isDoneToday
                              ? Icon(Icons.check_sharp, color: Theme.of(context).scaffoldBackgroundColor, size: 20)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Nội dung
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                decoration: isDoneToday ? TextDecoration.lineThrough : null,
                                color: isDoneToday ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (isDoneToday)
                              const Padding(
                                padding: EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'COMPLETED',
                                  style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Menu nút bấm
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert_sharp, size: 20, color: isDoneToday ? Colors.grey : color),
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: Theme.of(context).colorScheme.primary)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditHabitDialog(context, ref, habit);
                          } else if (value == 'delete') {
                            _showDeleteConfirmDialog(context, ref);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: 'edit', child: Text('EDIT', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold))),
                          PopupMenuItem(
                              value: 'delete',
                              child: Text('DELETE', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  void _showEditHabitDialog(BuildContext context, WidgetRef ref, Habit habit) {
    final controller = TextEditingController(text: habit.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
        ),
        title: Text('EDIT HABIT', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: 'Habit Name...',
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(habitVMProvider.notifier)
                    .updateHabit(habit.copyWith(name: controller.text));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Theme.of(context).colorScheme.error, width: 1),
        ),
        title: Text(
          'DELETE HABIT?',
          style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        content: const Text(
          'This action cannot be undone. All completion history will be permanently deleted.',
          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(habitVMProvider.notifier).deleteHabit(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('DELETE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }
}
