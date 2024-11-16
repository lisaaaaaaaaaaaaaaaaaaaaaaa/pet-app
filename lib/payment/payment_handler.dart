import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/subscription_plan.dart';
import '../models/subscription.dart';
import '../services/subscription_manager.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../config/env.dart';

class PaymentHandler {
  final AnalyticsService _analytics;
  final SubscriptionManager _subscriptionManager;
  final AuthService _authService;

  PaymentHandler(this._subscriptionManager, this._authService, this._analytics);

  Future<bool> processSubscription({
    required BuildContext context,
    required SubscriptionPlan plan,
  }) async {
    try {
      // Get current user
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('Please sign in to subscribe');
      }

      // Create subscription on backend
      final response = await http.post(
        Uri.parse(Environment.createSubscriptionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await user.getIdToken()}',
        },
        body: json.encode({
          'plan': plan.id,
          'userId': user.uid,
          'email': user.email,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body)['error'];
        throw Exception(error ?? 'Failed to create subscription');
      }

      final data = json.decode(response.body);

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'Golden Years Pet Care',
          customerId: data['customer'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          style: ThemeMode.system,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Theme.of(context).primaryColor,
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
              shadow: PaymentSheetShadowParams(color: Colors.black),
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Create subscription object
      final subscription = Subscription(
        id: data['subscriptionId'],
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isTrialPeriod: false,
        isActive: true,
        price: plan.price,
        status: Subscription.STATUS_ACTIVE,
        customerId: data['customer'],
        subscriptionId: data['subscriptionId'],
      );

      // Activate subscription
      await _subscriptionManager.activateSubscription(subscription);

      // Log analytics event
      await _analytics.logSubscription(
        planId: plan.id,
        planName: plan.name,
        amount: plan.price,
        userId: user.uid,
      );

      _showSuccess(context);
      return true;

    } on StripeException catch (e) {
      _showError(context, 'Payment failed: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      _showError(context, e.toString());
      return false;
    }
  }

  Future<bool> cancelSubscription(BuildContext context) async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Please sign in to manage subscription');

      final currentSubscription = _subscriptionManager.currentSubscription;
      if (currentSubscription == null) {
        throw Exception('No active subscription found');
      }

      final response = await http.post(
        Uri.parse(Environment.cancelSubscriptionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await user.getIdToken()}',
        },
        body: json.encode({
          'subscriptionId': currentSubscription.subscriptionId,
          'userId': user.uid,
        }),
      );

      if (response.statusCode == 200) {
        await _subscriptionManager.cancelSubscription();
        _showSuccess(context, message: 'Subscription cancelled successfully');
        
        await _analytics.logCancellation(
          subscriptionId: currentSubscription.id,
          userId: user.uid,
          reason: 'user_initiated',
        );
        
        return true;
      } else {
        final error = json.decode(response.body)['error'];
        throw Exception(error ?? 'Failed to cancel subscription');
      }
    } catch (e) {
      _showError(context, e.toString());
      return false;
    }
  }

  Future<bool> updatePaymentMethod({
    required BuildContext context,
    required String paymentMethodId,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Please sign in to update payment method');

      final response = await http.post(
        Uri.parse(Environment.updatePaymentMethodUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await user.getIdToken()}',
        },
        body: json.encode({
          'paymentMethodId': paymentMethodId,
          'userId': user.uid,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess(context, message: 'Payment method updated successfully');
        return true;
      } else {
        final error = json.decode(response.body)['error'];
        throw Exception(error ?? 'Failed to update payment method');
      }
    } catch (e) {
      _showError(context, e.toString());
      return false;
    }
  }

  void _showSuccess(BuildContext context, {String message = 'Subscription successful!'}) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}