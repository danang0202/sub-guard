# Design Document - SUB-GUARD Android

## Overview

SUB-GUARD adalah aplikasi mobile Android native yang dibangun menggunakan Flutter framework. Aplikasi ini dirancang dengan arsitektur clean architecture yang memisahkan concerns antara UI, business logic, dan data layer. Fokus utama design adalah memastikan reliabilitas notifikasi melalui penggunaan Android Alarm Manager dan optimasi untuk berbagai manufacturer Android.

Aplikasi menggunakan Hive sebagai database lokal untuk performa tinggi dan flutter_local_notifications dengan android_alarm_manager_plus untuk sistem notifikasi yang robust.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  (Flutter Widgets, Screens, State Management)           │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Business Logic Layer                  │
│  (Use Cases, Services, Notification Scheduler)          │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  (Repositories, Hive Database, Local Storage)           │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   Platform Layer                         │
│  (Android Alarm Manager, Notification Channels)         │
└─────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

**Presentation Layer:**
- Renders UI using Flutter widgets with Material Design
- Manages UI state using Riverpod
- Handles user interactions and navigation
- Displays subscription cards with brand colors
- Renders calendar view and dashboard

**Business Logic Layer:**
- Implements use cases for subscription management
- Calculates total costs and currency conversions
- Schedules notifications based on billing dates
- Manages notification escalation logic (H-7, H-3, H-1, Day-0)
- Handles backup/restore operations

**Data Layer:**
- Provides repository pattern for data access
- Manages Hive database operations
- Handles JSON export/import for backup
- Stores preset service templates
- Manages user settings persistence

**Platform Layer:**
- Interfaces with Android Alarm Manager
- Manages notification channels and priorities
- Handles full screen intents for Intense Alerts
- Detects device manufacturer for battery optimization guidance

## Components and Interfaces

### Core Components

#### 1. Subscription Manager
```dart
class SubscriptionManager {
  Future<void> addSubscription(Subscription subscription);
  Future<void> updateSubscription(String id, Subscription subscription);
  Future<void> deleteSubscription(String id);
  Future<Subscription?> getSubscription(String id);
  Future<List<Subscription>> getAllSubscriptions();
  Future<void> markAsPaid(String id);
  Future<void> cancelSubscription(String id);
}
```

#### 2. Notification Scheduler
```dart
class NotificationScheduler {
  Future<void> scheduleNotificationsForSubscription(Subscription subscription);
  Future<void> cancelNotificationsForSubscription(String subscriptionId);
  Future<void> rescheduleAllNotifications();
  Future<void> scheduleIntenseAlert(DateTime dateTime, Subscription subscription);
  Future<void> scheduleStandardNotification(DateTime dateTime, Subscription subscription);
}
```

#### 3. Alarm Manager Service
```dart
class AlarmManagerService {
  Future<void> scheduleAlarm(int id, DateTime dateTime, Map<String, dynamic> payload);
  Future<void> cancelAlarm(int id);
  Future<void> rescheduleAllAlarms();
  static void alarmCallback(int id);
}
```

#### 4. Preset Service Repository
```dart
class PresetServiceRepository {
  List<PresetService> getAllPresets();
  PresetService? getPresetByName(String name);
  List<PresetService> searchPresets(String query);
}
```

#### 5. Cost Calculator
```dart
class CostCalculator {
  double calculateMonthlyTotal(List<Subscription> subscriptions, String baseCurrency);
  double convertCurrency(double amount, String fromCurrency, String toCurrency);
  double normalizeToMonthly(double amount, BillingCycle cycle);
}
```

#### 6. Backup Manager
```dart
class BackupManager {
  Future<String> exportToJson();
  Future<void> importFromJson(String jsonPath);
  Future<bool> validateBackupFile(String jsonPath);
}
```

#### 7. Battery Optimization Detector
```dart
class BatteryOptimizationDetector {
  Future<String> getDeviceManufacturer();
  Future<bool> isBatteryOptimizationEnabled();
  String getWhitelistingInstructions(String manufacturer);
  Future<void> requestBatteryOptimizationExemption();
}
```

## Data Models

