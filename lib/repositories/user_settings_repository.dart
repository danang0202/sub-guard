import 'package:hive/hive.dart';
import '../models/user_settings.dart';
import '../models/notification_config.dart';

class UserSettingsRepository {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'user_settings';

  Box<UserSettings> get _box => Hive.box<UserSettings>(_boxName);

  /// Get user settings, returns default settings if none exist
  UserSettings get() {
    try {
      final settings = _box.get(_settingsKey);
      if (settings == null) {
        // Return default settings on first launch
        return const UserSettings();
      }
      return settings;
    } catch (e) {
      throw UserSettingsRepositoryException('Failed to get user settings: $e');
    }
  }

  /// Update user settings
  Future<void> update(UserSettings settings) async {
    try {
      await _box.put(_settingsKey, settings);
    } catch (e) {
      throw UserSettingsRepositoryException(
        'Failed to update user settings: $e',
      );
    }
  }

  /// Update base currency
  Future<void> updateBaseCurrency(String currency) async {
    try {
      final currentSettings = get();
      final updatedSettings = currentSettings.copyWith(baseCurrency: currency);
      await update(updatedSettings);
    } catch (e) {
      throw UserSettingsRepositoryException(
        'Failed to update base currency: $e',
      );
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    try {
      final currentSettings = get();
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
      await update(updatedSettings);
    } catch (e) {
      throw UserSettingsRepositoryException('Failed to update theme mode: $e');
    }
  }

  /// Update notification config
  Future<void> updateNotificationConfig(NotificationConfig config) async {
    try {
      final currentSettings = get();
      final updatedSettings = currentSettings.copyWith(
        notificationConfig: config,
      );
      await update(updatedSettings);
    } catch (e) {
      throw UserSettingsRepositoryException(
        'Failed to update notification config: $e',
      );
    }
  }

  /// Update last backup date
  Future<void> updateLastBackupDate(DateTime date) async {
    try {
      final currentSettings = get();
      final updatedSettings = currentSettings.copyWith(lastBackupDate: date);
      await update(updatedSettings);
    } catch (e) {
      throw UserSettingsRepositoryException(
        'Failed to update last backup date: $e',
      );
    }
  }

  /// Reset to default settings
  Future<void> reset() async {
    try {
      await update(const UserSettings());
    } catch (e) {
      throw UserSettingsRepositoryException(
        'Failed to reset user settings: $e',
      );
    }
  }

  /// Check if settings exist
  bool exists() {
    try {
      return _box.containsKey(_settingsKey);
    } catch (e) {
      throw UserSettingsRepositoryException(
        'Failed to check if settings exist: $e',
      );
    }
  }

  /// Initialize default settings if they don't exist
  Future<void> initializeDefaults() async {
    try {
      if (!exists()) {
        await update(const UserSettings());
      }
    } catch (e) {
      throw UserSettingsRepositoryException(
        'Failed to initialize default settings: $e',
      );
    }
  }
}

/// Custom exception for user settings repository operations
class UserSettingsRepositoryException implements Exception {
  final String message;

  UserSettingsRepositoryException(this.message);

  @override
  String toString() => 'UserSettingsRepositoryException: $message';
}
