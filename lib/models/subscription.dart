import 'package:hive/hive.dart';

part 'subscription.g.dart';

@HiveType(typeId: 0)
enum BillingCycle {
  @HiveField(0)
  monthly,
  @HiveField(1)
  yearly,
}

@HiveType(typeId: 1)
class Subscription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String serviceName;

  @HiveField(2)
  final double cost;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final BillingCycle billingCycle;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime nextBillingDate;

  // @HiveField(7) - removed: paymentMethod (no longer needed)

  @HiveField(8)
  final String? serviceLogoPath;

  @HiveField(9)
  final String? colorHex;

  @HiveField(10)
  final bool isAutoRenew;

  @HiveField(11)
  final bool isActive;

  @HiveField(12)
  final String? logoUrl;

  Subscription({
    required this.id,
    required this.serviceName,
    required this.cost,
    required this.currency,
    required this.billingCycle,
    required this.startDate,
    required this.nextBillingDate,
    this.serviceLogoPath,
    this.colorHex,
    required this.isAutoRenew,
    this.isActive = true,
    this.logoUrl,
  });

  // JSON serialization for backup functionality
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'cost': cost,
      'currency': currency,
      'billingCycle': billingCycle.name,
      'startDate': startDate.toIso8601String(),
      'nextBillingDate': nextBillingDate.toIso8601String(),
      'serviceLogoPath': serviceLogoPath,
      'colorHex': colorHex,
      'isAutoRenew': isAutoRenew,
      'isActive': isActive,
      'logoUrl': logoUrl,
    };
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      cost: (json['cost'] as num).toDouble(),
      currency: json['currency'] as String,
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == json['billingCycle'],
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
      serviceLogoPath: json['serviceLogoPath'] as String?,
      colorHex: json['colorHex'] as String?,
      isAutoRenew: json['isAutoRenew'] as bool,
      isActive: json['isActive'] as bool? ?? true,
      logoUrl: json['logoUrl'] as String?,
    );
  }

  // Copy with method for updates
  Subscription copyWith({
    String? id,
    String? serviceName,
    double? cost,
    String? currency,
    BillingCycle? billingCycle,
    DateTime? startDate,
    DateTime? nextBillingDate,
    String? serviceLogoPath,
    String? colorHex,
    bool? isAutoRenew,
    bool? isActive,
    String? logoUrl,
  }) {
    return Subscription(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      serviceLogoPath: serviceLogoPath ?? this.serviceLogoPath,
      colorHex: colorHex ?? this.colorHex,
      isAutoRenew: isAutoRenew ?? this.isAutoRenew,
      isActive: isActive ?? this.isActive,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subscription &&
        other.id == id &&
        other.serviceName == serviceName &&
        other.cost == cost &&
        other.currency == currency &&
        other.billingCycle == billingCycle &&
        other.startDate == startDate &&
        other.nextBillingDate == nextBillingDate &&
        other.serviceLogoPath == serviceLogoPath &&
        other.colorHex == colorHex &&
        other.isAutoRenew == isAutoRenew &&
        other.isActive == isActive &&
        other.logoUrl == logoUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      serviceName,
      cost,
      currency,
      billingCycle,
      startDate,
      nextBillingDate,
      serviceLogoPath,
      colorHex,
      isAutoRenew,
      isActive,
      logoUrl,
    );
  }
}
