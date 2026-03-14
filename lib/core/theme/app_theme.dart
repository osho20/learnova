import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colors ──────────────────────────────
  static const primary = Color(0xFF1A237E);
  static const primaryLight = Color(0xFF3949AB);
  static const accent = Color(0xFFFFC107);
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFB8C00);
  static const error = Color(0xFFE53935);

  static const bgLight = Color(0xFFF4F6FF);
  static const bgDark = Color(0xFF0D0D1A);
  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF1A1A2E);
  static const cardDark2 = Color(0xFF16213E);

  // ── Text Styles ──────────────────────────
  static TextTheme _textTheme(Color color) => TextTheme(
        displayLarge: GoogleFonts.poppins(
            fontSize: 28, fontWeight: FontWeight.w700, color: color),
        displayMedium: GoogleFonts.poppins(
            fontSize: 24, fontWeight: FontWeight.w700, color: color),
        headlineLarge: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w600, color: color),
        headlineMedium: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: color),
        titleLarge: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w600, color: color),
        titleMedium: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w500, color: color),
        bodyLarge: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w400, color: color),
        bodyMedium: GoogleFonts.poppins(
            fontSize: 13, fontWeight: FontWeight.w400, color: color),
        labelLarge: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w600, color: color),
        labelMedium: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500, color: color),
      );

  // ── Light Theme ──────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: accent,
          surface: bgLight,
          error: error,
        ),
        scaffoldBackgroundColor: bgLight,
        textTheme: _textTheme(const Color(0xFF1A1A2E)),
        appBarTheme: AppBarTheme(
          backgroundColor: bgLight,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: primary,
          ),
          iconTheme: const IconThemeData(color: primary),
        ),
        cardTheme: CardThemeData(
          color: cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardLight,
          selectedItemColor: primary,
          unselectedItemColor: Color(0xFF9E9E9E),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      );

  // ── Dark Theme ───────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: const Color(0xFF7986CB),
          secondary: accent,
          surface: bgDark,
          error: error,
        ),
        scaffoldBackgroundColor: bgDark,
        textTheme: _textTheme(Colors.white),
        appBarTheme: AppBarTheme(
          backgroundColor: bgDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7986CB),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF7986CB), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: cardDark,
          selectedItemColor: Color(0xFF7986CB),
          unselectedItemColor: Color(0xFF616161),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      );
}