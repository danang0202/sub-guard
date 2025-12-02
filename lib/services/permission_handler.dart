import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling notification and alarm permissions
/// Manages permission requests for Android 13+ notifications, exact alarms, and full screen intents
class PermissionHandler {
  static final PermissionHandler _instance = PermissionHandler._internal();
  factory PermissionHandler() => _instance;
  PermissionHandler._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Check if all required permissions are granted
  Future<PermissionStatus> checkAllPermissions() async {
    final notificationGranted = await checkNotificationPermission();
    final exactAlarmGranted = await checkExactAlarmPermission();

    if (!notificationGranted) {
      return PermissionStatus.notificationDenied;
    }
    if (!exactAlarmGranted) {
      return PermissionStatus.exactAlarmDenied;
    }

    return PermissionStatus.allGranted;
  }

  /// Check if notification permission is granted (Android 13+)
  Future<bool> checkNotificationPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) return true;

    // On Android 12 and below, notifications are granted by default
    final granted = await androidImplementation.areNotificationsEnabled();
    return granted ?? true;
  }

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> checkExactAlarmPermission() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation == null) return true;

    final granted = await androidImplementation.canScheduleExactNotifications();
    return granted ?? true;
  }

  /// Request notification permission (Android 13+)
  Future<bool> requestNotificationPermission() async {
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

  /// Request full screen intent permission
  /// Note: This is automatically granted if USE_FULL_SCREEN_INTENT is in manifest
  /// But we still need to check if it's available
  Future<bool> checkFullScreenIntentPermission() async {
    // Full screen intent permission is granted via manifest
    // We can't programmatically check it, so we assume it's granted
    // if the manifest includes USE_FULL_SCREEN_INTENT
    return true;
  }

  /// Request all required permissions with user-friendly dialogs
  Future<PermissionRequestResult> requestAllPermissions(
    BuildContext context,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequestedBefore = prefs.getBool('permissions_requested') ?? false;

    // Check current status
    final status = await checkAllPermissions();

    if (status == PermissionStatus.allGranted) {
      return PermissionRequestResult.allGranted;
    }

    // Request notification permission first
    if (!await checkNotificationPermission()) {
      if (context.mounted) {
        final shouldRequest = await _showPermissionExplanationDialog(
          context,
          title: 'Izin Notifikasi Diperlukan',
          message:
              'SUB-GUARD memerlukan izin notifikasi untuk mengingatkan Anda tentang tagihan yang akan datang.\n\n'
              'Tanpa izin ini, Anda tidak akan menerima pengingat penting tentang langganan Anda.',
          icon: Icons.notifications_active,
          hasRequestedBefore: hasRequestedBefore,
        );

        if (!shouldRequest) {
          return PermissionRequestResult.userCancelled;
        }
      }

      final granted = await requestNotificationPermission();

      if (!granted) {
        if (context.mounted) {
          await _showPermissionDeniedDialog(
            context,
            title: 'Izin Notifikasi Ditolak',
            message:
                'SUB-GUARD tidak dapat berfungsi dengan baik tanpa izin notifikasi.\n\n'
                'Silakan aktifkan izin notifikasi di Pengaturan > Aplikasi > SUB-GUARD > Izin.',
          );
        }
        await prefs.setBool('permissions_requested', true);
        return PermissionRequestResult.notificationDenied;
      }
    }

    // Request exact alarm permission
    if (!await checkExactAlarmPermission()) {
      if (context.mounted) {
        final shouldRequest = await _showPermissionExplanationDialog(
          context,
          title: 'Izin Alarm Tepat Diperlukan',
          message:
              'SUB-GUARD memerlukan izin untuk menjadwalkan alarm tepat waktu.\n\n'
              'Ini memastikan notifikasi muncul tepat pada waktu yang dijadwalkan, '
              'bahkan saat perangkat dalam mode hemat baterai.',
          icon: Icons.alarm,
          hasRequestedBefore: hasRequestedBefore,
        );

        if (!shouldRequest) {
          return PermissionRequestResult.userCancelled;
        }
      }

      final granted = await requestExactAlarmPermission();

      if (!granted) {
        if (context.mounted) {
          await _showPermissionDeniedDialog(
            context,
            title: 'Izin Alarm Ditolak',
            message:
                'Tanpa izin alarm tepat, notifikasi mungkin tidak muncul tepat waktu.\n\n'
                'Silakan aktifkan "Alarms & reminders" di Pengaturan > Aplikasi > SUB-GUARD > Izin.',
          );
        }
        await prefs.setBool('permissions_requested', true);
        return PermissionRequestResult.exactAlarmDenied;
      }
    }

    // Show full screen intent explanation
    if (context.mounted) {
      await _showFullScreenIntentInfo(context);
    }

    await prefs.setBool('permissions_requested', true);
    return PermissionRequestResult.allGranted;
  }

  /// Show permission explanation dialog before requesting
  Future<bool> _showPermissionExplanationDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required bool hasRequestedBefore,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          if (hasRequestedBefore)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Nanti Saja'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show permission denied dialog with instructions
  Future<void> _showPermissionDeniedDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  /// Show full screen intent information
  Future<void> _showFullScreenIntentInfo(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(
              Icons.phone_android,
              color: Theme.of(context).colorScheme.secondary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Notifikasi Layar Penuh',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'SUB-GUARD akan menampilkan notifikasi layar penuh untuk tagihan penting (H-1 dan hari tagihan).\n\n'
          'Notifikasi ini akan muncul bahkan saat layar terkunci untuk memastikan Anda tidak melewatkan tagihan penting.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  /// Check if user has permanently denied permissions
  Future<bool> hasUserPermanentlyDeniedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequestedBefore = prefs.getBool('permissions_requested') ?? false;

    if (!hasRequestedBefore) return false;

    final status = await checkAllPermissions();
    return status != PermissionStatus.allGranted;
  }
}

/// Permission status enum
enum PermissionStatus {
  allGranted,
  notificationDenied,
  exactAlarmDenied,
  fullScreenIntentDenied,
}

/// Permission request result enum
enum PermissionRequestResult {
  allGranted,
  notificationDenied,
  exactAlarmDenied,
  userCancelled,
}
