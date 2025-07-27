import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_mode.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeSettings>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeSettings> {
  ThemeNotifier() : super(const ThemeSettings()) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      state = ThemeSettings(mode: AppThemeMode.values[themeIndex]);
    } catch (e) {
      // If loading fails, keep default
      print('Failed to load theme preference: $e');
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      print('ThemeNotifier: Setting theme mode to ${mode.name}');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
      state = state.copyWith(mode: mode);
      print('ThemeNotifier: Theme mode set successfully. Current state: ${state.mode.name}');
      print('ThemeNotifier: Computed ThemeMode: ${themeMode.name}');
    } catch (e) {
      print('Failed to save theme preference: $e');
    }
  }

  ThemeMode get themeMode {
    switch (state.mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}