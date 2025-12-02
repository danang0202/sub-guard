import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../exceptions/app_exceptions.dart';

/// Centralized error handling utility.
///
/// Provides consistent error handling throughout the application,
/// including user feedback via SnackBar and error logging.
class ErrorHandler {
  // Private constructor to prevent instantiation
  ErrorHandler._();

  /// Show error to user via SnackBar.
  ///
  /// Displays a user-friendly error message in a SnackBar.
  /// For [AppException] instances, uses the [userFriendlyMessage].
  /// For other errors, displays a generic error message.
  static void showError(BuildContext context, Object error) {
    final message = _getUserFriendlyMessage(error);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Log error for debugging purposes.
  ///
  /// Logs the error message and optional stack trace to the debug console.
  /// In release mode, this could be extended to send errors to a crash
  /// reporting service.
  static void logError(Object error, [StackTrace? stackTrace]) {
    final message = error is AppException ? error.message : error.toString();

    debugPrint('ERROR: $message');
    if (stackTrace != null) {
      debugPrint('STACK TRACE: $stackTrace');
    }

    // In production, you might want to send this to a crash reporting service
    // like Firebase Crashlytics, Sentry, etc.
  }

  /// Handle error with both logging and user feedback.
  ///
  /// This is the primary method to use for error handling.
  /// It logs the error for debugging and shows a user-friendly message.
  static void handle(
    BuildContext context,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    logError(error, stackTrace);
    showError(context, error);
  }

  /// Get user-friendly message from an error.
  ///
  /// Returns the [userFriendlyMessage] for [AppException] instances,
  /// or a generic message for other error types.
  static String _getUserFriendlyMessage(Object error) {
    if (error is AppException) {
      return error.userFriendlyMessage;
    }

    // Generic fallback message for unknown errors
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  /// Get user-friendly message from an error (public version for testing).
  ///
  /// Returns the [userFriendlyMessage] for [AppException] instances,
  /// or a generic message for other error types.
  static String getUserFriendlyMessage(Object error) {
    return _getUserFriendlyMessage(error);
  }

  /// Show success message to user via SnackBar.
  ///
  /// Displays a success message in a green SnackBar.
  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning message to user via SnackBar.
  ///
  /// Displays a warning message in an orange SnackBar.
  static void showWarning(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
