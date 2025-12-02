import 'package:hive/hive.dart';
import '../models/subscription.dart';

class SubscriptionRepository {
  static const String _boxName = 'subscriptions';

  Box<Subscription> get _box => Hive.box<Subscription>(_boxName);

  // CRUD Operations

  /// Add a new subscription to the database
  Future<void> add(Subscription subscription) async {
    try {
      await _box.put(subscription.id, subscription);
    } catch (e) {
      throw SubscriptionRepositoryException('Failed to add subscription: $e');
    }
  }

  /// Update an existing subscription
  Future<void> update(String id, Subscription subscription) async {
    try {
      if (!_box.containsKey(id)) {
        throw SubscriptionRepositoryException(
          'Subscription with id $id not found',
        );
      }
      await _box.put(id, subscription);
    } catch (e) {
      if (e is SubscriptionRepositoryException) rethrow;
      throw SubscriptionRepositoryException(
        'Failed to update subscription: $e',
      );
    }
  }

  /// Delete a subscription by id
  Future<void> delete(String id) async {
    try {
      if (!_box.containsKey(id)) {
        throw SubscriptionRepositoryException(
          'Subscription with id $id not found',
        );
      }
      await _box.delete(id);
    } catch (e) {
      if (e is SubscriptionRepositoryException) rethrow;
      throw SubscriptionRepositoryException(
        'Failed to delete subscription: $e',
      );
    }
  }

  /// Get a subscription by id
  Subscription? get(String id) {
    try {
      return _box.get(id);
    } catch (e) {
      throw SubscriptionRepositoryException('Failed to get subscription: $e');
    }
  }

  /// Get all subscriptions
  List<Subscription> getAll() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw SubscriptionRepositoryException(
        'Failed to get all subscriptions: $e',
      );
    }
  }

  // Query Methods

  /// Get subscriptions by specific date
  List<Subscription> getByDate(DateTime date) {
    try {
      final targetDate = DateTime(date.year, date.month, date.day);
      return _box.values.where((subscription) {
        final billingDate = DateTime(
          subscription.nextBillingDate.year,
          subscription.nextBillingDate.month,
          subscription.nextBillingDate.day,
        );
        return billingDate.isAtSameMomentAs(targetDate);
      }).toList();
    } catch (e) {
      throw SubscriptionRepositoryException(
        'Failed to get subscriptions by date: $e',
      );
    }
  }

  /// Get all active subscriptions
  List<Subscription> getActive() {
    try {
      return _box.values
          .where((subscription) => subscription.isActive)
          .toList();
    } catch (e) {
      throw SubscriptionRepositoryException(
        'Failed to get active subscriptions: $e',
      );
    }
  }

  /// Get upcoming subscriptions within the specified number of days
  List<Subscription> getUpcoming({int days = 30}) {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));

      return _box.values.where((subscription) {
          return subscription.isActive &&
              subscription.nextBillingDate.isAfter(now) &&
              subscription.nextBillingDate.isBefore(futureDate);
        }).toList()
        ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    } catch (e) {
      throw SubscriptionRepositoryException(
        'Failed to get upcoming subscriptions: $e',
      );
    }
  }

  /// Clear all subscriptions (useful for testing or data reset)
  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      throw SubscriptionRepositoryException(
        'Failed to clear subscriptions: $e',
      );
    }
  }

  /// Get count of subscriptions
  int count() {
    try {
      return _box.length;
    } catch (e) {
      throw SubscriptionRepositoryException(
        'Failed to get subscription count: $e',
      );
    }
  }
}

/// Custom exception for repository operations
class SubscriptionRepositoryException implements Exception {
  final String message;

  SubscriptionRepositoryException(this.message);

  @override
  String toString() => 'SubscriptionRepositoryException: $message';
}
