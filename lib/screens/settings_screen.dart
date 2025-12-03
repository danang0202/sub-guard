import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../core/constants/app_colors.dart';

import '../models/notification_config.dart';
import '../models/user_settings.dart';
import '../providers/providers.dart';
import '../services/backup_manager.dart';
import '../services/permission_handler.dart';
import '../widgets/dynamic_island_toast.dart';

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
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Ambient Glow Background
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.1),
                    blurRadius: 80,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(height: kToolbarHeight + 40),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildSectionHeader('Preferences'),
                          _buildGlassContainer([
                            _buildSettingsTile(
                              icon: Icons.notifications_rounded,
                              title: 'Notifications',
                              subtitle: 'Manage reminders & alerts',
                              onTap: () => _showReminderDaysDialog(
                                settings.notificationConfig,
                              ),
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              icon: Icons.currency_exchange_rounded,
                              title: 'Currency',
                              subtitle: settings.baseCurrency,
                              onTap: () =>
                                  _showCurrencyDialog(settings.baseCurrency),
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              icon: Icons.palette_rounded,
                              title: 'Appearance',
                              subtitle: settings.themeMode == AppThemeMode.dark
                                  ? 'Dark Mode'
                                  : 'Light Mode',
                              trailing: Switch(
                                value: settings.themeMode == AppThemeMode.dark,
                                onChanged: (value) => _updateThemeMode(
                                  value
                                      ? AppThemeMode.dark
                                      : AppThemeMode.light,
                                ),
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ]),

                          const SizedBox(height: 24),
                          _buildSectionHeader('Data & Privacy'),
                          _buildGlassContainer([
                            _buildSettingsTile(
                              icon: Icons.backup_rounded,
                              title: 'Backup Data',
                              subtitle: 'Save your subscriptions locally',
                              onTap: () => _createBackup(backupManager),
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              icon: Icons.restore_rounded,
                              title: 'Restore Data',
                              subtitle: 'Import from a backup file',
                              onTap: () => _restoreBackup(backupManager),
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              icon: Icons.security_rounded,
                              title: 'Permissions',
                              subtitle: 'Manage app permissions',
                              onTap: _requestPermissions,
                            ),
                          ]),

                          const SizedBox(height: 24),
                          _buildSectionHeader('System'),
                          _buildGlassContainer([
                            _buildSettingsTile(
                              icon: Icons.battery_saver_rounded,
                              title: 'Battery Optimization',
                              subtitle: 'Ensure reminders work reliably',
                              onTap: () =>
                                  _showWhitelistingGuide(batteryDetector),
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              icon: Icons.info_outline_rounded,
                              title: 'About',
                              subtitle: 'Version 1.0.0',
                              onTap: _showAboutDialog,
                            ),
                          ]),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildGlassContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ] else
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 60,
    );
  }

  // ============ Action Methods ============

  Future<void> _updateThemeMode(AppThemeMode themeMode) async {
    try {
      await ref
          .read(userSettingsNotifierProvider.notifier)
          .updateThemeMode(themeMode);
    } catch (e) {
      if (mounted) {
        DynamicIslandToast.show(
          context,
          message: 'Failed to update theme',
          icon: Icons.error_rounded,
          iconColor: AppColors.error,
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
          DynamicIslandToast.show(
            context,
            message: 'All permissions granted!',
            icon: Icons.check_circle_rounded,
          );
          setState(() {});
          break;
        case PermissionRequestResult.notificationDenied:
        case PermissionRequestResult.exactAlarmDenied:
          DynamicIslandToast.show(
            context,
            message: 'Some permissions denied',
            icon: Icons.warning_rounded,
            iconColor: const Color(0xFFFFC107),
          );
          break;
        case PermissionRequestResult.userCancelled:
          break;
      }
    } catch (e) {
      if (mounted) {
        DynamicIslandToast.show(
          context,
          message: 'Error requesting permissions',
          icon: Icons.error_rounded,
          iconColor: AppColors.error,
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Select Base Currency',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) {
              final isSelected = currency == currentCurrency;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                title: Text(
                  currency,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () => Navigator.pop(context, currency),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selected != null && selected != currentCurrency) {
      try {
        await ref
            .read(userSettingsNotifierProvider.notifier)
            .updateBaseCurrency(selected);

        if (mounted) {
          DynamicIslandToast.show(
            context,
            message: 'Currency updated to $selected',
            icon: Icons.currency_exchange_rounded,
          );
        }
      } catch (e) {
        if (mounted) {
          DynamicIslandToast.show(
            context,
            message: 'Failed to update currency',
            icon: Icons.error_rounded,
            iconColor: AppColors.error,
          );
        }
      }
    }
  }

  Future<void> _showReminderDaysDialog(NotificationConfig config) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Reminder Days',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Current reminder schedule:\n\n'
          '${config.reminderDays.map((d) => '• $d days before billing').join('\n')}\n\n'
          'Customization coming soon!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'About SUB-GUARD',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'SUB-GUARD is a subscription tracking and reminder app designed to help you '
          'manage your digital subscriptions and prevent unwanted charges.\n\n'
          'Version 1.0.0',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primary),
            ),
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
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              'Battery Optimization',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Device: $deviceModel',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    instructions,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        DynamicIslandToast.show(
          context,
          message: 'Failed to load guide',
          icon: Icons.error_rounded,
          iconColor: AppColors.error,
        );
      }
    }
  }

  // ============ Backup Methods ============

  Future<void> _createBackup(BackupManager backupManager) async {
    setState(() => _isLoading = true);

    try {
      await backupManager.exportToJson();

      if (mounted) {
        setState(() => _isLoading = false);
        DynamicIslandToast.show(
          context,
          message: 'Backup created successfully',
          icon: Icons.save_rounded,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        DynamicIslandToast.show(
          context,
          message: 'Backup failed',
          icon: Icons.error_rounded,
          iconColor: AppColors.error,
        );
      }
    }
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
      if (filePath == null) return;

      final confirmed = await _showRestoreConfirmDialog();
      if (confirmed != true) return;

      setState(() => _isLoading = true);

      try {
        await backupManager.importFromJson(filePath);

        if (mounted) {
          setState(() => _isLoading = false);
          ref.invalidate(subscriptionListProvider);
          DynamicIslandToast.show(
            context,
            message: 'Data restored successfully',
            icon: Icons.restore_rounded,
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          DynamicIslandToast.show(
            context,
            message: 'Restore failed',
            icon: Icons.error_rounded,
            iconColor: AppColors.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        DynamicIslandToast.show(
          context,
          message: 'Error picking file',
          icon: Icons.error_rounded,
          iconColor: AppColors.error,
        );
      }
    }
  }

  Future<bool?> _showRestoreConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Restore Backup?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will replace all your current subscriptions and settings.\n\n'
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
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
}
