import 'package:change_life/features/goal/models/goal_model.dart';
import 'package:change_life/features/goal/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class GoalDetailScreen extends ConsumerWidget {
  final Goal goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the goals to get reactive updates
    final goals = ref.watch(goalVMProvider);
    // Find the latest version of this goal from the state
    final currentGoal =
        goals.firstWhere((g) => g.id == goal.id, orElse: () => goal);
    final isCompleted = currentGoal.progress == 1;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(isCompleted ? 'Thành tựu' : 'Chi tiết mục tiêu'),
        elevation: 0,
        backgroundColor: isCompleted ? Colors.amber[700] : null,
        foregroundColor: isCompleted ? Colors.white : null,
        actions: [
          IconButton(
            onPressed: () => _showEditGoalDialog(context, ref, currentGoal),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Sửa thông tin',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, currentGoal, isCompleted),
                  const SizedBox(height: 32),
                  Text(
                    isCompleted ? 'Các nhiệm vụ đã hoàn thành' : 'Nhiệm vụ nhỏ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final subGoal = currentGoal.subGoals[index];
                  return _buildSubGoalTile(
                      context, ref, currentGoal, subGoal, isCompleted);
                },
                childCount: currentGoal.subGoals.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: isCompleted
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddSubGoalDialog(context, ref, currentGoal),
              child: const Icon(Icons.add_task_rounded),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, Goal goal, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompleted)
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_rounded, color: Colors.amber),
                  SizedBox(width: 8),
                  Text('BẠN ĐÃ XUẤT SẮC HOÀN THÀNH!',
                      style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
        Text(
          goal.title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          goal.description,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.amber.withOpacity(0.05)
                : Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: isCompleted
                ? Border.all(color: Colors.amber.withOpacity(0.2))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                context,
                Icons.task_alt_rounded,
                'Số nhiệm vụ',
                '${goal.subGoals.length}',
                isCompleted ? Colors.amber : null,
              ),
              _buildInfoItem(
                context,
                Icons.calendar_month_rounded,
                'Thời gian thực hiện',
                DateFormat('dd/MM/yyyy').format(goal.deadline),
                isCompleted ? Colors.amber : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
      BuildContext context, IconData icon, String label, String value,
      [Color? color]) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Icon(icon, color: primaryColor),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSubGoalTile(BuildContext context, WidgetRef ref, Goal goal,
      SubGoal subGoal, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.amber.withOpacity(0.02)
            : (subGoal.isCompleted
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Theme.of(context).colorScheme.surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Colors.amber.withOpacity(0.1)
              : (subGoal.isCompleted
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
        ),
      ),
      child: CheckboxListTile(
        value: subGoal.isCompleted,
        onChanged: isCompleted
            ? null
            : (value) {
                ref
                    .read(goalVMProvider.notifier)
                    .toggleSubGoal(goal, subGoal.id);
              },
        title: Text(
          subGoal.title,
          style: TextStyle(
            decoration: subGoal.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight:
                subGoal.isCompleted ? FontWeight.normal : FontWeight.w600,
            color: subGoal.isCompleted
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: isCompleted ? Colors.amber : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showAddSubGoalDialog(BuildContext context, WidgetRef ref, Goal goal) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm nhiệm vụ nhỏ'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nhập tên nhiệm vụ'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newSubGoal = SubGoal(
                  id: DateTime.now().toString(),
                  title: controller.text,
                );
                final updatedGoal = goal.copyWith(
                  subGoals: [...goal.subGoals, newSubGoal],
                );
                ref
                    .read(goalVMProvider.notifier)
                    .updateGoal(goal.key, updatedGoal);
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, WidgetRef ref, Goal goal) {
    final titleController = TextEditingController(text: goal.title);
    final descController = TextEditingController(text: goal.description);
    DateTime selectedDate = goal.deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Chỉnh sửa mục tiêu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Tên mục tiêu'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hạn chót',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().isBefore(goal.deadline) 
                          ? DateTime.now() 
                          : goal.deadline.subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final updatedGoal = goal.copyWith(
                    title: titleController.text,
                    description: descController.text,
                    deadline: selectedDate,
                  );
                  ref
                      .read(goalVMProvider.notifier)
                      .updateGoal(goal.key, updatedGoal);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
