import '../models/subscription.dart';
import '../repositories/subscription_repository.dart';
import 'notification_scheduler.dart';

/// Service for managing subscription lifecycle
/// Coordinates between repository and notification scheduler
class SubscriptionManager {
  final SubscriptionRepository _repository;
  final NotificationScheduler _notificationScheduler;

  SubscriptionManager({
    required SubscriptionRepository repository,
    required NotificationScheduler notificationScheduler,
  }) : _repository = repository,
       _notificationScheduler = notificationScheduler;

  /// Add a new subscription
  /// Saves to database and schedules notifications
  Future<void> addSubscription(Subscription subscription) async {
    try {
      // Save to database
      await _repository.add(subscription);

      // Schedule notifications if subscription is active
      if (subscription.isActive) {
        await _notificationScheduler.scheduleNotificationsForSubscription(
          subscription,
        );
      }
    } catch (e) {
      throw SubscriptionManagerException('Failed to add subscription: $e');
    }
  }

  /// Update an existing subscription
  /// Updates database and reschedules notifications
  Future<void> updateSubscription(String id, Subscription subscription) async {
    try {
      // Cancel existing notifications
      await _notificationScheduler.cancelNotificationsForSubscription(id);

      // Update in database
      await _repository.update(id, subscription);

      // Reschedule notifications if subscription is active
      if (subscription.isActive) {
        await _notificationScheduler.scheduleNotificationsForSubscription(
          subscription,
        );
      }
    } catch (e) {
      throw SubscriptionManagerException('Failed to update subscription: $e');
    }
  }

  /// Delete a subscription
  /// Removes from database and cancels all notifications
  Future<void> deleteSubscription(String id) async {
    try {
      // Cancel all notifications
      await _notificationScheduler.cancelNotificationsForSubscription(id);

      // Delete from database
      await _repository.delete(id);
    } catch (e) {
      throw SubscriptionManagerException('Failed to delete subscription: $e');
    }
  }

  /// Mark a subscription as paid
  /// Updates next billing date and reschedules notifications
  Future<void> markAsPaid(String id) async {
    try {
      // Get the subscription
      final subscription = _repository.get(id);
      if (subscription == null) {
        throw SubscriptionManagerException(
          'Subscription with id $id not found',
        );
      }

      // Calculate next billing date based on billing cycle
      final nextBillingDate = _calculateNextBillingDate(
        subscription.nextBillingDate,
        subscription.billingCycle,
      );

      // Update subscription with new billing date
      final updatedSubscription = subscription.copyWith(
        nextBillingDate: nextBillingDate,
      );

      // Update in database and reschedule notifications
      await updateSubscription(id, updatedSubscription);
    } catch (e) {
      if (e is SubscriptionManagerException) rethrow;
      throw SubscriptionManagerException(
        'Failed to mark subscription as paid: $e',
      );
    }
  }

  /// Cancel a subscription
  /// Sets isActive to false and cancels all notifications
  Future<void> cancelSubscription(String id) async {
    try {
      // Get the subscription
      final subscription = _repository.get(id);
      if (subscription == null) {
        throw SubscriptionManagerException(
          'Subscription with id $id not found',
        );
      }

      // Update subscription to inactive
      final updatedSubscription = subscription.copyWith(isActive: false);

      // Cancel all notifications
      await _notificationScheduler.cancelNotificationsForSubscription(id);

      // Update in database
      await _repository.update(id, updatedSubscription);
    } catch (e) {
      if (e is SubscriptionManagerException) rethrow;
      throw SubscriptionManagerException('Failed to cancel subscription: $e');
    }
  }

  /// Get a subscription by id
  Subscription? getSubscription(String id) {
    try {
      return _repository.get(id);
    } catch (e) {
      throw SubscriptionManagerException('Failed to get subscription: $e');
    }
  }

  /// Get all subscriptions
  List<Subscription> getAllSubscriptions() {
    try {
      return _repository.getAll();
    } catch (e) {
      throw SubscriptionManagerException('Failed to get all subscriptions: $e');
    }
  }

  /// Get all active subscriptions
  List<Subscription> getActiveSubscriptions() {
    try {
      return _repository.getActive();
    } catch (e) {
      throw SubscriptionManagerException(
        'Failed to get active subscriptions: $e',
      );
    }
  }

  /// Get upcoming subscriptions
  List<Subscription> getUpcomingSubscriptions({int days = 30}) {
    try {
      return _repository.getUpcoming(days: days);
    } catch (e) {
      throw SubscriptionManagerException(
        'Failed to get upcoming subscriptions: $e',
      );
    }
  }

  /// Calculate next billing date based on billing cycle
  DateTime _calculateNextBillingDate(
    DateTime currentBillingDate,
    BillingCycle billingCycle,
  ) {
    switch (billingCycle) {
      case BillingCycle.monthly:
        // Add one month
        return DateTime(
          currentBillingDate.year,
          currentBillingDate.month + 1,
          currentBillingDate.day,
        );
      case BillingCycle.yearly:
        // Add one year
        return DateTime(
          currentBillingDate.year + 1,
          currentBillingDate.month,
          currentBillingDate.day,
        );
    }
  }
}

/// Custom exception for subscription manager operations
class SubscriptionManagerException implements Exception {
  final String message;

  SubscriptionManagerException(this.message);

  @override
  String toString() => 'SubscriptionManagerException: $message';
}
