class Subscription {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isTrialPeriod;
  final bool isActive;
  final double price;
  final String status;

  Subscription({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.isTrialPeriod,
    required this.isActive,
    this.price = 10.0,
    required this.status,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isTrialPeriod: json['isTrialPeriod'] ?? false,
      isActive: json['isActive'] ?? false,
      price: json['price']?.toDouble() ?? 10.0,
      status: json['status'],
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
  }) {
    return Subscription(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isTrialPeriod: isTrialPeriod ?? this.isTrialPeriod,
      isActive: isActive ?? this.isActive,
      price: price ?? this.price,
      status: status ?? this.status,
    );
  }
}
