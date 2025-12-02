import 'package:hive/hive.dart';

part 'notification_config.g.dart';

@HiveType(typeId: 2)
class NotificationConfig {
  @HiveField(0)
  final List<int> reminderDays;

  @HiveField(1)
  final bool isFullScreenAlertEnabled;

  @HiveField(2)
  final bool soundEnabled;

  const NotificationConfig({
    this.reminderDays = const [7, 3, 1, 0],
    this.isFullScreenAlertEnabled = true,
    this.soundEnabled = true,
  });

  NotificationConfig copyWith({
    List<int>? reminderDays,
    bool? isFullScreenAlertEnabled,
    bool? soundEnabled,
  }) {
    return NotificationConfig(
      reminderDays: reminderDays ?? this.reminderDays,
      isFullScreenAlertEnabled:
          isFullScreenAlertEnabled ?? this.isFullScreenAlertEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reminderDays': reminderDays,
      'isFullScreenAlertEnabled': isFullScreenAlertEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory NotificationConfig.fromJson(Map<String, dynamic> json) {
    return NotificationConfig(
      reminderDays: (json['reminderDays'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      isFullScreenAlertEnabled: json['isFullScreenAlertEnabled'] as bool,
      soundEnabled: json['soundEnabled'] as bool,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationConfig &&
        _listEquals(other.reminderDays, reminderDays) &&
        other.isFullScreenAlertEnabled == isFullScreenAlertEnabled &&
        other.soundEnabled == soundEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(reminderDays),
      isFullScreenAlertEnabled,
      soundEnabled,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
