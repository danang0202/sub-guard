import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide group, test, expect;
import 'package:sub_guard_android/core/constants/app_colors.dart';

/// **Feature: code-refactoring, Property 2: Color Constants Completeness**
///
/// *For any* color referenced in AppTheme, the color SHALL be defined
/// as a named constant in AppColors class.
/// **Validates: Requirements 3.2**
void main() {
  group('AppColors Property Tests', () {
    // **Feature: code-refactoring, Property 2: Color Constants Completeness**
    // **Validates: Requirements 3.2**
    Glados(any.choose(AppColors.requiredColors)).test(
      'Property 2: All required colors are defined in AppColors',
      (colorName) {
        final allColors = AppColors.allColors;

        // Property: For any required color name, it must exist in allColors
        expect(
          allColors.containsKey(colorName),
          isTrue,
          reason: 'Required color "$colorName" must be defined in AppColors',
        );

        // Property: The color value must be a valid Color (non-null)
        final color = allColors[colorName];
        expect(
          color,
          isNotNull,
          reason: 'Color "$colorName" must have a non-null value',
        );

        // Property: The color must be a valid Color instance
        expect(
          color,
          isA<Color>(),
          reason: 'Color "$colorName" must be a Color instance',
        );
      },
    );

    // Additional property test: All colors have valid alpha values
    Glados(any.choose(AppColors.allColors.keys.toList())).test(
      'Property 2b: All colors have valid alpha values (fully opaque)',
      (colorName) {
        final color = AppColors.allColors[colorName]!;

        // Property: All defined colors should be fully opaque (alpha = 1.0)
        expect(
          color.a,
          equals(1.0),
          reason: 'Color "$colorName" should be fully opaque',
        );
      },
    );
  });

  group('AppColors Unit Tests', () {
    test('AppColors contains all required colors', () {
      final allColors = AppColors.allColors;

      for (final requiredColor in AppColors.requiredColors) {
        expect(
          allColors.containsKey(requiredColor),
          isTrue,
          reason: 'Missing required color: $requiredColor',
        );
      }
    });

    test('AppColors primary matches expected hex value', () {
      expect(AppColors.primary, equals(const Color(0xFFBB86FC)));
    });

    test('AppColors secondary matches expected hex value', () {
      expect(AppColors.secondary, equals(const Color(0xFF03DAC6)));
    });

    test('AppColors surface matches expected hex value', () {
      expect(AppColors.surface, equals(const Color(0xFF1E1E1E)));
    });

    test('AppColors background matches expected hex value', () {
      expect(AppColors.background, equals(const Color(0xFF121212)));
    });

    test('AppColors error matches expected hex value', () {
      expect(AppColors.error, equals(const Color(0xFFFF5252)));
    });

    test('AppColors success matches expected hex value', () {
      expect(AppColors.success, equals(const Color(0xFF4CAF50)));
    });
  });
}
