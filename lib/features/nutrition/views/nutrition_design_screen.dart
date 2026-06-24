import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/providers/nutrition_provider.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/features/nutrition/models/supabase_food_model.dart';
import 'package:change_life/services/food_db_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NutritionDesignScreen extends ConsumerStatefulWidget {
  const NutritionDesignScreen({super.key});

  @override
  ConsumerState<NutritionDesignScreen> createState() =>
      _NutritionDesignScreenState();
}

class _NutritionDesignScreenState extends ConsumerState<NutritionDesignScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Step 1
  final _ageController = TextEditingController();
  String _gender = 'Nam';
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _goal = 'Giữ cân';
  final _targetWeightController = TextEditingController();
  String _activityLevel = 'Vận động vừa (3-5 ngày/tuần)';

  // Form Step 2
  final List<SupabaseFood> _selectedFoods = [];
  List<SupabaseFood> _fetchedFoods = [];
  bool _isLoadingFoods = false;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  Timer? _debounce;
  final FoodDbService _foodDbService = FoodDbService();

  final List<String> _categories = [
    'Tất cả',
    'Thịt và sản phẩm chế biến',
    'Thủy sản và sản phẩm chế biến',
    'Trứng và sản phẩm chế biến',
    'Sữa và sản phẩm chế biến',
    'Ngũ cốc và sản phẩm chế biến',
    'Khoai củ và sản phẩm chế biến',
    'Rau, quả, củ dùng làm rau',
    'Quả chín',
    'Hạt, quả giàu đạm, béo và sản phẩm chế biến',
  ];

  int _meatsPerDay = 2;
  int _mealsPerDay = 4;
  int _planDays = 1;

  @override
  void initState() {
    super.initState();
    _fetchFoods();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _fetchFoods();
    });
  }

  void _onCategoryChanged(String? category) {
    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
      _fetchFoods();
    }
  }

  Future<void> _fetchFoods() async {
    setState(() {
      _isLoadingFoods = true;
    });
    final foods = await _foodDbService.fetchFoods(
      searchQuery: _searchQuery,
      category: _selectedCategory,
    );
    if (mounted) {
      setState(() {
        _fetchedFoods = foods;
        _isLoadingFoods = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_ageController.text.isEmpty ||
          _heightController.text.isEmpty ||
          _weightController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
        );
        return;
      }
      if (_goal == 'Tăng cơ, tăng cân' && _targetWeightController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền mục tiêu cân nặng')),
        );
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _calculateAndSavePlan();
    }
  }

  void _calculateAndSavePlan() async {
    final age = int.tryParse(_ageController.text) ?? 25;
    final height = double.tryParse(_heightController.text) ?? 170.0;
    final weight = double.tryParse(_weightController.text) ?? 65.0;

    final mealPlanVM = ref.read(mealPlanVMProvider.notifier);
    await mealPlanVM.generateAndSaveMealPlan(
      age: age,
      height: height,
      weight: weight,
      gender: _gender,
      goal: _goal,
      activityLevel: _activityLevel,
      selectedFoods: _selectedFoods,
      mealsPerDay: _mealsPerDay,
      planDays: _planDays,
    );

    if (mounted) {
      context.pop(); // Go back to nutrition screen
    }
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
          title: const Text('THIẾT KẾ DINH DƯỠNG',
              style:
                  TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              color: index <= _currentStep
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade800,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('THÔNG TIN CƠ BẢN',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5)),
        const SizedBox(height: 24),
        _buildTextField('Tuổi', _ageController, TextInputType.number),
        const SizedBox(height: 16),
        _buildDropdown('Giới tính', _gender, ['Nam', 'Nữ'], (val) {
          setState(() => _gender = val!);
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    'Chiều cao (cm)', _heightController, TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField(
                    'Cân nặng (kg)', _weightController, TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown(
            'Mục tiêu', _goal, ['Giảm cân', 'Giữ cân', 'Tăng cơ, tăng cân'],
            (val) {
          setState(() => _goal = val!);
        }),
        const SizedBox(height: 16),
        _buildDropdown(
            'Mức độ vận động', _activityLevel, [
              'Ít vận động (Không tập)',
              'Vận động nhẹ (1-3 ngày/tuần)',
              'Vận động vừa (3-5 ngày/tuần)',
              'Vận động nhiều (6-7 ngày/tuần)',
              'Rất nhiều (Ngày 2 lần)'
            ],
            (val) {
          setState(() => _activityLevel = val!);
        }),
        if (_goal == 'Tăng cơ, tăng cân') ...[
          const SizedBox(height: 16),
          _buildTextField('Mục tiêu cân nặng (kg)', _targetWeightController,
              TextInputType.number),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('THỰC PHẨM ƯU THÍCH',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5)),
              const SizedBox(height: 8),
              const Text('Tìm kiếm và chọn các loại thực phẩm từ cơ sở dữ liệu để chúng tôi xây dựng thực đơn.',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                onChanged: _onSearchChanged,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Tìm kiếm tên thực phẩm...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdown('Danh mục', _selectedCategory, _categories, _onCategoryChanged),
              const SizedBox(height: 8),
              Text('Đã chọn: ${_selectedFoods.length} thực phẩm', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingFoods
              ? const Center(child: CircularProgressIndicator())
              : _fetchedFoods.isEmpty
                  ? const Center(child: Text('Không tìm thấy thực phẩm nào.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _fetchedFoods.length,
                      itemBuilder: (context, index) {
                        final food = _fetchedFoods[index];
                        final isSelected = _selectedFoods.any((f) => f.id == food.id);
                        return Card(
                          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade800),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFoods.removeWhere((f) => f.id == food.id);
                                } else {
                                  _selectedFoods.add(food);
                                }
                              });
                            },
                            title: Text(food.nameVi, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${food.energy ?? '-'} kcal | P: ${food.protein ?? '-'}g | C: ${food.carb ?? '-'}g | F: ${food.fat ?? '-'}g\n${food.category}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                                : Icon(Icons.circle_outlined, color: Colors.grey.shade600),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('CẤU TRÚC BỮA ĂN',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5)),
        const SizedBox(height: 24),
        Text('Một ngày bạn chia bao nhiêu bữa?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDropdownInt('Số bữa', _mealsPerDay, [3, 4, 5], (val) {
          setState(() => _mealsPerDay = val!);
        }, suffix: 'bữa'),
        const SizedBox(height: 24),
        Text('Số loại thịt trong một ngày?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDropdownInt('Số loại', _meatsPerDay, [1, 2, 3], (val) {
          setState(() => _meatsPerDay = val!);
        }, suffix: 'loại'),
        const SizedBox(height: 24),
        Text('Số ngày xây dựng thực đơn?',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildDropdownInt('Số ngày', _planDays, [1, 2, 3, 4, 5, 6, 7], (val) {
          setState(() => _planDays = val!);
        }, suffix: 'ngày'),
        const SizedBox(height: 8),
        Builder(
          builder: (context) {
            int meatCount = _selectedFoods.where((f) => 
                f.category.contains('Thịt') || 
                f.category.contains('Thủy sản') || 
                f.category.contains('Trứng')).length;
            if (meatCount == 0) meatCount = 1;
            return Text('Gợi ý: Dựa trên số lượng thịt bạn đã chọn ở bước trước, bạn nên tạo thực đơn cho $meatCount ngày rồi lặp lại.',
               style: const TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic));
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownInt(String label, int value, List<int> items,
      ValueChanged<int?> onChanged, {String suffix = ''}) {
    return DropdownButtonFormField<int>(
      value: value,
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(suffix.isEmpty ? '$item' : '$item $suffix')))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade900)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() {
                  _currentStep--;
                });
              },
              child: const Text('QUAY LẠI',
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0)),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(_currentStep < 2 ? 'TIẾP TỤC' : 'HOÀN THÀNH',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ),
        ],
      ),
    );
  }
}
