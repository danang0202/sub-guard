import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for displaying notifications
/// Handles both standard notifications and intense alerts with full screen intent
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize the notification service
  /// Must be called before using any notification methods
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels
    await _createNotificationChannels();

    _initialized = true;
  }

  /// Get the notifications plugin instance
  FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Standard notification channel
    const standardChannel = AndroidNotificationChannel(
      'subscription_reminders',
      'Subscription Reminders',
      description: 'Standard reminders for upcoming subscriptions',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Critical alert channel with full screen intent
    const intenseChannel = AndroidNotificationChannel(
      'critical_alerts',
      'Critical Billing Alerts',
      description: 'Critical alerts for imminent billing',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(standardChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(intenseChannel);
  }

  /// Show a standard notification (for H-7, H-3)
  Future<void> showStandardNotification({
    required String subscriptionId,
    required String serviceName,
    required double cost,
    required String currency,
    required int daysUntilBilling,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final String title;
    final String body;

    if (daysUntilBilling == 7) {
      title = 'Pengingat Tagihan - 7 Hari Lagi';
      body = '$serviceName: $currency $cost akan ditagih dalam 7 hari';
    } else if (daysUntilBilling == 3) {
      title = 'Pengingat Tagihan - 3 Hari Lagi';
      body = '$serviceName: $currency $cost akan ditagih dalam 3 hari';
    } else {
      title = 'Pengingat Tagihan';
      body = '$serviceName: $currency $cost akan ditagih';
    }

    const androidDetails = AndroidNotificationDetails(
      'subscription_reminders',
      'Subscription Reminders',
      channelDescription: 'Standard reminders for upcoming subscriptions',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      subscriptionId.hashCode,
      title,
      body,
      notificationDetails,
      payload: subscriptionId,
    );
  }

  /// Show an intense alert with full screen intent (for H-1, Day-0)
  Future<void> showIntenseAlert({
    required String subscriptionId,
    required String serviceName,
    required double cost,
    required String currency,
    required int daysUntilBilling,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final String title;
    final String body;

    if (daysUntilBilling == 1) {
      title = '⚠️ TAGIHAN BESOK! ⚠️';
      body = '$serviceName: $currency $cost AKAN DIPOTONG BESOK!';
    } else {
      title = '🚨 TAGIHAN HARI INI! 🚨';
      body = '$serviceName: $currency $cost AKAN DIPOTONG HARI INI!';
    }

    final androidDetails = AndroidNotificationDetails(
      'critical_alerts',
      'Critical Billing Alerts',
      channelDescription: 'Critical alerts for imminent billing',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      styleInformation: BigTextStyleInformation(body),
      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'mark_paid',
          'SAYA SUDAH BAYAR',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'cancel_subscription',
          'BATALKAN',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'snooze',
          'INGATKAN LAGI',
          cancelNotification: true,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      subscriptionId.hashCode + 1000, // Different ID for intense alerts
      title,
      body,
      notificationDetails,
      payload: subscriptionId,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    final actionId = response.actionId;

    if (payload == null) return;

    // Handle different actions
    switch (actionId) {
      case 'mark_paid':
        // TODO: Implement mark as paid functionality
        // This will be handled by the SubscriptionManager service
        // ignore: avoid_print
        print('Mark paid action for subscription: $payload');
        break;
      case 'cancel_subscription':
        // TODO: Implement cancel subscription functionality
        // This will be handled by the SubscriptionManager service
        // ignore: avoid_print
        print('Cancel subscription action for subscription: $payload');
        break;
      case 'snooze':
        // TODO: Implement snooze functionality
        // Reschedule notification for later
        // ignore: avoid_print
        print('Snooze action for subscription: $payload');
        break;
      default:
        // Default tap - open subscription detail
        // ignore: avoid_print
        print('Notification tapped for subscription: $payload');
        break;
    }
  }

  /// Cancel a notification by subscription ID
  Future<void> cancelNotification(String subscriptionId) async {
    await _notificationsPlugin.cancel(subscriptionId.hashCode);
    await _notificationsPlugin.cancel(subscriptionId.hashCode + 1000);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermissions() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) return false;

    final granted = await androidImplementation
        .requestNotificationsPermission();
    return granted ?? false;
  }

  /// Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) return false;

    final granted = await androidImplementation.requestExactAlarmsPermission();
    return granted ?? false;
  }
}

/// Custom exception for notification service operations
class NotificationServiceException implements Exception {
  final String message;

  NotificationServiceException(this.message);

  @override
  String toString() => 'NotificationServiceException: $message';
}
