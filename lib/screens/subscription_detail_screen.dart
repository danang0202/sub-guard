import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/preset_service.dart';
import '../providers/providers.dart';
import '../core/constants/app_colors.dart';
import '../widgets/dynamic_island_toast.dart';
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'Subscription not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final brandColor = _getBrandColor(subscription.colorHex);
    final daysUntilBilling = subscription.nextBillingDate
        .difference(DateTime.now())
        .inDays;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Ambient Glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brandColor.withOpacity(0.2),
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withOpacity(0.4),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              // Custom App Bar with Actions
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: _buildAppBarButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  _buildAppBarButton(
                    icon: Icons.edit_rounded,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditSubscriptionScreen(
                            subscriptionId: subscriptionId,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildAppBarButton(
                    icon: Icons.delete_rounded,
                    iconColor: AppColors.error,
                    onPressed: () => _confirmDelete(context, ref, subscription),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Logo & Service Name
                      Hero(
                        tag: 'logo_${subscription.id}',
                        child: _buildLogo(subscription, brandColor),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        subscription.serviceName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          '${subscription.currency} ${subscription.cost.toStringAsFixed(2)} / ${_formatBillingCycle(subscription.billingCycle)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Stats Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.4,
                        children: [
                          _buildInfoCard(
                            'Next Billing',
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(subscription.nextBillingDate),
                            Icons.calendar_today_rounded,
                            brandColor,
                            isUrgent:
                                daysUntilBilling <= 3 && daysUntilBilling >= 0,
                          ),
                          _buildInfoCard(
                            'Days Left',
                            _formatDaysUntil(daysUntilBilling),
                            Icons.timer_rounded,
                            AppColors.secondary,
                            highlightValue: true,
                          ),
                          _buildInfoCard(
                            'Status',
                            subscription.isActive ? 'Active' : 'Cancelled',
                            subscription.isActive
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            subscription.isActive
                                ? AppColors.success
                                : AppColors.error,
                            highlightValue: true,
                            valueColor: subscription.isActive
                                ? AppColors.success
                                : AppColors.error,
                          ),
                          _buildInfoCard(
                            'Auto-Renewal',
                            subscription.isAutoRenew ? 'On' : 'Off',
                            Icons.autorenew_rounded,
                            Colors.white,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Actions
                      if (subscription.isActive) ...[
                        _buildActionButton(
                          label: 'Mark as Paid',
                          icon: Icons.verified_rounded,
                          backgroundColor: const Color(0xFF2ECC71),
                          textColor: Colors.white,
                          onPressed: () =>
                              _markAsPaid(context, ref, subscription),
                          hasShadow: true,
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          label: 'Cancel Subscription',
                          icon: Icons.cancel_rounded,
                          backgroundColor: const Color(
                            0xFFFF4757,
                          ).withOpacity(0.1),
                          borderColor: const Color(0xFFFF4757),
                          textColor: const Color(0xFFFF4757),
                          onPressed: () =>
                              _confirmCancel(context, ref, subscription),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
    Color? backgroundColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14), // Rounded rectangle (Squircle)
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: 20),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Subscription subscription, Color brandColor) {
    Widget logoContent;
    final isDarkBrand = brandColor.computeLuminance() < 0.3;
    final displayColor = isDarkBrand ? Colors.white : brandColor;

    // Try to find logo URL from subscription or matching preset
    String? logoUrl = subscription.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      // Fallback: Try to find matching preset
      try {
        final preset = presetServices.firstWhere(
          (p) => p.name.toLowerCase() == subscription.serviceName.toLowerCase(),
        );
        logoUrl = preset.logoUrl;
      } catch (_) {}
    }

    if (logoUrl != null && logoUrl.isNotEmpty) {
      logoContent = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          logoUrl,
          width: 64,
          height: 64,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              _buildPlaceholderLogo(subscription, displayColor),
        ),
      );
    } else if (subscription.serviceLogoPath != null &&
        subscription.serviceLogoPath!.isNotEmpty) {
      if (subscription.serviceLogoPath!.startsWith('assets/')) {
        logoContent = Image.asset(
          subscription.serviceLogoPath!,
          width: 64,
          height: 64,
          color: isDarkBrand ? Colors.white : null,
          errorBuilder: (_, __, ___) =>
              _buildPlaceholderLogo(subscription, displayColor),
        );
      } else {
        logoContent = _buildPlaceholderLogo(subscription, displayColor);
      }
    } else {
      logoContent = _buildPlaceholderLogo(subscription, displayColor);
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: brandColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: brandColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: brandColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(child: logoContent),
    );
  }

  Widget _buildPlaceholderLogo(Subscription subscription, Color color) {
    return Text(
      subscription.serviceName.isNotEmpty
          ? subscription.serviceName[0].toUpperCase()
          : '?',
      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color accentColor, {
    bool highlightValue = false,
    Color? valueColor,
    bool isUrgent = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent
            ? const Color(0xFFFF4757).withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFFF4757).withOpacity(0.5)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      valueColor ??
                      (isUrgent ? const Color(0xFFFF4757) : Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    Color? borderColor,
    bool hasShadow = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
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
        return AppColors.primary;
      }
    }
    return AppColors.primary;
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
      return '${-days} Days Overdue';
    } else if (days == 0) {
      return 'Today';
    } else if (days == 1) {
      return 'Tomorrow';
    } else {
      return '$days Days';
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
        DynamicIslandToast.show(
          context,
          message: 'Subscription marked as paid',
          icon: Icons.verified_rounded,
          iconColor: const Color(0xFF2ECC71),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        DynamicIslandToast.show(
          context,
          message: 'Error: $e',
          icon: Icons.error_rounded,
          iconColor: AppColors.error,
        );
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Cancel Subscription',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to cancel ${subscription.serviceName}? This will stop all future notifications.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.error),
            ),
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
          DynamicIslandToast.show(
            context,
            message: 'Subscription cancelled',
            icon: Icons.cancel_rounded,
            iconColor: AppColors.textSecondary,
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          DynamicIslandToast.show(
            context,
            message: 'Error: $e',
            icon: Icons.error_rounded,
            iconColor: AppColors.error,
          );
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete Subscription',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${subscription.serviceName}? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
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
          DynamicIslandToast.show(
            context,
            message: 'Subscription deleted',
            icon: Icons.delete_rounded,
            iconColor: AppColors.error,
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          DynamicIslandToast.show(
            context,
            message: 'Error: $e',
            icon: Icons.error_rounded,
            iconColor: AppColors.error,
          );
        }
      }
    }
  }
}
