# Permission Handling in SUB-GUARD

## Overview

SUB-GUARD requires several Android permissions to function properly. This document explains the permission handling implementation and how it ensures reliable notification delivery.

## Required Permissions

### 1. POST_NOTIFICATIONS (Android 13+)
- **Purpose**: Display notifications to the user
- **Required for**: All notification features
- **Requested**: On app startup and in Settings screen
- **Fallback**: App cannot send notifications if denied

### 2. SCHEDULE_EXACT_ALARM (Android 12+)
- **Purpose**: Schedule alarms at exact times
- **Required for**: Precise notification timing
- **Requested**: On app startup and in Settings screen
- **Fallback**: Notifications may be delayed if denied

### 3. USE_FULL_SCREEN_INTENT
- **Purpose**: Display full-screen notifications when device is locked
- **Required for**: Intense Alert mode (H-1 and Day-0 notifications)
- **Granted**: Automatically via AndroidManifest.xml
- **Fallback**: Standard notifications if not available

### 4. Additional Permissions (Manifest Only)
- `VIBRATE`: Allow notifications to vibrate
- `WAKE_LOCK`: Wake device for notifications
- `RECEIVE_BOOT_COMPLETED`: Reschedule notifications after device restart
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: Request battery optimization exemption

## Implementation

### PermissionHandler Service

The `PermissionHandler` service (`lib/services/permission_handler.dart`) provides:

1. **Permission Checking**
   - `checkNotificationPermission()`: Check if notifications are enabled
   - `checkExactAlarmPermission()`: Check if exact alarms can be scheduled
   - `checkFullScreenIntentPermission()`: Check if full screen intents are available
   - `checkAllPermissions()`: Check all permissions at once

2. **Permission Requesting**
   - `requestNotificationPermission()`: Request notification permission
   - `requestExactAlarmPermission()`: Request exact alarm permission
   - `requestAllPermissions(context)`: Request all permissions with user-friendly dialogs

3. **User Experience**
   - Shows explanation dialogs before requesting permissions
   - Shows denial dialogs with instructions if permissions are denied
   - Tracks whether permissions have been requested before
   - Provides different messaging for first-time vs. repeat requests

### Integration Points

#### 1. App Startup (main.dart)
```dart
// Automatically request permissions on first launch
WidgetsBinding.instance.addPostFrameCallback((_) {
  _requestPermissions();
});
```

#### 2. Settings Screen
```dart
// Manual permission check and request
ListTile(
  title: const Text('Request Permissions'),
  onTap: () => _requestPermissions(permissionHandler),
)
```

#### 3. Permission Status Display
The Settings screen shows real-time permission status:
- ✅ Green check: Permission granted
- ⚠️ Yellow warning: Permission not granted
- ℹ️ Blue info: Permission configured via manifest

## User Flow

### First Launch
1. App starts and initializes
2. Permission handler checks current status
3. If permissions not granted:
   - Shows explanation dialog for notification permission
   - User taps "Continue" → System permission dialog appears
   - Shows explanation dialog for exact alarm permission
   - User taps "Continue" → System permission dialog appears
   - Shows info dialog about full screen intents
4. Success message displayed if all granted

### Subsequent Launches
- If permissions already granted: No dialogs shown
- If permissions denied: User can manually request in Settings

### Permission Denial
If user denies permissions:
1. Denial dialog shown with instructions
2. User can go to Settings → Apps → SUB-GUARD → Permissions
3. User can manually enable permissions
4. App will detect permission changes on next launch

## Testing

### Unit Tests
Located in `test/services/permission_handler_test.dart`:
- Singleton pattern verification
- Enum value verification
- Full screen intent permission check

### Manual Testing Checklist
- [ ] First launch shows permission dialogs
- [ ] Granting all permissions shows success message
- [ ] Denying notification permission shows denial dialog
- [ ] Denying exact alarm permission shows denial dialog
- [ ] Settings screen shows correct permission status
- [ ] "Request Permissions" button in Settings works
- [ ] Permissions persist after app restart
- [ ] Notifications work after granting permissions

## Troubleshooting

### Notifications Not Appearing
1. Check Settings → Permissions section
2. Verify all permissions are granted (green checkmarks)
3. If denied, tap "Request Permissions" to request again
4. If still denied, manually enable in Android Settings

### Exact Alarms Not Working
1. Android 12+ requires explicit permission
2. Check Settings → Permissions → Exact Alarm Permission
3. If denied, user must enable "Alarms & reminders" in Android Settings

### Full Screen Intents Not Showing
1. Verify USE_FULL_SCREEN_INTENT is in AndroidManifest.xml
2. Check if device manufacturer restricts full screen intents
3. Verify battery optimization is disabled (see Battery Optimization Guide)

## Best Practices

1. **Request Permissions Contextually**
   - Explain why each permission is needed
   - Request at appropriate times (not all at once if possible)
   - Provide clear instructions for denied permissions

2. **Handle Denial Gracefully**
   - Don't block app functionality completely
   - Provide alternative flows when possible
   - Guide users to Settings if needed

3. **Respect User Choice**
   - Don't repeatedly request denied permissions
   - Track permission request history
   - Allow users to manually request later

4. **Test on Multiple Devices**
   - Different Android versions handle permissions differently
   - Manufacturer customizations may affect behavior
   - Test on Android 12, 13, and 14+

## References

- [Android Notification Permission](https://developer.android.com/develop/ui/views/notifications/notification-permission)
- [Schedule Exact Alarms](https://developer.android.com/about/versions/12/behavior-changes-12#exact-alarm-permission)
- [Full Screen Intents](https://developer.android.com/reference/android/app/Notification.Builder#setFullScreenIntent(android.app.PendingIntent,%20boolean))
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
