import 'package:change_life/features/workout/models/exercise_model.dart';
import 'package:change_life/features/workout/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeWorkoutViewModelProvider);
    final session = activeState.session;

    if (session == null) {
      return const Scaffold(body: Center(child: Text('No active session')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activeState.isEditMode ? "Chỉnh sửa kế hoạch" : session.name),
        actions: [
          // Nút Lưu — chỉ hiện khi Edit Mode
          if (activeState.isEditMode)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Lưu thay đổi',
              onPressed: () {
                final template = activeState.editedTemplate;
                if (template != null) {
                  ref
                      .read(workoutViewModelProvider.notifier)
                      .updateWorkout(template); 
                }
                context.pop();
              },
            ),
          // Nút xóa buổi tập — chỉ hiện khi đang Edit Mode
          if (activeState.isEditMode && activeState.templateId != null)
            IconButton(
              icon: const Icon(Icons.delete_forever_outlined, color: Colors.red),
              tooltip: 'Xóa buổi tập',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Xóa buổi tập?'),
                    content: Text(
                      'Bạn có chắc muốn xóa "${session.name}" không?\nHành động này không thể hoàn tác.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Huỷ'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  ref
                      .read(workoutViewModelProvider.notifier)
                      .deleteWorkout(activeState.templateId!);
                  context.pop();
                }
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: session.exerciseLogs.length,
                  itemBuilder: (context, exIndex) {
                    final log = session.exerciseLogs[exIndex];
                    return _ExerciseCard(exIndex: exIndex, log: log);
                  },
                ),
              ),
              if (!activeState.isEditMode) // Chỉ hiện nút Hoàn thành khi đang tập
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeState.allSetsCompleted
                            ? Colors.green
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      // Chỉ cho bấm khi tất cả set đã hoàn thành
                      onPressed: activeState.allSetsCompleted
                          ? () {
                              final hiveService = ref.read(
                                workoutHiveServiceProvider,
                              );
                              ref
                                  .read(activeWorkoutViewModelProvider.notifier)
                                  .finishSession(hiveService);
                              context.pop();
                            }
                          : null,
                      child: const Text(
                        'HOÀN THÀNH BUỔI TẬP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          if (activeState.isTimerActive)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: _RestTimerOverlay(seconds: activeState.restTimerSeconds),
            ),
          if (activeState.isEditMode)
            Positioned(
              bottom: 80,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: () => _showAddExerciseDialog(context, ref),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddExerciseDialog(
        // MVVM: View chỉ truyền dữ liệu thô, ViewModel dựng model
        onSave: (name, muscle, sets, weight, reps) => ref
            .read(activeWorkoutViewModelProvider.notifier)
            .createAndAddExercise(
              name: name,
              muscle: muscle,
              sets: sets,
              weight: weight,
              reps: reps,
            ),
      ),
    );
  }
}

