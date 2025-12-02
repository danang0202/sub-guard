# Requirements Document

## Introduction

Dokumen ini mendefinisikan requirements untuk refactoring codebase SUB-GUARD Android agar lebih modular, clean, dan maintainable. Refactoring ini bertujuan untuk meningkatkan code quality, mengurangi coupling antar komponen, dan memudahkan pengembangan fitur di masa depan.

## Glossary

- **SUB-GUARD**: Aplikasi tracking subscription dan reminder untuk Android
- **Widget**: Komponen UI reusable di Flutter
- **Provider**: State management menggunakan Riverpod
- **Service**: Class yang menangani business logic dan external operations
- **Repository**: Layer abstraksi untuk data access
- **Barrel File**: File yang mengekspor multiple modules untuk simplified imports

## Requirements

### Requirement 1: Modularisasi Main Entry Point

**User Story:** As a developer, I want the main.dart file to be focused only on app initialization, so that the code is easier to understand and maintain.

#### Acceptance Criteria

1. WHEN the application starts THEN the Main Entry Point SHALL delegate app initialization to a dedicated AppInitializer service
2. WHEN the application starts THEN the Main Entry Point SHALL delegate theme configuration to a dedicated AppTheme class
3. WHEN the application starts THEN the Main Entry Point SHALL contain only essential bootstrapping code under 100 lines
4. WHEN navigation is needed THEN the Main Entry Point SHALL delegate navigation logic to a dedicated MainNavigationScreen in a separate file

### Requirement 2: Ekstraksi Dialog Components

**User Story:** As a developer, I want dialog components to be reusable and separated from screen logic, so that I can maintain consistency across the app.

#### Acceptance Criteria

1. WHEN a dialog is displayed THEN the Dialog Component SHALL be defined in a dedicated file under lib/widgets/dialogs/
2. WHEN the BatteryOptimizationDialog is needed THEN the Dialog Component SHALL be importable from a centralized dialogs barrel file
3. WHEN creating new dialogs THEN the Dialog Component SHALL follow a consistent pattern with configurable title, content, and actions

### Requirement 3: Centralized Theme Management

**User Story:** As a developer, I want theme configuration to be centralized, so that I can easily modify app appearance and support multiple themes.

#### Acceptance Criteria

1. WHEN the app theme is configured THEN the Theme Manager SHALL provide light and dark theme definitions from a single source
2. WHEN color values are needed THEN the Theme Manager SHALL expose named color constants instead of hardcoded hex values
3. WHEN the theme mode changes THEN the Theme Manager SHALL apply the new theme without app restart

### Requirement 4: Service Layer Cleanup

**User Story:** As a developer, I want services to have single responsibilities, so that they are easier to test and maintain.

#### Acceptance Criteria

1. WHEN a service is created THEN the Service SHALL handle only one domain of functionality
2. WHEN services have dependencies THEN the Service SHALL receive dependencies through constructor injection
3. WHEN deprecated APIs are used THEN the Service SHALL be updated to use current Flutter/Dart APIs

### Requirement 5: Consistent Error Handling

**User Story:** As a developer, I want consistent error handling across the app, so that users receive clear feedback and errors are properly logged.

#### Acceptance Criteria

1. WHEN an error occurs in a service THEN the Error Handler SHALL wrap the error in a domain-specific exception type
2. WHEN an error is displayed to users THEN the Error Handler SHALL show a user-friendly message via SnackBar or Dialog
3. WHEN an error occurs THEN the Error Handler SHALL log the error details for debugging purposes

### Requirement 6: Widget Extraction for Screens

**User Story:** As a developer, I want screen widgets to be broken into smaller, focused components, so that they are reusable and testable.

#### Acceptance Criteria

1. WHEN a screen contains multiple sections THEN the Screen SHALL delegate each section to a dedicated widget
2. WHEN a widget is extracted THEN the Widget SHALL be placed in lib/widgets/ with appropriate subdirectory organization
3. WHEN widgets are created THEN the Widget SHALL accept data and callbacks as parameters rather than accessing providers directly where possible

### Requirement 7: Code Quality Improvements

**User Story:** As a developer, I want the codebase to follow Flutter best practices, so that the code is consistent and maintainable.

#### Acceptance Criteria

1. WHEN deprecated APIs are detected THEN the Code Quality process SHALL update them to current alternatives
2. WHEN unused imports exist THEN the Code Quality process SHALL remove them
3. WHEN TODO comments exist THEN the Code Quality process SHALL either implement the functionality or create tracked issues
