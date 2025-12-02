import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../providers/providers.dart';
import 'add_edit_subscription_screen.dart';

class SubscriptionDetailScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref
        .watch(subscriptionListProvider.notifier)
        .getSubscription(subscriptionId);

    if (subscription == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subscription Details')),
        body: const Center(child: Text('Subscription not found')),
      );
    }

    final brandColor = _getBrandColor(subscription.colorHex);
    final daysUntilBilling = subscription.nextBillingDate
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditSubscriptionScreen(subscriptionId: subscriptionId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref, subscription),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with service info
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    brandColor.withOpacity(0.3),
                    brandColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Service logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: brandColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: brandColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        subscription.serviceName.isNotEmpty
                            ? subscription.serviceName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subscription.serviceName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${subscription.currency} ${subscription.cost.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBB86FC),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatBillingCycle(subscription.billingCycle),
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),

            // Details section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDetailCard(
                    'Next Billing Date',
                    DateFormat(
                      'MMMM dd, yyyy',
                    ).format(subscription.nextBillingDate),
                    Icons.calendar_today,
                    _getHighlightColor(daysUntilBilling),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    'Days Until Billing',
                    _formatDaysUntil(daysUntilBilling),
                    Icons.access_time,
                    _getHighlightColor(daysUntilBilling),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    'Start Date',
                    DateFormat('MMMM dd, yyyy').format(subscription.startDate),
                    Icons.event,
                    null,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    'Auto-Renewal',
                    subscription.isAutoRenew ? 'Enabled' : 'Disabled',
                    subscription.isAutoRenew ? Icons.autorenew : Icons.block,
                    null,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    'Status',
                    subscription.isActive ? 'Active' : 'Cancelled',
                    subscription.isActive ? Icons.check_circle : Icons.cancel,
                    subscription.isActive
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5252),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  if (subscription.isActive) ...[
                    ElevatedButton.icon(
                      onPressed: () => _markAsPaid(context, ref, subscription),
                      icon: const Icon(Icons.check),
                      label: const Text('Mark as Paid'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _confirmCancel(context, ref, subscription),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel Subscription'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: const Color(0xFFFF5252),
                        side: const BorderSide(color: Color(0xFFFF5252)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    String label,
    String value,
    IconData icon,
    Color? highlightColor,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: highlightColor ?? const Color(0xFFBB86FC),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: highlightColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBrandColor(String? colorHex) {
    if (colorHex != null) {
      try {
        final hex = colorHex.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (e) {
        return const Color(0xFFBB86FC);
      }
    }
    return const Color(0xFFBB86FC);
  }

  Color? _getHighlightColor(int daysUntilBilling) {
    if (daysUntilBilling < 0) {
      return const Color(0xFFFF5252);
    } else if (daysUntilBilling <= 1) {
      return const Color(0xFFFF5252);
    } else if (daysUntilBilling <= 7) {
      return const Color(0xFFFFC107);
    }
    return null;
  }

  String _formatBillingCycle(BillingCycle cycle) {
    switch (cycle) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }

  String _formatDaysUntil(int days) {
    if (days < 0) {
      return 'Overdue by ${-days} day${-days != 1 ? 's' : ''}';
    } else if (days == 0) {
      return 'Due today!';
    } else if (days == 1) {
      return 'Due tomorrow';
    } else {
      return '$days days';
    }
  }

  Future<void> _markAsPaid(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    try {
      await ref
          .read(subscriptionListProvider.notifier)
          .markAsPaid(subscription.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription marked as paid')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: Text(
          'Are you sure you want to cancel ${subscription.serviceName}? '
          'This will stop all future notifications.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription cancelled')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text(
          'Are you sure you want to delete ${subscription.serviceName}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF5252),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(subscriptionListProvider.notifier)
            .deleteSubscription(subscription.id);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Subscription deleted')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
