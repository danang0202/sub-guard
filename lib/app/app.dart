import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import '../screens/main_navigation_screen.dart';
import '../services/permission_handler.dart';
import '../providers/service_providers.dart';
import '../core/constants/app_colors.dart';
import '../widgets/dialogs/dialogs.dart';

/// Main application widget for SUB-GUARD.
///
/// Handles app-level configuration including theme setup,
/// permission requests, and battery optimization checks.
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Minimal initialization - only schedule background tasks
    // Heavy operations deferred to prevent blocking main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay background tasks to let UI render first
      // Increased to 5 seconds to ensure UI is fully stable
      Future.delayed(const Duration(seconds: 5), () async {
        if (!mounted) return;
        _initializeBackgroundTasks();
      });
    });
  }

  /// Run background initialization tasks without blocking the main thread
  /// NotificationSettingsHandler removed - will be initialized later if needed
  Future<void> _initializeBackgroundTasks() async {
    // Run these operations in parallel but don't await them together
    // This prevents blocking the UI thread
    Future.microtask(() async {
      try {
        await _requestPermissions();
      } catch (e) {
        debugPrint('Permission request failed: $e');
      }
    });

    Future.microtask(() async {
      try {
        await _checkBatteryOptimization();
      } catch (e) {
        debugPrint('Battery optimization check failed: $e');
      }
    });
  }

  /// Request all required permissions on app startup
  Future<void> _requestPermissions() async {
    try {
      final permissionHandler = PermissionHandler();

      // Check if permissions are already granted
      final status = await permissionHandler.checkAllPermissions();

      if (status == PermissionStatus.allGranted) {
        // All permissions granted, no need to show dialogs
        return;
      }

      // Request permissions with explanation dialogs
      if (mounted) {
        final result = await permissionHandler.requestAllPermissions(context);

        if (result == PermissionRequestResult.allGranted) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Semua izin telah diberikan. SUB-GUARD siap digunakan!',
                ),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Silently fail - don't block app launch if permission check fails
      debugPrint('Failed to request permissions: $e');
    }
  }

  /// Check battery optimization status and show warning dialog if enabled
  Future<void> _checkBatteryOptimization() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasShownWarning =
          prefs.getBool('battery_optimization_warning_shown') ?? false;

      // Only check on first launch or if user hasn't dismissed the warning
      if (!hasShownWarning) {
        final detector = ref.read(batteryOptimizationDetectorProvider);
        final isOptimizationEnabled = await detector
            .isBatteryOptimizationEnabled();

        if (isOptimizationEnabled && mounted) {
          final manufacturer = await detector.getDeviceManufacturer();
          final instructions = detector.getWhitelistingInstructions(
            manufacturer,
          );
          final deviceModel = await detector.getDeviceModel();

          // Show warning dialog
          if (mounted) {
            _showBatteryOptimizationDialog(
              manufacturer: manufacturer,
              instructions: instructions,
              deviceModel: deviceModel,
            );
          }
        }
      }
    } catch (e) {
      // Silently fail - don't block app launch if detection fails
      debugPrint('Failed to check battery optimization: $e');
    }
  }

  /// Show battery optimization warning dialog
  void _showBatteryOptimizationDialog({
    required String manufacturer,
    required String instructions,
    required String deviceModel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BatteryOptimizationDialog(
        manufacturer: manufacturer,
        instructions: instructions,
        deviceModel: deviceModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subs Guard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode
      home: const MainNavigationScreen(),
    );
  }
}
