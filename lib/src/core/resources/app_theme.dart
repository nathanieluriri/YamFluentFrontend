import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _darkText = Colors.black;
  static const _mutedText = Color(0xFF646464);
  static const _subtleText = Color(0xFF464646);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.redditSansTextTheme();
    final textTheme = baseTextTheme.apply(
      bodyColor: _mutedText,
      displayColor: _darkText,
    ).copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: _darkText,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: _darkText,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: _darkText,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: _mutedText,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.32,
        fontSize: 16,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: _subtleText,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.32,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: _darkText,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: _subtleText,
      ),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4), 
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.redditSansTextTheme(
      ThemeData.dark().textTheme,
    );
    final textTheme = baseTextTheme.apply(
      bodyColor: _mutedText,
      displayColor: _darkText,
    ).copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: _darkText,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: _darkText,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: _darkText,
        fontWeight: FontWeight.w600,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: _subtleText,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.32,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: _mutedText,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.32,
        fontSize: 16,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: _darkText,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: _subtleText,
      ),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD0BCFF), 
        brightness: Brightness.dark,
      ),
      textTheme: textTheme,
    );
  }
}
