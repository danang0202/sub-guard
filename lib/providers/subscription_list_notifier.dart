import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription.dart';
import '../services/subscription_manager.dart';
import 'service_providers.dart';

/// StateNotifier for managing the subscription list
/// Provides reactive state management for subscriptions
class SubscriptionListNotifier extends StateNotifier<List<Subscription>> {
  final SubscriptionManager _subscriptionManager;

  bool _isInitialized = false;

  SubscriptionListNotifier(this._subscriptionManager) : super([]) {
    // Don't load immediately - prevents blocking main thread during startup
    // Data will load lazily when first accessed
  }

  /// Initialize and load subscriptions
  /// Call this after UI is ready to prevent blocking main thread
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Future.microtask(() {
      _loadSubscriptions();
      _isInitialized = true;
    });
  }

  /// Load all subscriptions from repository
  void _loadSubscriptions() {
    try {
      final subscriptions = _subscriptionManager.getAllSubscriptions();
      state = subscriptions;
    } catch (e) {
      // Handle error - keep empty state
      state = [];
    }
  }

  /// Reload subscriptions from repository
  /// Useful after external changes
  void reload() {
    _loadSubscriptions();
  }

  /// Add a new subscription
  Future<void> addSubscription(Subscription subscription) async {
    try {
      await _subscriptionManager.addSubscription(subscription);
      // Reload to get updated list
      _loadSubscriptions();
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing subscription
  Future<void> updateSubscription(String id, Subscription subscription) async {
    try {
      await _subscriptionManager.updateSubscription(id, subscription);
      // Reload to get updated list
      _loadSubscriptions();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a subscription
  Future<void> deleteSubscription(String id) async {
    try {
      await _subscriptionManager.deleteSubscription(id);
      // Reload to get updated list
      _loadSubscriptions();
    } catch (e) {
      rethrow;
    }
  }

  /// Mark a subscription as paid
  Future<void> markAsPaid(String id) async {
    try {
      await _subscriptionManager.markAsPaid(id);
      // Reload to get updated list
      _loadSubscriptions();
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a subscription
  Future<void> cancelSubscription(String id) async {
    try {
      await _subscriptionManager.cancelSubscription(id);
      // Reload to get updated list
      _loadSubscriptions();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific subscription by id
  Subscription? getSubscription(String id) {
    try {
      return state.firstWhere((sub) => sub.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all active subscriptions
  List<Subscription> getActiveSubscriptions() {
    return state.where((sub) => sub.isActive).toList();
  }
}

/// Provider for SubscriptionListNotifier
/// Manages the reactive subscription list state
final subscriptionListProvider =
    StateNotifierProvider<SubscriptionListNotifier, List<Subscription>>((ref) {
      final subscriptionManager = ref.watch(subscriptionManagerProvider);
      return SubscriptionListNotifier(subscriptionManager);
    });
