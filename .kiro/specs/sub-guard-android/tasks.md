# Implementation Plan

- [x] 1. Set up Flutter project structure and dependencies
  - Initialize Flutter project with proper package name
  - Add dependencies: hive, hive_flutter, flutter_local_notifications, android_alarm_manager_plus, riverpod, intl
  - Configure Android manifest with required permissions
  - Set up notification channels in Android native code
  - _Requirements: 3.5, 4.4, 9.1_

- [x] 2. Implement core data models
  - [x] 2.1 Create Subscription model with Hive type adapter
    - Define Subscription class with all fields (id, serviceName, cost, currency, billingCycle, dates, etc.)
    - Implement toJson/fromJson for backup functionality
    - Create Hive type adapter for local storage
    - _Requirements: 2.1, 2.2, 2.5_

  - [ ]* 2.2 Write property test for subscription persistence round trip
    - **Property 1: Subscription persistence round trip**
    - **Validates: Requirements 2.5**

  - [x] 2.3 Create PresetService model
    - Define PresetService class with name, logo path, color, currency
    - Create const list of popular preset services (Netflix, Spotify, GitHub, ChatGPT, Adobe, etc.)
    - _Requirements: 1.1, 1.2_

  - [ ]* 2.4 Write property test for preset auto-population
    - **Property 10: Preset auto-population completeness**
    - **Validates: Requirements 1.1**

  - [x] 2.5 Create NotificationConfig and UserSettings models
    - Define NotificationConfig with reminder days and alert preferences
    - Define UserSettings with base currency, theme, last backup date
    - Create Hive type adapters for both models
    - _Requirements: 11.1, 11.2_

- [x] 3. Set up local database with Hive
  - [x] 3.1 Initialize Hive and register adapters
    - Initialize Hive in main.dart
    - Register all type adapters
    - Open boxes for subscriptions, settings
    - _Requirements: 2.5_

  - [x] 3.2 Create SubscriptionRepository
    - Implement CRUD operations (add, update, delete, get, getAll)
    - Implement query methods (getByDate, getActive, getUpcoming)
    - Handle Hive box operations with error handling
    - _Requirements: 2.5, 10.2, 10.3_

  - [x] 3.3 Create UserSettingsRepository
    - Implement get and update methods for user settings
    - Provide default settings on first launch
    - _Requirements: 11.5_

- [x] 4. Implement notification scheduling system
  - [x] 4.1 Create AlarmManagerService
    - Implement alarm scheduling using android_alarm_manager_plus
    - Create static callback function for alarm triggers
    - Implement alarm cancellation and rescheduling
    - Configure exact alarms with wakeup and rescheduleOnReboot
    - _Requirements: 3.5, 9.1, 9.2_

  - [x] 4.2 Create NotificationScheduler service
    - Implement scheduleNotificationsForSubscription (creates 4 alarms: -7, -3, -1, 0 days)
    - Implement cancelNotificationsForSubscription
    - Implement rescheduleAllNotifications
    - Generate unique alarm IDs based on subscription ID and reminder day
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [ ]* 4.3 Write property test for notification scheduling completeness
    - **Property 2: Notification scheduling completeness**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4**

  - [x] 4.4 Implement notification display logic
    - Create function to show standard notifications (for H-7, H-3)
    - Create function to show intense alerts with full screen intent (for H-1, Day-0)
    - Configure notification actions ("SAYA SUDAH BAYAR", "BATALKAN", "INGATKAN LAGI")
    - _Requirements: 4.1, 4.3_

  - [ ]* 4.5 Write property test for notification rescheduling preservation
    - **Property 5: Notification rescheduling preservation**
    - **Validates: Requirements 9.2**

