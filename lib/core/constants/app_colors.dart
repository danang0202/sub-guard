import 'package:flutter/material.dart';

/// Named color constants for the SUB-GUARD app.
///
/// This class provides centralized color definitions to replace
/// hardcoded hex values throughout the application.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors - Vibrant Blue & Cyan
  static const Color primary = Color(0xFF2E86DE); // Vibrant Blue
  static const Color secondary = Color(0xFF48DBFB); // Cyan

  // Gradients
  static const Color primaryGradientStart = Color(0xFF005BEA);
  static const Color primaryGradientEnd = Color(0xFF00C6FB);

  // Surface and background colors - Sophisticated Dark
  static const Color background = Color(0xFF09090B); // Almost Black
  static const Color surface = Color(0xFF18181B); // Zinc 900
  static const Color surfaceHighlight = Color(0xFF27272A); // Zinc 800

  // Semantic colors
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD93D); // Modern Yellow

  // Neutral colors
  static const Color unselected = Color(0xFF71717A); // Zinc 500
  static const Color divider = Color(0xFF27272A);

  // Text colors
  static const Color textPrimary = Color(0xFFFAFAFA); // Off-white
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400

  /// Returns all color constants as a map for validation purposes.
  static Map<String, Color> get allColors => {
    'primary': primary,
    'secondary': secondary,
    'surface': surface,
    'background': background,
    'error': error,
    'success': success,
    'warning': warning,
    'unselected': unselected,
    'divider': divider,
    'textPrimary': textPrimary,
    'textSecondary': textSecondary,
  };

  /// List of required color names that must be defined.
  static const List<String> requiredColors = [
    'primary',
    'secondary',
    'surface',
    'background',
    'error',
    'success',
  ];
}
