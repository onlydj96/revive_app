enum AppThemeMode {
  light,
  dark,
  system,
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
