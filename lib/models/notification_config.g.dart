// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationConfigAdapter extends TypeAdapter<NotificationConfig> {
  @override
  final int typeId = 2;

  @override
  NotificationConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationConfig(
      reminderDays: (fields[0] as List).cast<int>(),
      isFullScreenAlertEnabled: fields[1] as bool,
      soundEnabled: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationConfig obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.reminderDays)
      ..writeByte(1)
      ..write(obj.isFullScreenAlertEnabled)
      ..writeByte(2)
      ..write(obj.soundEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
