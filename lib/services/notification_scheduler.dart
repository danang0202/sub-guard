import '../models/subscription.dart';
import '../models/notification_config.dart';
import '../repositories/subscription_repository.dart';
import 'alarm_manager_service.dart';

/// Service for scheduling subscription notifications
/// Creates multiple alarms for each subscription based on reminder days
class NotificationScheduler {
  final AlarmManagerService _alarmManager;
  final SubscriptionRepository _subscriptionRepository;
  final NotificationConfig _notificationConfig;

  NotificationScheduler({
    required AlarmManagerService alarmManager,
    required SubscriptionRepository subscriptionRepository,
    required NotificationConfig notificationConfig,
  }) : _alarmManager = alarmManager,
       _subscriptionRepository = subscriptionRepository,
       _notificationConfig = notificationConfig;

  /// Schedule all notifications for a subscription
  /// Creates 4 alarms by default: -7, -3, -1, 0 days before billing
  Future<void> scheduleNotificationsForSubscription(
    Subscription subscription,
  ) async {
    try {
      // Only schedule for active subscriptions
      if (!subscription.isActive) {
        return;
      }

      final billingDate = subscription.nextBillingDate;
      final now = DateTime.now();

      // Schedule notifications for each reminder day
      for (final reminderDay in _notificationConfig.reminderDays) {
        // Calculate the base notification date
        final baseDate = billingDate.subtract(Duration(days: reminderDay));

        // Schedule for 3 times: 07:30, 12:00, 18:00
        final times = [
          {'hour': 7, 'minute': 30},
          {'hour': 12, 'minute': 0},
          {'hour': 18, 'minute': 0},
        ];

        for (var i = 0; i < times.length; i++) {
          final time = times[i];
          final notificationDate = DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            time['hour']!,
            time['minute']!,
          );

          // Only schedule if the notification date is in the future
          if (notificationDate.isAfter(now)) {
            final alarmId = _generateAlarmId(subscription.id, reminderDay, i);

            // Determine notification type based on reminder day
            final notificationType = _getNotificationType(reminderDay);

            final payload = {
              'subscriptionId': subscription.id,
              'serviceName': subscription.serviceName,
              'cost': subscription.cost,
              'currency': subscription.currency,
              'notificationType': notificationType,
              'daysUntilBilling': reminderDay,
            };

            await _alarmManager.scheduleAlarm(
              alarmId,
              notificationDate,
              payload,
            );
          }
        }
      }
    } catch (e) {
      throw NotificationSchedulerException(
        'Failed to schedule notifications for subscription ${subscription.id}: $e',
      );
    }
  }

  /// Cancel all notifications for a subscription
  Future<void> cancelNotificationsForSubscription(String subscriptionId) async {
    try {
      // Cancel alarms for all possible reminder days and times
      for (final reminderDay in _notificationConfig.reminderDays) {
        // 3 times per day
        for (var i = 0; i < 3; i++) {
          final alarmId = _generateAlarmId(subscriptionId, reminderDay, i);
          await _alarmManager.cancelAlarm(alarmId);
        }
      }
    } catch (e) {
      throw NotificationSchedulerException(
        'Failed to cancel notifications for subscription $subscriptionId: $e',
      );
    }
  }

  /// Reschedule all notifications for all subscriptions
  /// Useful after device reboot or settings change
  Future<void> rescheduleAllNotifications() async {
    try {
      // Get all active subscriptions
      final subscriptions = _subscriptionRepository.getActive();

      // Cancel and reschedule for each subscription
      for (final subscription in subscriptions) {
        // Cancel existing notifications
        await cancelNotificationsForSubscription(subscription.id);

        // Schedule new notifications
        await scheduleNotificationsForSubscription(subscription);
      }
    } catch (e) {
      throw NotificationSchedulerException(
        'Failed to reschedule all notifications: $e',
      );
    }
  }

  /// Generate a unique alarm ID based on subscription ID, reminder day, and time index
  /// This ensures each notification has a unique ID
  int _generateAlarmId(String subscriptionId, int reminderDay, int timeIndex) {
    // Use hash code of subscription ID combined with reminder day and time index
    // This creates a unique but reproducible ID
    final baseHash = subscriptionId.hashCode;

    // Combine with reminder day and time index to make it unique
    // Use different multipliers to avoid collisions
    // reminderDay * 1000000 (up to ~2000 days)
    // timeIndex * 10000 (up to ~100 times)
    return (baseHash & 0x0FFFFFFF) +
        (reminderDay * 1000000) +
        (timeIndex * 10000);
  }

  /// Determine notification type based on days until billing
  /// Returns 'intense' for H-1 and Day-0, 'standard' for others
  String _getNotificationType(int daysUntilBilling) {
    if (!_notificationConfig.isFullScreenAlertEnabled) {
      return 'standard';
    }

    // Intense alerts for 1 day before and day of billing
    if (daysUntilBilling <= 1) {
      return 'intense';
    }

    return 'standard';
  }
}

/// Custom exception for notification scheduler operations
class NotificationSchedulerException implements Exception {
  final String message;

  NotificationSchedulerException(this.message);

  @override
  String toString() => 'NotificationSchedulerException: $message';
}
