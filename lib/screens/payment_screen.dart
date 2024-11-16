import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription_plan.dart';
import '../payment/payment_handler.dart';
import '../services/subscription_manager.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subscriptionManager = Provider.of<SubscriptionManager>(context);
    final authService = Provider.of<AuthService>(context);
    final analyticsService = Provider.of<AnalyticsService>(context);
    final paymentHandler = PaymentHandler(subscriptionManager, authService, analyticsService);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Subscription'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Golden Years Premium',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.pets,
                        text: 'Unlimited Pet Profiles',
                        description: 'Add as many pets as you want',
                      ),
                      _buildFeatureItem(
                        icon: Icons.health_and_safety,
                        text: 'Advanced Health Tracking',
                        description: 'Detailed health monitoring',
                      ),
                      _buildFeatureItem(
                        icon: Icons.support_agent,
                        text: 'Priority Support',
                        description: '24/7 premium customer service',
                      ),
                      _buildFeatureItem(
                        icon: Icons.analytics,
                        text: 'Health Analytics',
                        description: 'Detailed health insights',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '\$10.00',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const Text('per month'),
                      const SizedBox(height: 8),
                      const Text(
                        'Cancel anytime',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: () => _handleSubscription(context, paymentHandler),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Subscribe Now',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                'By subscribing, you agree to our terms and conditions. '
                'You can cancel your subscription at any time.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscription(
    BuildContext context,
    PaymentHandler paymentHandler,
  ) async {
    try {
      final success = await paymentHandler.processSubscription(
        context: context,
        plan: SubscriptionPlan.monthly,
      );

      if (success && context.mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}