import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/user_settings_repository.dart';
import '../models/preset_service.dart';

/// Provider for SubscriptionRepository
/// Provides access to subscription database operations
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

/// Provider for UserSettingsRepository
/// Provides access to user settings database operations
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return UserSettingsRepository();
});

/// Provider for PresetServiceRepository
/// Provides access to preset service templates
final presetServiceRepositoryProvider = Provider<PresetServiceRepository>((
  ref,
) {
  return PresetServiceRepository();
});

/// Repository for managing preset services
/// Provides access to predefined service templates
class PresetServiceRepository {
  /// Get all preset services
  List<PresetService> getAllPresets() {
    return presetServices;
  }

  /// Get a preset service by name
  PresetService? getPresetByName(String name) {
    try {
      return presetServices.firstWhere(
        (preset) => preset.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Search presets by query
  /// Searches in service name
  List<PresetService> searchPresets(String query) {
    if (query.isEmpty) {
      return presetServices;
    }

    final lowerQuery = query.toLowerCase();
    return presetServices.where((preset) {
      return preset.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
