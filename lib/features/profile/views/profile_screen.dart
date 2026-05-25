import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageService = ref.watch(storageServiceProvider);

    final userName = storageService.getUsername();
    final gender = storageService.getGender();
    final age = storageService.getAge();
    final height = storageService.getHeight();
    final weight = storageService.getWeight();
    final tdee = storageService.getNutritionTotalCalories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
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
              child: Icon(Icons.person, size: 60, color: Theme.of(context).colorScheme.onPrimary),
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
            const SizedBox(height: 32),

            // 2. Body Metrics
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ClipRect(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ImageFiltered(
                            imageFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: storageService.hasConfiguredNutrition() ? 0 : 0.6),
                              BlendMode.darken,
                            ),
                            child: ImageFiltered(
                              imageFilter: storageService.hasConfiguredNutrition()
                                  ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                                  : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildMetricItem('Giới tính', gender),
                                      _buildMetricItem('Tuổi', '$age'),
                                      _buildMetricItem('Chiều cao', '${height.toStringAsFixed(0)} cm'),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildMetricItem('Cân nặng', '${weight.toStringAsFixed(1)} kg'),
                                      _buildMetricItem('Mục tiêu Calo', '$tdee kcal'),
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
            const SizedBox(height: 32),

            // 5. Support & Others
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
                      // Navigate to privacy policy or show dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Chính sách bảo mật'),
                          content: const Text('Chính sách bảo mật của Change Life...'),
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
                    trailing: Text('v1.0.0', style: TextStyle(color: Colors.grey)),
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
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
