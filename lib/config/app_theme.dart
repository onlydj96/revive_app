import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================================
  // Material Design 3 Color System - Expanded Palette
  // ============================================================================

  // ============================================================================
  // LIGHT THEME COLORS
  // ============================================================================

  // 🟪 Primary Colors (보라 계열 - 브랜드 컬러)
  static const Color primary = Color(0xFF6750A4); // M3 권장 보라 톤
  static const Color onPrimary = Color(0xFFFFFFFF); // 텍스트 대비 최적
  static const Color primaryContainer = Color(0xFFEADDFF); // 강조면/버튼배경
  static const Color onPrimaryContainer = Color(0xFF21005D); // 읽기 좋은 텍스트

  // 🟩 Secondary Colors (청록 계열 - CTA/액센트)
  static const Color secondary = Color(0xFF1A9988); // 채도 조정된 안정적 청록
  static const Color onSecondary = Color(0xFFFFFFFF); // 가독성
  static const Color secondaryContainer = Color(0xFFD0F4EF); // 밝은 액센트 배경
  static const Color onSecondaryContainer = Color(0xFF0B4740); // 고대비 텍스트

  // 🟫 Tertiary Colors (보조 컬러 - 중화 역할)
  static const Color tertiary = Color(0xFF7D5260); // 보조 액센트
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD9E3); // 부드러운 배경
  static const Color onTertiaryContainer = Color(0xFF31111D);

  // ⚪ Neutral Tones (UI 기본 톤 - 배경/텍스트/카드)
  static const Color neutralN0 = Color(0xFFFFFFFF); // 순백
  static const Color neutralN10 = Color(0xFFF5F5F5); // 매우 밝은 회색
  static const Color neutralN20 = Color(0xFFE6E1E5); // 밝은 회색
  static const Color neutralN30 = Color(0xFFCAC4D0); // 중간 밝은 회색
  static const Color neutralN50 = Color(0xFF79747E); // 중간 회색
  static const Color neutralN70 = Color(0xFF49454F); // 어두운 회색
  static const Color neutralN90 = Color(0xFF1D1B20); // 매우 어두운 회색

  // 🎨 Surface & Background
  static const Color surface = Color(0xFFFFFBFE); // 기본 surface
  static const Color onSurface = Color(0xFF1D1B20); // surface 위 텍스트
  static const Color surfaceVariant = Color(0xFFE7E0EC); // 변형 surface
  static const Color onSurfaceVariant = Color(0xFF49454F); // 변형 surface 텍스트
  static const Color background = Color(0xFFFFFBFE); // 기본 배경
  static const Color onBackground = Color(0xFF1D1B20); // 배경 위 텍스트

  // 📐 Outline & Divider
  static const Color outline = Color(0xFF79747E); // 테두리
  static const Color outlineVariant = Color(0xFFCAC4D0); // 부드러운 구분선

  // 🔴 Semantic Colors (의미 기반 색)
  static const Color error = Color(0xFFBA1A1A); // M3 표준 오류
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color success = Color(0xFF0A8754); // 시각적 안정감 있는 녹색
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFA6F4C5);
  static const Color onSuccessContainer = Color(0xFF002114);

  static const Color warning = Color(0xFFFFB703); // 과한 채도 방지
  static const Color onWarning = Color(0xFF000000);
  static const Color warningContainer = Color(0xFFFFE8B3);
  static const Color onWarningContainer = Color(0xFF3D2E00);

  static const Color info = Color(0xFF219EBC); // 정보성 메시지
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFD0F0FF);
  static const Color onInfoContainer = Color(0xFF001E2B);

  // ============================================================================
  // DARK THEME COLORS
  // ============================================================================

  // 🟪 Primary Colors (Dark)
  static const Color darkPrimary = Color(0xFFD0BCFF); // 밝은 보라
  static const Color darkOnPrimary = Color(0xFF381E72); // 대비
  static const Color darkPrimaryContainer = Color(0xFF4F378B); // 컨테이너
  static const Color darkOnPrimaryContainer = Color(0xFFEADDFF);

  // 🟩 Secondary Colors (Dark)
  static const Color darkSecondary = Color(0xFF74DCCE); // 밝은 청록
  static const Color darkOnSecondary = Color(0xFF003E38);
  static const Color darkSecondaryContainer = Color(0xFF345E58);
  static const Color darkOnSecondaryContainer = Color(0xFFA8F5EB);

  // 🟫 Tertiary Colors (Dark)
  static const Color darkTertiary = Color(0xFFEFB8C8); // 밝은 핑크
  static const Color darkOnTertiary = Color(0xFF492532);
  static const Color darkTertiaryContainer = Color(0xFF633B48);
  static const Color darkOnTertiaryContainer = Color(0xFFFFD9E3);

  // 🌙 Surface & Background (Dark)
  static const Color darkSurface = Color(0xFF1C1B1F); // 기본 다크 surface
  static const Color darkOnSurface = Color(0xFFE6E1E5); // 텍스트
  static const Color darkSurfaceVariant = Color(0xFF49454F); // 변형 surface
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkBackground = Color(0xFF1C1B1F); // 배경
  static const Color darkOnBackground = Color(0xFFE6E1E5);

  // 📐 Outline & Divider (Dark)
  static const Color darkOutline = Color(0xFF938F99); // 테두리
  static const Color darkOutlineVariant = Color(0xFF49454F); // 부드러운 구분선

  // 🔴 Semantic Colors (Dark)
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkSuccess = Color(0xFF79DDA7);
  static const Color darkOnSuccess = Color(0xFF003920);
  static const Color darkSuccessContainer = Color(0xFF005234);
  static const Color darkOnSuccessContainer = Color(0xFFA6F4C5);

  static const Color darkWarning = Color(0xFFFFD180);
  static const Color darkOnWarning = Color(0xFF3D2E00);
  static const Color darkWarningContainer = Color(0xFF5B4300);
  static const Color darkOnWarningContainer = Color(0xFFFFE8B3);

  static const Color darkInfo = Color(0xFF7DD3F0);
  static const Color darkOnInfo = Color(0xFF003544);
  static const Color darkInfoContainer = Color(0xFF004D61);
  static const Color darkOnInfoContainer = Color(0xFFD0F0FF);

  // ============================================================================
  // Light Theme Configuration
  // ============================================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Explicit primary colors for backward compatibility
    primaryColor: primary,
    primaryColorLight: primaryContainer,
    primaryColorDark: onPrimaryContainer,

    // Color Scheme - Material 3 complete semantic colors
    colorScheme: const ColorScheme.light(
      // Primary colors
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,

      // Secondary colors
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,

      // Tertiary colors
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,

      // Surface colors
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: neutralN0,

      // Error colors
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,

      // Outline colors
      outline: outline,
      outlineVariant: outlineVariant,
    ),

    // Scaffold background
    scaffoldBackgroundColor: surface,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Colors.transparent,
      foregroundColor: primary,
      titleTextStyle: TextStyle(
        color: primary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: primary),
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: neutralN0,
      surfaceTintColor: primaryContainer,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primary,
      unselectedItemColor: neutralN50,
      backgroundColor: surface,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: neutralN0,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: neutralN50),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondary,
      foregroundColor: onSecondary,
      elevation: 6,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: primaryContainer,
      labelStyle: const TextStyle(color: onPrimaryContainer),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: outlineVariant,
      thickness: 1,
      space: 1,
    ),
  );

  // ============================================================================
  // Dark Theme Configuration
  // ============================================================================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Explicit primary colors for backward compatibility
    primaryColor: darkPrimary,
    primaryColorLight: darkPrimary,
    primaryColorDark: darkPrimaryContainer,

    // Color Scheme - Material 3 complete semantic colors for dark mode
    colorScheme: const ColorScheme.dark(
      // Primary colors
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      primaryContainer: darkPrimaryContainer,
      onPrimaryContainer: darkOnPrimaryContainer,

      // Secondary colors
      secondary: darkSecondary,
      onSecondary: darkOnSecondary,
      secondaryContainer: darkSecondaryContainer,
      onSecondaryContainer: darkOnSecondaryContainer,

      // Tertiary colors
      tertiary: darkTertiary,
      onTertiary: darkOnTertiary,
      tertiaryContainer: darkTertiaryContainer,
      onTertiaryContainer: darkOnTertiaryContainer,

      // Surface colors
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerHighest: darkSurfaceVariant,

      // Error colors
      error: darkError,
      onError: darkOnError,
      errorContainer: darkErrorContainer,
      onErrorContainer: darkOnErrorContainer,

      // Outline colors
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,

      // Surface variant
      onSurfaceVariant: darkOnSurfaceVariant,
    ),

    // Scaffold background
    scaffoldBackgroundColor: darkBackground,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: Colors.transparent,
      foregroundColor: darkPrimary,
      titleTextStyle: TextStyle(
        color: darkPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: darkPrimary),
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: darkSurface,
      surfaceTintColor: darkPrimary.withValues(alpha: 0.05),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkSecondary,
      unselectedItemColor: darkOutline,
      backgroundColor: darkSurface,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkOutline),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkError, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: darkOutline),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkSecondary,
        foregroundColor: darkOnSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 2,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkSecondary,
      foregroundColor: darkOnSecondary,
      elevation: 6,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: darkPrimaryContainer,
      labelStyle: const TextStyle(color: darkOnPrimaryContainer),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: darkOutlineVariant,
      thickness: 1,
      space: 1,
    ),

    // Text Theme - enhanced readability for dark mode
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Color(0xFFE6E1E5)),
      displayMedium: TextStyle(color: Color(0xFFE6E1E5)),
      displaySmall: TextStyle(color: Color(0xFFE6E1E5)),
      headlineLarge: TextStyle(color: Color(0xFFE6E1E5)),
      headlineMedium: TextStyle(color: Color(0xFFE6E1E5)),
      headlineSmall: TextStyle(color: Color(0xFFE6E1E5)),
      titleLarge: TextStyle(color: Color(0xFFE6E1E5)),
      titleMedium: TextStyle(color: Color(0xFFE6E1E5)),
      titleSmall: TextStyle(color: Color(0xFFCAC4D0)),
      bodyLarge: TextStyle(color: Color(0xFFE6E1E5)),
      bodyMedium: TextStyle(color: Color(0xFFCAC4D0)),
      bodySmall: TextStyle(color: Color(0xFF938F99)),
      labelLarge: TextStyle(color: Color(0xFFE6E1E5)),
      labelMedium: TextStyle(color: Color(0xFFCAC4D0)),
      labelSmall: TextStyle(color: Color(0xFF938F99)),
    ),
  );

  // ============================================================================
  // Theme Helper Methods
  // ============================================================================

  /// Get appropriate text color based on background brightness
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOnSurface
        : onSurface;
  }

  /// Get appropriate secondary text color
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkOnSurfaceVariant
        : onSurfaceVariant;
  }

  /// Get appropriate surface color
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  /// Get appropriate card color
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : neutralN0;
  }

  // ============================================================================
  // Semantic Color Helpers
  // ============================================================================

  /// Get success color
  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSuccess
        : success;
  }

  /// Get success container color
  static Color getSuccessContainerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSuccessContainer
        : successContainer;
  }

  /// Get warning color
  static Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkWarning
        : warning;
  }

  /// Get warning container color
  static Color getWarningContainerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkWarningContainer
        : warningContainer;
  }

  /// Get info color
  static Color getInfoColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkInfo
        : info;
  }

  /// Get info container color
  static Color getInfoContainerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkInfoContainer
        : infoContainer;
  }

  // ============================================================================
  // Utility Methods - Material Design 3 Integrated
  // ============================================================================

  /// 색상이 밝은지 어두운지 판단 (for dynamic contrast calculation)
  /// Returns true if the color is light, false if dark
  /// Use case: Custom color badges, dynamic theming
  static bool isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }

  /// 주어진 배경색에 대한 대비되는 텍스트 색상 반환
  /// Returns contrasting text color for the given background
  /// Use case: Custom colored containers, badges, chips
  static Color contrastText(Color backgroundColor) {
    return isLightColor(backgroundColor) ? onSurface : Colors.white;
  }

  /// 다크 모드 대응 대비 텍스트 색상
  /// Returns contrasting text color with dark mode support
  static Color contrastTextDynamic(BuildContext context, Color backgroundColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isLightColor(backgroundColor)
        ? (isDark ? darkOnSurface : onSurface)
        : Colors.white;
  }

  // ============================================================================
  // Material Design 3 Container Colors (replaces alpha-based variants)
  // ============================================================================

  /// Primary container color (M3 standard for light backgrounds)
  /// Replaces: primaryLight() - Use this instead of alpha-based overlays
  static Color getPrimaryContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimaryContainer
        : primaryContainer;
  }

  /// Secondary container color (M3 standard for accent backgrounds)
  static Color getSecondaryContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSecondaryContainer
        : secondaryContainer;
  }

  /// Tertiary container color (M3 standard for auxiliary backgrounds)
  static Color getTertiaryContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTertiaryContainer
        : tertiaryContainer;
  }

  // ============================================================================
  // Material Design 3 Surface Elevation System
  // ============================================================================

  /// Surface Level 0 - Base surface (cards at rest)
  static Color getSurfaceLevel0(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : surface;
  }

  /// Surface Level 1 - Slightly elevated (0dp to 1dp)
  /// Use case: Cards, sheets at rest
  static Color getSurfaceLevel1(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color.alphaBlend(darkPrimary.withValues(alpha: 0.05), darkSurface)
        : surface;
  }

  /// Surface Level 2 - Moderately elevated (1dp to 3dp)
  /// Use case: Hovered cards, app bars
  static Color getSurfaceLevel2(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color.alphaBlend(darkPrimary.withValues(alpha: 0.08), darkSurface)
        : surface;
  }

  /// Surface Level 3 - Elevated (3dp to 6dp)
  /// Use case: Dialogs, bottom sheets
  static Color getSurfaceLevel3(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color.alphaBlend(darkPrimary.withValues(alpha: 0.11), darkSurface)
        : surface;
  }

  /// Surface Level 4 - Highly elevated (6dp to 8dp)
  /// Use case: Navigation drawers
  static Color getSurfaceLevel4(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color.alphaBlend(darkPrimary.withValues(alpha: 0.12), darkSurface)
        : surface;
  }

  /// Surface Level 5 - Maximum elevation (8dp+)
  /// Use case: Modal bottom sheets, floating action buttons
  static Color getSurfaceLevel5(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color.alphaBlend(darkPrimary.withValues(alpha: 0.14), darkSurface)
        : surface;
  }

  // ============================================================================
  // Overlay & Scrim Colors (for images, gradients, modals)
  // ============================================================================

  /// 어두운 오버레이 (이미지 위 그라데이션 등)
  /// Use case: Image overlays, text readability on images
  static const Color overlayDark = Color(0x80000000); // black with 50% opacity

  /// 밝은 오버레이
  /// Use case: Light backgrounds, reverse contrast overlays
  static const Color overlayLight = Color(0x80FFFFFF); // white with 50% opacity

  /// 모달 스크림 (modal bottom sheet, dialog 배경)
  /// Use case: Modal backgrounds, focus dimming
  static const Color scrimModal = Color(0x99000000); // black with 60% opacity

  /// 부드러운 스크림 (subtle dimming)
  /// Use case: Subtle overlays, loading states
  static const Color scrimSubtle = Color(0x33000000); // black with 20% opacity
}

