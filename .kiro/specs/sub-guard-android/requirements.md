# Requirements Document

## Introduction

SUB-GUARD adalah aplikasi mobile Android yang dirancang untuk membantu pengguna melacak dan mengelola langganan digital mereka. Aplikasi ini berfokus pada pencegahan "Ghost Billing" (pemotongan dana otomatis yang tidak disadari) melalui sistem notifikasi intensif yang dapat menembus mode doze/sleep Android. Target pengguna adalah power user dan freelancer yang memiliki banyak langganan SaaS atau layanan hiburan.

## Glossary

- **SUB-GUARD System**: Sistem aplikasi mobile Android untuk tracking langganan digital
- **Subscription**: Langganan digital yang memiliki biaya berulang (bulanan/tahunan)
- **Ghost Billing**: Pemotongan dana otomatis dari langganan yang tidak disadari pengguna
- **Intense Alert**: Notifikasi prioritas tinggi yang menggunakan full screen intent Android
- **Preset Service**: Template layanan populer dengan logo dan warna brand yang sudah terdefinisi
- **Billing Cycle**: Siklus pembayaran langganan (bulanan atau tahunan)
- **Full Screen Intent**: Fitur Android native yang menampilkan notifikasi layar penuh
- **Alarm Manager**: Komponen sistem Android untuk menjadwalkan eksekusi kode di level OS
- **Doze Mode**: Mode hemat baterai Android yang membatasi aktivitas background aplikasi
- **Battery Optimization**: Fitur Android yang membatasi aktivitas background untuk menghemat baterai
- **Notification Channel**: Saluran notifikasi Android dengan prioritas dan pengaturan spesifik
- **Hive Database**: Database NoSQL lokal untuk penyimpanan data di perangkat Android
- **Material You**: Sistem desain dinamis Android 12+ yang menyesuaikan dengan tema sistem

## Requirements

### Requirement 1

**User Story:** As a user, I want to add new subscriptions quickly using preset templates, so that I can save time and avoid manual data entry.

#### Acceptance Criteria

1. WHEN a user selects a preset service from the list THEN the SUB-GUARD System SHALL auto-populate the service name, logo, brand color, and default currency
2. WHEN a user views the preset service list THEN the SUB-GUARD System SHALL display popular services including Netflix, Spotify, GitHub, ChatGPT, and Adobe
3. WHEN a user selects a preset service THEN the SUB-GUARD System SHALL allow the user to modify the auto-populated billing amount
4. WHEN a user needs a service not in presets THEN the SUB-GUARD System SHALL provide a custom manual entry option
5. WHERE a custom subscription is created, the SUB-GUARD System SHALL allow the user to upload a custom icon or select a custom card color

### Requirement 2

**User Story:** As a user, I want to specify subscription details accurately, so that I can track my billing cycles correctly.

#### Acceptance Criteria

1. WHEN a user creates a subscription THEN the SUB-GUARD System SHALL require the user to specify the billing cycle as monthly or yearly
2. WHEN a user creates a subscription THEN the SUB-GUARD System SHALL require the user to specify the next billing date
3. WHEN a user creates a subscription THEN the SUB-GUARD System SHALL allow the user to mark whether the subscription has auto-renewal enabled
4. WHEN a user creates a subscription THEN the SUB-GUARD System SHALL allow the user to specify the payment method
5. WHEN a user saves a subscription THEN the SUB-GUARD System SHALL persist the subscription data to the Hive Database immediately

### Requirement 3

**User Story:** As a user, I want to receive timely reminders before billing dates, so that I can decide whether to continue or cancel subscriptions.

#### Acceptance Criteria

1. WHEN a subscription billing date is 7 days away THEN the SUB-GUARD System SHALL send a standard Android notification to the user
2. WHEN a subscription billing date is 3 days away THEN the SUB-GUARD System SHALL send a standard Android notification to the user
3. WHEN a subscription billing date is 1 day away THEN the SUB-GUARD System SHALL send an Intense Alert notification to the user
4. WHEN a subscription billing date arrives THEN the SUB-GUARD System SHALL send an Intense Alert notification to the user
5. WHILE the device is in Doze Mode, the SUB-GUARD System SHALL ensure notifications are delivered using Alarm Manager

### Requirement 4

**User Story:** As a user, I want critical billing reminders to be impossible to miss, so that I never experience unwanted charges.

#### Acceptance Criteria

1. WHEN an Intense Alert is triggered THEN the SUB-GUARD System SHALL display a full screen intent that takes over the device screen
2. WHEN an Intense Alert is displayed THEN the SUB-GUARD System SHALL show the alert even when the device is locked
3. WHEN an Intense Alert is displayed THEN the SUB-GUARD System SHALL include prominent action buttons labeled "SAYA SUDAH BAYAR" and "BATALKAN"
4. WHEN an Intense Alert is triggered THEN the SUB-GUARD System SHALL play a custom alarm sound through a high-priority Notification Channel
5. WHERE Battery Optimization is enabled for the app, the SUB-GUARD System SHALL detect the device manufacturer and display specific whitelisting instructions

### Requirement 5

**User Story:** As a user, I want to see my total subscription costs, so that I can understand my monthly financial commitments.

#### Acceptance Criteria

1. WHEN a user views the dashboard THEN the SUB-GUARD System SHALL calculate and display the total monthly cost across all subscriptions
2. WHEN subscriptions have different billing cycles THEN the SUB-GUARD System SHALL normalize yearly subscriptions to monthly equivalents for the total calculation
3. WHEN subscriptions use different currencies THEN the SUB-GUARD System SHALL convert all costs to the user's base currency for the total calculation
4. WHEN a user adds or removes a subscription THEN the SUB-GUARD System SHALL update the total cost calculation immediately
5. WHEN a user views the dashboard THEN the SUB-GUARD System SHALL display the total cost in the user's configured base currency

