import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_config.dart';
import '../providers/computed_providers.dart';
import '../providers/service_providers.dart';

/// Service for handling notification settings changes
/// Listens to notification config changes and triggers notification rescheduling
class NotificationSettingsHandler {
  final Ref _ref;

  NotificationSettingsHandler(this._ref);

  /// Initialize the handler and start listening to settings changes
  void initialize() {
    // Listen to settings changes
    _ref.listen<NotificationConfig>(
      userSettingsProvider.select((settings) => settings.notificationConfig),
      (previous, next) {
        _onNotificationConfigChanged(previous, next);
      },
    );
  }

  /// Handle notification config changes
  /// Triggers rescheduleAllNotifications when settings change
  Future<void> _onNotificationConfigChanged(
    NotificationConfig? previous,
    NotificationConfig next,
  ) async {
    // Skip if this is the first initialization
    if (previous == null) {
      return;
    }

    // Check if any relevant settings changed
    final hasChanged = _hasRelevantChanges(previous, next);

    if (hasChanged) {
      try {
        // Get the notification scheduler
        final scheduler = _ref.read(notificationSchedulerProvider);

        // Reschedule all notifications with new settings
        await scheduler.rescheduleAllNotifications();

        print('Notifications rescheduled due to settings change');
      } catch (e) {
        print('Error rescheduling notifications: $e');
        rethrow;
      }
    }
  }

  /// Check if there are relevant changes that require rescheduling
  bool _hasRelevantChanges(
    NotificationConfig previous,
    NotificationConfig next,
  ) {
    // Check if reminder days changed
    if (!_listEquals(previous.reminderDays, next.reminderDays)) {
      return true;
    }

    // Check if full screen alert mode changed
    if (previous.isFullScreenAlertEnabled != next.isFullScreenAlertEnabled) {
      return true;
    }

    // Sound enabled doesn't require rescheduling, just affects playback
    // So we don't trigger reschedule for sound changes

    return false;
  }

  /// Helper to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Provider for NotificationSettingsHandler
final notificationSettingsHandlerProvider =
    Provider<NotificationSettingsHandler>((ref) {
      return NotificationSettingsHandler(ref);
    });