class _ExerciseCard extends ConsumerWidget {
  final int exIndex;
  final ExerciseLog log;
  const _ExerciseCard({required this.exIndex, required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeWorkoutViewModelProvider);
    final isEditMode = activeState.isEditMode;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isEditMode
                    ? Expanded(
                        child: TextFormField(
                          initialValue: log.exercise.name,
                          onChanged: (val) => ref
                              .read(activeWorkoutViewModelProvider.notifier)
                              .renameExercise(exIndex, val),
                          decoration: const InputDecoration(
                            labelText: 'Exercise Name',
                          ),
                        ),
                      )
                    : Text(
                        log.exercise.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                if (isEditMode)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      ref
                          .read(activeWorkoutViewModelProvider.notifier)
                          .deleteExercise(exIndex);
                    },
                  ),
              ],
            ),
            // Note Field
            TextFormField(
              initialValue: log.notes,
              onChanged: (val) => ref
                  .read(activeWorkoutViewModelProvider.notifier)
                  .updateExerciseNote(exIndex, val),
              decoration: const InputDecoration(
                hintText: 'Ghi chú cho bài tập này...',
                isDense: true,
                prefixIcon: Icon(Icons.notes, size: 18),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            // Stepper chỉnh thời gian nghỉ — chỉ hiện trong Edit Mode
            if (isEditMode)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 18, color: Colors.blue),
                    const SizedBox(width: 6),
                    const Text(
                      'Thời gian nghỉ:',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    // Nút giảm
                    _RestStepper(
                      value: log.restSeconds ?? 60,
                      onChanged: (v) => ref
                          .read(activeWorkoutViewModelProvider.notifier)
                          .updateRestTime(exIndex, v),
                    ),
                  ],
                ),
              ),
            const Divider(),
            ...log.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final workoutSet = entry.value;
              final bool isCompleted = workoutSet.isCompleted;

              return Opacity(
                opacity: isCompleted ? 0.5 : 1.0, // Làm mờ nếu đã hoàn thành
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: isCompleted
                                ? Colors.green
                                : Colors.grey[300],
                            child: Text(
                              '${setIndex + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isCompleted ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          if (workoutSet.isPR == true)
                            const Positioned(
                              top: -6,
                              right: -6,
                              child: Icon(
                                Icons.workspace_premium,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      // Weight: Only editable in Edit Mode
                      Expanded(
                        child: TextFormField(
                          initialValue: workoutSet.weight.toString(),
                          keyboardType: TextInputType.number,
                          enabled: isEditMode && !isCompleted,
                          decoration: InputDecoration(
                            suffixText: 'kg',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            fillColor: (isEditMode && !isCompleted)
                                ? null
                                : Colors.grey[100],
                            filled: true,
                          ),
                          onChanged: (val) {
                            double? w = double.tryParse(val);
                            if (w != null) {
                              ref
                                  .read(activeWorkoutViewModelProvider.notifier)
                                  .updateSet(
                                    exIndex,
                                    setIndex,
                                    w,
                                    workoutSet.reps,
                                  );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Reps: Always editable unless completed
                      Expanded(
                        child: TextFormField(
                          initialValue: workoutSet.reps.toString(),
                          keyboardType: TextInputType.number,
                          enabled: !isCompleted,
                          decoration: const InputDecoration(
                            suffixText: 'reps',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                          ),
                          onChanged: (val) {
                            int? r = int.tryParse(val);
                            if (r != null) {
                              ref
                                  .read(activeWorkoutViewModelProvider.notifier)
                                  .updateSet(
                                    exIndex,
                                    setIndex,
                                    workoutSet.weight,
                                    r,
                                  );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Checkbox(
                        value: isCompleted,
                        // Disable khi: Edit Mode, đã hoàn thành, HOẶC đang trong thời gian nghỉ
                        onChanged: (isEditMode || isCompleted || activeState.isTimerActive)
                            ? null
                            : (val) {
                                ref
                                    .read(
                                      activeWorkoutViewModelProvider.notifier,
                                    )
                                    .toggleSet(exIndex, setIndex);
                              },
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (isEditMode)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () => ref
                      .read(activeWorkoutViewModelProvider.notifier)
                      .addSet(exIndex),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm hiệp tập'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget: Stepper chỉnh thời gian nghỉ
// ─────────────────────────────────────────────
class _RestStepper extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const _RestStepper({required this.value, required this.onChanged});

  String _label(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final rem = s % 60;
    return rem == 0 ? '${m}m' : '${m}m ${rem}s';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: value > 15 ? () => onChanged(value - 15) : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _label(value),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: value < 300 ? () => onChanged(value + 15) : null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Dialog: Thêm bài tập mới trong buổi tập
// ─────────────────────────────────────────────
class _AddExerciseDialog extends StatefulWidget {
  // MVVM: callback nhận dữ liệu thô, không nhận model object
  final void Function(String name, String muscle, int sets, double weight, int reps) onSave;
  const _AddExerciseDialog({required this.onSave});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _muscleCtrl = TextEditingController();
  int _sets = 3;
  final _weightCtrl = TextEditingController(text: '0');
  int _reps = 10;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _muscleCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    // MVVM: View chỉ gửi dữ liệu thô — ViewModel sẽ tự tạo model objects
    widget.onSave(_nameCtrl.text.trim(), _muscleCtrl.text.trim(), _sets, weight, _reps);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_box_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Thêm bài tập',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên bài tập
                  TextFormField(
                    controller: _nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Tên bài tập *',
                      hintText: 'VD: Bench Press, Squat...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Không được để trống'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Nhóm cơ
                  TextFormField(
                    controller: _muscleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nhóm cơ (tuỳ chọn)',
                      hintText: 'VD: Chest, Back, Legs...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.accessibility_new_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Số hiệp / kg / reps
                  Row(
                    children: [
                      // Số hiệp
                      Expanded(
                        child: _Stepper(
                          label: 'Số hiệp',
                          value: _sets,
                          min: 1,
                          max: 20,
                          onChanged: (v) => setState(() => _sets = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Kg
                      Expanded(
                        child: TextFormField(
                          controller: _weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Kg',
                            suffixText: 'kg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Reps
                      Expanded(
                        child: _Stepper(
                          label: 'Reps',
                          value: _reps,
                          min: 1,
                          max: 200,
                          onChanged: (v) => setState(() => _reps = v),
                        ),
                      ),
                    ],
                  ),
                ],
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
                    icon: const Icon(Icons.check),
                    label: const Text('Thêm'),
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
// Widget helper: Stepper số nguyên
// ─────────────────────────────────────────────
class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final void Function(int) onChanged;

  const _Stepper({
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
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _btn(
                Icons.remove,
                value > min ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              _btn(Icons.add, value < max ? () => onChanged(value + 1) : null),
            ],
          ),
        ),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Icon(
        icon,
        size: 16,
        color: onTap != null ? null : Colors.grey.shade300,
      ),
    ),
  );
}

class _RestTimerOverlay extends ConsumerWidget {
  final int seconds;
  const _RestTimerOverlay({required this.seconds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.timer_outlined, color: Colors.orangeAccent),
          Text(
            'Thời gian nghỉ: $seconds giây',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () =>
                ref.read(activeWorkoutViewModelProvider.notifier).stopTimer(),
          ),
        ],
      ),
    );
  }
}
