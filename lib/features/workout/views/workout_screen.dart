import 'package:change_life/features/workout/models/exercise_form_data.dart';
import 'package:change_life/features/workout/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    int today = DateTime.now().weekday - 1;
    _tabController.index = today;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddWorkoutDialog(
        initialDayOfWeek: _tabController.index + 1,
        // View truyền dữ liệu thô — ViewModel dựng model objects
        onSave: (name, dayOfWeek, exercises) {
          ref
              .read(workoutViewModelProvider.notifier)
              .createAndAddWorkout(
                name: name,
                dayOfWeek: dayOfWeek,
                exercises: exercises,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text(
            'WORKOUT SCHEDULE',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: _days.map((day) => Tab(text: day.toUpperCase())).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(
            7,
            (index) => _WorkoutDayList(dayOfWeek: index + 1),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddWorkoutDialog,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dialog: Tạo buổi tập mới
// ─────────────────────────────────────────────
class _AddWorkoutDialog extends StatefulWidget {
  final int initialDayOfWeek;
  // MVVM: callback nhận dữ liệu thô, không nhận model object
  final void Function(
    String name,
    int dayOfWeek,
    List<ExerciseFormData> exercises,
  )
  onSave;

  const _AddWorkoutDialog({
    required this.initialDayOfWeek,
    required this.onSave,
  });

  @override
  State<_AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<_AddWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sessionNameController = TextEditingController();
  late int _selectedDay;

  // Danh sách bài tập đang được thêm vào buổi tập
  final List<_ExerciseEntry> _exercises = [];

  final List<String> _dayNames = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDayOfWeek;
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    for (final ex in _exercises) {
      ex.dispose();
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(_ExerciseEntry());
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Thêm ít nhất 1 bài tập!')));
      return;
    }

    // MVVM: View chỉ gom dữ liệu thô thành ExerciseFormData
    // ViewModel sẽ tự dựng các model objects
    final formData = _exercises
        .map(
          (ex) => ExerciseFormData(
            name: ex.nameController.text.trim(),
            muscle: ex.muscleController.text.trim(),
            sets: ex.sets,
            weight: ex.weight,
            reps: ex.reps,
          ),
        )
        .toList();

    widget.onSave(_sessionNameController.text.trim(), _selectedDay, formData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary)),
              ),
              child: Text(
                'CREATE WORKOUT',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18),
              ),
            ),

            // ── Body (scrollable) ──
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên buổi tập
                    TextFormField(
                      controller: _sessionNameController,
                      autofocus: true,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'WORKOUT NAME',
                        labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        hintText: 'E.G. LEG DAY...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'REQUIRED'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Chọn ngày tập
                    const Text(
                      'DAY OF WEEK',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        final selected = _selectedDay == day;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = day),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                              border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade800),
                            ),
                            child: Text(
                              _dayNames[i].toUpperCase(),
                              style: TextStyle(
                                color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),

                    // Danh sách bài tập
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EXERCISES (${_exercises.length})',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                        TextButton.icon(
                          onPressed: _addExercise,
                          icon: Icon(Icons.add, size: 18, color: Theme.of(context).colorScheme.primary),
                          label: Text('ADD EXERCISE', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ),
                      ],
                    ),
                    Divider(color: Theme.of(context).colorScheme.primary, height: 16),

                    if (_exercises.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'NO EXERCISES YET.\nTAP "ADD EXERCISE" TO START.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                        ),
                      ),

                    ...List.generate(_exercises.length, (i) {
                      return _ExerciseEntryCard(
                        key: ValueKey(i),
                        entry: _exercises[i],
                        index: i,
                        onRemove: () => _removeExercise(i),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ── Footer ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.primary)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        side: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SAVE WORKOUT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
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
}

// ─────────────────────────────────────────────
// Model nội bộ cho mỗi bài tập trong dialog
// ─────────────────────────────────────────────
class _ExerciseEntry {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController muscleController = TextEditingController();
  int sets = 3;
  double weight = 0;
  int reps = 10;

  void dispose() {
    nameController.dispose();
    muscleController.dispose();
  }
}

// ─────────────────────────────────────────────
// Widget: Thẻ nhập thông tin 1 bài tập
// ─────────────────────────────────────────────
class _ExerciseEntryCard extends StatefulWidget {
  final _ExerciseEntry entry;
  final int index;
  final VoidCallback onRemove;

  const _ExerciseEntryCard({
    super.key,
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  @override
  State<_ExerciseEntryCard> createState() => _ExerciseEntryCardState();
}

class _ExerciseEntryCardState extends State<_ExerciseEntryCard> {
  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề + nút xoá
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'EXERCISE',
                  style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.5),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close_sharp,
                    color: Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tên bài tập
            TextFormField(
              controller: entry.nameController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'EXERCISE NAME *',
                labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                hintText: 'E.G. BENCH PRESS...',
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                isDense: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'REQUIRED' : null,
            ),
            const SizedBox(height: 12),

            // Nhóm cơ
            TextFormField(
              controller: entry.muscleController,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'MUSCLE GROUP (OPTIONAL)',
                labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                hintText: 'E.G. CHEST, BACK...',
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // Số hiệp / kg / reps
            Row(
              children: [
                // Số hiệp
                Expanded(
                  child: _NumberField(
                    label: 'SETS',
                    value: entry.sets,
                    min: 1,
                    max: 20,
                    onChanged: (v) => setState(() => entry.sets = v),
                  ),
                ),
                const SizedBox(width: 12),
                // Cân nặng
                Expanded(
                  child: _NumberFieldDouble(
                    label: 'WEIGHT (KG)',
                    value: entry.weight,
                    onChanged: (v) => setState(() => entry.weight = v),
                  ),
                ),
                const SizedBox(width: 12),
                // Số lần
                Expanded(
                  child: _NumberField(
                    label: 'REPS',
                    value: entry.reps,
                    min: 1,
                    max: 200,
                    onChanged: (v) => setState(() => entry.reps = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget helper: Stepper số nguyên
// ─────────────────────────────────────────────
class _NumberField extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  const _NumberField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Row(
            children: [
              _iconBtn(
                context,
                Icons.remove,
                value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                ),
              ),
              _iconBtn(
                context,
                Icons.add,
                value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(BuildContext context, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: onTap != null ? Colors.grey.shade800 : Colors.transparent,
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? Theme.of(context).colorScheme.onSurface : Colors.grey.shade800,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget helper: Nhập số thực (kg)
// ─────────────────────────────────────────────
class _NumberFieldDouble extends StatefulWidget {
  final String label;
  final double value;
  final void Function(double) onChanged;

  const _NumberFieldDouble({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_NumberFieldDouble> createState() => _NumberFieldDoubleState();
}

class _NumberFieldDoubleState extends State<_NumberFieldDouble> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toString(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, fontSize: 16),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey.shade700)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Colors.grey.shade700)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) widget.onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Widget: Danh sách buổi tập theo ngày
// ─────────────────────────────────────────────
class _WorkoutDayList extends ConsumerWidget {
  final int dayOfWeek;
  const _WorkoutDayList({required this.dayOfWeek});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutViewModelProvider);
    final dayWorkouts = workouts
        .where((w) => w.dayOfWeek == dayOfWeek && w.dateCompleted == null)
        .toList();

    if (dayWorkouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade800),
            const SizedBox(height: 16),
            Text(
              'NO WORKOUTS',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TAP + TO BUILD YOUR DISCIPLINE',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayWorkouts.length,
      itemBuilder: (context, index) {
        final workout = dayWorkouts[index];
        return Card(
          elevation: 0,
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/workout/detail', extra: workout),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${workout.exerciseLogs.length} EXERCISES',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.primary, size: 16),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ── Preview bài tập ──
                  ...workout.exerciseLogs.take(4).map(
                    (log) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.square, size: 8, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              log.exercise.name.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            log.sets.isNotEmpty ? '${log.sets.length} × ${log.sets.first.weight}KG' : '${log.sets.length} SETS',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (workout.exerciseLogs.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${workout.exerciseLogs.length - 4} MORE...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  // ── Action row ──
                  Row(
                    children: [
                      // Nút Chỉnh sửa
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            final notifier = ref.read(
                              activeWorkoutViewModelProvider.notifier,
                            );
                            notifier.startSession(workout);
                            if (!ref
                                .read(activeWorkoutViewModelProvider)
                                .isEditMode) {
                              notifier.toggleEditMode();
                            }
                            context.push('/workout/active');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurface,
                            side: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'EDIT',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nút Bắt đầu tập
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            final notifier = ref.read(
                              activeWorkoutViewModelProvider.notifier,
                            );
                            notifier.startSession(workout);
                            if (ref
                                .read(activeWorkoutViewModelProvider)
                                .isEditMode) {
                              notifier.toggleEditMode();
                            }
                            context.push('/workout/active');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'START WORKOUT',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

