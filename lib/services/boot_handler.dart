import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/subscription.dart';
import '../models/user_settings.dart';
import '../models/notification_config.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/user_settings_repository.dart';
import 'notification_scheduler.dart';
import 'alarm_manager_service.dart';

/// Service to handle device boot events and reschedule notifications
/// Validates: Requirements 9.2
class BootHandler {
  static bool _isInitialized = false;

  /// Initialize the boot handler
  /// This registers a callback that will be triggered after device boot
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Register the boot callback with android_alarm_manager_plus
      // This callback will be triggered by the BootReceiver after device restart
      await AndroidAlarmManager.initialize();
      _isInitialized = true;

      // ignore: avoid_print
      print('BootHandler initialized successfully');
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing BootHandler: $e');
    }
  }

  /// Static callback function that gets triggered after device boot
  /// This must be a top-level or static function
  @pragma('vm:entry-point')
  static Future<void> bootCallback() async {
    try {
      // ignore: avoid_print
      print('Boot callback triggered, rescheduling notifications');

      await _rescheduleAllNotifications();

      // ignore: avoid_print
      print('Successfully rescheduled all notifications after boot');
    } catch (e) {
      // ignore: avoid_print
      print('Error in boot callback: $e');
    }
  }

  /// Reschedule all notifications after device boot
  static Future<void> _rescheduleAllNotifications() async {
    try {
      // Initialize Hive if not already initialized
      if (!Hive.isBoxOpen('subscriptions')) {
        await Hive.initFlutter();

        // Register adapters
        if (!Hive.isAdapterRegistered(0)) {
          Hive.registerAdapter(BillingCycleAdapter());
        }
        if (!Hive.isAdapterRegistered(1)) {
          Hive.registerAdapter(SubscriptionAdapter());
        }
        if (!Hive.isAdapterRegistered(2)) {
          Hive.registerAdapter(NotificationConfigAdapter());
        }
        if (!Hive.isAdapterRegistered(3)) {
          Hive.registerAdapter(AppThemeModeAdapter());
        }
        if (!Hive.isAdapterRegistered(4)) {
          Hive.registerAdapter(UserSettingsAdapter());
        }

        // Open boxes
        await Hive.openBox<Subscription>('subscriptions');
        await Hive.openBox<UserSettings>('settings');
      }

      // Initialize alarm manager
      final alarmManager = AlarmManagerService();
      await alarmManager.initialize();

      // Get repositories
      final subscriptionRepository = SubscriptionRepository();
      final userSettingsRepository = UserSettingsRepository();

      // Get notification config from user settings
      final settings = userSettingsRepository.get();
      final notificationConfig = settings.notificationConfig;

      // Create notification scheduler
      final notificationScheduler = NotificationScheduler(
        alarmManager: alarmManager,
        subscriptionRepository: subscriptionRepository,
        notificationConfig: notificationConfig,
      );

      // Reschedule all notifications
      await notificationScheduler.rescheduleAllNotifications();
    } catch (e) {
      // ignore: avoid_print
      print('Error rescheduling notifications after boot: $e');
      rethrow;
    }
  }
}
