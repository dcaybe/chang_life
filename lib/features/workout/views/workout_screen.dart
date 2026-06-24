import 'dart:async';
import 'package:change_life/features/workout/models/exercise_form_data.dart';
import 'package:change_life/features/workout/models/exercisedb_model.dart';
import 'package:change_life/features/workout/providers/exercisedb_provider.dart';
import 'package:change_life/features/workout/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:change_life/features/workout/views/exercise_search_screen.dart';

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

  void _showAddWorkoutOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary)),
              ),
              child: Text(
                'CHOOSE WORKOUT TYPE',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
              title: const Text('BLANK WORKOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              subtitle: const Text('Create a workout from scratch', style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(ctx);
                _showAddWorkoutDialog();
              },
            ),
            Divider(color: Colors.grey.shade800, height: 1),
            ListTile(
              leading: Icon(Icons.copy, color: Theme.of(context).colorScheme.primary),
              title: const Text('FROM TEMPLATE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              subtitle: const Text('Choose a pre-defined routine', style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(ctx);
                _showTemplatesDialog();
              },
            ),
            Divider(color: Colors.grey.shade800, height: 1),
            ListTile(
              leading: Icon(Icons.event_note, color: Theme.of(context).colorScheme.primary),
              title: const Text('WEEKLY PROGRAM', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              subtitle: const Text('Replace your entire week with a package', style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(ctx);
                _showWeeklyTemplatesDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showWeeklyTemplatesDialog() {
    showDialog(
      context: context,
      builder: (context) => _WeeklyTemplatesDialog(
        onSelectTemplate: (template) {
          final notifier = ref.read(workoutViewModelProvider.notifier);
          // Clear the old planned workouts
          notifier.clearAllPlannedWorkouts();
          
          // Add the new workouts
          template.workouts.forEach((dayOfWeek, workoutTemplate) {
            notifier.createAndAddWorkout(
              name: workoutTemplate.name,
              dayOfWeek: dayOfWeek,
              exercises: workoutTemplate.exercises,
            );
          });
        },
      ),
    );
  }

  void _showTemplatesDialog() {
    showDialog(
      context: context,
      builder: (context) => _TemplatesDialog(
        initialDayOfWeek: _tabController.index + 1,
        onSelectTemplate: (template, dayOfWeek) {
          ref
              .read(workoutViewModelProvider.notifier)
              .createAndAddWorkout(
                name: template.name,
                dayOfWeek: dayOfWeek,
                exercises: template.exercises,
              );
        },
      ),
    );
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
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Navigate to Exercise Search Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExerciseSearchScreen()),
                );
              },
            ),
          ],
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
          onPressed: _showAddWorkoutOptions,
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
// Dialog: Tạo buổi tập mới (tích hợp ExerciseDB API)
// ─────────────────────────────────────────────
class _AddWorkoutDialog extends ConsumerStatefulWidget {
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
  ConsumerState<_AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends ConsumerState<_AddWorkoutDialog> {
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

  /// Mở bottom sheet chọn bài tập từ ExerciseDB API
  void _openExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => _ExercisePickerSheet(
        onExerciseSelected: (ExerciseDbItem exercise) {
          setState(() {
            final entry = _ExerciseEntry();
            entry.nameController.text = exercise.name;
            entry.muscleController.text = exercise.primaryMuscle;
            entry.gifUrl = exercise.gifUrl;
            _exercises.add(entry);
          });
          Navigator.pop(ctx);
        },
      ),
    );
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
                          onPressed: _openExercisePicker,
                          icon: Icon(Icons.search, size: 18, color: Theme.of(context).colorScheme.primary),
                          label: Text('BROWSE', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ),
                      ],
                    ),
                    Divider(color: Theme.of(context).colorScheme.primary, height: 16),

                    if (_exercises.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'NO EXERCISES YET.\nTAP "BROWSE" TO FIND EXERCISES.',
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
// Dialog: Chọn Weekly Template
// ─────────────────────────────────────────────
class WeeklyWorkoutTemplate {
  final String name;
  final String description;
  final Map<int, WorkoutTemplate> workouts;

  const WeeklyWorkoutTemplate({required this.name, required this.description, required this.workouts});
}

final List<WeeklyWorkoutTemplate> weeklyTemplates = [
  WeeklyWorkoutTemplate(
    name: 'PPL (PUSH/PULL/LEGS) - 6 DAYS',
    description: 'A classic 6-day split for muscle hypertrophy',
    workouts: {
      1: defaultTemplates.firstWhere((t) => t.name == 'PUSH DAY'),
      2: defaultTemplates.firstWhere((t) => t.name == 'PULL DAY'),
      3: defaultTemplates.firstWhere((t) => t.name == 'LEG DAY'),
      4: defaultTemplates.firstWhere((t) => t.name == 'PUSH DAY'),
      5: defaultTemplates.firstWhere((t) => t.name == 'PULL DAY'),
      6: defaultTemplates.firstWhere((t) => t.name == 'LEG DAY'),
    },
  ),
  WeeklyWorkoutTemplate(
    name: 'FULL BODY - 3 DAYS',
    description: '3 days a week full body routine',
    workouts: {
      1: defaultTemplates.firstWhere((t) => t.name == 'FULL BODY BEGINNER'),
      3: defaultTemplates.firstWhere((t) => t.name == 'FULL BODY BEGINNER'),
      5: defaultTemplates.firstWhere((t) => t.name == 'FULL BODY BEGINNER'),
    },
  ),
];

class _WeeklyTemplatesDialog extends StatelessWidget {
  final void Function(WeeklyWorkoutTemplate template) onSelectTemplate;

  const _WeeklyTemplatesDialog({required this.onSelectTemplate});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary)),
            ),
            child: Text(
              'WEEKLY PROGRAMS',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('REPLACE YOUR WEEK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  const Text('Choosing a weekly program will clear your existing planned workouts for the week.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ...weeklyTemplates.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(t.name, style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.0)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(t.description, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text('${t.workouts.length} DAYS A WEEK', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          trailing: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: Theme.of(context).cardColor,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                title: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                content: const Text('This will clear all your current planned workouts. Proceed?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('CANCEL'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      onSelectTemplate(t);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                    ),
                                    child: const Text('REPLACE', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.primary)),
            ),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dialog: Chọn template
// ─────────────────────────────────────────────
class WorkoutTemplate {
  final String name;
  final String description;
  final List<ExerciseFormData> exercises;

  const WorkoutTemplate({required this.name, required this.description, required this.exercises});
}

const List<WorkoutTemplate> defaultTemplates = [
  WorkoutTemplate(
    name: 'FULL BODY BEGINNER',
    description: 'A basic full body routine for beginners',
    exercises: [
      ExerciseFormData(name: 'SQUAT', muscle: 'LEGS', sets: 3, weight: 0, reps: 12),
      ExerciseFormData(name: 'PUSH UP', muscle: 'CHEST', sets: 3, weight: 0, reps: 10),
      ExerciseFormData(name: 'PULL UP', muscle: 'BACK', sets: 3, weight: 0, reps: 5),
    ],
  ),
  WorkoutTemplate(
    name: 'PUSH DAY',
    description: 'Chest, Shoulders, and Triceps',
    exercises: [
      ExerciseFormData(name: 'BENCH PRESS', muscle: 'CHEST', sets: 4, weight: 20, reps: 10),
      ExerciseFormData(name: 'OVERHEAD PRESS', muscle: 'SHOULDERS', sets: 3, weight: 10, reps: 12),
      ExerciseFormData(name: 'TRICEP PUSH DOWN', muscle: 'TRICEPS', sets: 3, weight: 15, reps: 15),
    ],
  ),
  WorkoutTemplate(
    name: 'PULL DAY',
    description: 'Back, Biceps, and Rear Delts',
    exercises: [
      ExerciseFormData(name: 'DEADLIFT', muscle: 'BACK', sets: 3, weight: 40, reps: 8),
      ExerciseFormData(name: 'BARBELL ROW', muscle: 'BACK', sets: 3, weight: 20, reps: 10),
      ExerciseFormData(name: 'BICEP CURL', muscle: 'BICEPS', sets: 3, weight: 10, reps: 15),
    ],
  ),
  WorkoutTemplate(
    name: 'LEG DAY',
    description: 'Quads, Hamstrings, and Calves',
    exercises: [
      ExerciseFormData(name: 'BARBELL SQUAT', muscle: 'LEGS', sets: 4, weight: 40, reps: 10),
      ExerciseFormData(name: 'LEG PRESS', muscle: 'LEGS', sets: 3, weight: 80, reps: 12),
      ExerciseFormData(name: 'CALF RAISE', muscle: 'CALVES', sets: 4, weight: 20, reps: 15),
    ],
  ),
];

class _TemplatesDialog extends StatefulWidget {
  final int initialDayOfWeek;
  final void Function(WorkoutTemplate template, int dayOfWeek) onSelectTemplate;

  const _TemplatesDialog({required this.initialDayOfWeek, required this.onSelectTemplate});

  @override
  State<_TemplatesDialog> createState() => _TemplatesDialogState();
}

class _TemplatesDialogState extends State<_TemplatesDialog> {
  late int _selectedDay;
  final List<String> _dayNames = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDayOfWeek;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary)),
            ),
            child: Text(
              'WORKOUT TEMPLATES',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DAY OF WEEK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
                  const Text('SELECT A TEMPLATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  ...defaultTemplates.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(t.name, style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.0)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(t.description, style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text('${t.exercises.length} EXERCISES', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          trailing: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                          onTap: () {
                            widget.onSelectTemplate(t, _selectedDay);
                            Navigator.pop(context);
                          },
                        ),
                      )),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.primary)),
            ),
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
        ],
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
  String? gifUrl; // URL ảnh GIF từ ExerciseDB API

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
    final hasGif = entry.gifUrl != null && entry.gifUrl!.isNotEmpty;

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
                Expanded(
                  child: Text(
                    entry.nameController.text.isNotEmpty
                        ? entry.nameController.text.toUpperCase()
                        : 'EXERCISE',
                    style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.onSurface, letterSpacing: 1.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
            const SizedBox(height: 12),

            // GIF preview + nhóm cơ
            if (hasGif || entry.muscleController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GIF thumbnail
                    if (hasGif)
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          color: Colors.black,
                        ),
                        child: Image.network(
                          entry.gifUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.fitness_center,
                            color: Colors.grey.shade600,
                            size: 32,
                          ),
                        ),
                      ),
                    // Thông tin cơ bản
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (entry.muscleController.text.isNotEmpty) ...[
                            Text(
                              'TARGET MUSCLE',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                entry.muscleController.text.toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Nếu chưa có tên (thêm thủ công) thì hiện text field
            if (entry.nameController.text.isEmpty) ...[
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
            ],

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

    // Tìm các buổi tập đã hoàn thành trong ngày hôm nay
    final today = DateTime.now();
    final completedToday = workouts.where((w) {
      if (w.dateCompleted == null) return false;
      return w.dateCompleted!.year == today.year &&
             w.dateCompleted!.month == today.month &&
             w.dateCompleted!.day == today.day;
    }).toList();

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
        final isCompletedToday = completedToday.any((cw) => cw.name == workout.name);

        return Opacity(
          opacity: isCompletedToday ? 0.6 : 1.0,
          child: Card(
            elevation: 0,
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color: isCompletedToday ? Colors.grey.shade600 : Theme.of(context).colorScheme.primary, 
                width: 1,
              ),
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
                      // Badge hoàn thành
                      if (isCompletedToday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text(
                            'DONE',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        )
                      else
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
                            backgroundColor: isCompletedToday ? Colors.grey.shade800 : Theme.of(context).colorScheme.primary,
                            foregroundColor: isCompletedToday ? Colors.white : Theme.of(context).colorScheme.onPrimary,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: Text(
                            isCompletedToday ? 'TẬP LẠI' : 'START WORKOUT',
                            style: const TextStyle(
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
        ));
      },
    );
  }
}