// ============================================================================
// Spacing System - Consistent spacing values across the app
// ============================================================================

/// Material Design 3 기반 spacing 시스템
/// 일관된 간격을 위한 상수 정의
class AppSpacing {
  AppSpacing._();

  // Base unit: 4dp (following Material Design)
  static const double unit = 4.0;

  /// Extra small spacing (4dp) - Minimal spacing
  static const double xs = 4.0;

  /// Small spacing (8dp) - Compact spacing
  static const double sm = 8.0;

  /// Medium spacing (12dp) - Default item spacing
  static const double md = 12.0;

  /// Large spacing (16dp) - Section spacing, padding
  static const double lg = 16.0;

  /// Extra large spacing (24dp) - Large section gaps
  static const double xl = 24.0;

  /// Double extra large spacing (32dp) - Major section dividers
  static const double xxl = 32.0;

  /// Triple extra large spacing (48dp) - Page-level spacing
  static const double xxxl = 48.0;

  /// Huge spacing (64dp) - Empty state padding
  static const double huge = 64.0;

  // ============================================================================
  // Semantic Spacing
  // ============================================================================

  /// Default screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);

  /// Card content padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Compact card padding
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Section title margin bottom
  static const double sectionTitleSpacing = md;

  /// Space between cards/items in a list
  static const double listItemSpacing = md;

