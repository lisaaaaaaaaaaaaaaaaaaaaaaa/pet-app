import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/subscription.dart';
import '../services/subscription_manager.dart';
import '../services/analytics_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentHandler {
  final SubscriptionManager _subscriptionManager;
  final AnalyticsService _analytics;
  final String _apiUrl = 'YOUR_API_URL'; // Replace with your actual API URL

  PaymentHandler({
    required SubscriptionManager subscriptionManager,
    required AnalyticsService analytics,
  })  : _subscriptionManager = subscriptionManager,
        _analytics = analytics;

  Future<void> startSubscription(BuildContext context, Subscription subscription) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create payment intent
      final paymentIntentResult = await _createPaymentIntent(
        amount: subscription.price,
        currency: 'usd',
        customerId: user.uid,
      );

      if (paymentIntentResult == null) throw Exception('Failed to create payment intent');

      // Confirm payment with Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentResult['clientSecret'],
          merchantDisplayName: 'Golden Years',
          customerId: user.uid,
          customerEphemeralKeySecret: paymentIntentResult['ephemeralKey'],
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // If we get here, payment was successful
      await _subscriptionManager.activateSubscription(subscription);
      
      // Log successful subscription
      await _analytics.logSubscription(
        id: subscription.id,
        amount: subscription.price,
        currency: 'usd',
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription activated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }

  Future<void> cancelCurrentSubscription(BuildContext context) async {
    try {
      final currentSubscription = _subscriptionManager.currentSubscription;
      if (currentSubscription == null) {
        throw Exception('No active subscription found');
      }

      // Call your backend to cancel the subscription
      final response = await http.post(
        Uri.parse('$_apiUrl/cancel-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subscriptionId': currentSubscription.id,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel subscription');
      }

      // Update local subscription status
      await _subscriptionManager.cancelSubscription();

      // Log cancellation
      await _analytics.logCancellation(
        id: currentSubscription.id,
        reason: 'user_initiated',
      );

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription cancelled successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _createPaymentIntent({
    required int amount,
    required String currency,
    required String customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
          'customer': customerId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }
}
