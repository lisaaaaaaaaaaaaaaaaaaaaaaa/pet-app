import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/payment_handler.dart';
import '../theme/app_theme.dart';

class PaymentScreen extends StatelessWidget {
  final Subscription subscription;
  final PaymentHandler paymentHandler;

  const PaymentScreen({
    Key? key,
    required this.subscription,
    required this.paymentHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Subscribe to ${subscription.name}',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Price: \$${(subscription.price / 100).toStringAsFixed(2)}/month',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                try {
                  final success = await paymentHandler(subscription);
                  if (success && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment failed. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Process Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