  /// Space between sections
  static const double sectionSpacing = xl;

  /// Space between groups within a section
  static const double groupSpacing = lg;

  // ============================================================================
  // SizedBox helpers
  // ============================================================================

  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);

  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
}

/// Material Design 3 색상 시스템을 위한 BuildContext 확장
/// Extension for Material Design 3 color system with brightness awareness
extension AppThemeExtension on BuildContext {
  // ==========================================================================
  // Primary Colors
  // ==========================================================================

  /// 현재 테마의 primary 색상
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Primary container 색상 (M3 standard for light backgrounds)
  /// Replaces: primaryLightBackground - Use this for chips, badges, light backgrounds
  Color get primaryContainer => AppTheme.getPrimaryContainer(this);

  /// Primary container 위의 텍스트 색상
  Color get onPrimaryContainer => Theme.of(this).colorScheme.onPrimaryContainer;

  // ==========================================================================
  // Secondary Colors
  // ==========================================================================

  /// Secondary 색상
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;

  /// Secondary container 색상 (accent backgrounds)
  Color get secondaryContainer => AppTheme.getSecondaryContainer(this);

  /// Secondary container 위의 텍스트 색상
  Color get onSecondaryContainer => Theme.of(this).colorScheme.onSecondaryContainer;

  // ==========================================================================
  // Tertiary Colors
  // ==========================================================================

