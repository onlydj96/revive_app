import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================================
  // Brand Colors - Material Design 3 Role-based System
  // ============================================================================

  // LIGHT THEME COLORS
  // Primary: Main brand color for logo, key actions, prominent buttons
  static const Color primaryBrand =
      Color(0xFF656176); // Purple Gray - Main brand identity

  // Primary Container: Emphasized buttons, AppBar, Chip backgrounds
  static const Color primaryContainerBrand =
      Color(0xFFDECDF5); // Soft Purple - Emphasized surfaces

  // Secondary: Accent color for CTAs, links, highlighted text
  static const Color secondaryBrand =
      Color(0xFF1B998B); // Teal - Call-to-action color

  // Secondary Container: Darker accent surfaces, Tag backgrounds
  static const Color secondaryContainerBrand =
      Color(0xFF534D56); // Dark Gray - Accent surfaces

  // Background/Surface: App-wide background and card base color
  static const Color backgroundBrand =
      Color(0xFFF8F1FF); // Very Light Purple - Base background

  // DARK THEME COLORS
  // Dark theme specific colors for better contrast and readability
  static const Color darkBackground =
      Color(0xFF1A1625); // Deep Purple Black - Main background
  static const Color darkSurface =
      Color(0xFF2D2634); // Dark Purple - Card/Surface background
  static const Color darkSurfaceVariant =
      Color(0xFF3D3545); // Lighter surface for elevation

  static const Color darkPrimary =
      Color(0xFFBEACDC); // Light Purple - Accessible primary
  static const Color darkPrimaryContainer =
      Color(0xFF4F4560); // Medium Purple - Container background

  static const Color darkSecondary =
      Color(0xFF5FDBC9); // Bright Teal - High visibility accent
  static const Color darkSecondaryContainer =
      Color(0xFF2A4A44); // Dark Teal - Container background

  // Border and divider colors
  static const Color darkOutline = Color(0xFF4F4A58); // Border color
  static const Color darkOutlineVariant = Color(0xFF3A3641); // Subtle divider

  // ============================================================================
  // Light Theme Configuration
  // ============================================================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Explicit primary colors for backward compatibility with Theme.of(context).primaryColor
    primaryColor: primaryBrand,
    primaryColorLight: primaryContainerBrand,
    primaryColorDark: secondaryContainerBrand,

    // Color Scheme - Material 3 semantic colors
    colorScheme: ColorScheme.light(
      // Primary colors - main brand identity
      primary: primaryBrand,
      onPrimary: Colors.white,
      primaryContainer: primaryContainerBrand,
      onPrimaryContainer: primaryBrand,

      // Secondary colors - accent and CTA
      secondary: secondaryBrand,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainerBrand,
      onSecondaryContainer: Colors.white,

      // Surface colors - backgrounds and cards
      surface: backgroundBrand,
      onSurface: const Color(0xFF1C1B1F),
      surfaceContainerHighest: Colors.white,

      // Error colors
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,

      // Outline colors
      outline: const Color(0xFF79747E),
      outlineVariant: const Color(0xFFCAC4D0),
    ),

    // Scaffold background
    scaffoldBackgroundColor: backgroundBrand,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Colors.transparent,
      foregroundColor: primaryBrand,
      titleTextStyle: TextStyle(
        color: primaryBrand,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: primaryBrand),
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      surfaceTintColor: backgroundBrand,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryBrand,
      unselectedItemColor: Color(0xFF79747E),
      backgroundColor: backgroundBrand,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCAC4D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCAC4D0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryBrand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: Color(0xFF79747E)),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBrand,
        foregroundColor: Colors.white,
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
      backgroundColor: primaryBrand,
      foregroundColor: Colors.white,
      elevation: 6,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: primaryContainerBrand,
      labelStyle: const TextStyle(color: primaryBrand),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFFCAC4D0),
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

    // Color Scheme - Material 3 semantic colors for dark mode
    colorScheme: ColorScheme.dark(
      // Primary colors - lighter for dark backgrounds
      primary: darkPrimary,
      onPrimary: const Color(0xFF382E40),
      primaryContainer: darkPrimaryContainer,
      onPrimaryContainer: darkPrimary,

      // Secondary colors - bright accent for visibility
      secondary: darkSecondary,
      onSecondary: const Color(0xFF003731),
      secondaryContainer: darkSecondaryContainer,
      onSecondaryContainer: darkSecondary,

      // Surface colors - layered dark surfaces
      surface: darkSurface,
      onSurface: const Color(0xFFE6E1E5),
      surfaceContainerHighest: darkSurfaceVariant,

      // Error colors
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),

      // Outline colors
      outline: darkOutline,
      outlineVariant: darkOutlineVariant,

      // Surface variants for elevation
      onSurfaceVariant: const Color(0xFFCAC4D0),
    ),

    // Scaffold background
    scaffoldBackgroundColor: darkBackground,

    // AppBar Theme
    appBarTheme: AppBarTheme(
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
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkSecondary,
      unselectedItemColor: const Color(0xFF938F99),
      backgroundColor: darkSurface,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      elevation: 8,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: Color(0xFF938F99)),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkSecondary,
        foregroundColor: const Color(0xFF003731),
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
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkSecondary,
      foregroundColor: const Color(0xFF003731),
      elevation: 6,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: darkPrimaryContainer,
      labelStyle: TextStyle(color: darkPrimary),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
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
        ? const Color(0xFFE6E1E5)
        : const Color(0xFF1C1B1F);
  }

  /// Get appropriate secondary text color
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFCAC4D0)
        : const Color(0xFF79747E);
  }

  /// Get appropriate surface color
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : Colors.white;
  }

  /// Get appropriate card color
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : Colors.white;
  }
}
