import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'notification_config.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 3)
enum AppThemeMode {
  @HiveField(0)
  light,
  @HiveField(1)
  dark,
  @HiveField(2)
  system,
}

extension AppThemeModeExtension on AppThemeMode {
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

@HiveType(typeId: 4)
class UserSettings {
  @HiveField(0)
  final String baseCurrency;

  @HiveField(1)
  final AppThemeMode themeMode;

  @HiveField(2)
  final DateTime? lastBackupDate;

  @HiveField(3)
  final NotificationConfig notificationConfig;

  const UserSettings({
    this.baseCurrency = 'USD',
    this.themeMode = AppThemeMode.dark,
    this.lastBackupDate,
    this.notificationConfig = const NotificationConfig(),
  });

  UserSettings copyWith({
    String? baseCurrency,
    AppThemeMode? themeMode,
    DateTime? lastBackupDate,
    NotificationConfig? notificationConfig,
  }) {
    return UserSettings(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      themeMode: themeMode ?? this.themeMode,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      notificationConfig: notificationConfig ?? this.notificationConfig,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'themeMode': themeMode.name,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'notificationConfig': notificationConfig.toJson(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      baseCurrency: json['baseCurrency'] as String,
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.dark,
      ),
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'] as String)
          : null,
      notificationConfig: NotificationConfig.fromJson(
        json['notificationConfig'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettings &&
        other.baseCurrency == baseCurrency &&
        other.themeMode == themeMode &&
        other.lastBackupDate == lastBackupDate &&
        other.notificationConfig == notificationConfig;
  }

  @override
  int get hashCode {
    return Object.hash(
      baseCurrency,
      themeMode,
      lastBackupDate,
      notificationConfig,
    );
  }
}
