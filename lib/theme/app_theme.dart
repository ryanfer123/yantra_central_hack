import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggle() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AppTheme {
  // Core Colors — shared across themes
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningAmber = Color(0xFFFF9500);
  static const Color dangerRed = Color(0xFFFF3B30);
  static const Color regenGreen = Color(0xFF30D158);

  // Light theme colors
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardSecondary = Color(0xFF2C2C2E);
  static const Color textPrimary = Color(0xFF0D0D0D);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color divider = Color(0xFFE5E5EA);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF98989D);
  static const Color textTertiaryDark = Color(0xFF636366);
  static const Color dividerDark = Color(0xFF38383A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        surface: surfaceWhite,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSurface: textPrimaryDark,
      ),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimaryDark,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final primary = brightness == Brightness.light ? textPrimary : textPrimaryDark;
    final secondary = brightness == Brightness.light ? textSecondary : textSecondaryDark;
    final tertiary = brightness == Brightness.light ? textTertiary : textTertiaryDark;

    return GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge: GoogleFonts.dmSans(
        fontSize: 56, fontWeight: FontWeight.w700, color: primary,
        letterSpacing: -2,
      ),
      displayMedium: GoogleFonts.dmSans(
        fontSize: 40, fontWeight: FontWeight.w700, color: primary,
        letterSpacing: -1.5,
      ),
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 28, fontWeight: FontWeight.w700, color: primary,
        letterSpacing: -0.8,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 22, fontWeight: FontWeight.w600, color: primary,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: primary,
        letterSpacing: -0.3,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 15, fontWeight: FontWeight.w500, color: primary,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 15, fontWeight: FontWeight.w400, color: primary,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w400, color: secondary,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11, fontWeight: FontWeight.w500, color: tertiary,
        letterSpacing: 0.4,
      ),
    );
  }

  // Helper to get theme-aware colors from context
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color scaffoldBg(BuildContext context) =>
      isDarkMode(context) ? backgroundDark : backgroundLight;

  static Color surface(BuildContext context) =>
      isDarkMode(context) ? surfaceDark : surfaceWhite;

  static Color cardColor(BuildContext context) =>
      isDarkMode(context) ? cardDark : surfaceWhite;

  static Color textPrimaryC(BuildContext context) =>
      isDarkMode(context) ? textPrimaryDark : textPrimary;

  static Color textSecondaryC(BuildContext context) =>
      isDarkMode(context) ? textSecondaryDark : textSecondary;

  static Color textTertiaryC(BuildContext context) =>
      isDarkMode(context) ? textTertiaryDark : textTertiary;

  static Color dividerC(BuildContext context) =>
      isDarkMode(context) ? dividerDark : divider;

  static Color navBarBg(BuildContext context) =>
      isDarkMode(context) ? surfaceDark : surfaceWhite;
}
