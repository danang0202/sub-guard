// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 1;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      serviceName: fields[1] as String,
      cost: fields[2] as double,
      currency: fields[3] as String,
      billingCycle: fields[4] as BillingCycle,
      startDate: fields[5] as DateTime,
      nextBillingDate: fields[6] as DateTime,
      serviceLogoPath: fields[8] as String?,
      colorHex: fields[9] as String?,
      isAutoRenew: fields[10] as bool,
      isActive: fields[11] as bool,
      logoUrl: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serviceName)
      ..writeByte(2)
      ..write(obj.cost)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.billingCycle)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.nextBillingDate)
      ..writeByte(8)
      ..write(obj.serviceLogoPath)
      ..writeByte(9)
      ..write(obj.colorHex)
      ..writeByte(10)
      ..write(obj.isAutoRenew)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.logoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillingCycleAdapter extends TypeAdapter<BillingCycle> {
  @override
  final int typeId = 0;

  @override
  BillingCycle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillingCycle.monthly;
      case 1:
        return BillingCycle.yearly;
      default:
        return BillingCycle.monthly;
    }
  }

  @override
  void write(BinaryWriter writer, BillingCycle obj) {
    switch (obj) {
      case BillingCycle.monthly:
        writer.writeByte(0);
        break;
      case BillingCycle.yearly:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingCycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
