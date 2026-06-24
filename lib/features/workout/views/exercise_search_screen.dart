import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:change_life/features/workout/providers/exercisedb_provider.dart';
import 'package:change_life/features/workout/views/widgets/tutorial_sheet.dart';

class ExerciseSearchScreen extends ConsumerStatefulWidget {
  const ExerciseSearchScreen({super.key});

  @override
  ConsumerState<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends ConsumerState<ExerciseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = query.trim();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bài tập...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          style: const TextStyle(fontSize: 18),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
            ),
        ],
      ),
      body: _searchQuery.isEmpty
          ? const Center(
              child: Text(
                'Nhập tên bài tập để tìm kiếm (VD: Bench Press)',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : Consumer(
              builder: (context, ref, child) {
                final searchParams = ExerciseSearchParams(name: _searchQuery, limit: 30);
                final searchState = ref.watch(exerciseSearchProvider(searchParams));

                return searchState.when(
                  data: (response) {
                    if (response.data.isEmpty) {
                      return const Center(child: Text('Không tìm thấy bài tập nào.'));
                    }
                    return ListView.builder(
                      itemCount: response.data.length,
                      itemBuilder: (context, index) {
                        final item = response.data[index];
                        return ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.fitness_center, color: Theme.of(context).colorScheme.primary),
                          ),
                          title: Text(
                            item.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text('${item.primaryMuscle} • ${item.equipment}'),
                          trailing: const Icon(Icons.info_outline, color: Colors.blue),
                          onTap: () {
                            // Ẩn bàn phím trước khi hiện modal
                            FocusScope.of(context).unfocus();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              builder: (context) => SizedBox(
                                height: MediaQuery.of(context).size.height * 0.85,
                                child: TutorialSheet(exerciseName: item.name),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Lỗi: $err')),
                );
              },
            ),
    );
  }
}
