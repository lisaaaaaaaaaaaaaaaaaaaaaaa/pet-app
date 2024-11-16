class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String interval;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    this.interval = 'month',
  });

  static const monthly = SubscriptionPlan(
    id: 'price_monthly',
    name: 'Golden Years Premium',
    description: 'Complete Pet Care Management System',
    price: 10.00,
    features: [
      'Unlimited Pet Profiles',
      'Advanced Health Tracking',
      'Priority Support',
      'Health Analytics',
      'Medication Reminders',
      'Vet Visit History',
      'Diet Tracking',
      'Behavior Monitoring'
    ],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'interval': interval,
    'features': features,
  };

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as double,
      interval: json['interval'] as String? ?? 'month',
      features: List<String>.from(json['features'] as List),
    );
  }
}
