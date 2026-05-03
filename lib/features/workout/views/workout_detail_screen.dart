import 'package:change_life/features/workout/models/exercise_model.dart';
import 'package:change_life/features/workout/models/workout_model.dart';
import 'package:change_life/features/workout/providers/workout_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _VolumePoint {
  final DateTime date;
  final double volume;
  const _VolumePoint({required this.date, required this.volume});
}

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────
class WorkoutDetailScreen extends ConsumerWidget {
  final WorkoutSession session;
  const WorkoutDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Lấy lại session mới nhất từ provider thay vì dùng giá trị khởi tạo
    final latestSession = ref
        .watch(workoutViewModelProvider)
        .firstWhere(
          (w) => w.id == session.id,
          orElse: () => session, // Fallback nếu bị xoá
        );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          latestSession.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar_outlined),
            tooltip: 'Chỉnh sửa kế hoạch',
            onPressed: () {
              final notifier =
                  ref.read(activeWorkoutViewModelProvider.notifier);
              notifier.startSession(latestSession);
              if (!ref.read(activeWorkoutViewModelProvider).isEditMode) {
                notifier.toggleEditMode();
              }
              context.push('/workout/active');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // ── Summary chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SummaryRow(session: latestSession),
          ),

          // ── Bắt đầu tập button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text(
                'Bắt đầu tập ngay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final notifier = ref.read(
                  activeWorkoutViewModelProvider.notifier,
                );
                notifier.startSession(latestSession);
                if (ref.read(activeWorkoutViewModelProvider).isEditMode) {
                  notifier.toggleEditMode();
                }
                context.push('/workout/active');
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(),
          ),

          // ── Exercise cards ──
          ...latestSession.exerciseLogs.asMap().entries.map((entry) {
            return _ExerciseDetailCard(log: entry.value, index: entry.key);
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Summary row — tổng số sets, volume
// ─────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final WorkoutSession session;
  const _SummaryRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final totalSets = session.exerciseLogs.fold(
      0,
      (sum, log) => sum + log.sets.length,
    );

    final totalVolume = session.exerciseLogs.fold(0.0, (sum, log) {
      return sum + log.sets.fold(0.0, (s, set) => s + set.weight * set.reps);
    });

    return Row(
      children: [
        _Chip(
          icon: Icons.repeat_rounded,
          label: '$totalSets sets',
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        _Chip(
          icon: Icons.monitor_weight_outlined,
          label: '${totalVolume.toStringAsFixed(0)} kg vol',
          color: Colors.orange,
        ),
        const SizedBox(width: 8),
        _Chip(
          icon: Icons.timer_outlined,
          label: '~${(totalSets * 1.5).toStringAsFixed(0)} phút',
          color: Colors.green,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Exercise Detail Card — hiển thị bảng sets + biểu đồ
// ─────────────────────────────────────────────────────────────
class _ExerciseDetailCard extends ConsumerStatefulWidget {
  final ExerciseLog log;
  final int index;
  const _ExerciseDetailCard({required this.log, required this.index});

  @override
  ConsumerState<_ExerciseDetailCard> createState() =>
      _ExerciseDetailCardState();
}

class _ExerciseDetailCardState extends ConsumerState<_ExerciseDetailCard> {
  bool _showChart = false;

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final colorScheme = Theme.of(context).colorScheme;

    // Get historical volume data
    final workoutHiveService = ref.read(workoutHiveServiceProvider);
    final allSessions = workoutHiveService.getWorkouts();

    final historyLogs = <_VolumePoint>[];
    final completedSessions = allSessions
        .where((s) => s.dateCompleted != null)
        .toList();
    completedSessions.sort(
      (a, b) => a.dateCompleted!.compareTo(b.dateCompleted!),
    );

    for (var session in completedSessions) {
      final exerciseLogs = session.exerciseLogs.where(
        (l) => l.exercise.name == log.exercise.name,
      );
      for (var exLog in exerciseLogs) {
        if (exLog.totalVolume > 0) {
          historyLogs.add(
            _VolumePoint(
              date: session.dateCompleted!,
              volume: exLog.totalVolume,
            ),
          );
        }
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header bài tập ──
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.exercise.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (log.exercise.targetMuscle.isNotEmpty)
                        Text(
                          log.exercise.targetMuscle,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                // Nút toggle biểu đồ
                TextButton.icon(
                  onPressed: () => setState(() => _showChart = !_showChart),
                  icon: Icon(
                    _showChart ? Icons.bar_chart : Icons.bar_chart_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _showChart ? 'Ẩn' : 'Lịch sử',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Ghi chú bài tập ──
            if (log.notes.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, size: 14, color: Colors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        log.notes,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Bảng Sets ──
            _SetTable(log: log),

            // ── Biểu đồ lịch sử (toggle) ──
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _showChart
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: _VolumeChart(
                        exerciseName: log.exercise.name,
                        history: historyLogs,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Set Table
// ─────────────────────────────────────────────────────────────
class _SetTable extends StatelessWidget {
  final ExerciseLog log;
  const _SetTable({required this.log});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          children: const [
            _THeader('Set'),
            _THeader('Weight'),
            _THeader('Reps'),
            _THeader('1RM'),
          ],
        ),
        // Data rows
        ...log.sets.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          final oneRM = (s.weight * (1 + s.reps / 30)).toStringAsFixed(1);
          return TableRow(
            decoration: BoxDecoration(
              color: i.isOdd ? Colors.grey.withOpacity(0.04) : null,
            ),
            children: [
              _TCell('${i + 1}', bold: true),
              _TCell('${s.weight}kg'),
              _TCell('${s.reps}'),
              _TCell(oneRM, color: Colors.blue, isPR: s.isPR == true),
            ],
          );
        }),
      ],
    );
  }
}

class _THeader extends StatelessWidget {
  final String text;
  const _THeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TCell extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;
  final bool isPR;
  const _TCell(this.text, {this.bold = false, this.color, this.isPR = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          if (isPR == true)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.workspace_premium,
                color: Colors.amber,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Volume Progression Line Chart
// ─────────────────────────────────────────────────────────────
class _VolumeChart extends StatelessWidget {
  final String exerciseName;
  final List<_VolumePoint> history;

  const _VolumeChart({required this.exerciseName, required this.history});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (history.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text('Chưa có dữ liệu lịch sử'),
      );
    }

    final maxY =
        (history.map((h) => h.volume).reduce((a, b) => a > b ? a : b) * 1.15)
            .ceilToDouble();
    final spots = List.generate(
      history.length,
      (i) => FlSpot(i.toDouble(), history[i].volume),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              'Tiến trình Volume',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const Spacer(),
            Text(
              '${history.length} buổi',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              maxY: maxY,
              minY: 0,
              gridData: FlGridData(
                show: true,
                horizontalInterval: maxY > 0 ? (maxY / 4).ceilToDouble() : 10,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (val) =>
                    FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (val, _) {
                      final idx = val.toInt();
                      if (idx < 0 || idx >= history.length) {
                        return const SizedBox.shrink();
                      }
                      final isLast = idx == history.length - 1;
                      final date = history[idx].date;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(
                            fontSize: 9,
                            color: isLast
                                ? colorScheme.primary
                                : Colors.grey.shade500,
                            fontWeight: isLast
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: index == spots.length - 1
                            ? colorScheme.primary
                            : Colors.white,
                        strokeWidth: 2,
                        strokeColor: colorScheme.primary,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: colorScheme.primary.withOpacity(0.15),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colorScheme.inverseSurface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(0)} kg',
                        TextStyle(
                          color: colorScheme.onInverseSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
