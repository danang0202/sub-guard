import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sub_guard_android/models/user_settings.dart';
import 'package:sub_guard_android/models/notification_config.dart';
import 'package:sub_guard_android/repositories/user_settings_repository.dart';

void main() {
  late UserSettingsRepository repository;
  late Directory tempDir;

  setUpAll(() async {
    // Initialize Hive for testing with temporary directory
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);
    Hive.registerAdapter(AppThemeModeAdapter());
    Hive.registerAdapter(NotificationConfigAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
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
    await Hive.openBox<UserSettings>('settings');
    repository = UserSettingsRepository();
  });

  tearDown(() async {
    // Clear and close the box after each test
    final box = Hive.box<UserSettings>('settings');
    await box.clear();
    await box.close();
    await Hive.deleteBoxFromDisk('settings');
  });

  group('UserSettingsRepository basic operations', () {
    test('get should return default settings on first launch', () {
      final settings = repository.get();
      expect(settings.baseCurrency, 'USD');
      expect(settings.themeMode, AppThemeMode.dark);
      expect(settings.lastBackupDate, isNull);
      expect(settings.notificationConfig.reminderDays, [7, 3, 1, 0]);
    });

    test('update should store settings', () async {
      final newSettings = const UserSettings(
        baseCurrency: 'EUR',
        themeMode: AppThemeMode.light,
      );

      await repository.update(newSettings);

      final retrieved = repository.get();
      expect(retrieved.baseCurrency, 'EUR');
      expect(retrieved.themeMode, AppThemeMode.light);
    });

    test('exists should return false initially', () {
      expect(repository.exists(), false);
    });

    test('exists should return true after update', () async {
      await repository.update(const UserSettings());
      expect(repository.exists(), true);
    });

    test('initializeDefaults should create default settings', () async {
      expect(repository.exists(), false);

      await repository.initializeDefaults();

      expect(repository.exists(), true);
      final settings = repository.get();
      expect(settings.baseCurrency, 'USD');
    });
  });

  group('UserSettingsRepository specific updates', () {
    test('updateBaseCurrency should update only currency', () async {
      await repository.update(const UserSettings(baseCurrency: 'USD'));

      await repository.updateBaseCurrency('EUR');

      final settings = repository.get();
      expect(settings.baseCurrency, 'EUR');
      expect(settings.themeMode, AppThemeMode.dark); // Should remain unchanged
    });

    test('updateThemeMode should update only theme', () async {
      await repository.update(const UserSettings(themeMode: AppThemeMode.dark));

      await repository.updateThemeMode(AppThemeMode.light);

      final settings = repository.get();
      expect(settings.themeMode, AppThemeMode.light);
      expect(settings.baseCurrency, 'USD'); // Should remain unchanged
    });

    test(
      'updateNotificationConfig should update only notification config',
      () async {
        await repository.update(const UserSettings());

        final newConfig = const NotificationConfig(
          reminderDays: [7, 1],
          isFullScreenAlertEnabled: false,
        );
        await repository.updateNotificationConfig(newConfig);

        final settings = repository.get();
        expect(settings.notificationConfig.reminderDays, [7, 1]);
        expect(settings.notificationConfig.isFullScreenAlertEnabled, false);
        expect(settings.baseCurrency, 'USD'); // Should remain unchanged
      },
    );

    test('updateLastBackupDate should update only backup date', () async {
      await repository.update(const UserSettings());

      final backupDate = DateTime(2024, 12, 1);
      await repository.updateLastBackupDate(backupDate);

      final settings = repository.get();
      expect(settings.lastBackupDate, backupDate);
      expect(settings.baseCurrency, 'USD'); // Should remain unchanged
    });

    test('reset should restore default settings', () async {
      // Set custom settings
      await repository.update(
        const UserSettings(baseCurrency: 'EUR', themeMode: AppThemeMode.light),
      );

      // Reset to defaults
      await repository.reset();

      final settings = repository.get();
      expect(settings.baseCurrency, 'USD');
      expect(settings.themeMode, AppThemeMode.dark);
    });
  });
}
