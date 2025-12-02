import 'package:flutter/material.dart';
import '../../models/notification_config.dart';
import '../../models/user_settings.dart';

class NotificationSettingsSection extends StatelessWidget {
  final UserSettings settings;
  final Function(NotificationConfig) onConfigChanged;
  final VoidCallback onReminderDaysTap;

  const NotificationSettingsSection({
    super.key,
    required this.settings,
    required this.onConfigChanged,
    required this.onReminderDaysTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Intense Alert Mode'),
          subtitle: const Text('Use full-screen alerts for critical reminders'),
          value: settings.notificationConfig.isFullScreenAlertEnabled,
          onChanged: (value) => onConfigChanged(
            settings.notificationConfig.copyWith(
              isFullScreenAlertEnabled: value,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Sound'),
          subtitle: const Text('Play sound with notifications'),
          value: settings.notificationConfig.soundEnabled,
          onChanged: (value) => onConfigChanged(
            settings.notificationConfig.copyWith(soundEnabled: value),
          ),
        ),
        ListTile(
          title: const Text('Reminder Days'),
          subtitle: Text(
            'Currently: ${settings.notificationConfig.reminderDays.join(", ")} days before',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: onReminderDaysTap,
        ),
      ],
    );
  }
}
