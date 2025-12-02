# Boot Receiver Implementation

## Overview

The Boot Receiver ensures that all subscription notifications are rescheduled when the device restarts. This is critical for SUB-GUARD's reliability, as Android clears all scheduled alarms when the device reboots.

## Architecture

### Components

1. **BootReceiver.kt** (Native Android)
   - Location: `android/app/src/main/kotlin/com/subguard/sub_guard_android/BootReceiver.kt`
   - Listens for `BOOT_COMPLETED` and `LOCKED_BOOT_COMPLETED` intents
   - Triggers the alarm rescheduling process through AlarmService

2. **BootHandler** (Dart)
   - Location: `lib/services/boot_handler.dart`
   - Provides the `bootCallback()` static method
   - Initializes Hive, repositories, and reschedules all notifications

3. **AndroidManifest.xml**
   - Registers the BootReceiver with appropriate intent filters
   - Includes `directBootAware="true"` for early boot support

## How It Works

1. **Device Boots**: Android system broadcasts `BOOT_COMPLETED` intent
2. **BootReceiver Triggered**: The native BootReceiver catches the broadcast
3. **AlarmService Enqueued**: BootReceiver enqueues work through AlarmService
4. **Dart Callback Executed**: The `bootCallback()` method runs in a background isolate
5. **Notifications Rescheduled**: All active subscriptions get their notifications rescheduled

## Key Features

- **Direct Boot Aware**: Works even before the device is unlocked
- **Background Execution**: Runs in a background isolate without launching the app
- **Reliable**: Uses android_alarm_manager_plus's proven infrastructure
- **Error Handling**: Logs errors but doesn't crash if rescheduling fails

## Requirements Validated

- **Requirement 9.2**: "WHEN the device restarts THEN the SUB-GUARD System SHALL reschedule all pending notifications automatically"

## Testing

To test the boot receiver:

1. Add some subscriptions with upcoming billing dates
2. Restart the device
3. Check logs for "Boot callback triggered, rescheduling notifications"
4. Verify that notifications still fire at the expected times

## Permissions Required

- `RECEIVE_BOOT_COMPLETED`: Required to receive boot broadcasts
- `WAKE_LOCK`: Required to keep the device awake during rescheduling

## Notes

- The boot callback runs in a background isolate, so it has its own Hive instance
- All Hive adapters must be registered again in the callback
- The callback should complete quickly to avoid ANR (Application Not Responding) errors
