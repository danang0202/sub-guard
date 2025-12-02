/// Base exception for app-specific errors.
///
/// All domain-specific exceptions should extend this class to provide
/// consistent error handling throughout the application.
abstract class AppException implements Exception {
  /// Technical error message for debugging purposes.
  String get message;

  /// User-friendly message suitable for display in UI.
  String get userFriendlyMessage;

  @override
  String toString() => 'AppException: $message';
}

/// Exception for service layer errors.
///
/// Use this for errors that occur in business logic or external service calls.
class ServiceException extends AppException {
  @override
  final String message;

  @override
  final String userFriendlyMessage;

  /// Optional original error that caused this exception.
  final Object? originalError;

  ServiceException({
    required this.message,
    String? userFriendlyMessage,
    this.originalError,
  }) : userFriendlyMessage =
           userFriendlyMessage ??
           'Terjadi kesalahan pada layanan. Silakan coba lagi.';

  @override
  String toString() => 'ServiceException: $message';
}

/// Exception for repository/data layer errors.
///
/// Use this for errors related to data persistence, retrieval, or storage.
class RepositoryException extends AppException {
  @override
  final String message;

  @override
  final String userFriendlyMessage;

  /// Optional original error that caused this exception.
  final Object? originalError;

  RepositoryException({
    required this.message,
    String? userFriendlyMessage,
    this.originalError,
  }) : userFriendlyMessage =
           userFriendlyMessage ?? 'Gagal mengakses data. Silakan coba lagi.';

  @override
  String toString() => 'RepositoryException: $message';
}

/// Exception for validation errors.
///
/// Use this for errors related to input validation or business rule violations.
class ValidationException extends AppException {
  @override
  final String message;

  @override
  final String userFriendlyMessage;

  /// Optional field name that failed validation.
  final String? fieldName;

  ValidationException({
    required this.message,
    String? userFriendlyMessage,
    this.fieldName,
  }) : userFriendlyMessage =
           userFriendlyMessage ?? 'Data tidak valid. Silakan periksa kembali.';

  @override
  String toString() =>
      'ValidationException: $message${fieldName != null ? ' (field: $fieldName)' : ''}';
}

/// Exception for network-related errors.
///
/// Use this for errors related to network connectivity or API calls.
class NetworkException extends AppException {
  @override
  final String message;

  @override
  final String userFriendlyMessage;

  /// HTTP status code if applicable.
  final int? statusCode;

  NetworkException({
    required this.message,
    String? userFriendlyMessage,
    this.statusCode,
  }) : userFriendlyMessage =
           userFriendlyMessage ?? 'Koneksi bermasalah. Periksa jaringan Anda.';

  @override
  String toString() =>
      'NetworkException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Exception for permission-related errors.
///
/// Use this for errors related to missing or denied permissions.
class PermissionException extends AppException {
  @override
  final String message;

  @override
  final String userFriendlyMessage;

  /// Name of the permission that was denied.
  final String? permissionName;

  PermissionException({
    required this.message,
    String? userFriendlyMessage,
    this.permissionName,
  }) : userFriendlyMessage =
           userFriendlyMessage ?? 'Izin diperlukan untuk fitur ini.';

  @override
  String toString() =>
      'PermissionException: $message${permissionName != null ? ' (permission: $permissionName)' : ''}';
}
