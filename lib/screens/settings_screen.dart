import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../models/theme_mode.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
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
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Theme Mode Selection
                  Text(
                    'Theme Mode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: ${themeSettings.mode.name} | System: ${Theme.of(context).brightness.name}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Light Mode
                  RadioListTile<AppThemeMode>(
                    title: const Text('Light Mode'),
                    subtitle: const Text('Always use light theme'),
                    value: AppThemeMode.light,
                    groupValue: themeSettings.mode,
                    onChanged: (value) {
                      if (value != null) {
                        print('Setting theme mode to: ${value.name}');
                        themeNotifier.setThemeMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  // Dark Mode
                  RadioListTile<AppThemeMode>(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Always use dark theme'),
                    value: AppThemeMode.dark,
                    groupValue: themeSettings.mode,
                    onChanged: (value) {
                      if (value != null) {
                        print('Setting theme mode to: ${value.name}');
                        themeNotifier.setThemeMode(value);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  // System Mode
                  RadioListTile<AppThemeMode>(
                    title: const Text('System'),
                    subtitle: const Text('Follow system theme'),
                    value: AppThemeMode.system,
                    groupValue: themeSettings.mode,
                    onChanged: (value) {
                      if (value != null) {
                        print('Setting theme mode to: ${value.name}');
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
          
          // App Info Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  ListTile(
                    leading: const Icon(Icons.church),
                    title: const Text('Revive Church'),
                    subtitle: const Text('Church Management Assistant'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}