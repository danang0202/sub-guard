import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Service for detecting device manufacturer and battery optimization status
/// Provides manufacturer-specific instructions for whitelisting the app
class BatteryOptimizationDetector {
  final DeviceInfoPlugin _deviceInfo;

  BatteryOptimizationDetector({DeviceInfoPlugin? deviceInfo})
    : _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  /// Get device manufacturer name
  Future<String> getDeviceManufacturer() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.manufacturer.toLowerCase();
      }
      return 'unknown';
    } catch (e) {
      throw BatteryOptimizationDetectorException(
        'Failed to get device manufacturer: $e',
      );
    }
  }

  /// Check if battery optimization is enabled for the app
  /// Note: This is a simplified check. Full implementation would require
  /// platform channel to check actual battery optimization status
  Future<bool> isBatteryOptimizationEnabled() async {
    try {
      // This is a placeholder implementation
      // In a real app, you would use a platform channel to check:
      // PowerManager.isIgnoringBatteryOptimizations(packageName)
      // For now, we assume it's enabled by default
      return true;
    } catch (e) {
      throw BatteryOptimizationDetectorException(
        'Failed to check battery optimization status: $e',
      );
    }
  }

  /// Get manufacturer-specific whitelisting instructions
  String getWhitelistingInstructions(String manufacturer) {
    final normalizedManufacturer = manufacturer.toLowerCase();

    if (_manufacturerInstructions.containsKey(normalizedManufacturer)) {
      return _manufacturerInstructions[normalizedManufacturer]!;
    }

    // Return generic instructions if manufacturer not found
    return _manufacturerInstructions['generic']!;
  }

  /// Get whitelisting instructions for current device
  Future<String> getDeviceWhitelistingInstructions() async {
    try {
      final manufacturer = await getDeviceManufacturer();
      return getWhitelistingInstructions(manufacturer);
    } catch (e) {
      throw BatteryOptimizationDetectorException(
        'Failed to get whitelisting instructions: $e',
      );
    }
  }

  /// Map of manufacturer-specific battery optimization instructions
  static final Map<String, String> _manufacturerInstructions = {
    'xiaomi': '''
Langkah untuk Xiaomi/MIUI:

1. Buka Settings → Apps → Manage Apps
2. Cari "SUB-GUARD"
3. Pilih "Battery saver" → "No restrictions"
4. Kembali dan aktifkan "Autostart"
5. Buka Settings → Battery & performance
6. Pilih "App battery saver" → Cari SUB-GUARD
7. Pilih "No restrictions"

Catatan: Langkah ini penting untuk memastikan notifikasi berfungsi dengan baik.
''',
    'samsung': '''
Langkah untuk Samsung:

1. Buka Settings → Apps → SUB-GUARD
2. Pilih "Battery" → "Optimize battery usage"
3. Pilih "All" dari dropdown
4. Matikan optimasi untuk SUB-GUARD
5. Kembali ke Settings → Device care → Battery
6. Pilih "App power management"
7. Matikan "Put unused apps to sleep"
8. Pastikan SUB-GUARD tidak ada di "Sleeping apps" atau "Deep sleeping apps"

Catatan: Samsung memiliki beberapa layer battery optimization yang perlu dinonaktifkan.
''',
    'oppo': '''
Langkah untuk Oppo/ColorOS:

1. Buka Settings → Battery → App Battery Management
2. Cari SUB-GUARD dan pilih "Don't optimize"
3. Buka Settings → Privacy → Startup Manager
4. Aktifkan SUB-GUARD
5. Buka Settings → Additional Settings → Battery
6. Pilih "Power Saving Mode" → Manage apps
7. Pastikan SUB-GUARD tidak dibatasi

Catatan: Oppo sangat agresif dalam membatasi background apps.
''',
    'realme': '''
Langkah untuk Realme:

1. Buka Settings → Battery → App Battery Management
2. Cari SUB-GUARD dan pilih "Don't optimize"
3. Buka Settings → App Management → Startup Manager
4. Aktifkan SUB-GUARD
5. Buka Settings → Battery → More Battery Settings
6. Matikan "Adaptive Battery"
7. Buka Settings → App Management → SUB-GUARD
8. Aktifkan "Allow background activity"

Catatan: Realme menggunakan ColorOS yang mirip dengan Oppo.
''',
    'huawei': '''
Langkah untuk Huawei/EMUI:

1. Buka Settings → Apps → Apps
2. Cari SUB-GUARD
3. Pilih "Battery" → "App launch"
4. Matikan "Manage automatically"
5. Aktifkan "Auto-launch", "Secondary launch", dan "Run in background"
6. Buka Settings → Battery → App launch
7. Cari SUB-GUARD dan atur ke "Manual"
8. Aktifkan semua opsi

Catatan: Huawei sangat ketat dalam battery management.
''',
    'vivo': '''
Langkah untuk Vivo/FuntouchOS:

1. Buka Settings → Battery → Background power consumption management
2. Cari SUB-GUARD dan pilih "Allow high background power consumption"
3. Buka Settings → More Settings → Applications
4. Pilih SUB-GUARD → Permissions
5. Aktifkan "Auto-start"
6. Buka Settings → Battery → High background power consumption
7. Pastikan SUB-GUARD ada dalam daftar

Catatan: Vivo memiliki battery optimization yang agresif.
''',
    'oneplus': '''
Langkah untuk OnePlus/OxygenOS:

1. Buka Settings → Apps → SUB-GUARD
2. Pilih "Battery" → "Battery optimization"
3. Pilih "All apps" dan cari SUB-GUARD
4. Pilih "Don't optimize"
5. Kembali ke Settings → Battery → Battery optimization
6. Pilih "Advanced optimization"
7. Matikan "Deep optimization" dan "Sleep standby optimization"

Catatan: OnePlus lebih ringan dibanding manufacturer lain, tapi tetap perlu diatur.
''',
    'google': '''
Langkah untuk Google Pixel:

1. Buka Settings → Apps → SUB-GUARD
2. Pilih "Battery" → "Battery optimization"
3. Pilih "All apps" dari dropdown
4. Cari SUB-GUARD dan pilih "Don't optimize"
5. Buka Settings → Battery → Battery Saver
6. Pastikan "Turn on automatically" tidak mengganggu SUB-GUARD

Catatan: Google Pixel memiliki battery optimization yang lebih standar.
''',
    'generic': '''
Langkah Umum untuk Android:

1. Buka Settings → Apps → SUB-GUARD
2. Pilih "Battery" atau "Battery optimization"
3. Pilih "All apps" dari dropdown (jika ada)
4. Cari SUB-GUARD
5. Pilih "Don't optimize" atau "No restrictions"
6. Pastikan notifikasi diizinkan untuk SUB-GUARD
7. Periksa apakah ada pengaturan "Auto-start" dan aktifkan

Catatan: Langkah ini mungkin berbeda tergantung versi Android dan manufacturer.
Jika notifikasi masih tidak muncul, coba cari pengaturan battery optimization
di menu Settings perangkat Anda.
''',
  };

  /// Get list of supported manufacturers
  List<String> getSupportedManufacturers() {
    return _manufacturerInstructions.keys
        .where((key) => key != 'generic')
        .toList();
  }

  /// Check if manufacturer has specific instructions
  bool hasSpecificInstructions(String manufacturer) {
    final normalizedManufacturer = manufacturer.toLowerCase();
    return _manufacturerInstructions.containsKey(normalizedManufacturer) &&
        normalizedManufacturer != 'generic';
  }

  /// Get device model information
  Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      }
      return 'Unknown device';
    } catch (e) {
      throw BatteryOptimizationDetectorException(
        'Failed to get device model: $e',
      );
    }
  }

  /// Get Android version
  Future<String> getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
      }
      return 'Unknown';
    } catch (e) {
      throw BatteryOptimizationDetectorException(
        'Failed to get Android version: $e',
      );
    }
  }
}

/// Custom exception for battery optimization detector operations
class BatteryOptimizationDetectorException implements Exception {
  final String message;

  BatteryOptimizationDetectorException(this.message);

  @override
  String toString() => 'BatteryOptimizationDetectorException: $message';
}
