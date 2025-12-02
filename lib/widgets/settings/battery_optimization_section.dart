import 'package:flutter/material.dart';
import '../../services/battery_optimization_detector.dart';

class BatteryOptimizationSection extends StatelessWidget {
  final BatteryOptimizationDetector detector;
  final VoidCallback onShowGuide;

  const BatteryOptimizationSection({
    super.key,
    required this.detector,
    required this.onShowGuide,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<bool>(
          future: detector.isBatteryOptimizationEnabled(),
          builder: (context, snapshot) {
            final isEnabled = snapshot.data ?? true;

            return ListTile(
              leading: Icon(
                isEnabled ? Icons.warning : Icons.check_circle,
                color: isEnabled
                    ? const Color(0xFFFFC107)
                    : const Color(0xFF4CAF50),
              ),
              title: const Text('Battery Optimization Status'),
              subtitle: Text(
                isEnabled
                    ? 'Enabled - May affect notifications'
                    : 'Disabled - Notifications will work reliably',
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Whitelisting Guide'),
          subtitle: const Text('View device-specific instructions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onShowGuide,
        ),
      ],
    );
  }
}
