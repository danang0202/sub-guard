import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sub_guard_android/models/subscription.dart';
import 'package:sub_guard_android/repositories/subscription_repository.dart';

void main() {
  late SubscriptionRepository repository;
  late Directory tempDir;

  setUpAll(() async {
    // Initialize Hive for testing with temporary directory
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(BillingCycleAdapter());
    Hive.registerAdapter(SubscriptionAdapter());
  });

  tearDownAll(() async {
    // Clean up temporary directory
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    // Open a fresh box for each test
    await Hive.openBox<Subscription>('subscriptions');
    repository = SubscriptionRepository();
  });

  tearDown(() async {
    // Clear and close the box after each test
    await repository.clear();
    await Hive.box<Subscription>('subscriptions').close();
    await Hive.deleteBoxFromDisk('subscriptions');
  });

  group('SubscriptionRepository CRUD operations', () {
    test('add should store a subscription', () async {
      final subscription = Subscription(
        id: 'test-1',
        serviceName: 'Netflix',
        cost: 15.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: DateTime(2024, 2, 1),
        isAutoRenew: true,
      );

      await repository.add(subscription);

      final retrieved = repository.get('test-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.serviceName, 'Netflix');
      expect(retrieved.cost, 15.99);
    });

    test('update should modify an existing subscription', () async {
      final subscription = Subscription(
        id: 'test-2',
        serviceName: 'Spotify',
        cost: 9.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: DateTime(2024, 2, 1),
        isAutoRenew: true,
      );

      await repository.add(subscription);

      final updated = subscription.copyWith(cost: 12.99);
      await repository.update('test-2', updated);

      final retrieved = repository.get('test-2');
      expect(retrieved!.cost, 12.99);
    });

    test('delete should remove a subscription', () async {
      final subscription = Subscription(
        id: 'test-3',
        serviceName: 'GitHub',
        cost: 4.0,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: DateTime(2024, 2, 1),
        isAutoRenew: true,
      );

      await repository.add(subscription);
      expect(repository.get('test-3'), isNotNull);

      await repository.delete('test-3');
      expect(repository.get('test-3'), isNull);
    });

    test('getAll should return all subscriptions', () async {
      final sub1 = Subscription(
        id: 'test-4',
        serviceName: 'Netflix',
        cost: 15.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: DateTime(2024, 2, 1),
        isAutoRenew: true,
      );

      final sub2 = Subscription(
        id: 'test-5',
        serviceName: 'Spotify',
        cost: 9.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: DateTime(2024, 2, 1),
        isAutoRenew: true,
      );

      await repository.add(sub1);
      await repository.add(sub2);

      final all = repository.getAll();
      expect(all.length, 2);
    });
  });

  group('SubscriptionRepository query methods', () {
    test('getActive should return only active subscriptions', () async {
      final active = Subscription(
        id: 'test-6',
        serviceName: 'Netflix',
        cost: 15.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: DateTime(2024, 2, 1),
        isAutoRenew: true,
        isActive: true,
      );

      final inactive = Subscription(
        id: 'test-7',
        serviceName: 'Spotify',
        cost: 9.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: DateTime(2024, 2, 1),
        isAutoRenew: true,
        isActive: false,
      );

      await repository.add(active);
      await repository.add(inactive);

      final activeList = repository.getActive();
      expect(activeList.length, 1);
      expect(activeList.first.id, 'test-6');
    });

    test('getByDate should return subscriptions for specific date', () async {
      final targetDate = DateTime(2024, 3, 15);

      final sub1 = Subscription(
        id: 'test-8',
        serviceName: 'Netflix',
        cost: 15.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: targetDate,
        isAutoRenew: true,
      );

      final sub2 = Subscription(
        id: 'test-9',
        serviceName: 'Spotify',
        cost: 9.99,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        startDate: DateTime(2024, 1, 1),
        nextBillingDate: DateTime(2024, 3, 20),
        isAutoRenew: true,
      );

      await repository.add(sub1);
      await repository.add(sub2);

      final byDate = repository.getByDate(targetDate);
      expect(byDate.length, 1);
      expect(byDate.first.id, 'test-8');
    });

    test(
      'getUpcoming should return subscriptions within specified days',
      () async {
        final now = DateTime.now();
        final in10Days = now.add(const Duration(days: 10));
        final in40Days = now.add(const Duration(days: 40));

        final upcoming = Subscription(
          id: 'test-10',
          serviceName: 'Netflix',
          cost: 15.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          startDate: DateTime(2024, 1, 1),
          nextBillingDate: in10Days,
          isAutoRenew: true,
        );

        final farFuture = Subscription(
          id: 'test-11',
          serviceName: 'Spotify',
          cost: 9.99,
          currency: 'USD',
          billingCycle: BillingCycle.monthly,
          startDate: DateTime(2024, 1, 1),
          nextBillingDate: in40Days,
          isAutoRenew: true,
        );

        await repository.add(upcoming);
        await repository.add(farFuture);

        final upcomingList = repository.getUpcoming(days: 30);
        expect(upcomingList.length, 1);
        expect(upcomingList.first.id, 'test-10');
      },
    );
  });
}
