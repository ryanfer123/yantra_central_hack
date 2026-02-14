// lib/theme/admin_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  // ── Command Center Palette ────────────────────────────────────────────────
  static const Color bg = Color(0xFF0A0E1A);
  static const Color bgCard = Color(0xFF111827);
  static const Color bgCardSecondary = Color(0xFF1A2235);
  static const Color border = Color(0xFF1F2D45);

  static const Color red = Color(0xFFEF4444);
  static const Color redDim = Color(0xFF7F1D1D);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDim = Color(0xFF78350F);
  static const Color green = Color(0xFF10B981);
  static const Color greenDim = Color(0xFF064E3B);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueDim = Color(0xFF1E3A5F);
  static const Color cyan = Color(0xFF06B6D4);

  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: blue,
        background: bg,
        surface: bgCard,
        onPrimary: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
    );
  }
}