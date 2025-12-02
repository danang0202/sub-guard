import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide group, test, expect;
import 'package:sub_guard_android/core/exceptions/app_exceptions.dart';

/// **Feature: code-refactoring, Property 3: Exception User Message**
///
/// *For any* AppException subclass instance, the userFriendlyMessage property
/// SHALL return a non-empty string.
/// **Validates: Requirements 5.2**
void main() {
  group('AppExceptions Property Tests', () {
    // **Feature: code-refactoring, Property 3: Exception User Message**
    // **Validates: Requirements 5.2**

    // Test ServiceException with random messages
    Glados(any.nonEmptyLetters).test(
      'Property 3a: ServiceException always has non-empty userFriendlyMessage',
      (message) {
        final exception = ServiceException(message: message);

        // Property: userFriendlyMessage must be non-empty
        expect(
          exception.userFriendlyMessage.isNotEmpty,
          isTrue,
          reason: 'ServiceException.userFriendlyMessage must be non-empty',
        );

        // Property: userFriendlyMessage must be a String
        expect(
          exception.userFriendlyMessage,
          isA<String>(),
          reason: 'ServiceException.userFriendlyMessage must be a String',
        );
      },
    );

    // Test RepositoryException with random messages
    Glados(any.nonEmptyLetters).test(
      'Property 3b: RepositoryException always has non-empty userFriendlyMessage',
      (message) {
        final exception = RepositoryException(message: message);

        // Property: userFriendlyMessage must be non-empty
        expect(
          exception.userFriendlyMessage.isNotEmpty,
          isTrue,
          reason: 'RepositoryException.userFriendlyMessage must be non-empty',
        );
      },
    );

    // Test ValidationException with random messages
    Glados(any.nonEmptyLetters).test(
      'Property 3c: ValidationException always has non-empty userFriendlyMessage',
      (message) {
        final exception = ValidationException(message: message);

        // Property: userFriendlyMessage must be non-empty
        expect(
          exception.userFriendlyMessage.isNotEmpty,
          isTrue,
          reason: 'ValidationException.userFriendlyMessage must be non-empty',
        );
      },
    );

    // Test NetworkException with random messages
    Glados(any.nonEmptyLetters).test(
      'Property 3d: NetworkException always has non-empty userFriendlyMessage',
      (message) {
        final exception = NetworkException(message: message);

        // Property: userFriendlyMessage must be non-empty
        expect(
          exception.userFriendlyMessage.isNotEmpty,
          isTrue,
          reason: 'NetworkException.userFriendlyMessage must be non-empty',
        );
      },
    );

    // Test PermissionException with random messages
    Glados(any.nonEmptyLetters).test(
      'Property 3e: PermissionException always has non-empty userFriendlyMessage',
      (message) {
        final exception = PermissionException(message: message);

        // Property: userFriendlyMessage must be non-empty
        expect(
          exception.userFriendlyMessage.isNotEmpty,
          isTrue,
          reason: 'PermissionException.userFriendlyMessage must be non-empty',
        );
      },
    );

    // Test custom userFriendlyMessage is preserved
    Glados2(any.nonEmptyLetters, any.nonEmptyLetters).test(
      'Property 3f: Custom userFriendlyMessage is preserved when provided',
      (message, customUserMessage) {
        final exception = ServiceException(
          message: message,
          userFriendlyMessage: customUserMessage,
        );

        // Property: custom userFriendlyMessage should be preserved
        expect(
          exception.userFriendlyMessage,
          equals(customUserMessage),
          reason: 'Custom userFriendlyMessage should be preserved',
        );
      },
    );
  });

  group('AppExceptions Unit Tests', () {
    test('ServiceException has default userFriendlyMessage', () {
      final exception = ServiceException(message: 'Test error');
      expect(exception.userFriendlyMessage.isNotEmpty, isTrue);
      expect(exception.message, equals('Test error'));
    });

    test('RepositoryException has default userFriendlyMessage', () {
      final exception = RepositoryException(message: 'Database error');
      expect(exception.userFriendlyMessage.isNotEmpty, isTrue);
      expect(exception.message, equals('Database error'));
    });

    test('ValidationException has default userFriendlyMessage', () {
      final exception = ValidationException(message: 'Invalid input');
      expect(exception.userFriendlyMessage.isNotEmpty, isTrue);
      expect(exception.message, equals('Invalid input'));
    });

    test('ValidationException includes fieldName in toString', () {
      final exception = ValidationException(
        message: 'Invalid input',
        fieldName: 'email',
      );
      expect(exception.toString(), contains('email'));
    });

    test('NetworkException includes statusCode in toString', () {
      final exception = NetworkException(
        message: 'Server error',
        statusCode: 500,
      );
      expect(exception.toString(), contains('500'));
    });

    test('PermissionException includes permissionName in toString', () {
      final exception = PermissionException(
        message: 'Permission denied',
        permissionName: 'CAMERA',
      );
      expect(exception.toString(), contains('CAMERA'));
    });

    test('ServiceException preserves originalError', () {
      final originalError = Exception('Original');
      final exception = ServiceException(
        message: 'Wrapped error',
        originalError: originalError,
      );
      expect(exception.originalError, equals(originalError));
    });
  });
}
