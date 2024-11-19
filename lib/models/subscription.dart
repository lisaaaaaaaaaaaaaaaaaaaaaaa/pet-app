class Subscription {
  final String id;
  final String name;
  final String description;
  final int price;  // in cents
  final Duration duration;
  final List<String> features;

  const Subscription({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.features,
  });

  // From JSON
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      duration: Duration(days: json['duration_days'] as int),
      features: List<String>.from(json['features'] as List),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_days': duration.inDays,
      'features': features,
    };
  }
}
