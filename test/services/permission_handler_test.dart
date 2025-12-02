import 'package:flutter_test/flutter_test.dart';
import 'package:sub_guard_android/services/permission_handler.dart';

void main() {
  group('PermissionHandler', () {
    late PermissionHandler permissionHandler;

    setUp(() {
      permissionHandler = PermissionHandler();
    });

    test('should be a singleton', () {
      final instance1 = PermissionHandler();
      final instance2 = PermissionHandler();

      expect(instance1, same(instance2));
    });

    test('should have all permission status enum values', () {
      expect(PermissionStatus.values.length, 4);
      expect(PermissionStatus.values, contains(PermissionStatus.allGranted));
      expect(
        PermissionStatus.values,
        contains(PermissionStatus.notificationDenied),
      );
      expect(
        PermissionStatus.values,
        contains(PermissionStatus.exactAlarmDenied),
      );
      expect(
        PermissionStatus.values,
        contains(PermissionStatus.fullScreenIntentDenied),
      );
    });

    test('should have all permission request result enum values', () {
      expect(PermissionRequestResult.values.length, 4);
      expect(
        PermissionRequestResult.values,
        contains(PermissionRequestResult.allGranted),
      );
      expect(
        PermissionRequestResult.values,
        contains(PermissionRequestResult.notificationDenied),
      );
      expect(
        PermissionRequestResult.values,
        contains(PermissionRequestResult.exactAlarmDenied),
      );
      expect(
        PermissionRequestResult.values,
        contains(PermissionRequestResult.userCancelled),
      );
    });

    test('checkFullScreenIntentPermission should return true', () async {
      // Full screen intent is granted via manifest
      final result = await permissionHandler.checkFullScreenIntentPermission();
      expect(result, isTrue);
    });
  });
}
