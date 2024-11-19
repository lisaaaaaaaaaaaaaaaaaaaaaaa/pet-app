// lib/models/subscription.dart


class Subscription {
  // Existing properties...
  // (keeping all the properties you already have)

  // New properties
  final String? customerId;
  final List<SubscriptionAddon> addons;
  final BillingSchedule billingSchedule;
  final List<PaymentHistory> paymentHistory;
  final SubscriptionLimits limits;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? referralCode;
  final int? trialDays;
  final bool isTrialUsed;

  Subscription({
    required this.id,
    required this.petId,
    required this.level,
    required this.startDate,
    this.expiryDate,
    this.autoRenew = true,
    this.status = 'active',
    required this.price,
    this.currency = 'USD',
    this.paymentMethod,
    this.features = const [],
    this.featureUsage = const {},
    this.promotionCode,
    this.discount,
    this.billingInfo,
    this.transactionHistory = const [],
    this.usage = const {},
    required this.lastBillingDate,
    this.nextBillingDate,
    this.cancellationReason,
    // New parameters
    this.customerId,
    this.addons = const [],
    this.billingSchedule = const BillingSchedule(),
    this.paymentHistory = const [],
    this.limits = const SubscriptionLimits(),
    this.metadata = const {},
    DateTime? createdAt,
    this.updatedAt,
    this.referralCode,
    this.trialDays,
    this.isTrialUsed = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Enhanced copyWith method
  Subscription copyWith({
    // Existing parameters...
    // (keeping all your existing copyWith parameters)
    
    // New parameters
    String? customerId,
    List<SubscriptionAddon>? addons,
    BillingSchedule? billingSchedule,
    List<PaymentHistory>? paymentHistory,
    SubscriptionLimits? limits,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? referralCode,
    int? trialDays,
    bool? isTrialUsed,
  }) {
    return Subscription(
      // Existing assignments...
      // (keeping all your existing assignments)
      
      // New assignments
      customerId: customerId ?? this.customerId,
      addons: addons ?? this.addons,
      billingSchedule: billingSchedule ?? this.billingSchedule,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      limits: limits ?? this.limits,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      referralCode: referralCode ?? this.referralCode,
      trialDays: trialDays ?? this.trialDays,
      isTrialUsed: isTrialUsed ?? this.isTrialUsed,
    );
  }

  // Enhanced toJson method
  Map<String, dynamic> toJson() {
    return {
      // Existing fields...
      // (keeping all your existing fields)
      
      // New fields
      'customerId': customerId,
      'addons': addons.map((addon) => addon.toJson()).toList(),
      'billingSchedule': billingSchedule.toJson(),
      'paymentHistory': paymentHistory.map((payment) => payment.toJson()).toList(),
      'limits': limits.toJson(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'referralCode': referralCode,
      'trialDays': trialDays,
      'isTrialUsed': isTrialUsed,
    };
  }

  // Enhanced fromJson factory
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      // Existing assignments...
      // (keeping all your existing assignments)
      
      // New assignments
      customerId: json['customerId'],
      addons: (json['addons'] as List?)
          ?.map((addon) => SubscriptionAddon.fromJson(addon))
          .toList() ?? [],
      billingSchedule: json['billingSchedule'] != null
          ? BillingSchedule.fromJson(json['billingSchedule'])
          : const BillingSchedule(),
      paymentHistory: (json['paymentHistory'] as List?)
          ?.map((payment) => PaymentHistory.fromJson(payment))
          .toList() ?? [],
      limits: json['limits'] != null
          ? SubscriptionLimits.fromJson(json['limits'])
          : const SubscriptionLimits(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      referralCode: json['referralCode'],
      trialDays: json['trialDays'],
      isTrialUsed: json['isTrialUsed'] ?? false,
    );
  }
  // Continuing lib/models/subscription.dart

class SubscriptionAddon {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final List<String> features;
  final DateTime activatedAt;
  final DateTime? expiresAt;
  final bool isActive;

  const SubscriptionAddon({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'USD',
    this.features = const [],
    required this.activatedAt,
    this.expiresAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'features': features,
      'activatedAt': activatedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory SubscriptionAddon.fromJson(Map<String, dynamic> json) {
    return SubscriptionAddon(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'USD',
      features: List<String>.from(json['features'] ?? []),
      activatedAt: DateTime.parse(json['activatedAt']),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }
}

class BillingSchedule {
  final String interval; // monthly, yearly, etc.
  final int intervalCount;
  final int? dayOfMonth;
  final bool prorated;
  final Map<String, dynamic> customSchedule;

  const BillingSchedule({
    this.interval = 'monthly',
    this.intervalCount = 1,
    this.dayOfMonth,
    this.prorated = true,
    this.customSchedule = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'interval': interval,
      'intervalCount': intervalCount,
      'dayOfMonth': dayOfMonth,
      'prorated': prorated,
      'customSchedule': customSchedule,
    };
  }

  factory BillingSchedule.fromJson(Map<String, dynamic> json) {
    return BillingSchedule(
      interval: json['interval'] ?? 'monthly',
      intervalCount: json['intervalCount'] ?? 1,
      dayOfMonth: json['dayOfMonth'],
      prorated: json['prorated'] ?? true,
      customSchedule: Map<String, dynamic>.from(json['customSchedule'] ?? {}),
    );
  }
}

class PaymentHistory {
  final String id;
  final DateTime date;
  final double amount;
  final String currency;
  final String status;
  final String? paymentMethod;
  final String? transactionId;
  final Map<String, dynamic> metadata;

  const PaymentHistory({
    required this.id,
    required this.date,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'metadata': metadata,
    };
  }

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

class SubscriptionLimits {
  final int maxPets;
  final int maxUsers;
  final int maxDocuments;
  final int maxPhotos;
  final Map<String, int> featureLimits;

  const SubscriptionLimits({
    this.maxPets = 1,
    this.maxUsers = 1,
    this.maxDocuments = 100,
    this.maxPhotos = 500,
    this.featureLimits = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'maxPets': maxPets,
      'maxUsers': maxUsers,
      'maxDocuments': maxDocuments,
      'maxPhotos': maxPhotos,
      'featureLimits': featureLimits,
    };
  }

  factory SubscriptionLimits.fromJson(Map<String, dynamic> json) {
    return SubscriptionLimits(
      maxPets: json['maxPets'] ?? 1,
      maxUsers: json['maxUsers'] ?? 1,
      maxDocuments: json['maxDocuments'] ?? 100,
      maxPhotos: json['maxPhotos'] ?? 500,
      featureLimits: Map<String, int>.from(json['featureLimits'] ?? {}),
    );
  }
}

// Additional helper methods for the Subscription class
extension SubscriptionHelpers on Subscription {
  bool isInTrial() {
    if (trialDays == null || isTrialUsed) return false;
    final trialEnd = startDate.add(Duration(days: trialDays!));
    return DateTime.now().isBefore(trialEnd);
  }

  int? getRemainingTrialDays() {
    if (!isInTrial()) return null;
    final trialEnd = startDate.add(Duration(days: trialDays!));
    return trialEnd.difference(DateTime.now()).inDays;
  }

  double getTotalPrice() {
    double total = getDiscountedPrice();
    for (var addon in addons) {
      if (addon.isActive) {
        total += addon.price;
      }
    }
    return total;
  }

  bool hasReachedLimit(String feature) {
    if (!limits.featureLimits.containsKey(feature)) return false;
    return (usage[feature] ?? 0) >= limits.featureLimits[feature]!;
  }

  List<String> getActiveFeatures() {
    final activeFeatures = [...features];
    for (var addon in addons) {
      if (addon.isActive) {
        activeFeatures.addAll(addon.features);
      }
    }
    return activeFeatures.toSet().toList(); // Remove duplicates
  }

  bool needsPaymentUpdate() {
    if (!isActive()) return false;
    if (paymentMethod == null) return true;
    return paymentHistory.isNotEmpty && 
           paymentHistory.last.status.toLowerCase() == 'failed';
  }

  String getFormattedNextBillingAmount() {
    return '${currency.toUpperCase()} ${getTotalPrice().toStringAsFixed(2)}';
  }

  Map<String, dynamic> getUsageReport() {
    return {
      'period': {
        'start': lastBillingDate.toIso8601String(),
        'end': nextBillingDate?.toIso8601String(),
      },
      'limits': limits.toJson(),
      'currentUsage': usage,
      'utilizationPercentage': Map.fromEntries(
        limits.featureLimits.entries.map((e) => MapEntry(
          e.key,
          ((usage[e.key] ?? 0) / e.value * 100).toStringAsFixed(1) + '%',
        )),
      ),
    };
  }
}