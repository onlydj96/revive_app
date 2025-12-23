import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';
import 'services/deep_link_service.dart';
import 'services/storage_service.dart';
import 'services/push_notification_service.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'config/app_theme.dart';
import 'utils/logger.dart';

final _logger = Logger('Main');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIXED P0-5: Load environment variables before initializing services
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    _logger.info('Firebase initialized successfully');
  } catch (e) {
    _logger.error('Firebase initialization failed', e);
  }

  // Initialize Deep Link Service
  await DeepLinkService.instance.initialize();

  // PERF: Initialize storage buckets once at app startup
  // Prevents redundant initialization on every HomeScreen visit
  try {
    await StorageService.initializeBuckets();
  } catch (e) {
    // Log error but continue - storage will be retried if needed
    _logger.error('Storage initialization failed', e);
  }

  // Initialize Push Notification Service
  try {
    await PushNotificationService().initialize();
    _logger.info('Push notification service initialized');
  } catch (e) {
    _logger.error('Push notification initialization failed', e);
  }

  runApp(const ProviderScope(child: EzerApp()));
}

class EzerApp extends ConsumerWidget {
  const EzerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final localeSettings = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Ezer - Revive Church',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeSettings.mode.toThemeMode(),
      routerConfig: appRouter,
      // Localization configuration
      locale: localeSettings.locale.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
