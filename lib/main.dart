import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  await NotificationService().initialize();

  // Initialize Supabase Backend
  await Supabase.initialize(
    url: SupabaseConstants.url, // Placeholder: Replace with actual Supabase URL
    anonKey: SupabaseConstants.anonKey, // Placeholder: Replace with actual Anon Key
  );

  runApp(
    const ProviderScope(
      child: VeluneApp(),
    ),
  );
}

/// Convenience getter for the global Supabase client instance
final supabase = Supabase.instance.client;

class VeluneApp extends StatelessWidget {
  const VeluneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VELUNE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