  /// Tertiary 색상
  Color get tertiaryColor => Theme.of(this).colorScheme.tertiary;

  /// Tertiary container 색상 (auxiliary backgrounds)
  Color get tertiaryContainer => AppTheme.getTertiaryContainer(this);

  /// Tertiary container 위의 텍스트 색상
  Color get onTertiaryContainer => Theme.of(this).colorScheme.onTertiaryContainer;

  // ==========================================================================
  // Surface & Background Colors (with elevation support)
  // ==========================================================================

  /// Base surface 색상
  Color get surfaceColor => AppTheme.getSurfaceColor(this);

  /// Surface Level 1 - Slightly elevated (cards at rest)
  Color get surfaceLevel1 => AppTheme.getSurfaceLevel1(this);

  /// Surface Level 2 - Moderately elevated (hovered cards, app bars)
  Color get surfaceLevel2 => AppTheme.getSurfaceLevel2(this);

  /// Surface Level 3 - Elevated (dialogs, bottom sheets)
  Color get surfaceLevel3 => AppTheme.getSurfaceLevel3(this);

  /// Surface Level 4 - Highly elevated (navigation drawers)
  Color get surfaceLevel4 => AppTheme.getSurfaceLevel4(this);

  /// Surface Level 5 - Maximum elevation (modals, FABs)
  Color get surfaceLevel5 => AppTheme.getSurfaceLevel5(this);

