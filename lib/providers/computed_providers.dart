import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../models/user_settings.dart';
import 'subscription_list_notifier.dart';
import 'repository_providers.dart';
import 'service_providers.dart';
import 'user_settings_notifier.dart';

/// Provider for total monthly cost
/// Watches subscription list and calculates total cost in base currency
final totalCostProvider = Provider<double>((ref) {
  final subscriptions = ref.watch(subscriptionListProvider);
  final settings = ref.watch(userSettingsRepositoryProvider).get();
  final costCalculator = ref.watch(costCalculatorProvider);

  return costCalculator.calculateMonthlyTotal(
    subscriptions,
    settings.baseCurrency,
  );
});

/// Provider for upcoming bills (next 30 days)
/// Filters active subscriptions with billing dates in the next 30 days (including today)
/// Optimized to reduce computational overhead on main thread
final upcomingBillsProvider = Provider<List<Subscription>>((ref) {
  final subscriptions = ref.watch(subscriptionListProvider);

  // Cache current time to avoid multiple DateTime.now() calls
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thirtyDaysLater = today.add(const Duration(days: 30));

  // Pre-filter active subscriptions first (cheaper operation)
  final activeSubscriptions = subscriptions.where((s) => s.isActive);

  // Then filter by date range
  final upcoming = <Subscription>[];
  for (final subscription in activeSubscriptions) {
    // Normalize billing date once per subscription
    final billingDate = DateTime(
      subscription.nextBillingDate.year,
      subscription.nextBillingDate.month,
      subscription.nextBillingDate.day,
    );

    if (!billingDate.isBefore(today) && billingDate.isBefore(thirtyDaysLater)) {
      upcoming.add(subscription);
    }
  }

  // Sort in-place
  upcoming.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
  return upcoming;
});

/// Provider for calendar data
/// Groups subscriptions by billing date for calendar view
/// Optimized to reduce computational overhead
final calendarDataProvider = Provider<Map<DateTime, List<Subscription>>>((ref) {
  final subscriptions = ref.watch(subscriptionListProvider);
  final Map<DateTime, List<Subscription>> calendarData = {};

  // Pre-filter active subscriptions to reduce iterations
  final activeSubscriptions = subscriptions.where((s) => s.isActive);

  for (final subscription in activeSubscriptions) {
    // Normalize date to midnight for grouping
    final date = DateTime(
      subscription.nextBillingDate.year,
      subscription.nextBillingDate.month,
      subscription.nextBillingDate.day,
    );

    // Use putIfAbsent for cleaner code
    calendarData.putIfAbsent(date, () => []).add(subscription);
  }

  return calendarData;
});

/// Provider for subscriptions on a specific date
/// Returns subscriptions that have billing date on the specified date
final subscriptionsForDateProvider =
    Provider.family<List<Subscription>, DateTime>((ref, date) {
      final calendarData = ref.watch(calendarDataProvider);

      // Normalize date to midnight
      final normalizedDate = DateTime(date.year, date.month, date.day);

      return calendarData[normalizedDate] ?? [];
    });

/// Provider for active subscriptions count
final activeSubscriptionsCountProvider = Provider<int>((ref) {
  final subscriptions = ref.watch(subscriptionListProvider);
  return subscriptions.where((sub) => sub.isActive).length;
});

/// Provider for user settings state notifier
/// Provides reactive state management for user settings
final userSettingsNotifierProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
      final repository = ref.watch(userSettingsRepositoryProvider);
      return UserSettingsNotifier(repository);
    });

/// Provider for user settings (read-only)
/// Provides reactive access to user settings
final userSettingsProvider = Provider<UserSettings>((ref) {
  return ref.watch(userSettingsNotifierProvider);
});