### Subscription Model
```dart
class Subscription {
  final String id;
  final String serviceName;
  final double cost;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime startDate;
  final DateTime nextBillingDate;
  final String paymentMethod;
  final String? serviceLogoPath;
  final String? colorHex;
  final bool isAutoRenew;
  final bool isActive;
  
  Subscription({
    required this.id,
    required this.serviceName,
    required this.cost,
    required this.currency,
    required this.billingCycle,
    required this.startDate,
    required this.nextBillingDate,
    required this.paymentMethod,
    this.serviceLogoPath,
    this.colorHex,
    required this.isAutoRenew,
    this.isActive = true,
  });
}

enum BillingCycle { monthly, yearly }
```

### Preset Service Model
```dart
class PresetService {
  final String name;
  final String logoAssetPath;
  final String colorHex;
  final String defaultCurrency;
  final double? suggestedPrice;
  
  PresetService({
    required this.name,
    required this.logoAssetPath,
    required this.colorHex,
    required this.defaultCurrency,
    this.suggestedPrice,
  });
}
```

### Notification Config Model
```dart
class NotificationConfig {
  final List<int> reminderDays; // e.g., [7, 3, 1, 0]
  final bool isFullScreenAlertEnabled;
  final bool soundEnabled;
  
  NotificationConfig({
    this.reminderDays = const [7, 3, 1, 0],
    this.isFullScreenAlertEnabled = true,
    this.soundEnabled = true,
  });
}
```

### User Settings Model
```dart
class UserSettings {
  final String baseCurrency;
  final ThemeMode themeMode;
  final DateTime? lastBackupDate;
  final NotificationConfig notificationConfig;
  
  UserSettings({
    this.baseCurrency = 'USD',
    this.themeMode = ThemeMode.dark,
    this.lastBackupDate,
    required this.notificationConfig,
  });
}
```

