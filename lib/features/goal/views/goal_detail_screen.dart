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
            isCompleted ? 'ACHIEVEMENT' : 'GOAL DETAIL',
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          backgroundColor: isCompleted ? Colors.amber[900] : Theme.of(context).scaffoldBackgroundColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          actions: [
            IconButton(
              onPressed: () => _showEditGoalDialog(context, ref, currentGoal),
              icon: const Icon(Icons.edit_sharp),
              color: isCompleted ? Colors.white : Theme.of(context).colorScheme.primary,
              tooltip: 'Edit Goal',
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
                    isCompleted ? 'COMPLETED TASKS' : 'SUB TASKS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: Theme.of(context).colorScheme.onSurface,
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: const Icon(Icons.add_sharp, size: 28),
            ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Goal goal, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCompleted)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: Colors.amber, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_sharp, color: Colors.amber),
                SizedBox(width: 8),
                Text('OUTSTANDING ACHIEVEMENT!',
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        fontSize: 12)),
              ],
            ),
          ),
        Text(
          goal.title.toUpperCase(),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          goal.description,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.zero,
            border: Border.all(
              color: isCompleted ? Colors.amber : Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                context,
                Icons.check_box_sharp,
                'TASKS',
                '${goal.subGoals.length}',
                isCompleted ? Colors.amber : Theme.of(context).colorScheme.primary,
              ),
              _buildInfoItem(
                context,
                Icons.calendar_month_sharp,
                'DEADLINE',
                DateFormat('dd/MM/yyyy').format(goal.deadline),
                isCompleted ? Colors.amber : Theme.of(context).colorScheme.primary,
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
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSubGoalTile(BuildContext context, WidgetRef ref, Goal goal,
      SubGoal subGoal, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isCompleted
              ? Colors.amber
              : (subGoal.isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade800),
          width: 1,
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
          subGoal.title.toUpperCase(),
          style: TextStyle(
            decoration: subGoal.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: subGoal.isCompleted
                ? Colors.grey.shade600
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: isCompleted ? Colors.amber : Theme.of(context).colorScheme.primary,
        checkColor: Theme.of(context).colorScheme.onPrimary,
        side: const BorderSide(color: Colors.grey, width: 2),
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
                ref
                    .read(goalVMProvider.notifier)
                    .addSubGoal(goal, controller.text);
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
