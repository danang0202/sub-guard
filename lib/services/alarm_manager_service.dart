import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'notification_service.dart';

/// Top-level callback function for alarm manager - MUST be top-level!
@pragma('vm:entry-point')
Future<void> alarmCallback(int id, Map<String, dynamic> payload) async {
  try {
    // Extract notification data
    final subscriptionId = payload['subscriptionId'] as String;
    final serviceName = payload['serviceName'] as String;
    final cost = payload['cost'] as double;
    final currency = payload['currency'] as String;
    final notificationType = payload['notificationType'] as String;
    final daysUntilBilling = payload['daysUntilBilling'] as int;

    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Show the appropriate notification
    if (notificationType == 'intense') {
      await notificationService.showIntenseAlert(
        subscriptionId: subscriptionId,
        serviceName: serviceName,
        cost: cost,
        currency: currency,
        daysUntilBilling: daysUntilBilling,
      );
    } else {
      await notificationService.showStandardNotification(
        subscriptionId: subscriptionId,
        serviceName: serviceName,
        cost: cost,
        currency: currency,
        daysUntilBilling: daysUntilBilling,
      );
    }
  } catch (e) {
    // Log error but don't throw - we're in a background callback
    // ignore: avoid_print
    print('Error in alarm callback: $e');
  }
}

/// Service for managing Android Alarm Manager alarms
/// Uses android_alarm_manager_plus to schedule OS-level alarms that work
/// even when the app is closed or the device is in doze mode
class AlarmManagerService {
  static final AlarmManagerService _instance = AlarmManagerService._internal();
  factory AlarmManagerService() => _instance;
  AlarmManagerService._internal();

  /// Initialize the alarm manager service
  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  /// Schedule an alarm at a specific date and time
  ///
  /// [id] - Unique alarm ID
  /// [dateTime] - When the alarm should trigger
  /// [payload] - Data to pass to the callback (subscription info)
  Future<void> scheduleAlarm(
    int id,
    DateTime dateTime,
    Map<String, dynamic> payload,
  ) async {
    try {
      await AndroidAlarmManager.oneShotAt(
        dateTime,
        id,
        alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: payload,
      );
    } catch (e) {
      throw AlarmManagerException('Failed to schedule alarm: $e');
    }
  }

  /// Cancel a scheduled alarm
  ///
  /// [id] - The alarm ID to cancel
  Future<void> cancelAlarm(int id) async {
    try {
      await AndroidAlarmManager.cancel(id);
    } catch (e) {
      throw AlarmManagerException('Failed to cancel alarm: $e');
    }
  }

  /// Cancel all scheduled alarms
  Future<void> cancelAllAlarms() async {
    try {
      // Note: android_alarm_manager_plus doesn't have a cancelAll method
      // This would need to be implemented by tracking alarm IDs
      // For now, we'll rely on individual cancellation
    } catch (e) {
      throw AlarmManagerException('Failed to cancel all alarms: $e');
    }
  }
}

/// Custom exception for alarm manager operations
class AlarmManagerException implements Exception {
  final String message;

  AlarmManagerException(this.message);

  @override
  String toString() => 'AlarmManagerException: $message';
}
