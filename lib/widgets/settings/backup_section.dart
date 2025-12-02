import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_settings.dart';

class BackupSection extends StatelessWidget {
  final UserSettings settings;
  final VoidCallback onCreateBackup;
  final VoidCallback onRestoreBackup;

  const BackupSection({
    super.key,
    required this.settings,
    required this.onCreateBackup,
    required this.onRestoreBackup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (settings.lastBackupDate != null)
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Last Backup'),
            subtitle: Text(
              DateFormat(
                'MMMM dd, yyyy HH:mm',
              ).format(settings.lastBackupDate!),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Create Backup'),
          subtitle: const Text('Export all data to JSON file'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onCreateBackup,
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text('Restore from Backup'),
          subtitle: const Text('Import data from JSON file'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onRestoreBackup,
        ),
      ],
    );
  }
}
