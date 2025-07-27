import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'services/deep_link_service.dart';
import 'providers/theme_provider.dart';
import 'config/app_theme.dart';
import 'models/theme_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Deep Link Service
  await DeepLinkService.instance.initialize();
  
  runApp(const ProviderScope(child: EzerApp()));
}

class EzerApp extends ConsumerWidget {
  const EzerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    
    // Convert AppThemeMode to ThemeMode
    ThemeMode themeMode;
    switch (themeSettings.mode) {
      case AppThemeMode.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        themeMode = ThemeMode.system;
        break;
    }
    
    print('Main: Building with theme mode: ${themeSettings.mode.name} -> ${themeMode.name}');
    
    return MaterialApp.router(
      title: 'Ezer - Revive Church',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
