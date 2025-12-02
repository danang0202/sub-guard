# Design Document: Code Refactoring

## Overview

Refactoring ini bertujuan untuk meningkatkan modularitas dan maintainability codebase SUB-GUARD. Fokus utama adalah memecah file-file besar menjadi komponen yang lebih kecil dengan single responsibility, centralized theme management, dan consistent error handling.

## Architecture

### Current State
```
lib/
├── main.dart (350+ lines, multiple responsibilities)
├── models/
├── providers/
├── repositories/
├── screens/
├── services/
└── widgets/
    └── settings/ (already refactored)
```

### Target State
```
lib/
├── main.dart (~50 lines, bootstrapping only)
├── app/
│   ├── app.dart (MyApp widget)
│   ├── app_initializer.dart (initialization logic)
│   └── app_theme.dart (theme configuration)
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   ├── exceptions/
│   │   └── app_exceptions.dart
│   └── utils/
│       └── error_handler.dart
├── models/
├── providers/
├── repositories/
├── screens/
│   └── main_navigation_screen.dart (extracted)
├── services/
└── widgets/
    ├── dialogs/
    │   ├── battery_optimization_dialog.dart
    │   └── dialogs.dart (barrel)
    └── settings/
```

## Components and Interfaces

### 1. AppInitializer

```dart
/// Handles all app initialization tasks
class AppInitializer {
  /// Initialize all required services and dependencies
  static Future<void> initialize() async;
  
  /// Initialize Hive database and register adapters
  static Future<void> _initializeHive() async;
  
  /// Initialize notification system
  static Future<void> _initializeNotifications() async;
  
  /// Initialize alarm manager
  static Future<void> _initializeAlarmManager() async;
}
```

### 2. AppTheme

```dart
/// Centralized theme configuration
class AppTheme {
  /// Dark theme configuration
  static ThemeData get darkTheme;
  
  /// Light theme configuration  
  static ThemeData get lightTheme;
  
  /// Get theme based on mode
  static ThemeData getTheme(AppThemeMode mode);
}
```

### 3. AppColors

```dart
/// Named color constants
class AppColors {
  static const Color primary = Color(0xFFBB86FC);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color background = Color(0xFF121212);
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);
  // ... more colors
}
```

### 4. AppExceptions

```dart
/// Base exception for app-specific errors
abstract class AppException implements Exception {
  String get message;
  String get userFriendlyMessage;
}

/// Service-specific exceptions
class ServiceException extends AppException { ... }
class RepositoryException extends AppException { ... }
class ValidationException extends AppException { ... }
```

### 5. ErrorHandler

```dart
/// Centralized error handling utility
class ErrorHandler {
  /// Show error to user via SnackBar
  static void showError(BuildContext context, AppException error);
  
  /// Log error for debugging
  static void logError(Object error, [StackTrace? stackTrace]);
  
  /// Handle error with both logging and user feedback
  static void handle(BuildContext context, Object error);
}
```

## Data Models

Tidak ada perubahan pada data models. Struktur existing sudah baik:
- `Subscription` - model untuk subscription data
- `NotificationConfig` - konfigurasi notifikasi
- `UserSettings` - pengaturan user

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Theme Validity
*For any* AppThemeMode value, the AppTheme.getTheme() method SHALL return a valid ThemeData with non-null colorScheme containing primary, secondary, surface, and error colors.
**Validates: Requirements 1.2, 3.1**

### Property 2: Color Constants Completeness
*For any* color referenced in AppTheme, the color SHALL be defined as a named constant in AppColors class.
**Validates: Requirements 3.2**

### Property 3: Exception User Message
*For any* AppException subclass instance, the userFriendlyMessage property SHALL return a non-empty string.
**Validates: Requirements 5.2**

### Property 4: Error Handler Message Mapping
*For any* AppException passed to ErrorHandler.handle(), the handler SHALL produce a SnackBar with non-empty content text.
**Validates: Requirements 5.1, 5.2**

## Error Handling

### Strategy

1. **Service Layer**: Throw domain-specific exceptions
```dart
try {
  await someOperation();
} catch (e) {
  throw ServiceException(
    message: 'Operation failed: $e',
    userFriendlyMessage: 'Gagal melakukan operasi. Silakan coba lagi.',
  );
}
```

2. **UI Layer**: Catch and display using ErrorHandler
```dart
try {
  await service.doSomething();
} catch (e) {
  ErrorHandler.handle(context, e);
}
```

3. **Logging**: All errors logged with context
```dart
ErrorHandler.logError(error, stackTrace);
```

## Testing Strategy

### Unit Testing
- Test AppTheme returns valid ThemeData for all modes
- Test AppColors contains all required color constants
- Test AppException subclasses provide correct messages
- Test ErrorHandler produces appropriate user messages

### Property-Based Testing
Library: `fast_check` (Dart property-based testing library)

Each property test will be annotated with:
```dart
// **Feature: code-refactoring, Property {number}: {property_text}**
```

Property tests will verify:
1. Theme generation produces valid themes for any mode
2. Error handler maps all exception types to user messages
3. Extracted widgets render with any valid input combination

### Integration Testing
- Verify app initializes correctly with all services
- Verify theme changes apply without restart
- Verify error handling flow from service to UI

## File Changes Summary

### New Files to Create
| File | Purpose |
|------|---------|
| `lib/app/app.dart` | MyApp widget |
| `lib/app/app_initializer.dart` | Initialization logic |
| `lib/app/app_theme.dart` | Theme configuration |
| `lib/core/constants/app_colors.dart` | Color constants |
| `lib/core/exceptions/app_exceptions.dart` | Exception classes |
| `lib/core/utils/error_handler.dart` | Error handling utility |
| `lib/screens/main_navigation_screen.dart` | Navigation screen |
| `lib/widgets/dialogs/battery_optimization_dialog.dart` | Dialog widget |
| `lib/widgets/dialogs/dialogs.dart` | Barrel file |

### Files to Modify
| File | Changes |
|------|---------|
| `lib/main.dart` | Simplify to bootstrapping only |
| `lib/screens/settings_screen.dart` | Use ErrorHandler, update deprecated APIs |
| `lib/services/notification_service.dart` | Implement TODO items or remove |

### Files to Delete
None - all existing functionality preserved
