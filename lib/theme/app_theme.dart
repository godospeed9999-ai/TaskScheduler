// THEME LOCK: dark — source: domain signal (AI/developer tool, night usage)
// Scaffold.backgroundColor = AppTheme.backgroundDark — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary palette
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9D5FF0);
  static const Color primaryContainer = Color(0xFF3D1A7A);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryContainer = Color(0xFF0E4A57);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Dark surfaces
  static const Color backgroundDark = Color(0xFF0D0D1A);
  static const Color surfaceDark = Color(0xFF13132B);
  static const Color surfaceVariantDark = Color(0xFF1C1C3A);
  static const Color cardDark = Color(0xFF1A1A35);
  static const Color glassSurface = Color(0x0FFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFF1F1F5);
  static const Color textSecondary = Color(0xFF9A9AB0);
  static const Color textMuted = Color(0xFF5A5A7A);

  // Category colors
  static const Color categoryStudy = Color(0xFF7C3AED);
  static const Color categoryWork = Color(0xFF06B6D4);
  static const Color categoryHealth = Color(0xFF10B981);
  static const Color categoryPersonal = Color(0xFFF59E0B);
  static const Color categoryOther = Color(0xFF6B7280);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEDE9FE),
      secondary: secondary,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF1A1A1A),
      error: error,
      onError: Colors.white,
      outline: const Color(0xFFCCCCCC),
      outlineVariant: const Color(0xFFEEEEEE),
    ),
    textTheme: GoogleFonts.soraTextTheme(ThemeData.light().textTheme),
    scaffoldBackgroundColor: const Color(0xFFF5F5FA),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: const Color(0xFFEDE9FE),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: const Color(0xFFCCF2FA),
      surface: surfaceDark,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceVariantDark,
      error: error,
      onError: Colors.white,
      outline: const Color(0xFF3A3A5C),
      outlineVariant: const Color(0xFF252545),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.soraTextTheme(
      ThemeData.dark().textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.sora(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: textPrimary),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: glassSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: glassBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: glassBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      labelStyle: GoogleFonts.sora(color: textSecondary, fontSize: 14),
      hintStyle: GoogleFonts.sora(color: textMuted, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: glassBorder, width: 1),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: glassSurface,
      selectedColor: primaryContainer,
      labelStyle: GoogleFonts.sora(fontSize: 13, color: textPrimary),
      side: const BorderSide(color: glassBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 8,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return surfaceVariantDark;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF252545),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceVariantDark,
      contentTextStyle: GoogleFonts.sora(color: textPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}