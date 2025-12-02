import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_colors.dart';

/// Dialog to warn users about battery optimization and provide instructions.
///
/// This dialog is shown when battery optimization is enabled on the device,
/// which can prevent notifications from being delivered on time.
class BatteryOptimizationDialog extends StatelessWidget {
  final String manufacturer;
  final String instructions;
  final String deviceModel;

  const BatteryOptimizationDialog({
    super.key,
    required this.manufacturer,
    required this.instructions,
    required this.deviceModel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          Icon(Icons.battery_alert, color: AppColors.error, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pengaturan Baterai Penting',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perangkat: $deviceModel',
              style: const TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'SUB-GUARD memerlukan pengecualian dari battery optimization untuk memastikan notifikasi tagihan berfungsi dengan baik.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                instructions,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tanpa pengaturan ini, notifikasi mungkin tidak muncul tepat waktu!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            // Mark as shown so it doesn't appear again
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('battery_optimization_warning_shown', true);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Nanti Saja'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            // Mark as shown
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('battery_optimization_warning_shown', true);

            // Close dialog
            if (context.mounted) {
              Navigator.of(context).pop();
            }

            // Open battery settings
            // Note: This would require a platform channel implementation
            // For now, we'll just show a message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Silakan buka Settings secara manual dan ikuti instruksi di atas',
                  ),
                  duration: Duration(seconds: 4),
                ),
              );
            }
          },
          icon: const Icon(Icons.settings),
          label: const Text('Buka Pengaturan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
        ),
      ],
    );
  }
}
