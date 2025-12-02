import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide group, test, expect;
import 'package:sub_guard_android/app/app_theme.dart';
import 'package:sub_guard_android/models/user_settings.dart';

/// **Feature: code-refactoring, Property 1: Theme Validity**
///
/// *For any* AppThemeMode value, the AppTheme.getTheme() method SHALL return
/// a valid ThemeData with non-null colorScheme containing primary, secondary,
/// surface, and error colors.
/// **Validates: Requirements 1.2, 3.1**
void main() {
  group('AppTheme Property Tests', () {
    // **Feature: code-refactoring, Property 1: Theme Validity**
    // **Validates: Requirements 1.2, 3.1**
    Glados(any.choose(AppThemeMode.values)).test(
      'Property 1: Theme Validity - getTheme returns valid ThemeData for any AppThemeMode',
      (mode) {
        final theme = AppTheme.getTheme(mode);

        // Property: Theme must be non-null
        expect(
          theme,
          isNotNull,
          reason: 'Theme must not be null for mode $mode',
        );

        // Property: Theme must be a valid ThemeData instance
        expect(
          theme,
          isA<ThemeData>(),
          reason: 'Must return ThemeData for mode $mode',
        );

        // Property: ColorScheme must be non-null
        expect(
          theme.colorScheme,
          isNotNull,
          reason: 'ColorScheme must not be null for mode $mode',
        );

        // Property: Primary color must be non-null
        expect(
          theme.colorScheme.primary,
          isNotNull,
          reason: 'Primary color must not be null for mode $mode',
        );

        // Property: Secondary color must be non-null
        expect(
          theme.colorScheme.secondary,
          isNotNull,
          reason: 'Secondary color must not be null for mode $mode',
        );

        // Property: Surface color must be non-null
        expect(
          theme.colorScheme.surface,
          isNotNull,
          reason: 'Surface color must not be null for mode $mode',
        );

        // Property: Error color must be non-null
        expect(
          theme.colorScheme.error,
          isNotNull,
          reason: 'Error color must not be null for mode $mode',
        );
      },
    );

    // Additional property: ThemeMode mapping is consistent
    Glados(any.choose(AppThemeMode.values)).test(
      'Property 1b: getThemeMode returns valid ThemeMode for any AppThemeMode',
      (mode) {
        final themeMode = AppTheme.getThemeMode(mode);

        // Property: ThemeMode must be a valid enum value
        expect(
          ThemeMode.values.contains(themeMode),
          isTrue,
          reason: 'ThemeMode must be a valid enum value for mode $mode',
        );
      },
    );
  });

  group('AppTheme Unit Tests', () {
    test('darkTheme returns valid dark theme', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.colorScheme.secondary, isNotNull);
      expect(theme.colorScheme.surface, isNotNull);
      expect(theme.colorScheme.error, isNotNull);
    });

    test('lightTheme returns valid light theme', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, equals(Brightness.light));
      expect(theme.colorScheme.primary, isNotNull);
      expect(theme.colorScheme.secondary, isNotNull);
      expect(theme.colorScheme.surface, isNotNull);
      expect(theme.colorScheme.error, isNotNull);
    });

    test('getTheme returns darkTheme for AppThemeMode.dark', () {
      final theme = AppTheme.getTheme(AppThemeMode.dark);
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('getTheme returns lightTheme for AppThemeMode.light', () {
      final theme = AppTheme.getTheme(AppThemeMode.light);
      expect(theme.brightness, equals(Brightness.light));
    });

    test('getTheme returns darkTheme for AppThemeMode.system', () {
      // System mode defaults to dark theme
      final theme = AppTheme.getTheme(AppThemeMode.system);
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('getThemeMode maps correctly', () {
      expect(
        AppTheme.getThemeMode(AppThemeMode.light),
        equals(ThemeMode.light),
      );
      expect(AppTheme.getThemeMode(AppThemeMode.dark), equals(ThemeMode.dark));
      expect(
        AppTheme.getThemeMode(AppThemeMode.system),
        equals(ThemeMode.system),
      );
    });
  });
}