### Requirement 6

**User Story:** As a user, I want to view my billing dates in a calendar format, so that I can visualize when charges will occur.

#### Acceptance Criteria

1. WHEN a user opens the calendar view THEN the SUB-GUARD System SHALL display all subscription billing dates on a visual calendar
2. WHEN a billing date is within 7 days THEN the SUB-GUARD System SHALL highlight that date with a warning color
3. WHEN a billing date is within 1 day THEN the SUB-GUARD System SHALL highlight that date with a critical color
4. WHEN a user taps a date on the calendar THEN the SUB-GUARD System SHALL display all subscriptions due on that date
5. WHEN multiple subscriptions share the same billing date THEN the SUB-GUARD System SHALL display all of them on that calendar date

### Requirement 7

**User Story:** As a user, I want to backup and restore my subscription data locally, so that I can protect my data and transfer it between devices.

#### Acceptance Criteria

1. WHEN a user initiates a backup THEN the SUB-GUARD System SHALL export all subscription data to a JSON file in the device's internal storage
2. WHEN a user initiates a restore THEN the SUB-GUARD System SHALL import subscription data from a selected JSON file
3. WHEN a backup is created THEN the SUB-GUARD System SHALL include all subscription details, notification settings, and user preferences
4. WHEN a restore is performed THEN the SUB-GUARD System SHALL validate the JSON file format before importing
5. WHEN a backup is successfully created THEN the SUB-GUARD System SHALL update the lastBackupDate in user settings

### Requirement 8

**User Story:** As a user, I want the app to use high contrast design, so that I can quickly identify critical information at a glance.

#### Acceptance Criteria

1. WHEN a user views the app THEN the SUB-GUARD System SHALL use a dark background with neon-colored text and icons
2. WHEN a subscription is within 7 days of billing THEN the SUB-GUARD System SHALL display that subscription with yellow highlighting
3. WHEN a subscription is within 1 day of billing THEN the SUB-GUARD System SHALL display that subscription with red highlighting
4. WHEN displaying preset services THEN the SUB-GUARD System SHALL use the service's brand colors for easy recognition
5. WHERE the device runs Android 12 or higher, the SUB-GUARD System SHALL support Material You dynamic theming

### Requirement 9

**User Story:** As a user, I want notifications to work reliably even when the app is closed, so that I never miss important billing reminders.

#### Acceptance Criteria

1. WHEN the app is force-closed by the user THEN the SUB-GUARD System SHALL continue to trigger scheduled notifications using Alarm Manager
2. WHEN the device restarts THEN the SUB-GUARD System SHALL reschedule all pending notifications automatically
3. WHEN a notification is scheduled THEN the SUB-GUARD System SHALL use Android Alarm Manager to ensure OS-level execution
4. WHEN the app is in background THEN the SUB-GUARD System SHALL not rely on app-level processes for notification delivery
5. WHILE Battery Optimization is active, the SUB-GUARD System SHALL use Alarm Manager to bypass doze mode restrictions

### Requirement 10

**User Story:** As a user, I want to manage my subscriptions easily, so that I can update or delete them as needed.

#### Acceptance Criteria

1. WHEN a user views a subscription THEN the SUB-GUARD System SHALL provide options to edit or delete the subscription
2. WHEN a user edits a subscription THEN the SUB-GUARD System SHALL update the stored data and reschedule notifications accordingly
3. WHEN a user deletes a subscription THEN the SUB-GUARD System SHALL remove all associated data and cancel scheduled notifications
4. WHEN a user marks a subscription as paid THEN the SUB-GUARD System SHALL update the next billing date based on the billing cycle
5. WHEN a user cancels a subscription THEN the SUB-GUARD System SHALL stop all future notifications for that subscription

### Requirement 11

**User Story:** As a user, I want to configure notification preferences, so that I can customize how and when I receive alerts.

#### Acceptance Criteria

1. WHEN a user accesses notification settings THEN the SUB-GUARD System SHALL allow the user to enable or disable Intense Alert mode
2. WHEN a user accesses notification settings THEN the SUB-GUARD System SHALL allow the user to customize reminder days
3. WHEN a user disables Intense Alert mode THEN the SUB-GUARD System SHALL use standard notifications for all reminders
4. WHEN a user enables Intense Alert mode THEN the SUB-GUARD System SHALL use full screen intents for critical reminders
5. WHEN a user changes notification settings THEN the SUB-GUARD System SHALL apply the changes to all future scheduled notifications

### Requirement 12

**User Story:** As a user, I want the app to guide me through battery optimization settings, so that I can ensure notifications work reliably on my device.

#### Acceptance Criteria

1. WHEN the app first launches THEN the SUB-GUARD System SHALL detect the device manufacturer
2. WHEN Battery Optimization is enabled for the app THEN the SUB-GUARD System SHALL display a warning to the user
3. WHEN the user views the battery optimization warning THEN the SUB-GUARD System SHALL provide manufacturer-specific instructions for whitelisting
4. WHEN the device is a Xiaomi device THEN the SUB-GUARD System SHALL display Xiaomi-specific battery optimization instructions
5. WHEN the device is a Samsung, Oppo, or other manufacturer THEN the SUB-GUARD System SHALL display appropriate manufacturer-specific instructions