- [x] 5. Implement business logic services
  - [x] 5.1 Create CostCalculator service
    - Implement calculateMonthlyTotal function
    - Implement normalizeToMonthly for yearly subscriptions (divide by 12)
    - Implement basic currency conversion (can use 1:1 for MVP, or add exchange rates)
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ]* 5.2 Write property tests for cost calculation
    - **Property 3: Cost calculation consistency**
    - **Property 4: Currency normalization**
    - **Validates: Requirements 5.1, 5.2**

  - [x] 5.3 Create SubscriptionManager service
    - Implement addSubscription (save to DB + schedule notifications)
    - Implement updateSubscription (update DB + reschedule notifications)
    - Implement deleteSubscription (remove from DB + cancel notifications)
    - Implement markAsPaid (update next billing date + reschedule)
    - Implement cancelSubscription (set isActive=false + cancel notifications)
    - _Requirements: 10.2, 10.3, 10.4, 10.5_

  - [ ]* 5.4 Write property tests for subscription management
    - **Property 7: Subscription deletion cleanup**
    - **Property 8: Billing date update propagation**
    - **Property 12: Active subscription filtering**
    - **Validates: Requirements 10.3, 10.4, 10.5**

  - [x] 5.5 Create BackupManager service
    - Implement exportToJson (serialize all data to JSON file)
    - Implement importFromJson (deserialize and restore data)
    - Implement validateBackupFile (check JSON structure)
    - Update lastBackupDate in settings after successful backup
    - _Requirements: 7.1, 7.2, 7.4, 7.5_

  - [ ]* 5.6 Write property test for backup and restore round trip
    - **Property 6: Backup and restore round trip**
    - **Validates: Requirements 7.1, 7.2, 7.3**

  - [x] 5.7 Create BatteryOptimizationDetector service
    - Implement getDeviceManufacturer using device_info_plus
    - Implement isBatteryOptimizationEnabled check
    - Create map of manufacturer-specific whitelisting instructions
    - Implement getWhitelistingInstructions function
    - _Requirements: 4.5, 12.1, 12.3, 12.4_

  - [ ]* 5.8 Write property test for manufacturer instructions
    - **Property: Manufacturer instruction completeness**
    - **Validates: Requirements 12.3**

- [x] 6. Set up state management with Riverpod
  - [x] 6.1 Create repository providers
    - Create subscriptionRepositoryProvider
    - Create userSettingsRepositoryProvider
    - Create presetServiceRepositoryProvider
    - _Requirements: All_

  - [x] 6.2 Create service providers
    - Create notificationSchedulerProvider
    - Create costCalculatorProvider
    - Create subscriptionManagerProvider
    - Create backupManagerProvider
    - _Requirements: All_

  - [x] 6.3 Create state notifier for subscription list
    - Implement SubscriptionListNotifier extending StateNotifier
    - Load subscriptions from repository on initialization
    - Provide methods to add, update, delete subscriptions
    - _Requirements: 10.2, 10.3_

  - [x] 6.4 Create computed providers
    - Create totalCostProvider (watches subscription list and calculates total)
    - Create upcomingBillsProvider (filters subscriptions in next 30 days)
    - Create calendarDataProvider (groups subscriptions by billing date)
    - _Requirements: 5.1, 5.4, 6.1_

  - [ ]* 6.5 Write property test for calendar date aggregation
    - **Property 9: Calendar date aggregation**
    - **Validates: Requirements 6.4**

