import 'package:change_life/features/habit/providers/habit_provider.dart';
import 'package:change_life/router/app_router.dart';
import 'package:change_life/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();
  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
