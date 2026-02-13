import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Colors
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardSecondary = Color(0xFF2C2C2E);
  static const Color textPrimary = Color(0xFF0D0D0D);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color textTertiary = Color(0xFFAEAEB2);
  static const Color successGreen = Color(0xFF34C759);
  static const Color warningAmber = Color(0xFFFF9500);
  static const Color dangerRed = Color(0xFFFF3B30);
  static const Color regenGreen = Color(0xFF30D158);
  static const Color divider = Color(0xFFE5E5EA);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        background: backgroundLight,
        surface: surfaceWhite,
        onPrimary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 56, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -2,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 40, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -1.5,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.8,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11, fontWeight: FontWeight.w500, color: textTertiary,
          letterSpacing: 0.4,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardTheme(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}