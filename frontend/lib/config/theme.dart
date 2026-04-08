import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colors ──
  static const Color primaryTeal = Color(0xFF00BFA5);
  static const Color primaryCyan = Color(0xFF00ACC1);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF252525);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color accentRed = Color(0xFFEF5350);
  static const Color accentOrange = Color(0xFFFFA726);
  static const Color accentYellow = Color(0xFFFFEE58);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryTeal, primaryCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
  );

  // ── Theme ──
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundDark,
        primaryColor: primaryTeal,
        colorScheme: const ColorScheme.dark(
          primary: primaryTeal,
          secondary: primaryCyan,
          surface: surfaceDark,
          error: accentRed,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        cardTheme: CardThemeData(
          color: cardDark,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryTeal, width: 2),
          ),
          hintStyle: GoogleFonts.inter(color: textSecondary),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          headlineMedium: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary),
          bodyLarge: GoogleFonts.inter(fontSize: 16, color: textPrimary),
          bodyMedium: GoogleFonts.inter(fontSize: 14, color: textSecondary),
          bodySmall: GoogleFonts.inter(fontSize: 12, color: textSecondary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryTeal,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
