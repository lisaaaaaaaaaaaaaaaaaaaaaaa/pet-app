import 'package:flutter/material.dart';
import 'stripe_service.dart';
import '../models/subscription_plan.dart';
import '../services/analytics_service.dart';

class PaymentHandler {
  final AnalyticsService _analytics = AnalyticsService();

  Future<bool> processPayment({
    required BuildContext context,
    required SubscriptionPlan plan,
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvc,
  }) async {
    try {
      // Create payment method
      final paymentMethod = await StripeService.createPaymentMethod(
        number: cardNumber,
        expMonth: expMonth,
        expYear: expYear,
        cvc: cvc,
      );

      // Create payment intent on your server
      final clientSecret = await _createPaymentIntent(plan);

      // Confirm payment
      final paymentResult = await StripeService.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        paymentMethod: paymentMethod,
      );

      if (paymentResult.status == 'succeeded') {
        await _analytics.logSubscription(
          planId: plan.id,
          planName: plan.name,
          amount: plan.price,
        );
        return true;
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      _showError(context, e.toString());
      return false;
    }
  }

  Future<String> _createPaymentIntent(SubscriptionPlan plan) async {
    // Implement your server call to create payment intent
    throw UnimplementedError();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
