class Subscription {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isTrialPeriod;
  final bool isActive;
  final double price;
  final String status;
  final String? customerId; // Add this for Stripe integration
  final String? subscriptionId; // Add this for Stripe integration

  // Add subscription status constants
  static const String STATUS_ACTIVE = 'active';
  static const String STATUS_CANCELED = 'canceled';
  static const String STATUS_INCOMPLETE = 'incomplete';
  static const String STATUS_TRIAL = 'trial';
  static const String STATUS_EXPIRED = 'expired';

  const Subscription({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.isTrialPeriod,
    required this.isActive,
    this.price = 10.0,
    required this.status,
    this.customerId,
    this.subscriptionId,
  });

  // Add computed properties
  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);
  int get daysRemaining => endDate?.difference(DateTime.now()).inDays ?? 0;
  bool get needsRenewal => daysRemaining <= 3;
  
  // Factory constructor for trial subscription
  factory Subscription.trial() {
    final now = DateTime.now();
    return Subscription(
      id: 'trial_${DateTime.now().millisecondsSinceEpoch}',
      startDate: now,
      endDate: now.add(const Duration(days: 7)),
      isTrialPeriod: true,
      isActive: true,
      status: STATUS_TRIAL,
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isTrialPeriod: json['isTrialPeriod'] ?? false,
      isActive: json['isActive'] ?? false,
      price: json['price']?.toDouble() ?? 10.0,
      status: json['status'],
      customerId: json['customerId'],
      subscriptionId: json['subscriptionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isTrialPeriod': isTrialPeriod,
      'isActive': isActive,
      'price': price,
      'status': status,
      'customerId': customerId,
      'subscriptionId': subscriptionId,
    };
  }

  Subscription copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    bool? isTrialPeriod,
    bool? isActive,
    double? price,
    String? status,
    String? customerId,
    String? subscriptionId,
  }) {
    return Subscription(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isTrialPeriod: isTrialPeriod ?? this.isTrialPeriod,
      isActive: isActive ?? this.isActive,
      price: price ?? this.price,
      status: status ?? this.status,
      customerId: customerId ?? this.customerId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscription &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Subscription(id: $id, status: $status, isActive: $isActive, '
      'daysRemaining: $daysRemaining)';
}