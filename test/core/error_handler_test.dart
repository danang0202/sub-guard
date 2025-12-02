import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide group, test, expect;
import 'package:sub_guard_android/core/exceptions/app_exceptions.dart';
import 'package:sub_guard_android/core/utils/error_handler.dart';

/// **Feature: code-refactoring, Property 4: Error Handler Message Mapping**
///
/// *For any* AppException passed to ErrorHandler.handle(), the handler
/// SHALL produce a SnackBar with non-empty content text.
/// **Validates: Requirements 5.1, 5.2**
void main() {
  group('ErrorHandler Property Tests', () {
    // **Feature: code-refactoring, Property 4: Error Handler Message Mapping**
    // **Validates: Requirements 5.1, 5.2**

    // Test ServiceException message mapping
    Glados(
      any.nonEmptyLetters,
    ).test('Property 4a: ServiceException maps to non-empty user message', (
      message,
    ) {
      final exception = ServiceException(message: message);
      final userMessage = ErrorHandler.getUserFriendlyMessage(exception);

      // Property: getUserFriendlyMessage must return non-empty string
      expect(
        userMessage.isNotEmpty,
        isTrue,
        reason:
            'ErrorHandler must produce non-empty message for ServiceException',
      );

      // Property: message must be a String
      expect(
        userMessage,
        isA<String>(),
        reason: 'ErrorHandler must produce a String message',
      );
    });

    // Test RepositoryException message mapping
    Glados(
      any.nonEmptyLetters,
    ).test('Property 4b: RepositoryException maps to non-empty user message', (
      message,
    ) {
      final exception = RepositoryException(message: message);
      final userMessage = ErrorHandler.getUserFriendlyMessage(exception);

      // Property: getUserFriendlyMessage must return non-empty string
      expect(
        userMessage.isNotEmpty,
        isTrue,
        reason:
            'ErrorHandler must produce non-empty message for RepositoryException',
      );
    });

    // Test ValidationException message mapping
    Glados(
      any.nonEmptyLetters,
    ).test('Property 4c: ValidationException maps to non-empty user message', (
      message,
    ) {
      final exception = ValidationException(message: message);
      final userMessage = ErrorHandler.getUserFriendlyMessage(exception);

      // Property: getUserFriendlyMessage must return non-empty string
      expect(
        userMessage.isNotEmpty,
        isTrue,
        reason:
            'ErrorHandler must produce non-empty message for ValidationException',
      );
    });

    // Test NetworkException message mapping
    Glados(
      any.nonEmptyLetters,
    ).test('Property 4d: NetworkException maps to non-empty user message', (
      message,
    ) {
      final exception = NetworkException(message: message);
      final userMessage = ErrorHandler.getUserFriendlyMessage(exception);

      // Property: getUserFriendlyMessage must return non-empty string
      expect(
        userMessage.isNotEmpty,
        isTrue,
        reason:
            'ErrorHandler must produce non-empty message for NetworkException',
      );
    });

    // Test PermissionException message mapping
    Glados(
      any.nonEmptyLetters,
    ).test('Property 4e: PermissionException maps to non-empty user message', (
      message,
    ) {
      final exception = PermissionException(message: message);
      final userMessage = ErrorHandler.getUserFriendlyMessage(exception);

      // Property: getUserFriendlyMessage must return non-empty string
      expect(
        userMessage.isNotEmpty,
        isTrue,
        reason:
            'ErrorHandler must produce non-empty message for PermissionException',
      );
    });

    // Test custom userFriendlyMessage is preserved through ErrorHandler
    Glados2(any.nonEmptyLetters, any.nonEmptyLetters).test(
      'Property 4f: Custom userFriendlyMessage is preserved through ErrorHandler',
      (message, customUserMessage) {
        final exception = ServiceException(
          message: message,
          userFriendlyMessage: customUserMessage,
        );
        final userMessage = ErrorHandler.getUserFriendlyMessage(exception);

        // Property: custom userFriendlyMessage should be preserved
        expect(
          userMessage,
          equals(customUserMessage),
          reason:
              'Custom userFriendlyMessage should be preserved through ErrorHandler',
        );
      },
    );

    // Test non-AppException errors get generic message
    Glados(any.nonEmptyLetters).test(
      'Property 4g: Non-AppException errors get non-empty generic message',
      (message) {
        final error = Exception(message);
        final userMessage = ErrorHandler.getUserFriendlyMessage(error);

        // Property: getUserFriendlyMessage must return non-empty string for any error
        expect(
          userMessage.isNotEmpty,
          isTrue,
          reason:
              'ErrorHandler must produce non-empty message for any error type',
        );
      },
    );
  });

  group('ErrorHandler Unit Tests', () {
    test(
      'getUserFriendlyMessage returns exception userFriendlyMessage for AppException',
      () {
        final exception = ServiceException(
          message: 'Technical error',
          userFriendlyMessage: 'User friendly message',
        );

        expect(
          ErrorHandler.getUserFriendlyMessage(exception),
          equals('User friendly message'),
        );
      },
    );

    test(
      'getUserFriendlyMessage returns generic message for non-AppException',
      () {
        final error = Exception('Some error');
        final message = ErrorHandler.getUserFriendlyMessage(error);

        expect(message.isNotEmpty, isTrue);
        expect(message, equals('Terjadi kesalahan. Silakan coba lagi.'));
      },
    );

    test('getUserFriendlyMessage returns generic message for String error', () {
      const error = 'String error';
      final message = ErrorHandler.getUserFriendlyMessage(error);

      expect(message.isNotEmpty, isTrue);
      expect(message, equals('Terjadi kesalahan. Silakan coba lagi.'));
    });

    test('getUserFriendlyMessage handles null-like scenarios gracefully', () {
      // Test with various error types
      final errors = [Exception('test'), Error(), 'string error', 123, true];

      for (final error in errors) {
        final message = ErrorHandler.getUserFriendlyMessage(error);
        expect(message.isNotEmpty, isTrue);
      }
    });
  });
}
