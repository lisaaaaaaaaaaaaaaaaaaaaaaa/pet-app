import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/payment_config.dart';

class StripeService {
  Future<void> initPayment({
    required String country,
    required String postalCode,
    required String state,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${PaymentConfig.apiUrl}/create-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'country': country,
          'postalCode': postalCode,
          'state': state,
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(jsonResponse['error']);
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Golden Years Pet App',
          paymentIntentClientSecret: jsonResponse['paymentIntent'],
          customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
          customerId: jsonResponse['customer'],
        ),
      );

      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }
}
