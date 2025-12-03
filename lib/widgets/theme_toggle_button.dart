import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_mode.dart';
import '../providers/theme_provider.dart';

/// A widget that displays a theme mode toggle button
///
/// This widget allows users to switch between light, dark, and system themes.
/// It can be displayed as either an icon button or a menu button with options.
class ThemeToggleButton extends ConsumerWidget {
  /// The style of the toggle button
  final ThemeToggleStyle style;

  /// Optional icon size (defaults to 24)
  final double iconSize;

  /// Optional tooltip text
  final String? tooltip;

  const ThemeToggleButton({
    super.key,
    this.style = ThemeToggleStyle.icon,
    this.iconSize = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    if (style == ThemeToggleStyle.menu) {
      return _buildMenuButton(context, themeSettings, themeNotifier);
    } else {
      return _buildIconButton(context, themeSettings, themeNotifier);
    }
  }

  /// Build a simple icon button that cycles through themes
  Widget _buildIconButton(
    BuildContext context,
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    final IconData icon;
    final String tooltipText;

    switch (themeSettings.mode) {
      case AppThemeMode.light:
        icon = Icons.light_mode;
        tooltipText = 'Light mode';
        break;
      case AppThemeMode.dark:
        icon = Icons.dark_mode;
        tooltipText = 'Dark mode';
        break;
      case AppThemeMode.system:
        icon = Icons.brightness_auto;
        tooltipText = 'System theme';
        break;
    }

    return IconButton(
      icon: Icon(icon, size: iconSize),
      tooltip: tooltip ?? tooltipText,
      onPressed: () {
        final nextMode = _getNextThemeMode(themeSettings.mode);
        themeNotifier.setThemeMode(nextMode);
      },
    );
  }

  /// Build a popup menu button with all theme options
  Widget _buildMenuButton(
    BuildContext context,
    ThemeSettings themeSettings,
    ThemeNotifier themeNotifier,
  ) {
    return PopupMenuButton<AppThemeMode>(
      icon: Icon(_getThemeIcon(themeSettings.mode), size: iconSize),
      tooltip: tooltip ?? 'Theme mode',
      onSelected: (AppThemeMode mode) {
        themeNotifier.setThemeMode(mode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<AppThemeMode>>[
        PopupMenuItem<AppThemeMode>(
          value: AppThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                color: themeSettings.mode == AppThemeMode.light
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Light',
                style: TextStyle(
                  fontWeight: themeSettings.mode == AppThemeMode.light
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<AppThemeMode>(
          value: AppThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                color: themeSettings.mode == AppThemeMode.dark
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'Dark',
                style: TextStyle(
                  fontWeight: themeSettings.mode == AppThemeMode.dark
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<AppThemeMode>(
          value: AppThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.brightness_auto,
                color: themeSettings.mode == AppThemeMode.system
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                'System',
                style: TextStyle(
                  fontWeight: themeSettings.mode == AppThemeMode.system
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get the icon for the current theme mode
  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Get the next theme mode in the cycle (Light → Dark → System → Light)
  AppThemeMode _getNextThemeMode(AppThemeMode current) {
    switch (current) {
      case AppThemeMode.light:
        return AppThemeMode.dark;
      case AppThemeMode.dark:
        return AppThemeMode.system;
      case AppThemeMode.system:
        return AppThemeMode.light;
    }
  }
}

/// The style of the theme toggle button
enum ThemeToggleStyle {
  /// Simple icon button that cycles through themes
  icon,

  /// Menu button with all theme options
  menu,
}

/// A widget that displays a theme mode list tile for settings screens
class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    String getCurrentModeText() {
      switch (themeSettings.mode) {
        case AppThemeMode.light:
          return 'Light';
        case AppThemeMode.dark:
          return 'Dark';
        case AppThemeMode.system:
          return 'System';
      }
    }

    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Theme'),
      subtitle: Text(getCurrentModeText()),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Choose Theme'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThemeModeOption(
                    mode: AppThemeMode.light,
                    currentMode: themeSettings.mode,
                    onTap: () {
                      themeNotifier.setThemeMode(AppThemeMode.light);
                      Navigator.pop(context);
                    },
                  ),
                  _ThemeModeOption(
                    mode: AppThemeMode.dark,
                    currentMode: themeSettings.mode,
                    onTap: () {
                      themeNotifier.setThemeMode(AppThemeMode.dark);
                      Navigator.pop(context);
                    },
                  ),
                  _ThemeModeOption(
                    mode: AppThemeMode.system,
                    currentMode: themeSettings.mode,
                    onTap: () {
                      themeNotifier.setThemeMode(AppThemeMode.system);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Internal widget for theme mode options in dialog
class _ThemeModeOption extends StatelessWidget {
  final AppThemeMode mode;
  final AppThemeMode currentMode;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.mode,
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == currentMode;

    IconData icon;
    String label;

    switch (mode) {
      case AppThemeMode.light:
        icon = Icons.light_mode;
        label = 'Light';
        break;
      case AppThemeMode.dark:
        icon = Icons.dark_mode;
        label = 'Dark';
        break;
      case AppThemeMode.system:
        icon = Icons.brightness_auto;
        label = 'System';
        break;
    }

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
