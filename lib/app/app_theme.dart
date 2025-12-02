import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import '../models/user_settings.dart';

/// Centralized theme configuration for the SUB-GUARD app.
///
/// Provides light and dark theme definitions using AppColors constants.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Dark theme configuration
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(color: AppColors.surface, elevation: 2),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.unselected,
      type: BottomNavigationBarType.fixed,
    ),
  );

  /// Light theme configuration
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: Colors.grey.shade100,
      error: AppColors.error,
    ),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade100,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.black,
    ),
    cardTheme: CardThemeData(color: Colors.grey.shade100, elevation: 2),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.grey.shade100,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.unselected,
      type: BottomNavigationBarType.fixed,
    ),
  );

  /// Get theme based on AppThemeMode
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.system:
        // For system mode, default to dark theme
        // The actual system preference should be handled by MaterialApp's themeMode
        return darkTheme;
    }
  }

  /// Get ThemeMode for MaterialApp based on AppThemeMode
  static ThemeMode getThemeMode(AppThemeMode mode) {
    return mode.toThemeMode();
  }
}