- [x] 7. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Build UI screens and widgets
  - [x] 8.1 Create main app structure
    - Set up MaterialApp with dark theme
    - Configure high contrast color scheme (dark background, neon accents)
    - Set up navigation with bottom navigation bar
    - _Requirements: 8.1_

  - [x] 8.2 Create SubscriptionCard widget
    - Display service logo, name, cost, next billing date
    - Apply brand colors from subscription data
    - Implement color highlighting based on billing proximity (yellow for <7 days, red for <1 day)
    - _Requirements: 8.2, 8.3, 8.4_

  - [x] 8.3 Build Dashboard screen
    - Display total monthly cost card at top
    - Show list of upcoming subscriptions using SubscriptionCard
    - Connect to totalCostProvider and upcomingBillsProvider
    - _Requirements: 5.1, 5.5_

  - [x] 8.4 Build Calendar screen
    - Implement month calendar view using table_calendar or custom widget
    - Highlight dates with subscriptions using warning/critical colors
    - Show subscription list when date is tapped
    - Connect to calendarDataProvider
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

  - [x] 8.5 Build Add/Edit Subscription screen
    - Create preset service selector (grid of service cards with logos)
    - Create manual entry form for custom subscriptions
    - Implement form validation (require billing cycle, next billing date)
    - Add billing cycle toggle (monthly/yearly)
    - Add date picker for next billing date
    - Add payment method input field
    - Implement save functionality using SubscriptionManager
    - _Requirements: 1.1, 1.2, 1.4, 2.1, 2.2, 2.4_

  - [x] 8.6 Build Subscription Detail screen
    - Display full subscription information
    - Add edit and delete buttons
    - Add "Mark as Paid" button
    - Add "Cancel Subscription" button
    - Implement actions using SubscriptionManager
    - _Requirements: 10.1, 10.4, 10.5_

  - [x] 8.7 Build Settings screen
    - Add notification preferences section (enable/disable Intense Alert, customize reminder days)
    - Add base currency selector
    - Add theme toggle (if not using Material You)
    - Add backup button (triggers BackupManager.exportToJson)
    - Add restore button (triggers file picker and BackupManager.importFromJson)
    - Display battery optimization status and whitelisting guide
    - _Requirements: 11.1, 11.2, 7.1, 7.2, 4.5, 12.2_

  - [x] 8.8 Create Intense Alert full screen activity
    - Design full screen layout with red gradient background
    - Display service logo and name prominently
    - Show warning message with cost
    - Add large action buttons ("SAYA SUDAH BAYAR", "BATALKAN", "INGATKAN LAGI")
    - Implement button actions (mark as paid, cancel subscription, snooze)
    - _Requirements: 4.1, 4.2, 4.3_

- [x] 9. Implement notification settings propagation
  - [x] 9.1 Add settings change handler
    - Listen to notification settings changes
    - Trigger rescheduleAllNotifications when settings change
    - Update notification types based on Intense Alert mode setting
    - _Requirements: 11.3, 11.4, 11.5_

  - [ ]* 9.2 Write property test for notification settings propagation
    - **Property 11: Notification settings propagation**
    - **Validates: Requirements 11.5**

- [x] 10. Add boot receiver for notification rescheduling
  - [x] 10.1 Create BootReceiver in Android native code
    - Implement BroadcastReceiver for BOOT_COMPLETED
    - Trigger rescheduleAllNotifications on device restart
    - _Requirements: 9.2_

- [x] 11. Implement battery optimization guidance
  - [x] 11.1 Create battery optimization check on app launch
    - Check if battery optimization is enabled
    - Show warning dialog if enabled
    - Display manufacturer-specific instructions
    - Provide button to open battery settings
    - _Requirements: 4.5, 12.2, 12.3_

- [-] 12. Add error handling and edge cases
  - [x] 12.1 Add database error handling
    - Wrap Hive operations in try-catch
    - Show user-friendly error messages
    - Implement retry logic for write failures
    - _Requirements: All_

  - [x] 12.2 Add notification permission handling
    - Request notification permissions on Android 13+
    - Request SCHEDULE_EXACT_ALARM permission
    - Request USE_FULL_SCREEN_INTENT permission
    - Show explanation dialogs for denied permissions
    - _Requirements: 3.5, 4.1_

  - [x] 12.3 Add backup/restore error handling
    - Validate JSON structure before importing
    - Show specific error messages for invalid files
    - Handle file not found errors
    - Request storage permissions if needed
    - _Requirements: 7.4_

- [x] 13. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