### Notification Payload Model
```dart
class NotificationPayload {
  final String subscriptionId;
  final String serviceName;
  final double cost;
  final String currency;
  final NotificationType type;
  final int daysUntilBilling;
  
  NotificationPayload({
    required this.subscriptionId,
    required this.serviceName,
    required this.cost,
    required this.currency,
    required this.type,
    required this.daysUntilBilling,
  });
}

enum NotificationType { standard, intense }
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Subscription persistence round trip
*For any* valid subscription object, saving it to the database and then retrieving it should produce an equivalent subscription with all fields preserved.
**Validates: Requirements 2.5**

### Property 2: Notification scheduling completeness
*For any* subscription with a valid next billing date, scheduling notifications should create exactly 4 alarm entries (for days -7, -3, -1, and 0) in the Alarm Manager.
**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

### Property 3: Cost calculation consistency
*For any* list of subscriptions, calculating the monthly total twice should always produce the same result.
**Validates: Requirements 5.1, 5.4**

### Property 4: Currency normalization
*For any* subscription with yearly billing cycle, normalizing to monthly should divide the cost by 12.
**Validates: Requirements 5.2**

### Property 5: Notification rescheduling preservation
*For any* set of scheduled notifications, canceling and rescheduling all notifications should result in the same number of scheduled alarms.
**Validates: Requirements 9.2, 9.3**

### Property 6: Backup and restore round trip
*For any* set of subscriptions, exporting to JSON and then importing should restore all subscriptions with equivalent data.
**Validates: Requirements 7.1, 7.2, 7.3**

### Property 7: Subscription deletion cleanup
*For any* subscription, deleting it should remove all associated scheduled notifications from the Alarm Manager.
**Validates: Requirements 10.3**

### Property 8: Billing date update propagation
*For any* subscription marked as paid, the next billing date should be updated by adding one billing cycle period to the current next billing date.
**Validates: Requirements 10.4**

### Property 9: Calendar date aggregation
*For any* date on the calendar, the subscriptions displayed for that date should exactly match all subscriptions whose next billing date equals that date.
**Validates: Requirements 6.4**

### Property 10: Preset auto-population completeness
*For any* preset service selected, all fields (serviceName, logoPath, colorHex, defaultCurrency) should be non-null after auto-population.
**Validates: Requirements 1.1**

### Property 11: Notification settings propagation
*For any* change to notification settings, all future scheduled notifications should reflect the new settings after rescheduling.
**Validates: Requirements 11.5**

### Property 12: Active subscription filtering
*For any* subscription marked as cancelled (isActive = false), it should not appear in the dashboard total cost calculation.
**Validates: Requirements 10.5**

## Error Handling

### Database Errors
- **Hive Box Not Opened**: Ensure all Hive boxes are opened during app initialization. Provide fallback to re-open if closed unexpectedly.
- **Data Corruption**: Validate data structure when reading from Hive. If corrupted, log error and skip the corrupted entry.
- **Write Failures**: Retry write operations up to 3 times with exponential backoff. Show user error message if all retries fail.

### Notification Errors
- **Alarm Manager Unavailable**: Check if Alarm Manager service is available. Fall back to WorkManager if unavailable.
- **Permission Denied**: Request necessary permissions (SCHEDULE_EXACT_ALARM, USE_FULL_SCREEN_INTENT) at app startup. Show explanation dialog if denied.
- **Notification Channel Creation Failed**: Retry channel creation. Log error and use default channel if creation fails.

### Backup/Restore Errors
- **Invalid JSON Format**: Validate JSON structure before importing. Show specific error message indicating which field is invalid.
- **File Not Found**: Check file existence before attempting restore. Show file picker if path is invalid.
- **Storage Permission Denied**: Request storage permissions. Show explanation and guide user to settings if permanently denied.

### Currency Conversion Errors
- **Unknown Currency**: Maintain a fallback list of common currencies. If currency not found, display in original currency with warning.
- **Conversion Rate Unavailable**: Use 1:1 conversion as fallback and show warning to user.

### Platform-Specific Errors
- **Battery Optimization Detection Failed**: Assume optimization is enabled and show generic whitelisting instructions.
- **Manufacturer Detection Failed**: Show generic Android battery optimization instructions.
- **Full Screen Intent Not Supported**: Fall back to high-priority notification with sound and vibration.

## Testing Strategy

### Unit Testing

Unit tests will cover:
- **Data Model Serialization**: Test Subscription, PresetService, and UserSettings to/from JSON
- **Cost Calculator Logic**: Test monthly normalization, currency conversion, and total calculation with various inputs
- **Date Calculations**: Test billing date updates, reminder day calculations
- **Validation Logic**: Test input validation for subscription creation
- **Preset Repository**: Test preset search and retrieval

### Property-Based Testing

Property-based testing will use the **fast_check** equivalent for Dart, which is **test_api** with custom generators, or **faker** for data generation combined with standard test assertions.

For Flutter/Dart, we'll use the built-in **test** package with custom property test helpers that generate random inputs.

**Configuration:**
- Each property test will run a minimum of 100 iterations
- Tests will use random seed for reproducibility
- Failed tests will shrink inputs to find minimal failing case

**Property Tests to Implement:**
1. **Subscription Persistence Round Trip** (Property 1)
2. **Notification Scheduling Completeness** (Property 2)
3. **Cost Calculation Consistency** (Property 3)
4. **Currency Normalization** (Property 4)
5. **Notification Rescheduling Preservation** (Property 5)
6. **Backup and Restore Round Trip** (Property 6)
7. **Subscription Deletion Cleanup** (Property 7)
8. **Billing Date Update Propagation** (Property 8)
9. **Calendar Date Aggregation** (Property 9)
10. **Preset Auto-Population Completeness** (Property 10)
11. **Notification Settings Propagation** (Property 11)
12. **Active Subscription Filtering** (Property 12)

Each property-based test will be tagged with a comment in this format:
```dart
// **Feature: sub-guard-android, Property 1: Subscription persistence round trip**
test('subscription persistence round trip', () { ... });
```

### Integration Testing

Integration tests will verify:
- **End-to-End Subscription Flow**: Create subscription → Schedule notifications → Receive notification → Mark as paid
- **Backup/Restore Flow**: Create subscriptions → Export → Clear data → Import → Verify data
- **Notification Delivery**: Schedule alarm → Wait for trigger → Verify notification appears
- **UI Navigation**: Navigate through all screens and verify state persistence

### Widget Testing

Widget tests will cover:
- **Subscription Card Rendering**: Verify brand colors, logos, and billing information display correctly
- **Calendar View**: Verify dates are highlighted correctly based on proximity to billing
- **Dashboard**: Verify total cost calculation displays correctly
- **Form Validation**: Verify input validation messages appear correctly

### Platform Testing

Platform-specific tests will verify:
- **Alarm Manager Integration**: Verify alarms are scheduled at correct times
- **Full Screen Intent**: Verify full screen notifications appear when device is locked
- **Battery Optimization Detection**: Verify correct manufacturer detection and instructions
- **Notification Channels**: Verify high-priority channel is created correctly

### Test Data Generators

Custom generators for property-based testing:
```dart
// Generate random subscriptions
Subscription generateRandomSubscription();

