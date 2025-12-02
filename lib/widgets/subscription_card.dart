import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/subscription.dart';
import '../models/preset_service.dart';
import '../core/constants/app_colors.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback? onTap;

  const SubscriptionCard({super.key, required this.subscription, this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysUntilBilling = subscription.nextBillingDate
        .difference(DateTime.now())
        .inDays;
    final isUrgent = daysUntilBilling <= 3;
    final brandColor = _getBrandColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surface.withOpacity(0.8)],
        ),
        border: Border.all(
          color: isUrgent
              ? AppColors.error.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Brand Logo (Larger & Glowing)
                _buildLogo(brandColor),
                const SizedBox(width: 20),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.serviceName,
                        style: const TextStyle(
                          fontSize: 16, // Reduced from 18
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.payment_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${subscription.currency} ${subscription.cost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14, // Reduced from 15
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            subscription.billingCycle.name == 'monthly'
                                ? 'Mo'
                                : 'Yr',
                            style: TextStyle(
                              fontSize: 12, // Reduced from 13
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Date & Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: isUrgent
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat(
                            'MMM dd',
                          ).format(subscription.nextBillingDate),
                          style: TextStyle(
                            fontSize: 13, // Reduced from 14
                            fontWeight: FontWeight.w600,
                            color: isUrgent
                                ? AppColors.error
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(daysUntilBilling),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(Color brandColor) {
    Widget logoContent;

    // Check if brand color is too dark for dark mode
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
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          logoUrl,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildPlaceholderLogo(displayColor),
        ),
      );
    } else if (subscription.serviceLogoPath != null &&
        subscription.serviceLogoPath!.isNotEmpty) {
      if (subscription.serviceLogoPath!.startsWith('assets/')) {
        logoContent = Image.asset(
          subscription.serviceLogoPath!,
          width: 32,
          height: 32,
          color: isDarkBrand
              ? Colors.white
              : null, // Tint icon white if brand is dark
          errorBuilder: (_, __, ___) => _buildPlaceholderLogo(displayColor),
        );
      } else {
        logoContent = _buildPlaceholderLogo(displayColor);
      }
    } else {
      logoContent = _buildPlaceholderLogo(displayColor);
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: brandColor.withOpacity(0.25), // Brighter background
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: brandColor.withOpacity(0.5), // Clearer border
          width: 1.5,
        ),
      ),
      child: Center(child: logoContent),
    );
  }

  Widget _buildPlaceholderLogo(Color color) {
    return Text(
      subscription.serviceName.isNotEmpty
          ? subscription.serviceName[0].toUpperCase()
          : '?',
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildStatusBadge(int days) {
    Color color;
    String text;

    if (days < 0) {
      color = AppColors.error;
      text = 'Overdue';
    } else if (days == 0) {
      color = AppColors.error;
      text = 'Today';
    } else if (days == 1) {
      color = AppColors.warning;
      text = 'Tomorrow';
    } else {
      color = AppColors.secondary;
      text = '$days days';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11, // Reduced from 12
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getBrandColor() {
    if (subscription.colorHex != null) {
      try {
        final hexColor = subscription.colorHex!.replaceAll('#', '');
        return Color(int.parse('FF$hexColor', radix: 16));
      } catch (e) {
        return AppColors.primary;
      }
    }
    return AppColors.primary;
  }
}
