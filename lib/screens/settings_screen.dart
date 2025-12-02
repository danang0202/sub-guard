import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/exceptions/app_exceptions.dart';
import '../core/utils/error_handler.dart';
import '../models/notification_config.dart';
import '../models/user_settings.dart';
import '../providers/providers.dart';
import '../services/backup_manager.dart';
import '../services/permission_handler.dart';
import '../widgets/settings/settings_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final backupManager = ref.watch(backupManagerProvider);
    final batteryDetector = ref.watch(batteryOptimizationDetectorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SectionHeader(title: 'Notification Preferences'),
                NotificationSettingsSection(
                  settings: settings,
                  onConfigChanged: _updateNotificationConfig,
                  onReminderDaysTap: () =>
                      _showReminderDaysDialog(settings.notificationConfig),
                ),
                const Divider(height: 32),
                const SectionHeader(title: 'Currency'),
                _buildCurrencySettings(settings),
                const Divider(height: 32),
                const SectionHeader(title: 'Appearance'),
                ThemeSettingsSection(
                  settings: settings,
                  onThemeChanged: _updateThemeMode,
                ),
                const Divider(height: 32),
                const SectionHeader(title: 'Backup & Restore'),
                BackupSection(
                  settings: settings,
                  onCreateBackup: () => _createBackup(backupManager),
                  onRestoreBackup: () => _restoreBackup(backupManager),
                ),
                const Divider(height: 32),
                const SectionHeader(title: 'Permissions'),
                PermissionsSection(onRequestPermissions: _requestPermissions),
                const Divider(height: 32),
                const SectionHeader(title: 'Battery Optimization'),
                BatteryOptimizationSection(
                  detector: batteryDetector,
                  onShowGuide: () => _showWhitelistingGuide(batteryDetector),
                ),
                const Divider(height: 32),
                const SectionHeader(title: 'About'),
                AboutSection(onAboutTap: _showAboutDialog),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildCurrencySettings(UserSettings settings) {
    return ListTile(
      title: const Text('Base Currency'),
      subtitle: Text(settings.baseCurrency),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCurrencyDialog(settings.baseCurrency),
    );
  }

  // ============ Action Methods ============

  Future<void> _updateNotificationConfig(NotificationConfig config) async {
    try {
      await ref
          .read(userSettingsNotifierProvider.notifier)
          .updateNotificationConfig(config);

      if (mounted) {
        ErrorHandler.showSuccess(context, 'Notification settings updated');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handle(
          context,
          ServiceException(
            message: 'Failed to update notification config: $e',
            userFriendlyMessage: 'Failed to update notification settings',
            originalError: e,
          ),
        );
      }
    }
  }

  Future<void> _updateThemeMode(AppThemeMode themeMode) async {
    try {
      await ref
          .read(userSettingsNotifierProvider.notifier)
          .updateThemeMode(themeMode);

      if (mounted) {
        ErrorHandler.showSuccess(context, 'Theme updated');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handle(
          context,
          ServiceException(
            message: 'Failed to update theme: $e',
            userFriendlyMessage: 'Failed to update theme',
            originalError: e,
          ),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final permissionHandler = PermissionHandler();
      final result = await permissionHandler.requestAllPermissions(context);

      if (!mounted) return;

      switch (result) {
        case PermissionRequestResult.allGranted:
          ErrorHandler.showSuccess(context, 'All permissions granted!');
          setState(() {});
          break;
        case PermissionRequestResult.notificationDenied:
          ErrorHandler.showError(
            context,
            PermissionException(
              message: 'Notification permission denied',
              userFriendlyMessage: 'Notification permission denied',
              permissionName: 'notification',
            ),
          );
          break;
        case PermissionRequestResult.exactAlarmDenied:
          ErrorHandler.showError(
            context,
            PermissionException(
              message: 'Exact alarm permission denied',
              userFriendlyMessage: 'Exact alarm permission denied',
              permissionName: 'exact_alarm',
            ),
          );
          break;
        case PermissionRequestResult.userCancelled:
          ErrorHandler.showWarning(context, 'Permission request cancelled');
          break;
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handle(
          context,
          PermissionException(
            message: 'Error requesting permissions: $e',
            userFriendlyMessage: 'Failed to request permissions',
          ),
        );
      }
    }
  }

  // ============ Dialog Methods ============

  Future<void> _showCurrencyDialog(String currentCurrency) async {
    final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'IDR', 'SGD', 'MYR', 'THB'];

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Base Currency'),
        content: SingleChildScrollView(
          child: RadioGroup<String>(
            groupValue: currentCurrency,
            onChanged: (value) {
              if (value != null) Navigator.pop(context, value);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: currencies.map((currency) {
                return ListTile(
                  leading: Radio<String>(value: currency),
                  title: Text(currency),
                  onTap: () => Navigator.pop(context, currency),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null && selected != currentCurrency) {
      try {
        await ref
            .read(userSettingsNotifierProvider.notifier)
            .updateBaseCurrency(selected);

        if (mounted) {
          ErrorHandler.showSuccess(context, 'Currency updated');
        }
      } catch (e) {
        if (mounted) {
          ErrorHandler.handle(
            context,
            ServiceException(
              message: 'Failed to update currency: $e',
              userFriendlyMessage: 'Failed to update currency',
              originalError: e,
            ),
          );
        }
      }
    }
  }

  Future<void> _showReminderDaysDialog(NotificationConfig config) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Days'),
        content: Text(
          'Current reminder schedule:\n\n'
          '${config.reminderDays.map((d) => '• $d days before billing').join('\n')}\n\n'
          'Customization coming soon!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About SUB-GUARD'),
        content: const Text(
          'SUB-GUARD is a subscription tracking and reminder app designed to help you '
          'manage your digital subscriptions and prevent unwanted charges.\n\n'
          'Features:\n'
          '• Track monthly and yearly subscriptions\n'
          '• Receive timely reminders before billing\n'
          '• View subscriptions in calendar format\n'
          '• Backup and restore your data\n\n'
          'Version 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWhitelistingGuide(dynamic detector) async {
    try {
      final manufacturer = await detector.getDeviceManufacturer();
      final instructions = detector.getWhitelistingInstructions(manufacturer);
      final deviceModel = await detector.getDeviceModel();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Battery Optimization Guide'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Device: $deviceModel',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(instructions),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handle(
          context,
          ServiceException(
            message: 'Failed to get device info: $e',
            userFriendlyMessage: 'Failed to load battery optimization guide',
            originalError: e,
          ),
        );
      }
    }
  }

  // ============ Backup Methods ============

  Future<void> _createBackup(BackupManager backupManager) async {
    setState(() => _isLoading = true);

    try {
      final filePath = await backupManager.exportToJson();

      if (mounted) {
        setState(() => _isLoading = false);
        _showBackupSuccessDialog(filePath);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showBackupErrorDialog(e);
      }
    }
  }

  void _showBackupSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Created'),
        content: Text('Backup saved successfully to:\n\n$filePath'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupErrorDialog(dynamic e) {
    String errorMessage = 'Backup Failed';
    String errorDetails = e.toString();

    if (e is BackupManagerException) {
      switch (e.type) {
        case BackupErrorType.storagePermissionDenied:
          errorMessage = 'Permission Denied';
          errorDetails = 'Storage permission is required to create backups.';
          break;
        case BackupErrorType.writeError:
          errorMessage = 'Write Error';
          errorDetails = 'Failed to write backup file.';
          break;
        case BackupErrorType.parseError:
          errorMessage = 'Serialization Error';
          errorDetails = 'Failed to convert data to JSON format.';
          break;
        default:
          errorDetails = e.message;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(errorMessage),
        content: Text(errorDetails),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBackup(BackupManager backupManager) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Backup File',
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) {
        if (mounted) {
          ErrorHandler.showError(
            context,
            ValidationException(
              message: 'File path is null',
              userFriendlyMessage: 'Failed to get file path',
            ),
          );
        }
        return;
      }

      final confirmed = await _showRestoreConfirmDialog();
      if (confirmed != true) return;

      setState(() => _isLoading = true);

      try {
        await backupManager.importFromJson(filePath);

        if (mounted) {
          setState(() => _isLoading = false);
          ref.invalidate(subscriptionListProvider);
          _showRestoreSuccessDialog();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showRestoreErrorDialog(e);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorHandler.handle(
          context,
          ServiceException(
            message: 'Restore backup failed: $e',
            userFriendlyMessage: 'Failed to restore backup',
            originalError: e,
          ),
        );
      }
    }
  }

  Future<bool?> _showRestoreConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
          'This will replace all your current subscriptions and settings.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showRestoreSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Successful'),
        content: const Text('Your data has been restored successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRestoreErrorDialog(dynamic e) {
    String errorMessage = 'Failed to restore backup';
    String errorDetails = e.toString();

    if (e is BackupManagerException) {
      switch (e.type) {
        case BackupErrorType.fileNotFound:
          errorMessage = 'File Not Found';
          break;
        case BackupErrorType.invalidFormat:
          errorMessage = 'Invalid File Format';
          break;
        case BackupErrorType.parseError:
          errorMessage = 'Parse Error';
          break;
        default:
          errorDetails = e.message;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(errorMessage),
        content: Text(errorDetails),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
