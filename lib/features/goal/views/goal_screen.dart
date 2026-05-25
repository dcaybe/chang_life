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
    final inProgressGoals = ref.watch(inProgressGoalsProvider);
    final completedGoals = ref.watch(completedGoalsProvider);

    return DefaultTabController(
      length: 2,
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'GOALS & ACHIEVEMENTS',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
            centerTitle: true,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
              tabs: [
                Tab(text: 'ACTIVE (${inProgressGoals.length})'),
                Tab(text: 'COMPLETED (${completedGoals.length})'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildGoalList(context, inProgressGoals, 'NO ACTIVE GOALS'),
              _buildGoalList(context, completedGoals, 'NO ACHIEVEMENTS YET. STAY DISCIPLINED!'),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddGoalDialog(context, ref),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            label: const Text('NEW GOAL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            icon: const Icon(Icons.add, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalList(
    BuildContext context,
    List<Goal> goals,
    String emptyMessage,
  ) {
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
            Icon(Icons.flag_sharp, size: 100, color: Colors.grey.shade800),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: isCompleted ? Colors.amber : Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
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
                        goal.title.toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: isCompleted ? Colors.amber : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      const Icon(Icons.military_tech, color: Colors.amber, size: 32)
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: remainingDays > 3 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error),
                        ),
                        child: Text(
                          '$remainingDays DAYS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: remainingDays > 3 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  goal.description,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isCompleted ? 'COMPLETED 🏆' : 'PROGRESS: ${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: isCompleted ? Colors.amber : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${goal.subGoals.where((s) => s.isCompleted).length}/${goal.subGoals.length} TASKS',
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(height: 8, width: double.infinity, color: Theme.of(context).dividerColor),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: 8,
                          width: constraints.maxWidth * (progress > 0 ? progress : 0),
                          color: isCompleted ? Colors.amber : Theme.of(context).colorScheme.primary,
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
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
          ),
          title: Text('NEW GOAL', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Goal Title',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    hintText: 'e.g. Learn Flutter',
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                    hintText: 'Enter goal details',
                    hintStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Deadline', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  trailing: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Theme.of(context).colorScheme.primary,
                              onPrimary: Theme.of(context).colorScheme.onPrimary,
                              surface: Theme.of(context).cardColor,
                              onSurface: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          child: child!,
                        );
                      },
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
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  ref.read(goalVMProvider.notifier).createGoal(
                    title: titleController.text,
                    description: descController.text,
                    deadline: selectedDate,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('ADD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ),
          ],
        ),
      ),
    );
  }
}
