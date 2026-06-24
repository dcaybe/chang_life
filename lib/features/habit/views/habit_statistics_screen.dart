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

    // Lấy dữ liệu thống kê từ Provider (MVVM-compliant)
    final stats = ref.watch(habitStatisticsProvider);
    final last7Days = stats.last7Days;
    final dailyCompletionData = stats.dailyCompletionData;
    final totalCompletions = stats.totalCompletions;

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
          title: const Text('DISCIPLINE STATS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          centerTitle: true,
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
                  title: 'STREAK',
                  value: stats.currentStreak.toString(),
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  title: 'COMPLETED',
                  value: totalCompletions.toString(),
                  icon: Icons.check_box_sharp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  title: 'HABITS',
                  value: habits.length.toString(),
                  icon: Icons.list_alt_sharp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Biểu đồ ──
            Text(
              'COMPLETION RATE (7 DAYS)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(8, 24, 24, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
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
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: BorderRadius.zero,
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 100,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            // ── Danh sách chi tiết ──
            Text(
              'CONSISTENCY',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            ...habits.map((h) => _HabitSummaryTile(habit: h)).toList(),
          ],
        ),
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

  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.0),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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

  Widget build(BuildContext context) {
    final count = habit.completedDays.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: habit.colorValue != null ? Color(habit.colorValue!).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              shape: BoxShape.rectangle,
              border: Border.all(color: habit.colorValue != null ? Color(habit.colorValue!) : Colors.grey, width: 1),
            ),
            child: Icon(
              Icons.star_sharp,
              color: habit.colorValue != null ? Color(habit.colorValue!) : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, fontSize: 16, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text('COMPLETED $count TIMES', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
