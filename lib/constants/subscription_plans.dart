import '../models/subscription.dart';

class SubscriptionPlans {
  static const Subscription premium = Subscription(
    id: 'premium_monthly',
    name: 'Premium Plan',
    description: 'Unlimited access to all features',
    price: 999, // $9.99 in cents
    duration: Duration(days: 30),
    features: [
      'Unlimited pet profiles',
      'Health tracking & reminders',
      'Vet appointment scheduling',
      'Premium support',
    ],
  );

  static const Subscription basic = Subscription(
    id: 'basic_free',
    name: 'Basic Plan',
    description: 'Basic features for one pet',
    price: 0,
    duration: Duration(days: 30),
    features: [
      'One pet profile',
      'Basic health tracking',
      'Community support',
    ],
  );
}
