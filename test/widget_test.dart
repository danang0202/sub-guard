// This is a basic Flutter widget test for SUB-GUARD app.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:sub_guard_android/app/app.dart';
import 'package:sub_guard_android/models/subscription.dart';
import 'package:sub_guard_android/models/notification_config.dart';
import 'package:sub_guard_android/models/user_settings.dart';

void main() {
  late Directory testDir;

  setUpAll(() async {
    // Create a temporary directory for Hive in tests
    testDir = Directory.systemTemp.createTempSync('hive_test_');

    // Initialize Hive with the test directory
    Hive.init(testDir.path);

    // Register Hive type adapters
    Hive.registerAdapter(BillingCycleAdapter());
    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(NotificationConfigAdapter());
    Hive.registerAdapter(AppThemeModeAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    // Open Hive boxes for testing
    await Hive.openBox<Subscription>('subscriptions');
    await Hive.openBox<UserSettings>('settings');
  });

  tearDownAll(() async {
    // Clean up Hive after tests
    await Hive.close();

    // Delete the temporary directory
    if (testDir.existsSync()) {
      testDir.deleteSync(recursive: true);
    }
  });

  testWidgets('SUB-GUARD app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Pump a single frame to render the initial UI
    await tester.pump();

    // Verify that the bottom navigation bar is displayed with expected items
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Verify that navigation icons are present
    expect(find.byIcon(Icons.dashboard), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Pump the timer duration to let the delayed initialization complete
    // This handles the Future.delayed(Duration(seconds: 1)) in _MyAppState.initState
    await tester.pump(const Duration(seconds: 2));
  });
}
