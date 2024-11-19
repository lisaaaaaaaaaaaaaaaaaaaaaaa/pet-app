import 'package:flutter/material.dart';
import '../payment/stripe_service.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SubscriptionTestScreen extends StatelessWidget {
  const SubscriptionTestScreen({super.key});

  Future<void> _testSubscription(BuildContext context) async {
    try {
      final functions = FirebaseFunctions.instance;
      final result = await functions.httpsCallable('createSubscription').call();

      await StripeService.initPaymentSheet(
        paymentIntentClientSecret: result.data['paymentIntent'],
        customerId: result.data['customer'],
        customerEphemeralKeySecret: result.data['ephemeralKey'],
        merchantDisplayName: 'Golden Years Pet Care',
      );

      await StripeService.presentPaymentSheet();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Subscription')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _testSubscription(context),
          child: const Text('Test \$10 Subscription'),
        ),
      ),
    );
  }
}