// ─────────────────────────────────────────────
// Bottom Sheet: Tìm và chọn bài tập từ ExerciseDB API
// ─────────────────────────────────────────────
class _ExercisePickerSheet extends ConsumerStatefulWidget {
  final void Function(ExerciseDbItem exercise) onExerciseSelected;

  const _ExercisePickerSheet({required this.onExerciseSelected});

  @override
  ConsumerState<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends ConsumerState<_ExercisePickerSheet> {
  final _searchController = TextEditingController();
  String? _selectedBodyPart;
  String _searchQuery = '';
  Timer? _debounce;

  /// Map icon cho mỗi body part
  static const Map<String, IconData> _bodyPartIcons = {
    'back': Icons.accessibility_new,
    'chest': Icons.shield,
    'shoulders': Icons.expand,
    'upper arms': Icons.fitness_center,
    'lower arms': Icons.front_hand,
    'upper legs': Icons.airline_seat_legroom_extra,
    'lower legs': Icons.directions_walk,
    'waist': Icons.circle_outlined,
    'neck': Icons.face,
    'cardio': Icons.favorite,
  };

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = value.trim();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyPartsAsync = ref.watch(bodyPartsProvider);

    // Tạo search params từ state hiện tại
    final searchParams = ExerciseSearchParams(
      name: _searchQuery.isNotEmpty ? _searchQuery : null,
      bodyPart: _selectedBodyPart,
      limit: 30,
    );
    final exercisesAsync = ref.watch(exerciseSearchProvider(searchParams));

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // ── Handle bar ──
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              child: Text(
                'EXERCISE DATABASE',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 18,
                ),
              ),
            ),

            // ── Body Part Chips (nhóm cơ) ──
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 8),
                    child: Text(
                      'MUSCLE GROUP',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: bodyPartsAsync.when(
                      data: (bodyParts) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: bodyParts.length + 1, // +1 cho nút "ALL"
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Nút "ALL" — bỏ filter
                            final isSelected = _selectedBodyPart == null;
                            return _buildBodyPartChip(
                              context,
                              label: 'ALL',
                              icon: Icons.apps,
                              isSelected: isSelected,
                              onTap: () => setState(() => _selectedBodyPart = null),
                            );
                          }
                          final part = bodyParts[index - 1];
                          final isSelected = _selectedBodyPart == part;
                          return _buildBodyPartChip(
                            context,
                            label: part.toUpperCase(),
                            icon: _bodyPartIcons[part] ?? Icons.circle,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedBodyPart = part),
                          );
                        },
                      ),
                      loading: () => Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'FAILED TO LOAD MUSCLE GROUPS',
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Field ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'SEARCH BY NAME...',
                  hintStyle: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey.shade500),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  isDense: true,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // ── Results count ──
            exercisesAsync.when(
              data: (response) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${response.total} RESULTS',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (_selectedBodyPart != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          _selectedBodyPart!.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 4),

            // ── Exercise List ──
            Expanded(
              child: exercisesAsync.when(
                data: (response) {
                  if (response.data.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey.shade700),
                          const SizedBox(height: 12),
                          Text(
                            'NO EXERCISES FOUND',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try different filters or search terms',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: response.data.length,
                    itemBuilder: (context, index) {
                      final exercise = response.data[index];
                      return _ExerciseResultTile(
                        exercise: exercise,
                        onTap: () => widget.onExerciseSelected(exercise),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'LOADING EXERCISES...',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 12),
                        Text(
                          'FAILED TO LOAD',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          err.toString(),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBodyPartChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade700,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widget: Một dòng kết quả bài tập trong picker
// ─────────────────────────────────────────────
class _ExerciseResultTile extends StatelessWidget {
  final ExerciseDbItem exercise;
  final VoidCallback onTap;

  const _ExerciseResultTile({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // GIF thumbnail
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade700),
                  color: Colors.black,
                ),
                child: exercise.gifUrl.isNotEmpty
                    ? Image.network(
                        exercise.gifUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.fitness_center,
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                      )
                    : Icon(
                        Icons.fitness_center,
                        color: Colors.grey.shade600,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Target muscles
                    if (exercise.targetMuscles.isNotEmpty)
                      Text(
                        exercise.targetMuscles.join(', ').toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                    const SizedBox(height: 2),
                    // Equipment
                    Row(
                      children: [
                        Icon(Icons.build_outlined, size: 10, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            exercise.equipment.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Add icon
              Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
