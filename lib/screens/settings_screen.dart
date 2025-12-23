import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../models/theme_mode.dart';
import '../utils/logger.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static final _logger = Logger('SettingsScreen');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final localeSettings = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appearance,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Theme Mode Selection
                  Text(
                    l10n.themeMode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.currentTheme(themeSettings.mode.name, Theme.of(context).brightness.name),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Light Mode
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.lightMode),
                    subtitle: Text(l10n.lightModeDesc),
                    value: AppThemeMode.light,
                    groupValue: themeSettings.mode,
                    onChanged: (value) {
                      if (value != null) {
                        _logger.debug('Setting theme mode to: ${value.name}');
                        themeNotifier.setThemeMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Dark Mode
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.darkMode),
                    subtitle: Text(l10n.darkModeDesc),
                    value: AppThemeMode.dark,
                    groupValue: themeSettings.mode,
                    onChanged: (value) {
                      if (value != null) {
                        _logger.debug('Setting theme mode to: ${value.name}');
                        themeNotifier.setThemeMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // System Mode
                  RadioListTile<AppThemeMode>(
                    title: Text(l10n.systemMode),
                    subtitle: Text(l10n.systemModeDesc),
                    value: AppThemeMode.system,
                    groupValue: themeSettings.mode,
                    onChanged: (value) {
                      if (value != null) {
                        _logger.debug('Setting theme mode to: ${value.name}');
                        themeNotifier.setThemeMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Language Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.languageDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),

                  // English
                  RadioListTile<AppLocale>(
                    title: Row(
                      children: [
                        Text(AppLocale.english.flag),
                        const SizedBox(width: 12),
                        Text(l10n.english),
                      ],
                    ),
                    value: AppLocale.english,
                    groupValue: localeSettings.locale,
                    onChanged: (value) {
                      if (value != null) {
                        _logger.debug('Setting locale to: ${value.code}');
                        localeNotifier.setLocale(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Korean
                  RadioListTile<AppLocale>(
                    title: Row(
                      children: [
                        Text(AppLocale.korean.flag),
                        const SizedBox(width: 12),
                        Text(l10n.korean),
                      ],
                    ),
                    value: AppLocale.korean,
                    groupValue: localeSettings.locale,
                    onChanged: (value) {
                      if (value != null) {
                        _logger.debug('Setting locale to: ${value.code}');
                        localeNotifier.setLocale(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.about,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.appVersion),
                    subtitle: const Text('1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(Icons.church),
                    title: Text(l10n.reviveChurch),
                    subtitle: Text(l10n.churchManagementAssistant),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
