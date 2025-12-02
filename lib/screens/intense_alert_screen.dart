import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../providers/providers.dart';

class IntenseAlertScreen extends ConsumerWidget {
  final String subscriptionId;

  const IntenseAlertScreen({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref
        .watch(subscriptionListProvider.notifier)
        .getSubscription(subscriptionId);

    if (subscription == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Text(
              'Subscription not found',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      );
    }

    final daysUntilBilling = subscription.nextBillingDate
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFD32F2F), Color(0xFFB71C1C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Service logo
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        subscription.serviceName.isNotEmpty
                            ? subscription.serviceName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Warning icon and text
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_rounded, size: 48, color: Colors.white),
                    SizedBox(width: 16),
                    Text(
                      'TAGIHAN BESOK!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.warning_rounded, size: 48, color: Colors.white),
                  ],
                ),

                const SizedBox(height: 24),

                // Service name
                Text(
                  subscription.serviceName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Amount
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${subscription.currency} ${subscription.cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        daysUntilBilling == 0
                            ? 'AKAN DIPOTONG HARI INI!'
                            : 'AKAN DIPOTONG BESOK!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Action buttons
                _buildActionButton(
                  context,
                  ref,
                  subscription,
                  'SAYA SUDAH BAYAR',
                  Icons.check_circle,
                  Colors.white,
                  const Color(0xFF4CAF50),
                  _handlePaid,
                ),

                const SizedBox(height: 16),

                _buildActionButton(
                  context,
                  ref,
                  subscription,
                  'BATALKAN LANGGANAN',
                  Icons.cancel,
                  Colors.white,
                  const Color(0xFFFF9800),
                  _handleCancel,
                ),

                const SizedBox(height: 16),

                _buildActionButton(
                  context,
                  ref,
                  subscription,
                  'INGATKAN LAGI NANTI',
                  Icons.snooze,
                  const Color(0xFFFF5252),
                  Colors.white,
                  _handleSnooze,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
    String label,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    Function(BuildContext, WidgetRef, Subscription) onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: () => onPressed(context, ref, subscription),
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
    );
  }

  Future<void> _handlePaid(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    try {
      await ref
          .read(subscriptionListProvider.notifier)
          .markAsPaid(subscription.id);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${subscription.serviceName} marked as paid'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF5252),
          ),
        );
      }
    }
  }

  Future<void> _handleCancel(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Langganan?'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan langganan ${subscription.serviceName}? '
          'Notifikasi untuk langganan ini akan dihentikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(subscriptionListProvider.notifier)
            .cancelSubscription(subscription.id);

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${subscription.serviceName} cancelled'),
              backgroundColor: const Color(0xFFFF9800),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: const Color(0xFFFF5252),
            ),
          );
        }
      }
    }
  }

  void _handleSnooze(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) {
    // Simply dismiss the alert
    // In a full implementation, this could reschedule the notification
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert snoozed'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