// Generate random billing dates
DateTime generateRandomBillingDate();

// Generate random currency codes
String generateRandomCurrency();

// Generate random preset services
PresetService generateRandomPreset();

// Generate random notification configs
NotificationConfig generateRandomNotificationConfig();
```

## UI/UX Design Specifications

### Color Scheme

**Base Theme (Dark Mode):**
- Background: `#121212`
- Surface: `#1E1E1E`
- Primary: `#BB86FC`
- Secondary: `#03DAC6`

**Alert Colors:**
- Warning (H-7, H-3): `#FFC107` (Yellow/Amber)
- Critical (H-1, Day-0): `#FF5252` (Red)
- Safe: `#4CAF50` (Green)

**Brand Colors (Examples):**
- Netflix: `#E50914`
- Spotify: `#1DB954`
- GitHub: `#181717`
- ChatGPT: `#10A37F`
- Adobe: `#FF0000`

### Typography

- **Headings**: Roboto Bold, 24sp
- **Body**: Roboto Regular, 16sp
- **Captions**: Roboto Light, 12sp
- **Alert Text**: Roboto Bold, 20sp

### Screen Layouts

#### Dashboard Screen
- Top: Total monthly cost card (large, prominent)
- Middle: Upcoming bills section (sorted by date)
- Bottom: Navigation bar

#### Calendar Screen
- Month view with date cells
- Color-coded dates based on billing proximity
- Tap date to see subscriptions

#### Subscription Detail Screen
- Service logo and name at top
- Cost and billing cycle
- Next billing date (prominent)
- Edit/Delete buttons
- Payment method info

#### Add/Edit Subscription Screen
- Preset service selector (grid of logos)
- Manual entry form (if custom)
- Billing cycle toggle
- Date picker for next billing
- Save button

#### Settings Screen
- Notification preferences
- Base currency selector
- Theme toggle (if Material You disabled)
- Backup/Restore buttons
- Battery optimization status and guide

### Intense Alert Screen Design

Full screen layout when alarm triggers:
```
┌─────────────────────────────────────┐
│                                     │
│         [SERVICE LOGO]              │
│                                     │
│    ⚠️ TAGIHAN BESOK! ⚠️            │
│                                     │
│         [SERVICE NAME]              │
│                                     │
│      Rp [AMOUNT] AKAN DIPOTONG     │
│                                     │
│  ┌─────────────────────────────┐  │
│  │   SAYA SUDAH BAYAR          │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │   BATALKAN LANGGANAN        │  │
│  └─────────────────────────────┘  │
│                                     │
│  ┌─────────────────────────────┐  │
│  │   INGATKAN LAGI NANTI       │  │
│  └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

Background: Red gradient
Text: White, bold
Buttons: Large, high contrast

## Implementation Notes

### Android Permissions Required

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

### Notification Channel Configuration

```dart
const AndroidNotificationChannel standardChannel = AndroidNotificationChannel(
  'subscription_reminders',
  'Subscription Reminders',
  description: 'Standard reminders for upcoming subscriptions',
  importance: Importance.high,
);

