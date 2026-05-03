import 'package:change_life/features/habit/models/habit_model.dart';
import 'package:flutter/material.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final color = habit.colorValue != null ? Color(habit.colorValue!) : Theme.of(context).colorScheme.primary;
    final completedDays = habit.completedDays.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết thói quen'),
        backgroundColor: Colors.transparent,
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
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    habit.name,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tổng cộng ${habit.completedDays.length} lần hoàn thành',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Lịch sử gần đây',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (completedDays.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('Chưa có dữ liệu hoàn thành.', style: TextStyle(color: Colors.grey)),
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
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available, color: Colors.green, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          completedDays[index],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        const Text('Thành công', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}


