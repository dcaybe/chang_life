import 'package:change_life/features/goal/models/goal_model.dart';
import 'package:change_life/features/goal/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class GoalScreen extends ConsumerWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalVMProvider);
    final inProgressGoals = goals.where((g) => g.progress < 1).toList();
    final completedGoals = goals.where((g) => g.progress == 1 && g.subGoals.isNotEmpty).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text(
            'Mục tiêu & Thành tựu',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Đang thực hiện (${inProgressGoals.length})'),
              Tab(text: 'Thành tựu (${completedGoals.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGoalList(context, inProgressGoals, 'Chưa có mục tiêu nào đang thực hiện'),
            _buildGoalList(context, completedGoals, 'Chưa có thành tựu nào. Hãy cố gắng hoàn thành mục tiêu!'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddGoalDialog(context, ref),
          label: const Text('Thêm mục tiêu'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildGoalList(BuildContext context, List<Goal> goals, String emptyMessage) {
    if (goals.isEmpty) {
      return _buildEmptyState(context, emptyMessage);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(context, goal);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.military_tech_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal) {
    final progress = goal.progress;
    final remainingDays = goal.remainingDays;
    final isCompleted = progress == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isCompleted 
                ? Colors.amber.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isCompleted
              ? Colors.amber.withOpacity(0.3)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/goal/detail', extra: goal),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? Colors.amber[800] : null,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 28)
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: remainingDays > 3
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$remainingDays ngày còn lại',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  remainingDays > 3 ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goal.description,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCompleted ? 'ĐÃ HOÀN THÀNH 🏆' : 'Tiến độ: ${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCompleted ? Colors.amber[900] : null,
                        ),
                      ),
                      Text(
                        '${goal.subGoals.where((s) => s.isCompleted).length}/${goal.subGoals.length} nhiệm vụ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isCompleted 
                              ? Colors.amber.withOpacity(0.1)
                              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: 8,
                            width: constraints.maxWidth *
                                (progress > 0 ? progress : 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isCompleted
                                    ? [Colors.amber, Colors.orange]
                                    : [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.secondary,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Thêm mục tiêu mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tên mục tiêu',
                    hintText: 'Ví dụ: Học Flutter',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    hintText: 'Nhập mục tiêu cụ thể của bạn',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Hạn chót',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                  trailing: Icon(Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
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
                  final newGoal = Goal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: descController.text,
                    deadline: selectedDate,
                    subGoals: [],
                  );
                  ref.read(goalVMProvider.notifier).addGoal(newGoal);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }
}