const AndroidNotificationChannel intenseChannel = AndroidNotificationChannel(
  'critical_alerts',
  'Critical Billing Alerts',
  description: 'Critical alerts for imminent billing',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  enableLights: true,
);
```

### Alarm Manager Implementation

Use `android_alarm_manager_plus` with exact alarms:
```dart
await AndroidAlarmManager.oneShotAt(
  scheduledDateTime,
  alarmId,
  alarmCallback,
  exact: true,
  wakeup: true,
  rescheduleOnReboot: true,
);
```

### Manufacturer-Specific Battery Optimization Instructions

**Xiaomi:**
1. Buka Settings → Apps → Manage Apps
2. Cari "SUB-GUARD"
3. Pilih "Battery saver" → "No restrictions"
4. Aktifkan "Autostart"

**Samsung:**
1. Buka Settings → Apps → SUB-GUARD
2. Pilih "Battery" → "Optimize battery usage"
3. Pilih "All" dan matikan optimasi untuk SUB-GUARD

**Oppo/Realme:**
1. Buka Settings → Battery → App Battery Management
2. Cari SUB-GUARD dan pilih "Don't optimize"
3. Buka Settings → Privacy → Startup Manager
4. Aktifkan SUB-GUARD

**Generic Android:**
1. Buka Settings → Apps → SUB-GUARD
2. Pilih "Battery" → "Battery optimization"
3. Pilih "All apps" dan cari SUB-GUARD
4. Pilih "Don't optimize"

### State Management with Riverpod

```dart
// Subscription list provider
final subscriptionListProvider = StateNotifierProvider<SubscriptionListNotifier, List<Subscription>>((ref) {
  return SubscriptionListNotifier(ref.read(subscriptionRepositoryProvider));
});

// Total cost provider
final totalCostProvider = Provider<double>((ref) {
  final subscriptions = ref.watch(subscriptionListProvider);
  final settings = ref.watch(userSettingsProvider);
  return ref.read(costCalculatorProvider).calculateMonthlyTotal(
    subscriptions,
    settings.baseCurrency,
  );
});

// Upcoming bills provider (next 30 days)
final upcomingBillsProvider = Provider<List<Subscription>>((ref) {
  final subscriptions = ref.watch(subscriptionListProvider);
  final now = DateTime.now();
  final thirtyDaysLater = now.add(Duration(days: 30));
  
  return subscriptions
      .where((s) => s.nextBillingDate.isBefore(thirtyDaysLater) && s.isActive)
      .toList()
    ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
});
```

### Preset Services Data

Store preset services as a const list:
```dart
const List<PresetService> presetServices = [
  PresetService(
    name: 'Netflix',
    logoAssetPath: 'assets/logos/netflix.png',
    colorHex: '#E50914',
    defaultCurrency: 'USD',
    suggestedPrice: 15.49,
  ),
  PresetService(
    name: 'Spotify',
    logoAssetPath: 'assets/logos/spotify.png',
    colorHex: '#1DB954',
    defaultCurrency: 'USD',
    suggestedPrice: 9.99,
  ),
  // ... more presets
];
```

## Performance Considerations

### Database Optimization
- Use Hive lazy boxes for large datasets
- Index subscriptions by nextBillingDate for calendar queries
- Batch write operations when importing backups

### Notification Scheduling Optimization
- Schedule only next 4 notifications per subscription (not all future ones)
- Reschedule next batch after each billing cycle completes
- Use unique alarm IDs based on subscription ID and reminder day

### UI Performance
- Use ListView.builder for subscription lists
- Cache preset service logos in memory
- Lazy load calendar dates (only current month + 1)

### Memory Management
- Dispose controllers and listeners properly
- Use const constructors where possible
- Avoid rebuilding entire widget tree on state changes

## Security Considerations

### Data Privacy
- All data stored locally on device (no cloud sync)
- No network requests for subscription data
- Backup files stored in app-private directory by default

### Sensitive Information
- Payment method stored as string (e.g., "Visa ending in 1234")
- No storage of full credit card numbers
- No storage of passwords or authentication tokens

### Permissions
- Request permissions with clear explanations
- Gracefully degrade if permissions denied
- Don't block core functionality if optional permissions denied