  /// Card background 색상
  Color get cardColor => AppTheme.getCardColor(this);

  // ==========================================================================
  // Semantic Colors (Status & Feedback)
  // ==========================================================================

  /// Success 색상 (brightness-aware)
  Color get successColor => AppTheme.getSuccessColor(this);

  /// Success container 색상
  Color get successContainer => AppTheme.getSuccessContainerColor(this);

  /// Warning 색상 (brightness-aware)
  Color get warningColor => AppTheme.getWarningColor(this);

  /// Warning container 색상
  Color get warningContainer => AppTheme.getWarningContainerColor(this);

  /// Info 색상 (brightness-aware)
  Color get infoColor => AppTheme.getInfoColor(this);

  /// Info container 색상
  Color get infoContainer => AppTheme.getInfoContainerColor(this);

  /// Error 색상 (brightness-aware)
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// Error container 색상
  Color get errorContainer => Theme.of(this).colorScheme.errorContainer;

  // ==========================================================================
  // Text Colors
  // ==========================================================================

  /// Primary text 색상 (brightness-aware)
  Color get textColor => AppTheme.getTextColor(this);

  /// Secondary text 색상 (brightness-aware)
  Color get secondaryTextColor => AppTheme.getSecondaryTextColor(this);

  /// Surface 위의 텍스트 색상
  Color get onSurface => Theme.of(this).colorScheme.onSurface;

  /// Surface variant 위의 텍스트 색상
  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;

  // ==========================================================================
  // Outline & Divider Colors
  // ==========================================================================

  /// Outline 색상 (테두리)
  Color get outlineColor => Theme.of(this).colorScheme.outline;

  /// Outline variant 색상 (부드러운 구분선)
  Color get outlineVariant => Theme.of(this).colorScheme.outlineVariant;
}
