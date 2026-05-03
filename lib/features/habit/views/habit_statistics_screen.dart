import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HabitStatisticsScreen extends ConsumerWidget {
  const HabitStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitVMProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // ── Tính toán dữ liệu 7 ngày gần nhất ──
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      return now.subtract(Duration(days: 6 - index));
    });

    final dailyCompletionData = last7Days.map((date) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final total = habits.length;
      if (total == 0) return 0.0;
      final completed = habits.where((h) => h.completedDays.contains(dateStr)).length;
      return (completed / total) * 100;
    }).toList();

    // Tính tổng số lần hoàn thành từ trước đến nay
    final totalCompletions = habits.fold<int>(0, (sum, h) => sum + h.completedDays.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê thói quen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tổng quan ──
            Row(
              children: [
                _StatCard(
                  title: 'Tổng hoàn thành',
                  value: totalCompletions.toString(),
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  title: 'Thói quen đang có',
                  value: habits.length.toString(),
                  icon: Icons.list_alt_rounded,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Biểu đồ ──
            const Text(
              'Tỉ lệ hoàn thành (7 ngày qua)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(8, 24, 24, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = last7Days[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('E').format(date), // T2, T3...
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(dailyCompletionData.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: dailyCompletionData[i],
                          color: colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 100,
                            color: colorScheme.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            // ── Danh sách chi tiết ──
            const Text(
              'Độ kiên trì',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...habits.map((h) => _HabitSummaryTile(habit: h)).toList(),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitSummaryTile extends StatelessWidget {
  final dynamic habit;
  const _HabitSummaryTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final count = habit.completedDays.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: habit.colorValue != null ? Color(habit.colorValue!).withOpacity(0.2) : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              color: habit.colorValue != null ? Color(habit.colorValue!) : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Đã hoàn thành $count lần', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
