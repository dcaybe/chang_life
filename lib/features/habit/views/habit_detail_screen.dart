import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final color = habit.colorValue != null ? Color(habit.colorValue!) : Theme.of(context).colorScheme.primary;
    final completedDays = habit.completedDays.reversed.toList();

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
          title: const Text('HABIT DETAIL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.zero,
                  border: Border.all(color: color, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(Icons.star_sharp, color: color, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      habit.name.toUpperCase(),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TOTAL ${habit.completedDays.length} COMPLETIONS',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text(
                'RECENT HISTORY',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
            
              if (completedDays.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('NO DATA YET', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: completedDays.length > 10 ? 10 : completedDays.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(color: Colors.grey.shade800),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_box_sharp, color: color, size: 20),
                          const SizedBox(width: 16),
                          Text(
                            _formatDate(completedDays[index]),
                            style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.0),
                          ),
                          const Spacer(),
                          Text('✓ DONE', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(date.year, date.month, date.day);
      final diff = today.difference(target).inDays;
      if (diff == 0) return 'TODAY ✓';
      if (diff == 1) return 'YESTERDAY';
      return DateFormat('EEE, MMM d').format(date).toUpperCase();
    } catch (_) {
      return dateStr;
    }
  }
}


