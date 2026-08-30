import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant Neon & Glassmorphism Palette
  static const Color primaryRed = Color(0xFFFF2A55); // Neon Emergency Red
  static const Color accentOrange = Color(0xFFFF9100); // Neon Amber
  static const Color successGreen = Color(0xFF00E676); // Vibrant Emerald Green
  static const Color purpleAccent = Color(0xFFA855F7); // DTN Neon Purple
  static const Color darkBackground = Color(0xFF0B0E14); // Deep Midnight Space Dark
  static const Color cardDark = Color(0xFF161B26); // Glassmorphism Elevated Card Surface
  static const Color textPrimary = Color(0xFFF8FAFC); // Pure Crisp Text
  static const Color textSecondary = Color(0xFF94A3B8); // Muted Subtitle Gray
  static const Color inputBorder = Color(0xFF262D3D); // Border Accent

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        secondary: accentOrange,
        surface: cardDark,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        titleLarge: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 22),
        bodyLarge: const TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryRed, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: primaryRed.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}
