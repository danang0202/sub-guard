import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_scheduler.dart';
import '../services/cost_calculator.dart';
import '../services/subscription_manager.dart';
import '../services/backup_manager.dart';
import '../services/alarm_manager_service.dart';
import '../services/battery_optimization_detector.dart';
import 'repository_providers.dart';
import 'computed_providers.dart';

/// Provider for AlarmManagerService
/// Provides access to Android alarm scheduling
final alarmManagerServiceProvider = Provider<AlarmManagerService>((ref) {
  return AlarmManagerService();
});

/// Provider for NotificationScheduler
/// Provides notification scheduling functionality
/// Automatically recreates when notification config changes
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final alarmManager = ref.watch(alarmManagerServiceProvider);
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  final userSettings = ref.watch(userSettingsProvider);

  return NotificationScheduler(
    alarmManager: alarmManager,
    subscriptionRepository: subscriptionRepository,
    notificationConfig: userSettings.notificationConfig,
  );
});

/// Provider for CostCalculator
/// Provides cost calculation and currency conversion functionality
final costCalculatorProvider = Provider<CostCalculator>((ref) {
  return CostCalculator();
});

/// Provider for SubscriptionManager
/// Provides subscription lifecycle management
final subscriptionManagerProvider = Provider<SubscriptionManager>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  final notificationScheduler = ref.watch(notificationSchedulerProvider);

  return SubscriptionManager(
    repository: subscriptionRepository,
    notificationScheduler: notificationScheduler,
  );
});

/// Provider for BackupManager
/// Provides backup and restore functionality
final backupManagerProvider = Provider<BackupManager>((ref) {
  final subscriptionRepository = ref.watch(subscriptionRepositoryProvider);
  final settingsRepository = ref.watch(userSettingsRepositoryProvider);

  return BackupManager(
    subscriptionRepository: subscriptionRepository,
    settingsRepository: settingsRepository,
  );
});

/// Provider for BatteryOptimizationDetector
/// Provides battery optimization detection and guidance
final batteryOptimizationDetectorProvider =
    Provider<BatteryOptimizationDetector>((ref) {
      return BatteryOptimizationDetector();
    });
