import 'package:flutter/material.dart';
import '../../services/permission_handler.dart';

class PermissionsSection extends StatelessWidget {
  final VoidCallback onRequestPermissions;

  const PermissionsSection({super.key, required this.onRequestPermissions});

  @override
  Widget build(BuildContext context) {
    final permissionHandler = PermissionHandler();

    return Column(
      children: [
        _buildPermissionTile(
          future: permissionHandler.checkNotificationPermission(),
          title: 'Notification Permission',
          grantedText: 'Granted',
          deniedText: 'Not granted - Required for reminders',
        ),
        _buildPermissionTile(
          future: permissionHandler.checkExactAlarmPermission(),
          title: 'Exact Alarm Permission',
          grantedText: 'Granted',
          deniedText: 'Not granted - Required for precise timing',
        ),
        _buildPermissionTile(
          future: permissionHandler.checkFullScreenIntentPermission(),
          title: 'Full Screen Intent',
          grantedText: 'Available',
          deniedText: 'Configured via manifest',
          useInfoIcon: true,
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Request Permissions'),
          subtitle: const Text('Check and request all required permissions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onRequestPermissions,
        ),
      ],
    );
  }

  Widget _buildPermissionTile({
    required Future<bool> future,
    required String title,
    required String grantedText,
    required String deniedText,
    bool useInfoIcon = false,
  }) {
    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        final isGranted = snapshot.data ?? false;

        return ListTile(
          leading: Icon(
            isGranted
                ? Icons.check_circle
                : (useInfoIcon ? Icons.info : Icons.warning),
            color: isGranted
                ? const Color(0xFF4CAF50)
                : (useInfoIcon
                      ? const Color(0xFF03DAC6)
                      : const Color(0xFFFFC107)),
          ),
          title: Text(title),
          subtitle: Text(isGranted ? grantedText : deniedText),
        );
      },
    );
  }
}
