import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import '../config/env.dart';

class StripeService {
  static Future<void> initialize() async {
    try {
      Stripe.publishableKey = Environment.stripePublishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Error initializing Stripe: $e');
      rethrow;
    }
  }

  static Future<PaymentMethod> createPaymentMethod({
    required String number,
    required int expMonth,
    required int expYear,
    required String cvc,
    String? name,
    BillingDetails? billingDetails,
  }) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails ?? BillingDetails(name: name),
          ),
        ),
      );
      return paymentMethod;
    } catch (e) {
      debugPrint('Error creating payment method: $e');
      rethrow;
    }
  }

  static Future<void> confirmPayment({
    required String paymentIntentClientSecret,
    BillingDetails? billingDetails,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret,
        PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails ?? const BillingDetails(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      rethrow;
    }
  }

  static Future<void> initPaymentSheet({
    required String paymentIntentClientSecret,
    required String customerId,
    required String customerEphemeralKeySecret,
    String? merchantDisplayName,
    ThemeMode? themeMode,
    PaymentSheetAppearance? appearance,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: merchantDisplayName ?? 'Golden Years Pet Care',
          customerId: customerId,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          style: themeMode ?? ThemeMode.system,
          appearance: appearance ?? _defaultAppearance(),
        ),
      );
    } catch (e) {
      debugPrint('Error initializing payment sheet: $e');
      rethrow;
    }
  }

  static Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      debugPrint('Error presenting payment sheet: $e');
      rethrow;
    }
  }

  static Future<void> confirmPaymentSheetPayment() async {
    try {
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      debugPrint('Error confirming payment sheet payment: $e');
      rethrow;
    }
  }

  static Future<PaymentIntent> retrievePaymentIntent(String clientSecret) async {
    try {
      return await Stripe.instance.retrievePaymentIntent(clientSecret);
    } catch (e) {
      debugPrint('Error retrieving payment intent: $e');
      rethrow;
    }
  }

  static Future<bool> handleCardAction(String paymentIntentClientSecret) async {
    try {
      final paymentIntent = await Stripe.instance.handleNextAction(paymentIntentClientSecret);
      return paymentIntent.status == PaymentIntentsStatus.Succeeded;
    } catch (e) {
      debugPrint('Error handling card action: $e');
      return false;
    }
  }

  static PaymentSheetAppearance _defaultAppearance() {
    return PaymentSheetAppearance(
      colors: PaymentSheetAppearanceColors(
        primary: Colors.blue,
        background: Colors.white,
        componentBackground: Colors.grey[200],
        componentText: Colors.black,
        primaryText: Colors.black,
        secondaryText: Colors.grey[700],
        componentDivider: Colors.grey[400],
      ),
      shapes: PaymentSheetShape(
        borderRadius: 12,
        borderWidth: 1,
        shadow: PaymentSheetShadowParams(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ),
      primaryButton: const PaymentSheetPrimaryButtonAppearance(
        colors: PaymentSheetPrimaryButtonTheme(
          light: PaymentSheetPrimaryButtonThemeColors(
            background: Colors.blue,
            text: Colors.white,
          ),
          dark: PaymentSheetPrimaryButtonThemeColors(
            background: Colors.blue,
            text: Colors.white,
          ),
        ),
        shapes: PaymentSheetPrimaryButtonShape(
          blurRadius: 8,
          borderRadius: 8,
        ),
      ),
    );
  }

  static Future<CardFieldInputDetails?> createToken({
    required String number,
    required int expMonth,
    required int expYear,
    required String cvc,
  }) async {
    try {
      final cardField = CardField(
        onCardChanged: (card) {},
      );
      
      cardField.onCardChanged(CardFieldInputDetails(
        complete: true,
        number: number,
        expiryMonth: expMonth,
        expiryYear: expYear,
        cvc: cvc,
      ));

      return await cardField.displayedCardDetails;
    } catch (e) {
      debugPrint('Error creating token: $e');
      return null;
    }
  }

  static Future<void> clearPaymentSheet() async {
    try {
      await Stripe.instance.resetPaymentSheetCustomer();
    } catch (e) {
      debugPrint('Error clearing payment sheet: $e');
    }
  }

  static String? getErrorMessage(StripeException e) {
    switch (e.error.code) {
      case FailureCode.Canceled:
        return 'Payment cancelled';
      case FailureCode.Failed:
        return 'Payment failed: ${e.error.localizedMessage}';
      case FailureCode.InvalidRequestError:
        return 'Invalid payment details';
      default:
        return e.error.localizedMessage;
    }
  }
}