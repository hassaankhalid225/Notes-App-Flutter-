import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-modern color palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color accentColor = Color(0xFF8B5CF6); // Violet
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1E293B);
  static const Color subtitleColor = Color(0xFF64748B);
  static const Color dangerColor = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: cardColor,
        error: dangerColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.2,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor.withValues(alpha: 0.8),
          height: 1.5,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: subtitleColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textColor,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.outfit(color: subtitleColor.withValues(alpha: 0.5)),
      ),
    );
  }

  static ThemeData get darkTheme {
    const Color darkBg = Color(0xFF0F172A);
    const Color darkCard = Color(0xFF1E293B);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: darkCard,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.5,
        ),
        bodySmall: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white54,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
        ),
      ),
    );
  }
}
