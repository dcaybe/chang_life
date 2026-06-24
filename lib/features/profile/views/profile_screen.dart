import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/features/workout/providers/workout_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _selectedExercise;
  String _searchQuery = '';
  String _selectedMuscle = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final storageService = ref.watch(storageServiceProvider);

    final userName = storageService.getUsername();
    final gender = storageService.getGender();
    final age = storageService.getAge();
    final height = storageService.getHeight();
    final weight = storageService.getWeight();
    final tdee = storageService.getNutritionTotalCalories();

    // Lấy dữ liệu bài tập phân theo nhóm cơ
    final exercisesByMuscle = ref.watch(workoutViewModelProvider.notifier).getCompletedExercisesByMuscle();
    
    // Lọc bài tập
    List<String> filteredExercises = [];
    if (_selectedMuscle == 'Tất cả') {
      for (var list in exercisesByMuscle.values) {
        filteredExercises.addAll(list);
      }
    } else {
      filteredExercises.addAll(exercisesByMuscle[_selectedMuscle] ?? []);
    }
    
    // Xóa trùng lặp và sắp xếp
    filteredExercises = filteredExercises.toSet().toList()..sort();

    // Lọc theo từ khóa tìm kiếm
    if (_searchQuery.isNotEmpty) {
      filteredExercises = filteredExercises
          .where((e) => e.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Tự động chọn bài tập đầu tiên nếu danh sách không rỗng và chưa có bài nào được chọn hoặc bài đang chọn không hợp lệ
    if (filteredExercises.isNotEmpty && 
        (_selectedExercise == null || !filteredExercises.contains(_selectedExercise))) {
      _selectedExercise = filteredExercises.first;
    } else if (filteredExercises.isEmpty) {
      _selectedExercise = null;
    }

    // Danh sách tất cả nhóm cơ để cho vào Dropdown
    final allMuscles = ['Tất cả', ...exercisesByMuscle.keys.toList()..sort()];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/profile/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Header (Avatar, Name)
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Thành viên Change Life',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // 2. Body Metrics
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chỉ số cơ thể',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRect(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ImageFiltered(
                            imageFilter: ColorFilter.mode(
                              Colors.black.withValues(
                                alpha: storageService.hasConfiguredNutrition()
                                    ? 0
                                    : 0.6,
                              ),
                              BlendMode.darken,
                            ),
                            child: ImageFiltered(
                              imageFilter:
                                  storageService.hasConfiguredNutrition()
                                  ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                                  : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildMetricItem('Giới tính', gender),
                                      _buildMetricItem('Tuổi', '$age'),
                                      _buildMetricItem(
                                        'Chiều cao',
                                        '${height.toStringAsFixed(0)} cm',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildMetricItem(
                                        'Cân nặng',
                                        '${weight.toStringAsFixed(1)} kg',
                                      ),
                                      _buildMetricItem(
                                        'Mục tiêu Calo',
                                        '$tdee kcal',
                                      ),
                                      const SizedBox(width: 60), // Spacer
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Overlay Nút Thêm nếu chưa cấu hình
                          if (!storageService.hasConfiguredNutrition())
                            Positioned(
                              child: IconButton(
                                icon: const Icon(Icons.add_circle, size: 48),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  context.push('/nutrition/design');
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. 1RM Strength Progression Chart
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Sức mạnh tối đa (1RM)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (exercisesByMuscle.isEmpty)
                      Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: Text(
                          'Chưa có lịch sử tập luyện để tính 1RM.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      )
                    else ...[
                      // Row chứa Filter Nhóm cơ & TextField Tìm kiếm
                      Row(
                        children: [
                          // Dropdown lọc theo nhóm cơ
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Theme.of(context).dividerColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedMuscle,
                                  isExpanded: true,
                                  dropdownColor: Theme.of(context).cardColor,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  items: allMuscles.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _selectedMuscle = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // TextField Tìm kiếm bài tập
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tìm bài tập...',
                                  hintStyle: const TextStyle(fontSize: 13),
                                  prefixIcon: const Icon(Icons.search, size: 18),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                                  ),
                                ),
                                style: const TextStyle(fontSize: 13),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (filteredExercises.isEmpty)
                        Container(
                          height: 100,
                          alignment: Alignment.center,
                          child: Text(
                            'Không tìm thấy bài tập phù hợp.',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                        )
                      else ...[
                        // Dropdown Chọn bài tập từ danh sách đã lọc
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedExercise ?? filteredExercises.first,
                              isExpanded: true,
                              dropdownColor: Theme.of(context).cardColor,
                              items: filteredExercises.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedExercise = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Biểu đồ 1RM
                        _OneRMChart(
                          exerciseName: _selectedExercise ?? filteredExercises.first,
                          history: ref.watch(workoutViewModelProvider.notifier).getExercise1RMHistory(_selectedExercise ?? filteredExercises.first),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Support & Others
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Chính sách bảo mật (Privacy Policy)'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Chính sách bảo mật'),
                          content: const Text(
                            'Chính sách bảo mật của Change Life...',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Đóng'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Phiên bản ứng dụng'),
                    trailing: Text(
                      'v1.0.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 1RM Progression Line Chart
// ─────────────────────────────────────────────────────────────
class _OneRMChart extends StatelessWidget {
  final String exerciseName;
  final List<Map<String, dynamic>> history;

  const _OneRMChart({required this.exerciseName, required this.history});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (history.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text(
          'Không tìm thấy lịch sử 1RM của bài tập này.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
      );
    }

    final maxY =
        (history.map((h) => h['oneRM'] as double).reduce((a, b) => a > b ? a : b) * 1.15)
            .ceilToDouble();
    
    final minYVal = history.map((h) => h['oneRM'] as double).reduce((a, b) => a < b ? a : b);
    final minY = (minYVal * 0.85).floorToDouble();

    final spots = List.generate(
      history.length,
      (i) => FlSpot(i.toDouble(), history[i]['oneRM'] as double),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              'Tiến trình sức mạnh 1RM (Max 1RM)',
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
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              maxY: maxY,
              minY: minY >= 0 ? minY : 0,
              gridData: FlGridData(
                show: true,
                horizontalInterval: (maxY - minY) > 0 ? ((maxY - minY) / 4).ceilToDouble() : 10,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (val) =>
                    FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
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
                      final date = history[idx]['date'] as DateTime;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
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
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: index == spots.length - 1
                            ? Colors.blue
                            : Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.blue,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.12),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colorScheme.inverseSurface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)} kg',
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
