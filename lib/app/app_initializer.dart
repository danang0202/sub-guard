import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/subscription.dart';
import '../models/notification_config.dart';
import '../models/user_settings.dart';

/// Global Flutter Local Notifications plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Handles all app initialization tasks.
///
/// This class centralizes initialization logic that was previously
/// scattered in main.dart, making it easier to maintain and test.
class AppInitializer {
  // Private constructor to prevent instantiation
  AppInitializer._();

  /// Initialize all required services and dependencies.
  ///
  /// This method should be called once at app startup before runApp().
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await _initializeHive();
    await _initializeAlarmManager();
    await _initializeNotifications();
  }

  /// Initialize Hive database and register adapters.
  static Future<void> _initializeHive() async {
    await Hive.initFlutter();

    // Register Hive type adapters
    Hive.registerAdapter(BillingCycleAdapter());
    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(NotificationConfigAdapter());
    Hive.registerAdapter(AppThemeModeAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    // Open Hive boxes
    await Hive.openBox<Subscription>('subscriptions');
    await Hive.openBox<UserSettings>('settings');
  }

  /// Initialize Android Alarm Manager.
  static Future<void> _initializeAlarmManager() async {
    // Guard against duplicate initialization
    // This prevents "duplicate background isolate" warning
    try {
      await AndroidAlarmManager.initialize();
    } catch (e) {
      // If already initialized, this will fail silently
      debugPrint('AlarmManager initialization: $e');
    }
  }

  /// Initialize Flutter Local Notifications.
  static Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }
}
