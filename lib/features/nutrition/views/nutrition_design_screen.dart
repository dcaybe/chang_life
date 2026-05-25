import 'package:change_life/features/nutrition/models/meal_plan_model.dart';
import 'package:change_life/features/nutrition/providers/nutrition_provider.dart';
import 'package:change_life/features/nutrition/providers/nutrition_services.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // Form Step 2
  final List<String> _availableFoods = [
    'Cơm',
    'Ức gà',
    'Thịt lợn',
    'Thịt bò',
    'Cá',
    'Trứng',
    'Chuối',
    'Lạc',
    'Rau xanh',
    'Khoai lang'
  ];
  final List<String> _selectedFoods = [];
  int _meatsPerDay = 2;
  int _mealsPerDay = 4;

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
      selectedFoods: _selectedFoods,
      mealsPerDay: _mealsPerDay,
    );

    if (mounted) {
      Navigator.pop(context); // Go back to nutrition screen
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
        if (_goal == 'Tăng cơ, tăng cân') ...[
          const SizedBox(height: 16),
          _buildTextField('Mục tiêu cân nặng (kg)', _targetWeightController,
              TextInputType.number),
        ],
      ],
    );
  }

  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('THỰC PHẨM ƯU THÍCH',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5)),
        const SizedBox(height: 8),
        const Text('Chọn các loại thực phẩm bạn thường xuyên sử dụng',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableFoods.map((food) {
            final isSelected = _selectedFoods.contains(food);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedFoods.remove(food);
                  } else {
                    _selectedFoods.add(food);
                  }
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).cardColor,
                  border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade800),
                ),
                child: Text(
                  food,
                  style: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
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
            borderSide: BorderSide(color: Colors.transparent)),
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
            borderSide: BorderSide(color: Colors.transparent)),
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
            borderSide: BorderSide(color: Colors.transparent)),
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
