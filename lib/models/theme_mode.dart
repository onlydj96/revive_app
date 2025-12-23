import 'package:flutter/material.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  /// Convert AppThemeMode to Flutter's ThemeMode
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

class ThemeSettings {
  final AppThemeMode mode;

  const ThemeSettings({
    this.mode = AppThemeMode.system,
  });

  ThemeSettings copyWith({
    AppThemeMode? mode,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
    );
  }
}
