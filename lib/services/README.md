# Notification Scheduling Services

This directory contains the services for managing subscription notifications in SUB-GUARD.

## Services Overview

### 1. AlarmManagerService
Manages Android Alarm Manager alarms for OS-level scheduling that works even when the app is closed or in doze mode.

**Key Features:**
- Schedules exact alarms with wakeup capability
- Reschedules alarms after device reboot
- Static callback function for background execution

**Usage:**
```dart
final alarmService = AlarmManagerService();
await alarmService.initialize();

// Schedule an alarm
await alarmService.scheduleAlarm(
  alarmId,
  dateTime,
  {
    'subscriptionId': 'sub-123',
    'serviceName': 'Netflix',
    'cost': 15.99,
    'currency': 'USD',
    'notificationType': 'intense',
    'daysUntilBilling': 1,
  },
);

// Cancel an alarm
await alarmService.cancelAlarm(alarmId);
```

### 2. NotificationScheduler
Orchestrates notification scheduling for subscriptions by creating multiple alarms based on reminder days.

**Key Features:**
- Creates 4 alarms per subscription (H-7, H-3, H-1, Day-0)
- Generates unique alarm IDs
- Determines notification type based on proximity to billing date
- Reschedules all notifications (useful after settings change or reboot)

**Usage:**
```dart
final scheduler = NotificationScheduler(
  alarmManager: alarmService,
  subscriptionRepository: subscriptionRepo,
  notificationConfig: notificationConfig,
);

// Schedule notifications for a subscription
await scheduler.scheduleNotificationsForSubscription(subscription);

// Cancel notifications for a subscription
await scheduler.cancelNotificationsForSubscription(subscriptionId);

// Reschedule all notifications
await scheduler.rescheduleAllNotifications();
```

### 3. NotificationService
Handles the display of notifications with different priority levels.

**Key Features:**
- Standard notifications for H-7 and H-3 reminders
- Intense alerts with full screen intent for H-1 and Day-0
- Notification actions (Mark Paid, Cancel, Snooze)
- Permission handling for Android 13+

**Usage:**
```dart
final notificationService = NotificationService();
await notificationService.initialize();

// Show standard notification
await notificationService.showStandardNotification(
  subscriptionId: 'sub-123',
  serviceName: 'Netflix',
  cost: 15.99,
  currency: 'USD',
  daysUntilBilling: 7,
);

// Show intense alert
await notificationService.showIntenseAlert(
  subscriptionId: 'sub-123',
  serviceName: 'Netflix',
  cost: 15.99,
  currency: 'USD',
  daysUntilBilling: 1,
);

// Request permissions
await notificationService.requestPermissions();
```

## Integration Example

Here's how to integrate these services in your app:

```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  // ... register adapters ...
  
  // Initialize services
  final alarmService = AlarmManagerService();
  await alarmService.initialize();
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Set notification service for alarm callbacks
  AlarmManagerService.setNotificationService(notificationService);
  
  runApp(MyApp());
}

// When adding a subscription
final scheduler = NotificationScheduler(
  alarmManager: AlarmManagerService(),
  subscriptionRepository: subscriptionRepo,
  notificationConfig: userSettings.notificationConfig,
);

await subscriptionRepo.add(subscription);
await scheduler.scheduleNotificationsForSubscription(subscription);
```

## Requirements Validation

These services implement the following requirements:

- **3.1-3.4**: Notification scheduling at H-7, H-3, H-1, and Day-0
- **3.5**: Using Alarm Manager to work in doze mode
- **4.1-4.3**: Intense alerts with full screen intent and action buttons
- **9.1-9.3**: Reliable notifications even when app is closed, with reboot rescheduling

## Android Permissions Required

Add these permissions to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
```
