import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_settings.dart';
import '../models/notification_config.dart';
import '../repositories/user_settings_repository.dart';

/// StateNotifier for managing user settings
/// Provides reactive state management for user settings changes
class UserSettingsNotifier extends StateNotifier<UserSettings> {
  final UserSettingsRepository _repository;

  UserSettingsNotifier(this._repository) : super(_repository.get());

  /// Update the entire user settings
  Future<void> updateSettings(UserSettings settings) async {
    await _repository.update(settings);
    state = settings;
  }

  /// Update base currency
  Future<void> updateBaseCurrency(String currency) async {
    final updatedSettings = state.copyWith(baseCurrency: currency);
    await _repository.update(updatedSettings);
    state = updatedSettings;
  }

  /// Update theme mode
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final updatedSettings = state.copyWith(themeMode: themeMode);
    await _repository.update(updatedSettings);
    state = updatedSettings;
  }

  /// Update notification config
  Future<void> updateNotificationConfig(NotificationConfig config) async {
    final updatedSettings = state.copyWith(notificationConfig: config);
    await _repository.update(updatedSettings);
    state = updatedSettings;
  }

  /// Update last backup date
  Future<void> updateLastBackupDate(DateTime date) async {
    final updatedSettings = state.copyWith(lastBackupDate: date);
    await _repository.update(updatedSettings);
    state = updatedSettings;
  }

  /// Reset to default settings
  Future<void> reset() async {
    const defaultSettings = UserSettings();
    await _repository.update(defaultSettings);
    state = defaultSettings;
  }

  /// Reload settings from repository
  void reload() {
    state = _repository.get();
  }
}
