import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:change_life/features/settings/providers/setting_provider.dart';
import 'package:change_life/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Giao diện',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Kinetic Discipline (Nền Tối)'),
            subtitle: const Text('Giao diện gốc xanh dạ quang'),
            value: AppThemeMode.kineticDiscipline,
            groupValue: settings.currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).changeTheme(value);
              }
            },
          ),
          RadioListTile<AppThemeMode>(
            title: const Text('Serene Blue (Nền Sáng)'),
            subtitle: const Text('Giao diện xanh lam dịu nhẹ'),
            value: AppThemeMode.sereneBlue,
            groupValue: settings.currentTheme,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).changeTheme(value);
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Ngôn ngữ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ hiển thị'),
            trailing: const Text(
              'Tiếng Việt',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            onTap: () {
              // TODO: Implement language selection
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Nhắc nhở tập luyện'),
            value: true,
            onChanged: (value) {
              // TODO: Implement notifications
            },
            secondary: const Icon(Icons.notifications_active_outlined),
          ),
          SwitchListTile(
            title: const Text('Nhắc nhở uống nước'),
            value: false,
            onChanged: (value) {
              // TODO: Implement notifications
            },
            secondary: const Icon(Icons.water_drop_outlined),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Thông tin ứng dụng',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Chính sách bảo mật (Privacy Policy)'),
            onTap: () {
              // TODO: Navigate to Privacy Policy screen or open URL
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chính sách bảo mật đang được cập nhật.'),
                ),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Phiên bản ứng dụng'),
            trailing: Text(
              'v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
