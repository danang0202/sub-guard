import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/subscription.dart';
import '../models/user_settings.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/user_settings_repository.dart';

/// Service for backing up and restoring application data
class BackupManager {
  final SubscriptionRepository _subscriptionRepository;
  final UserSettingsRepository _settingsRepository;

  BackupManager({
    required SubscriptionRepository subscriptionRepository,
    required UserSettingsRepository settingsRepository,
  }) : _subscriptionRepository = subscriptionRepository,
       _settingsRepository = settingsRepository;

  /// Export all data to JSON file
  /// Returns the file path of the created backup
  Future<String> exportToJson() async {
    try {
      // Get all subscriptions
      final subscriptions = _subscriptionRepository.getAll();

      // Get user settings
      final settings = _settingsRepository.get();

      // Create backup data structure
      final backupData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
        'settings': settings.toJson(),
      };

      // Convert to JSON string
      String jsonString;
      try {
        jsonString = jsonEncode(backupData);
      } catch (e) {
        throw BackupManagerException(
          'Failed to serialize data to JSON: $e',
          type: BackupErrorType.parseError,
        );
      }

      // Get app documents directory
      Directory directory;
      try {
        directory = await getApplicationDocumentsDirectory();
      } catch (e) {
        throw BackupManagerException(
          'Failed to access storage directory: $e. Please check storage permissions.',
          type: BackupErrorType.storagePermissionDenied,
        );
      }

      // Create backup file with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'subguard_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // Write to file
      try {
        await file.writeAsString(jsonString);
      } catch (e) {
        throw BackupManagerException(
          'Failed to write backup file: $e. Please check storage permissions and available space.',
          type: BackupErrorType.writeError,
        );
      }

      // Update last backup date in settings
      try {
        await _settingsRepository.updateLastBackupDate(DateTime.now());
      } catch (e) {
        // Non-critical error, backup was successful
        // Just log it but don't fail the operation
      }

      return file.path;
    } catch (e) {
      if (e is BackupManagerException) rethrow;
      throw BackupManagerException(
        'Failed to export data: $e',
        type: BackupErrorType.unknown,
      );
    }
  }

  /// Import data from JSON file
  /// Validates and restores all subscriptions and settings
  Future<void> importFromJson(String jsonPath) async {
    // Validate backup file first with detailed error messages
    await validateBackupFileDetailed(jsonPath);

    try {
      // Read file
      final file = File(jsonPath);
      final jsonString = await file.readAsString();

      // Parse JSON (already validated, so this should succeed)
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Clear existing data
      try {
        await _subscriptionRepository.clear();
      } catch (e) {
        throw BackupManagerException(
          'Failed to clear existing data before restore: $e',
          type: BackupErrorType.writeError,
        );
      }

      // Restore subscriptions
      final subscriptionsJson = backupData['subscriptions'] as List<dynamic>;

      for (var i = 0; i < subscriptionsJson.length; i++) {
        try {
          final subscription = Subscription.fromJson(
            subscriptionsJson[i] as Map<String, dynamic>,
          );
          await _subscriptionRepository.add(subscription);
        } catch (e) {
          throw BackupManagerException(
            'Failed to restore subscription at index $i: $e',
            type: BackupErrorType.writeError,
          );
        }
      }

      // Restore settings
      try {
        final settingsJson = backupData['settings'] as Map<String, dynamic>;
        final settings = UserSettings.fromJson(settingsJson);
        await _settingsRepository.update(settings);
      } catch (e) {
        throw BackupManagerException(
          'Failed to restore settings: $e',
          type: BackupErrorType.writeError,
        );
      }
    } catch (e) {
      if (e is BackupManagerException) rethrow;
      throw BackupManagerException(
        'Failed to import data: $e',
        type: BackupErrorType.unknown,
      );
    }
  }

  /// Validate backup file structure
  /// Checks if JSON has required fields and valid format
  /// Throws BackupManagerException with specific error details
  Future<void> validateBackupFileDetailed(String jsonPath) async {
    // Check if file exists
    final file = File(jsonPath);
    if (!await file.exists()) {
      throw BackupManagerException(
        'Backup file not found at: $jsonPath',
        type: BackupErrorType.fileNotFound,
      );
    }

    String jsonString;
    try {
      jsonString = await file.readAsString();
    } catch (e) {
      throw BackupManagerException(
        'Failed to read backup file: $e',
        type: BackupErrorType.readError,
      );
    }

    // Parse JSON
    dynamic data;
    try {
      data = jsonDecode(jsonString);
    } catch (e) {
      throw BackupManagerException(
        'Invalid JSON format: $e',
        type: BackupErrorType.parseError,
      );
    }

    // Check if it's a map
    if (data is! Map<String, dynamic>) {
      throw BackupManagerException(
        'Backup file must contain a JSON object, found: ${data.runtimeType}',
        type: BackupErrorType.invalidFormat,
      );
    }

    // Check required top-level fields
    if (!data.containsKey('version')) {
      throw BackupManagerException(
        'Missing required field: version',
        type: BackupErrorType.missingRequiredFields,
      );
    }

    if (!data.containsKey('subscriptions')) {
      throw BackupManagerException(
        'Missing required field: subscriptions',
        type: BackupErrorType.missingRequiredFields,
      );
    }

    if (!data.containsKey('settings')) {
      throw BackupManagerException(
        'Missing required field: settings',
        type: BackupErrorType.missingRequiredFields,
      );
    }

    // Check subscriptions is a list
    if (data['subscriptions'] is! List) {
      throw BackupManagerException(
        'Field "subscriptions" must be a list, found: ${data['subscriptions'].runtimeType}',
        type: BackupErrorType.invalidFieldType,
      );
    }

    // Check settings is a map
    if (data['settings'] is! Map) {
      throw BackupManagerException(
        'Field "settings" must be an object, found: ${data['settings'].runtimeType}',
        type: BackupErrorType.invalidFieldType,
      );
    }

    // Validate subscriptions
    final subscriptionsJson = data['subscriptions'] as List<dynamic>;
    for (var i = 0; i < subscriptionsJson.length; i++) {
      final subJson = subscriptionsJson[i];

      if (subJson is! Map<String, dynamic>) {
        throw BackupManagerException(
          'Subscription at index $i must be an object, found: ${subJson.runtimeType}',
          type: BackupErrorType.invalidFieldType,
        );
      }

      // Check required subscription fields
      final requiredFields = [
        'id',
        'serviceName',
        'cost',
        'currency',
        'billingCycle',
        'startDate',
        'nextBillingDate',
        'isAutoRenew',
      ];

      for (final field in requiredFields) {
        if (!subJson.containsKey(field)) {
          throw BackupManagerException(
            'Subscription at index $i is missing required field: $field',
            type: BackupErrorType.missingRequiredFields,
          );
        }
      }

      // Validate date fields can be parsed
      try {
        DateTime.parse(subJson['startDate'] as String);
      } catch (e) {
        throw BackupManagerException(
          'Subscription at index $i has invalid startDate format: ${subJson['startDate']}',
          type: BackupErrorType.invalidFieldType,
        );
      }

      try {
        DateTime.parse(subJson['nextBillingDate'] as String);
      } catch (e) {
        throw BackupManagerException(
          'Subscription at index $i has invalid nextBillingDate format: ${subJson['nextBillingDate']}',
          type: BackupErrorType.invalidFieldType,
        );
      }
    }

    // Validate settings
    final settingsJson = data['settings'] as Map<String, dynamic>;
    final requiredSettingsFields = [
      'baseCurrency',
      'themeMode',
      'notificationConfig',
    ];

    for (final field in requiredSettingsFields) {
      if (!settingsJson.containsKey(field)) {
        throw BackupManagerException(
          'Settings is missing required field: $field',
          type: BackupErrorType.missingRequiredFields,
        );
      }
    }

    // Validate notification config
    if (settingsJson['notificationConfig'] is! Map) {
      throw BackupManagerException(
        'Settings field "notificationConfig" must be an object',
        type: BackupErrorType.invalidFieldType,
      );
    }
  }

  /// Validate backup file structure (legacy method for backward compatibility)
  /// Returns true if valid, false otherwise
  Future<bool> validateBackupFile(String jsonPath) async {
    try {
      await validateBackupFileDetailed(jsonPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get list of available backup files
  Future<List<File>> getBackupFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => file.path.contains('subguard_backup_'))
          .toList();

      // Sort by modification date (newest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return files;
    } catch (e) {
      throw BackupManagerException('Failed to get backup files: $e');
    }
  }

  /// Delete a backup file
  Future<void> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw BackupManagerException('Failed to delete backup file: $e');
    }
  }

  /// Get backup file info
  Future<Map<String, dynamic>> getBackupInfo(String jsonPath) async {
    try {
      final file = File(jsonPath);
      if (!await file.exists()) {
        throw BackupManagerException('Backup file not found: $jsonPath');
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final subscriptionsCount = (data['subscriptions'] as List).length;
      final exportDate = DateTime.parse(data['exportDate'] as String);
      final version = data['version'] as String;

      return {
        'subscriptionsCount': subscriptionsCount,
        'exportDate': exportDate,
        'version': version,
        'filePath': jsonPath,
      };
    } catch (e) {
      throw BackupManagerException('Failed to get backup info: $e');
    }
  }
}

/// Custom exception for backup manager operations
class BackupManagerException implements Exception {
  final String message;
  final BackupErrorType type;

  BackupManagerException(this.message, {this.type = BackupErrorType.unknown});

  @override
  String toString() => 'BackupManagerException: $message';
}

/// Types of backup/restore errors
enum BackupErrorType {
  fileNotFound,
  invalidFormat,
  missingRequiredFields,
  invalidFieldType,
  parseError,
  storagePermissionDenied,
  writeError,
  readError,
  unknown,
}
