import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales in the app
enum AppLocale {
  english('en', 'English', '🇺🇸'),
  korean('ko', '한국어', '🇰🇷');

  const AppLocale(this.code, this.displayName, this.flag);

  final String code;
  final String displayName;
  final String flag;

  Locale get locale => Locale(code);

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.english,
    );
  }
}

/// Provider for locale settings
final localeProvider =
    StateNotifierProvider<LocaleNotifier, LocaleSettings>((ref) {
  return LocaleNotifier();
});

/// Locale settings state
class LocaleSettings {
  final AppLocale locale;

  const LocaleSettings({this.locale = AppLocale.english});

  LocaleSettings copyWith({AppLocale? locale}) {
    return LocaleSettings(locale: locale ?? this.locale);
  }
}

/// Locale notifier for managing locale state
class LocaleNotifier extends StateNotifier<LocaleSettings> {
  LocaleNotifier() : super(const LocaleSettings()) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        state = LocaleSettings(locale: AppLocale.fromCode(localeCode));
      }
    } catch (e) {
      // If loading fails, keep default (English)
    }
  }

  Future<void> setLocale(AppLocale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.code);
      state = state.copyWith(locale: locale);
    } catch (e) {
      // Silent fail for locale preference save
    }
  }

  Locale get currentLocale => state.locale.locale;
}
