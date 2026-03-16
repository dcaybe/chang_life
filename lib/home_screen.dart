import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Habit {
  final String id;
  final String name;
  final bool isDone;
  Habit({required this.name, required this.id, this.isDone = false});

  Habit copyWith({String? name, bool? isDone}) {
    return Habit(
      id: id,
      name: name ?? this.name,
      isDone: isDone ?? this.isDone,
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider1);
    final completed = ref.watch(countComplete);
    final total = habits.length;
    return Column(
      children: [
        const SizedBox(height: 20),
        Text('$completed/$total'),
        Expanded(
          child: ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitTile(id: habit.id);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// HabitTile
class HabitTile extends ConsumerWidget {
  final String id;

  const HabitTile({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = ref.watch(habitProvider(id));
    return ListTile(
      title: Text(habit.name),
      leading: Checkbox(
        value: habit.isDone,
        onChanged: (_) {
          ref.read(habitProvider1.notifier).toggle(id);
        },
      ),
    );
  }
}

// HabitNotifier
class HabitNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() {
    return [
      Habit(id: '0', name: 'gym', isDone: false),
      Habit(id: '1', name: 'study', isDone: false),
      Habit(id: '2', name: 'eat clean', isDone: false),
    ];
  }

  //done task
  void toggle(String id) {
    state = [
      for (final habit in state)
        if (habit.id == id) habit.copyWith(isDone: !habit.isDone) else habit,
    ];
  }

  //add task
  void addHabit(String name, String id) {
    state = [...state, Habit(id: id, name: name, isDone: false)];
  }

  //remove task
  void removeHabit(int index) {
    state = [
      for (var i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}

//provider count complete
final countComplete = Provider<int>((ref) {
  final habits = ref.watch(habitProvider1);
  return habits.where((h) => h.isDone).length;
});
final habitProvider1 = NotifierProvider<HabitNotifier, List<Habit>>(
  HabitNotifier.new,
);
final habitProvider = Provider.family<Habit, String>((ref, id) {
  final list = ref.watch(habitProvider1);

  return list.firstWhere((h) => h.id == id);
});
