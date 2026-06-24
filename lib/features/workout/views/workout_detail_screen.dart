import 'package:change_life/features/workout/models/exercise_model.dart';
import 'package:change_life/features/workout/models/workout_model.dart';
import 'package:change_life/features/workout/providers/workout_provider.dart';
import 'package:change_life/features/workout/views/widgets/tutorial_sheet.dart';
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
            latestSession.name.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.edit_calendar_sharp,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Chỉnh sửa kế hoạch',
              onPressed: () {
                final notifier = ref.read(
                  activeWorkoutViewModelProvider.notifier,
                );
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.play_arrow_sharp, size: 28),
                label: const Text(
                  'START WORKOUT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: Theme.of(context).colorScheme.primary,
                thickness: 1,
              ),
            ),

            // ── Exercise cards ──
            ...latestSession.exerciseLogs.asMap().entries.map((entry) {
              return _ExerciseDetailCard(log: entry.value, index: entry.key);
            }),
            const SizedBox(height: 32),
          ],
        ),
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
          label: '~${(totalSets * 4).toStringAsFixed(0)} phút',
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
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
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

    // Get historical volume data via ViewModel (MVVM-compliant)
    final historyData = ref
        .read(workoutViewModelProvider.notifier)
        .getExerciseVolumeHistory(log.exercise.name);
    final historyLogs = historyData
        .map(
          (d) => _VolumePoint(
            date: d['date'] as DateTime,
            volume: d['volume'] as double,
          ),
        )
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header bài tập ──
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  color: Theme.of(context).colorScheme.primary,
                  alignment: Alignment.center,
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.exercise.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (log.exercise.targetMuscle.isNotEmpty)
                        Text(
                          log.exercise.targetMuscle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _showChart = !_showChart),
                  icon: Icon(
                    _showChart ? Icons.bar_chart_sharp : Icons.bar_chart_sharp,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    _showChart ? 'HIDE' : 'HISTORY',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 22),
                  tooltip: 'Xem hướng dẫn',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => FractionallySizedBox(
                        heightFactor: 0.8,
                        child: TutorialSheet(exerciseName: log.exercise.name),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.0,
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
