import 'package:flutter/material.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/home_screen.dart';
import '../models/subscription.dart';
import '../services/payment_handler.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case '/auth':
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      
      case '/payment':
        final subscription = Subscription(
          id: 'monthly_subscription',
          name: 'Monthly Subscription',
          description: 'Full access to all features',
          price: 999, // $9.99 in cents
          duration: const Duration(days: 30),
          features: const [
            'Unlimited Pet Profiles',
            'Health Tracking & Analytics',
            'Vet Appointment Scheduling',
            'Medication Reminders',
            '24/7 Vet Support',
          ],
        );
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            subscription: subscription,
            paymentHandler: (sub) async {
              // TODO: Implement actual payment processing
              await Future.delayed(const Duration(seconds: 2));
              return true;
            },
          ),
        );
      
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
