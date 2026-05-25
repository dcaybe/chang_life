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
            activeState.isEditMode ? "CHỈNH SỬA KẾ HOẠCH" : session.name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          actions: [
            if (activeState.isEditMode)
              IconButton(
                icon: Icon(Icons.save_outlined, color: Theme.of(context).colorScheme.primary),
                tooltip: 'Lưu thay đổi',
                onPressed: () {
                  final template = activeState.editedTemplate;
                  if (template != null) {
                    ref.read(workoutViewModelProvider.notifier).updateWorkout(template);
                  }
                  context.pop();
                },
              ),
            if (activeState.isEditMode && activeState.templateId != null)
              IconButton(
                icon: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
                tooltip: 'Xóa buổi tập',
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: Theme.of(context).cardColor,
                      title: Text('Xóa buổi tập?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                      content: Text(
                        'Bạn có chắc muốn xóa "${session.name}" không?\nHành động này không thể hoàn tác.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Huỷ', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Xóa'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    ref.read(workoutViewModelProvider.notifier).deleteWorkout(activeState.templateId!);
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
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: session.exerciseLogs.length,
                    itemBuilder: (context, exIndex) {
                      final log = session.exerciseLogs[exIndex];
                      return _ExerciseCard(exIndex: exIndex, log: log);
                    },
                  ),
                ),
                if (!activeState.isEditMode) // Chỉ hiện nút Hoàn thành khi đang tập
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeState.allSetsCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).cardColor,
                        foregroundColor: activeState.allSetsCompleted
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        elevation: 0,
                      ),
                      onPressed: activeState.allSetsCompleted
                          ? () {
                              ref.read(activeWorkoutViewModelProvider.notifier).finishSession();
                              context.pop();
                            }
                          : null,
                      child: Text(
                        'LOG WORKOUT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: activeState.allSetsCompleted ? Theme.of(context).colorScheme.onPrimary : Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            if (activeState.isTimerActive)
              Positioned(
                bottom: activeState.isEditMode ? 20 : 100,
                left: 16,
                right: 16,
                child: _RestTimerOverlay(seconds: activeState.restTimerSeconds),
              ),
            if (activeState.isEditMode)
              Positioned(
                bottom: 20,
                right: 16,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  onPressed: () => _showAddExerciseDialog(context, ref),
                  child: const Icon(Icons.add, size: 32),
                ),
              ),
          ],
        ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                          onChanged: (val) => ref
                              .read(activeWorkoutViewModelProvider.notifier)
                              .renameExercise(exIndex, val),
                          decoration: InputDecoration(
                            labelText: 'Exercise Name',
                            labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Text(
                          log.exercise.name.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                if (isEditMode)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    onPressed: () {
                      ref.read(activeWorkoutViewModelProvider.notifier).deleteExercise(exIndex);
                    },
                  ),
              ],
            ),
            // Note Field
            TextFormField(
              initialValue: log.notes,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
              onChanged: (val) => ref
                  .read(activeWorkoutViewModelProvider.notifier)
                  .updateExerciseNote(exIndex, val),
              decoration: const InputDecoration(
                hintText: 'Notes...',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                prefixIcon: Icon(Icons.notes, size: 18, color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
            // Stepper chỉnh thời gian nghỉ — chỉ hiện trong Edit Mode
            if (isEditMode)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Rest Time:',
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
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
            const Divider(color: Colors.grey, height: 24),
            // Table Header
            Row(
              children: [
                const SizedBox(width: 40, child: Text('SET', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                const Expanded(child: Text('KG', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                const Expanded(child: Text('REPS', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                const SizedBox(width: 40, child: Icon(Icons.check, color: Colors.grey, size: 20)),
              ],
            ),
            const SizedBox(height: 8),
            ...log.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final workoutSet = entry.value;
              final bool isCompleted = workoutSet.isCompleted;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isCompleted ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                  border: Border.all(
                    color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade800,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Row(
                    children: [
                      // Set number
                      SizedBox(
                        width: 32,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '${setIndex + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isCompleted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (workoutSet.isPR == true)
                              const Positioned(
                                top: -10,
                                right: -4,
                                child: Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Weight
                      Expanded(
                        child: TextFormField(
                          initialValue: workoutSet.weight.toString(),
                          keyboardType: TextInputType.number,
                          enabled: isEditMode && !isCompleted,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            fillColor: isEditMode && !isCompleted ? Theme.of(context).colorScheme.onSurface.withOpacity(0.1) : Colors.transparent,
                            filled: isEditMode && !isCompleted,
                          ),
                          onChanged: (val) {
                            double? w = double.tryParse(val);
                            if (w != null) {
                              ref.read(activeWorkoutViewModelProvider.notifier).updateSet(exIndex, setIndex, w, workoutSet.reps);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Reps
                      Expanded(
                        child: TextFormField(
                          initialValue: workoutSet.reps.toString(),
                          keyboardType: TextInputType.number,
                          enabled: !isCompleted,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (val) {
                            int? r = int.tryParse(val);
                            if (r != null) {
                              ref.read(activeWorkoutViewModelProvider.notifier).updateSet(exIndex, setIndex, workoutSet.weight, r);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Checkbox equivalent
                      InkWell(
                        onTap: (isEditMode || activeState.isTimerActive && !isCompleted)
                            ? null
                            : () {
                                ref.read(activeWorkoutViewModelProvider.notifier).toggleSet(exIndex, setIndex);
                              },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.grey.shade800,
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Icon(
                            Icons.check,
                            color: isCompleted ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            if (isEditMode)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(activeWorkoutViewModelProvider.notifier)
                        .addSet(exIndex),
                    icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                    label: Text('THÊM HIỆP TẬP', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
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
            color: Colors.transparent,
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.zero,
          ),
          child: Text(
            _label(value),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.primary),
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
    // Format mm:ss
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.timer, color: Theme.of(context).colorScheme.primary, size: 32),
          Text(
            'REST: $m:$s',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface, size: 28),
            onPressed: () =>
                ref.read(activeWorkoutViewModelProvider.notifier).stopTimer(),
          ),
        ],
      ),
    );
  }
}
