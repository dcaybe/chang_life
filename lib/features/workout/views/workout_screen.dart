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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Schedule'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _days.map((day) => Tab(text: day)).toList(),
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
        child: const Icon(Icons.add),
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
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center),
                  const SizedBox(width: 8),
                  Text(
                    'Tạo buổi tập mới',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                      decoration: const InputDecoration(
                        labelText: 'Tên buổi tập *',
                        hintText: 'VD: Push Day, Leg Day...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Không được để trống'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Chọn ngày tập
                    Text(
                      'Ngày tập',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        final selected = _selectedDay == day;
                        return ChoiceChip(
                          label: Text(_dayNames[i]),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedDay = day),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Danh sách bài tập
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bài tập (${_exercises.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: _addExercise,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Thêm bài'),
                        ),
                      ],
                    ),
                    const Divider(height: 8),

                    if (_exercises.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'Chưa có bài tập nào.\nNhấn "Thêm bài" để bắt đầu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
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
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Huỷ'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Lưu buổi tập'),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề + nút xoá
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    '${widget.index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bài tập',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Tên bài tập
            TextFormField(
              controller: entry.nameController,
              decoration: const InputDecoration(
                labelText: 'Tên bài tập *',
                hintText: 'VD: Bench Press, Squat...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập tên bài tập' : null,
            ),
            const SizedBox(height: 8),

            // Nhóm cơ
            TextFormField(
              controller: entry.muscleController,
              decoration: const InputDecoration(
                labelText: 'Nhóm cơ (tuỳ chọn)',
                hintText: 'VD: Chest, Back, Legs...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            // Số hiệp / kg / reps
            Row(
              children: [
                // Số hiệp
                Expanded(
                  child: _NumberField(
                    label: 'Số hiệp',
                    value: entry.sets,
                    min: 1,
                    max: 20,
                    onChanged: (v) => setState(() => entry.sets = v),
                  ),
                ),
                const SizedBox(width: 8),
                // Cân nặng
                Expanded(
                  child: _NumberFieldDouble(
                    label: 'Kg',
                    value: entry.weight,
                    onChanged: (v) => setState(() => entry.weight = v),
                  ),
                ),
                const SizedBox(width: 8),
                // Số lần
                Expanded(
                  child: _NumberField(
                    label: 'Reps',
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
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _iconBtn(
                Icons.remove,
                value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              _iconBtn(
                Icons.add,
                value < max ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? null : Colors.grey.shade300,
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
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: 'kg',
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
          onChanged: (v) {
            final parsed = double.tryParse(v);
            if (parsed != null) widget.onChanged(parsed);
          },
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
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Chưa có buổi tập nào.\nNhấn + để thêm buổi tập mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dayWorkouts.length,
      itemBuilder: (context, index) {
        final workout = dayWorkouts[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            // Tap bìa → vào màn chi tiết
            onTap: () => context.push('/workout/detail', extra: workout),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.fitness_center,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              '${workout.exerciseLogs.length} bài tập',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Preview bài tập ──
                  ...workout.exerciseLogs.take(3).map(
                    (log) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              log.exercise.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${log.sets.length} × ${log.sets.first.weight}kg',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (workout.exerciseLogs.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '+ ${workout.exerciseLogs.length - 3} bài nữa...',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const Divider(height: 20),

                  // ── Action row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Nút Chỉnh sửa
                      TextButton.icon(
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
                        icon: const Icon(Icons.edit_calendar),
                        label: const Text('Chỉnh sửa'),
                      ),
                      // Nút Bắt đầu tập
                      ElevatedButton.icon(
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
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          'Bắt đầu tập',
                          style: TextStyle(color: Colors.white),
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

